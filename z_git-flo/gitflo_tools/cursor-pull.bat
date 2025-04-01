@echo off
setlocal enabledelayedexpansion

REM Keyboard Shortcut Configuration
REM Ctrl+Alt+L for Pull
REM Ctrl+Alt+K for Push

REM Get the script's directory and workspace root
set "SCRIPT_DIR=%~dp0"
set "WORKSPACE_ROOT=%SCRIPT_DIR%..\..\"
cd /d "%WORKSPACE_ROOT%"

REM Verify environment
if not exist ".git" (
    echo Error: Not in a Git repository root
    echo Current directory: %CD%
    exit /b 1
)

REM Get current branch
for /f "tokens=*" %%a in ('git rev-parse --abbrev-ref HEAD') do set BRANCH=%%a

echo ======================================================
echo                 CURSOR PULL OPERATION
echo              Working Directory: [%CD%]
echo                 Branch: [%BRANCH%]
if "%1"=="-test" echo                   [TEST MODE]
echo ======================================================
echo.

REM Check for test mode
if "%1"=="-test" (
    echo Test mode activated. No Git operations will be performed.
    echo.
    echo Script location: %SCRIPT_DIR%
    echo Workspace root: %CD%
    goto :end
)

echo Fetching latest changes from GitHub...
git fetch

echo.
echo Pulling changes from the current branch...
git pull

echo.
echo ======================================================
echo Success! You now have the latest changes from GitHub.
echo ======================================================
echo.

:end
endlocal 