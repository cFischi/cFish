@echo off
title MD-JSON Sync Startup Removal
echo Removing MD-JSON synchronization from Windows startup...

:: Ensure the script is running as administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo This script requires administrator privileges.
    echo Please right-click and select "Run as administrator".
    echo.
    pause
    exit /b 1
)

:: Remove the scheduled task
echo Removing scheduled task "MD-JSON Sync"...
schtasks /delete /tn "MD-JSON Sync" /f

if %errorLevel% equ 0 (
    echo.
    echo Successfully removed MD-JSON synchronization from Windows startup.
) else (
    echo.
    echo Failed to remove the scheduled task. It may not exist or there was an error.
    echo Error code: %errorLevel%
)

echo.
echo Press any key to exit...
pause >nul 