@echo off
setlocal

echo =======================================================
echo cFish.io Lightweight File Naming Convention Checker
echo =======================================================
echo.
echo This script will check files in UcF directories
echo against the naming convention and generate a summary.
echo.
echo Press any key to continue...
pause > nul

echo.
echo Running lightweight file naming convention checker...
powershell -ExecutionPolicy Bypass -File check-file-naming-light.ps1

echo.
echo Checker complete!
echo.
echo A summary has been generated in file-naming-compliance-summary.md
echo.
echo =======================================================

pause 