@echo off
REM Visual Directory Order Tool for cFish.io
REM This batch file helps display directories in your preferred order

echo.
echo ===== CFISH.IO DIRECTORY VISUAL ORGANIZATION =====
echo.
echo This tool will display your directories in your preferred visual order:
echo   1) .cursor (at top)
echo   2) _Resources
echo   3) docs and Documentation
echo   4) U1-U7 directories
echo   5) wp-content
echo   6) _Archives
echo   7) Backup directories
echo   8) All other directories
echo.
echo Choose an option:
echo.
echo [1] Show directories in preferred order (without files)
echo [2] Show directories and files in preferred order
echo [3] Create desktop shortcuts in preferred order
echo [4] Exit
echo.

set /p choice=Enter your choice (1-4): 

if "%choice%"=="1" (
  powershell -ExecutionPolicy Bypass -File "%~dp0ucf-u7.3-directory-visual-order-20250314.ps1" -Command "Show-CustomDirectoryOrder -RootPath '%cd%'"
) else if "%choice%"=="2" (
  powershell -ExecutionPolicy Bypass -File "%~dp0ucf-u7.3-directory-visual-order-20250314.ps1" -Command "Show-CustomDirectoryOrder -RootPath '%cd%' -IncludeFiles"
) else if "%choice%"=="3" (
  powershell -ExecutionPolicy Bypass -File "%~dp0ucf-u7.3-directory-visual-order-20250314.ps1" -Command "Create-DesktopShortcuts -RootPath '%cd%' -OpenInExplorer"
) else if "%choice%"=="4" (
  echo Exiting...
  goto :eof
) else (
  echo Invalid choice. Please run again and select a valid option.
)

echo.
pause 