# ucf-u5.1-verify-sync-system-20250313.ps1
# Sync System Verification Script for cFish.io
# This script verifies that the tYDiSync system is running correctly

# Configuration
$CONFIG = @{
    # System paths
    SyncSystemPath = "cFish.io\U5-Data\Synchronization\tydisync"
    StartScript = "cFish.io\U5-Data\Synchronization\tydisync\start-optimized-sync.bat"
    ConfigPath = "cFish.io\U5-Data\Synchronization\tydisync\config"
    LogsPath = "cFish.io\U5-Data\Synchronization\tydisync\tydisync-debug.log"
    
    ##### Monitoring paths
    MonitoringLogsPath = "cFish.io\U3-Operations\Monitoring\logs"
    VerificationLogFile = "cFish.io\U3-Operations\Monitoring\logs\sync-verification.log"
    
    ##### Test files
    TestMarkdownFile = "cFish.io\U5-Data\Synchronization\tydisync\md\sync-system-verification-test.md"
    TestJsonFile = "cFish.io\U5-Data\Synchronization\tydisync\json\sync-system-verification-test.json"
    
    ##### Memory file
    MemoryFile = "cFish.io\Documentation\memory.md"
    
    ##### Error patterns to look for in sync logs
    ErrorPatterns = @(
        "error",
        "exception",
        "failed",
        "crash",
        "unable to",
        "cannot",
        "timeout"
    )
}

##### Create monitoring directories if they don't exist
foreach($dir in @($CONFIG.MonitoringLogsPath)) {
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
        [ValidateSet("INFO", "WARNING", "ERROR", "SUCCESS")]
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    ##### Write to console with appropriate color
    switch ($Level) {
        "INFO" { Write-Host $logMessage }
        "WARNING" { Write-Host $logMessage -ForegroundColor Yellow }
        "ERROR" { Write-Host $logMessage -ForegroundColor Red }
        "SUCCESS" { Write-Host $logMessage -ForegroundColor Green }
    }
    
    ##### Create log directory if it doesn't exist
    $logDir = Split-Path -Parent $CONFIG.VerificationLogFile
    if (-not (Test-Path $logDir)) {
        New-Item -Path $logDir -ItemType Directory -Force | Out-Null
    }
    
    ##### Write to log file
    Add-Content -Path $CONFIG.VerificationLogFile -Value $logMessage
}

##### Function to check if tYDiSync system is installed correctly
function Test-SyncSystemInstallation {
    Write-Log "Checking tYDiSync system installation..."
    
    ##### Check if sync system directory exists
    if (-not (Test-Path $CONFIG.SyncSystemPath)) {
        Write-Log "tYDiSync directory not found at $($CONFIG.SyncSystemPath)" -Level "ERROR"
        return $false
    }
    
    ##### Check if start script exists
    if (-not (Test-Path $CONFIG.StartScript)) {
        Write-Log "Start script not found at $($CONFIG.StartScript)" -Level "ERROR"
        return $false
    }
    
    ##### Check if config directory exists
    if (-not (Test-Path $CONFIG.ConfigPath)) {
        Write-Log "Configuration directory not found at $($CONFIG.ConfigPath)" -Level "ERROR"
        return $false
    }
    
    Write-Log "tYDiSync system is installed correctly" -Level "SUCCESS"
    return $true
}

##### Function to check if tYDiSync process is running
function Test-SyncSystemProcess {
    Write-Log "Checking if tYDiSync process is running..."
    
    ##### Check for running processes (adjust the process name as needed)
    $syncProcess = Get-Process -Name "node" -ErrorAction SilentlyContinue | 
                  Where-Object { $_.CommandLine -like "*start-optimized-sync.js*" }
    
    if ($null -eq $syncProcess) {
        Write-Log "tYDiSync process is not running" -Level "ERROR"
        return $false
    } else {
        Write-Log "tYDiSync is running (PID: $($syncProcess.Id))" -Level "SUCCESS"
        return $true
    }
}

##### Function to check log files for errors
function Test-SyncSystemLogs {
    Write-Log "Checking sync system logs for errors..."
    
    if (-not (Test-Path $CONFIG.LogsPath)) {
        Write-Log "Sync system log file not found at $($CONFIG.LogsPath)" -Level "WARNING"
        return $true  ##### Return true as there are no logs to check
    }
    
    $errorCount = 0
    $content = Get-Content $CONFIG.LogsPath -ErrorAction SilentlyContinue
    
    foreach ($pattern in $CONFIG.ErrorPatterns) {
        $matches = $content | Where-Object { $_ -match $pattern }
        $matchCount = ($matches | Measure-Object).Count
        
        if ($matchCount -gt 0) {
            Write-Log "Found $matchCount occurrences of '$pattern' in sync system logs" -Level "WARNING"
            $errorCount += $matchCount
        }
    }
    
    if ($errorCount -gt 0) {
        Write-Log "Found total of $errorCount potential issues in sync system logs" -Level "WARNING"
        return $false
    } else {
        Write-Log "No errors found in sync system logs" -Level "SUCCESS"
        return $true
    }
}

