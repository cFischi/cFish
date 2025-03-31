@echo off
echo ========================================
echo GitHub Push Helper
echo ========================================
echo.

:: Set the repository path
set REPO_PATH=C:\Users\Chris\cFish.io

:: Change to repository directory
echo Changing to repository directory: %REPO_PATH%
cd /d %REPO_PATH%
if %ERRORLEVEL% neq 0 (
    echo Error: Could not change to repository directory.
    goto :error
)
echo.

:: Get current branch
echo Getting current branch information...
for /f "tokens=*" %%a in ('git rev-parse --abbrev-ref HEAD') do set CURRENT_BRANCH=%%a
if %ERRORLEVEL% neq 0 (
    echo Error: Could not determine current branch.
    goto :error
)
echo Current branch: %CURRENT_BRANCH%
echo.

:: Confirm push
echo About to push branch [%CURRENT_BRANCH%] to GitHub.
set /p CONFIRM=Continue? (Y/N): 
if /i not "%CONFIRM%"=="Y" goto :cancel

:: Push to GitHub
echo.
echo Pushing to GitHub...
git push -u origin %CURRENT_BRANCH%
if %ERRORLEVEL% neq 0 (
    echo Error: Failed to push to GitHub.
    goto :error
)

:: Success
echo.
echo ========================================
echo Success! Branch [%CURRENT_BRANCH%] pushed to GitHub.
echo.
echo Next steps:
echo 1. Create a pull request on GitHub.com
echo 2. Merge the pull request into main
echo 3. Deploy from WordPress.com dashboard
echo ========================================
goto :end

:cancel
echo.
echo Operation cancelled by user.
goto :end

:error
echo.
echo ========================================
echo An error occurred. Please check the messages above.
echo ========================================

:end
echo.
echo Press any key to exit...
pause > nul 