@echo off
echo ===== Git Status Operation =====

rem Change to repository directory
cd /d "C:\Users\Chris\cFish.io"

rem Get current branch
for /f "tokens=*" %%a in ('git rev-parse --abbrev-ref HEAD') do set BRANCH=%%a
echo Current branch: %BRANCH%

rem Check if in test mode
if "%1"=="--test" (
    echo Test mode: Would show status for branch %BRANCH%.
    goto :end
)

rem Show Git status
echo Current Git status for branch %BRANCH%:
echo.
git status

echo.
echo ===== Status operation completed =====

:end 