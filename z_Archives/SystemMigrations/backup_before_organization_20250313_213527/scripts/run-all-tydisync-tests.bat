@echo off
echo ===== tYDiSync~ Complete Test Suite =====
echo Running all tYDiSync~ tests...
echo.

setlocal enabledelayedexpansion

set LOG_DIR=..\logs
set SUMMARY_LOG=%LOG_DIR%\tydisync-all-tests-summary.log

REM Create log directory if it doesn't exist
if not exist %LOG_DIR% mkdir %LOG_DIR%

echo [%date% %time%] Running Complete tYDiSync~ Test Suite > %SUMMARY_LOG%

REM Initialize counters
set TOTAL_TESTS=0
set PASSED_TESTS=0
set FAILED_TESTS=0
set SKIPPED_TESTS=0

echo ===== 1. Basic Functionality Tests =====
echo [%date% %time%] Running Basic Functionality Tests >> %SUMMARY_LOG%
call test-tydisync-functionality.bat
set EXIT_CODE=!ERRORLEVEL!

REM Count based on basic test results
if !EXIT_CODE! equ 0 (
    set /a PASSED_TESTS+=4
    set /a TOTAL_TESTS+=4
    set /a SKIPPED_TESTS+=1
    echo [%date% %time%] Basic Functionality Tests: PASSED >> %SUMMARY_LOG%
) else (
    for /f %%a in ('findstr /c:"PASSED" ..\logs\tydisync-test-results.log ^| find /c /v ""') do set /a PASSED_TESTS+=%%a
    for /f %%a in ('findstr /c:"FAILED" ..\logs\tydisync-test-results.log ^| find /c /v ""') do set /a FAILED_TESTS+=%%a
    for /f %%a in ('findstr /c:"SKIPPED" ..\logs\tydisync-test-results.log ^| find /c /v ""') do set /a SKIPPED_TESTS+=%%a
    set /a TOTAL_TESTS+=5
    echo [%date% %time%] Basic Functionality Tests: FAILED >> %SUMMARY_LOG%
)

echo.
echo ===== 2. Watch Mode Tests =====
echo [%date% %time%] Running Watch Mode Tests >> %SUMMARY_LOG%
call test-tydisync-watch-mode.bat
set EXIT_CODE=!ERRORLEVEL!

REM Count based on watch mode test results
if !EXIT_CODE! equ 0 (
    set /a PASSED_TESTS+=2
    set /a TOTAL_TESTS+=2
    echo [%date% %time%] Watch Mode Tests: PASSED >> %SUMMARY_LOG%
) else (
    set /a FAILED_TESTS+=2
    set /a TOTAL_TESTS+=2
    echo [%date% %time%] Watch Mode Tests: FAILED >> %SUMMARY_LOG%
)

echo.
echo ===== 3. Edge Case Tests =====
echo [%date% %time%] Running Edge Case Tests >> %SUMMARY_LOG%
call test-tydisync-edge-cases.bat
set EXIT_CODE=!ERRORLEVEL!

REM Count based on edge case test results
if !EXIT_CODE! equ 0 (
    set /a PASSED_TESTS+=5
    set /a TOTAL_TESTS+=5
    echo [%date% %time%] Edge Case Tests: PASSED >> %SUMMARY_LOG%
) else (
    for /f %%a in ('findstr /c:"PASSED" ..\logs\tydisync-edge-test.log ^| find /c /v ""') do set /a PASSED_EDGE=%%a
    for /f %%a in ('findstr /c:"FAILED" ..\logs\tydisync-edge-test.log ^| find /c /v ""') do set /a FAILED_EDGE=%%a
    
    REM Count is approximate since we're parsing logs - adjust if needed
    if defined PASSED_EDGE set /a PASSED_TESTS+=PASSED_EDGE
    if defined FAILED_EDGE set /a FAILED_TESTS+=FAILED_EDGE
    set /a TOTAL_TESTS+=5
    
    echo [%date% %time%] Edge Case Tests: FAILED >> %SUMMARY_LOG%
)

echo.
echo ===== Test Summary =====
echo [%date% %time%] Test Summary >> %SUMMARY_LOG%
echo Total Tests: %TOTAL_TESTS%
echo Passed: %PASSED_TESTS%
echo Failed: %FAILED_TESTS%
echo Skipped: %SKIPPED_TESTS%

echo Total Tests: %TOTAL_TESTS% >> %SUMMARY_LOG%
echo Passed: %PASSED_TESTS% >> %SUMMARY_LOG%
echo Failed: %FAILED_TESTS% >> %SUMMARY_LOG%
echo Skipped: %SKIPPED_TESTS% >> %SUMMARY_LOG%

set /a PASS_PERCENTAGE=PASSED_TESTS*100/TOTAL_TESTS
echo Pass Rate: %PASS_PERCENTAGE%%%
echo Pass Rate: %PASS_PERCENTAGE%%% >> %SUMMARY_LOG%

if %FAILED_TESTS% equ 0 (
    echo.
    echo ALL TESTS PASSED!
    echo [%date% %time%] ALL TESTS PASSED! >> %SUMMARY_LOG%
    
    REM Create success indicator file
    echo %date% %time% > ..\tydisync-test\tests-passed.txt
    exit /b 0
) else (
    echo.
    echo SOME TESTS FAILED. Please review the logs for details.
    echo [%date% %time%] SOME TESTS FAILED. >> %SUMMARY_LOG%
    
    REM Create failure indicator file
    echo %date% %time% > ..\tydisync-test\tests-failed.txt
    exit /b 1
) 