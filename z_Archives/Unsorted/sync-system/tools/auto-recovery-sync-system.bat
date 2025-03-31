@echo off
setlocal enabledelayedexpansion

echo.
echo =========================================================
echo   tYDiSync~ - Auto-Recovery Tool
echo =========================================================
echo.

:: Detect working directory
set "CURRENT_DIR=%~dp0"
set "ROOT_DIR=%CURRENT_DIR%..\..\"
set "RECOVERY_SCRIPT=%ROOT_DIR%tools\auto-recovery-sync-system.ps1"

:: Check if the recovery script exists
if not exist "%RECOVERY_SCRIPT%" (
    echo ERROR: Recovery script not found at expected location.
    echo Expected: %RECOVERY_SCRIPT%
    echo.
    echo This is likely due to a path configuration issue.
    echo Please verify directory structure and try again.
    pause
    exit /b 1
)

echo Running auto-recovery script...
echo.

:: Run the PowerShell script with elevated privileges
powershell.exe -ExecutionPolicy Bypass -File "%RECOVERY_SCRIPT%"

:: Preserve the exit code
set EXIT_CODE=%ERRORLEVEL%

if %EXIT_CODE% neq 0 (
    echo.
    echo WARNING: Recovery process completed with error code %EXIT_CODE%
    echo Check logs for details.
    pause
)

exit /b %EXIT_CODE% 