# System Monitoring Script
# This script collects system metrics and triggers alerts based on thresholds
# Version: 1.0.0

param (
    [string]$ConfigPath = "C:\Users\Chris\cFish.io\scripts\..\config\monitoring",
    [string]$LogPath = "C:\Users\Chris\cFish.io\scripts\..\logs\monitoring"
)

# Load configuration
$configFile = Join-Path $ConfigPath "monitoring-config.json"
$alertConfigFile = Join-Path $ConfigPath "alert-config.json"
$metricsFile = Join-Path $LogPath "system-metrics.json"
$logFile = Join-Path $LogPath "monitoring.log"

function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    $logTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$logTime] [$Level] $Message"
    
    Add-Content -Path $logFile -Value $logMessage
}

# Check if configuration exists
if (-not (Test-Path $configFile)) {
    Write-Log "Configuration file not found: $configFile" -Level "ERROR"
    exit 1
}

if (-not (Test-Path $alertConfigFile)) {
    Write-Log "Alert configuration file not found: $alertConfigFile" -Level "ERROR"
    exit 1
}

# Load configurations
try {
    $config = Get-Content -Path $configFile | ConvertFrom-Json
    $alertConfig = Get-Content -Path $alertConfigFile | ConvertFrom-Json
    Write-Log "Loaded configuration files successfully" -Level "INFO"
} catch {
    Write-Log "Failed to load configuration: $($_.Exception.Message)" -Level "ERROR"
    exit 1
}

# Initialize metrics storage
$metrics = @{
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
    $osInfo = Get-CimInstance -ClassName Win32_OperatingSystem
    $totalMemoryMB = [math]::Round($osInfo.TotalVisibleMemorySize / 1024, 2)
    $freeMemoryMB = [math]::Round($osInfo.FreePhysicalMemory / 1024, 2)
    $usedMemoryMB = $totalMemoryMB - $freeMemoryMB
    $memoryUsedPercent = [math]::Round(($usedMemoryMB / $totalMemoryMB) * 100, 2)
    
    # Get CPU information
    $cpuLoad = (Get-CimInstance -ClassName Win32_Processor | Measure-Object -Property LoadPercentage -Average).Average
    
    # Get disk information
    $systemDrive = $env:SystemDrive
    $driveInfo = Get-PSDrive -Name $systemDrive.Substring(0, 1)
    $totalSpaceGB = [math]::Round($driveInfo.Used / 1GB + $driveInfo.Free / 1GB, 2)
    $usedSpaceGB = [math]::Round($driveInfo.Used / 1GB, 2)
    $freeSpaceGB = [math]::Round($driveInfo.Free / 1GB, 2)
    $diskUsedPercent = [math]::Round(($usedSpaceGB / $totalSpaceGB) * 100, 2)
    
    # Get network information
    $networkInfo = Get-NetAdapterStatistics | Where-Object { $_.ReceivedBytes -gt 0 }
    $bytesSent = ($networkInfo | Measure-Object -Property SentBytes -Sum).Sum
    $bytesReceived = ($networkInfo | Measure-Object -Property ReceivedBytes -Sum).Sum
    $connections = (Get-NetTCPConnection | Measure-Object).Count
    
    # Update metrics object
    $metrics.SystemMetrics.Memory.Total = $totalMemoryMB
    $metrics.SystemMetrics.Memory.Used = $usedMemoryMB
    $metrics.SystemMetrics.Memory.UsedPercent = $memoryUsedPercent
    $metrics.SystemMetrics.Memory.Available = $freeMemoryMB
    
    $metrics.SystemMetrics.CPU.LoadPercent = $cpuLoad
    
    $metrics.SystemMetrics.Disk.Total = $totalSpaceGB
    $metrics.SystemMetrics.Disk.Used = $usedSpaceGB
    $metrics.SystemMetrics.Disk.UsedPercent = $diskUsedPercent
    $metrics.SystemMetrics.Disk.Available = $freeSpaceGB
    
    $metrics.SystemMetrics.Network.BytesSent = $bytesSent
    $metrics.SystemMetrics.Network.BytesReceived = $bytesReceived
    $metrics.SystemMetrics.Network.ConnectionCount = $connections
    
    Write-Log "Collected system metrics" -Level "INFO"
}

