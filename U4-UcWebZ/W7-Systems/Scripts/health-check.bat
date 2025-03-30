@echo off
echo Running System Health Check...
powershell -ExecutionPolicy Bypass -File "%~dp0\ucf-u7.3-health-check-20250328.ps1"
if %ERRORLEVEL% NEQ 0 (
    echo Warning: System requires attention - check health check log for details
    pause
    exit /b 1
)
echo System health check completed successfully
pause 