@echo off
REM create-workbench-system.bat
REM Purpose: User-friendly wrapper for workbench system creation script
REM Author: Claude 3.7 Sonnet
REM Date: 2025-03-20
REM Version: 1.0

echo.
echo ==========================================================
echo    cFish.io Workbench System Creation Launcher
echo    %DATE% %TIME%
echo ==========================================================
echo.

echo This script will create a standardized workbench system
echo across all main directories in the cFish.io workspace.
echo.
echo Each workbench will include the following structure:
echo   - active/         (Current work items)
echo   - WB-readme/      (README files for active items)
echo   - next-WB/        (Future work items)
echo   - next-readme/    (README files for future items)
echo   - WB-memory.md    (Tracking file)
echo.
echo This should be run only once for initial setup.
echo.

set /p confirm=Are you sure you want to create the workbench system? (Y/N): 

if /i "%confirm%"=="Y" (
    echo.
    echo Creating workbench system...
    echo.
    
    powershell -ExecutionPolicy Bypass -File "%~dp0ucf-u7.3-create-workbench-system-20250320.ps1"
    
    echo.
    echo Workbench system creation completed.
    echo.
    echo After reviewing the results, consider running:
    echo update-workbench-system.bat to enhance the workbenches.
    echo.
) else (
    echo.
    echo Workbench system creation cancelled.
    echo.
)

echo Press any key to exit...
pause > nul 