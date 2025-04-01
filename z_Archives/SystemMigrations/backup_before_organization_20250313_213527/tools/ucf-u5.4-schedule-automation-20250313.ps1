# ucf-u5.4-schedule-automation-20250313.ps1
# This script schedules automated tasks for daily health checks and backups
# Following UcFish digital organization standards
# Department: U5 - Data Management
# Function: 4 - Automation

#-----------------------------------------------
# Configuration
#-----------------------------------------------
$CONFIG = @{
    HealthCheck = @{
        TaskName = "cFish.io Daily Health Check"
        Description = "Run daily health check for cFish.io systems"
        ScriptPath = "C:\Users\Chris\cFish.io\tools\daily-health-check.ps1"
        Time = "08:00"
    }
    Backup = @{
        TaskName = "cFish.io Daily Backup"
        Description = "Run daily backup for cFish.io systems"
        ScriptPath = "C:\Users\Chris\cFish.io\tools\daily-backup.ps1"
        Time = "17:00"
    }
    LogFile = "logs\automation-schedule-$(Get-Date -Format 'yyyyMMdd').log"
}

#-----------------------------------------------
##### Initialize
#-----------------------------------------------
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$ErrorActionPreference = "Stop"
$successCount = 0
$errorCount = 0

##### Create log directory if it doesn't exist
$logDir = Split-Path -Parent $CONFIG.LogFile
if (-not (Test-Path $logDir)) {
    New-Item -Path $logDir -ItemType Directory -Force | Out-Null
}

#-----------------------------------------------
##### Helper Functions
#-----------------------------------------------
function Write-ScheduleLog {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [Parameter(Mandatory=$false)]
        [ValidateSet("INFO", "WARNING", "ERROR", "SUCCESS")]
        [string]$Level = "INFO"
    )
    
    $logMessage = "[$timestamp] [$Level] $Message"
    
    switch ($Level) {
        "INFO" { 
            Write-Host $logMessage -ForegroundColor Gray
        }
        "WARNING" { 
            Write-Host $logMessage -ForegroundColor Yellow
        }
        "ERROR" { 
            Write-Host $logMessage -ForegroundColor Red
        }
        "SUCCESS" { 
            Write-Host $logMessage -ForegroundColor Green
        }
    }
    
    ##### Log to file
    Add-Content -Path $CONFIG.LogFile -Value $logMessage
}

function Test-AdminPrivileges {
    $identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object System.Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Register-AutomationTask {
    param(
        [Parameter(Mandatory=$true)]
        [string]$TaskName,
        
        [Parameter(Mandatory=$true)]
        [string]$Description,
        
        [Parameter(Mandatory=$true)]
        [string]$ScriptPath,
        
        [Parameter(Mandatory=$true)]
        [string]$Time
    )
    
    ##### Check if script exists
    if (-not (Test-Path $ScriptPath)) {
        Write-ScheduleLog "Script does not exist at path: $ScriptPath" -Level "ERROR"
        return $false
    }
    
    try {
        ##### Check if task already exists
        $existingTask = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
        
        if ($existingTask) {
            Write-ScheduleLog "Task '$TaskName' already exists. Updating configuration..." -Level "WARNING"
            Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
        }
        
        ##### Create the scheduled task action
        $action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ExecutionPolicy Bypass -File `"$ScriptPath`""
        
        ##### Create the trigger
        $trigger = New-ScheduledTaskTrigger -Daily -At $Time
        
        ##### Set the principal (run with highest privileges)
        $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
        
        ##### Register the task
        Register-ScheduledTask -Action $action -Trigger $trigger -Principal $principal -TaskName $TaskName -Description $Description
        
        Write-ScheduleLog "Successfully scheduled task: $TaskName at $Time daily" -Level "SUCCESS"
        return $true
    }
    catch {
        Write-ScheduleLog "Failed to schedule task: $TaskName. Error: $_" -Level "ERROR"
        return $false
    }
}

#-----------------------------------------------
##### Main
#-----------------------------------------------
Write-ScheduleLog "Starting automation scheduling script" -Level "INFO"

##### Check for admin privileges
if (-not (Test-AdminPrivileges)) {
    Write-ScheduleLog "This script requires administrator privileges to schedule tasks" -Level "ERROR"
    Write-ScheduleLog "Please run PowerShell as Administrator and try again" -Level "ERROR"
    exit 1
}

##### Schedule health check task
Write-ScheduleLog "Scheduling daily health check task..." -Level "INFO"
$healthCheckResult = Register-AutomationTask -TaskName $CONFIG.HealthCheck.TaskName -Description $CONFIG.HealthCheck.Description -ScriptPath $CONFIG.HealthCheck.ScriptPath -Time $CONFIG.HealthCheck.Time

if ($healthCheckResult) {
    $successCount++
} else {
    $errorCount++
}

##### Schedule backup task
Write-ScheduleLog "Scheduling daily backup task..." -Level "INFO"
$backupResult = Register-AutomationTask -TaskName $CONFIG.Backup.TaskName -Description $CONFIG.Backup.Description -ScriptPath $CONFIG.Backup.ScriptPath -Time $CONFIG.Backup.Time

if ($backupResult) {
    $successCount++
} else {
    $errorCount++
}

##### Summary
Write-ScheduleLog "Automation scheduling completed with $successCount successes and $errorCount errors" -Level "INFO"
if ($errorCount -eq 0) {
    Write-ScheduleLog "All automation tasks scheduled successfully" -Level "SUCCESS"
} else {
    Write-ScheduleLog "Some automation tasks could not be scheduled. Check the log for details." -Level "WARNING"
}

Write-ScheduleLog "Scheduling script completed at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -Level "INFO"

##### Display instructions
Write-Host "`nNext Steps:" -ForegroundColor Cyan
Write-Host "1. The scheduled tasks will run automatically at their specified times."
Write-Host "2. You can view and modify tasks in the Task Scheduler application."
Write-Host "3. Check logs in the 'logs' directory for task execution results."
Write-Host "4. To manually run a task, use the Task Scheduler or run the script directly." 
