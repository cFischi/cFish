# Deploy Monitoring System Script for cFish Process Visualization
# This script sets up and configures the monitoring system for production deployment
# Version: 1.0.0
# Date: 05-07-2025

param (
    [string]$ConfigPath = "$PSScriptRoot\..\config\monitoring",
    [string]$LogPath = "$PSScriptRoot\..\logs\monitoring",
    [int]$UpdateInterval = 30, # seconds
    [int]$MemoryThresholdWarning = 75, # percentage
    [int]$MemoryThresholdCritical = 85, # percentage
    [int]$ProcessThresholdWarning = 200, # count
    [int]$ProcessThresholdCritical = 250, # count
    [switch]$EnableSmsAlerts = $false,
    [switch]$EnableEmailAlerts = $true,
    [switch]$RunDashboard = $true
)

#region Setup
# Ensure directories exist
if (-not (Test-Path $ConfigPath)) {
    New-Item -Path $ConfigPath -ItemType Directory -Force | Out-Null
}

if (-not (Test-Path $LogPath)) {
    New-Item -Path $LogPath -ItemType Directory -Force | Out-Null
}

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$logFile = Join-Path $LogPath "monitoring-deploy-$timestamp.log"
$configFile = Join-Path $ConfigPath "monitoring-config.json"
$alertConfigFile = Join-Path $ConfigPath "alert-config.json"
$metricsFile = Join-Path $LogPath "system-metrics.json"
$dashboardScript = Join-Path $PSScriptRoot "start-monitoring-dashboard.ps1"

function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    $logTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$logTime] [$Level] $Message"
    
    Add-Content -Path $logFile -Value $logMessage
    
    switch ($Level) {
        "ERROR" { Write-Host $logMessage -ForegroundColor Red }
        "WARNING" { Write-Host $logMessage -ForegroundColor Yellow }
        "SUCCESS" { Write-Host $logMessage -ForegroundColor Green }
        default { Write-Host $logMessage }
    }
}

Write-Log "Starting monitoring system deployment" -Level "INFO"
#endregion

#region Configuration Creation
Write-Log "Creating monitoring system configuration" -Level "INFO"

# Create main configuration file
$monitoringConfig = @{
    UpdateInterval = $UpdateInterval
    Thresholds = @{
        Memory = @{
            Warning = $MemoryThresholdWarning
            Critical = $MemoryThresholdCritical
        }
        Process = @{
            Warning = $ProcessThresholdWarning
            Critical = $ProcessThresholdCritical
        }
        CPU = @{
            Warning = 70
            Critical = 85
        }
        Disk = @{
            Warning = 80
            Critical = 90
        }
    }
    Monitoring = @{
        Processes = @{
            Enabled = $true
            IncludedTypes = @("cursor", "node", "system")
            ProtectedProcesses = @("explorer", "winlogon", "wininit", "services", "lsass")
        }
        Resources = @{
            Enabled = $true
            MonitorItems = @("memory", "cpu", "disk", "network")
        }
        Applications = @{
            Enabled = $true
            MonitoredApps = @("ProcessTreeVisualization", "AlertCorrelationEngine", "QueuePrioritySystem", "MonitoringDashboard")
        }
    }
    Logging = @{
        Enabled = $true
        RetentionDays = 7
        LogLevel = "INFO"
        MaxLogSizeMB = 10
        RotateCount = 5
    }
    Reporting = @{
        Enabled = $true
        IntervalHours = 24
        Format = "HTML"
        IncludeMetrics = $true
        IncludeCharts = $true
    }
    Dashboard = @{
        RefreshInterval = 5
        DefaultView = "System"
        AvailableViews = @("System", "Process", "Application", "Integration")
        DataRetentionDays = 7
    }
}

