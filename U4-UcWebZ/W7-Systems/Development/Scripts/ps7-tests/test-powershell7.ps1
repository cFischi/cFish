# test-powershell7.ps1
# Purpose: Test PowerShell 7 functionality
# Created: 2025-03-12

# Display PowerShell version information
Write-Host "PowerShell Version Information:" -ForegroundColor Cyan
$PSVersionTable

##### Test platform-specific features
Write-Host "
Platform-Specific Features:" -ForegroundColor Cyan
if ($IsWindows) {
    Write-Host "Running on Windows" -ForegroundColor Green
}
elseif ($IsLinux) {
    Write-Host "Running on Linux" -ForegroundColor Green
}
elseif ($IsMacOS) {
    Write-Host "Running on macOS" -ForegroundColor Green
}
else {
    Write-Host "Running on unknown platform" -ForegroundColor Yellow
}

##### Test PowerShell 7 specific cmdlets
Write-Host "
Testing PowerShell 7 Specific Cmdlets:" -ForegroundColor Cyan
try {
    ##### Test parallel foreach
    Write-Host "Testing ForEach-Object -Parallel..." -ForegroundColor Gray
    1..3 | ForEach-Object -Parallel {
        "Processing $_ on thread [$(([System.Threading.Thread]::CurrentThread).ManagedThreadId)]"
        Start-Sleep -Seconds 1
    } -ThrottleLimit 3
    Write-Host "ForEach-Object -Parallel test successful" -ForegroundColor Green
}
catch {
    Write-Host "ForEach-Object -Parallel test failed: $_" -ForegroundColor Red
}

##### Test ternary operator
Write-Host "
Testing ternary operator..." -ForegroundColor Gray
$testValue = $true
$result = if ($testValue ) { "Value is true" } else { "Value is false" }
Write-Host "Ternary operator result: $result" -ForegroundColor Green

##### Test null conditional operators
Write-Host "
Testing null conditional operators..." -ForegroundColor Gray
$nullValue = $null
$nonNullValue = "test"
Write-Host "Null coalescing operator: $($nullValue ?? 'Default Value')" -ForegroundColor Green
Write-Host "Null conditional assignment: Before = '$nullValue'" -ForegroundColor Gray
$nullValue ??= "Assigned Value"
Write-Host "Null conditional assignment: After = '$nullValue'" -ForegroundColor Green

Write-Host "
PowerShell 7 test completed successfully" -ForegroundColor Cyan

