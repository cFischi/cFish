<#
.SYNOPSIS
    Configures test environments for cross-platform PowerShell testing.

.DESCRIPTION
    This script sets up test environments for testing PowerShell scripts across 
    different platforms: Windows PowerShell 5.1, PowerShell Core on Windows, and 
    PowerShell Core on Linux/WSL. It creates the necessary directory structure, 
    test data, and configuration files for each environment.

.PARAMETER TestDataPath
    Path where test data will be created.

.PARAMETER ConfigurePowerShell7
    Switch to install PowerShell 7 if not already installed.

.PARAMETER ConfigureWSL
    Switch to configure WSL for Linux testing.

.NOTES
    File Name      : setup-test-environments.ps1
    Author         : tY FischEYe
    Prerequisite   : PowerShell 5.1 or later
    Created        : 2025-03-13
    Version        : 1.0
    Cross-Platform : Yes (Windows PowerShell 5.1+, PowerShell Core 7+ on Windows/Linux/macOS)

.EXAMPLE
    .\setup-test-environments.ps1 -TestDataPath "test-data" -ConfigurePowerShell7 -ConfigureWSL
#>

#Requires -Version 5.1

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string]$TestDataPath = "test-cross-platform",

    [Parameter(Mandatory = $false)]
    [switch]$ConfigurePowerShell7,

    [Parameter(Mandatory = $false)]
    [switch]$ConfigureWSL
)

#-----------------------------------------------------------[Initialization]------------------------------------------------------------

##### Set strict mode to catch common scripting mistakes
Set-StrictMode -Version Latest

##### Set error action preference to stop on errors
$ErrorActionPreference = "Stop"

##### Import platform detection module (use the template until a proper module is created)
$scriptPath = $MyInvocation.MyCommand.Path
$scriptDir = Split-Path -Path $scriptPath -Parent
. (Join-Path -Path $scriptDir -ChildPath "cross-platform-template.ps1")

##### Get platform information
$Platform = Get-PlatformInfo

Write-Host "Platform: $($Platform.PlatformName)" -ForegroundColor Yellow
Write-Host "PowerShell Version: $($Platform.PSVersion)" -ForegroundColor Yellow

#-----------------------------------------------------------[Functions]---------------------------------------------------------------

