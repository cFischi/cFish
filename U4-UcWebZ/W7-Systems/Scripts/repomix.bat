@echo off
setlocal enabledelayedexpansion

:: RepomiX - Repository Management and Integration Tool Wrapper
:: Version: 1.0.0
:: Created: 03-28-2025

:: Get the directory of this batch file
set "SCRIPT_DIR=%~dp0"

:: Set the path to the PowerShell script
set "PS_SCRIPT=%SCRIPT_DIR%ucf-u7.3-repomix-20250328.ps1"

:: Check if PowerShell script exists
if not exist "%PS_SCRIPT%" (
    echo Error: RepomiX PowerShell script not found at: %PS_SCRIPT%
    exit /b 1
)

:: Forward all arguments to PowerShell script
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%PS_SCRIPT%" %*

:: Check PowerShell exit code
if errorlevel 1 (
    echo Error: RepomiX operation failed. Check the log file for details.
    exit /b 1
)

exit /b 0 