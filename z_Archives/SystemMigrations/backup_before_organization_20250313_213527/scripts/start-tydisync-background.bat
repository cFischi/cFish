@echo off
REM MD-JSON Synchronization System Background Launcher
REM This batch file starts the MD-JSON synchronization system in watch mode
REM as a background process with no visible window.

echo Starting MD-JSON Synchronization System in background...

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

REM Start the synchronization system in background
echo Starting MD-JSON sync in background mode...
echo Log file: logs\tydisync.log
echo.

REM Use start with /b to run in background and wscript to hide the window
start /b wscript.exe "%~dp0invisible.vbs" "%~dp0tydisync.js" "--watch"

echo MD-JSON synchronization process has been started in the background.
echo To stop it, use Task Manager to end the Node.js process.
echo.
timeout /t 5 