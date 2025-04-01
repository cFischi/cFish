@echo off
setlocal enabledelayedexpansion

REM Keyboard Shortcut Configuration
REM Ctrl+Alt+K for Push
REM Ctrl+Alt+L for Pull

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
echo                 CURSOR PUSH OPERATION
echo              Working Directory: [%CD%]
echo                 Branch: [%BRANCH%]
echo ======================================================
echo.

REM Check for changes
git status
echo.

REM Use provided commit message or generate one
if "%~1"=="" (
    set "COMMIT_MESSAGE=Auto-commit from cursor-push.bat %date% %time%"
) else (
    set "COMMIT_MESSAGE=%~1"
)
echo Using commit message: "%COMMIT_MESSAGE%"

REM Add, commit and push
echo.
echo Adding all changes...
git add .
if %ERRORLEVEL% neq 0 (
    echo Error adding files. Please check your changes and try again.
    exit /b 1
)

echo.
echo Committing changes with message: "%COMMIT_MESSAGE%"
git commit -n -m "%COMMIT_MESSAGE%"
if %ERRORLEVEL% neq 0 (
    echo Error committing changes. Please check the error message above.
    exit /b 1
)

echo.
echo Pushing to GitHub...
git push origin %BRANCH%
if %ERRORLEVEL% neq 0 (
    echo Error pushing to GitHub. Check your internet connection and GitHub access.
    exit /b 1
)

echo.
echo ======================================================
echo Success! Changes pushed to GitHub.
echo Remember to run 'cursor-pull.bat' on your other computer.
echo ======================================================
echo.
echo [Script executed via Ctrl+Alt+K shortcut] 