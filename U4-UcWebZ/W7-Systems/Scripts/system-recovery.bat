@echo off
echo Running System Recovery...
powershell -ExecutionPolicy Bypass -File "%~dp0\ucf-u7.3-system-recovery-20250328.ps1"
if %ERRORLEVEL% NEQ 0 (
    echo Error running system recovery
    exit /b 1
)
echo System recovery completed successfully
pause 