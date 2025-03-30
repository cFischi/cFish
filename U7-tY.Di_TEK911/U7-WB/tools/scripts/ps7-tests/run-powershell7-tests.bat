@echo off
echo ================================================================
echo      Running PowerShell 7 Tests
echo ================================================================
echo.

REM Get the directory of this batch file
set SCRIPT_DIR=%~dp0
set TEST_SCRIPT=%SCRIPT_DIR%test-powershell7.ps1

REM Try to find PowerShell 7 in common installation locations
set PS7_PATH=C:\Program Files\PowerShell\7\pwsh.exe
if not exist "%PS7_PATH%" set PS7_PATH=C:\Program Files\PowerShell\7-preview\pwsh.exe
if not exist "%PS7_PATH%" set PS7_PATH=%LOCALAPPDATA%\Microsoft\PowerShell\7\pwsh.exe
if not exist "%PS7_PATH%" set PS7_PATH=%LOCALAPPDATA%\Microsoft\PowerShell\7-preview\pwsh.exe

if not exist "%PS7_PATH%" (
    echo ERROR: PowerShell 7 not found. Please ensure it is installed.
    goto :end
)

echo Using PowerShell 7 from: %PS7_PATH%
echo Using test script: %TEST_SCRIPT%
echo.

if not exist "%TEST_SCRIPT%" (
    echo ERROR: Test script not found at %TEST_SCRIPT%
    goto :end
)

"%PS7_PATH%" -File "%TEST_SCRIPT%"

:end
echo.
echo ================================================================
echo      PowerShell 7 Tests Completed
echo ================================================================
pause
