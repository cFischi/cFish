@echo off
echo cFish.io - Pull from GitHub Helper
echo ==================================

REM Get current branch
for /f "tokens=*" %%a in ('git rev-parse --abbrev-ref HEAD') do set BRANCH=%%a

echo Current branch: %BRANCH%
echo.

REM Check for local changes first
git status
echo.

set /p CONTINUE=Continue with pull? (Y/N): 

if /i not "%CONTINUE%"=="Y" (
    echo Operation cancelled.
    exit /b
)

echo.
echo Pulling latest changes from GitHub...
git pull origin %BRANCH%

echo.
echo Done! You now have the latest changes from GitHub.
echo.

pause 