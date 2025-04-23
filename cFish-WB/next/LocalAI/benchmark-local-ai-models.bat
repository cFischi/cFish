@echo off
REM Local AI Model Benchmarking Batch Wrapper
REM File: benchmark-local-ai-models.bat
REM Description: Wrapper to easily run the PowerShell benchmarking script
REM @package cFish.io
REM @since 05-06-2025
REM @author AI: Cursor (Claude 3.7 Sonnet)

echo ============================================================
echo LOCAL AI MODEL BENCHMARKING UTILITY
echo ============================================================
echo.
echo This utility will guide you through benchmarking your local AI models.
echo It will test different models with various prompt types and
echo record performance metrics to determine optimal settings.
echo.
echo Prerequisites:
echo  - GPT4All must be installed
echo  - Recommended models should be downloaded
echo  - System should be optimized using optimize-system-for-ai.bat
echo.
echo Press any key to continue or CTRL+C to cancel...
pause > nul

powershell -ExecutionPolicy Bypass -File "%~dp0ucf-u7.3-model-benchmarking-20250506.ps1"

echo.
echo ============================================================
echo Benchmarking process complete.
echo ============================================================
echo.
echo Press any key to exit...
pause > nul 