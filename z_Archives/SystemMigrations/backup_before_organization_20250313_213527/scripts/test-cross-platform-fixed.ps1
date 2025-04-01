<#
.SYNOPSIS
    Cross-Platform Compatibility Test Suite for tYDiSync~
.DESCRIPTION
    This script tests various aspects of cross-platform compatibility
    including path handling, special character support, and platform detection.
.NOTES
    Version:        1.0
    Author:         tYFischEYe
    Creation Date:  2025-03-13
    Last Modified:  2025-03-13
#>

# Set strict mode and error action preference for consistent error handling
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Initialize global test counter
${Global}:TestFailures = 0

# Function to detect current platform
function Get-CurrentPlatform {
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

##### Function to test path handling with different separators
function Test-PathSeparators {
    param (
        [string]$TestDir
    )
    
    Write-Host "`nTesting Path Separators..." -ForegroundColor Yellow
    
    try {
        ##### Test with forward slashes
        $forwardSlashPath = $TestDir.Replace('\', '/')
        if (Test-Path $forwardSlashPath) {
            Write-Host "✓ Forward slash path works: $forwardSlashPath" -ForegroundColor Green
        }
        else {
            Write-Host "✗ Forward slash path failed: $forwardSlashPath" -ForegroundColor Red
            ${Global}:TestFailures++
        }
        
        ##### Test with backslashes
        $backslashPath = $TestDir.Replace('/', '\')
        if (Test-Path $backslashPath) {
            Write-Host "✓ Backslash path works: $backslashPath" -ForegroundColor Green
        }
        else {
            Write-Host "✗ Backslash path failed: $backslashPath" -ForegroundColor Red
            ${Global}:TestFailures++
        }
    }
    catch {
        Write-Host "✗ Path separator test failed: $_" -ForegroundColor Red
        ${Global}:TestFailures++
    }
}

##### Function to test platform-specific paths
function Test-PlatformSpecificPaths {
    param (
        [string]$TestDir
    )
    
    Write-Host "`nTesting Platform-Specific Path Formats..." -ForegroundColor Yellow
    
    try {
        $platform = Get-CurrentPlatform
        Write-Host "Current platform: $platform" -ForegroundColor Cyan
        
        ##### Create a test file based on the platform
        switch ($platform) {
            "Linux" {
                $testPath = Join-Path -Path $TestDir -ChildPath "linux_test_file.txt"
                Set-Content -Path $testPath -Value "Linux test file"
                Write-Host "✓ Created Linux test file: $testPath" -ForegroundColor Green
                Remove-Item -Path $testPath -Force
            }
            "macOS" {
                $testPath = Join-Path -Path $TestDir -ChildPath "macos_test_file.txt"
                Set-Content -Path $testPath -Value "macOS test file"
                Write-Host "✓ Created macOS test file: $testPath" -ForegroundColor Green
                Remove-Item -Path $testPath -Force
            }
            default {
                $testPath = Join-Path -Path $TestDir -ChildPath "windows_test_file.txt"
                Set-Content -Path $testPath -Value "Windows test file"
                Write-Host "✓ Created Windows test file: $testPath" -ForegroundColor Green
                Remove-Item -Path $testPath -Force
            }
        }
    }
    catch {
        Write-Host "✗ Platform-specific path test failed: $_" -ForegroundColor Red
        ${Global}:TestFailures++
    }
}

##### Function to test special character handling in filenames
function Test-SpecialCharacters {
    param (
        [string]$TestDir
    )
    
    Write-Host "`nTesting Special Character Handling..." -ForegroundColor Yellow
    
    ##### Test file with special characters in name
    $specialCharFile = Join-Path -Path $TestDir -ChildPath "special-char-tést~#file.txt"
    
    try {
        Set-Content -Path $specialCharFile -Value "File with special characters in name"
        Write-Host "✓ Created file with special characters: $specialCharFile" -ForegroundColor Green
        
        if (Test-Path $specialCharFile) {
            Write-Host "✓ Special character file exists" -ForegroundColor Green
            Remove-Item -Path $specialCharFile -Force
            Write-Host "✓ Removed special character file" -ForegroundColor Green
        } 
        else {
            Write-Host "✗ Special character file does not exist" -ForegroundColor Red
            ${Global}:TestFailures++
        }
    }
    catch {
        Write-Host "✗ Special character handling test failed: $_" -ForegroundColor Red
        ${Global}:TestFailures++
    }
    finally {
        ##### Clean up if the file still exists
        if (Test-Path $specialCharFile) {
            try {
                Remove-Item -Path $specialCharFile -Force -ErrorAction SilentlyContinue
                Write-Host "  Cleaned up special character test file" -ForegroundColor Gray
            }
            catch {
                Write-Host "  Warning: Could not clean up test file: $_" -ForegroundColor Yellow
            }
        }
    }
}

##### Function to test error handling
function Test-ErrorHandling {
    Write-Host "`nTesting Error Handling..." -ForegroundColor Yellow
    
    try {
        ##### Simulate an error
        Write-Host "  Simulating an error..." -ForegroundColor Gray
        $nonExistentFile = Join-Path -Path ${env}:TEMP -ChildPath "non-existent-file-$(Get-Date -Format 'yyyyMMddHHmmss').txt"
        $content = Get-Content -Path $nonExistentFile -ErrorAction Stop
        
        ##### Should not reach here
        Write-Host "✗ Error handling test failed: Expected error was not thrown" -ForegroundColor Red
        ${Global}:TestFailures++
    }
    catch {
        Write-Host "✓ Error was caught successfully: $_" -ForegroundColor Green
    }
}

##### Function to create and test a backup
function Test-BackupFunctionality {
    param (
        [string]$TestDir
    )
    
    Write-Host "`nTesting Backup Functionality..." -ForegroundColor Yellow
    
    $originalFile = Join-Path -Path $TestDir -ChildPath "original.txt"
    $backupFile = Join-Path -Path $TestDir -ChildPath "original.bak"
    
    try {
        ##### Create an original file
        Set-Content -Path $originalFile -Value "Original content"
        Write-Host "✓ Created original file: $originalFile" -ForegroundColor Green
        
        ##### Create a backup
        Copy-Item -Path $originalFile -Destination $backupFile -Force
        Write-Host "✓ Created backup file: $backupFile" -ForegroundColor Green
        
        ##### Verify backup
        if (Test-Path $backupFile) {
            $originalContent = Get-Content -Path $originalFile -Raw
            $backupContent = Get-Content -Path $backupFile -Raw
            
            if ($originalContent -eq $backupContent) {
                Write-Host "✓ Backup content matches original" -ForegroundColor Green
            }
            else {
                Write-Host "✗ Backup content does not match original" -ForegroundColor Red
                ${Global}:TestFailures++
            }
        }
        else {
            Write-Host "✗ Backup file was not created" -ForegroundColor Red
            ${Global}:TestFailures++
        }
    }
    catch {
        Write-Host "✗ Backup functionality test failed: $_" -ForegroundColor Red
        ${Global}:TestFailures++
    }
    finally {
        ##### Clean up test files
        if (Test-Path $originalFile) {
            Remove-Item -Path $originalFile -Force -ErrorAction SilentlyContinue
        }
        if (Test-Path $backupFile) {
            Remove-Item -Path $backupFile -Force -ErrorAction SilentlyContinue
        }
    }
}

##### Main test function
function Run-CrossPlatformTests {
    param (
        [string]$TestLocation = "temp"
    )
    
    Write-Host "==================================================================" -ForegroundColor Cyan
    Write-Host "          Cross-Platform Compatibility Test Suite" -ForegroundColor Cyan
    Write-Host "==================================================================" -ForegroundColor Cyan
    Write-Host "PowerShell Version: $($PSVersionTable.PSVersion)" -ForegroundColor White
    Write-Host "OS: $($PSVersionTable.OS)" -ForegroundColor White
    Write-Host "Platform: $(Get-CurrentPlatform)" -ForegroundColor White
    Write-Host "==================================================================" -ForegroundColor Cyan
    
    ##### Reset global test counter
    ${Global}:TestFailures = 0
    
    try {
        ##### Create a unique test directory
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $testDirName = "cross_platform_test_$timestamp"
        
        $testDir = if ($TestLocation -eq "temp") {
            Join-Path -Path ${env}:TEMP -ChildPath $testDirName
        } else {
            Join-Path -Path $TestLocation -ChildPath $testDirName
        }
        
        ##### Create the test directory
        if (-not (Test-Path -Path $testDir)) {
            New-Item -Path $testDir -ItemType Directory -Force | Out-Null
            Write-Host "✓ Created test directory: $testDir" -ForegroundColor Green
        }
        
        ##### Run the tests
        Test-PathSeparators -TestDir $testDir
        Test-PlatformSpecificPaths -TestDir $testDir
        Test-SpecialCharacters -TestDir $testDir
        Test-ErrorHandling
        Test-BackupFunctionality -TestDir $testDir
        
        ##### Print summary
        Write-Host "`n==================================================================" -ForegroundColor Cyan
        if (${Global}:TestFailures -eq 0) {
            Write-Host "✓ All tests passed successfully!" -ForegroundColor Green
        } else {
            Write-Host "✗ ${Global}:TestFailures test(s) failed!" -ForegroundColor Red
        }
        Write-Host "==================================================================" -ForegroundColor Cyan
        
        ##### Clean up
        if (Test-Path -Path $testDir) {
            Remove-Item -Path $testDir -Recurse -Force
            Write-Host "✓ Cleaned up test directory" -ForegroundColor Green
        }
        
        return ${Global}:TestFailures -eq 0
    }
    catch {
        Write-Host "✗ Cross-platform test error: $_" -ForegroundColor Red
        Write-Host "  Stack trace: $($_.ScriptStackTrace)" -ForegroundColor Red
        return $false
    }
}

# Execute the test function if script is run directly
if ($MyInvocation.InvocationName -eq $MyInvocation.MyCommand.Name) {
    $result = Run-CrossPlatformTests
    
    if ($result) {
        exit 0
    } else {
        exit 1
    }
} 
