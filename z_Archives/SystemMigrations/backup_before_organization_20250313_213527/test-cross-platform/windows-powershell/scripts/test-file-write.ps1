# Simple file write test
Write-Host "Testing file write capabilities..."

##### Get the script directory
$scriptDir = $PSScriptRoot
Write-Host "Script directory: $scriptDir"

##### Create a test file in the script directory
$testFilePath = Join-Path -Path $scriptDir -ChildPath "test-output.txt"
Write-Host "Test file path: $testFilePath"

try {
    "This is a test file." | Out-File -FilePath $testFilePath -Encoding UTF8
    Write-Host "Successfully wrote to test file: $testFilePath" -ForegroundColor Green
    
    ##### Read the file back
    $content = Get-Content -Path $testFilePath -Raw
    Write-Host "File content: $content"
    
    ##### Clean up
    Remove-Item -Path $testFilePath -Force
    Write-Host "Removed test file: $testFilePath" -ForegroundColor Green
} catch {
    Write-Host "Error writing to file: $_" -ForegroundColor Red
}

##### Try to create a file in the parent directory's logs folder
$logsDir = Join-Path -Path $scriptDir -ChildPath "..\logs"
Write-Host "Logs directory: $logsDir"

if (-not (Test-Path -Path $logsDir)) {
    try {
        New-Item -Path $logsDir -ItemType Directory -Force | Out-Null
        Write-Host "Created logs directory: $logsDir" -ForegroundColor Green
    } catch {
        Write-Host "Error creating logs directory: $_" -ForegroundColor Red
    }
}

$logFilePath = Join-Path -Path $logsDir -ChildPath "test-log.txt"
Write-Host "Log file path: $logFilePath"

try {
    "This is a test log entry." | Out-File -FilePath $logFilePath -Encoding UTF8
    Write-Host "Successfully wrote to log file: $logFilePath" -ForegroundColor Green
    
    ##### Read the file back
    $content = Get-Content -Path $logFilePath -Raw
    Write-Host "Log file content: $content"
} catch {
    Write-Host "Error writing to log file: $_" -ForegroundColor Red
} 
