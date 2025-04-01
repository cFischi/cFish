@echo off
echo =========================================================
echo   tYDiSync~ Auto-Recovery Mechanism
echo =========================================================
echo.

:: Check if running with admin privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo This script works best with administrator privileges.
    echo Some recovery operations may be limited.
    echo.
    pause
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
echo Starting auto-recovery mechanism...
echo.
powershell -ExecutionPolicy Bypass -File .\auto-recovery-sync-system.ps1 %*

if %errorlevel% neq 0 (
    echo.
    echo Auto-recovery mechanism reported issues.
    echo Check the log file for details.
    pause
    exit /b %errorlevel%
)

echo.
echo Auto-recovery complete.
echo.

pause 