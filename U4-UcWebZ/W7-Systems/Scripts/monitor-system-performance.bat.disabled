@echo off
echo Running System Performance Monitor...
powershell -ExecutionPolicy Bypass -File "%~dp0\ucf-u7.3-monitor-system-performance-20250328.ps1"
if %ERRORLEVEL% NEQ 0 (
    echo Error running performance monitor
    exit /b 1
)
echo Performance monitoring completed successfully
pause 