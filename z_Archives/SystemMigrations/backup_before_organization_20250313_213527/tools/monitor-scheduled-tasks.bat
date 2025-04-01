@echo off
REM monitor-scheduled-tasks.bat
REM This batch file runs the scheduled task monitoring script
REM Following UcFish digital organization standards

echo =========================================================
echo   cFish.io - Scheduled Task Monitoring
echo =========================================================

REM Execute PowerShell script with elevated privileges if needed
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0ucf-u5.1-schedule-monitor-20250314.ps1"

echo.
echo Monitoring completed. Check logs for details.
pause 