# Collect process metrics
function Get-ProcessMetrics {
    # Get all processes with memory information
    $processes = Get-Process | Select-Object Name, Id, WorkingSet, CPU, Description
    
    # Count processes by type
    $cursorProcesses = $processes | Where-Object { $_.Name -like "*cursor*" }
    $nodeProcesses = $processes | Where-Object { $_.Name -like "*node*" }
    $systemProcesses = $processes | Where-Object { $_.Name -in @("explorer", "winlogon", "wininit", "services", "lsass") }
    
    # Find high memory processes
    $highMemoryThresholdMB = $config.Thresholds.Memory.Warning * 10 # Example threshold
    $highMemoryProcesses = $processes | Where-Object { $_.WorkingSet / 1MB -gt $highMemoryThresholdMB }
    
    # Prepare process list
    $processList = @()
    foreach ($proc in $processes | Sort-Object WorkingSet -Descending | Select-Object -First 20) {
        $type = "other"
        if ($proc.Name -like "*cursor*") { $type = "cursor" }
        elseif ($proc.Name -like "*node*") { $type = "node" }
        elseif ($proc.Name -in @("explorer", "winlogon", "wininit", "services", "lsass")) { $type = "system" }
        
        $memoryMB = [math]::Round($proc.WorkingSet / 1MB, 2)
        
        $processList += @{
            Name = $proc.Name
            Id = $proc.Id
            MemoryMB = $memoryMB
            CPU = $proc.CPU
            Type = $type
            Protected = $proc.Name -in $config.Monitoring.Processes.ProtectedProcesses
        }
    }
    
    # Update metrics object
    $metrics.ProcessMetrics.TotalCount = $processes.Count
    $metrics.ProcessMetrics.CursorCount = $cursorProcesses.Count
    $metrics.ProcessMetrics.NodeCount = $nodeProcesses.Count
    $metrics.ProcessMetrics.SystemCount = $systemProcesses.Count
    $metrics.ProcessMetrics.HighMemoryCount = $highMemoryProcesses.Count
    $metrics.ProcessMetrics.ProcessList = $processList
    
    Write-Log "Collected process metrics" -Level "INFO"
}

# Check for alert conditions
function Check-AlertConditions {
    $triggeredAlerts = @()
    
    # Check memory warning threshold
    if ($metrics.SystemMetrics.Memory.UsedPercent -ge $config.Thresholds.Memory.Warning) {
        $triggeredAlerts += @{
            Rule = "MemoryWarning"
            Level = "WARNING"
            Message = "Memory usage is $($metrics.SystemMetrics.Memory.UsedPercent)% (threshold: $($config.Thresholds.Memory.Warning)%)"
            Timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
        }
    }
    
    # Check memory critical threshold
    if ($metrics.SystemMetrics.Memory.UsedPercent -ge $config.Thresholds.Memory.Critical) {
        $triggeredAlerts += @{
            Rule = "MemoryCritical"
            Level = "CRITICAL"
            Message = "CRITICAL: Memory usage is $($metrics.SystemMetrics.Memory.UsedPercent)% (threshold: $($config.Thresholds.Memory.Critical)%)"
            Timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
        }
    }
    
    # Check process warning threshold
    if ($metrics.ProcessMetrics.TotalCount -ge $config.Thresholds.Process.Warning) {
        $triggeredAlerts += @{
            Rule = "ProcessCountWarning"
            Level = "WARNING"
            Message = "Process count is $($metrics.ProcessMetrics.TotalCount) (threshold: $($config.Thresholds.Process.Warning))"
            Timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
        }
    }
    
    # Check process critical threshold
    if ($metrics.ProcessMetrics.TotalCount -ge $config.Thresholds.Process.Critical) {
        $triggeredAlerts += @{
            Rule = "ProcessCountCritical"
            Level = "CRITICAL"
            Message = "CRITICAL: Process count is $($metrics.ProcessMetrics.TotalCount) (threshold: $($config.Thresholds.Process.Critical))"
            Timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
        }
    }
    
    # Add triggered alerts to history and take actions
    foreach ($alert in $triggeredAlerts) {
        Write-Log "Alert triggered: $($alert.Message)" -Level $alert.Level
        $metrics.AlertHistory += $alert
        
        # Trigger alert actions based on configuration
        # (In a real implementation, this would send emails, SMS, etc.)
    }
    
    return $triggeredAlerts
}

# Main monitoring loop
Write-Log "Starting monitoring loop" -Level "INFO"

# Collect metrics
Get-SystemMetrics
Get-ProcessMetrics

# Check for alerts
$alerts = Check-AlertConditions

# Save metrics to file
$metrics | ConvertTo-Json -Depth 10 | Set-Content -Path $metricsFile

Write-Log "Metrics saved to $metricsFile" -Level "INFO"
