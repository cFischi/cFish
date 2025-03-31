@echo off
echo ========================================
echo Pull Request Helper
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

:: Use a simpler approach to access GitHub pull requests
echo Setting GitHub repository URL...
set GITHUB_USER=tY-FischEYe
set REPO_NAME=cFish.io
set HTTPS_URL=https://github.com/%GITHUB_USER%/%REPO_NAME%

echo Repository URL: %HTTPS_URL%
echo.

:: Generate PR URL - using a simpler format that works with private repos
set PR_URL=%HTTPS_URL%/pull/new/compare

echo ========================================
echo GitHub Pull Request Information
echo ========================================
echo.
echo Your current branch: %CURRENT_BRANCH%
echo.
echo This will open GitHub's pull request page where you can:
echo 1. Select your branch (%CURRENT_BRANCH%) as the "compare" branch
echo 2. Select "main" as the "base" branch
echo 3. Create the pull request
echo.
echo Pull Request URL:
echo %PR_URL%
echo.
echo Would you like to open this URL in your browser?
set /p OPEN_BROWSER=Open browser? (Y/N): 
if /i "%OPEN_BROWSER%"=="Y" (
    start "" "%PR_URL%"
)

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