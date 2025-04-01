# ucf-u5.1-schedule-tasks-20250314.ps1
# This script configures scheduled tasks for the digital organization system
# Following UcFish digital organization standards
# Department: U5 - Data Management
# Function: 4 - Automation

#-----------------------------------------------
# Configuration
#-----------------------------------------------
$CONFIG = @{
    TaskScheduler = @{
        TaskFolder = "\cFish.io"
        HealthCheckTaskName = "DailyHealthCheck"
        BackupTaskName = "DailyBackup"
        SyncMonitorTaskName = "SyncSystemMonitor"
    }
    Scripts = @{
        HealthCheckScript = "tools\daily-health-check.ps1"
        BackupScript = "tools\daily-backup.ps1"
        SyncRecoveryScript = "tools\auto-recovery-sync-system.ps1"
    }
    ExecutionTimes = @{
        HealthCheck = "08:00"
        Backup = "22:00"
        SyncMonitor = "00/01:00"  ##### Every hour
    }
    LogFile = "logs\schedule-tasks-$(Get-Date -Format 'yyyyMMdd').log"
}

#-----------------------------------------------
##### Initialize
#-----------------------------------------------
$ErrorActionPreference = "Stop"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$workingDirectory = (Get-Location).Path
$successCount = 0
$errorCount = 0

##### Create log directory if it doesn't exist
$logDir = Split-Path -Parent $CONFIG.LogFile
if (-not (Test-Path $logDir)) {
    New-Item -Path $logDir -ItemType Directory -Force | Out-Null
}

#-----------------------------------------------
##### Functions
#-----------------------------------------------
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    ##### Write to console with color
    switch ($Level) {
        "ERROR" { Write-Host $logMessage -ForegroundColor Red }
        "WARNING" { Write-Host $logMessage -ForegroundColor Yellow }
        "SUCCESS" { Write-Host $logMessage -ForegroundColor Green }
        default { Write-Host $logMessage }
    }
    
    ##### Write to log file
    Add-Content -Path $CONFIG.LogFile -Value $logMessage
}

