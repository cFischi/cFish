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
if %ERRORLEVEL% neq 0 (
    echo Error adding files. Please check your changes and try again.
    pause
    exit /b 1
)

echo.
echo Committing changes with message: "%COMMIT_MESSAGE%"
git commit -n -m "%COMMIT_MESSAGE%"
if %ERRORLEVEL% neq 0 (
    echo Error committing changes. Please check the error message above.
    pause
    exit /b 1
)

echo.
echo Pushing to GitHub...
git push origin %BRANCH%
if %ERRORLEVEL% neq 0 (
    echo Error pushing to GitHub. Check your internet connection and GitHub access.
    pause
    exit /b 1
)

echo.
echo Success! Changes pushed to GitHub.
echo Remember to run 'git pull origin %BRANCH%' on your other computer.
echo.

pause 