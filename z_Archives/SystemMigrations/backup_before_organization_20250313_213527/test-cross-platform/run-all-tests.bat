@echo off
echo Running cross-platform tests on all available environments...

echo.
echo =========================================
echo Testing on Windows PowerShell 5.1
echo =========================================
call "%~dp0\run-winps-tests.bat"

echo.
echo =========================================
echo Testing on PowerShell Core 7+ (Windows)
echo =========================================
call "%~dp0\run-ps7-tests.bat"

echo.
echo =========================================
echo Testing on PowerShell Core in WSL (Linux)
echo =========================================
call "%~dp0\run-wsl-tests.bat"

echo.
echo All tests completed!
pause
