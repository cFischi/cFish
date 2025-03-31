@echo off
REM =========================================================
REM   tYDiSync - Synchronization System Launcher
REM   Version: 0.5.5
REM   Date: 2025-03-14
REM =========================================================

echo.
echo =========================================================
echo   tYDiSync - Synchronization System Launcher
echo =========================================================
echo.

REM Get the directory of this batch file
set "SCRIPT_DIR=%~dp0"
cd "%SCRIPT_DIR%"

REM Run the PowerShell script with bypass execution policy
powershell -ExecutionPolicy Bypass -File "%SCRIPT_DIR%launch-sync-system.ps1"

REM Check the exit code
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ERROR: Failed to launch sync system.
    echo Please check the logs for more information.
    echo Log location: %SCRIPT_DIR%logs\sync-launcher-*.log
    echo.
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo Sync system launched successfully.
echo.

exit /b 0 