@echo off
REM Visual Directory Organization Tool Test Batch Wrapper
REM U7-Systems/Scripts/test-visual-directory-tool.bat

echo ===== CFISH.IO VISUAL DIRECTORY TOOL TEST =====
echo.
echo This script tests the functionality of the Visual Directory Organization Tool
echo.

echo Select a test option:
echo 1. Run all tests
echo 2. Test directory display only
echo 3. Test shortcut creation only
echo 4. Exit
echo.

:menu
set /p choice=Enter your choice (1-4): 

if "%choice%"=="1" (
    echo.
    echo Running all tests...
    powershell -ExecutionPolicy Bypass -File "%~dp0ucf-u7.3-directory-visual-order-test-20250315.ps1"
    goto end
)

if "%choice%"=="2" (
    echo.
    echo Testing directory display only...
    powershell -ExecutionPolicy Bypass -Command "Import-Module '%~dp0ucf-u7.3-directory-visual-order-20250314.ps1'; Show-CustomDirectoryOrder"
    goto end
)

if "%choice%"=="3" (
    echo.
    echo Testing shortcut creation...
    powershell -ExecutionPolicy Bypass -Command "Import-Module '%~dp0ucf-u7.3-directory-visual-order-20250314.ps1'; Create-DesktopShortcuts -OpenInExplorer"
    goto end
)

if "%choice%"=="4" (
    echo.
    echo Exiting...
    goto exit
)

echo.
echo Invalid choice. Please try again.
goto menu

:end
echo.
echo Test completed.

:exit
echo.
pause 