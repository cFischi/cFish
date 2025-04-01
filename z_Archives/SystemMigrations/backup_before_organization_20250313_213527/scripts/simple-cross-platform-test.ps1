# Simple Cross-Platform Compatibility Test Script
# This is a simplified version to demonstrate key concepts

# Set error handling preferences
$ErrorActionPreference = 'Stop'

# Initialize test counter
$TestFailures = 0

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

##### Main function
function Test-CrossPlatform {
    Write-Host "Starting Cross-Platform Tests"
    Write-Host "PowerShell Version: $($PSVersionTable.PSVersion)"
    Write-Host "Platform: $(Get-Platform)"
    
    ##### Create a test directory
    $testDir = Join-Path -Path ${env}:TEMP -ChildPath "simple_cross_platform_test"
    
    if (-not (Test-Path -Path $testDir)) {
        New-Item -Path $testDir -ItemType Directory -Force | Out-Null
        Write-Host "Created test directory: $testDir"
    }
    
    ##### Test path separators
    $forwardSlashPath = $testDir.Replace('\', '/')
    $backslashPath = $testDir.Replace('/', '\')
    
    Write-Host "Testing path with forward slashes: $forwardSlashPath"
    if (Test-Path $forwardSlashPath) {
        Write-Host "Forward slash path works" -ForegroundColor Green
    } else {
        Write-Host "Forward slash path failed" -ForegroundColor Red
        $TestFailures++
    }
    
    Write-Host "Testing path with backslashes: $backslashPath"
    if (Test-Path $backslashPath) {
        Write-Host "Backslash path works" -ForegroundColor Green
    } else {
        Write-Host "Backslash path failed" -ForegroundColor Red
        $TestFailures++
    }
    
    ##### Test special characters (if supported)
    try {
        $specialFile = Join-Path -Path $testDir -ChildPath "special-char-tést.txt"
        Set-Content -Path $specialFile -Value "Test content" -ErrorAction Stop
        Write-Host "Special character handling works" -ForegroundColor Green
        
        ##### Clean up
        if (Test-Path $specialFile) {
            Remove-Item -Path $specialFile -Force
        }
    }
    catch {
        Write-Host "Special character handling failed: $_" -ForegroundColor Red
        $TestFailures++
    }
    
    ##### Clean up
    if (Test-Path $testDir) {
        Remove-Item -Path $testDir -Recurse -Force
        Write-Host "Cleaned up test directory"
    }
    
    ##### Report results
    if ($TestFailures -eq 0) {
        Write-Host "All tests passed!" -ForegroundColor Green
    } else {
        Write-Host "$TestFailures test(s) failed!" -ForegroundColor Red
    }
}

# Run the tests
Test-CrossPlatform 
