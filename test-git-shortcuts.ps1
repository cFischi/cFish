# Test script to verify Git shortcut functionality
# This script will test all execution paths for Git shortcut scripts
# It does not perform actual Git operations, just verifies script execution

Write-Host "`n======= TESTING PUSH WRAPPER SCRIPT ======="
Write-Host "Running: .\push-helper-fixed.ps1 -TestMode" -ForegroundColor Cyan
try {
    & ".\push-helper-fixed.ps1" -TestMode
    Write-Host "Wrapper script executed successfully" -ForegroundColor Green
} catch {
    Write-Host "Error executing wrapper script: $_" -ForegroundColor Red
}

Write-Host "`n======= TESTING PULL WRAPPER SCRIPT ======="
Write-Host "Running: .\cursor-pull.bat -test" -ForegroundColor Cyan
try {
    & ".\cursor-pull.bat" -test
    Write-Host "Wrapper script executed successfully" -ForegroundColor Green
} catch {
    Write-Host "Error executing wrapper script: $_" -ForegroundColor Red
}

Write-Host "`n======= TESTING DIRECT PUSH SCRIPT ACCESS ======="
Write-Host "Running: .\z_git-flo\gitflo_tools\push-helper-fixed.ps1 -TestMode" -ForegroundColor Cyan
try {
    & ".\z_git-flo\gitflo_tools\push-helper-fixed.ps1" -TestMode
    Write-Host "Script executed successfully" -ForegroundColor Green
} catch {
    Write-Host "Error executing script: $_" -ForegroundColor Red
}

Write-Host "`n======= TESTING DIRECT PULL SCRIPT ACCESS ======="
Write-Host "Running: .\z_git-flo\gitflo_tools\cursor-pull.bat -test" -ForegroundColor Cyan
try {
    & ".\z_git-flo\gitflo_tools\cursor-pull.bat" -test
    Write-Host "Script executed successfully" -ForegroundColor Green
} catch {
    Write-Host "Error executing script: $_" -ForegroundColor Red
}

Write-Host "`n======= TEST COMPLETED ======="
Write-Host "Remember to restart VS Code for keybinding changes to take effect" -ForegroundColor Yellow 