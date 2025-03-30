@echo off
echo =========================================================
echo   cFish.io Task Scheduler Configuration
echo =========================================================
echo.

:: Check if running with admin privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo This script requires administrator privileges to configure scheduled tasks.
    echo Attempting to run with elevated privileges...
    
    powershell -Command "Start-Process '%~dpnx0' -Verb RunAs"
    exit /b
)

:: Change to the script directory
cd /d "%~dp0"

:: Check if PowerShell is available
where powershell >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: PowerShell is required but not available.
    echo Please install PowerShell or check your PATH.
    pause
    exit /b 1
)

:: Run the PowerShell script
echo Starting task scheduler configuration...
echo.
powershell -ExecutionPolicy Bypass -File .\ucf-u5.1-schedule-tasks-20250314.ps1

if %errorlevel% neq 0 (
    echo.
    echo Task scheduler configuration reported issues.
    echo Check the log file for details.
    pause
    exit /b %errorlevel%
)

echo.
echo Task scheduler configuration complete.
echo.

pause 