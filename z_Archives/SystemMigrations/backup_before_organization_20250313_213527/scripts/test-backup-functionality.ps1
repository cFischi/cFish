# Test Backup Functionality in prioritized-sync.ps1
# Created: 2024-06-28
# Purpose: Verify that the Backup-File function creates backups correctly

# Use the same Write-Log function as the original script
function Write-Log {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [Parameter(Mandatory=$false)]
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] [$Level] $Message"
}

##### Create test directory structure
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$TestDir = Join-Path -Path $ScriptDir -ChildPath "test-backup"
$TestFile = Join-Path -Path $TestDir -ChildPath "test-file.md"

##### Set backup directory for testing
$backupDir = Join-Path -Path $TestDir -ChildPath "backups"

##### Define the Backup-File function directly here (copied from prioritized-sync.ps1)
##### This avoids dot-sourcing the entire script
function Backup-File {
    param (
        [Parameter(Mandatory=$true)]
        [string]$FilePath
    )
    
    try {
        ##### Just use the filename with a timestamp
        $fileName = [System.IO.Path]::GetFileName($FilePath)
        $backupFileName = "backup_$(Get-Date -Format 'yyyyMMddHHmmss')_$fileName"
        $backupPath = Join-Path -Path $backupDir -ChildPath $backupFileName
        
        Copy-Item -Path $FilePath -Destination $backupPath -Force
        return $true
    }
    catch {
        Write-Log "Failed to backup file $FilePath" "ERROR"
        return $false
    }
}

##### ====================== TEST EXECUTION ======================

##### Cleanup previous test files if they exist
if (Test-Path $TestDir) {
    Remove-Item -Path $TestDir -Recurse -Force
}

##### Create test directory and file
New-Item -Path $TestDir -ItemType Directory -Force | Out-Null
Set-Content -Path $TestFile -Value "# Test Content`n`nThis is a test file for backup functionality."

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  tYDiSync~ - Backup Function Test  " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""

##### Check if test file was created
if (-not (Test-Path $TestFile)) {
    Write-Host "Error: Failed to create test file at $TestFile" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Created test file: $TestFile" -ForegroundColor Green

##### Make sure backup directory exists
if (-not (Test-Path $backupDir)) {
    New-Item -Path $backupDir -ItemType Directory -Force | Out-Null
    Write-Host "✅ Created backup directory: $backupDir" -ForegroundColor Green
}

##### Perform backup test
Write-Host "Testing backup function..." -ForegroundColor Yellow
$backupResult = Backup-File -FilePath $TestFile

##### Verify backup was successful
if ($backupResult -eq $true) {
    Write-Host "✅ Backup function returned success" -ForegroundColor Green
    
    ##### Check if any backup files were created
    $backupFiles = Get-ChildItem -Path $backupDir -Filter "backup_*"
    
    if ($backupFiles.Count -gt 0) {
        Write-Host "✅ Found $($backupFiles.Count) backup file(s) in $backupDir" -ForegroundColor Green
        
        ##### Verify content of first backup file
        $firstBackup = $backupFiles[0].FullName
        $originalContent = Get-Content -Path $TestFile -Raw
        $backupContent = Get-Content -Path $firstBackup -Raw
        
        if ($originalContent -eq $backupContent) {
            Write-Host "✅ Backup file content matches original file" -ForegroundColor Green
            Write-Host "✅ BACKUP TEST PASSED!" -ForegroundColor Green
        }
        else {
            Write-Host "❌ Backup file content does not match original file" -ForegroundColor Red
            Write-Host "❌ BACKUP TEST FAILED!" -ForegroundColor Red
        }
        
        ##### Display backup file path for review
        Write-Host "Backup file path: $firstBackup" -ForegroundColor Yellow
    }
    else {
        Write-Host "❌ No backup files found in $backupDir" -ForegroundColor Red
        Write-Host "❌ BACKUP TEST FAILED!" -ForegroundColor Red
    }
}
else {
    Write-Host "❌ Backup function returned failure" -ForegroundColor Red
    Write-Host "❌ BACKUP TEST FAILED!" -ForegroundColor Red
}

##### Print summary
Write-Host ""
Write-Host "Test Summary:" -ForegroundColor Cyan
Write-Host "- Test file: $TestFile"
Write-Host "- Backup directory: $backupDir"
if ($backupFiles.Count -gt 0) {
    Write-Host "- Backup file: $firstBackup"
    Write-Host "- Content verification: $(if($originalContent -eq $backupContent){"Passed"}else{"Failed"})"
}

# Optional: Clean up test files
# Uncomment the following line to clean up after test
# Remove-Item -Path $TestDir -Recurse -Force 
