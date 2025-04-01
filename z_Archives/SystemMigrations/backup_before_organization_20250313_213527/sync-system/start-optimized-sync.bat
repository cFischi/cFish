@echo off
setlocal enabledelayedexpansion

echo.
echo =========================================================
echo   tYDiSync~ - Optimized Synchronization System Launcher
echo =========================================================
echo.

:: Detect working directory
set "CURRENT_DIR=%~dp0"
set "ROOT_DIR=%CURRENT_DIR%..\"
set "ACTUAL_SYNC_PATH=%ROOT_DIR%cFish.io\U5-Data\Synchronization\tydisync\start-optimized-sync.bat"

:: Check if the actual sync file exists
if not exist "%ACTUAL_SYNC_PATH%" (
    echo ERROR: Sync system not found at expected location.
    echo Expected: %ACTUAL_SYNC_PATH%
    echo.
    echo This is likely due to a path configuration issue.
    echo Please verify directory structure and try again.
    pause
    exit /b 1
)

echo Redirecting to sync system...
echo.

:: Launch the actual sync system
call "%ACTUAL_SYNC_PATH%" %*

:: Preserve the exit code
set EXIT_CODE=%ERRORLEVEL%

if %EXIT_CODE% neq 0 (
    echo.
    echo WARNING: Sync system exited with error code %EXIT_CODE%
    echo Check logs for details.
    echo.
    echo You may want to run the auto-recovery tool:
    echo tools\auto-recovery-sync-system.bat
    pause
)

exit /b %EXIT_CODE% 