##### Function to test sync functionality by creating/modifying test files
function Test-SyncFunctionality {
    Write-Log "Testing sync functionality with test files..."
    
    ##### Define directories for the test files
    $mdDir = Split-Path -Parent $CONFIG.TestMarkdownFile
    $jsonDir = Split-Path -Parent $CONFIG.TestJsonFile
    
    ##### Create directories if they don't exist
    foreach($dir in @($mdDir, $jsonDir)) {
        if (-not (Test-Path $dir)) {
            New-Item -Path $dir -ItemType Directory -Force | Out-Null
            Write-Log "Created directory: $dir"
        }
    }
    
    ##### Generate timestamp for unique test content
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    
    ##### Create or update markdown test file
    $mdContent = @"
# Sync System Verification Test

This is an automatically generated test file to verify sync system functionality.

## Test Details
- Timestamp: $timestamp
- Generated by: ucf-u5.1-verify-sync-system-20250313.ps1
- Test ID: $([Guid]::NewGuid().ToString())

## Status
- Created: $([DateTime]::Now.ToString("yyyy-MM-dd HH:mm:ss"))

_This file should be synchronized to a corresponding JSON file._
"@
    
    try {
        Set-Content -Path $CONFIG.TestMarkdownFile -Value $mdContent
        Write-Log "Created/updated markdown test file at $($CONFIG.TestMarkdownFile)" -Level "SUCCESS"
        
        ##### Wait for the file to be synchronized (adjust time as needed)
        Write-Log "Waiting for synchronization to occur..."
        Start-Sleep -Seconds 10
        
        ##### Check if JSON file was created/updated
        if (Test-Path $CONFIG.TestJsonFile) {
            $jsonLastWrite = (Get-Item $CONFIG.TestJsonFile).LastWriteTime
            $timeDiff = [DateTime]::Now - $jsonLastWrite
            
            if ($timeDiff.TotalMinutes < 2) {
                Write-Log "JSON file was recently updated at $($CONFIG.TestJsonFile)" -Level "SUCCESS"
                return $true
            } else {
                Write-Log "JSON file exists but wasn't recently updated ($($timeDiff.TotalMinutes) minutes old)" -Level "WARNING"
                return $false
            }
        } else {
            Write-Log "JSON file was not created at $($CONFIG.TestJsonFile)" -Level "ERROR"
            return $false
        }
    } catch {
        Write-Log "Error testing sync functionality: $_" -Level "ERROR"
        return $false
    }
}

##### Function to restart sync system if it's not running
function Restart-SyncSystem {
    Write-Log "Attempting to restart the tYDiSync system..."
    
    try {
        ##### Check if the start script exists
        if (-not (Test-Path $CONFIG.StartScript)) {
            Write-Log "Start script not found at $($CONFIG.StartScript)" -Level "ERROR"
            return $false
        }
        
        ##### Kill any existing node processes related to sync system
        $syncProcesses = Get-Process -Name "node" -ErrorAction SilentlyContinue | 
                        Where-Object { $_.CommandLine -like "*start-optimized-sync.js*" }
        
        if ($syncProcesses) {
            foreach ($process in $syncProcesses) {
                Write-Log "Stopping existing sync process (PID: $($process.Id))..."
                Stop-Process -Id $process.Id -Force
            }
            
            ##### Wait for processes to stop
            Start-Sleep -Seconds 2
        }
        
        ##### Start the sync system
        Write-Log "Starting tYDiSync system..."
        Start-Process -FilePath $CONFIG.StartScript -NoNewWindow
        
        ##### Wait for system to start
        Start-Sleep -Seconds 10
        
        ##### Check if process is now running
        $newProcess = Get-Process -Name "node" -ErrorAction SilentlyContinue | 
                     Where-Object { $_.CommandLine -like "*start-optimized-sync.js*" }
        
        if ($newProcess) {
            Write-Log "tYDiSync system restarted successfully" -Level "SUCCESS"
            return $true
        } else {
            Write-Log "Failed to restart tYDiSync system" -Level "ERROR"
            return $false
        }
    } catch {
        Write-Log "Error restarting sync system: $_" -Level "ERROR"
        return $false
    }
}

