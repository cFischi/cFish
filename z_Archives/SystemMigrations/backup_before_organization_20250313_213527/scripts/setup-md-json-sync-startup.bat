@echo off
title MD-JSON Sync Startup Setup
echo Setting up MD-JSON synchronization to start automatically with Windows...

:: Ensure the script is running as administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo This script requires administrator privileges.
    echo Please right-click and select "Run as administrator".
    echo.
    pause
    exit /b 1
)

:: Get the current directory
set SCRIPT_DIR=%~dp0
set SCRIPT_DIR=%SCRIPT_DIR:~0,-1%

:: Create a scheduled task that runs at login
echo Creating scheduled task "MD-JSON Sync"...
schtasks /create /tn "MD-JSON Sync" /tr "\"%SCRIPT_DIR%\start-tydisync-silent.vbs\"" /sc onlogon /ru "%USERNAME%" /rl highest /f

if %errorLevel% equ 0 (
    echo.
    echo Successfully set up MD-JSON synchronization to start automatically with Windows.
    echo The synchronization will start silently when you log in.
) else (
    echo.
    echo Failed to create the scheduled task. Error code: %errorLevel%
)

echo.
echo Press any key to exit...
pause >nul 