function New-TestEnvironment {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$EnvName,
        
        [Parameter(Mandatory = $true)]
        [string]$BasePath
    )
    
    try {
        $envPath = Join-Path -Path $BasePath -ChildPath $EnvName
        
        ##### Create directory if it doesn't exist
        if (-not (Test-Path -Path $envPath)) {
            New-Item -Path $envPath -ItemType Directory -Force | Out-Null
            Write-Host "Created environment directory: $envPath" -ForegroundColor Green
        }
        
        ##### Create subdirectories
        $subDirs = @('data', 'logs', 'config', 'output', 'scripts')
        foreach ($dir in $subDirs) {
            $dirPath = Join-Path -Path $envPath -ChildPath $dir
            if (-not (Test-Path -Path $dirPath)) {
                New-Item -Path $dirPath -ItemType Directory -Force | Out-Null
                Write-Host "  Created subdirectory: $dir" -ForegroundColor Green
            }
        }
        
        ##### Create a test config file
        $configPath = Join-Path -Path $envPath -ChildPath "config\test-config.json"
        $configContent = @{
            environment = $EnvName
            created = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
            testDataPath = (Join-Path -Path $envPath -ChildPath "data")
            logPath = (Join-Path -Path $envPath -ChildPath "logs")
            outputPath = (Join-Path -Path $envPath -ChildPath "output")
        } | ConvertTo-Json -Depth 3
        
        Set-Content -Path $configPath -Value $configContent -Encoding UTF8
        Write-Host "  Created test configuration file" -ForegroundColor Green
        
        ##### Create a test data file
        $testDataPath = Join-Path -Path $envPath -ChildPath "data\test-data.txt"
        Set-Content -Path $testDataPath -Value "Test data for $EnvName`nCreated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -Encoding UTF8
        Write-Host "  Created test data file" -ForegroundColor Green
        
        ##### Create a platform detection test script
        $testScriptPath = Join-Path -Path $envPath -ChildPath "scripts\test-platform.ps1"
        $testScriptContent = @'
##### Platform detection test script
Write-Host "Testing platform detection..."
$PSVersionInfo = $PSVersionTable
Write-Host "PowerShell Version: $($PSVersionInfo.PSVersion)"
Write-Host "PowerShell Edition: $($PSVersionInfo.PSEdition)"

##### Check for platform variables
$platformInfo = [PSCustomObject]@{
    IsCore = $false
    IsWindows = $false
    IsLinux = $false
    IsMacOS = $false
}

##### PowerShell Core check
if ($PSVersionInfo.PSEdition -eq 'Core') {
    $platformInfo.IsCore = $true
    
    ##### Check platform variables if they exist
    if (Get-Variable -Name IsWindows -ErrorAction SilentlyContinue) {
        $platformInfo.IsWindows = $IsWindows
    }
    if (Get-Variable -Name IsLinux -ErrorAction SilentlyContinue) {
        $platformInfo.IsLinux = $IsLinux
    }
    if (Get-Variable -Name IsMacOS -ErrorAction SilentlyContinue) {
        $platformInfo.IsMacOS = $IsMacOS
    }
} else {
    ##### Windows PowerShell (assume Windows)
    $platformInfo.IsWindows = $true
}

##### Output results
Write-Host "Is PowerShell Core: $($platformInfo.IsCore)"
Write-Host "Is Windows: $($platformInfo.IsWindows)"
Write-Host "Is Linux: $($platformInfo.IsLinux)"
Write-Host "Is macOS: $($platformInfo.IsMacOS)"

##### Test environment variables
Write-Host "`nTesting environment variables..."
Write-Host "TEMP: ${env}:TEMP"
Write-Host "HOME: ${env}:HOME"
Write-Host "Path separator: $([IO.Path]::DirectorySeparatorChar)"

##### Test path handling
Write-Host "`nTesting path handling..."
$testPath = Join-Path -Path $PSScriptRoot -ChildPath "test-file.txt"
Write-Host "Test path: $testPath"
Set-Content -Path $testPath -Value "Test content" -Encoding UTF8
Write-Host "Created test file"
$testContent = Get-Content -Path $testPath -Raw
Write-Host "Test file content: $testContent"
Remove-Item -Path $testPath -Force
Write-Host "Removed test file"

##### Write results to log
$logPath = Join-Path -Path $PSScriptRoot -ChildPath "..\logs\platform-test.log"
"Platform test results:`n" | Out-File -FilePath $logPath -Encoding UTF8
"PowerShell Version: $($PSVersionInfo.PSVersion)" | Add-Content -Path $logPath -Encoding UTF8
"PowerShell Edition: $($PSVersionInfo.PSEdition)" | Add-Content -Path $logPath -Encoding UTF8
"Is PowerShell Core: $($platformInfo.IsCore)" | Add-Content -Path $logPath -Encoding UTF8
"Is Windows: $($platformInfo.IsWindows)" | Add-Content -Path $logPath -Encoding UTF8
"Is Linux: $($platformInfo.IsLinux)" | Add-Content -Path $logPath -Encoding UTF8
"Is macOS: $($platformInfo.IsMacOS)" | Add-Content -Path $logPath -Encoding UTF8
"Test run: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | Add-Content -Path $logPath -Encoding UTF8

Write-Host "`nTest completed! Results saved to $logPath"
'@
        
        Set-Content -Path $testScriptPath -Value $testScriptContent -Encoding UTF8
        Write-Host "  Created platform detection test script" -ForegroundColor Green
        
        ##### Create a path handling test script
        $pathTestScriptPath = Join-Path -Path $envPath -ChildPath "scripts\test-path-handling.ps1"
        $pathTestScriptContent = @'
##### Path handling test script
Write-Host "Testing path handling across platforms..."

##### Test 1: Using Join-Path (recommended)
$testDir = Join-Path -Path $PSScriptRoot -ChildPath "test-path-dir"
Write-Host "Test directory: $testDir"
New-Item -Path $testDir -ItemType Directory -Force | Out-Null

##### Test forward slash path
$forwardPath = $testDir.Replace('\', '/')
Write-Host "Forward slash path: $forwardPath"
$forwardWorks = Test-Path -Path $forwardPath
Write-Host "Forward slash path works: $forwardWorks"

##### Test backslash path
$backPath = $testDir.Replace('/', '\')
Write-Host "Backslash path: $backPath"
$backWorks = Test-Path -Path $backPath
Write-Host "Backslash path works: $backWorks"

##### Test with environment variables
$envPath = Join-Path -Path ${env}:TEMP -ChildPath "test-path-env"
Write-Host "Environment path: $envPath"
New-Item -Path $envPath -ItemType Directory -Force | Out-Null
Write-Host "Created environment directory"

##### Test with relative paths
$relativePath = Join-Path -Path "." -ChildPath "test-path-relative"
Write-Host "Relative path: $relativePath"
New-Item -Path $relativePath -ItemType Directory -Force | Out-Null
Write-Host "Created relative directory"

##### Test with special characters
$specialPath = Join-Path -Path $testDir -ChildPath "test with spaces and (special) characters.txt"
Write-Host "Special character path: $specialPath"
Set-Content -Path $specialPath -Value "Test content with special characters: äöüßÄÖÜ" -Encoding UTF8
Write-Host "Created special character file"

##### Test with unicode characters
$unicodePath = Join-Path -Path $testDir -ChildPath "test-unicode-你好.txt"
Write-Host "Unicode path: $unicodePath"
try {
    Set-Content -Path $unicodePath -Value "Unicode content: こんにちは" -Encoding UTF8
    Write-Host "Created unicode file" -ForegroundColor Green
} catch {
    Write-Host "Unicode path creation failed: $_" -ForegroundColor Red
}

##### Clean up
Remove-Item -Path $testDir -Recurse -Force
Write-Host "Removed test directory"

Remove-Item -Path $envPath -Recurse -Force
Write-Host "Removed environment directory"

Remove-Item -Path $relativePath -Recurse -Force
Write-Host "Removed relative directory"

##### Write results to log
$logPath = Join-Path -Path $PSScriptRoot -ChildPath "..\logs\path-test.log"
"Path handling test results:`n" | Out-File -FilePath $logPath -Encoding UTF8
"Forward slash path works: $forwardWorks" | Add-Content -Path $logPath -Encoding UTF8
"Backslash path works: $backWorks" | Add-Content -Path $logPath -Encoding UTF8
"Path separator character: $([IO.Path]::DirectorySeparatorChar)" | Add-Content -Path $logPath -Encoding UTF8
"Test run: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | Add-Content -Path $logPath -Encoding UTF8

Write-Host "`nTest completed! Results saved to $logPath"
'@
        
        Set-Content -Path $pathTestScriptPath -Value $pathTestScriptContent -Encoding UTF8
        Write-Host "  Created path handling test script" -ForegroundColor Green
        
        return $envPath
    }
    catch {
        Write-Error "Error creating test environment $EnvName`: $_"
        return $null
    }
}

function Install-PowerShell7 {
    [CmdletBinding()]
    param()
    
    try {
        ##### Check if PowerShell 7 is already installed
        $ps7Path = "${env}:ProgramFiles\PowerShell\7\pwsh.exe"
        
        if (Test-Path -Path $ps7Path) {
            Write-Host "PowerShell 7 is already installed at: $ps7Path" -ForegroundColor Green
            return $true
        }
        
        Write-Host "Installing PowerShell 7..." -ForegroundColor Yellow
        
        ##### Use the official Microsoft installation script
        $installScript = Join-Path -Path ${env}:TEMP -ChildPath "install-powershell.ps1"
        
        Invoke-WebRequest -Uri "https://aka.ms/install-powershell.ps1" -OutFile $installScript
        
        ##### Install PowerShell 7
        & $installScript -UseMSI -Quiet
        
        ##### Verify installation
        if (Test-Path -Path $ps7Path) {
            Write-Host "PowerShell 7 installation completed successfully" -ForegroundColor Green
            return $true
        }
        else {
            Write-Warning "PowerShell 7 installation might have failed. Please verify manually."
            return $false
        }
    }
    catch {
        Write-Error "Error installing PowerShell 7: $_"
        return $false
    }
}

function Setup-WSL {
    [CmdletBinding()]
    param()
    
    try {
        ##### Check if WSL is installed
        $wslCheck = wsl --status 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "WSL is already installed and configured" -ForegroundColor Green
            
            ##### Check for distributions
            $distributions = wsl --list --verbose
            Write-Host "Installed WSL distributions:" -ForegroundColor Yellow
            Write-Host $distributions
            
            return $true
        }
        
        Write-Host "Setting up WSL..." -ForegroundColor Yellow
        
        ##### Enable WSL feature
        Write-Host "Enabling Windows Subsystem for Linux feature..."
        Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
        
        ##### Enable Virtual Machine Platform feature (required for WSL 2)
        Write-Host "Enabling Virtual Machine Platform feature..."
        Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart
        
        Write-Host "WSL features have been enabled. A system restart is required." -ForegroundColor Yellow
        Write-Host "After restarting, run 'wsl --install -d Ubuntu' to install Ubuntu distribution." -ForegroundColor Yellow
        
        $restart = Read-Host "Do you want to restart now? (Y/N)"
        if ($restart -eq "Y" -or $restart -eq "y") {
            Restart-Computer -Force
        }
        
        return $true
    }
    catch {
        Write-Error "Error setting up WSL: $_"
        return $false
    }
}

