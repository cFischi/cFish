<#
.SYNOPSIS
    Verifies the proper functioning of the tYDiSync system.

.DESCRIPTION
    This script performs a comprehensive verification of the tYDiSync system,
    checking installation, process status, log analysis, and synchronization
    functionality. It generates detailed logs and can automatically restart
    the system if issues are detected.

.NOTES
    File Name      : ucf-u5.1-verify-sync-system-20250313.ps1
    Author         : AI: Cursor (Claude 3.7 Sonnet)
    Prerequisite   : PowerShell 5.1 or later
    Copyright      : cFish.io
    Version        : 1.0
    Created        : 2025-03-13
#>

# Script configuration
$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

##### Define paths
$basePath = "C:\Users\Chris\cFish.io\cFish.io"
$tydisyncPath = "$basePath\U5-Data\Synchronization\tydisync"
$logPath = "$basePath\U3-Operations\Monitoring\logs"
$verificationLogFile = "$logPath\sync-verification.log"
$memoryMdPath = "$basePath\Documentation\memory.md"
$tydisyncLogFile = "$tydisyncPath\tydisync-debug.log"

##### Create log directory if it doesn't exist
if (-not (Test-Path $logPath)) {
    New-Item -ItemType Directory -Path $logPath -Force | Out-Null
    Write-Verbose "Created log directory: $logPath"
}

##### Initialize log file with header
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$logHeader = @"
========================================================
tYDiSync System Verification - $timestamp
========================================================

"@
Add-Content -Path $verificationLogFile -Value $logHeader

##### Function to log messages
function Write-VerificationLog {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet("INFO", "WARNING", "ERROR", "SUCCESS")]
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    ##### Write to console with appropriate color
    switch ($Level) {
        "INFO" { Write-Verbose $Message }
        "WARNING" { Write-Warning $Message }
        "ERROR" { Write-Error $Message }
        "SUCCESS" { 
            $originalColor = $host.UI.RawUI.ForegroundColor
            $host.UI.RawUI.ForegroundColor = "Green"
            Write-Output $Message
            $host.UI.RawUI.ForegroundColor = $originalColor
        }
    }
    
    ##### Write to log file
    Add-Content -Path $verificationLogFile -Value $logMessage
}

##### Function to update memory.md
function Update-MemoryMd {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Title,
        
        [Parameter(Mandatory = $true)]
        [string[]]$Content
    )
    
    $date = Get-Date -Format "MM-dd-2025"
    $memoryContent = Get-Content -Path $memoryMdPath -Raw
    
    ##### Create the new entry
    $newEntry = @"
## $Title ($date)
$(foreach ($line in $Content) { "- $line`n" })

_Updated $date | AI: Cursor (Claude 3.7 Sonnet)_

"@
    
    ##### Find the position to insert (before "## Next Steps" if it exists)
    if ($memoryContent -match "###### Next Steps") {
        $memoryContent = $memoryContent -replace "###### Next Steps", "$newEntry###### Next Steps"
    } else {
        # If "###### Next Steps" doesn't exist, append to the end
        $memoryContent += "`n$newEntry"
    }
    
    ##### Write the updated content back to memory.md
    Set-Content -Path $memoryMdPath -Value $memoryContent
    Write-VerificationLog "Updated memory.md with verification results" -Level "INFO"
}

##### 1. Check Installation
function Test-Installation {
    Write-VerificationLog "Starting installation verification..." -Level "INFO"
    
    $requiredComponents = @(
        @{Path = "$tydisyncPath"; Type = "Directory"; Name = "tYDiSync root directory"},
        @{Path = "$tydisyncPath\start-optimized-sync.bat"; Type = "File"; Name = "Startup script"},
        @{Path = "$tydisyncPath\start-optimized-sync.js"; Type = "File"; Name = "Main script"},
        @{Path = "$tydisyncPath\config"; Type = "Directory"; Name = "Configuration directory"},
        @{Path = "$tydisyncPath\md"; Type = "Directory"; Name = "Markdown directory"},
        @{Path = "$tydisyncPath\json"; Type = "Directory"; Name = "JSON directory"}
    )
    
    $missingComponents = @()
    
    foreach ($component in $requiredComponents) {
        if (-not (Test-Path -Path $component.Path)) {
            $missingComponents += $component.Name
            Write-VerificationLog "Missing component: $($component.Name) at $($component.Path)" -Level "ERROR"
        } else {
            Write-VerificationLog "Component verified: $($component.Name)" -Level "INFO"
        }
    }
    
    if ($missingComponents.Count -eq 0) {
        Write-VerificationLog "All required components are installed" -Level "SUCCESS"
        return $true
    } else {
        Write-VerificationLog "Installation verification failed: $($missingComponents.Count) components missing" -Level "ERROR"
        return $false
    }
}

