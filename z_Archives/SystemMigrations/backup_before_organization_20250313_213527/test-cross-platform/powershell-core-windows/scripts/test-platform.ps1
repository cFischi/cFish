# Platform detection test script
Write-Host "Testing platform detection..."
$PSVersionInfo = $PSVersionTable
Write-Host "PowerShell Version: $($PSVersionInfo.PSVersion)"
Write-Host "PowerShell Edition: $($PSVersionInfo.PSEdition)"

##### Check for platform variables
$platformInfo = [PSCustomObject]@{
    IsCore = $false
    IsWindows = $false
    IsLinux = $false
    IsMacOS = $false
}

##### PowerShell Core check
if ($PSVersionInfo.PSEdition -eq 'Core') {
    $platformInfo.IsCore = $true
    
    ##### Check platform variables if they exist
    if (Get-Variable -Name IsWindows -ErrorAction SilentlyContinue) {
        $platformInfo.IsWindows = $IsWindows
    }
    if (Get-Variable -Name IsLinux -ErrorAction SilentlyContinue) {
        $platformInfo.IsLinux = $IsLinux
    }
    if (Get-Variable -Name IsMacOS -ErrorAction SilentlyContinue) {
        $platformInfo.IsMacOS = $IsMacOS
    }
} else {
    ##### Windows PowerShell (assume Windows)
    $platformInfo.IsWindows = $true
}

##### Output results
Write-Host "Is PowerShell Core: $($platformInfo.IsCore)"
Write-Host "Is Windows: $($platformInfo.IsWindows)"
Write-Host "Is Linux: $($platformInfo.IsLinux)"
Write-Host "Is macOS: $($platformInfo.IsMacOS)"

##### Test environment variables
Write-Host "`nTesting environment variables..."
Write-Host "TEMP: ${env}:TEMP"
Write-Host "HOME: ${env}:HOME"
Write-Host "Path separator: $([IO.Path]::DirectorySeparatorChar)"

##### Test path handling
Write-Host "`nTesting path handling..."
$testPath = Join-Path -Path $PSScriptRoot -ChildPath "test-file.txt"
Write-Host "Test path: $testPath"
Set-Content -Path $testPath -Value "Test content" -Encoding UTF8
Write-Host "Created test file"
$testContent = Get-Content -Path $testPath -Raw
Write-Host "Test file content: $testContent"
Remove-Item -Path $testPath -Force
Write-Host "Removed test file"

##### Write results to log
$logPath = Join-Path -Path $PSScriptRoot -ChildPath "..\logs\platform-test.log"
"Platform test results:`n" | Out-File -FilePath $logPath -Encoding UTF8
"PowerShell Version: $($PSVersionInfo.PSVersion)" | Add-Content -Path $logPath -Encoding UTF8
"PowerShell Edition: $($PSVersionInfo.PSEdition)" | Add-Content -Path $logPath -Encoding UTF8
"Is PowerShell Core: $($platformInfo.IsCore)" | Add-Content -Path $logPath -Encoding UTF8
"Is Windows: $($platformInfo.IsWindows)" | Add-Content -Path $logPath -Encoding UTF8
"Is Linux: $($platformInfo.IsLinux)" | Add-Content -Path $logPath -Encoding UTF8
"Is macOS: $($platformInfo.IsMacOS)" | Add-Content -Path $logPath -Encoding UTF8
"Test run: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | Add-Content -Path $logPath -Encoding UTF8

Write-Host "`nTest completed! Results saved to $logPath"

