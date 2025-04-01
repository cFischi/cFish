# Test script to check if Git scripts exist

Write-Host "`n======= CHECKING SCRIPT EXISTENCE ======="

$scripts = @(
    ".\push-helper-fixed.ps1",
    ".\cursor-pull.bat",
    ".\z_git-flo\gitflo_tools\push-helper-fixed.ps1",
    ".\z_git-flo\gitflo_tools\cursor-pull.bat"
)

$allExist = $true

foreach ($script in $scripts) {
    $exists = Test-Path $script
    if ($exists) {
        Write-Host "$script EXISTS" -ForegroundColor Green
    } else {
        Write-Host "$script DOES NOT EXIST" -ForegroundColor Red
        $allExist = $false
    }
}

if ($allExist) {
    Write-Host "`nAll scripts exist. Git shortcuts should work properly." -ForegroundColor Green
} else {
    Write-Host "`nSome scripts are missing. Git shortcuts may not work properly." -ForegroundColor Red
} 