##### 2. Check Process Status
function Test-ProcessStatus {
    Write-VerificationLog "Checking tYDiSync process status..." -Level "INFO"
    
    $nodeProcesses = Get-Process -Name "node" -ErrorAction SilentlyContinue | 
                    Where-Object { $_.CommandLine -like "*start-optimized-sync.js*" }
    
    if ($null -ne $nodeProcesses -and $nodeProcesses.Count -gt 0) {
        Write-VerificationLog "tYDiSync process is running (PID: $($nodeProcesses.Id))" -Level "SUCCESS"
        return $true
    } else {
        Write-VerificationLog "tYDiSync process is not running" -Level "ERROR"
        return $false
    }
}

##### 3. Analyze Log Files
function Test-LogFiles {
    Write-VerificationLog "Analyzing tYDiSync log files..." -Level "INFO"
    
    if (-not (Test-Path -Path $tydisyncLogFile)) {
        Write-VerificationLog "Log file not found: $tydisyncLogFile" -Level "ERROR"
        return $false
    }
    
    ##### Get the last 100 lines of the log file
    $logContent = Get-Content -Path $tydisyncLogFile -Tail 100
    
    ##### Check for errors
    $errorLines = $logContent | Where-Object { $_ -match "ERROR|FATAL|Exception|failed" }
    $warningLines = $logContent | Where-Object { $_ -match "WARNING|WARN" }
    
    ##### Check for recent activity (last 24 hours)
    $yesterday = (Get-Date).AddDays(-1)
    $recentActivity = $false
    
    foreach ($line in $logContent) {
        if ($line -match "\d{4}-\d{2}-\d{2}") {
            try {
                $logDate = [DateTime]::ParseExact($line.Substring(0, 10), "yyyy-MM-dd", $null)
                if ($logDate -ge $yesterday) {
                    $recentActivity = $true
                    break
                }
            } catch {
                ##### Continue if date parsing fails
                continue
            }
        }
    }
    
    ##### Report findings
    if ($errorLines.Count -gt 0) {
        Write-VerificationLog "Found $($errorLines.Count) error(s) in log file" -Level "WARNING"
        foreach ($error in $errorLines | Select-Object -First 5) {
            Write-VerificationLog "Log error: $error" -Level "WARNING"
        }
    } else {
        Write-VerificationLog "No errors found in log file" -Level "SUCCESS"
    }
    
    if ($warningLines.Count -gt 0) {
        Write-VerificationLog "Found $($warningLines.Count) warning(s) in log file" -Level "INFO"
    }
    
    if ($recentActivity) {
        Write-VerificationLog "Log shows recent activity (within last 24 hours)" -Level "SUCCESS"
    } else {
        Write-VerificationLog "No recent activity found in log (last 24 hours)" -Level "WARNING"
    }
    
    ##### Return true if no errors and has recent activity
    return ($errorLines.Count -eq 0 -and $recentActivity)
}

##### 4. Test Synchronization Functionality
function Test-SynchronizationFunctionality {
    Write-VerificationLog "Testing synchronization functionality..." -Level "INFO"
    
    ##### Create a unique test ID
    $testId = [Guid]::NewGuid().ToString().Substring(0, 8)
    $testFileName = "sync-test-$testId"
    $mdFilePath = "$tydisyncPath\md\$testFileName.md"
    $jsonFilePath = "$tydisyncPath\json\$testFileName.json"
    
    ##### Create test markdown file
    $testContent = @"
# Automated Sync Test

This is an automated test file created on $(Get-Date -Format "yyyy-MM-dd HH:mm:ss") to verify tYDiSync functionality.

###### Test Details
- Created by: Verification Script
- Purpose: Automated verification
- Test ID: $testId
"@
    
    try {
        # Create the test file
        Set-Content -Path $mdFilePath -Value $testContent
        Write-VerificationLog "Created test markdown file: $mdFilePath" -Level "INFO"
        
        ##### Wait for synchronization (up to 2 minutes)
        $syncTimeout = 120 ##### seconds
        $syncSuccessful = $false
        
        for ($i = 1; $i -le ($syncTimeout / 5); $i++) {
            Write-VerificationLog "Waiting for synchronization... ($($i * 5)s / ${syncTimeout}s)" -Level "INFO"
            Start-Sleep -Seconds 5
            
            if (Test-Path -Path $jsonFilePath) {
                $syncSuccessful = $true
                break
            }
        }
        
        if ($syncSuccessful) {
            Write-VerificationLog "Synchronization successful! JSON file created: $jsonFilePath" -Level "SUCCESS"
            
            ##### Verify content
            $jsonContent = Get-Content -Path $jsonFilePath -Raw
            if ($jsonContent -match $testId) {
                Write-VerificationLog "JSON content verification successful" -Level "SUCCESS"
            } else {
                Write-VerificationLog "JSON content verification failed - test ID not found in content" -Level "ERROR"
                $syncSuccessful = $false
            }
        } else {
            Write-VerificationLog "Synchronization failed - JSON file not created within timeout period" -Level "ERROR"
        }
        
        ##### Clean up test files
        Remove-Item -Path $mdFilePath -Force -ErrorAction SilentlyContinue
        if (Test-Path -Path $jsonFilePath) {
            Remove-Item -Path $jsonFilePath -Force -ErrorAction SilentlyContinue
        }
        Write-VerificationLog "Cleaned up test files" -Level "INFO"
        
        return $syncSuccessful
    } catch {
        Write-VerificationLog "Error during synchronization test: $_" -Level "ERROR"
        return $false
    }
}

