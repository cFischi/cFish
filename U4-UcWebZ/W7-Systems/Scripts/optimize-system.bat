@echo off
echo Running System Optimization...
powershell -ExecutionPolicy Bypass -File "%~dp0\ucf-u7.3-optimize-system-20250328.ps1"
if %ERRORLEVEL% NEQ 0 (
    echo Error running system optimization
    exit /b 1
)
echo System optimization completed successfully
pause 