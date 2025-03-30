@echo off
echo.
echo ***************************************
echo *   cFish.io TARGETED File Check      *
echo ***************************************
echo.
echo This script checks file naming conventions in directories you select
echo with support for detailed reporting of non-compliant files
echo.
echo Starting targeted check...
echo.

:: Run the PowerShell script with all parameters passed through
powershell -ExecutionPolicy Bypass -File check-file-naming-targeted.ps1 %*

echo.
echo Check completed!
echo.
pause 