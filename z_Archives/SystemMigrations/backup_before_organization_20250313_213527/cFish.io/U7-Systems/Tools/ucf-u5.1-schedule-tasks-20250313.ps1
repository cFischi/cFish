# ucf-u5.1-schedule-tasks-20250313.ps1
# Task Scheduler Script for cFish.io Digital Organization System
# This script creates scheduled tasks for system maintenance and monitoring

# Elevate to admin if needed
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script needs to be run as Administrator to schedule tasks. Please restart with admin privileges." -ForegroundColor Red
    exit
}

##### Configuration
$CONFIG = @{
    ##### System paths
    ScriptsPath = "C:\Users\Chris\cFish.io\cFish.io\U7-Systems\Tools"
    LogsPath = "C:\Users\Chris\cFish.io\cFish.io\U3-Operations\Monitoring\logs"
    TasksPath = "C:\Users\Chris\cFish.io\cFish.io\U3-Operations\Monitoring\scheduled-tasks"
    
    ##### Task definitions
    Tasks = @(
        @{
            Name = "cFish-DailyHealthCheck"
            DisplayName = "cFish.io Daily Health Check"
            Description = "Performs daily health check of cFish.io systems"
            ScriptPath = "ucf-u5.1-health-check-20250313.ps1"
            WorkingDirectory = "C:\Users\Chris\cFish.io\cFish.io\U7-Systems\Tools"
            Schedule = @{
                Type = "Daily"
                StartTime = "01:00" ##### 1:00 AM
                DaysInterval = 1
            }
        },
        @{
            Name = "cFish-DailyBackup"
            DisplayName = "cFish.io Daily Backup"
            Description = "Creates daily backups of critical cFish.io files"
            ScriptPath = "ucf-u5.1-backup-20250313.ps1"
            WorkingDirectory = "C:\Users\Chris\cFish.io\cFish.io\U7-Systems\Tools"
            Schedule = @{
                Type = "Daily"
                StartTime = "02:00" ##### 2:00 AM
                DaysInterval = 1
            }
        },
        @{
            Name = "cFish-SyncSystemVerification"
            DisplayName = "cFish.io Sync System Verification"
            Description = "Verifies that the tYDiSync system is running correctly"
            ScriptPath = "ucf-u5.1-verify-sync-system-20250313.ps1"
            WorkingDirectory = "C:\Users\Chris\cFish.io\cFish.io\U7-Systems\Tools"
            Schedule = @{
                Type = "Daily"
                StartTime = "03:00" ##### 3:00 AM
                DaysInterval = 1
            }
        },
        @{
            Name = "cFish-ScheduleMonitoring"
            DisplayName = "cFish.io Schedule Monitoring"
            Description = "Monitors and reports status of all scheduled tasks"
            ScriptPath = "ucf-u5.1-schedule-monitor-20250313.ps1"
            WorkingDirectory = "C:\Users\Chris\cFish.io\cFish.io\U7-Systems\Tools"
            Schedule = @{
                Type = "Daily"
                StartTime = "06:00" ##### 6:00 AM
                DaysInterval = 1
            }
        }
    )
}

##### Create necessary directories if they don't exist
foreach($dir in @($CONFIG.LogsPath, $CONFIG.TasksPath)) {
    if (-not (Test-Path $dir)) {
        New-Item -Path $dir -ItemType Directory -Force | Out-Null
        Write-Host "Created directory: $dir"
    }
}

