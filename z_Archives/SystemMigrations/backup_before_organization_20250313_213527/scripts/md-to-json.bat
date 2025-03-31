@echo off
SETLOCAL

echo =========================================
echo cFish.io MD-to-JSON Converter
echo =========================================

:: Check if Node.js is installed
node --version > nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
  echo ERROR: Node.js is not installed or not in PATH.
  echo Please install Node.js from https://nodejs.org/
  exit /b 1
)

:: Parse command line arguments
SET WATCH_MODE=
SET VERBOSE=

:PARSE_ARGS
IF "%~1"=="" GOTO ENDPARSE
IF /I "%~1"=="--watch" SET WATCH_MODE=--watch
IF /I "%~1"=="-w" SET WATCH_MODE=--watch
IF /I "%~1"=="--verbose" SET VERBOSE=--verbose
IF /I "%~1"=="-v" SET VERBOSE=--verbose
SHIFT
GOTO PARSE_ARGS
:ENDPARSE

:: Run the converter
echo Running markdown to JSON converter...

IF DEFINED WATCH_MODE (
  echo Watch mode enabled - Press Ctrl+C to stop
  node md-to-json.js %WATCH_MODE% %VERBOSE%
) ELSE (
  node md-to-json.js %VERBOSE%
)

IF %ERRORLEVEL% NEQ 0 (
  echo ERROR: Conversion failed with error code %ERRORLEVEL%
  exit /b %ERRORLEVEL%
)

echo =========================================
echo Conversion completed successfully!
echo =========================================

ENDLOCAL 