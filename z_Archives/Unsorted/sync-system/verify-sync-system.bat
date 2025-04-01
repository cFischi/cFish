@echo off
setlocal enabledelayedexpansion

echo.
echo =========================================================
echo   tYDiSync~ - System Verification Tool
echo =========================================================
echo.

:: Detect working directory
set "CURRENT_DIR=%~dp0"
set "ROOT_DIR=%CURRENT_DIR%..\"
set "VERIFY_SCRIPT=%ROOT_DIR%tools\ucf-u5.1-verify-sync-system-20250314.ps1"

:: Check if the verification script exists
if not exist "%VERIFY_SCRIPT%" (
    echo ERROR: Verification script not found at expected location.
    echo Expected: %VERIFY_SCRIPT%
    echo.
    echo This is likely due to a path configuration issue.
    echo Please verify directory structure and try again.
    pause
    exit /b 1
)

echo Running verification script...
echo.

:: Run the PowerShell script
powershell.exe -ExecutionPolicy Bypass -File "%VERIFY_SCRIPT%"

:: Preserve the exit code
set EXIT_CODE=%ERRORLEVEL%

if %EXIT_CODE% neq 0 (
    echo.
    echo WARNING: Verification completed with error code %EXIT_CODE%
    echo Check logs for details.
    pause
)

exit /b %EXIT_CODE% 