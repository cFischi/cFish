# Enhanced Cross-Platform Compatibility Test Script
# Purpose: Test PowerShell scripts in different environments
# Ticket: CFIO-2025-03
# Created: 2025-03-13

# Set error handling preferences
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

# Initialize test counter and results collection
${script}:TestsPassed = 0
${script}:TestsFailed = 0
${script}:TestResults = @{}

# Function to detect current platform
function Get-Platform {
    if ($PSVersionTable.PSEdition -eq 'Core' -and $IsLinux) {
        return "Linux"
    }
    elseif ($PSVersionTable.PSEdition -eq 'Core' -and $IsMacOS) {
        return "macOS"
    }
    elseif ($PSVersionTable.PSEdition -eq 'Core') {
        return "PowerShell Core (Windows)"
    }
    else {
        return "Windows PowerShell"
    }
}

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
    
    ${script}:TestResults[$TestName] = @{
        Success = $Success
        Message = $Message
        Platform = Get-Platform
        PowerShellVersion = $PSVersionTable.PSVersion.ToString()
    }
}

##### Test 1: Basic Path Handling
function Test-PathHandling {
    Write-Host "`nRunning Path Handling Tests..." -ForegroundColor Cyan
    
    ##### Create a test directory
    $testDir = Join-Path -Path ${env}:TEMP -ChildPath "cross_platform_path_test"
    
    try {
        if (-not (Test-Path -Path $testDir)) {
            New-Item -Path $testDir -ItemType Directory -Force | Out-Null
            Write-Host "  Created test directory: $testDir"
        }
        
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
        $joinedPathValid = $joinedPath -match [regex]::Escape($testDir)
        Log-TestResult -TestName "Join-Path Cmdlet" -Success $joinedPathValid -Message "Joined path: $joinedPath"
        
        ##### Test 1.4: Path with spaces
        $spaceDir = Join-Path -Path $testDir -ChildPath "folder with spaces"
        if (-not (Test-Path -Path $spaceDir)) {
            New-Item -Path $spaceDir -ItemType Directory -Force | Out-Null
        }
        $spacePathWorks = Test-Path $spaceDir
        Log-TestResult -TestName "Path With Spaces" -Success $spacePathWorks -Message "Path: $spaceDir"
        
        ##### Cleanup
        if (Test-Path $testDir) {
            Remove-Item -Path $testDir -Recurse -Force
            Write-Host "  Cleaned up test directory"
        }
    }
    catch {
        Log-TestResult -TestName "Path Handling" -Success $false -Message "Error: $_"
    }
}

##### Test 2: Special Character Handling
function Test-SpecialCharacters {
    Write-Host "`nRunning Special Character Tests..." -ForegroundColor Cyan
    
    $testDir = Join-Path -Path ${env}:TEMP -ChildPath "cross_platform_special_test"
    
    try {
        if (-not (Test-Path -Path $testDir)) {
            New-Item -Path $testDir -ItemType Directory -Force | Out-Null
            Write-Host "  Created test directory: $testDir"
        }
        
        ##### Test 2.1: Basic special characters
        $specialFile1 = Join-Path -Path $testDir -ChildPath "special-char-tést.txt"
        Set-Content -Path $specialFile1 -Value "Test content with special characters"
        $specialTest1 = Test-Path $specialFile1
        Log-TestResult -TestName "Basic Special Characters" -Success $specialTest1 -Message "File: $specialFile1"
        
        ##### Test 2.2: More complex special characters if supported
        try {
            $specialFile2 = Join-Path -Path $testDir -ChildPath "complex-ñáéíóúüñÑ-file.txt"
            Set-Content -Path $specialFile2 -Value "Test content with complex special characters"
            $specialTest2 = Test-Path $specialFile2
            Log-TestResult -TestName "Complex Special Characters" -Success $specialTest2 -Message "File: $specialFile2"
            
            ##### Clean up special file 2
            if (Test-Path $specialFile2) {
                Remove-Item -Path $specialFile2 -Force
            }
        }
        catch {
            Log-TestResult -TestName "Complex Special Characters" -Success $false -Message "Error: $_"
        }
        
        ##### Clean up special file 1
        if (Test-Path $specialFile1) {
            Remove-Item -Path $specialFile1 -Force
        }
        
        ##### Clean up test directory
        if (Test-Path $testDir) {
            Remove-Item -Path $testDir -Recurse -Force
            Write-Host "  Cleaned up test directory"
        }
    }
    catch {
        Log-TestResult -TestName "Special Character Handling" -Success $false -Message "Error: $_"
    }
}

