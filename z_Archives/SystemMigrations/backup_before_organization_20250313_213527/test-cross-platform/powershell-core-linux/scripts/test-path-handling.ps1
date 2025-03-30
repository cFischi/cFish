# Path handling test script
Write-Host "Testing path handling across platforms..."

##### Test 1: Using Join-Path (recommended)
$testDir = Join-Path -Path $PSScriptRoot -ChildPath "test-path-dir"
Write-Host "Test directory: $testDir"
New-Item -Path $testDir -ItemType Directory -Force | Out-Null

##### Test forward slash path
$forwardPath = $testDir.Replace('\', '/')
Write-Host "Forward slash path: $forwardPath"
$forwardWorks = Test-Path -Path $forwardPath
Write-Host "Forward slash path works: $forwardWorks"

##### Test backslash path
$backPath = $testDir.Replace('/', '\')
Write-Host "Backslash path: $backPath"
$backWorks = Test-Path -Path $backPath
Write-Host "Backslash path works: $backWorks"

##### Test with environment variables
$envPath = Join-Path -Path ${env}:TEMP -ChildPath "test-path-env"
Write-Host "Environment path: $envPath"
New-Item -Path $envPath -ItemType Directory -Force | Out-Null
Write-Host "Created environment directory"

##### Test with relative paths
$relativePath = Join-Path -Path "." -ChildPath "test-path-relative"
Write-Host "Relative path: $relativePath"
New-Item -Path $relativePath -ItemType Directory -Force | Out-Null
Write-Host "Created relative directory"

##### Test with special characters
$specialPath = Join-Path -Path $testDir -ChildPath "test with spaces and (special) characters.txt"
Write-Host "Special character path: $specialPath"
Set-Content -Path $specialPath -Value "Test content with special characters: äöüßÄÖÜ" -Encoding UTF8
Write-Host "Created special character file"

##### Test with unicode characters
$unicodePath = Join-Path -Path $testDir -ChildPath "test-unicode-??.txt"
Write-Host "Unicode path: $unicodePath"
try {
    Set-Content -Path $unicodePath -Value "Unicode content: ?????" -Encoding UTF8
    Write-Host "Created unicode file" -ForegroundColor Green
} catch {
    Write-Host "Unicode path creation failed: $_" -ForegroundColor Red
}

##### Clean up
Remove-Item -Path $testDir -Recurse -Force
Write-Host "Removed test directory"

Remove-Item -Path $envPath -Recurse -Force
Write-Host "Removed environment directory"

Remove-Item -Path $relativePath -Recurse -Force
Write-Host "Removed relative directory"

##### Write results to log
$logPath = Join-Path -Path $PSScriptRoot -ChildPath "..\logs\path-test.log"
"Path handling test results:`n" | Out-File -FilePath $logPath -Encoding UTF8
"Forward slash path works: $forwardWorks" | Add-Content -Path $logPath -Encoding UTF8
"Backslash path works: $backWorks" | Add-Content -Path $logPath -Encoding UTF8
"Path separator character: $([IO.Path]::DirectorySeparatorChar)" | Add-Content -Path $logPath -Encoding UTF8
"Test run: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | Add-Content -Path $logPath -Encoding UTF8

Write-Host "`nTest completed! Results saved to $logPath"