##### Function to create a scheduled task
function New-CFishScheduledTask {
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$TaskConfig
    )
    
    $taskName = $TaskConfig.Name
    $displayName = $TaskConfig.DisplayName
    $description = $TaskConfig.Description
    $scriptPath = Join-Path -Path $TaskConfig.WorkingDirectory -ChildPath $TaskConfig.ScriptPath
    
    ##### Check if script exists
    if (-not (Test-Path $scriptPath)) {
        Write-Host "Script not found: $scriptPath" -ForegroundColor Red
        return $false
    }
    
    ##### Create the scheduled task action
    $action = New-ScheduledTaskAction -Execute "PowerShell.exe" `
                                      -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"" `
                                      -WorkingDirectory $TaskConfig.WorkingDirectory
    
    ##### Create the scheduled task trigger based on schedule type
    $trigger = $null
    
    switch ($TaskConfig.Schedule.Type) {
        "Daily" {
            $trigger = New-ScheduledTaskTrigger -Daily -At $TaskConfig.Schedule.StartTime -DaysInterval $TaskConfig.Schedule.DaysInterval
        }
        "Weekly" {
            $trigger = New-ScheduledTaskTrigger -Weekly -At $TaskConfig.Schedule.StartTime -DaysOfWeek $TaskConfig.Schedule.DaysOfWeek -WeeksInterval $TaskConfig.Schedule.WeeksInterval
        }
        "Monthly" {
            $trigger = New-ScheduledTaskTrigger -Monthly -At $TaskConfig.Schedule.StartTime -DaysOfMonth $TaskConfig.Schedule.DaysOfMonth -Month $TaskConfig.Schedule.Months
        }
        default {
            Write-Host "Unsupported schedule type: $($TaskConfig.Schedule.Type)" -ForegroundColor Red
            return $false
        }
    }
    
    ##### Create the scheduled task settings
    $settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -DontStopOnIdleEnd -RestartInterval (New-TimeSpan -Minutes 1) -RestartCount 3
    
    ##### Create the task principal (who the task will run as)
    $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
    
    ##### Check if task already exists
    $existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
    
    if ($existingTask) {
        ##### Unregister the existing task
        Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
        Write-Host "Removed existing task: $taskName"
    }
    
    try {
        ##### Register the new task
        $task = Register-ScheduledTask -TaskName $taskName `
                                      -Action $action `
                                      -Trigger $trigger `
                                      -Settings $settings `
                                      -Principal $principal `
                                      -Description $description
        
        if ($task) {
            Write-Host "Successfully scheduled task: $displayName" -ForegroundColor Green
            return $true
        } else {
            Write-Host "Failed to schedule task: $displayName" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "Error scheduling task $displayName`: $_" -ForegroundColor Red
        return $false
    }
}

##### Main function to schedule all tasks
function Set-CFishScheduledTasks {
    $successCount = 0
    $failCount = 0
    
    Write-Host "Creating scheduled tasks for cFish.io system maintenance..."
    
    foreach ($task in $CONFIG.Tasks) {
        Write-Host "`nSetting up task: $($task.DisplayName)..."
        
        $result = New-CFishScheduledTask -TaskConfig $task
        
        if ($result) {
            $successCount++
        } else {
            $failCount++
        }
    }
    
    ##### Create a task status file
    $taskStatus = @()
    
    foreach ($task in $CONFIG.Tasks) {
        $taskStatus += @{
            Name = $task.DisplayName
            ScheduledTaskName = $task.Name
            ScriptPath = $task.ScriptPath
            LastRunTime = $null
            LastResult = $null
            Status = "Scheduled"
        }
    }
    
    ##### Save task status to file
    $tasksFile = Join-Path -Path $CONFIG.TasksPath -ChildPath "tasks-status.json"
    $taskStatus | ConvertTo-Json -Depth 4 | Set-Content $tasksFile
    
    return @{
        Success = $successCount
        Failed = $failCount
        Total = $CONFIG.Tasks.Count
    }
}

##### Main execution
Write-Host "cFish.io Task Scheduler"
Write-Host "======================================"
Write-Host "This script will set up scheduled tasks for system maintenance."
Write-Host "Tasks will run automatically at their scheduled times."
Write-Host "Task logs will be stored in $($CONFIG.LogsPath)"
Write-Host "======================================`n"

$results = Set-CFishScheduledTasks

Write-Host "`nTask Scheduling Summary:"
Write-Host "======================================"
Write-Host "Total tasks configured: $($results.Total)"
Write-Host "Successfully scheduled: $($results.Success)"
Write-Host "Failed to schedule: $($results.Failed)"
Write-Host "======================================"
Write-Host "Next steps: Update memory.md with task configuration details" 
