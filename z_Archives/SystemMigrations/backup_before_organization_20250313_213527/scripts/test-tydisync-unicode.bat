@echo off
REM test-tydisync-unicode.bat
REM
REM Windows batch file wrapper for the Unicode character testing script for tYDiSync~
REM This allows the test to be run from a Windows environment
REM

setlocal enabledelayedexpansion

REM Define colors for output (PowerShell color names)
set "GREEN=Green"
set "RED=Red"
set "YELLOW=Yellow"
set "RESET=White"

REM Get the directory of this script
set "SCRIPT_DIR=%~dp0"
set "LOG_DIR=%SCRIPT_DIR%\..\logs"
set "LOG_FILE=%LOG_DIR%\unicode-test-output.log"

REM Create logs directory if it doesn't exist
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

REM Print header with color
call :print_color %YELLOW% "=================================================================="
call :print_color %YELLOW% "                   tYDiSync~ Unicode Test                         "
call :print_color %YELLOW% "=================================================================="
echo.

REM Check if Node.js is installed
where node >nul 2>nul
if %ERRORLEVEL% neq 0 (
    call :print_color %RED% "Error: Node.js is not installed or not in PATH"
    echo Please install Node.js and try again
    exit /b 1
)

REM Check if the test script exists
set "TEST_SCRIPT=%SCRIPT_DIR%\test-tydisync-unicode.js"
if not exist "%TEST_SCRIPT%" (
    call :print_color %RED% "Error: Test script not found: %TEST_SCRIPT%"
    exit /b 1
)

REM Print system information
echo System information:
echo   OS: Windows %OS%
for /f "tokens=*" %%a in ('node -v') do set "NODE_VERSION=%%a"
echo   Node: %NODE_VERSION%
echo   Date: %DATE% %TIME%
echo.

REM Run the test
call :print_color %YELLOW% "Starting Unicode character test..."
echo Test output will be logged to: %LOG_FILE%
echo.

REM Execute the test script and capture output
node "%TEST_SCRIPT%" > "%LOG_FILE%" 2>&1

REM Display the output in the console as well
type "%LOG_FILE%"

REM Check if the test was successful
if %ERRORLEVEL% equ 0 (
    echo.
    call :print_color %GREEN% "Unicode test completed successfully!"
    echo See detailed results in the logs directory.
    exit /b 0
) else (
    echo.
    call :print_color %RED% "Unicode test failed!"
    echo Check the log file for error details: %LOG_FILE%
    exit /b 1
)

REM Function to print colored text
:print_color
set "color=%~1"
set "text=%~2"
powershell write-host "%text%" -foregroundcolor %color%
exit /b 0

endlocal 