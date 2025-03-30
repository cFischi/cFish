@echo off
SETLOCAL

:: Change to the script's directory
cd /d "%~dp0"

:: Start the MD-to-JSON watcher in the background
start "MD-to-JSON Watcher" /MIN cmd /c "md-to-json.bat --watch"

echo MD-to-JSON watcher started in background.
echo A minimized command window will remain open while watching for changes.
echo You can close it from the taskbar when no longer needed.

ENDLOCAL 