function Create-RunnerScripts {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$BasePath
    )
    
    try {
        ##### Create Windows PowerShell runner
        $winPsRunnerPath = Join-Path -Path $BasePath -ChildPath "run-winps-tests.bat"
        $winPsRunnerContent = @'
@echo off
echo Running tests in Windows PowerShell 5.1...
powershell.exe -ExecutionPolicy Bypass -File "%~dp0\run-tests.ps1" -Environment "windows-powershell"
pause
'@
        Set-Content -Path $winPsRunnerPath -Value $winPsRunnerContent -Encoding ASCII
        Write-Host "Created Windows PowerShell runner script: $winPsRunnerPath" -ForegroundColor Green
        
        ##### Create PowerShell Core runner
        $ps7RunnerPath = Join-Path -Path $BasePath -ChildPath "run-ps7-tests.bat"
        $ps7RunnerContent = @'
@echo off
echo Running tests in PowerShell Core 7+...
pwsh.exe -ExecutionPolicy Bypass -File "%~dp0\run-tests.ps1" -Environment "powershell-core-windows"
pause
'@
        Set-Content -Path $ps7RunnerPath -Value $ps7RunnerContent -Encoding ASCII
        Write-Host "Created PowerShell Core runner script: $ps7RunnerPath" -ForegroundColor Green
        
        ##### Create WSL PowerShell runner
        $wslRunnerPath = Join-Path -Path $BasePath -ChildPath "run-wsl-tests.bat"
        $wslRunnerContent = @'
@echo off
echo Running tests in PowerShell Core on WSL...
wsl pwsh -ExecutionPolicy Bypass -File "%~dp0/run-tests.ps1" -Environment "powershell-core-linux"
pause
'@
        Set-Content -Path $wslRunnerPath -Value $wslRunnerContent -Encoding ASCII
        Write-Host "Created WSL PowerShell runner script: $wslRunnerPath" -ForegroundColor Green
        
        ##### Create the main test runner script
        $mainRunnerPath = Join-Path -Path $BasePath -ChildPath "run-tests.ps1"
        $mainRunnerContent = @'
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
    & $pathScript
    
    ##### Copy log to results
    $logSource = Join-Path -Path $envPath -ChildPath "logs\path-test.log"
    $logDest = Join-Path -Path $resultsDir -ChildPath "path-test.log"
    Copy-Item -Path $logSource -Destination $logDest -Force
    Write-Host "Copied path test log to: $logDest" -ForegroundColor Green
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
'@

        Set-Content -Path $mainRunnerPath -Value $mainRunnerContent -Encoding UTF8
        Write-Host "Created main test runner script: $mainRunnerPath" -ForegroundColor Green
        
        ##### Create the run-all script
        $runAllPath = Join-Path -Path $BasePath -ChildPath "run-all-tests.bat"
        $runAllContent = @'
@echo off
echo Running cross-platform tests on all available environments...

echo.
echo =========================================
echo Testing on Windows PowerShell 5.1
echo =========================================
call "%~dp0\run-winps-tests.bat"

echo.
echo =========================================
echo Testing on PowerShell Core 7+ (Windows)
echo =========================================
call "%~dp0\run-ps7-tests.bat"

echo.
echo =========================================
echo Testing on PowerShell Core in WSL (Linux)
echo =========================================
call "%~dp0\run-wsl-tests.bat"

echo.
echo All tests completed!
pause
'@
        Set-Content -Path $runAllPath -Value $runAllContent -Encoding ASCII
        Write-Host "Created run-all script: $runAllPath" -ForegroundColor Green
        
        return $true
    }
    catch {
        Write-Error "Error creating runner scripts: $_"
        return $false
    }
}

