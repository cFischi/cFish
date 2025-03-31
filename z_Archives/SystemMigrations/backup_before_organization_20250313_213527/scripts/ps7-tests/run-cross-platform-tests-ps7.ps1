# run-cross-platform-tests-ps7.ps1
# Purpose: Run cross-platform tests in PowerShell 7
# Created: 2025-03-12

# Set preferences
$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

##### Initialize variables
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$rootDir = Split-Path -Parent (Split-Path -Parent $scriptDir)
$logFile = Join-Path -Path $scriptDir -ChildPath "..\logs\cross-platform-ps7-DATESTAMP.log"
$testScriptPath = Join-Path -Path $rootDir -ChildPath "scripts\test-cross-platform.ps1"
$resultsDir = Join-Path -Path $scriptDir -ChildPath "results"

##### Ensure directories exist
$logDir = Split-Path -Parent $logFile
if (-not (Test-Path $logDir)) {
    New-Item -Path $logDir -ItemType Directory -Force | Out-Null
    Write-Host "Created log directory: $logDir" -ForegroundColor Green
}

if (-not (Test-Path $resultsDir)) {
    New-Item -Path $resultsDir -ItemType Directory -Force | Out-Null
    Write-Host "Created results directory: $resultsDir" -ForegroundColor Green
}

##### Function to write to log file and console
function Write-Log {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [Parameter(Mandatory=$false)]
        [ValidateSet("INFO", "SUCCESS", "WARNING", "ERROR")]
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    ##### Write to log file
    Add-Content -Path $logFile -Value $logMessage
    
    ##### Write to console with color based on level
    switch ($Level) {
        "INFO" { Write-Host $logMessage -ForegroundColor Gray }
        "SUCCESS" { Write-Host $logMessage -ForegroundColor Green }
        "WARNING" { Write-Host $logMessage -ForegroundColor Yellow }
        "ERROR" { Write-Host $logMessage -ForegroundColor Red }
        default { Write-Host $logMessage }
    }
}

##### Banner
Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "      Running Cross-Platform Tests in PowerShell 7              " -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host ""

##### Display PowerShell version information
Write-Host "PowerShell Version Information:" -ForegroundColor Cyan
$PSVersionTable | Format-Table -AutoSize

##### Run the cross-platform tests
try {
    Write-Log "Running cross-platform tests from $testScriptPath..." "INFO"
    
    if (-not (Test-Path $testScriptPath)) {
        throw "Test script not found at $testScriptPath"
    }
    
    ##### Capture the output of the test script
    $output = & $testScriptPath *>&1
    
    ##### Save the output to a results file
    $resultsFile = "$resultsDir/cross-platform-ps7-results-20250312-220336.txt"
    Set-Content -Path $resultsFile -Value @"
Cross-Platform Test Results (PowerShell 7)
==========================================
Date: 2025-03-12 22:03:36
PowerShell Version: $($PSVersionTable.PSVersion)
OS: $($PSVersionTable.OS)

Test Output:
-----------
$output

"@
    
    Write-Log "Cross-platform tests completed. Results saved to $resultsFile" "SUCCESS"
    
    ##### Display a summary of the results
    Write-Host "`nTest Results Summary:" -ForegroundColor Cyan
    if ($output -match "Cross-Platform Compatibility Test FAILED") {
        Write-Host "❌ Some tests failed. See $resultsFile for details." -ForegroundColor Red
    }
    else {
        Write-Host "✅ All tests passed successfully!" -ForegroundColor Green
    }
}
catch {
    Write-Log "Error running cross-platform tests: $_" "ERROR"
    Write-Host "❌ Failed to run cross-platform tests: $_" -ForegroundColor Red
}

Write-Host "`n=================================================================" -ForegroundColor Cyan
Write-Host "      Cross-Platform Tests in PowerShell 7 Completed            " -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan

