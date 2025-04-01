@echo off
title MD-JSON Two-Way Sync
echo Starting MD-JSON synchronization watcher...
echo Process will continue in the background.
echo Press Ctrl+C to exit.

:: Run the Node.js script with watch mode
node tydisync.js --watch --verbose

echo.
echo Process ended. Press any key to close this window.
pause > nul 