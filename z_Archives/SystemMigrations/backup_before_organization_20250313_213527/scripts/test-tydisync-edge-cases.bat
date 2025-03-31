@echo off
echo ===== tYDiSync~ Edge Case Testing =====
echo Running tests for edge conditions...
echo.

setlocal enabledelayedexpansion

set LOG_DIR=..\logs
set LOG_FILE=%LOG_DIR%\tydisync-edge-test-summary.log

REM Create log directory if it doesn't exist
if not exist %LOG_DIR% mkdir %LOG_DIR%

echo [%date% %time%] Running tYDiSync~ Edge Case Tests > %LOG_FILE%

REM Check if Node.js is available
where node >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo Error: Node.js is not installed or not in PATH.
    echo Please install Node.js from https://nodejs.org/
    echo [%date% %time%] Error: Node.js not found >> %LOG_FILE%
    exit /b 1
)

REM Run the edge case test script
echo Running edge case tests...
node test-tydisync-edge-cases.js
set EXIT_CODE=!ERRORLEVEL!

REM Check the result
if !EXIT_CODE! equ 0 (
    echo.
    echo Edge Case Tests: PASSED
    echo [%date% %time%] Edge Case Tests: PASSED >> %LOG_FILE%
) else (
    echo.
    echo Edge Case Tests: FAILED
    echo [%date% %time%] Edge Case Tests: FAILED (Code: !EXIT_CODE!) >> %LOG_FILE%
)

echo.
echo Test results have been logged to %LOG_FILE%
echo Detailed logs available in ..\logs\tydisync-edge-test.log

exit /b !EXIT_CODE! 