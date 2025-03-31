@echo off
echo MD-JSON Sync System - Low CPU Mode Launcher
echo =============================================
echo.

:: Set Node.js memory limits - lower for less CPU usage
set NODE_OPTIONS=--max-old-space-size=1024

:: Create backups directory if it doesn't exist
if not exist "backups" mkdir backups

:: Check if chokidar is installed
node -e "try { require('chokidar'); console.log('Chokidar is installed.'); } catch (e) { console.log('ERROR: Chokidar is not installed. Installing...'); process.exit(1); }"

:: Install chokidar if not present
if %ERRORLEVEL% NEQ 0 (
    echo Installing required dependencies...
    npm install chokidar fs-extra moment
    if %ERRORLEVEL% NEQ 0 (
        echo Failed to install dependencies. Please run 'npm install chokidar fs-extra moment' manually.
        pause
        exit /b 1
    )
)

:: Define configuration file
set CONFIG_FILE=low-cpu-config.json

echo Starting MD-JSON Sync with LOW CPU settings...
echo This mode significantly reduces CPU usage but may be slower.
echo Press Ctrl+C to stop
echo.

:: Run with low CPU settings
node tydisync.js --watch --verbose --low-cpu --config=%CONFIG_FILE%

pause 