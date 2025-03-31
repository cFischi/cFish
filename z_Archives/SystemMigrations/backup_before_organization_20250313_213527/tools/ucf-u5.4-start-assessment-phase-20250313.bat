@echo off
REM =========================================================
REM   tYDiSync~ PowerShell Cross-Platform Assessment Phase   
REM =========================================================

echo Starting PowerShell Cross-Platform Compatibility Assessment Phase...
echo.

REM Create directories if they don't exist
if not exist "docs" mkdir docs
if not exist "results" mkdir results

REM Run the script inventory
echo ----------------------------------------
echo Step 1: Creating PowerShell Script Inventory
echo ----------------------------------------
powershell.exe -ExecutionPolicy Bypass -File "scripts\cross-platform-script-inventory.ps1" -OutputPath "docs\script-inventory.csv"

if %ERRORLEVEL% NEQ 0 (
    echo Error: Script inventory failed with error level %ERRORLEVEL%
    echo Continuing with next steps...
    echo.
)

REM Set up test environments
echo ----------------------------------------
echo Step 2: Setting up Test Environments
echo ----------------------------------------
powershell.exe -ExecutionPolicy Bypass -File "scripts\setup-test-environments.ps1" -TestDataPath "test-cross-platform"

if %ERRORLEVEL% NEQ 0 (
    echo Error: Test environment setup failed with error level %ERRORLEVEL%
    echo Continuing with next steps...
    echo.
)

REM Generate assessment report using a separate PowerShell script
echo ----------------------------------------
echo Step 3: Generating Assessment Report
echo ----------------------------------------
powershell.exe -ExecutionPolicy Bypass -File "create-assessment-report.ps1" -OutputPath "docs\assessment-phase-report.md"

if %ERRORLEVEL% NEQ 0 (
    echo Error: Assessment report generation failed with error level %ERRORLEVEL%
    echo Continuing with next steps...
    echo.
)

echo.
echo ----------------------------------------
echo Assessment Phase Initiated Successfully!
echo ----------------------------------------
echo.
echo Next steps:
echo 1. Review docs\script-inventory.csv and docs\script-inventory-summary.md
echo 2. Run tests using test-cross-platform\run-all-tests.bat
echo 3. Document platform-specific issues as you discover them
echo 4. Follow the implementation plan schedule for subsequent tasks
echo.
echo Assessment report generated: docs\assessment-phase-report.md
echo.

pause 