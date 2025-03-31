@echo off
echo Starting Enhanced MD-JSON Sync System...

REM Check if Node.js is installed
where node >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Node.js is not installed or not in the PATH. Please install Node.js.
    exit /b 1
)

REM Check for required dependencies
echo Checking dependencies...
call npm list chokidar >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Installing chokidar dependency...
    call npm install chokidar --save
)

REM Set environment variables for garbage collection
set NODE_OPTIONS=--max-old-space-size=2048 --expose-gc

REM Create lock directory if it doesn't exist
if not exist .locks mkdir .locks

REM Create backup directory if it doesn't exist
if not exist backups mkdir backups

echo Starting MD-JSON Sync with enhanced features:
echo - Memory management with automatic garbage collection
echo - Improved lock management with stale lock detection
echo - JSON validation and automatic repair
echo - Low CPU mode for reduced resource usage

REM Run the enhanced sync script with memory optimization flags
node --expose-gc --max-old-space-size=2048 tydisync-enhanced.js

REM If the process crashed due to memory issues, restart with lower memory settings
if %ERRORLEVEL% EQU 137 (
    echo Memory limit exceeded. Restarting with reduced memory settings...
    set NODE_OPTIONS=--max-old-space-size=1024 --expose-gc
    node --expose-gc --max-old-space-size=1024 tydisync-enhanced.js
)

echo MD-JSON Sync process has completed or was manually terminated. 