@echo off
echo Running tests in PowerShell Core on WSL...
wsl pwsh -ExecutionPolicy Bypass -File "%~dp0/run-tests.ps1" -Environment "powershell-core-linux"
pause
