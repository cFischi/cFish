@echo off
SETLOCAL

echo =========================================
echo cFish.io Cursor-Aware MD-JSON Sync Startup Setup
echo =========================================

:: Check for admin privileges
NET SESSION >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo.
    echo This script requires administrative privileges for some operations.
    echo Some features may not work properly without admin rights.
    echo.
    echo You can continue, but it's recommended to run as administrator.
    echo.
    pause
    echo Continuing anyway...
    echo.
)

:: Get the full path of the startup script
set "SCRIPT_PATH=%~dp0start-cursor-sync.bat"
set "STARTUP_PATH=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\CursorMdJsonSync.lnk"

echo Setting up Windows Startup integration...
echo.
echo Script Path: %SCRIPT_PATH%
echo Startup Link: %STARTUP_PATH%
echo.

:: Create a shortcut in the startup folder
echo Creating shortcut in startup folder...

:: Use PowerShell to create a shortcut (more reliable than VBS)
powershell -Command "$WshShell = New-Object -ComObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%STARTUP_PATH%'); $Shortcut.TargetPath = '%SCRIPT_PATH%'; $Shortcut.WorkingDirectory = '%~dp0'; $Shortcut.Description = 'Cursor-Aware MD-JSON Synchronization System'; $Shortcut.Save()"

IF %ERRORLEVEL% NEQ 0 (
    echo.
    echo ERROR: Failed to create startup shortcut.
    pause
    exit /b 1
)

echo.
echo Shortcut created successfully!
echo.
echo The Cursor-Aware MD-JSON synchronization system will now start automatically when you log in to Windows.
echo It will only activate when Cursor is detected as running.
echo.
echo To run it immediately, execute start-cursor-sync.bat or reboot your computer.
echo.
echo To remove this startup item, delete the shortcut from:
echo %STARTUP_PATH%
echo.

:: Create a remove script for convenience
echo @echo off > remove-cursor-sync-startup.bat
echo echo Removing Cursor-Aware MD-JSON Sync from startup... >> remove-cursor-sync-startup.bat
echo del "%STARTUP_PATH%" >> remove-cursor-sync-startup.bat
echo if exist "%STARTUP_PATH%" ( >> remove-cursor-sync-startup.bat
echo     echo Failed to remove startup shortcut. >> remove-cursor-sync-startup.bat
echo     echo Please delete it manually from: >> remove-cursor-sync-startup.bat
echo     echo %STARTUP_PATH% >> remove-cursor-sync-startup.bat
echo ) else ( >> remove-cursor-sync-startup.bat
echo     echo Startup shortcut removed successfully. >> remove-cursor-sync-startup.bat
echo ) >> remove-cursor-sync-startup.bat
echo pause >> remove-cursor-sync-startup.bat

echo A removal script (remove-cursor-sync-startup.bat) has been created for your convenience.

pause
ENDLOCAL 