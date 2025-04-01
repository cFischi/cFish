@echo off
setlocal enabledelayedexpansion

echo =========================================
echo cFish.io MD-JSON Two-Way Sync
echo =========================================

:: Check if Node.js is installed
where node >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo Error: Node.js is not installed or not in PATH.
    echo Please install Node.js from https://nodejs.org/
    exit /b 1
)

:: Parse command line arguments
set WATCH_MODE=
set VERBOSE_MODE=
set PREFER_MODE=
set RECURSIVE_MODE=
set DEPTH_PARAM=
set NON_RECURSIVE_WATCH=
set NO_BACKUPS=
set HELP_MODE=
set CONVERT_MODE=
set CONVERT_FILE=

echo DEBUG: Arguments: %*

:: Check for convert mode first
set i=0
for %%a in (%*) do (
    set /a i+=1
    if /i "%%a"=="--convert" (
        set CONVERT_MODE=--convert
        set /a next=!i!+1
        set j=0
        for %%b in (%*) do (
            set /a j+=1
            if !j!==!next! set CONVERT_FILE=%%b
        )
    )
    if /i "%%a"=="--verbose" set VERBOSE_MODE=--verbose
    if /i "%%a"=="-v" set VERBOSE_MODE=--verbose
    if /i "%%a"=="--watch" set WATCH_MODE=--watch
    if /i "%%a"=="-w" set WATCH_MODE=--watch
    if /i "%%a"=="--prefer-md" set PREFER_MODE=--prefer-md
    if /i "%%a"=="--prefer-json" set PREFER_MODE=--prefer-json
    if /i "%%a"=="--recursive" set RECURSIVE_MODE=--recursive
    if /i "%%a"=="--non-recursive-watch" set NON_RECURSIVE_WATCH=--non-recursive-watch
    if /i "%%a"=="--no-backups" set NO_BACKUPS=--no-backups
    if /i "%%a"=="--help" set HELP_MODE=1
    if /i "%%a"=="-h" set HELP_MODE=1
    if /i "%%a"=="/?" set HELP_MODE=1
)

echo DEBUG: After parsing:
echo DEBUG: WATCH_MODE=!WATCH_MODE!
echo DEBUG: VERBOSE_MODE=!VERBOSE_MODE!
echo DEBUG: PREFER_MODE=!PREFER_MODE!
echo DEBUG: RECURSIVE_MODE=!RECURSIVE_MODE!
echo DEBUG: DEPTH_PARAM=!DEPTH_PARAM!
echo DEBUG: NON_RECURSIVE_WATCH=!NON_RECURSIVE_WATCH!
echo DEBUG: NO_BACKUPS=!NO_BACKUPS!
echo DEBUG: HELP_MODE=!HELP_MODE!
echo DEBUG: CONVERT_MODE=!CONVERT_MODE!
echo DEBUG: CONVERT_FILE=!CONVERT_FILE!

:: Display help if requested or if no valid command is specified
if defined HELP_MODE goto :show_help
if not defined WATCH_MODE if not defined CONVERT_MODE goto :show_help

:: Set correct path to the JavaScript file
set JS_PATH=..\sync-system\core\tydisync.js

:: Check if the script exists
if not exist %JS_PATH% (
    echo ERROR: Could not find %JS_PATH%
    echo Make sure you're running this script from the scripts directory
    exit /b 1
)

:: Debug output
echo DEBUG: JS_PATH = %JS_PATH%
echo DEBUG: CONVERT_MODE = %CONVERT_MODE%
echo DEBUG: CONVERT_FILE = %CONVERT_FILE%
echo DEBUG: VERBOSE_MODE = %VERBOSE_MODE%

:: Build command with options
if defined CONVERT_MODE (
    if not defined CONVERT_FILE (
        echo ERROR: No file specified for conversion
        echo Usage: tydisync.bat --convert [file]
        exit /b 1
    )
    set CMD=node %JS_PATH% %CONVERT_MODE% "%CONVERT_FILE%" %VERBOSE_MODE% %PREFER_MODE% %NO_BACKUPS%
    echo Converting file: %CONVERT_FILE%
    echo DEBUG: Command = %CMD%
) else (
    set CMD=node %JS_PATH% %WATCH_MODE% %VERBOSE_MODE% %PREFER_MODE% %RECURSIVE_MODE% %DEPTH_PARAM% %NON_RECURSIVE_WATCH% %NO_BACKUPS%
    
    :: Display command information
    if defined WATCH_MODE (
        echo Running two-way Markdown-JSON synchronization...
        echo Watch mode enabled - Press Ctrl+C to stop
    ) else (
        echo Running one-time Markdown-JSON synchronization...
    )
    echo DEBUG: Command = %CMD%
)

:: Run the command
echo DEBUG: Executing command: %CMD%
%CMD%

:: Check for errors
if %ERRORLEVEL% neq 0 (
    echo ERROR: Synchronization failed with error code %ERRORLEVEL%
    exit /b %ERRORLEVEL%
)

goto :eof

:show_help
echo Usage: tydisync.bat [options]
echo.
echo Options:
echo   --watch, -w              Run in watch mode (continuous monitoring)
echo   --verbose, -v            Display detailed information
echo   --prefer-md              Prefer Markdown files in conflicts
echo   --prefer-json            Prefer JSON files in conflicts
echo   --recursive              Enable recursive directory scanning (default)
echo   --depth=N                Set maximum directory depth for recursive scanning
echo   --non-recursive-watch    Disable recursive watching for compatibility
echo   --no-backups             Disable automatic backups before modifying files
echo   --convert [file]         Convert a specific file (md to json or json to md)
echo   --help, -h, /?           Display this help message
echo.
echo Examples:
echo   tydisync.bat --watch --verbose
echo   tydisync.bat --prefer-md --depth=3
echo   tydisync.bat --non-recursive-watch --watch
echo   tydisync.bat --convert path/to/file.md
exit /b 0

:eof
endlocal 