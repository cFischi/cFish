@echo off
echo Running System Maintenance...
powershell -ExecutionPolicy Bypass -File "%~dp0\ucf-u7.3-master-system-maintenance-20250328.ps1"
if %ERRORLEVEL% NEQ 0 (
    echo Warning: System maintenance completed with warnings - check maintenance log for details
    pause
    exit /b 1
)
echo System maintenance completed successfully
pause 