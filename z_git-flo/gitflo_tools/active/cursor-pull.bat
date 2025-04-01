@echo off
setlocal enabledelayedexpansion

REM Get the directory of the script
set "SCRIPT_DIR=%~dp0"
set "WORKSPACE_ROOT=%SCRIPT_DIR%..\..\"

REM Store current directory
set "ORIGINAL_DIR=%CD%"

REM Change to workspace root
pushd "%WORKSPACE_ROOT%"

REM Configure Git to handle line endings
git config core.autocrlf true >nul 2>&1

REM Check if we're in a Git repository
git status >nul 2>&1
if errorlevel 1 (
    echo Error: Not in a Git repository or Git is not installed.
    goto :cleanup
)

REM Check if test mode is enabled
if "%1"=="-test" (
    echo Test mode: Would execute the following commands:
    echo git pull origin HEAD --allow-unrelated-histories
    goto :cleanup
)

REM Check if we have unfinished merge
if exist ".git\MERGE_HEAD" (
    echo Error: Unfinished merge detected. Please resolve conflicts first.
    goto :cleanup
)

echo Pulling changes from remote...
git pull origin HEAD --allow-unrelated-histories
if errorlevel 1 (
    echo Error: Failed to pull changes from remote.
    echo Try resolving conflicts manually or use: git merge --abort
) else (
    echo Successfully pulled changes from remote.
)

:cleanup
REM Return to original directory
popd

endlocal 