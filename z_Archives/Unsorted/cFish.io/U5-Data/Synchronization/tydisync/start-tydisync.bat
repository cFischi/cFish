@echo off
REM =========================================================
REM   tYDiSync - Synchronization System Launcher
REM   Version: 0.5.5
REM   Date: 2025-03-14
REM =========================================================
REM   This file serves as the main entry point for the tYDiSync system
REM   It redirects to the actual implementation file for better maintainability
REM =========================================================

echo.
echo =========================================================
echo   tYDiSync - Synchronization System Launcher
echo =========================================================
echo.

REM Get the directory of this batch file
set "SCRIPT_DIR=%~dp0"
cd "%SCRIPT_DIR%"

REM Check if the target script exists
if not exist "%SCRIPT_DIR%start-optimized-sync.bat" (
    echo ERROR: Implementation file not found.
    echo Expected: %SCRIPT_DIR%start-optimized-sync.bat
    echo.
    echo Please run the auto-recovery script to fix this issue.
    exit /b 1
)

REM Launch the actual implementation
echo Launching synchronization system...
echo.
call "%SCRIPT_DIR%start-optimized-sync.bat" %*

REM Return the exit code from the implementation
exit /b %ERRORLEVEL% 