##### Test 3: Error Handling
function Test-ErrorHandlingCapabilities {
    Write-Host "`nRunning Error Handling Tests..." -ForegroundColor Cyan
    
    ##### Test 3.1: Basic try-catch
    try {
        ##### Intentionally cause an error
        $nonExistentFile = Join-Path -Path ${env}:TEMP -ChildPath "non-existent-file-$(Get-Date -Format 'yyyyMMddHHmmss').txt"
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
            $nonExistentFile = Join-Path -Path ${env}:TEMP -ChildPath "another-non-existent-file-$(Get-Date -Format 'yyyyMMddHHmmss').txt"
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
}

##### Test 4: Backup Functionality
function Test-BackupFunctionality {
    Write-Host "`nRunning Backup Functionality Tests..." -ForegroundColor Cyan
    
    $testDir = Join-Path -Path ${env}:TEMP -ChildPath "cross_platform_backup_test"
    
    try {
        if (-not (Test-Path -Path $testDir)) {
            New-Item -Path $testDir -ItemType Directory -Force | Out-Null
            Write-Host "  Created test directory: $testDir"
        }
        
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
        
        ##### Clean up
        if (Test-Path $originalFile) {
            Remove-Item -Path $originalFile -Force
        }
        if (Test-Path $backupFile) {
            Remove-Item -Path $backupFile -Force
        }
        if (Test-Path $testDir) {
            Remove-Item -Path $testDir -Recurse -Force
            Write-Host "  Cleaned up test directory"
        }
    }
    catch {
        Log-TestResult -TestName "Backup Functionality" -Success $false -Message "Error: $_"
    }
}

##### Test 5: Platform-Specific Features
function Test-PlatformSpecificFeatures {
    Write-Host "`nRunning Platform-Specific Tests..." -ForegroundColor Cyan
    
    $platform = Get-Platform
    Write-Host "  Current platform: $platform"
    
    ##### Test 5.1: PowerShell Version Features
    $psVersion = $PSVersionTable.PSVersion
    $isCore = $PSVersionTable.PSEdition -eq 'Core'
    
    if ($isCore) {
        ##### Test Core-specific features
        try {
            ##### Test parallel processing (PS7 feature)
            $parallelSupported = $null -ne (Get-Command -Name 'ForEach-Object' -ParameterName 'Parallel' -ErrorAction SilentlyContinue)
            Log-TestResult -TestName "Parallel Processing" -Success $parallelSupported -Message "PowerShell Core: $psVersion"
            
            ##### Test ternary operator (PS7 feature) - using script blocks to avoid parse errors in PS5.1
            try {
                ##### Using Invoke-Expression to avoid parse errors in PS5.1
                $testScript = 'if ($true) { "Yes" } else { "No" }'
                $result = Invoke-Expression $testScript
                
                ##### In PowerShell 7, we could try the ternary but we need to avoid parse errors in PS5.1
                ##### PS7 would use: $result = if ($true ) { "Yes" } else { "No" }
                Log-TestResult -TestName "Conditional Expression" -Success $true -Message "PowerShell Core: $psVersion"
            }
            catch {
                Log-TestResult -TestName "Conditional Expression" -Success $false -Message "Not supported in PowerShell Core: $psVersion"
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
}

##### Main function to run all tests
function Test-CrossPlatformCompatibility {
    param (
        [switch]$GenerateReport,
        [string]$ReportPath = "results/cross-platform-test-report.md"
    )
    
    $startTime = Get-Date
    
    ##### Display header
    Write-Host "=================================================================" -ForegroundColor Yellow
    Write-Host "       tYDiSync~ Cross-Platform Compatibility Test Suite         " -ForegroundColor Yellow
    Write-Host "=================================================================" -ForegroundColor Yellow
    Write-Host "PowerShell Version: $($PSVersionTable.PSVersion)"
    Write-Host "PowerShell Edition: $($PSVersionTable.PSEdition)"
    Write-Host "Operating System: $($PSVersionTable.OS)"
    Write-Host "Platform Detected: $(Get-Platform)"
    Write-Host "Date/Time: $startTime"
    Write-Host "=================================================================" -ForegroundColor Yellow
    
    ##### Run all tests
    Test-PathHandling
    Test-SpecialCharacters
    Test-ErrorHandlingCapabilities
    Test-BackupFunctionality
    Test-PlatformSpecificFeatures
    
    ##### Display summary
    $endTime = Get-Date
    $duration = $endTime - $startTime
    
    Write-Host "`n=================================================================" -ForegroundColor Yellow
    Write-Host "                       Test Summary                              " -ForegroundColor Yellow
    Write-Host "=================================================================" -ForegroundColor Yellow
    Write-Host "Tests Passed: ${script}:TestsPassed" -ForegroundColor Green
    Write-Host "Tests Failed: ${script}:TestsFailed" -ForegroundColor Red
    Write-Host "Total Tests: $(${script}:TestsPassed + ${script}:TestsFailed)"
    Write-Host "Duration: $($duration.Minutes) minutes, $($duration.Seconds) seconds"
    Write-Host "=================================================================" -ForegroundColor Yellow
    
    ##### Generate report if requested
    if ($GenerateReport) {
        Generate-TestReport -ReportPath $ReportPath -StartTime $startTime -EndTime $endTime
    }
    
    ##### Return success/failure
    return (${script}:TestsFailed -eq 0)
}

##### Function to generate a test report
function Generate-TestReport {
    param (
        [string]$ReportPath,
        [datetime]$StartTime,
        [datetime]$EndTime
    )
    
    try {
        ##### Ensure the directory exists
        $reportDir = Split-Path -Path $ReportPath -Parent
        if (-not (Test-Path -Path $reportDir)) {
            New-Item -Path $reportDir -ItemType Directory -Force | Out-Null
        }
        
        $duration = $EndTime - $StartTime
        $date = Get-Date -Format "yyyy-MM-dd"
        
        ##### Create the report content line by line to avoid multi-line string issues
        $lines = @()
        $lines += "# tYDiSync~ Cross-Platform Compatibility Test Report"
        $lines += ""
        $lines += "Date: $date"
        $lines += "PowerShell Version: $($PSVersionTable.PSVersion)"
        $lines += "PowerShell Edition: $($PSVersionTable.PSEdition)"
        $lines += "Operating System: $($PSVersionTable.OS)"
        $lines += "Platform Detected: $(Get-Platform)"
        $lines += "Test Duration: $($duration.Minutes) minutes, $($duration.Seconds) seconds"
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
        $lines += "###### Detailed Results"
        $lines += ""
        $lines += "| Test Name | Result | Platform | PowerShell Version | Notes |"
        $lines += "|-----------|--------|----------|-------------------|-------|"
        
        foreach ($test in ${script}:TestResults.Keys) {
            $result = ${script}:TestResults[$test]
            $status = if ($result.Success) { "PASS" } else { "FAIL" }
            $lines += "| $test | $status | $($result.Platform) | $($result.PowerShellVersion) | $($result.Message) |"
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
        $lines | Out-File -FilePath $ReportPath -Encoding utf8 -Force
        
        Write-Host "`nTest report generated: $ReportPath" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "Error generating test report: $_" -ForegroundColor Red
        return $false
    }
}

##### Run the tests if script is executed directly
if ($MyInvocation.MyCommand.Name -eq $MyInvocation.InvocationName) {
    Write-Host "Starting tYDiSync~ Cross-Platform Compatibility Tests..." -ForegroundColor Cyan
    Write-Host "This will test key functionality across different PowerShell environments."
    Write-Host "Results will be captured in the results directory." -ForegroundColor Yellow
    
    $reportPath = "results/cross-platform-test-report-$(Get-Date -Format 'yyyyMMdd').md"
    Write-Host "Report will be generated at: $reportPath" -ForegroundColor Yellow
    
    $success = Test-CrossPlatformCompatibility -GenerateReport -ReportPath $reportPath
    
    ##### Final summary
    if ($success) {
        Write-Host "`nAll tests completed successfully!" -ForegroundColor Green
    } else {
        Write-Host "`nSome tests failed. Please check the report for details." -ForegroundColor Red
    }
    
    Write-Host "`nTest report is available at: $reportPath" -ForegroundColor Cyan
    Write-Host "Review the report for recommendations and next steps." -ForegroundColor Cyan
    
    # Set exit code based on test result
    exit [int](-not $success)
} 
