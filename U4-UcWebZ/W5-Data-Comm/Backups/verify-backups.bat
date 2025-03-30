@echo off
REM Backup Verification Batch Wrapper
REM U5-Data/Backups/verify-backups.bat

echo ===== CFISH.IO BACKUP VERIFICATION TOOL =====
echo.
echo This tool verifies the integrity of critical file backups
echo.

echo Select an option:
echo 1. Verify today's backups
echo 2. Verify backups from a specific date
echo 3. Verify all backups
echo 4. Exit
echo.

:menu
set /p choice=Enter your choice (1-4): 

if "%choice%"=="1" (
    echo.
    echo Verifying today's backups...
    powershell -ExecutionPolicy Bypass -File "%~dp0verify-backup-integrity.ps1"
    goto end
)

if "%choice%"=="2" (
    echo.
    set /p backup_date=Enter backup date (YYYYMMDD format): 
    echo Verifying backups from %backup_date%...
    powershell -ExecutionPolicy Bypass -File "%~dp0verify-backup-integrity.ps1" -BackupDate %backup_date%
    goto end
)

if "%choice%"=="3" (
    echo.
    echo Verifying all backups (this may take some time)...
    powershell -ExecutionPolicy Bypass -File "%~dp0verify-backup-integrity.ps1" -VerifyAll
    goto end
)

if "%choice%"=="4" (
    echo.
    echo Exiting...
    goto exit
)

echo.
echo Invalid choice. Please try again.
goto menu

:end
echo.
echo Verification completed.

:exit
echo.
pause 