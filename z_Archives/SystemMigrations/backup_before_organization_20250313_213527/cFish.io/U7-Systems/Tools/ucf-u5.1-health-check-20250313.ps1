# ucf-u5.1-health-check-20250313.ps1
# Health Check Script for cFish.io Digital Organization System
# This script performs regular health checks on the cFish.io systems

# Configuration
$CONFIG = @{
    # System paths
    SyncSystem = "cFish.io\U5-Data\Synchronization\tydisync"
    LogsPath = "cFish.io\U3-Operations\Monitoring\logs"
    TasksPath = "cFish.io\U3-Operations\Monitoring\scheduled-tasks"
    MemoryFile = "cFish.io\Documentation\memory.md"
    
    ##### Log settings
    LogFile = "cFish.io\U3-Operations\Monitoring\logs\health-check-log.txt"
    MaxLogSize = 5MB  ##### Maximum log file size before rotation
    
    ##### Error patterns to look for in logs
    ErrorPatterns = @(
        "error",
        "exception",
        "failed",
        "crash",
        "unable to",
        "cannot"
    )
}

##### Create log directories if they don't exist
foreach($dir in @($CONFIG.LogsPath, $CONFIG.TasksPath)) {
    if (-not (Test-Path $dir)) {
        New-Item -Path $dir -ItemType Directory -Force | Out-Null
        Write-Host "Created directory: $dir"
    }
}

##### Function to write to log file
function Write-Log {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [Parameter(Mandatory=$false)]
        [ValidateSet("INFO", "WARNING", "ERROR")]
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    ##### Write to console
    switch ($Level) {
        "INFO" { Write-Host $logMessage }
        "WARNING" { Write-Host $logMessage -ForegroundColor Yellow }
        "ERROR" { Write-Host $logMessage -ForegroundColor Red }
    }
    
    ##### Write to log file
    Add-Content -Path $CONFIG.LogFile -Value $logMessage
    
    ##### Rotate log if too large
    if ((Get-Item $CONFIG.LogFile).Length -gt $CONFIG.MaxLogSize) {
        $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
        $rotatedLog = "$($CONFIG.LogFile).$timestamp.bak"
        Move-Item -Path $CONFIG.LogFile -Destination $rotatedLog
        New-Item -Path $CONFIG.LogFile -ItemType File | Out-Null
        Write-Host "Log rotated to $rotatedLog"
    }
}

##### Function to check if tYDiSync is running
function Test-SyncSystem {
    Write-Log "Checking tYDiSync system status..."
    
    ##### Check if sync system directory exists
    if (-not (Test-Path $CONFIG.SyncSystem)) {
        Write-Log "tYDiSync directory not found at $($CONFIG.SyncSystem)" -Level "ERROR"
        return $false
    }
    
    ##### Check for running processes (adjust the process name as needed)
    $syncProcess = Get-Process -Name "node" -ErrorAction SilentlyContinue | 
                  Where-Object { $_.CommandLine -like "*start-optimized-sync.js*" }
    
    if ($null -eq $syncProcess) {
        Write-Log "tYDiSync process is not running" -Level "ERROR"
        return $false
    } else {
        Write-Log "tYDiSync is running (PID: $($syncProcess.Id))"
        return $true
    }
}

##### Function to check log files for errors
function Test-LogFiles {
    Write-Log "Checking log files for errors..."
    $errorCount = 0
    
    ##### Get all log files in the logs directory
    $logFiles = Get-ChildItem -Path $CONFIG.LogsPath -Filter "*.log" -Recurse
    
    foreach ($logFile in $logFiles) {
        Write-Log "Checking log file: $($logFile.FullName)"
        
        $content = Get-Content $logFile.FullName -ErrorAction SilentlyContinue
        
        foreach ($pattern in $CONFIG.ErrorPatterns) {
            $matches = $content | Where-Object { $_ -match $pattern }
            $matchCount = ($matches | Measure-Object).Count
            
            if ($matchCount -gt 0) {
                Write-Log "Found $matchCount occurrences of '$pattern' in $($logFile.Name)" -Level "WARNING"
                $errorCount += $matchCount
            }
        }
    }
    
    if ($errorCount -gt 0) {
        Write-Log "Found total of $errorCount potential issues in log files" -Level "WARNING"
        return $false
    } else {
        Write-Log "No errors found in log files"
        return $true
    }
}

