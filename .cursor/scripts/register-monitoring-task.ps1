# Register Monitoring System Scheduled Task
# Purpose: Configure and register the monitoring system as a scheduled task with administrator privileges
# Created: 05-08-2025

# Enable strict mode
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Configuration
$config = @{
    TaskName = "cFish_SystemMonitoring"
    Description = "UcF System Monitoring - Continuously monitors system resources and process states"
    ExecutionInterval = 5  # minutes
    ScriptPath = "$PSScriptRoot\monitor-system.ps1"
    LogPath = "$PSScriptRoot\..\logs\monitoring"
    ConfigPath = "$PSScriptRoot\..\config\monitoring"
    LogFile = "$PSScriptRoot\..\logs\task-registration.log"
    EmailNotification = @{
        Enabled = $true
        ToAddress = "admin@cfish.io, alerts@cfish.io"
        FromAddress = "monitoring@cfish.io"
        SmtpServer = "smtp.cfish.io"
        SmtpPort = 587
        UseTLS = $true
    }
}

# Ensure log directory exists
$logDir = Split-Path $config.LogFile -Parent
if (-not (Test-Path $logDir)) {
    New-Item -Path $logDir -ItemType Directory -Force | Out-Null
}

# Logging function
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    
    try {
        Add-Content -Path $config.LogFile -Value $logEntry
        
        switch ($Level) {
            "ERROR" { Write-Host $logEntry -ForegroundColor Red }
            "WARNING" { Write-Host $logEntry -ForegroundColor Yellow }
            "SUCCESS" { Write-Host $logEntry -ForegroundColor Green }
            default { Write-Host $logEntry }
        }
    }
    catch {
        Write-Error "Failed to write to log: $($_.Exception.Message)"
    }
}

