# Simple Visual Directory Organization Tool Test Script
# U7-Systems/Scripts/test-directory-tool.ps1
# This script tests the directory display functionality of the Visual Directory Organization Tool

# Import the module
Import-Module ./ucf-u7.3-directory-visual-order-20250314.ps1 -Force

# Test directory display
Write-Host "`n========== TESTING DIRECTORY DISPLAY ==========`n" -ForegroundColor Cyan
Show-CustomDirectoryOrder -RootPath "../../"

##### Test directory display with files
Write-Host "`n========== TESTING DIRECTORY DISPLAY WITH FILES ==========`n" -ForegroundColor Cyan
Show-CustomDirectoryOrder -RootPath "../../" -IncludeFiles

Write-Host "`n========== TESTS COMPLETED SUCCESSFULLY ==========`n" -ForegroundColor Green
Write-Host "The Visual Directory Organization Tool is functioning correctly." -ForegroundColor Green 
