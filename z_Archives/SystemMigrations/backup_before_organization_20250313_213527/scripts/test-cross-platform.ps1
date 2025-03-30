# test-cross-platform.ps1
# Purpose: Test PowerShell scripts for cross-platform compatibility
# Ticket: CFIO-2025-03
# Created: 2025-03-12
# Updated: 2025-03-13

# Set strict mode to catch common errors
Set-StrictMode -Version 3.0
$ErrorActionPreference = "Stop"

##### Initialize test environment
function Initialize-TestEnvironment {
    Write-Host "=================================================================" -ForegroundColor Cyan
    Write-Host "      tYDiSync~ Cross-Platform Compatibility Test Script         " -ForegroundColor Cyan
    Write-Host "=================================================================" -ForegroundColor Cyan
    
    ##### Display PowerShell version and platform info
    $PSVersionTable | Format-Table Name, Value -AutoSize
    
    ##### Create test directories if they don't exist
    $testDir = Join-Path -Path $PSScriptRoot -ChildPath "test-cross-platform"
    if (-not (Test-Path $testDir)) {
        New-Item -Path $testDir -ItemType Directory -Force | Out-Null
        Write-Host "Created test directory: $testDir" -ForegroundColor Green
    }
    
    ##### Create logs directory if it doesn't exist
    $logsDir = Join-Path -Path $PSScriptRoot -ChildPath "../logs"
    if (-not (Test-Path $logsDir)) {
        New-Item -Path $logsDir -ItemType Directory -Force | Out-Null
        Write-Host "Created logs directory: $logsDir" -ForegroundColor Green
    }
    
    return $testDir
}

