<#
.SYNOPSIS
    Sets up WSL with Ubuntu and installs PowerShell Core for Linux testing.

.DESCRIPTION
    This script enables Windows Subsystem for Linux (WSL 2), installs Ubuntu,
    and then installs PowerShell Core inside the WSL environment. It also
    configures the necessary components for cross-platform testing.

.NOTES
    File Name      : setup-wsl-linux.ps1
    Author         : tY FischEYe
    Prerequisite   : Windows 10 version 2004+ or Windows 11, Windows PowerShell 5.1 or later
    Created        : 2025-03-13
    Version        : 1.0
#>

#Requires -Version 5.1
#Requires -RunAsAdministrator

# Set strict mode to catch common scripting mistakes
Set-StrictMode -Version Latest

# Set error action preference to stop on errors
$ErrorActionPreference = "Stop"

##### Ubuntu installer script path
$ubuntuInstallerScript = Join-Path ${env}:TEMP "install-powershell-ubuntu.sh"

##### Check if WSL is installed and enabled
function Test-WSLEnabled {
    try {
        $wslOutput = wsl --status 2>&1
        if ($wslOutput -like "*WSL is not registered*") {
            return $false
        }
        return $true
    }
    catch {
        return $false
    }
}

##### Enable WSL and install WSL 2
function Enable-WSL {
    Write-Host "Enabling Windows Subsystem for Linux..." -ForegroundColor Yellow
    
    try {
        ##### Enable WSL feature
        dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
        
        ##### Enable Virtual Machine Platform feature
        dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
        
        Write-Host "WSL features enabled. System restart required." -ForegroundColor Green
        
        $restart = Read-Host "Do you want to restart your computer now? (Y/N)"
        if ($restart -eq "Y" -or $restart -eq "y") {
            Write-Host "Restarting computer in 10 seconds. Save your work now."
            Start-Sleep -Seconds 10
            Restart-Computer -Force
            exit
        }
        else {
            Write-Warning "WSL setup requires a system restart. Please restart your computer before continuing."
            return $false
        }
    }
    catch {
        Write-Error "Failed to enable WSL: $_"
        return $false
    }
}

##### Set WSL 2 as default
function Set-WSL2Default {
    Write-Host "Setting WSL 2 as default version..." -ForegroundColor Yellow
    
    try {
        wsl --set-default-version 2
        Write-Host "WSL 2 set as default version." -ForegroundColor Green
        return $true
    }
    catch {
        Write-Error "Failed to set WSL 2 as default: $_"
        return $false
    }
}

##### Check if Ubuntu is installed in WSL
function Test-UbuntuInstalled {
    try {
        $distros = wsl --list
        return ($distros -like "*Ubuntu*")
    }
    catch {
        return $false
    }
}

##### Install Ubuntu in WSL
function Install-Ubuntu {
    Write-Host "Installing Ubuntu in WSL..." -ForegroundColor Yellow
    
    try {
        ##### Install Ubuntu (latest LTS)
        wsl --install -d Ubuntu
        
        ##### Check if installation successful
        if (Test-UbuntuInstalled) {
            Write-Host "Ubuntu installed successfully in WSL." -ForegroundColor Green
            return $true
        }
        else {
            Write-Error "Ubuntu installation verification failed."
            return $false
        }
    }
    catch {
        Write-Error "Failed to install Ubuntu: $_"
        return $false
    }
}

##### Create PowerShell installation script for Ubuntu
function Create-PowerShellInstallScript {
    Write-Host "Creating PowerShell installation script for Ubuntu..." -ForegroundColor Yellow
    
    $scriptContent = @'
#!/bin/bash
##### PowerShell installation script for Ubuntu

echo "Installing PowerShell Core in Ubuntu WSL..."

##### Download the Microsoft repository GPG keys
wget -q https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb

##### Register the Microsoft repository GPG keys
sudo dpkg -i packages-microsoft-prod.deb

##### Update the list of products
sudo apt-get update

##### Install PowerShell
sudo apt-get install -y powershell

##### Verify installation
pwsh --version

echo "PowerShell Core installation completed!"
'@
    
    try {
        Set-Content -Path $ubuntuInstallerScript -Value $scriptContent -Force
        Write-Host "PowerShell installation script created: $ubuntuInstallerScript" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Error "Failed to create PowerShell installation script: $_"
        return $false
    }
}

