@echo off
REM System Optimization Batch Wrapper for Local AI
REM File: optimize-system-for-ai.bat
REM Description: Wrapper to easily run the PowerShell optimization script
REM @package cFish.io
REM @since 05-06-2025
REM @author AI: Cursor (Claude 3.7 Sonnet)

echo ============================================================
echo SYSTEM OPTIMIZATION FOR LOCAL AI WORKLOADS
echo ============================================================
echo.
echo This script will analyze your system and recommend optimizations
echo for running local AI models efficiently.
echo.
echo Press any key to continue or CTRL+C to cancel...
pause > nul

powershell -ExecutionPolicy Bypass -File "%~dp0ucf-u7.3-system-optimization-20250506.ps1"

echo.
echo ============================================================
echo System optimization analysis complete.
echo ============================================================
echo.
echo Press any key to exit...
pause > nul 