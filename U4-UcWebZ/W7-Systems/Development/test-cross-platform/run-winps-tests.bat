@echo off
echo Running tests in Windows PowerShell 5.1...
powershell.exe -ExecutionPolicy Bypass -File "%~dp0\run-tests.ps1" -Environment "windows-powershell"
pause
