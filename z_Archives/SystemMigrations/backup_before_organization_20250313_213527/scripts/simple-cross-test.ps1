# Simple Cross-Platform Test Script
# This is a simplified version to ensure proper execution

Write-Host "Starting Simple Cross-Platform Test..." -ForegroundColor Cyan

##### Enhanced platform detection that works in both Windows PowerShell 5.1 and PowerShell Core
function Get-PlatformInfo {
    ##### Create a custom object to hold platform information
    $platformInfo = [PSCustomObject]@{
        IsCore            = $false
        IsWindows         = $false
        IsLinux           = $false
        IsMacOS           = $false
        PlatformName      = ""
        PathSeparator     = [IO.Path]::DirectorySeparatorChar
        PSVersion         = $PSVersionTable.PSVersion
    }

    ##### Check if running PowerShell Core
    if ($PSVersionTable.PSEdition -eq 'Core') {
        $platformInfo.IsCore = $true
        
        ##### PowerShell Core specific platform checks
        if (Test-Path variable:IsWindows) {
            if ($IsWindows) {
                $platformInfo.IsWindows = $true
                $platformInfo.PlatformName = "PowerShell Core (Windows)"
            }
        } 
        elseif (Test-Path variable:IsLinux) {
            if ($IsLinux) {
                $platformInfo.IsLinux = $true
                $platformInfo.PlatformName = "PowerShell Core (Linux)"
            }
        }
        elseif (Test-Path variable:IsMacOS) {
            if ($IsMacOS) {
                $platformInfo.IsMacOS = $true
                $platformInfo.PlatformName = "PowerShell Core (macOS)"
            }
        }
        else {
            ##### Fallback for PowerShell Core when automatic variables are not available
            try {
                ##### Try using .NET Core's RuntimeInformation
                Add-Type -TypeDefinition @"
                using System;
                using System.Runtime.InteropServices;
                public class PlatformDetection {
                    public static bool IsWindows() { return RuntimeInformation.IsOSPlatform(OSPlatform.Windows); }
                    public static bool IsLinux() { return RuntimeInformation.IsOSPlatform(OSPlatform.Linux); }
                    public static bool IsOSX() { return RuntimeInformation.IsOSPlatform(OSPlatform.OSX); }
                }
"@ -ErrorAction SilentlyContinue

                if ([PlatformDetection]::IsWindows()) {
                    $platformInfo.IsWindows = $true
                    $platformInfo.PlatformName = "PowerShell Core (Windows)"
                }
                elseif ([PlatformDetection]::IsLinux()) {
                    $platformInfo.IsLinux = $true
                    $platformInfo.PlatformName = "PowerShell Core (Linux)"
                }
                elseif ([PlatformDetection]::IsOSX()) {
                    $platformInfo.IsMacOS = $true
                    $platformInfo.PlatformName = "PowerShell Core (macOS)"
                }
            }
            catch {
                ##### Last resort: check platform using .NET Framework approach
                if ([System.Environment]::OSVersion.Platform -eq "Win32NT") {
                    $platformInfo.IsWindows = $true
                    $platformInfo.PlatformName = "PowerShell Core (Windows)"
                }
                elseif ([System.Environment]::OSVersion.Platform -eq "Unix") {
                    ##### Further distinguish between Linux and macOS
                    if (Test-Path "/System/Library/CoreServices/SystemVersion.plist") {
                        $platformInfo.IsMacOS = $true
                        $platformInfo.PlatformName = "PowerShell Core (macOS)"
                    }
                    else {
                        $platformInfo.IsLinux = $true
                        $platformInfo.PlatformName = "PowerShell Core (Linux)"
                    }
                }
                else {
                    $platformInfo.PlatformName = "PowerShell Core (Unknown)"
                }
            }
        }
    }
    else {
        ##### Windows PowerShell
        $platformInfo.IsWindows = $true
        $platformInfo.PlatformName = "Windows PowerShell"
    }

    return $platformInfo
}

##### Get platform information
$Platform = Get-PlatformInfo

Write-Host "Platform: $($Platform.PlatformName)" -ForegroundColor Yellow
Write-Host "PowerShell Version: $($Platform.PSVersion)" -ForegroundColor Yellow
Write-Host "Is Windows: $($Platform.IsWindows)" -ForegroundColor Yellow
Write-Host "Is Linux: $($Platform.IsLinux)" -ForegroundColor Yellow
Write-Host "Is macOS: $($Platform.IsMacOS)" -ForegroundColor Yellow

##### Test 1: Path handling
Write-Host "`nTest 1: Path Handling" -ForegroundColor Green
$testDir = Join-Path -Path ${env}:TEMP -ChildPath "simple_test_$(Get-Date -Format 'yyyyMMddHHmmss')"
New-Item -Path $testDir -ItemType Directory -Force | Out-Null
Write-Host "Created test directory: $testDir"

$forwardSlashPath = $testDir.Replace('\', '/')
$pathWorksForward = Test-Path $forwardSlashPath
Write-Host "Forward slash path works: $pathWorksForward"

##### Test 2: Special characters
Write-Host "`nTest 2: Special Characters" -ForegroundColor Green
try {
    $specialFile = Join-Path -Path $testDir -ChildPath "special-char-test.txt"
    Set-Content -Path $specialFile -Value "Test content" -ErrorAction Stop
    Write-Host "Special character file created: $specialFile"
    Remove-Item -Path $specialFile -Force -ErrorAction SilentlyContinue
} catch {
    Write-Host "Error with special character file: $_" -ForegroundColor Red
}

##### Test 3: Error handling
Write-Host "`nTest 3: Error Handling" -ForegroundColor Green
try {
    ##### Intentionally cause an error
    $nonExistentFile = Join-Path -Path $testDir -ChildPath "non-existent-file.txt"
    Get-Content -Path $nonExistentFile -ErrorAction Stop
} catch {
    Write-Host "Successfully caught error (expected behavior)"
}

##### Cleanup
if (Test-Path -Path $testDir) {
    Remove-Item -Path $testDir -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "`nCleaned up test directory"
}

##### Write a simple report
$reportPath = "results/simple-test-report.txt"
$reportDir = Split-Path -Path $reportPath -Parent
if (-not (Test-Path -Path $reportDir)) {
    New-Item -Path $reportDir -ItemType Directory -Force | Out-Null
}

@"
Simple Cross-Platform Test Report
================================
Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
Platform: $($Platform.PlatformName)
PowerShell Version: $($Platform.PSVersion)

All tests completed.
"@ | Out-File -FilePath $reportPath -Encoding utf8 -Force

Write-Host "`nTest report written to: $reportPath" -ForegroundColor Green
Write-Host "All tests completed!" -ForegroundColor Cyan 
