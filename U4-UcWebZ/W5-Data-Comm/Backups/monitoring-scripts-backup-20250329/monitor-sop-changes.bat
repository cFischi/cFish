@echo off
REM =======================================================================
REM cFish.io Digital Organization System - SOP Change Monitor
REM Version: 1.0.0
REM Date: 2025-03-14
REM =======================================================================

echo cFish.io Digital Organization System - SOP Change Monitor
echo =====================================================================
echo.
echo This tool monitors Standard Operating Procedure (SOP) documents for changes
echo and updates configuration files accordingly. This ensures that all tools
echo remain in sync with the latest SOP requirements.
echo.
echo Options:
echo  -runonce   : Check for changes once and exit
echo  -detailed  : Show detailed log information
echo.

REM Parse parameters
set RUNONCE=
set DETAILED=

:PARAM_LOOP
if "%~1"=="" goto PARAM_DONE
if /i "%~1"=="-runonce" (
    set RUNONCE=-RunOnce
    shift
    goto PARAM_LOOP
)
if /i "%~1"=="-detailed" (
    set DETAILED=-Detailed
    shift
    goto PARAM_LOOP
)
shift
goto PARAM_LOOP

:PARAM_DONE

REM Run the PowerShell script
powershell.exe -ExecutionPolicy Bypass -File "%~dp0monitor-sop-changes.ps1" %RUNONCE% %DETAILED%

echo.
if not defined RUNONCE (
    echo The monitoring script is running in the background.
    echo Press Ctrl+C to stop the monitoring process.
)
else (
    echo Script completed.
    pause
) 