##### Install PowerShell Core in Ubuntu WSL
function Install-PowerShellInUbuntu {
    Write-Host "Installing PowerShell Core in Ubuntu WSL..." -ForegroundColor Yellow
    
    try {
        ##### Make sure the script is created
        if (-not (Test-Path $ubuntuInstallerScript)) {
            Create-PowerShellInstallScript
        }
        
        ##### Copy script to WSL home directory using Get-Content and pipe
        $scriptContent = Get-Content -Path $ubuntuInstallerScript -Raw
        $scriptContent | wsl --distribution Ubuntu --exec bash -c "cat > ~/install-powershell.sh"
        
        ##### Make script executable
        wsl --distribution Ubuntu --exec chmod +x ~/install-powershell.sh
        
        ##### Run installation script
        Write-Host "Running PowerShell installation in Ubuntu WSL. This may take a few minutes..." -ForegroundColor Yellow
        wsl --distribution Ubuntu --exec ~/install-powershell.sh
        
        ##### Verify PowerShell installation
        $pwshVersion = wsl --distribution Ubuntu --exec pwsh --version
        
        if ($pwshVersion -like "*PowerShell*") {
            Write-Host "PowerShell Core installed successfully in Ubuntu WSL:" -ForegroundColor Green
            Write-Host $pwshVersion -ForegroundColor Green
            return $true
        }
        else {
            Write-Warning "PowerShell Core installation in Ubuntu WSL could not be verified."
            return $false
        }
    }
    catch {
        Write-Error "Failed to install PowerShell in Ubuntu WSL: $_"
        return $false
    }
}

##### Copy test scripts to WSL environment
function Copy-TestScriptsToWSL {
    Write-Host "Copying test scripts to WSL environment..." -ForegroundColor Yellow
    
    try {
        ##### Create test directory in WSL home
        wsl --distribution Ubuntu --exec mkdir -p ~/tydisync-tests
        
        ##### Source directory for test scripts
        $sourceTestDir = Join-Path $PSScriptRoot "..\test-cross-platform"
        
        if (Test-Path $sourceTestDir) {
            ##### Get all PowerShell scripts in test directory
            $testScripts = Get-ChildItem -Path $sourceTestDir -Filter "*.ps1" -Recurse
            
            foreach ($script in $testScripts) {
                $targetPath = "~/tydisync-tests/$($script.Name)"
                
                ##### Copy script to WSL
                Get-Content -Path $script.FullName | wsl --distribution Ubuntu --exec bash -c "cat > $targetPath"
                
                ##### Make script executable in WSL
                wsl --distribution Ubuntu --exec chmod +x $targetPath
                
                Write-Host "Copied test script: $($script.Name)" -ForegroundColor Green
            }
            
            Write-Host "All test scripts copied to WSL environment successfully." -ForegroundColor Green
            return $true
        }
        else {
            Write-Warning "Test scripts directory not found at: $sourceTestDir"
            return $false
        }
    }
    catch {
        Write-Error "Failed to copy test scripts to WSL: $_"
        return $false
    }
}

##### Run tests in WSL environment
function Run-WSLTests {
    Write-Host "Running tests in WSL environment..." -ForegroundColor Yellow
    
    try {
        $testScriptPath = Join-Path $PSScriptRoot "..\test-cross-platform\run-wsl-tests.bat"
        
        if (Test-Path $testScriptPath) {
            Write-Host "Executing test script: $testScriptPath"
            Start-Process -FilePath $testScriptPath -Wait
            Write-Host "WSL tests completed. Check the test results." -ForegroundColor Green
        }
        else {
            Write-Warning "Test script not found at: $testScriptPath"
        }
    }
    catch {
        Write-Error "Failed to run WSL tests: $_"
    }
}

##### Main execution flow
function Main {
    Write-Host "=== WSL with Ubuntu and PowerShell Core Setup Script ===" -ForegroundColor Cyan
    
    ##### Check if WSL is enabled
    if (-not (Test-WSLEnabled)) {
        Write-Host "WSL is not enabled. Enabling WSL features..."
        if (-not (Enable-WSL)) {
            Write-Host "Exiting due to WSL setup issues. Please restart your computer and run this script again."
            return
        }
    }
    
    ##### Set WSL 2 as default version
    Set-WSL2Default
    
    ##### Check if Ubuntu is installed
    if (-not (Test-UbuntuInstalled)) {
        Write-Host "Ubuntu is not installed in WSL. Installing..."
        if (-not (Install-Ubuntu)) {
            Write-Host "Exiting due to Ubuntu installation issues."
            return
        }
    }
    else {
        Write-Host "Ubuntu is already installed in WSL." -ForegroundColor Green
    }
    
    ##### Install PowerShell Core in Ubuntu
    Install-PowerShellInUbuntu
    
    ##### Copy test scripts to WSL
    Copy-TestScriptsToWSL
    
    ##### Ask to run tests
    $runTests = Read-Host "Do you want to run the WSL tests now? (Y/N)"
    if ($runTests -eq "Y" -or $runTests -eq "y") {
        Run-WSLTests
    }
    else {
        Write-Host "You can run the tests later using: .\test-cross-platform\run-wsl-tests.bat"
    }
    
    Write-Host "WSL setup completed successfully." -ForegroundColor Cyan
    Write-Host "You can now run PowerShell Core tests in Ubuntu WSL environment."
}

# Run the main function
Main 