# Create alert configuration file
$alertConfig = @{
    Enabled = $true
    Channels = @{
        Email = @{
            Enabled = $EnableEmailAlerts
            Recipients = @("admin@cfish.io", "alerts@cfish.io")
            SmtpServer = "smtp.cfish.io"
            SmtpPort = 587
            UseTLS = $true
            FromAddress = "alerts@cfish.io"
            Subject = "cFish.io Monitoring Alert"
        }
        SMS = @{
            Enabled = $EnableSmsAlerts
            Recipients = @("+19876543210")
            Provider = "Twilio"
        }
        Dashboard = @{
            Enabled = $true
            HighlightCritical = $true
            PlaySound = $true
        }
    }
    Rules = @{
        MemoryWarning = @{
            Condition = "Memory usage exceeds $MemoryThresholdWarning%"
            Level = "WARNING"
            Cooldown = 300 # seconds
            Actions = @("Dashboard", "Email")
            Message = "System memory usage is high"
        }
        MemoryCritical = @{
            Condition = "Memory usage exceeds $MemoryThresholdCritical%"
            Level = "CRITICAL"
            Cooldown = 120 # seconds
            Actions = @("Dashboard", "Email", "SMS")
            Message = "CRITICAL: System memory usage"
            AutoRemediate = $true
            RemediationScript = "remediate-memory.ps1"
        }
        ProcessCountWarning = @{
            Condition = "Process count exceeds $ProcessThresholdWarning"
            Level = "WARNING"
            Cooldown = 300 # seconds
            Actions = @("Dashboard", "Email")
            Message = "Process count is high"
        }
        ProcessCountCritical = @{
            Condition = "Process count exceeds $ProcessThresholdCritical"
            Level = "CRITICAL"
            Cooldown = 120 # seconds
            Actions = @("Dashboard", "Email", "SMS")
            Message = "CRITICAL: Process count is very high"
            AutoRemediate = $true
            RemediationScript = "remediate-processes.ps1"
        }
        ComponentDown = @{
            Condition = "Component status is DOWN"
            Level = "CRITICAL"
            Cooldown = 60 # seconds
            Actions = @("Dashboard", "Email", "SMS")
            Message = "CRITICAL: Component is down"
            AutoRemediate = $true
            RemediationScript = "restart-component.ps1"
        }
    }
}

# Write configurations to files
$monitoringConfig | ConvertTo-Json -Depth 10 | Set-Content -Path $configFile
$alertConfig | ConvertTo-Json -Depth 10 | Set-Content -Path $alertConfigFile

Write-Log "Configuration files created successfully" -Level "SUCCESS"
#endregion

#region Deploy Monitoring Service
Write-Log "Deploying monitoring service" -Level "INFO"

# Create a Windows service or scheduled task for the monitoring script
try {
    # Prepare the monitoring command
    $monitorCmd = "powershell.exe -ExecutionPolicy Bypass -File `"$PSScriptRoot\monitor-system.ps1`" -ConfigPath `"$ConfigPath`" -LogPath `"$LogPath`" -NoProfile -WindowStyle Hidden"
    
    # Remove existing task if it exists
    $taskName = "cFishSystemMonitoring"
    $taskExists = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
    if ($taskExists) {
        Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
        Write-Log "Removed existing scheduled task: $taskName" -Level "INFO"
    }
    
    # Create a scheduled task that runs every minute
    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$PSScriptRoot\monitor-system.ps1`" -ConfigPath `"$ConfigPath`" -LogPath `"$LogPath`" -NoProfile -WindowStyle Hidden"
    $trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 1)
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -Hidden -ExecutionTimeLimit (New-TimeSpan -Minutes 5)
    
    Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -RunLevel Highest
    Write-Log "Created scheduled task for system monitoring" -Level "SUCCESS"
} catch {
    Write-Log "Failed to create scheduled task: $($_.Exception.Message)" -Level "ERROR"
}
#endregion

