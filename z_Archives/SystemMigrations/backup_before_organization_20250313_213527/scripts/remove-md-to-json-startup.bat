@echo off
SETLOCAL

echo =========================================
echo Remove cFish.io MD-to-JSON Startup Task
echo =========================================

:: Check for admin privileges
NET SESSION >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo ERROR: This script requires administrative privileges.
    echo Please right-click and select "Run as administrator".
    pause
    exit /b 1
)

echo Removing Windows Task Scheduler task...
echo.

:: Delete the scheduled task
schtasks /Delete /F /TN "cFish.io-MDtoJSON-Watcher"

IF %ERRORLEVEL% NEQ 0 (
    echo.
    echo ERROR: Failed to remove scheduled task.
    echo The task may not exist or you may not have sufficient permissions.
    pause
    exit /b 1
)

echo.
echo Task removed successfully!
echo.
echo The MD-to-JSON watcher will no longer start automatically when you log in to Windows.
echo.
echo To set it up again, run: setup-md-to-json-startup.bat
echo.

pause
ENDLOCAL 