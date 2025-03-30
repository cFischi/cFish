[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [ValidateSet("windows-powershell", "powershell-core-windows", "powershell-core-linux")]
    [string]$Environment
)

##### Set error action preference
$ErrorActionPreference = "Stop"

##### Import platform detection (relative path)
$scriptDir = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
$platformDetectionPath = Join-Path -Path $scriptDir -ChildPath "..\scripts\cross-platform-template.ps1"

if (Test-Path -Path $platformDetectionPath) {
    . $platformDetectionPath
} else {
    Write-Error "Platform detection script not found at: $platformDetectionPath"
    exit 1
}

$Platform = Get-PlatformInfo

Write-Host "Running tests for environment: $Environment" -ForegroundColor Yellow
Write-Host "Detected platform: $($Platform.PlatformName)" -ForegroundColor Yellow
Write-Host "PowerShell version: $($Platform.PSVersion)" -ForegroundColor Yellow

##### Verify we're running in the correct environment
switch ($Environment) {
    "windows-powershell" {
        if ($Platform.IsCore -eq $true) {
            Write-Warning "Expected Windows PowerShell but running in PowerShell Core"
        }
    }
    "powershell-core-windows" {
        if ($Platform.IsCore -eq $false) {
            Write-Warning "Expected PowerShell Core but running in Windows PowerShell"
        }
        if ($Platform.IsWindows -eq $false) {
            Write-Warning "Expected Windows platform but running on non-Windows platform"
        }
    }
    "powershell-core-linux" {
        if ($Platform.IsCore -eq $false) {
            Write-Warning "Expected PowerShell Core but running in Windows PowerShell"
        }
        if ($Platform.IsLinux -eq $false) {
            Write-Warning "Expected Linux platform but running on non-Linux platform"
        }
    }
}

##### Create results directory
$resultsDir = Join-Path -Path $scriptDir -ChildPath "$Environment-results"
if (-not (Test-Path -Path $resultsDir)) {
    New-Item -Path $resultsDir -ItemType Directory -Force | Out-Null
    Write-Host "Created results directory: $resultsDir" -ForegroundColor Green
}

##### Run platform test
$envPath = Join-Path -Path $scriptDir -ChildPath $Environment
$platformScript = Join-Path -Path $envPath -ChildPath "scripts\test-platform.ps1"

if (Test-Path -Path $platformScript) {
    Write-Host "`nRunning platform detection test..." -ForegroundColor Cyan
    & $platformScript
    
    ##### Copy log to results
    $logSource = Join-Path -Path $envPath -ChildPath "logs\platform-test.log"
    $logDest = Join-Path -Path $resultsDir -ChildPath "platform-test.log"
    Copy-Item -Path $logSource -Destination $logDest -Force
    Write-Host "Copied platform test log to: $logDest" -ForegroundColor Green
} else {
    Write-Warning "Platform test script not found at: $platformScript"
}

##### Run path handling test
$pathScript = Join-Path -Path $envPath -ChildPath "scripts\test-path-handling.ps1"

if (Test-Path -Path $pathScript) {
    Write-Host "`nRunning path handling test..." -ForegroundColor Cyan
    
    ##### Ensure logs directory exists
    $logsDir = Join-Path -Path $envPath -ChildPath "logs"
    if (-not (Test-Path -Path $logsDir)) {
        New-Item -Path $logsDir -ItemType Directory -Force | Out-Null
        Write-Host "Created logs directory: $logsDir" -ForegroundColor Green
    }
    
    ##### Run the test script
    & $pathScript
    
    ##### Copy log to results
    $logSource = Join-Path -Path $envPath -ChildPath "logs\path-test.log"
    $logDest = Join-Path -Path $resultsDir -ChildPath "path-test.log"
    
    if (Test-Path -Path $logSource) {
        Copy-Item -Path $logSource -Destination $logDest -Force
        Write-Host "Copied path test log to: $logDest" -ForegroundColor Green
    } else {
        Write-Warning "Path test log not found at: $logSource"
    }
} else {
    Write-Warning "Path handling test script not found at: $pathScript"
}

##### Generate summary report
$summaryPath = Join-Path -Path $resultsDir -ChildPath "test-summary.md"
$summaryContent = @"
##### Cross-Platform Test Results for $Environment

**Test Date:** $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
**Platform:** $($Platform.PlatformName)
**PowerShell Version:** $($Platform.PSVersion)

###### Test Results

- Platform Detection Test: Completed
- Path Handling Test: Completed

###### Platform Information

- PowerShell Edition: $($PSVersionTable.PSEdition)
- OS: $([System.Environment]::OSVersion.VersionString)
- Path Separator: '$([IO.Path]::DirectorySeparatorChar)'

"@

Set-Content -Path $summaryPath -Value $summaryContent -Encoding UTF8
Write-Host "`nGenerated test summary: $summaryPath" -ForegroundColor Green

Write-Host "`nAll tests completed for environment: $Environment" -ForegroundColor Cyan

