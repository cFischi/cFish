# Test Directory Operations
Write-Host "Starting Directory Operations Test..."

# Test Variables
$testDir = ".cursor/test-dir"
$testFile = "$testDir/test.txt"
$testContent = "Test content"

try {
    # Test directory creation
    Write-Host "Testing directory creation..."
    if (Test-Path $testDir) {
        Remove-Item $testDir -Recurse -Force
    }
    New-Item -ItemType Directory -Path $testDir -Force
    if (Test-Path $testDir) {
        Write-Host "✓ Directory creation successful" -ForegroundColor Green
    } else {
        throw "Directory creation failed"
    }

    # Test file creation
    Write-Host "Testing file creation..."
    Set-Content -Path $testFile -Value $testContent
    if (Test-Path $testFile) {
        Write-Host "✓ File creation successful" -ForegroundColor Green
    } else {
        throw "File creation failed"
    }

    # Test file read
    Write-Host "Testing file read..."
    $content = Get-Content -Path $testFile
    if ($content -eq $testContent) {
        Write-Host "✓ File read successful" -ForegroundColor Green
    } else {
        throw "File read failed"
    }

    # Test file update
    Write-Host "Testing file update..."
    $newContent = "Updated content"
    Set-Content -Path $testFile -Value $newContent
    $content = Get-Content -Path $testFile
    if ($content -eq $newContent) {
        Write-Host "✓ File update successful" -ForegroundColor Green
    } else {
        throw "File update failed"
    }

    # Test file deletion
    Write-Host "Testing file deletion..."
    Remove-Item -Path $testFile
    if (-not (Test-Path $testFile)) {
        Write-Host "✓ File deletion successful" -ForegroundColor Green
    } else {
        throw "File deletion failed"
    }

    # Test directory deletion
    Write-Host "Testing directory deletion..."
    Remove-Item -Path $testDir
    if (-not (Test-Path $testDir)) {
        Write-Host "✓ Directory deletion successful" -ForegroundColor Green
    } else {
        throw "Directory deletion failed"
    }

    Write-Host "`nAll directory operations tests passed!" -ForegroundColor Green
} catch {
    Write-Host "`nTest failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
} 