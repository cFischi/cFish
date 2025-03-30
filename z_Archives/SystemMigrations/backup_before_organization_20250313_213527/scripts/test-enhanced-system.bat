@echo off
echo MD-JSON Sync System - Enhanced Testing Suite
echo ==========================================

REM Create test directories if they don't exist
if not exist test-data mkdir test-data
if not exist test-data\md mkdir test-data\md
if not exist test-data\json mkdir test-data\json
if not exist backups mkdir backups
if not exist .locks mkdir .locks

REM Check command line arguments
if "%1"=="" goto help
if "%1"=="help" goto help
if "%1"=="install" goto install
if "%1"=="generate" goto generate
if "%1"=="monitor" goto monitor
if "%1"=="stress" goto stress
if "%1"=="run" goto run
goto help

:help
echo.
echo Usage:
echo   test-enhanced-system.bat install      - Install required dependencies
echo   test-enhanced-system.bat generate     - Generate test files
echo   test-enhanced-system.bat monitor [N]  - Monitor sync for N minutes (default: 5)
echo   test-enhanced-system.bat stress [N] [OPS] - Run stress test for N minutes (default: 10)
echo   test-enhanced-system.bat run          - Run the enhanced MD-JSON sync system
echo   test-enhanced-system.bat help         - Show this help
goto end

:install
echo.
echo Installing required dependencies...
call npm install chokidar
call npm install
echo Dependencies installed successfully.
goto end

:generate
echo.
echo Generating test files...
node test-enhanced-sync.js generate
echo Test files generated successfully.
goto end

:monitor
echo.
set duration=5
if not "%2"=="" set duration=%2
echo Starting monitoring for %duration% minutes...
node test-enhanced-sync.js monitor %duration%
goto end

:stress
echo.
set duration=10
set ops=10
if not "%2"=="" set duration=%2
if not "%3"=="" set ops=%3
echo Running stress test for %duration% minutes with %ops% operations per minute...
start "MD-JSON Sync System" run-enhanced.bat
timeout /t 5
node test-enhanced-sync.js stress %duration% %ops%
goto end

:run
echo.
echo Starting Enhanced MD-JSON Sync System...
call run-enhanced.bat
goto end

:end
echo.
echo Testing completed. 