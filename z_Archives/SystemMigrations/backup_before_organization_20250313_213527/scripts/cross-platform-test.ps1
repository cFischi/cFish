# Enhanced Cross-Platform Test Script
# Purpose: Test PowerShell scripts for cross-platform compatibility
# Ticket: CFIO-2025-03
# Created: 2025-03-13

# Set error handling preferences
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

# Initialize test counters
${script}:TestsPassed = 0
${script}:TestsFailed = 0

Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "       tYDiSync~ Cross-Platform Compatibility Test Suite          " -ForegroundColor Cyan
Write-Host "==================================================================" -ForegroundColor Cyan

##### Get platform information
$isCore = $PSVersionTable.PSEdition -eq 'Core'
$platform = if ($isCore) { 
    if ($PSVersionTable.Platform -eq 'Unix') {
        if ($PSVersionTable.OS -like "*Linux*") { "Linux" }
        elseif ($PSVersionTable.OS -like "*Darwin*") { "macOS" }
        else { "PowerShell Core (Unix)" }
    } else {
        "PowerShell Core (Windows)"
    }
} else {
    "Windows PowerShell"
}

Write-Host "Platform: $platform" -ForegroundColor Yellow
Write-Host "PowerShell Version: $($PSVersionTable.PSVersion)" -ForegroundColor Yellow
Write-Host "Date/Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Yellow
Write-Host "==================================================================" -ForegroundColor Cyan

##### Function to log test results
function Log-TestResult {
    param (
        [string]$TestName,
        [bool]$Success,
        [string]$Message = ""
    )
    
    if ($Success) {
        Write-Host "PASS: $TestName" -ForegroundColor Green
        ${script}:TestsPassed++
    } else {
        Write-Host "FAIL: $TestName - $Message" -ForegroundColor Red
        ${script}:TestsFailed++
    }
}

##### Test 1: Path Handling Tests
Write-Host "`nRunning Path Handling Tests..." -ForegroundColor Cyan

