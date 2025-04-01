@echo off
echo ===== tYDiSync~ Watch Mode Testing =====
echo Running automated tests for watch mode functionality...
echo.

setlocal enabledelayedexpansion

set LOG_DIR=..\logs
set LOG_FILE=%LOG_DIR%\tydisync-watch-test.log

REM Create log directory if it doesn't exist
if not exist %LOG_DIR% mkdir %LOG_DIR%

echo [%date% %time%] Running tYDiSync~ Watch Mode Test > %LOG_FILE%

REM Check if Node.js is available
where node >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo Error: Node.js is not installed or not in PATH.
    echo Please install Node.js from https://nodejs.org/
    echo [%date% %time%] Error: Node.js not found >> %LOG_FILE%
    exit /b 1
)

REM Run the watch mode test script
echo Running watch mode test script...
node test-tydisync-watch-mode.js
set EXIT_CODE=!ERRORLEVEL!

REM Check the result
if !EXIT_CODE! equ 0 (
    echo.
    echo Watch Mode Test: PASSED
    echo [%date% %time%] Watch Mode Test: PASSED >> %LOG_FILE%
) else (
    echo.
    echo Watch Mode Test: FAILED
    echo [%date% %time%] Watch Mode Test: FAILED (Code: !EXIT_CODE!) >> %LOG_FILE%
)

echo.
echo Test results have been logged to %LOG_FILE%
echo See detailed output in ..\tydisync-test\watch_output.txt

exit /b !EXIT_CODE! 