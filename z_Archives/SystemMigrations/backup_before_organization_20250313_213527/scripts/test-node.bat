@echo off
echo Checking for Node.js installation...
node -v
if %ERRORLEVEL% NEQ 0 (
  echo Node.js is not installed or not in your PATH. Please install Node.js from https://nodejs.org/
) else (
  echo Node.js is installed and working correctly.
)
echo.
echo Press any key to close this window...
pause > nul 