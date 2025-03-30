@echo off
REM Run the MD-JSON sync system with increased memory allocation
REM This helps prevent JavaScript heap out of memory errors

echo Running MD-JSON synchronization with increased memory allocation...
echo.

REM Increase max old space size to 8GB (8192MB)
node --max-old-space-size=8192 tydisync.js --watch --verbose %*

echo.
echo Process completed or terminated.
pause 