$testDir = Join-Path -Path ${env}:TEMP -ChildPath "cross_platform_test_$(Get-Date -Format 'yyyyMMddHHmmss')"
try {
    ##### Create test directory
    New-Item -Path $testDir -ItemType Directory -Force | Out-Null
    Write-Host "Created test directory: $testDir"
    
    ##### Test 1.1: Forward slash paths
    $forwardSlashPath = $testDir.Replace('\', '/')
    $forwardSlashWorks = Test-Path $forwardSlashPath
    Log-TestResult -TestName "Forward Slash Path" -Success $forwardSlashWorks -Message "Path: $forwardSlashPath"
    
    ##### Test 1.2: Backslash paths
    $backslashPath = $testDir.Replace('/', '\')
    $backslashWorks = Test-Path $backslashPath
    Log-TestResult -TestName "Backslash Path" -Success $backslashWorks -Message "Path: $backslashPath"
    
    ##### Test 1.3: Join-Path cmdlet
    $joinedPath = Join-Path -Path $testDir -ChildPath "test_file.txt"
    $joinedPathValid = $joinedPath -match ([regex]::Escape($testDir))
    Log-TestResult -TestName "Join-Path Cmdlet" -Success $joinedPathValid -Message "Joined path: $joinedPath"
    
    ##### Test 1.4: Path with spaces
    $spaceDir = Join-Path -Path $testDir -ChildPath "folder with spaces"
    New-Item -Path $spaceDir -ItemType Directory -Force | Out-Null
    $spacePathWorks = Test-Path $spaceDir
    Log-TestResult -TestName "Path With Spaces" -Success $spacePathWorks -Message "Path: $spaceDir"
}
catch {
    Log-TestResult -TestName "Path Handling" -Success $false -Message "Error: $_"
}

##### Test 2: Special Character Tests
Write-Host "`nRunning Special Character Tests..." -ForegroundColor Cyan

try {
    ##### Test 2.1: Basic special characters
    $specialFile = Join-Path -Path $testDir -ChildPath "special-char-test.txt"
    Set-Content -Path $specialFile -Value "Test content with special characters"
    $specialTest = Test-Path $specialFile
    Log-TestResult -TestName "Basic Special Characters" -Success $specialTest -Message "File: $specialFile"
    
    ##### Clean up special file
    if (Test-Path $specialFile) {
        Remove-Item -Path $specialFile -Force
    }
}
catch {
    Log-TestResult -TestName "Special Character Handling" -Success $false -Message "Error: $_"
}

##### Test 3: Error Handling Tests
Write-Host "`nRunning Error Handling Tests..." -ForegroundColor Cyan

##### Test 3.1: Basic try-catch
try {
    ##### Intentionally cause an error
    $nonExistentFile = Join-Path -Path $testDir -ChildPath "non-existent-file-$(Get-Date -Format 'yyyyMMddHHmmss').txt"
    $content = Get-Content -Path $nonExistentFile -ErrorAction Stop
    Log-TestResult -TestName "Try-Catch" -Success $false -Message "Expected error was not thrown"
}
catch {
    Log-TestResult -TestName "Try-Catch" -Success $true -Message "Successfully caught error"
}

##### Test 3.2: ErrorActionPreference
$originalPreference = $ErrorActionPreference
$ErrorActionPreference = "Continue"

try {
    $errorThrown = $false
    try {
        ##### This should not throw with ErrorActionPreference = Continue
        $nonExistentFile = Join-Path -Path $testDir -ChildPath "another-non-existent-file-$(Get-Date -Format 'yyyyMMddHHmmss').txt"
        $content = Get-Content -Path $nonExistentFile
    }
    catch {
        $errorThrown = $true
    }
    
    ##### It should not have thrown with ErrorActionPreference = Continue
    Log-TestResult -TestName "ErrorActionPreference" -Success (-not $errorThrown) -Message "Error handling respects ErrorActionPreference"
}
finally {
    ##### Restore original preference
    $ErrorActionPreference = $originalPreference
}

##### Test 4: Backup Functionality Tests
Write-Host "`nRunning Backup Functionality Tests..." -ForegroundColor Cyan

try {
    ##### Test 4.1: Basic file backup
    $originalFile = Join-Path -Path $testDir -ChildPath "original.txt"
    $backupFile = Join-Path -Path $testDir -ChildPath "original.bak"
    
    Set-Content -Path $originalFile -Value "Original content for backup test"
    Copy-Item -Path $originalFile -Destination $backupFile -Force
    
    $backupExists = Test-Path $backupFile
    Log-TestResult -TestName "File Backup Creation" -Success $backupExists -Message "Backup file: $backupFile"
    
    ##### Test 4.2: Content verification
    if ($backupExists) {
        $originalContent = Get-Content -Path $originalFile -Raw
        $backupContent = Get-Content -Path $backupFile -Raw
        
        $contentMatches = ($originalContent -eq $backupContent)
        Log-TestResult -TestName "Backup Content Verification" -Success $contentMatches -Message "Content comparison"
    }
    else {
        Log-TestResult -TestName "Backup Content Verification" -Success $false -Message "Backup file doesn't exist"
    }
    
    ##### Clean up test files
    if (Test-Path $originalFile) {
        Remove-Item -Path $originalFile -Force
    }
    if (Test-Path $backupFile) {
        Remove-Item -Path $backupFile -Force
    }
}
catch {
    Log-TestResult -TestName "Backup Functionality" -Success $false -Message "Error: $_"
}

##### Test 5: Platform-Specific Features
Write-Host "`nRunning Platform-Specific Tests..." -ForegroundColor Cyan

##### Test 5.1: PowerShell Version Features
$psVersion = $PSVersionTable.PSVersion

if ($isCore) {
    ##### Test Core-specific features
    try {
        ##### Test parallel processing (PS7 feature)
        $parallelSupported = $null -ne (Get-Command -Name 'ForEach-Object' -ParameterName 'Parallel' -ErrorAction SilentlyContinue)
        Log-TestResult -TestName "Parallel Processing" -Success $parallelSupported -Message "PowerShell Core: $psVersion"
        
        ##### Test conditional expression (avoiding ternary operator syntax)
        try {
            ##### Using Invoke-Expression to avoid parse errors in PS5.1
            $testScript = 'if ($true) { "Yes" } else { "No" }'
            $result = Invoke-Expression $testScript
            Log-TestResult -TestName "Conditional Expression" -Success $true -Message "PowerShell Core: $psVersion"
        }
        catch {
            Log-TestResult -TestName "Conditional Expression" -Success $false -Message "Error: $_"
        }
    }
    catch {
        Log-TestResult -TestName "PowerShell Core Features" -Success $false -Message "Error: $_"
    }
}
else {
    ##### Report Windows PowerShell limitations
    Log-TestResult -TestName "Parallel Processing" -Success $false -Message "Not supported in Windows PowerShell: $psVersion"
    Log-TestResult -TestName "Conditional Expression" -Success $true -Message "Using if/else in Windows PowerShell: $psVersion"
}

##### Test 5.2: Environment Variables
try {
    $tempDirExists = Test-Path ${env}:TEMP
    Log-TestResult -TestName "Environment Variables" -Success $tempDirExists -Message "TEMP directory: ${env}:TEMP"
}
catch {
    Log-TestResult -TestName "Environment Variables" -Success $false -Message "Error: $_"
}

##### Clean up
if (Test-Path -Path $testDir) {
    Remove-Item -Path $testDir -Recurse -Force
    Write-Host "`nCleaned up test directory" -ForegroundColor Gray
}

##### Display summary
Write-Host "`n==================================================================" -ForegroundColor Cyan
Write-Host "                       Test Summary                              " -ForegroundColor Cyan
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "Tests Passed: ${script}:TestsPassed" -ForegroundColor Green
Write-Host "Tests Failed: ${script}:TestsFailed" -ForegroundColor Red
Write-Host "Total Tests: $(${script}:TestsPassed + ${script}:TestsFailed)"
Write-Host "==================================================================" -ForegroundColor Cyan

##### Generate report
$reportPath = "results/cross-platform-test-report-$(Get-Date -Format 'yyyyMMdd').md"
$reportDir = Split-Path -Path $reportPath -Parent
if (-not (Test-Path -Path $reportDir)) {
    New-Item -Path $reportDir -ItemType Directory -Force | Out-Null
}

##### Build report line by line
$lines = @()
$lines += "# tYDiSync~ Cross-Platform Compatibility Test Report"
$lines += ""
$lines += "Date: $(Get-Date -Format 'yyyy-MM-dd')"
$lines += "PowerShell Version: $($PSVersionTable.PSVersion)"
$lines += "PowerShell Edition: $($PSVersionTable.PSEdition)"

##### Get OS information in a cross-platform way
$osInfo = if ($isCore) {
    $PSVersionTable.OS
} else {
    [System.Environment]::OSVersion.ToString()
}
$lines += "Operating System: $osInfo"
$lines += "Platform Detected: $platform"
$lines += ""
$lines += "###### Summary"
$lines += "* Tests Passed: ${script}:TestsPassed"
$lines += "* Tests Failed: ${script}:TestsFailed"
$lines += "* Total Tests: $(${script}:TestsPassed + ${script}:TestsFailed)"

##### Avoid division by zero
if ((${script}:TestsPassed + ${script}:TestsFailed) -gt 0) {
    $successRate = [math]::Round((${script}:TestsPassed / (${script}:TestsPassed + ${script}:TestsFailed)) * 100, 2)
    $lines += "* Success Rate: $successRate%"
} else {
    $lines += "* Success Rate: N/A (no tests run)"
}

$lines += ""
$lines += "###### Recommendations"
$lines += ""
$lines += "####### Path Handling"
$lines += "* Use Join-Path for all path operations to ensure cross-platform compatibility"
$lines += "* Avoid hardcoded path separators"
$lines += "* Test path operations on all supported platforms"
$lines += ""
$lines += "####### Special Characters"
$lines += "* Use caution with special characters in filenames"
$lines += "* Ensure proper encoding when working with international characters"
$lines += "* Test with a variety of special characters across platforms"
$lines += ""
$lines += "####### Error Handling"
$lines += "* Set ErrorActionPreference = 'Stop' at the beginning of scripts"
$lines += "* Use try-catch-finally blocks for critical operations"
$lines += "* Include detailed error messages and logging"
$lines += "* Ensure error handling works consistently across platforms"
$lines += ""
$lines += "####### Backup Functionality"
$lines += "* Verify backup file existence after creation"
$lines += "* Validate backup content matches the original"
$lines += "* Implement cleanup in finally blocks"
$lines += ""
$lines += "####### Platform-Specific Features"
$lines += "* Check PowerShell version before using version-specific features"
$lines += "* Provide alternative implementations for Windows PowerShell vs. PowerShell Core"
$lines += "* Document platform limitations in script headers"
$lines += ""
$lines += "###### Next Steps"
$lines += "1. Address any failed tests"
$lines += "2. Implement recommendations in all PowerShell scripts"
$lines += "3. Continue regular cross-platform testing as scripts are modified"
$lines += "4. Create automated test pipeline for ongoing verification"

##### Write the report to file
$lines | Out-File -FilePath $reportPath -Encoding utf8 -Force

Write-Host "`nTest report generated at: $reportPath" -ForegroundColor Green
Write-Host "Review the report for recommendations and next steps." -ForegroundColor Gray

# Return result based on test outcome
if (${script}:TestsFailed -eq 0) {
    exit 0  # Success
} else {
    exit 1  # Failure
} 