#region Deploy Monitoring Dashboard
if ($RunDashboard) {
    Write-Log "Deploying monitoring dashboard" -Level "INFO"
    
    # Create dashboard script if it doesn't exist
    if (-not (Test-Path $dashboardScript)) {
        $dashboardScriptContent = @"
# Monitoring Dashboard Script
# This script starts the real-time monitoring dashboard
# Version: 1.0.0

param (
    [string]`$ConfigPath = "$ConfigPath",
    [string]`$MetricsPath = "$LogPath",
    [int]`$RefreshInterval = 5
)

`$dashboardConfig = Get-Content -Path "`$ConfigPath\monitoring-config.json" | ConvertFrom-Json
`$metricsFile = Join-Path `$MetricsPath "system-metrics.json"

# Launch the dashboard application
try {
    npm run start:dashboard -- --config="`$ConfigPath\monitoring-config.json" --metrics="`$metricsFile" --refresh=`$RefreshInterval
} catch {
    Write-Host "Error starting dashboard: `$(`$_.Exception.Message)" -ForegroundColor Red
    exit 1
}
"@
        
        Set-Content -Path $dashboardScript -Value $dashboardScriptContent
        Write-Log "Created dashboard startup script" -Level "SUCCESS"
    }
    
    # Launch the dashboard in a new window
    try {
        Start-Process -FilePath "powershell.exe" -ArgumentList "-ExecutionPolicy Bypass -File `"$dashboardScript`"" -WindowStyle Normal
        Write-Log "Launched monitoring dashboard" -Level "SUCCESS"
    } catch {
        Write-Log "Failed to launch monitoring dashboard: $($_.Exception.Message)" -Level "ERROR"
    }
}
#endregion

#region Create Monitor Script
$monitorScriptPath = Join-Path $PSScriptRoot "monitor-system.ps1"
if (-not (Test-Path $monitorScriptPath)) {
    Write-Log "Creating monitoring script" -Level "INFO"
    
    $monitorScriptContent = @"
# System Monitoring Script
# This script collects system metrics and triggers alerts based on thresholds
# Version: 1.0.0

param (
    [string]`$ConfigPath = "$ConfigPath",
    [string]`$LogPath = "$LogPath"
)

# Load configuration
`$configFile = Join-Path `$ConfigPath "monitoring-config.json"
`$alertConfigFile = Join-Path `$ConfigPath "alert-config.json"
`$metricsFile = Join-Path `$LogPath "system-metrics.json"
`$logFile = Join-Path `$LogPath "monitoring.log"

function Write-Log {
    param(
        [string]`$Message,
        [string]`$Level = "INFO"
    )
    
    `$logTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    `$logMessage = "[`$logTime] [`$Level] `$Message"
    
    Add-Content -Path `$logFile -Value `$logMessage
}

# Check if configuration exists
if (-not (Test-Path `$configFile)) {
    Write-Log "Configuration file not found: `$configFile" -Level "ERROR"
    exit 1
}

if (-not (Test-Path `$alertConfigFile)) {
    Write-Log "Alert configuration file not found: `$alertConfigFile" -Level "ERROR"
    exit 1
}

# Load configurations
try {
    `$config = Get-Content -Path `$configFile | ConvertFrom-Json
    `$alertConfig = Get-Content -Path `$alertConfigFile | ConvertFrom-Json
    Write-Log "Loaded configuration files successfully" -Level "INFO"
} catch {
    Write-Log "Failed to load configuration: `$(`$_.Exception.Message)" -Level "ERROR"
    exit 1
}

# Initialize metrics storage
`$metrics = @{
    Timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
    SystemMetrics = @{
        Memory = @{
            Total = 0
            Used = 0
            UsedPercent = 0
            Available = 0
        }
        CPU = @{
            LoadPercent = 0
            Temperature = 0
        }
        Disk = @{
            Total = 0
            Used = 0
            UsedPercent = 0
            Available = 0
        }
        Network = @{
            BytesSent = 0
            BytesReceived = 0
            ConnectionCount = 0
        }
    }
    ProcessMetrics = @{
        TotalCount = 0
        CursorCount = 0
        NodeCount = 0
        SystemCount = 0
        HighMemoryCount = 0
        HighCpuCount = 0
        ProcessList = @()
    }
    ApplicationMetrics = @{
        Components = @()
    }
    AlertHistory = @()
}

# Collect system metrics
function Get-SystemMetrics {
    # Get memory information
    `$osInfo = Get-CimInstance -ClassName Win32_OperatingSystem
    `$totalMemoryMB = [math]::Round(`$osInfo.TotalVisibleMemorySize / 1024, 2)
    `$freeMemoryMB = [math]::Round(`$osInfo.FreePhysicalMemory / 1024, 2)
    `$usedMemoryMB = `$totalMemoryMB - `$freeMemoryMB
    `$memoryUsedPercent = [math]::Round((`$usedMemoryMB / `$totalMemoryMB) * 100, 2)
    
    # Get CPU information
    `$cpuLoad = (Get-CimInstance -ClassName Win32_Processor | Measure-Object -Property LoadPercentage -Average).Average
    
    # Get disk information
    `$systemDrive = `$env:SystemDrive
    `$driveInfo = Get-PSDrive -Name `$systemDrive.Substring(0, 1)
    `$totalSpaceGB = [math]::Round(`$driveInfo.Used / 1GB + `$driveInfo.Free / 1GB, 2)
    `$usedSpaceGB = [math]::Round(`$driveInfo.Used / 1GB, 2)
    `$freeSpaceGB = [math]::Round(`$driveInfo.Free / 1GB, 2)
    `$diskUsedPercent = [math]::Round((`$usedSpaceGB / `$totalSpaceGB) * 100, 2)
    
    # Get network information
    `$networkInfo = Get-NetAdapterStatistics | Where-Object { `$_.ReceivedBytes -gt 0 }
    `$bytesSent = (`$networkInfo | Measure-Object -Property SentBytes -Sum).Sum
    `$bytesReceived = (`$networkInfo | Measure-Object -Property ReceivedBytes -Sum).Sum
    `$connections = (Get-NetTCPConnection | Measure-Object).Count
    
    # Update metrics object
    `$metrics.SystemMetrics.Memory.Total = `$totalMemoryMB
    `$metrics.SystemMetrics.Memory.Used = `$usedMemoryMB
    `$metrics.SystemMetrics.Memory.UsedPercent = `$memoryUsedPercent
    `$metrics.SystemMetrics.Memory.Available = `$freeMemoryMB
    
    `$metrics.SystemMetrics.CPU.LoadPercent = `$cpuLoad
    
    `$metrics.SystemMetrics.Disk.Total = `$totalSpaceGB
    `$metrics.SystemMetrics.Disk.Used = `$usedSpaceGB
    `$metrics.SystemMetrics.Disk.UsedPercent = `$diskUsedPercent
    `$metrics.SystemMetrics.Disk.Available = `$freeSpaceGB
    
    `$metrics.SystemMetrics.Network.BytesSent = `$bytesSent
    `$metrics.SystemMetrics.Network.BytesReceived = `$bytesReceived
    `$metrics.SystemMetrics.Network.ConnectionCount = `$connections
    
    Write-Log "Collected system metrics" -Level "INFO"
}

# Collect process metrics
function Get-ProcessMetrics {
    # Get all processes with memory information
    `$processes = Get-Process | Select-Object Name, Id, WorkingSet, CPU, Description
    
    # Count processes by type
    `$cursorProcesses = `$processes | Where-Object { `$_.Name -like "*cursor*" }
    `$nodeProcesses = `$processes | Where-Object { `$_.Name -like "*node*" }
    `$systemProcesses = `$processes | Where-Object { `$_.Name -in @("explorer", "winlogon", "wininit", "services", "lsass") }
    
    # Find high memory processes
    `$highMemoryThresholdMB = `$config.Thresholds.Memory.Warning * 10 # Example threshold
    `$highMemoryProcesses = `$processes | Where-Object { `$_.WorkingSet / 1MB -gt `$highMemoryThresholdMB }
    
    # Prepare process list
    `$processList = @()
    foreach (`$proc in `$processes | Sort-Object WorkingSet -Descending | Select-Object -First 20) {
        `$type = "other"
        if (`$proc.Name -like "*cursor*") { `$type = "cursor" }
        elseif (`$proc.Name -like "*node*") { `$type = "node" }
        elseif (`$proc.Name -in @("explorer", "winlogon", "wininit", "services", "lsass")) { `$type = "system" }
        
        `$memoryMB = [math]::Round(`$proc.WorkingSet / 1MB, 2)
        
        `$processList += @{
            Name = `$proc.Name
            Id = `$proc.Id
            MemoryMB = `$memoryMB
            CPU = `$proc.CPU
            Type = `$type
            Protected = `$proc.Name -in `$config.Monitoring.Processes.ProtectedProcesses
        }
    }
    
    # Update metrics object
    `$metrics.ProcessMetrics.TotalCount = `$processes.Count
    `$metrics.ProcessMetrics.CursorCount = `$cursorProcesses.Count
    `$metrics.ProcessMetrics.NodeCount = `$nodeProcesses.Count
    `$metrics.ProcessMetrics.SystemCount = `$systemProcesses.Count
    `$metrics.ProcessMetrics.HighMemoryCount = `$highMemoryProcesses.Count
    `$metrics.ProcessMetrics.ProcessList = `$processList
    
    Write-Log "Collected process metrics" -Level "INFO"
}

