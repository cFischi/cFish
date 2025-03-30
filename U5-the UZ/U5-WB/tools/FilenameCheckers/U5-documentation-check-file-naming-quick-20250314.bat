@echo off
setlocal

echo =======================================================
echo cFish.io Quick File Naming Compliance Check
echo =======================================================
echo.
echo This is a lightweight version that works faster and
echo only shows summary information without listing every file.
echo.
echo Press any key to continue...
pause > nul

echo.
echo Running quick file naming compliance check...
powershell -ExecutionPolicy Bypass -File check-file-naming-quick.ps1 %*

echo.
echo Check complete!
echo.
echo =======================================================

pause 