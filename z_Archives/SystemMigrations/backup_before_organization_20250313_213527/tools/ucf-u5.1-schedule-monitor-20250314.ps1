# ucf-u5.1-schedule-monitor-20250314.ps1
# This script monitors scheduled tasks for proper execution
# Following UcFish digital organization standards
# Department: U5 - Data Management
# Function: 1 - Documentation

#-----------------------------------------------
# Configuration
#-----------------------------------------------
$CONFIG = @{
    TasksToMonitor = @(
        @{
            Name = "cFish.io Daily Health Check"
            ExpectedTime = "08:00"
            GracePeriodMinutes = 30
        },
        @{
            Name = "cFish.io Daily Backup"
            ExpectedTime = "17:00"
            GracePeriodMinutes = 30
        }
    )
    LogFile = "logs\schedule-monitor-$(Get-Date -Format 'yyyyMMdd').log"
    AlertFile = "logs\schedule-monitor-alerts.log"
    MemoryMdPath = "memory.md"
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
##### Functions
#-----------------------------------------------
function Write-Log {
    param (
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    $logMessage = "[$timestamp] [$Level] $Message"
    Add-Content -Path $CONFIG.LogFile -Value $logMessage
    
    if ($Level -eq "ERROR" -or $Level -eq "WARNING") {
        Add-Content -Path $CONFIG.AlertFile -Value $logMessage
    }
    
    Write-Host $logMessage
}

function Get-TaskLastRunTime {
    param (
        [string]$TaskName
    )
    
    try {
        $task = Get-ScheduledTask -TaskName $TaskName -ErrorAction Stop
        $taskInfo = Get-ScheduledTaskInfo -TaskName $TaskName -ErrorAction Stop
        
        $status = "Unhealthy"
        if ($task.State -eq "Ready" -and $taskInfo.LastTaskResult -eq 0) {
            $status = "Healthy"
        }
        
        return @{
            LastRunTime = $taskInfo.LastRunTime
            LastTaskResult = $taskInfo.LastTaskResult
            State = $task.State
            Status = $status
        }
    }
    catch {
        Write-Log "Failed to get information for task '$TaskName': $_" -Level "ERROR"
        $errorCount++
        
        return @{
            LastRunTime = $null
            LastTaskResult = -1
            State = "Unknown"
            Status = "Unhealthy"
        }
    }
}

function Update-MemoryMd {
    param (
        [string]$Content
    )
    
    try {
        $memoryContent = Get-Content -Path $CONFIG.MemoryMdPath -Raw
        $todayDate = Get-Date -Format "MM-dd-2025"
        $sectionTitle = "###### Scheduled Task Monitoring ($todayDate)"
        
        # Check if we already have a section for today
        if ($memoryContent -match [regex]::Escape($sectionTitle)) {
            # Update existing section
            $memoryContent = $memoryContent -replace 
                "(?ms)$([regex]::Escape($sectionTitle)).*?(?=^###### |\Z)", 
                "$sectionTitle`n$Content`n`n_Updated $todayDate | AI: Cursor (Claude 3.7 Sonnet)_`n`n"
        }
        else {
            ##### Add new section at the top
            $memoryContent = "$sectionTitle`n$Content`n`n_Updated $todayDate | AI: Cursor (Claude 3.7 Sonnet)_`n`n$memoryContent"
        }
        
        Set-Content -Path $CONFIG.MemoryMdPath -Value $memoryContent
        Write-Log "Successfully updated memory.md with monitoring results" -Level "INFO"
    }
    catch {
        Write-Log "Failed to update memory.md: $_" -Level "ERROR"
        $errorCount++
    }
}

#-----------------------------------------------
##### Main process
#-----------------------------------------------
Write-Log "Starting scheduled task monitoring" -Level "INFO"

try {
    $monitoringResults = @()
    $memoryContent = ""
    
    foreach ($task in $CONFIG.TasksToMonitor) {
        Write-Log "Checking task: $($task.Name)" -Level "INFO"
        
        $taskInfo = Get-TaskLastRunTime -TaskName $task.Name
        
        if ($null -ne $taskInfo.LastRunTime) {
            $lastRunDate = $taskInfo.LastRunTime.ToString("yyyy-MM-dd")
            $lastRunTime = $taskInfo.LastRunTime.ToString("HH:mm:ss")
            $expectedTime = $task.ExpectedTime
            $today = Get-Date -Format "yyyy-MM-dd"
            
            $result = @{
                TaskName = $task.Name
                LastRunDate = $lastRunDate
                LastRunTime = $lastRunTime
                LastTaskResult = $taskInfo.LastTaskResult
                State = $taskInfo.State
                Status = $taskInfo.Status
                RunToday = $lastRunDate -eq $today
            }
            
            $monitoringResults += $result
            
            $statusIcon = if ($result.Status -eq "Healthy" -and $result.RunToday) { "✅" } else { "❌" }
            $memoryContent += "- $statusIcon $($task.Name): "
            
            if ($result.RunToday) {
                $memoryContent += "Ran successfully today at $lastRunTime`n"
                Write-Log "Task '$($task.Name)' ran successfully today at $lastRunTime" -Level "INFO"
                $successCount++
            }
            else {
                $memoryContent += "Did not run today (last run: $lastRunDate $lastRunTime)`n"
                Write-Log "Task '$($task.Name)' did not run today (last run: $lastRunDate $lastRunTime)" -Level "WARNING"
                $errorCount++
            }
        }
        else {
            $monitoringResults += @{
                TaskName = $task.Name
                LastRunDate = "Never"
                LastRunTime = "Never"
                LastTaskResult = -1
                State = "Unknown"
                Status = "Unhealthy"
                RunToday = $false
            }
            
            $memoryContent += "- ❌ $($task.Name): Never run or not found`n"
            Write-Log "Task '$($task.Name)' has never run or was not found" -Level "ERROR"
            $errorCount++
        }
    }
    
    ##### Update memory.md with monitoring results
    Update-MemoryMd -Content $memoryContent
}
catch {
    Write-Log "An error occurred during monitoring: $_" -Level "ERROR"
    $errorCount++
}
finally {
    Write-Log "Scheduled task monitoring completed with $successCount successes and $errorCount errors" -Level "INFO"
} 
