@echo off
echo Pulling changes from remote...

REM Save current location
pushd %~dp0
cd "C:\Users\Chris\cFish.io"

REM Get current branch name
for /f "tokens=*" %%a in ('git rev-parse --abbrev-ref HEAD') do set CURRENT_BRANCH=%%a
echo Current branch: %CURRENT_BRANCH%

REM Pull from the specific branch
git pull origin %CURRENT_BRANCH%

if %ERRORLEVEL% EQU 0 (
    echo Successfully pulled changes from remote.
) else (
    echo Error: Failed to pull changes from remote.
)

REM Return to original location
popd 