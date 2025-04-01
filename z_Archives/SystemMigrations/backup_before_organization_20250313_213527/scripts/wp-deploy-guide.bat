@echo off
echo ========================================
echo WordPress.com Deployment Guide
echo ========================================
echo.

echo This guide will help you deploy your changes to WordPress.com
echo after merging your pull request on GitHub.
echo.

echo STEP 1: Ensure your pull request has been merged to main
echo ----------------------------------------
echo Before proceeding, make sure your pull request has been
echo successfully merged into the main branch on GitHub.
echo.
echo Press any key to continue...
pause > nul
cls

echo ========================================
echo WordPress.com Deployment Guide
echo ========================================
echo.

echo STEP 2: Access WordPress.com Dashboard
echo ----------------------------------------
echo 1. Log in to your WordPress.com account
echo 2. Navigate to your site dashboard
echo.
echo Press any key to continue...
pause > nul
cls

echo ========================================
echo WordPress.com Deployment Guide
echo ========================================
echo.

echo STEP 3: Trigger GitHub Deployment
echo ----------------------------------------
echo 1. In your WordPress.com dashboard:
echo    - Go to Jetpack → Settings
echo    - Click on "GitHub Deployments"
echo    - Click "Deploy Now" to manually trigger a deployment
echo.
echo Would you like to open WordPress.com now?
set /p OPEN_BROWSER=Open browser? (Y/N): 
if /i "%OPEN_BROWSER%"=="Y" (
    start "" "https://wordpress.com/sites"
)
echo.
echo Press any key to continue...
pause > nul
cls

echo ========================================
echo WordPress.com Deployment Guide
echo ========================================
echo.

echo STEP 4: Verify Deployment
echo ----------------------------------------
echo 1. Monitor the deployment in the GitHub Deployments section
echo 2. Once complete, visit your site to verify the changes
echo 3. Check that:
echo    - Your child theme is active
echo    - The footer displays correctly
echo    - All styling is applied as expected
echo.
echo Press any key to continue...
pause > nul
cls

echo ========================================
echo WordPress.com Deployment Guide
echo ========================================
echo.

echo STEP 5: Update Local Environment
echo ----------------------------------------
echo After successful deployment, switch back to main branch locally:
echo.
echo   git checkout main
echo   git pull origin main
echo.
echo This ensures your local main branch is up to date with the remote.
echo.
echo Press any key to exit...
pause > nul 