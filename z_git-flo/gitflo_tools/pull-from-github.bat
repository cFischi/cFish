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
echo Fetching latest changes from GitHub...
git fetch origin %BRANCH%
if %ERRORLEVEL% neq 0 (
    echo Error fetching from GitHub. Check your internet connection and GitHub access.
    pause
    exit /b 1
)

echo.
echo Pulling latest changes from GitHub...
git pull origin %BRANCH%
if %ERRORLEVEL% neq 0 (
    echo Error pulling changes. There might be conflicts that need resolution.
    pause
    exit /b 1
)

echo.
echo Success! You now have the latest changes from GitHub.
echo.

pause 