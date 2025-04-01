@echo off
REM =========================================================
REM   File Naming Convention Checker
REM   Version: 1.0.0
REM   Date: 2025-03-14
REM =========================================================

echo.
echo =========================================================
echo   cFish.io File Naming Convention Checker
echo   Following UcFish digital organization standards
echo =========================================================
echo.

REM Get the directory of this batch file
set "SCRIPT_DIR=%~dp0"
cd "%SCRIPT_DIR%\.."

REM Check if PowerShell is available
where powershell >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ERROR: PowerShell is not available in your system.
    echo Please install PowerShell to use this tool.
    goto :EOF
)

echo Running file naming convention check...
echo.

REM Parse command line arguments
set FIX_MODE=0
if "%1"=="-fix" (
    set FIX_MODE=1
    echo Fix mode enabled. Non-compliant files will be automatically renamed.
    echo.
)

REM Run the script
if %FIX_MODE%==1 (
    powershell -ExecutionPolicy Bypass -File "%SCRIPT_DIR%ucf-u5.3-file-naming-check-20250314.ps1" -FixMode $true
) else (
    powershell -ExecutionPolicy Bypass -File "%SCRIPT_DIR%ucf-u5.3-file-naming-check-20250314.ps1"
)

echo.
echo File naming convention check completed.
echo See logs directory for detailed report.
echo.
echo To automatically rename files, run this script with the -fix parameter:
echo ucf-u5.3-check-file-naming-20250314.bat -fix
echo.

pause 