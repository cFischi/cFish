@echo off
echo Running tests in PowerShell Core 7+...
pwsh.exe -ExecutionPolicy Bypass -File "%~dp0\run-tests.ps1" -Environment "powershell-core-windows"
pause
