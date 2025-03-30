@echo off
REM verify-sync-system.bat
REM This batch file verifies the sync system is working properly
REM Following UcFish digital organization standards

echo =========================================================
echo   cFish.io - Sync System Verification
echo =========================================================

REM Execute PowerShell script
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0ucf-u5.1-verify-sync-system-20250314.ps1"

echo.
echo Verification completed. Check memory.md and logs for details.
pause 