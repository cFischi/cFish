@echo off
:: ucf-u5.4-run-scheduler-as-admin-20250313.bat
:: This batch file runs the automation scheduling script with administrator privileges
:: Following UcFish digital organization standards
:: Department: U5 - Data Management
:: Function: 4 - Automation

echo =========================================================
echo  cFish.io Automation Scheduler - Administrator Elevation
echo =========================================================
echo.
echo This script will launch a new PowerShell window with administrator privileges
echo to schedule the daily health checks and backups.
echo.
echo Please click "Yes" on the UAC prompt to continue.
echo.
pause

:: Run the PowerShell script with administrator privileges
powershell -Command "Start-Process PowerShell -ArgumentList '-ExecutionPolicy Bypass -File \"%~dp0ucf-u5.4-schedule-automation-20250313.ps1\"' -Verb RunAs"

echo.
echo If a new PowerShell window opened, the scheduler is running with administrator privileges.
echo Please check that window for results.
echo.
pause 