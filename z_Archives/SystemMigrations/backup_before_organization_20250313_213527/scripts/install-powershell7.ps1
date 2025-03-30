<#
.SYNOPSIS
    Installs PowerShell 7 on Windows systems.

.DESCRIPTION
    This script downloads and installs the latest stable version of PowerShell 7
    on Windows systems. It checks for existing installations, downloads the
    installer if needed, and runs the installation with recommended parameters.

.NOTES
    File Name      : install-powershell7.ps1
    Author         : tY FischEYe
    Prerequisite   : Windows PowerShell 5.1 or later
    Created        : 2025-03-13
    Version        : 1.0
#>

#Requires -Version 5.1
#Requires -RunAsAdministrator

# Set strict mode to catch common scripting mistakes
Set-StrictMode -Version Latest

# Set error action preference to stop on errors
$ErrorActionPreference = "Stop"

##### Output directory for the installer
$downloadDir = Join-Path ${env}:TEMP "PS7Install"
$installerPath = Join-Path $downloadDir "PowerShell-7-win-x64.msi"

##### Ensure download directory exists
if (-not (Test-Path $downloadDir)) {
    New-Item -Path $downloadDir -ItemType Directory -Force | Out-Null
    Write-Host "Created temporary directory: $downloadDir"
}

##### Check if PowerShell 7 is already installed
function Test-PowerShell7Installed {
    $ps7Path = "${env}:ProgramFiles\PowerShell\7\pwsh.exe"
    
    if (Test-Path $ps7Path) {
        try {
            $version = & $ps7Path -Command '$PSVersionTable.PSVersion.ToString()'
            Write-Host "PowerShell 7 is already installed (Version: $version)"
            return $true
        }
        catch {
            Write-Warning "PowerShell 7 path exists but unable to determine version."
            return $false
        }
    }
    return $false
}

##### Download PowerShell 7 installer
function Download-PowerShell7 {
    Write-Host "Downloading PowerShell 7 installer..."
    
    ##### Using the aka.ms link that redirects to the latest stable version
    $downloadUrl = "https://aka.ms/powershell-release?tag=stable"
    
    try {
        ##### Use TLS 1.2 for security
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        
        ##### Download the file
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($downloadUrl, $installerPath)
        
        Write-Host "PowerShell 7 installer downloaded to: $installerPath"
        return $true
    }
    catch {
        Write-Error "Failed to download PowerShell 7 installer: $_"
        return $false
    }
}

##### Install PowerShell 7
function Install-PowerShell7 {
    Write-Host "Installing PowerShell 7..."
    
    try {
        ##### Install with recommended parameters
        $arguments = @(
            "/package", $installerPath,
            "/quiet",
            "ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1",
            "ADD_FILE_CONTEXT_MENU_RUNPOWERSHELL=1",
            "ENABLE_PSREMOTING=1",
            "REGISTER_MANIFEST=1",
            "USE_MU=1",
            "ENABLE_MU=1"
        )
        
        Start-Process -FilePath "msiexec.exe" -ArgumentList $arguments -Wait -NoNewWindow
        
        ##### Verify installation
        if (Test-PowerShell7Installed) {
            Write-Host "PowerShell 7 installation completed successfully!" -ForegroundColor Green
            
            ##### Get the exact version
            $ps7Path = "${env}:ProgramFiles\PowerShell\7\pwsh.exe"
            $version = & $ps7Path -Command '$PSVersionTable.PSVersion.ToString()'
            Write-Host "Installed PowerShell version: $version" -ForegroundColor Green
            
            ##### Add to PATH if it's not already there
            $path = [Environment]::GetEnvironmentVariable("PATH", "Machine")
            $ps7Dir = "${env}:ProgramFiles\PowerShell\7"
            if ($path -notlike "*$ps7Dir*") {
                [Environment]::SetEnvironmentVariable("PATH", "$path;$ps7Dir", "Machine")
                Write-Host "Added PowerShell 7 directory to system PATH." -ForegroundColor Green
            }
            
            return $true
        }
        else {
            Write-Error "PowerShell 7 installation verification failed."
            return $false
        }
    }
    catch {
        Write-Error "Failed to install PowerShell 7: $_"
        return $false
    }
}

##### Run PowerShell 7 tests
function Run-PowerShell7Tests {
    Write-Host "Running PowerShell 7 tests..." -ForegroundColor Yellow
    
    try {
        $testScriptPath = Join-Path $PSScriptRoot "..\test-cross-platform\run-ps7-tests.bat"
        
        if (Test-Path $testScriptPath) {
            Write-Host "Executing test script: $testScriptPath"
            Start-Process -FilePath $testScriptPath -Wait
            Write-Host "PowerShell 7 tests completed. Check the test results." -ForegroundColor Green
        }
        else {
            Write-Warning "Test script not found at: $testScriptPath"
        }
    }
    catch {
        Write-Error "Failed to run PowerShell 7 tests: $_"
    }
}

##### Main execution flow
function Main {
    Write-Host "=== PowerShell 7 Installation Script ===" -ForegroundColor Cyan
    
    ##### Check if already installed
    if (-not (Test-PowerShell7Installed)) {
        ##### Download installer
        if (Download-PowerShell7) {
            ##### Install PowerShell 7
            if (Install-PowerShell7) {
                Write-Host "PowerShell 7 installation successful." -ForegroundColor Green
                
                ##### Ask to run tests
                $runTests = Read-Host "Do you want to run the PowerShell 7 tests now? (Y/N)"
                if ($runTests -eq "Y" -or $runTests -eq "y") {
                    Run-PowerShell7Tests
                }
                else {
                    Write-Host "You can run the tests later using: .\test-cross-platform\run-ps7-tests.bat"
                }
            }
        }
    }
    else {
        Write-Host "PowerShell 7 is already installed." -ForegroundColor Green
        
        ##### Ask to run tests
        $runTests = Read-Host "Do you want to run the PowerShell 7 tests now? (Y/N)"
        if ($runTests -eq "Y" -or $runTests -eq "y") {
            Run-PowerShell7Tests
        }
        else {
            Write-Host "You can run the tests later using: .\test-cross-platform\run-ps7-tests.bat"
        }
    }
    
    Write-Host "Script completed." -ForegroundColor Cyan
}

# Run the main function
Main 
