@echo off
REM MD-JSON Synchronization System - Test Suite Runner
REM This batch file runs all test scripts for the MD-JSON synchronization system

echo MD-JSON Synchronization System Test Suite
echo -----------------------------------------
echo.

REM Check if Node.js is installed
where node >nul 2>nul
if %errorLevel% neq 0 (
  echo Error: Node.js is not installed or not in PATH.
  echo Please install Node.js from https://nodejs.org/
  pause
  exit /b 1
)

REM Create test directories if they don't exist
if not exist test-data mkdir test-data
if not exist test-merge mkdir test-merge
if not exist test-critical mkdir test-critical
if not exist test-cursor mkdir test-cursor

echo Running Agent Architecture Tests...
echo.
node test-agent-architecture.js
if %errorLevel% neq 0 (
  echo Warning: Agent Architecture Tests had issues.
  echo Check the output above for details.
  echo.
)

echo.
echo Running Content Merge Tests...
echo.
node test-merge-functionality.js
if %errorLevel% neq 0 (
  echo Warning: Content Merge Tests had issues.
  echo Check the output above for details.
  echo.
)

echo.
echo Running Critical File Protection Tests...
echo.
node test-critical-file-protection.js
if %errorLevel% neq 0 (
  echo Warning: Critical File Protection Tests had issues.
  echo Check the output above for details.
  echo.
)

echo.
echo Running Cursor Integration Tests...
echo.
node test-cursor-integration.js
if %errorLevel% neq 0 (
  echo Warning: Cursor Integration Tests had issues.
  echo Check the output above for details.
  echo.
)

echo.
echo All tests completed.
echo See test results above for details.

pause 