# Cross-Platform Compatibility Test for tYDiSync~ PowerShell Scripts
# Purpose: Provides instructions and runner for testing scripts across platforms
# Ticket: CFIO-2025-03
# Created: 2025-03-12
# Updated: 2025-03-13

<#
.SYNOPSIS
    Instructions and runner for cross-platform testing of tYDiSync~ PowerShell scripts.

.DESCRIPTION
    This script provides detailed instructions on how to test tYDiSync~ PowerShell scripts
    across different platforms and environments. It includes commands for running tests
    on Windows PowerShell 5.1, PowerShell 7+ on Windows, PowerShell in WSL, and PowerShell on macOS.

.EXAMPLE
    .\test-cross-platform-compatibility.ps1 -RunTests

.PARAMETER RunTests
    If specified, runs the cross-platform tests on the current platform.
#>

param(
    [switch]$RunTests
)

function Show-TestInstructions {
    Write-Host "=================================================================" -ForegroundColor Cyan
    Write-Host "      tYDiSync~ Cross-Platform Compatibility Testing Guide       " -ForegroundColor Cyan
    Write-Host "=================================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Follow these steps to test tYDiSync~ scripts across different platforms:" -ForegroundColor Yellow
    Write-Host ""
    
    Write-Host "1. Windows PowerShell 5.1" -ForegroundColor Green
    Write-Host "   Open Windows PowerShell and run:" -ForegroundColor Gray
    Write-Host "   powershell -ExecutionPolicy Bypass -File scripts\test-cross-platform.ps1" -ForegroundColor White
    Write-Host ""
    
    Write-Host "2. PowerShell 7+ on Windows" -ForegroundColor Green
    Write-Host "   Open PowerShell 7+ and run:" -ForegroundColor Gray
    Write-Host "   pwsh -ExecutionPolicy Bypass -File scripts\test-cross-platform.ps1" -ForegroundColor White
    Write-Host ""
    
    Write-Host "3. PowerShell in Windows Subsystem for Linux (WSL)" -ForegroundColor Green
    Write-Host "   Open WSL and run:" -ForegroundColor Gray
    Write-Host "   pwsh -ExecutionPolicy Bypass -File /mnt/c/Users/[username]/cFish.io/scripts/test-cross-platform.ps1" -ForegroundColor White
    Write-Host "   (Adjust the path based on your WSL mount point)" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "4. PowerShell on macOS (if available)" -ForegroundColor Green
    Write-Host "   Open Terminal on macOS and run:" -ForegroundColor Gray
    Write-Host "   pwsh -ExecutionPolicy Bypass -File /path/to/cFish.io/scripts/test-cross-platform.ps1" -ForegroundColor White
    Write-Host "   (Adjust the path based on your macOS file location)" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "Recording Results:" -ForegroundColor Yellow
    Write-Host "- After running tests in each environment, document the results in memory.md" -ForegroundColor Gray
    Write-Host "- Include any platform-specific issues encountered" -ForegroundColor Gray
    Write-Host "- Note any compatibility fixes needed" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "To run the tests on this platform now, use:" -ForegroundColor Yellow
    Write-Host ".\test-cross-platform-compatibility.ps1 -RunTests" -ForegroundColor White
    Write-Host ""
    Write-Host "=================================================================" -ForegroundColor Cyan
}

function Run-AllTests {
    ##### Detect which platform we're on and display info
    Write-Host "Running cross-platform tests on current environment:" -ForegroundColor Yellow
    Write-Host "PowerShell Version: $($PSVersionTable.PSVersion)" -ForegroundColor White
    Write-Host "OS: $($PSVersionTable.OS)" -ForegroundColor White
    Write-Host "Platform: $([System.Environment]::OSVersion.Platform)" -ForegroundColor White
    Write-Host "=================================================================" -ForegroundColor Cyan
    
    ##### Run the test script
    try {
        & "$PSScriptRoot\test-cross-platform.ps1"
    }
    catch {
        Write-Host "Error running tests: $_" -ForegroundColor Red
    }
}

# Main execution logic
if ($RunTests) {
    Run-AllTests
} else {
    Show-TestInstructions
}