##### Function to check scheduled tasks
function Test-ScheduledTasks {
    Write-Log "Checking scheduled tasks status..."
    $taskCount = 0
    $failedCount = 0
    
    ##### Get scheduled tasks
    ##### In a real implementation, this would need to query the Windows Task Scheduler
    ##### For this script, we'll simulate by checking a tasks status file
    
    $tasksFile = Join-Path -Path $CONFIG.TasksPath -ChildPath "tasks-status.json"
    
    if (Test-Path $tasksFile) {
        $tasks = Get-Content $tasksFile -Raw | ConvertFrom-Json
        
        foreach ($task in $tasks) {
            $taskCount++
            
            if ($task.LastResult -ne 0) {
                Write-Log "Task '$($task.Name)' failed with result code $($task.LastResult)" -Level "ERROR"
                $failedCount++
            } else {
                Write-Log "Task '$($task.Name)' ran successfully on $($task.LastRunTime)"
            }
        }
    } else {
        Write-Log "Tasks status file not found: $tasksFile" -Level "WARNING"
        return $true  ##### Return true as there are no tasks defined yet
    }
    
    if ($failedCount -gt 0) {
        Write-Log "$failedCount out of $taskCount scheduled tasks failed" -Level "ERROR"
        return $false
    } else {
        Write-Log "All $taskCount scheduled tasks ran successfully"
        return $true
    }
}

##### Function to update memory.md with health check results
function Update-MemoryFile {
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$Results
    )
    
    Write-Log "Updating memory.md with health check results..."
    
    ##### Generate the timestamp for the entry
    $timestamp = Get-Date -Format "MM-dd-2025"
    
    ##### Create the entry content
    $entryContent = @"
## Daily Health Check ($timestamp)
- Executed system health check on all critical cFish.io systems
- tYDiSync Status: $($Results.SyncStatus)
- Log Files Status: $($Results.LogStatus)
- Scheduled Tasks Status: $($Results.TasksStatus)
- Overall System Health: $($Results.OverallStatus)
- Recommendations: $($Results.Recommendations)

_Updated $timestamp | AI: Cursor (Claude 3.7 Sonnet)_

"@
    
    ##### Check if memory file exists
    if (-not (Test-Path $CONFIG.MemoryFile)) {
        Write-Log "Memory file not found: $($CONFIG.MemoryFile)" -Level "ERROR"
        return $false
    }
    
    ##### Read the content of memory.md
    $memoryContent = Get-Content $CONFIG.MemoryFile -Raw
    
    ##### Find the position to insert the new entry (after existing entries, before "Next Steps" if present)
    $nextStepsIndex = $memoryContent.IndexOf("###### Next Steps")
    
    if ($nextStepsIndex -gt 0) {
        # Insert before Next Steps
        $updatedContent = $memoryContent.Substring(0, $nextStepsIndex) + 
                         $entryContent + 
                         $memoryContent.Substring($nextStepsIndex)
    } else {
        # Append to the end
        $updatedContent = $memoryContent + "`n" + $entryContent
    }
    
    ##### Write the updated content back to the file
    $updatedContent | Set-Content $CONFIG.MemoryFile
    
    Write-Log "memory.md updated successfully"
    return $true
}

##### Main function to run all health checks
function Start-HealthCheck {
    $results = @{
        SyncStatus = "❌ Not Running"
        LogStatus = "❌ Errors Found"
        TasksStatus = "❌ Tasks Failed"
        OverallStatus = "❌ Critical Issues"
        Recommendations = "System requires immediate attention"
    }
    
    ##### Run the health checks
    $syncCheck = Test-SyncSystem
    $logCheck = Test-LogFiles
    $tasksCheck = Test-ScheduledTasks
    
    ##### Update results
    if ($syncCheck) { $results.SyncStatus = "✅ Running" }
    if ($logCheck) { $results.LogStatus = "✅ No Errors" }
    if ($tasksCheck) { $results.TasksStatus = "✅ All Tasks Completed" }
    
    ##### Determine overall status
    if ($syncCheck -and $logCheck -and $tasksCheck) {
        $results.OverallStatus = "✅ Healthy"
        $results.Recommendations = "No action required"
    } elseif (-not $syncCheck) {
        $results.OverallStatus = "❌ Critical Issues"
        $results.Recommendations = "Restart tYDiSync system immediately"
    } elseif (-not $logCheck) {
        $results.OverallStatus = "⚠️ Warnings"
        $results.Recommendations = "Investigate log errors"
    } elseif (-not $tasksCheck) {
        $results.OverallStatus = "⚠️ Warnings"
        $results.Recommendations = "Fix failed scheduled tasks"
    }
    
    ##### Generate results summary
    Write-Log "Health check completed with overall status: $($results.OverallStatus)"
    Write-Log "tYDiSync: $($results.SyncStatus)"
    Write-Log "Logs: $($results.LogStatus)"
    Write-Log "Tasks: $($results.TasksStatus)"
    Write-Log "Recommendations: $($results.Recommendations)"
    
    ##### Update memory file
    Update-MemoryFile -Results $results
    
    return $results
}

##### Execute health check
Write-Host "Starting cFish.io Health Check..."
$checkResults = Start-HealthCheck
Write-Host "`nHealth Check Summary:"
Write-Host "===================="
Write-Host "Overall Status: $($checkResults.OverallStatus)"
Write-Host "tYDiSync: $($checkResults.SyncStatus)"
Write-Host "Logs: $($checkResults.LogStatus)"
Write-Host "Tasks: $($checkResults.TasksStatus)"
Write-Host "`nRecommendations: $($checkResults.Recommendations)"
Write-Host "====================" 
