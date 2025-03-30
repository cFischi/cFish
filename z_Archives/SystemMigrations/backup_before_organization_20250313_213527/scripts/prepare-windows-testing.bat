@echo off
REM prepare-windows-testing.bat
REM
REM Script to prepare and execute Windows testing for tYDiSync~
REM This script:
REM 1. Sets up the testing environment
REM 2. Runs all tests in the correct order
REM 3. Generates test reports
REM

setlocal enabledelayedexpansion

REM Define colors for output (PowerShell color names)
set "GREEN=Green"
set "RED=Red"
set "YELLOW=Yellow"
set "BLUE=Cyan"
set "RESET=White"

REM Get the directory of this script
set "SCRIPT_DIR=%~dp0"
set "LOG_DIR=%SCRIPT_DIR%\..\logs\windows-testing"
for /f "tokens=1-5 delims=/ " %%a in ('echo %date%') do set "DATE_STAMP=%%c-%%b-%%a"
for /f "tokens=1-3 delims=:." %%a in ('echo %time: =0%') do set "TIME_STAMP=%%a-%%b-%%c"
set "TIMESTAMP=%DATE_STAMP%_%TIME_STAMP%"
set "LOG_FILE=%LOG_DIR%\windows-testing-%TIMESTAMP%.log"

REM Create header
call :print_color %YELLOW% "=================================================================="
call :print_color %YELLOW% "                tYDiSync~ Windows Testing Suite                   "
call :print_color %YELLOW% "=================================================================="
echo.

REM Create logs directory if it doesn't exist
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

REM Initialize log file
echo tYDiSync~ Windows Testing - %TIMESTAMP% > "%LOG_FILE%"
echo ===================================== >> "%LOG_FILE%"
echo. >> "%LOG_FILE%"

REM Function to log messages
:log
set "message=%~1"
echo %message%
echo %message% >> "%LOG_FILE%"
exit /b 0

REM Step 1: Verify system requirements
call :print_color %BLUE% "Step 1: Verifying system requirements..."
call :log ""

REM Check for Node.js
where node >nul 2>nul
if %ERRORLEVEL% neq 0 (
    call :print_color %RED% "  Error: Node.js is not installed or not in PATH"
    call :log "  Error: Node.js is not installed or not in PATH"
    call :log "  Windows testing cannot proceed without Node.js"
    exit /b 1
) else (
    for /f "tokens=*" %%a in ('node -v') do set "NODE_VERSION=%%a"
    call :print_color %GREEN% "  Node.js is installed: %NODE_VERSION%"
    call :log "  Node.js is installed: %NODE_VERSION%"
)

REM Check for PowerShell
where powershell >nul 2>nul
if %ERRORLEVEL% neq 0 (
    call :print_color %RED% "  Error: PowerShell is not available"
    call :log "  Error: PowerShell is not available"
    call :log "  Some colorized output may not display correctly"
) else (
    call :print_color %GREEN% "  PowerShell is available"
    call :log "  PowerShell is available"
)

REM Verify Windows environment
if not defined OS (
    call :print_color %YELLOW% "  Warning: OS environment variable not defined"
    call :log "  Warning: OS environment variable not defined"
    call :log "  This script is intended for Windows testing"
) else (
    call :print_color %GREEN% "  Running on Windows: %OS%"
    call :log "  Running on Windows: %OS%"
)

call :log ""

REM Step 2: Run tests in sequence
call :print_color %BLUE% "Step 2: Running tests..."
call :log ""

REM Track test results
set "TOTAL_TESTS=0"
set "PASSED_TESTS=0"

REM Function to run a test and report status
:run_test
set "test_script=%~1"
set "test_name=%~2"

call :print_color %YELLOW% "Running %test_name% test..."
call :log "Running %test_name% test..."

REM Execute test
call "%test_script%"

if %ERRORLEVEL% equ 0 (
    call :print_color %GREEN% "  %test_name% test completed successfully"
    call :log "  %test_name% test completed successfully"
    set /a PASSED_TESTS+=1
    set "TEST_RESULT_%TOTAL_TESTS%=PASS"
) else (
    call :print_color %RED% "  %test_name% test failed"
    call :log "  %test_name% test failed"
    set "TEST_RESULT_%TOTAL_TESTS%=FAIL"
)

set /a TOTAL_TESTS+=1
set "TEST_NAME_%TOTAL_TESTS%=%test_name%"
call :log ""
exit /b 0

REM Run basic functionality test
call :run_test "%SCRIPT_DIR%\test-tydisync-functionality.bat" "Basic functionality"

