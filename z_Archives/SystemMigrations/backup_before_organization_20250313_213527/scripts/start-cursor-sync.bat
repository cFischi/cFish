@echo off
SETLOCAL EnableDelayedExpansion

echo =========================================
echo cFish.io Cursor-Aware MD-JSON Sync Starter
echo =========================================

:: Check if Node.js is installed
where node >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo Error: Node.js is not installed or not in PATH.
    echo Please install Node.js from https://nodejs.org/
    exit /b 1
)

:: Check if Cursor is running
tasklist /FI "IMAGENAME eq Cursor.exe" 2>NUL | find /I /N "Cursor.exe">NUL
if %ERRORLEVEL% neq 0 (
    echo Cursor is not currently running. The sync system will start automatically when Cursor is launched.
) else (
    echo Cursor is running. Starting synchronization system...
)

:: Change to the script's directory
cd /d "%~dp0"

:: Check for chokidar module installation
if not exist "node_modules\chokidar" (
    echo Installing required dependencies...
    npm install chokidar fs-extra
    
    if %ERRORLEVEL% neq 0 (
        echo Error: Failed to install dependencies.
        exit /b 1
    )
)

:: Start the controller in the background
start "Cursor-Aware MD-JSON Sync" /MIN cmd /c "node cursor-sync-controller.js"

echo.
echo Cursor-Aware MD-JSON synchronization service started in background.
echo A minimized command window will remain open while the service is running.
echo You can close it from the taskbar when no longer needed.
echo.

ENDLOCAL 