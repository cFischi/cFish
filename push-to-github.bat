@echo off
echo cFish.io - Push to GitHub Helper
echo ================================

REM Get current branch
for /f "tokens=*" %%a in ('git rev-parse --abbrev-ref HEAD') do set BRANCH=%%a

echo Current branch: %BRANCH%
echo.

REM Check for changes
git status
echo.

REM Ask for commit message
set /p COMMIT_MESSAGE=Enter commit message (or press Enter to cancel): 

if "%COMMIT_MESSAGE%"=="" (
    echo Operation cancelled.
    exit /b
)

REM Add, commit and push
echo.
echo Adding all changes...
git add .

echo.
echo Committing changes with message: "%COMMIT_MESSAGE%"
git commit -m "%COMMIT_MESSAGE%"

echo.
echo Pushing to GitHub...
git push origin %BRANCH%

echo.
echo Done! Remember to run 'git pull origin %BRANCH%' on your other computer.
echo.

pause 