function Test-AdminPrivileges {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Create-TaskFolder {
    param(
        [string]$FolderPath
    )
    
    try {
        $taskService = New-Object -ComObject Schedule.Service
        $taskService.Connect()
        $rootFolder = $taskService.GetFolder("\")
        
        ##### Split folder path and create each level if it doesn't exist
        $folders = $FolderPath.Split('\') | Where-Object { $_ -ne "" }
        $currentPath = "\"
        
        foreach ($folder in $folders) {
            $currentPath += $folder + "\"
            
            try {
                $taskService.GetFolder($currentPath) | Out-Null
                Write-Log "Task folder exists: $currentPath" -Level "INFO"
            }
            catch {
                $rootFolder.CreateFolder($folder)
                Write-Log "Created task folder: $currentPath" -Level "SUCCESS"
                $rootFolder = $taskService.GetFolder($currentPath)
            }
        }
        
        return $true
    }
    catch {
        Write-Log "Failed to create task folder: $_" -Level "ERROR"
        return $false
    }
}

function Create-DailyTask {
    param(
        [string]$TaskName,
        [string]$ScriptPath,
        [string]$ExecutionTime,
        [string]$Description
    )
    
    try {
        $fullScriptPath = Join-Path -Path $workingDirectory -ChildPath $ScriptPath
        if (-not (Test-Path $fullScriptPath)) {
            Write-Log "Script file not found: $fullScriptPath" -Level "ERROR"
            return $false
        }
        
        ##### Build the action to run PowerShell with the script
        $action = New-ScheduledTaskAction -Execute "powershell.exe" `
                                          -Argument "-ExecutionPolicy Bypass -File `"$fullScriptPath`"" `
                                          -WorkingDirectory $workingDirectory
        
        ##### Parse the execution time (HH:MM)
        $hourMinute = $ExecutionTime.Split(':')
        $hour = [int]$hourMinute[0]
        $minute = [int]$hourMinute[1]
        
        ##### Create a daily trigger
        $trigger = New-ScheduledTaskTrigger -Daily -At "$hour`:$minute"
        
        ##### Configure task settings
        $settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -DontStopOnIdleEnd -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
        
        ##### Use the current user for the task
        $principal = New-ScheduledTaskPrincipal -UserId "${env}:USERDOMAIN\${env}:USERNAME" -LogonType S4U -RunLevel Highest
        
        ##### Create the task
        $taskPath = $CONFIG.TaskScheduler.TaskFolder
        
        ##### Unregister the task if it already exists
        Unregister-ScheduledTask -TaskName $TaskName -TaskPath $taskPath -Confirm:$false -ErrorAction SilentlyContinue
        
        ##### Register the new task
        $task = Register-ScheduledTask -TaskName $TaskName `
                                      -TaskPath $taskPath `
                                      -Action $action `
                                      -Trigger $trigger `
                                      -Settings $settings `
                                      -Principal $principal `
                                      -Description $Description `
                                      -Force
        
        if ($task) {
            Write-Log "Successfully created scheduled task: $TaskName" -Level "SUCCESS"
            return $true
        }
        else {
            Write-Log "Failed to create task: $TaskName" -Level "ERROR"
            return $false
        }
    }
    catch {
        Write-Log "Error creating scheduled task '$TaskName': $_" -Level "ERROR"
        return $false
    }
}

function Create-HourlyTask {
    param(
        [string]$TaskName,
        [string]$ScriptPath,
        [string]$Description
    )
    
    try {
        $fullScriptPath = Join-Path -Path $workingDirectory -ChildPath $ScriptPath
        if (-not (Test-Path $fullScriptPath)) {
            Write-Log "Script file not found: $fullScriptPath" -Level "ERROR"
            return $false
        }
        
        ##### Build the action to run PowerShell with the script
        $action = New-ScheduledTaskAction -Execute "powershell.exe" `
                                          -Argument "-ExecutionPolicy Bypass -File `"$fullScriptPath`" -RunAsService" `
                                          -WorkingDirectory $workingDirectory
        
        ##### Create an hourly trigger
        $trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 60) -RepetitionDuration ([TimeSpan]::MaxValue)
        
        ##### Configure task settings
        $settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -DontStopOnIdleEnd -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
        
        ##### Use the current user for the task
        $principal = New-ScheduledTaskPrincipal -UserId "${env}:USERDOMAIN\${env}:USERNAME" -LogonType S4U -RunLevel Highest
        
        ##### Create the task
        $taskPath = $CONFIG.TaskScheduler.TaskFolder
        
        ##### Unregister the task if it already exists
        Unregister-ScheduledTask -TaskName $TaskName -TaskPath $taskPath -Confirm:$false -ErrorAction SilentlyContinue
        
        ##### Register the new task
        $task = Register-ScheduledTask -TaskName $TaskName `
                                      -TaskPath $taskPath `
                                      -Action $action `
                                      -Trigger $trigger `
                                      -Settings $settings `
                                      -Principal $principal `
                                      -Description $Description `
                                      -Force
        
        if ($task) {
            Write-Log "Successfully created scheduled task: $TaskName" -Level "SUCCESS"
            return $true
        }
        else {
            Write-Log "Failed to create task: $TaskName" -Level "ERROR"
            return $false
        }
    }
    catch {
        Write-Log "Error creating scheduled task '$TaskName': $_" -Level "ERROR"
        return $false
    }
}

#-----------------------------------------------
##### Main process
#-----------------------------------------------
Write-Log "Starting scheduled task configuration" -Level "INFO"

##### Check for administrator privileges
if (-not (Test-AdminPrivileges)) {
    Write-Log "This script requires administrator privileges to configure scheduled tasks" -Level "WARNING"
    Write-Log "Please run this script as an administrator" -Level "WARNING"
    exit 1
}

##### Create task scheduler folder
$folderResult = Create-TaskFolder -FolderPath $CONFIG.TaskScheduler.TaskFolder
if (-not $folderResult) {
    Write-Log "Failed to create task scheduler folder, exiting" -Level "ERROR"
    exit 1
}

##### Create daily health check task
$healthCheckResult = Create-DailyTask -TaskName $CONFIG.TaskScheduler.HealthCheckTaskName `
                                      -ScriptPath $CONFIG.Scripts.HealthCheckScript `
                                      -ExecutionTime $CONFIG.ExecutionTimes.HealthCheck `
                                      -Description "cFish.io - Daily Health Check for Digital Organization System"
if ($healthCheckResult) {
    $successCount++
}
else {
    $errorCount++
}

##### Create daily backup task
$backupResult = Create-DailyTask -TaskName $CONFIG.TaskScheduler.BackupTaskName `
                                 -ScriptPath $CONFIG.Scripts.BackupScript `
                                 -ExecutionTime $CONFIG.ExecutionTimes.Backup `
                                 -Description "cFish.io - Daily Backup for Digital Organization System"
if ($backupResult) {
    $successCount++
}
else {
    $errorCount++
}

##### Create sync system monitor task
$syncMonitorResult = Create-HourlyTask -TaskName $CONFIG.TaskScheduler.SyncMonitorTaskName `
                                      -ScriptPath $CONFIG.Scripts.SyncRecoveryScript `
                                      -Description "cFish.io - Hourly Sync System Monitor and Auto-Recovery"
if ($syncMonitorResult) {
    $successCount++
}
else {
    $errorCount++
}

##### Update memory.md with task configuration status
$memoryContent = "## Scheduled Task Configuration (03-14-2025)\n"
$memoryContent += "- Configured automated tasks using Windows Task Scheduler for digital organization system\n"

if ($healthCheckResult) {
    $memoryContent += "- ✅ Configured daily health check task to run at $($CONFIG.ExecutionTimes.HealthCheck)\n"
}
else {
    $memoryContent += "- ❌ Failed to configure daily health check task\n"
}

if ($backupResult) {
    $memoryContent += "- ✅ Configured daily backup task to run at $($CONFIG.ExecutionTimes.Backup)\n"
}
else {
    $memoryContent += "- ❌ Failed to configure daily backup task\n"
}

if ($syncMonitorResult) {
    $memoryContent += "- ✅ Configured hourly sync system monitoring task\n"
}
else {
    $memoryContent += "- ❌ Failed to configure sync system monitoring task\n"
}

$memoryContent += "- Tasks created in scheduler folder: $($CONFIG.TaskScheduler.TaskFolder)\n"
$memoryContent += "- All tasks configured to use highest privileges for reliable execution\n"
$memoryContent += "- Tasks set to run whether user is logged in or not\n"
$memoryContent += "- Implemented 'start when available' to ensure tasks run even after system downtime\n"
$memoryContent += "- Configured tasks to continue running on battery power for laptops\n\n"
$memoryContent += "_Updated 03-14-2025 | AI: Cursor (Claude 3.7 Sonnet)_\n\n"

##### Find the position to insert in memory.md
$memoryFile = "memory.md"
if (Test-Path $memoryFile) {
    $memoryFileContent = Get-Content $memoryFile -Raw
    
    ##### Look for "Next Steps" section to insert before it
    $nextStepsPosition = $memoryFileContent.IndexOf("###### Next Steps")
    
    if ($nextStepsPosition -ge 0) {
        $newContent = $memoryFileContent.Substring(0, $nextStepsPosition) + $memoryContent + $memoryFileContent.Substring($nextStepsPosition)
        Set-Content -Path $memoryFile -Value $newContent
        Write-Log "Updated memory.md with task configuration details" -Level "SUCCESS"
    }
    else {
        ##### If "Next Steps" section not found, just append
        Add-Content -Path $memoryFile -Value $memoryContent
        Write-Log "Appended task configuration details to memory.md" -Level "SUCCESS"
    }
}
else {
    Write-Log "Could not find memory.md file to update" -Level "WARNING"
}

##### Final summary
Write-Log "Task configuration completed with $successCount successes and $errorCount failures" -Level "INFO"

if ($errorCount -gt 0) {
    Write-Log "There were errors during task configuration. Review the log for details." -Level "WARNING"
    exit 1
}
else {
    Write-Log "All tasks were configured successfully" -Level "SUCCESS"
    exit 0
} 