#-----------------------------------------------------------[Main Execution]----------------------------------------------------------

try {
    Write-Host "Setting up cross-platform PowerShell test environments..." -ForegroundColor Cyan
    
    ##### Ensure the base test directory exists
    if (-not (Test-Path -Path $TestDataPath)) {
        New-Item -Path $TestDataPath -ItemType Directory -Force | Out-Null
        Write-Host "Created test base directory: $TestDataPath" -ForegroundColor Green
    }
    
    ##### Create test environments
    Write-Host "`nCreating test environments..." -ForegroundColor Cyan
    
    $windowsPsEnv = New-TestEnvironment -EnvName "windows-powershell" -BasePath $TestDataPath
    $ps7WindowsEnv = New-TestEnvironment -EnvName "powershell-core-windows" -BasePath $TestDataPath
    $ps7LinuxEnv = New-TestEnvironment -EnvName "powershell-core-linux" -BasePath $TestDataPath
    
    ##### Create runner scripts
    Write-Host "`nCreating test runner scripts..." -ForegroundColor Cyan
    Create-RunnerScripts -BasePath $TestDataPath
    
    ##### Install PowerShell 7 if requested
    if ($ConfigurePowerShell7) {
        Write-Host "`nConfiguring PowerShell 7..." -ForegroundColor Cyan
        Install-PowerShell7
    }
    
    ##### Configure WSL if requested
    if ($ConfigureWSL) {
        Write-Host "`nConfiguring WSL..." -ForegroundColor Cyan
        Setup-WSL
    }
    
    Write-Host "`nTest environments setup completed!" -ForegroundColor Green
    Write-Host "`nNext steps:`n"
    Write-Host "1. Run tests on Windows PowerShell 5.1 using $TestDataPath\run-winps-tests.bat"
    Write-Host "2. Run tests on PowerShell Core 7+ using $TestDataPath\run-ps7-tests.bat"
    Write-Host "3. Run tests on WSL using $TestDataPath\run-wsl-tests.bat" 
    Write-Host "4. Alternatively, run all tests using $TestDataPath\run-all-tests.bat"
    Write-Host "5. Review test results in the *-results directories"
}
catch {
    Write-Error "Error setting up test environments: $_"
} 
