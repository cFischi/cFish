@echo off
setlocal enabledelayedexpansion

echo =========================================
echo cFish.io MD-JSON Two-Way Sync (Safe Mode)
echo =========================================
echo.

:: Check for existing lock file
if exist .tydisync.lock (
    echo CAUTION: Lock file (.tydisync.lock) exists!
    echo This may indicate that another sync process is already running.
    echo.
    
    :: Check lock file age
    for /f "tokens=1,2" %%a in ('dir /a /tc .tydisync.lock ^| findstr /v "Directory" ^| findstr "[0-9]"') do (
        set "lockdate=%%a"
        set "locktime=%%b"
    )
    
    echo Lock file created: !lockdate! !locktime!
    echo.
    
    choice /C YN /M "Do you want to forcibly remove the lock file and continue"
    if errorlevel 2 (
        echo Operation canceled by user.
        exit /b 1
    ) else (
        echo Removing lock file...
        del /f .tydisync.lock
    )
)

:: Create backup of critical files before running sync
echo Creating backups of critical files...
if exist memory.md (
    echo - Backing up memory.md
    copy /y memory.md memory.md.bak.%date:~-4,4%%date:~-7,2%%date:~-10,2%.%time:~0,2%%time:~3,2%%time:~6,2% > nul
)

:: Check for other sync processes
for /f "tokens=1" %%p in ('tasklist /fi "imagename eq node.exe" ^| findstr /i "node.exe"') do (
    echo WARNING: Node.js process is already running. This could lead to conflicts.
    echo.
    
    choice /C YN /M "Do you want to continue anyway"
    if errorlevel 2 (
        echo Operation canceled by user.
        exit /b 1
    )
    
    goto proceed
)

:proceed
echo.
echo Starting MD-JSON sync with enhanced safety...
echo.

:: Parse command line arguments
set WATCH_MODE=
set VERBOSE_MODE=
set PREFER_MODE=

if "%~1"=="" goto :no_args
:parse_args
if "%~1"=="--watch" set WATCH_MODE=--watch
if "%~1"=="-w" set WATCH_MODE=--watch
if "%~1"=="--verbose" set VERBOSE_MODE=--verbose
if "%~1"=="-v" set VERBOSE_MODE=--verbose
if "%~1"=="--prefer-md" set PREFER_MODE=--prefer-md
if "%~1"=="--prefer-json" set PREFER_MODE=--prefer-json
shift
if not "%~1"=="" goto :parse_args
:no_args

:: Build command with safety option
set CMD=node tydisync.js
if defined WATCH_MODE set CMD=%CMD% %WATCH_MODE%
if defined VERBOSE_MODE set CMD=%CMD% %VERBOSE_MODE%
if defined PREFER_MODE set CMD=%CMD% %PREFER_MODE%

:: Display configuration
echo Configuration:
if defined WATCH_MODE (
    echo - Watch Mode: Enabled
) else (
    echo - Watch Mode: Disabled
)
if defined VERBOSE_MODE (
    echo - Verbose Mode: Enabled
) else (
    echo - Verbose Mode: Disabled
)
if "%PREFER_MODE%"=="--prefer-md" (
    echo - Conflict Resolution: Prefer Markdown
) else if "%PREFER_MODE%"=="--prefer-json" (
    echo - Conflict Resolution: Prefer JSON
) else (
    echo - Conflict Resolution: Timestamp-based
)
echo.

:: Run with timeout to help catch errors
echo Running command: %CMD%
echo.
echo Monitoring for 3 seconds to catch startup errors...
start /b cmd /c "%CMD% > sync_output.log 2>&1"

:: Wait briefly to catch immediate errors
timeout /t 3 > nul

:: Check if there was any error output
if exist sync_output.log (
    findstr /i "error exception" sync_output.log > nul
    if not errorlevel 1 (
        echo ERROR detected in synchronization output:
        type sync_output.log
        echo.
        echo Sync process may have failed to start properly.
        exit /b 1
    ) else (
        echo ✓ Sync started successfully with no immediate errors.
        echo Check sync_output.log for detailed output.
    )
)

if defined WATCH_MODE (
    echo.
    echo Watch mode enabled - Sync process is running in the background
    echo To stop the process, use Task Manager to end node.exe
)

exit /b 0 