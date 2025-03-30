@echo off
echo.
echo **************************************
echo *   cFish.io STANDARD File Check     *
echo **************************************
echo.
echo This script checks file naming conventions in key directories
echo with moderate depth (1 level of subdirectories)
echo.
echo Starting check...
echo.

powershell -ExecutionPolicy Bypass -File check-file-naming-standard.ps1

echo.
echo Check completed!
echo.
pause 