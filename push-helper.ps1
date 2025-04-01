# Wrapper script for backward compatibility
param(
    [switch]$TestMode
)

Write-Host "Redirecting to z_git-flo\gitflo_tools\push-helper-fixed.ps1..."
if ($TestMode) {
    & ".\z_git-flo\gitflo_tools\push-helper-fixed.ps1" -TestMode
} else {
    & ".\z_git-flo\gitflo_tools\push-helper-fixed.ps1"
} 