REM Run watch mode test
call :run_test "%SCRIPT_DIR%\test-tydisync-watch-mode.bat" "Watch mode"

REM Run edge cases test
call :run_test "%SCRIPT_DIR%\test-tydisync-edge-cases.bat" "Edge cases"

REM Run Unicode test
call :run_test "%SCRIPT_DIR%\test-tydisync-unicode.bat" "Unicode handling"

REM Run path edge cases test
call :run_test "%SCRIPT_DIR%\test-tydisync-path-edge-cases.bat" "Path edge cases"

REM Calculate success rate
set /a SUCCESS_RATE=(%PASSED_TESTS% * 100) / %TOTAL_TESTS%

REM Final summary
call :print_color %BLUE% "Testing Summary:"
call :log "Testing Summary:"
call :log "  Total tests:   %TOTAL_TESTS%"
call :log "  Passed tests:  %PASSED_TESTS%"
call :log "  Failed tests:  %TOTAL_TESTS% - %PASSED_TESTS%"
call :log "  Success rate:  %SUCCESS_RATE%%%"
call :log ""

if %PASSED_TESTS% equ %TOTAL_TESTS% (
    call :print_color %GREEN% "All tests passed successfully!"
    call :log "All tests passed successfully!"
) else (
    call :print_color %RED% "Some tests failed. Check individual test logs for details."
    call :log "Some tests failed. Check individual test logs for details."
)

call :log ""
call :log "Detailed logs available at: %LOG_FILE%"

REM Create summary file with platform-specific information
set "SUMMARY_FILE=%LOG_DIR%\windows-testing-summary-%TIMESTAMP%.md"

echo # tYDiSync~ Windows Testing Summary > "%SUMMARY_FILE%"
echo. >> "%SUMMARY_FILE%"
echo **Test Date:** %DATE% %TIME% >> "%SUMMARY_FILE%"
echo. >> "%SUMMARY_FILE%"
echo ## System Information >> "%SUMMARY_FILE%"
echo - **OS:** Windows %OS% >> "%SUMMARY_FILE%"
for /f "tokens=2 delims==" %%a in ('wmic os get caption /value ^| find "="') do echo - **Version:** %%a >> "%SUMMARY_FILE%"
echo - **Node Version:** %NODE_VERSION% >> "%SUMMARY_FILE%"
for /f "tokens=2 delims==" %%a in ('wmic volume where drivetype^=3 get filesystem /value ^| find "FileSystem"') do echo - **File System:** %%a >> "%SUMMARY_FILE%"
echo. >> "%SUMMARY_FILE%"
echo ## Test Results >> "%SUMMARY_FILE%"
echo - **Total Tests:** %TOTAL_TESTS% >> "%SUMMARY_FILE%"
echo - **Passed Tests:** %PASSED_TESTS% >> "%SUMMARY_FILE%"
echo - **Failed Tests:** %TOTAL_TESTS% - %PASSED_TESTS% >> "%SUMMARY_FILE%"
echo - **Success Rate:** %SUCCESS_RATE%%% >> "%SUMMARY_FILE%"
echo. >> "%SUMMARY_FILE%"
echo ## Individual Test Results >> "%SUMMARY_FILE%"

for /l %%i in (1,1,%TOTAL_TESTS%) do (
    if "!TEST_RESULT_%%i!"=="PASS" (
        echo %%i. **!TEST_NAME_%%i!:** ✅ Passed >> "%SUMMARY_FILE%"
    ) else (
        echo %%i. **!TEST_NAME_%%i!:** ❌ Failed >> "%SUMMARY_FILE%"
    )
)

echo. >> "%SUMMARY_FILE%"
echo ## Log Locations >> "%SUMMARY_FILE%"
echo - Main log: `%LOG_FILE%` >> "%SUMMARY_FILE%"
echo - Individual test logs are available in the `..\logs\` directory. >> "%SUMMARY_FILE%"
echo. >> "%SUMMARY_FILE%"
echo _Generated: %DATE% %TIME%_ >> "%SUMMARY_FILE%"

call :log "Summary report created at: %SUMMARY_FILE%"
call :log ""
call :log "Windows testing completed."

REM Exit with success if all tests passed, failure otherwise
if %PASSED_TESTS% equ %TOTAL_TESTS% (
    exit /b 0
) else (
    exit /b 1
)

REM Function to print colored text
:print_color
set "color=%~1"
set "text=%~2"
powershell write-host "%text%" -foregroundcolor %color%
exit /b 0

endlocal 