##### 5. Restart tYDiSync if needed
function Restart-TYDiSync {
    Write-VerificationLog "Attempting to restart tYDiSync..." -Level "INFO"
    
    try {
        ##### Navigate to tYDiSync directory
        Set-Location -Path $tydisyncPath
        
        ##### Run the start script
        $startScript = "$tydisyncPath\start-optimized-sync.bat"
        if (Test-Path -Path $startScript) {
            Start-Process -FilePath $startScript -WindowStyle Hidden
            Write-VerificationLog "Started tYDiSync using $startScript" -Level "INFO"
            
            ##### Wait a moment for the process to start
            Start-Sleep -Seconds 10
            
            ##### Verify process started
            if (Test-ProcessStatus) {
                Write-VerificationLog "tYDiSync restart successful" -Level "SUCCESS"
                return $true
            } else {
                Write-VerificationLog "tYDiSync restart failed - process not running after restart attempt" -Level "ERROR"
                return $false
            }
        } else {
            Write-VerificationLog "Start script not found: $startScript" -Level "ERROR"
            return $false
        }
    } catch {
        Write-VerificationLog "Error during tYDiSync restart: $_" -Level "ERROR"
        return $false
    }
}

##### Main verification process
function Start-SyncVerification {
    Write-VerificationLog "Starting tYDiSync system verification" -Level "INFO"
    
    $verificationResults = @{
        "Installation" = $false
        "Process" = $false
        "Logs" = $false
        "Functionality" = $false
        "RestartAttempted" = $false
        "RestartSuccessful" = $false
    }
    
    ##### 1. Check Installation
    $verificationResults.Installation = Test-Installation
    
    ##### 2. Check Process Status
    $verificationResults.Process = Test-ProcessStatus
    
    ##### If process is not running, attempt to restart
    if (-not $verificationResults.Process) {
        $verificationResults.RestartAttempted = $true
        $verificationResults.RestartSuccessful = Restart-TYDiSync
        
        ##### Update process status after restart attempt
        $verificationResults.Process = Test-ProcessStatus
    }
    
    ##### 3. Analyze Log Files
    $verificationResults.Logs = Test-LogFiles
    
    ##### 4. Test Synchronization Functionality (only if process is running)
    if ($verificationResults.Process) {
        $verificationResults.Functionality = Test-SynchronizationFunctionality
    } else {
        Write-VerificationLog "Skipping synchronization test because process is not running" -Level "WARNING"
    }
    
    ##### Generate summary
    $successCount = ($verificationResults.GetEnumerator() | Where-Object { $_.Value -eq $true }).Count
    $totalChecks = $verificationResults.Count - 2  ##### Exclude restart flags
    
    $summaryLines = @()
    $summaryLines += "Verification completed with $successCount/$totalChecks checks passed"
    
    foreach ($result in $verificationResults.GetEnumerator()) {
        if ($result.Key -notin @("RestartAttempted", "RestartSuccessful")) {
            $status = if ($result.Value) { "PASSED" } else { "FAILED" }
            $summaryLines += "$($result.Key) check: $status"
        }
    }
    
    if ($verificationResults.RestartAttempted) {
        $restartStatus = if ($verificationResults.RestartSuccessful) { "successful" } else { "failed" }
        $summaryLines += "Restart attempt: $restartStatus"
    }
    
    ##### Log summary
    Write-VerificationLog "===== VERIFICATION SUMMARY =====" -Level "INFO"
    foreach ($line in $summaryLines) {
        Write-VerificationLog $line -Level "INFO"
    }
    
    ##### Update memory.md with verification results
    $overallStatus = if ($successCount -eq $totalChecks) { "Successful" } else { "Failed" }
    Update-MemoryMd -Title "tYDiSync Verification $overallStatus" -Content $summaryLines
    
    ##### Return overall success/failure
    return ($successCount -eq $totalChecks)
}

##### Execute verification
try {
    $verificationSuccess = Start-SyncVerification
    
    if ($verificationSuccess) {
        Write-VerificationLog "tYDiSync verification completed successfully" -Level "SUCCESS"
        exit 0
    } else {
        Write-VerificationLog "tYDiSync verification completed with issues" -Level "WARNING"
        exit 1
    }
} catch {
    Write-VerificationLog "Critical error during verification: $_" -Level "ERROR"
    
    ##### Update memory.md with error
    Update-MemoryMd -Title "tYDiSync Verification Error" -Content @(
        "Critical error during verification: $_",
        "Check verification log for details: $verificationLogFile"
    )
    
    exit 2
} 
