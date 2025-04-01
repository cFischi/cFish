@echo off
REM Script for pulling the latest changes from GitHub
REM Updated to be location-aware and work regardless of where it's called from

SETLOCAL EnableDelayedExpansion

REM Check for test mode
set "TEST_MODE=false"
if "%1"=="-test" set "TEST_MODE=true"

REM Determine the script's directory even if called from elsewhere
set "SCRIPT_DIR=%~dp0"
set "ORIGINAL_DIR=%CD%"

REM Navigate to workspace root
cd /d "%SCRIPT_DIR%\..\..\"
set "WORKSPACE_ROOT=%CD%"

echo.
echo ======================================================
echo                 CURSOR PULL OPERATION
echo              Working Directory: [%WORKSPACE_ROOT%]
if "%TEST_MODE%"=="true" echo                   [TEST MODE]
echo ======================================================
echo.

if "%TEST_MODE%"=="true" (
    echo Test mode activated. No Git operations will be performed.
    echo.
    echo Script location: %SCRIPT_DIR%
    echo Workspace root: %WORKSPACE_ROOT%
    echo Original directory: %ORIGINAL_DIR%
    echo Test successful!
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
REM Return to original directory
cd /d "%ORIGINAL_DIR%"

ENDLOCAL 