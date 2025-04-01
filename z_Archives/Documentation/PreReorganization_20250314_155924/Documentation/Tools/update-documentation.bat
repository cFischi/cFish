@echo off
REM =========================================================
REM update-documentation.bat
REM Purpose: Update memory.md and changelog.md with implementation details
REM Date: 2025-03-14
REM =========================================================

echo Updating documentation with implementation details...
echo.

echo Updating memory.md...
powershell -ExecutionPolicy Bypass -File "update-memory.ps1"

echo.
echo Updating changelog.md...
powershell -ExecutionPolicy Bypass -File "update-changelog.ps1"

echo.
echo Documentation update complete.
echo.
pause 