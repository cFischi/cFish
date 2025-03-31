@echo off
echo Starting MD-JSON Sync with optimized memory settings...

REM Check if Node.js is installed
where node >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Node.js is not installed or not in the PATH. Please install Node.js.
    exit /b 1
)

REM Check if chokidar is installed, install if missing
call npm list chokidar >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Chokidar dependency is missing, installing...
    call npm install chokidar --save
    if %ERRORLEVEL% NEQ 0 (
        echo Failed to install chokidar. Please check your internet connection.
        exit /b 1
    )
)

REM Set environment variables for garbage collection
set NODE_OPTIONS=--max-old-space-size=2048 --expose-gc

REM Run the sync script with memory optimization flags
echo Running MD-JSON Sync with memory limit of 2GB and manual garbage collection...
node --expose-gc --max-old-space-size=2048 tydisync.js --watch --verbose --low-cpu-mode

REM If the process crashed due to memory issues, restart with lower memory settings
if %ERRORLEVEL% EQU 137 (
    echo Memory limit exceeded. Restarting with reduced memory settings...
    node --expose-gc --max-old-space-size=1024 tydisync.js --watch --verbose --low-cpu-mode
)

echo MD-JSON Sync process has completed or was manually terminated. 