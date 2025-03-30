@echo off
echo cFish.io - Cursor Push (Parameter-based)
echo =======================================

REM Check if commit message was provided
if "%~1"=="" (
    echo Error: No commit message provided.
    echo Usage: cursor-push.bat "Your commit message here"
    exit /b 1
)

REM Get current branch
for /f "tokens=*" %%a in ('git rev-parse --abbrev-ref HEAD') do set BRANCH=%%a

echo Current branch: %BRANCH%
echo.

REM Check for changes
git status
echo.

REM Use provided commit message
set COMMIT_MESSAGE=%~1
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
echo Success! Changes pushed to GitHub.
echo Remember to run 'cursor-pull.bat' on your other computer.
echo. 