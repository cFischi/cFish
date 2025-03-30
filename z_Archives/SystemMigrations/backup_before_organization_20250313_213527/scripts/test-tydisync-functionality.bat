@echo off
echo ===== tYDiSync~ Functional Testing Script =====
echo Testing basic functionality after the file renaming project
echo.

setlocal enabledelayedexpansion

set TEST_DIR=..\tydisync-test
set MD_DIR=%TEST_DIR%\md
set JSON_DIR=%TEST_DIR%\json
set LOG_FILE=..\logs\tydisync-test-results.log
set LOG_DIR=..\logs

REM Create test and log directories if they don't exist
if not exist %TEST_DIR% mkdir %TEST_DIR%
if not exist %MD_DIR% mkdir %MD_DIR%
if not exist %JSON_DIR% mkdir %JSON_DIR%
if not exist %LOG_DIR% mkdir %LOG_DIR%

echo [%date% %time%] Starting tYDiSync~ functional tests > %LOG_FILE%

echo === Test 1: Basic Markdown to JSON Conversion ===
echo [%date% %time%] Test 1: Basic Markdown to JSON Conversion >> %LOG_FILE%

echo # Test Heading > %MD_DIR%\test1.md
echo. >> %MD_DIR%\test1.md
echo This is a test paragraph. >> %MD_DIR%\test1.md
echo. >> %MD_DIR%\test1.md
echo - List item 1 >> %MD_DIR%\test1.md
echo - List item 2 >> %MD_DIR%\test1.md

echo Running tydisync.bat for basic conversion...
call tydisync.bat --convert %MD_DIR%\test1.md --verbose
set EXIT_CODE=!ERRORLEVEL!

REM Check both possible locations for the output file
if exist %JSON_DIR%\test1.json (
    echo Test 1: PASSED - Successfully created JSON file in expected directory
    echo [%date% %time%] Test 1: PASSED - Successfully created JSON file in expected directory >> %LOG_FILE%
) else if exist %TEST_DIR%\test1.json (
    echo Test 1: PASSED - Successfully created JSON file in root test directory
    echo [%date% %time%] Test 1: PASSED - Successfully created JSON file in root test directory >> %LOG_FILE%
) else (
    echo Test 1: FAILED - JSON file not created
    echo [%date% %time%] Test 1: FAILED - JSON file not created, exit code: !EXIT_CODE! >> %LOG_FILE%
)

echo.
echo === Test 2: JSON to Markdown Conversion ===
echo [%date% %time%] Test 2: JSON to Markdown Conversion >> %LOG_FILE%

echo {"heading":"Test JSON","content":"This is a test JSON file.","items":["Item A","Item B","Item C"]} > %JSON_DIR%\test2.json

echo Running tydisync.bat for reverse conversion...
call tydisync.bat --convert %JSON_DIR%\test2.json --verbose
set EXIT_CODE=!ERRORLEVEL!

REM Check both possible locations for the output file
if exist %MD_DIR%\test2.md (
    echo Test 2: PASSED - Successfully created Markdown file in expected directory
    echo [%date% %time%] Test 2: PASSED - Successfully created Markdown file in expected directory >> %LOG_FILE%
) else if exist %TEST_DIR%\test2.md (
    echo Test 2: PASSED - Successfully created Markdown file in root test directory
    echo [%date% %time%] Test 2: PASSED - Successfully created Markdown file in root test directory >> %LOG_FILE%
) else (
    echo Test 2: FAILED - Markdown file not created
    echo [%date% %time%] Test 2: FAILED - Markdown file not created, exit code: !EXIT_CODE! >> %LOG_FILE%
)

echo.
echo === Test 3: Watch Mode Functionality ===
echo [%date% %time%] Test 3: Watch Mode Functionality >> %LOG_FILE%

echo SKIPPING Watch Mode Test - This test requires manual verification
echo [%date% %time%] SKIPPED - Watch Mode Test requires manual verification >> %LOG_FILE%
echo Test 3: SKIPPED - Watch Mode Test requires manual verification

echo.
echo === Test 4: Error Handling ===
echo [%date% %time%] Test 4: Error Handling >> %LOG_FILE%

echo Creating invalid JSON file...
echo {This is invalid JSON > %JSON_DIR%\invalid.json

echo Running tydisync.bat with invalid JSON...
call tydisync.bat --convert %JSON_DIR%\invalid.json > %TEST_DIR%\error_output.txt 2>&1
set EXIT_CODE=!ERRORLEVEL!

findstr /C:"ERROR" %TEST_DIR%\error_output.txt > nul
if !ERRORLEVEL! equ 0 (
    echo Test 4: PASSED - Error was properly reported
    echo [%date% %time%] Test 4: PASSED - Error was properly reported >> %LOG_FILE%
) else (
    echo Test 4: FAILED - Error was not properly reported
    echo [%date% %time%] Test 4: FAILED - Error was not properly reported >> %LOG_FILE%
)

echo.
echo === Test 5: Backup System ===
echo [%date% %time%] Test 5: Backup System >> %LOG_FILE%

REM Prepare a test file for backup testing
copy %MD_DIR%\test1.md %MD_DIR%\backup_test.md > nul

echo Running tydisync.bat with backup option...
call tydisync.bat --convert %MD_DIR%\backup_test.md --verbose
set EXIT_CODE=!ERRORLEVEL!

REM Check if a backup was created in the backup directory
dir /b /s ..\backups\*backup_test* > %TEST_DIR%\backup_files.txt 2>&1
findstr /C:"backup_test" %TEST_DIR%\backup_files.txt > nul

if !ERRORLEVEL! equ 0 (
    echo Test 5: PASSED - Backup file was created
    echo [%date% %time%] Test 5: PASSED - Backup file was created >> %LOG_FILE%
) else (
    echo Test 5: FAILED - Backup file was not created
    echo [%date% %time%] Test 5: FAILED - Backup file was not created >> %LOG_FILE%
)

echo.
echo === Test Results Summary ===

set PASS_COUNT=0
set SKIP_COUNT=0
findstr /C:"PASSED" %LOG_FILE% > %TEST_DIR%\pass_count.txt
for /f %%A in ('type %TEST_DIR%\pass_count.txt ^| find /c /v ""') do set PASS_COUNT=%%A
findstr /C:"SKIPPED" %LOG_FILE% > %TEST_DIR%\skip_count.txt
for /f %%A in ('type %TEST_DIR%\skip_count.txt ^| find /c /v ""') do set SKIP_COUNT=%%A

set /a TOTAL_TESTS=4
echo Passed %PASS_COUNT% out of %TOTAL_TESTS% tests, with %SKIP_COUNT% skipped.

if %PASS_COUNT% equ %TOTAL_TESTS% (
    echo All tests PASSED!
    echo [%date% %time%] All tests PASSED! >> %LOG_FILE%
) else (
    echo Some tests FAILED. Please review the log file for details: %LOG_FILE%
    echo [%date% %time%] Some tests FAILED. Please review the log file for details. >> %LOG_FILE%
)

echo.
echo Testing completed. Full results available in %LOG_FILE% 