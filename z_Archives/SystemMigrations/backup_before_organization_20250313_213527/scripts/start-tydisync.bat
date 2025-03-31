@echo off
REM MD-JSON Synchronization System Launcher
REM This batch file starts the MD-JSON synchronization system in watch mode
REM with verbose logging enabled.

echo Starting MD-JSON Sync System for Cursor...
node cursor-tydisync.js --watch --verbose

REM Check if Node.js is installed
where node >nul 2>nul
if %ERRORLEVEL% neq 0 (
  echo Error: Node.js is not installed or not in PATH.
  echo Please install Node.js from https://nodejs.org/
  pause
  exit /b 1
)

REM Check if the main script exists
if not exist tydisync.js (
  echo Error: tydisync.js not found.
  echo Please make sure you're running this from the correct directory.
  pause
  exit /b 1
)

REM Create logs directory if it doesn't exist
if not exist logs mkdir logs

REM Start the synchronization system in watch mode with verbose logging
echo Starting MD-JSON sync in watch mode with verbose logging...
echo Log file: logs\tydisync.log
echo.
echo Press Ctrl+C to stop the synchronization process.
echo.

node tydisync.js --watch --verbose

REM If we get here, the process has ended
echo.
echo MD-JSON synchronization process has ended.
pause 