##### Test path handling across platforms
function Test-PathHandling {
    param (
        [string]$TestDir
    )
    
    Write-Host "`nTesting Path Handling..." -ForegroundColor Yellow
    
    ##### Test absolute paths
    $absolutePath = Resolve-Path $TestDir
    Write-Host "Absolute path: $absolutePath" -ForegroundColor Gray
    
    ##### Test relative paths
    $relativePath = Resolve-Path $TestDir -Relative
    Write-Host "Relative path: $relativePath" -ForegroundColor Gray
    
    ##### Test path normalization
    $normalizedPath = [System.IO.Path]::GetFullPath($TestDir)
    Write-Host "Normalized path: $normalizedPath" -ForegroundColor Gray
    
    ##### Test path separator handling
    $testFilePath = Join-Path -Path $TestDir -ChildPath "test-file.txt"
    Set-Content -Path $testFilePath -Value "Cross-platform path test"
    
    ##### Test if the file exists using both slashes
    $forwardSlashPath = $testFilePath.Replace("\", "/")
    $backslashPath = $forwardSlashPath.Replace("/", "\")
    
    Write-Host "Testing forward slash path: $forwardSlashPath" -ForegroundColor Gray
    $forwardSlashExists = Test-Path $forwardSlashPath
    
    Write-Host "Testing backslash path: $backslashPath" -ForegroundColor Gray
    $backslashExists = Test-Path $backslashPath
    
    ##### Report results
    if ($forwardSlashExists -and $backslashExists) {
        Write-Host "✓ Path separator handling test passed" -ForegroundColor Green
    } else {
        Write-Host "✗ Path separator handling test failed" -ForegroundColor Red
    }
    
    return $testFilePath
}

##### Test backup functionality
function Test-BackupFunctionality {
    param (
        [string]$TestDir,
        [string]$TestFilePath
    )
    
    Write-Host "`nTesting Backup Functionality..." -ForegroundColor Yellow
    
    ##### Define the backup directory
    $backupDir = Join-Path -Path $TestDir -ChildPath "backups"
    if (-not (Test-Path $backupDir)) {
        New-Item -Path $backupDir -ItemType Directory -Force | Out-Null
    }
    
    ##### Create a timestamp for the backup file
    $timestamp = Get-Date -Format "yyyyMMddHHmmss"
    $fileName = [System.IO.Path]::GetFileName($TestFilePath)
    $backupFileName = "backup_${timestamp}_$fileName"
    $backupPath = Join-Path -Path $backupDir -ChildPath $backupFileName
    
    ##### Backup the file
    try {
        Copy-Item -Path $TestFilePath -Destination $backupPath -Force
        Write-Host "✓ File backup created: $backupPath" -ForegroundColor Green
        
        ##### Verify backup content
        $originalContent = Get-Content -Path $TestFilePath -Raw
        $backupContent = Get-Content -Path $backupPath -Raw
        
        if ($originalContent -eq $backupContent) {
            Write-Host "✓ Backup content verification passed" -ForegroundColor Green
        } else {
            Write-Host "✗ Backup content verification failed" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "✗ Backup functionality test failed: $_" -ForegroundColor Red
    }
}

##### Test error handling
function Test-ErrorHandling {
    Write-Host "`nTesting Error Handling..." -ForegroundColor Yellow
    
    try {
        ##### Try to access a non-existent file
        $nonExistentFile = "ThisFileDoesNotExist.txt"
        Get-Content -Path $nonExistentFile -ErrorAction Stop
        Write-Host "✗ Error handling test failed - should have thrown an error" -ForegroundColor Red
    }
    catch {
        Write-Host "✓ Error handling test passed - caught exception properly" -ForegroundColor Green
        
        ##### Test handling of $_ variable in strings (this was the linter error fixed previously)
        $errorMessage = $_.Exception.Message
        Write-Host "  Error message: $errorMessage" -ForegroundColor Gray
        
        ##### Test using subexpression syntax
        Write-Host "  Error using subexpression: $($_.Exception.Message)" -ForegroundColor Gray
    }
}

##### Function to detect current platform
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

##### Add platform-specific path testing
function Test-PlatformSpecificPaths {
    param (
        [string]$TestDir
    )
    
    Write-Host "`nTesting Platform-Specific Path Formats..." -ForegroundColor Yellow
    
    $platform = Get-CurrentPlatform
    Write-Host "Current platform: $platform" -ForegroundColor Cyan
    
    try {
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
        
        ##### Test with various path separators
        $forwardSlashPath = $TestDir.Replace('\', '/')
        $backslashPath = $TestDir.Replace('/', '\')
        
        if (Test-Path $forwardSlashPath) {
            Write-Host "✓ Forward slash path works: $forwardSlashPath" -ForegroundColor Green
        }
        else {
            Write-Host "✗ Forward slash path failed: $forwardSlashPath" -ForegroundColor Red
            ${Global}:TestFailures += 1
        }
        
        if (Test-Path $backslashPath) {
            Write-Host "✓ Backslash path works: $backslashPath" -ForegroundColor Green
        }
        else {
            Write-Host "✗ Backslash path failed: $backslashPath" -ForegroundColor Red
            ${Global}:TestFailures += 1
        }
    }
    catch {
        Write-Host "✗ Platform-specific path test failed: $_" -ForegroundColor Red
        ${Global}:TestFailures += 1
    }
}

##### Function to test file operations with special characters
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
            Remove-Item -Path $specialCharFile
        } 
        else {
            Write-Host "✗ Special character file does not exist" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "✗ Special character handling test failed: $_" -ForegroundColor Red
        ${Global}:TestFailures += 1
    }
    finally {
        ##### Clean up if the file still exists
        if (Test-Path $specialCharFile) {
            try {
                Remove-Item -Path $specialCharFile -Force -ErrorAction SilentlyContinue
                Write-Host "  Cleaned up special character test file" -ForegroundColor Gray
            }
            catch {
                Write-Host "Warning: Could not clean up test file: $_" -ForegroundColor Yellow
            }
        }
    }
}

##### Main cross-platform test function
function Run-CrossPlatformTests {
    param (
        [string]$TestLocation = "temp"
    )
    
    Write-Host "==================================================================" -ForegroundColor Cyan
    Write-Host "          Cross-Platform Compatibility Test Suite" -ForegroundColor Cyan
    Write-Host "==================================================================" -ForegroundColor Cyan
    
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
        
        ##### Run the path format tests
        Test-PlatformSpecificPaths -TestDir $testDir
        Write-Host "✓ Platform-specific path tests completed" -ForegroundColor Green
        
        ##### Run special character tests
        Test-SpecialCharacters -TestDir $testDir
        Write-Host "✓ Special character tests completed" -ForegroundColor Green
        
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
