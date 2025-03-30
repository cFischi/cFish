@echo off
REM =======================================================================
REM cFish.io Digital Organization System - Daily Health Check
REM Version: 1.0.0
REM Date: 2025-03-14
REM =======================================================================

echo cFish.io Digital Organization System - Daily Health Check
echo =====================================================================
echo.
echo This tool performs a comprehensive health check of the cFish.io system:
echo  - Disk space availability
echo  - Directory structure integrity
echo  - File naming compliance
echo  - Scheduled tasks status
echo  - tYDiSync~ system functionality
echo.
echo The check will generate an HTML report with detailed findings and
echo recommended actions for any issues detected.
echo.

REM Run the PowerShell script
powershell.exe -ExecutionPolicy Bypass -File "%~dp0daily-health-check.ps1"

echo.
echo Script completed.
pause 