# Check for alert conditions
function Check-AlertConditions {
    `$triggeredAlerts = @()
    
    # Check memory warning threshold
    if (`$metrics.SystemMetrics.Memory.UsedPercent -ge `$config.Thresholds.Memory.Warning) {
        `$triggeredAlerts += @{
            Rule = "MemoryWarning"
            Level = "WARNING"
            Message = "Memory usage is `$(`$metrics.SystemMetrics.Memory.UsedPercent)% (threshold: `$(`$config.Thresholds.Memory.Warning)%)"
            Timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
        }
    }
    
    # Check memory critical threshold
    if (`$metrics.SystemMetrics.Memory.UsedPercent -ge `$config.Thresholds.Memory.Critical) {
        `$triggeredAlerts += @{
            Rule = "MemoryCritical"
            Level = "CRITICAL"
            Message = "CRITICAL: Memory usage is `$(`$metrics.SystemMetrics.Memory.UsedPercent)% (threshold: `$(`$config.Thresholds.Memory.Critical)%)"
            Timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
        }
    }
    
    # Check process warning threshold
    if (`$metrics.ProcessMetrics.TotalCount -ge `$config.Thresholds.Process.Warning) {
        `$triggeredAlerts += @{
            Rule = "ProcessCountWarning"
            Level = "WARNING"
            Message = "Process count is `$(`$metrics.ProcessMetrics.TotalCount) (threshold: `$(`$config.Thresholds.Process.Warning))"
            Timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
        }
    }
    
    # Check process critical threshold
    if (`$metrics.ProcessMetrics.TotalCount -ge `$config.Thresholds.Process.Critical) {
        `$triggeredAlerts += @{
            Rule = "ProcessCountCritical"
            Level = "CRITICAL"
            Message = "CRITICAL: Process count is `$(`$metrics.ProcessMetrics.TotalCount) (threshold: `$(`$config.Thresholds.Process.Critical))"
            Timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
        }
    }
    
    # Add triggered alerts to history and take actions
    foreach (`$alert in `$triggeredAlerts) {
        Write-Log "Alert triggered: `$(`$alert.Message)" -Level `$alert.Level
        `$metrics.AlertHistory += `$alert
        
        # Trigger alert actions based on configuration
        # (In a real implementation, this would send emails, SMS, etc.)
    }
    
    return `$triggeredAlerts
}

# Main monitoring loop
Write-Log "Starting monitoring loop" -Level "INFO"

# Collect metrics
Get-SystemMetrics
Get-ProcessMetrics

# Check for alerts
`$alerts = Check-AlertConditions

# Save metrics to file
`$metrics | ConvertTo-Json -Depth 10 | Set-Content -Path `$metricsFile

Write-Log "Metrics saved to `$metricsFile" -Level "INFO"
"@
    
    Set-Content -Path $monitorScriptPath -Value $monitorScriptContent
    Write-Log "Created monitoring script: $monitorScriptPath" -Level "SUCCESS"
}
#endregion

#region Summary
$monitoringSetup = @{
    Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    StatusSummary = @{
        ConfigurationCreated = (Test-Path $configFile) -and (Test-Path $alertConfigFile)
        MonitoringServiceDeployed = $true
        DashboardDeployed = $RunDashboard
        Scripts = @{
            MonitorScript = Test-Path $monitorScriptPath
            DashboardScript = Test-Path $dashboardScript
        }
        Status = "Ready"
    }
    NextSteps = @(
        "Verify monitoring system is collecting data",
        "Configure additional alert rules if needed",
        "Test alert notifications",
        "Review dashboard for real-time monitoring"
    )
}

$monitoringSetup | ConvertTo-Json -Depth 5 | Set-Content -Path (Join-Path $ConfigPath "deployment-status.json")

Write-Log "Monitoring system deployment complete" -Level "SUCCESS"
Write-Log "Configuration: $ConfigPath" -Level "INFO"
Write-Log "Logs: $LogPath" -Level "INFO"
Write-Log "Dashboard: $(if ($RunDashboard) {'Enabled'} else {'Disabled'})" -Level "INFO"
Write-Log "Email Alerts: $(if ($EnableEmailAlerts) {'Enabled'} else {'Disabled'})" -Level "INFO"
Write-Log "SMS Alerts: $(if ($EnableSmsAlerts) {'Enabled'} else {'Disabled'})" -Level "INFO"

Write-Log "Next steps:" -Level "INFO"
foreach ($step in $monitoringSetup.NextSteps) {
    Write-Log "- $step" -Level "INFO"
}
#endregion 