# Check if running with administrator privileges
function Test-IsAdmin {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Create monitoring configuration if it doesn't exist
function Create-MonitoringConfig {
    try {
        # Create config directory if it doesn't exist
        if (-not (Test-Path $config.ConfigPath)) {
            New-Item -Path $config.ConfigPath -ItemType Directory -Force | Out-Null
            Write-Log "Created monitoring config directory: $($config.ConfigPath)" "INFO"
        }
        
        # Create monitoring config file if it doesn't exist
        $configFile = Join-Path $config.ConfigPath "monitoring-config.json"
        if (-not (Test-Path $configFile)) {
            $monitoringConfig = @{
                UpdateInterval = 30  # seconds
                Thresholds = @{
                    Memory = @{
                        Warning = 75    # percent
                        Critical = 85   # percent
                        Emergency = 90  # percent
                    }
                    Process = @{
                        MaxTotal = 250  # count
                        MaxCursor = 3   # count
                        MaxMemoryPerCursor = 300  # MB
                        TotalCursorMemory = 1000  # MB
                    }
                    Disk = @{
                        Warning = 80    # percent
                        Critical = 90   # percent
                    }
                    CPU = @{
                        Warning = 70    # percent
                        Critical = 85   # percent
                    }
                }
                Alerts = @{
                    Email = @{
                        Enabled = $config.EmailNotification.Enabled
                        Recipients = $config.EmailNotification.ToAddress.Split(',').Trim()
                        FromAddress = $config.EmailNotification.FromAddress
                        SmtpServer = $config.EmailNotification.SmtpServer
                        SmtpPort = $config.EmailNotification.SmtpPort
                        UseTLS = $config.EmailNotification.UseTLS
                    }
                    AutoRemediate = @{
                        Enabled = $true
                        Actions = @(
                            "CleanupProcesses",
                            "TriggerGarbageCollection",
                            "OptimizeCursorInstances"
                        )
                    }
                }
                Reporting = @{
                    LogRetention = 7  # days
                    MetricsPath = Join-Path $config.LogPath "metrics"
                    AlertsPath = Join-Path $config.LogPath "alerts"
                }
            }
            
            $monitoringConfig | ConvertTo-Json -Depth 10 | Set-Content -Path $configFile
            Write-Log "Created monitoring configuration file: $configFile" "SUCCESS"
        }
        
        return $true
    }
    catch {
        Write-Log "Failed to create monitoring configuration: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

# Register the scheduled task
function Register-MonitoringTask {
    param(
        [switch]$Force
    )
    
    try {
        # Check if task already exists
        $existingTask = Get-ScheduledTask -TaskName $config.TaskName -ErrorAction SilentlyContinue
        
        if ($existingTask -and -not $Force) {
            Write-Log "Task '$($config.TaskName)' already exists. Use -Force to replace it." "WARNING"
            return $false
        }
        
        if ($existingTask -and $Force) {
            Write-Log "Removing existing task: $($config.TaskName)" "INFO"
            Unregister-ScheduledTask -TaskName $config.TaskName -Confirm:$false
        }
        
        # Create the task action - PowerShell script execution
        $scriptArguments = "-ExecutionPolicy Bypass -File `"$($config.ScriptPath)`" -ConfigPath `"$($config.ConfigPath)`" -LogPath `"$($config.LogPath)`" -NoProfile -WindowStyle Hidden"
        $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument $scriptArguments
        
        # Create the trigger - Run every X minutes
        $trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes $config.ExecutionInterval)
        
        # Create the settings
        $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -Hidden -ExecutionTimeLimit (New-TimeSpan -Minutes 10) -RunOnlyIfNetworkAvailable:$false
        
        # Create the principal - Run with highest privileges
        $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
        
        # Register the task
        Register-ScheduledTask -TaskName $config.TaskName -Action $action -Trigger $trigger -Settings $settings -Principal $principal -Description $config.Description
        
        Write-Log "Successfully registered scheduled task: $($config.TaskName)" "SUCCESS"
        Write-Log "Script: $($config.ScriptPath)" "INFO"
        Write-Log "Interval: Every $($config.ExecutionInterval) minutes" "INFO"
        
        return $true
    }
    catch {
        Write-Log "Failed to register scheduled task: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

# Verify the scheduled task is running properly
function Test-TaskRegistration {
    try {
        # Get the task
        $task = Get-ScheduledTask -TaskName $config.TaskName -ErrorAction Stop
        
        # Check task state
        if ($task.State -eq "Running" -or $task.State -eq "Ready") {
            Write-Log "Task verification successful: $($config.TaskName) is $($task.State)" "SUCCESS"
            
            # Get task details
            $taskInfo = Get-ScheduledTaskInfo -TaskName $config.TaskName
            
            # Report last run time if available
            if ($taskInfo.LastRunTime -and $taskInfo.LastRunTime -ne [DateTime]::MinValue) {
                Write-Log "Last run time: $($taskInfo.LastRunTime)" "INFO"
                Write-Log "Last result: $($taskInfo.LastTaskResult)" "INFO"
                
                # Check result code
                if ($taskInfo.LastTaskResult -eq 0) {
                    Write-Log "Last run was successful" "SUCCESS"
                }
                else {
                    Write-Log "Last run completed with code: $($taskInfo.LastTaskResult)" "WARNING"
                }
            }
            else {
                Write-Log "Task has not run yet" "INFO"
            }
            
            # Report next run time
            if ($taskInfo.NextRunTime -and $taskInfo.NextRunTime -ne [DateTime]::MinValue) {
                Write-Log "Next run time: $($taskInfo.NextRunTime)" "INFO"
            }
            
            return $true
        }
        else {
            Write-Log "Task verification failed: $($config.TaskName) is in state '$($task.State)'" "WARNING"
            return $false
        }
    }
    catch {
        Write-Log "Failed to verify task: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

# Create log directories
function Create-LogDirectories {
    try {
        # Create main log directory
        if (-not (Test-Path $config.LogPath)) {
            New-Item -Path $config.LogPath -ItemType Directory -Force | Out-Null
            Write-Log "Created log directory: $($config.LogPath)" "INFO"
        }
        
        # Create metrics directory
        $metricsDir = Join-Path $config.LogPath "metrics"
        if (-not (Test-Path $metricsDir)) {
            New-Item -Path $metricsDir -ItemType Directory -Force | Out-Null
            Write-Log "Created metrics directory: $metricsDir" "INFO"
        }
        
        # Create alerts directory
        $alertsDir = Join-Path $config.LogPath "alerts"
        if (-not (Test-Path $alertsDir)) {
            New-Item -Path $alertsDir -ItemType Directory -Force | Out-Null
            Write-Log "Created alerts directory: $alertsDir" "INFO"
        }
        
        return $true
    }
    catch {
        Write-Log "Failed to create log directories: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

# Main execution
try {
    Write-Log "=== Monitoring Task Registration Started ===" "INFO"
    
    # Check administrator privileges
    $isAdmin = Test-IsAdmin
    if (-not $isAdmin) {
        Write-Log "This script must be run with administrator privileges" "ERROR"
        Write-Log "Please restart as administrator" "ERROR"
        exit 1
    }
    
    Write-Log "Running with administrator privileges" "INFO"
    
    # Create log directories
    $logDirsCreated = Create-LogDirectories
    if (-not $logDirsCreated) {
        Write-Log "Failed to create log directories" "ERROR"
        exit 1
    }
    
    # Create monitoring configuration
    $configCreated = Create-MonitoringConfig
    if (-not $configCreated) {
        Write-Log "Failed to create monitoring configuration" "ERROR"
        exit 1
    }
    
    # Verify script path
    if (-not (Test-Path $config.ScriptPath)) {
        Write-Log "Monitoring script not found: $($config.ScriptPath)" "ERROR"
        exit 1
    }
    
    # Register the task
    $taskRegistered = Register-MonitoringTask -Force
    if (-not $taskRegistered) {
        Write-Log "Failed to register monitoring task" "ERROR"
        exit 1
    }
    
    # Test the task registration
    $taskVerified = Test-TaskRegistration
    if (-not $taskVerified) {
        Write-Log "Task verification failed" "WARNING"
        Write-Log "Please check the task manually in Task Scheduler" "WARNING"
    }
    
    # Report completion
    Write-Log "Monitoring system scheduled task registration complete" "SUCCESS"
    Write-Log "Task Name: $($config.TaskName)" "INFO"
    Write-Log "Execution Interval: Every $($config.ExecutionInterval) minutes" "INFO"
    Write-Log "Configuration Path: $($config.ConfigPath)" "INFO"
    Write-Log "Log Path: $($config.LogPath)" "INFO"
    
    Write-Log "=== Monitoring Task Registration Completed ===" "SUCCESS"
}
catch {
    Write-Log "Unexpected error: $($_.Exception.Message)" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    exit 1
} 