##### Function to update memory.md with verification results
function Update-MemoryFile {
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$Results
    )
    
    Write-Log "Updating memory.md with verification results..."
    
    $timestamp = Get-Date -Format "MM-dd-2025"
    $memoryFile = $CONFIG.MemoryFile
    
    if (-not (Test-Path $memoryFile)) {
        Write-Log "Memory file not found: $memoryFile" -Level "ERROR"
        return $false
    }
    
    ##### Determine overall status message
    $statusMessage = if ($Results.OverallStatus -eq "Healthy") {
        "All systems operational"
    } elseif ($Results.OverallStatus -eq "Warning") {
        "System operational with warnings"
    } else {
        "System requires attention"
    }
    
    ##### Create the entry content
    $entryContent = @"
## Sync System Verification ($timestamp)
- Verified tYDiSync system functionality and performance
- Installation check: $($Results.InstallationStatus)
- Process check: $($Results.ProcessStatus)
- Log analysis: $($Results.LogStatus)
- Sync functionality: $($Results.SyncStatus)
- Overall system status: $($Results.OverallStatus)
- Status message: $statusMessage
- Recommendations: $($Results.Recommendations)

_Updated $timestamp | AI: Cursor (Claude 3.7 Sonnet)_

"@
    
    ##### Read the content of memory.md
    $memoryContent = Get-Content $memoryFile -Raw
    
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
    $updatedContent | Set-Content $memoryFile
    
    Write-Log "memory.md updated successfully"
    return $true
}

##### Main verification function
function Start-SyncSystemVerification {
    $results = @{
        InstallationStatus = "❌ Failed"
        ProcessStatus = "❌ Not Running"
        LogStatus = "❌ Errors Found"
        SyncStatus = "❌ Not Functioning"
        OverallStatus = "Critical"
        Recommendations = "System requires immediate attention"
    }
    
    ##### Check installation
    $installationCheck = Test-SyncSystemInstallation
    if ($installationCheck) {
        $results.InstallationStatus = "✅ Installed Correctly"
    }
    
    ##### Check process
    $processCheck = Test-SyncSystemProcess
    if ($processCheck) {
        $results.ProcessStatus = "✅ Running"
    } elseif ($installationCheck) {
        ##### Try to restart the system if it's installed but not running
        Write-Log "tYDiSync is not running, attempting to restart..."
        $restartSuccess = Restart-SyncSystem
        
        if ($restartSuccess) {
            $results.ProcessStatus = "⚠️ Restarted"
            $processCheck = $true
        }
    }
    
    ##### Only continue with other checks if the process is running
    if ($processCheck) {
        ##### Check logs
        $logCheck = Test-SyncSystemLogs
        if ($logCheck) {
            $results.LogStatus = "✅ No Errors"
        } else {
            $results.LogStatus = "⚠️ Warnings Found"
        }
        
        ##### Check sync functionality
        $syncCheck = Test-SyncFunctionality
        if ($syncCheck) {
            $results.SyncStatus = "✅ Functioning"
        } else {
            $results.SyncStatus = "⚠️ Partially Functioning"
        }
    }
    
    ##### Determine overall status
    if ($installationCheck -and $processCheck -and $logCheck -and $syncCheck) {
        $results.OverallStatus = "Healthy"
        $results.Recommendations = "No action required"
    } elseif ($installationCheck -and $processCheck) {
        if ($logCheck -or $syncCheck) {
            $results.OverallStatus = "Warning"
            $results.Recommendations = "Monitor system for potential issues"
        } else {
            $results.OverallStatus = "Warning"
            $results.Recommendations = "Investigate log errors and sync functionality"
        }
    } elseif ($installationCheck -and -not $processCheck) {
        $results.OverallStatus = "Critical"
        $results.Recommendations = "Restart tYDiSync system manually"
    } else {
        $results.OverallStatus = "Critical"
        $results.Recommendations = "Reinstall tYDiSync system"
    }
    
    ##### Update memory file
    Update-MemoryFile -Results $results
    
    return $results
}

##### Main execution
Write-Host "Starting tYDiSync System Verification..."
$verificationResults = Start-SyncSystemVerification

##### Display summary
Write-Host "`nSync System Verification Summary:"
Write-Host "================================="
Write-Host "Installation: $($verificationResults.InstallationStatus)"
Write-Host "Process: $($verificationResults.ProcessStatus)"
Write-Host "Logs: $($verificationResults.LogStatus)"
Write-Host "Sync Functionality: $($verificationResults.SyncStatus)"
Write-Host "`nOverall Status: $($verificationResults.OverallStatus)"
Write-Host "Recommendations: $($verificationResults.Recommendations)"
Write-Host "=================================" 
