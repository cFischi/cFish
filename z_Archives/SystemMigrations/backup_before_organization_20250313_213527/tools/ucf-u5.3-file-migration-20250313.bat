@echo off
REM ucf-u5.3-file-migration-20250313.bat
REM This script migrates files to the standardized directory structure
REM Following UcFish digital organization standards
REM Department: U5 - Data Management
REM Function: 3 - Data Migration

echo ===== cFish.io File Migration - %date% %time% =====
echo.

REM Configuration
set SIMULATE=true
set LOG_FILE=logs\migration-%date:~10,4%%date:~4,2%%date:~7,2%.log

REM Create log directory if it doesn't exist
if not exist logs mkdir logs

REM Log function
call :log "Starting file migration process (Simulation: %SIMULATE%)"

REM Process migrations
call :log "Starting migration of example files..."

REM Example 1
set SOURCE=sync-system\tydisync-debug.log
set DEST=logs\sync-system\tyf-u5.1-tydisync-debug-20250313.log
call :process_file "%SOURCE%" "%DEST%" "Sync system debug log"

REM Example 2
set SOURCE=tydisync-powershell-cross-platform-summary.md
set DEST=docs\procedures\tyf-u2.4-powershell-cross-platform-summary-20250313.md
call :process_file "%SOURCE%" "%DEST%" "PowerShell cross-platform documentation"

REM Example 3
set SOURCE=start-assessment-phase.bat
set DEST=tools\ucf-u5.4-start-assessment-phase-20250313.bat
call :process_file "%SOURCE%" "%DEST%" "Assessment phase startup script"

REM Migration complete
call :log "===== Migration Complete ====="

REM Run health check if not in simulation mode
if "%SIMULATE%"=="false" (
    call :log "Running health check..."
    call .\tools\daily-health-check.ps1
)

echo.
echo Migration process completed. See %LOG_FILE% for details.
goto :eof

REM ===== Functions =====

:log
echo [%date% %time%] %~1
echo [%date% %time%] %~1 >> %LOG_FILE%
goto :eof

:process_file
set SRC=%~1
set DST=%~2
set DESC=%~3

call :log "Processing: %DESC% (%SRC%)"

REM Check if source exists
if not exist %SRC% (
    call :log "ERROR: Source file not found: %SRC%"
    goto :eof
)

REM Create destination directory if needed
for %%F in ("%DST%") do set DST_DIR=%%~dpF
if not exist %DST_DIR% (
    if "%SIMULATE%"=="true" (
        call :log "SIMULATION: Would create directory: %DST_DIR%"
    ) else (
        mkdir %DST_DIR%
        call :log "Created directory: %DST_DIR%"
    )
)

REM Check if destination already exists
if exist %DST% (
    call :log "WARNING: Destination already exists, will be overwritten: %DST%"
)

REM Copy the file
if "%SIMULATE%"=="true" (
    call :log "SIMULATION: Would copy %SRC% to %DST%"
) else (
    copy /Y %SRC% %DST% > nul
    if exist %DST% (
        call :log "SUCCESS: Copied %SRC% to %DST%"
    ) else (
        call :log "ERROR: Failed to copy %SRC% to %DST%"
    )
)

goto :eof 