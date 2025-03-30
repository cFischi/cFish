@echo off
setlocal enabledelayedexpansion

echo.
echo =========================================================
echo   tYDiSync~ - Optimized Synchronization System Launcher
echo =========================================================
echo.

:: Check for Node.js installation
where node >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo ERROR: Node.js is not installed or not in PATH.
    echo Please install Node.js from https://nodejs.org/
    pause
    exit /b 1
)

:: Set memory optimization parameters
set NODE_OPTIONS=--max-old-space-size=4096 --expose-gc

:: Change to the script directory
cd /d "%~dp0"

:: Check for required dependencies
echo Checking dependencies...
if not exist node_modules\chokidar (
    echo Installing required dependencies...
    npm install chokidar fs-extra path glob events
    if %ERRORLEVEL% neq 0 (
        echo ERROR: Failed to install dependencies.
        pause
        exit /b 1
    )
)

:: Ensure backups directory exists
if not exist ..\backups mkdir ..\backups

:: Ensure state directory exists
if not exist state mkdir state

:: Start the optimized sync system
echo Starting tYDiSync~ with optimized memory settings...
echo (Node.js heap size: 4GB with garbage collection enabled)
echo.
echo Press Ctrl+C to stop the synchronization process.
echo.

node %NODE_OPTIONS% start-optimized-sync.js %*

if %ERRORLEVEL% neq 0 (
    echo.
    echo tYDiSync~ exited with error code %ERRORLEVEL%
    echo Check log files for details.
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo tYDiSync~ stopped successfully.
echo.

endlocal 