@echo off
setlocal enabledelayedexpansion

echo cFish.io WordPress File Sync Tool
echo --------------------------------
echo.

set REPO_DIR=C:\Users\Chris\cFish.io
set STUDIO_DIR=C:\Users\Chris\Studio\cfishio

:menu
echo Choose what to sync:
echo 1. Assembler Child Theme
echo 2. Custom Plugin (if you have any)
echo 3. All Themes
echo 4. All Plugins
echo 5. Exit
echo.
set /p choice=Enter your choice (1-5): 

if "%choice%"=="1" (
    call :sync_assembler_theme
) else if "%choice%"=="2" (
    call :sync_custom_plugin
) else if "%choice%"=="3" (
    call :sync_all_themes
) else if "%choice%"=="4" (
    call :sync_all_plugins
) else if "%choice%"=="5" (
    exit /b
) else (
    echo Invalid choice. Please try again.
    echo.
    goto menu
)

goto menu

:sync_assembler_theme
echo.
echo Syncing Assembler Child Theme...
if not exist "%STUDIO_DIR%\wp-content\themes\assembler-child" mkdir "%STUDIO_DIR%\wp-content\themes\assembler-child"
xcopy "%REPO_DIR%\wp-content\themes\assembler-child" "%STUDIO_DIR%\wp-content\themes\assembler-child" /E /I /Y
echo Assembler Child Theme synced successfully!
echo.
goto :eof

:sync_custom_plugin
echo.
set /p plugin_name=Enter the name of your custom plugin folder: 
if not exist "%REPO_DIR%\wp-content\plugins\%plugin_name%" (
    echo Plugin folder not found in repository.
    goto :eof
)
if not exist "%STUDIO_DIR%\wp-content\plugins\%plugin_name%" mkdir "%STUDIO_DIR%\wp-content\plugins\%plugin_name%"
xcopy "%REPO_DIR%\wp-content\plugins\%plugin_name%" "%STUDIO_DIR%\wp-content\plugins\%plugin_name%" /E /I /Y
echo Custom Plugin %plugin_name% synced successfully!
echo.
goto :eof

:sync_all_themes
echo.
echo Syncing all themes...
xcopy "%REPO_DIR%\wp-content\themes" "%STUDIO_DIR%\wp-content\themes" /E /I /Y
echo All themes synced successfully!
echo.
goto :eof

:sync_all_plugins
echo.
echo Syncing all plugins...
xcopy "%REPO_DIR%\wp-content\plugins" "%STUDIO_DIR%\wp-content\plugins" /E /I /Y
echo All plugins synced successfully!
echo.
goto :eof 