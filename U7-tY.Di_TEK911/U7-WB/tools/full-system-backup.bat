@echo off
REM Run the full-system-backup script
REM This is a wrapper for U7-Systems\Tools\OrganizationSystem\full-system-backup.bat

echo Running full-system-backup...
powershell -ExecutionPolicy Bypass -File "U7-Systems\Tools\OrganizationSystem\full-system-backup.bat" %*
if %ERRORLEVEL% NEQ 0 (
    echo Error occurred during execution.
    pause
    exit /b %ERRORLEVEL%
)
echo Script completed successfully.
exit /b 0
