@echo off
echo ===== Git Pull Operation =====

rem Change to repository directory
cd /d "C:\Users\Chris\cFish.io"

rem Get current branch
for /f "tokens=*" %%a in ('git rev-parse --abbrev-ref HEAD') do set BRANCH=%%a
echo Current branch: %BRANCH%

rem Check if in test mode
if "%1"=="--test" (
    echo Test mode: Would pull changes from remote for branch %BRANCH%.
    goto :end
)

rem Pull from remote
echo Pulling from remote branch %BRANCH%...
git pull origin %BRANCH%

if %ERRORLEVEL% EQU 0 (
    echo Successfully pulled changes from remote.
) else (
    echo Error: Failed to pull changes from remote.
    echo Possible solutions:
    echo - If there are merge conflicts, resolve them before continuing
    echo - If there are local changes, commit them first with Ctrl+Alt+K
    echo - For connection issues, verify your internet connection
)

:end
echo ===== Pull operation completed ===== 