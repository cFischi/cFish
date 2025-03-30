@echo off
SETLOCAL

echo =========================================
echo cFish.io MD-to-JSON Startup Configuration
echo =========================================

:: Check for admin privileges
NET SESSION >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo ERROR: This script requires administrative privileges.
    echo Please right-click and select "Run as administrator".
    pause
    exit /b 1
)

:: Get the full path of the VBS script
set "SCRIPT_PATH=%~dp0start-md-to-json-silent.vbs"
set "SCRIPT_PATH=%SCRIPT_PATH:\=\\%"

:: Get the current username for the task
for /f "tokens=* delims=" %%u in ('whoami') do set CURRENT_USER=%%u

echo Setting up Windows Task Scheduler task...
echo.
echo Task Name: cFish.io-MDtoJSON-Watcher
echo Script: %SCRIPT_PATH%
echo User: %CURRENT_USER%
echo.

:: Create the scheduled task
schtasks /Create /F /SC ONLOGON /TN "cFish.io-MDtoJSON-Watcher" /TR "%SCRIPT_PATH%" /RU "%CURRENT_USER%" /IT

IF %ERRORLEVEL% NEQ 0 (
    echo.
    echo ERROR: Failed to create scheduled task.
    pause
    exit /b 1
)

echo.
echo Task created successfully!
echo.
echo The MD-to-JSON watcher will now start automatically when you log in to Windows.
echo To run it immediately, execute start-md-to-json-watcher.bat or reboot your computer.
echo.
echo To remove this startup task, run: schtasks /Delete /F /TN "cFish.io-MDtoJSON-Watcher"
echo.

pause
ENDLOCAL 