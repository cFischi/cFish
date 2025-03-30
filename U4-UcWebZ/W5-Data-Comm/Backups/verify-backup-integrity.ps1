# Backup Verification Script
# U5-Data/Backups/verify-backup-integrity.ps1
# This script verifies the integrity of critical file backups

param (
    [string]$BackupDate = (Get-Date -Format 'yyyyMMdd'),
    [switch]$VerifyAll
)

$ErrorActionPreference = "Stop"

##### Define log file
$logFile = Join-Path -Path $PSScriptRoot -ChildPath "backup-verification-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"

function Write-Log {
    param (
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $logEntry = "[$timestamp] [$Level] $Message"
    Add-Content -Path $logFile -Value $logEntry
    
    ##### Also output to console
    switch ($Level) {
        "ERROR" { Write-Host $logEntry -ForegroundColor Red }
        "WARNING" { Write-Host $logEntry -ForegroundColor Yellow }
        "SUCCESS" { Write-Host $logEntry -ForegroundColor Green }
        default { Write-Host $logEntry }
    }
}

##### Function to calculate file hash using System.Security.Cryptography.SHA256
function Get-FileHashManual {
    param (
        [string]$FilePath
    )
    
    try {
        $sha256 = [System.Security.Cryptography.SHA256]::Create()
        $fileStream = [System.IO.File]::OpenRead($FilePath)
        $hashBytes = $sha256.ComputeHash($fileStream)
        $fileStream.Close()
        $fileStream.Dispose()
        
        $hashString = [System.BitConverter]::ToString($hashBytes).Replace("-", "").ToLower()
        return $hashString
    }
    catch {
        Write-Log "Error calculating hash for $FilePath - $_" "ERROR"
        return $null
    }
    finally {
        if ($null -ne $fileStream) {
            $fileStream.Close()
            $fileStream.Dispose()
        }
        if ($null -ne $sha256) {
            $sha256.Dispose()
        }
    }
}

Write-Log "Starting backup verification process"

##### Define critical files and their locations
$criticalFiles = @(
    @{Name = "memory.md"; SourcePath = "../../memory.md"},
    @{Name = "changelog.md"; SourcePath = "../../changelog.md"}
)

##### Define backup directory
$backupRoot = Join-Path -Path $PSScriptRoot -ChildPath "backups/daily"

##### If verifying all, get all backup dates
if ($VerifyAll) {
    $backupDates = Get-ChildItem -Path $backupRoot -Directory | Select-Object -ExpandProperty Name
} else {
    $backupDates = @($BackupDate)
}

##### Verification counters
$totalFiles = 0
$verifiedFiles = 0
$corruptedFiles = 0
$missingFiles = 0

##### Verify each backup date
foreach ($date in $backupDates) {
    Write-Log "Verifying backups for date: $date"
    $backupDir = Join-Path -Path $backupRoot -ChildPath $date
    
    if (-not (Test-Path $backupDir)) {
        Write-Log "Backup directory not found for date: $date" "WARNING"
        continue
    }
    
    ##### Verify each critical file
    foreach ($file in $criticalFiles) {
        $totalFiles++
        $sourcePath = Resolve-Path -Path $file.SourcePath -ErrorAction SilentlyContinue
        $backupPath = Join-Path -Path $backupDir -ChildPath $file.Name
        
        if (-not (Test-Path $backupPath)) {
            Write-Log "Backup file not found: $($file.Name) ($date)" "ERROR"
            $missingFiles++
            continue
        }
        
        if (-not $sourcePath) {
            Write-Log "Source file not found: $($file.SourcePath)" "WARNING"
            continue
        }
        
        try {
            ##### Calculate hashes using manual function
            $sourceHash = Get-FileHashManual -FilePath $sourcePath
            $backupHash = Get-FileHashManual -FilePath $backupPath
            
            if ($sourceHash -eq $backupHash) {
                Write-Log "Verified: $($file.Name) ($date)" "SUCCESS"
                $verifiedFiles++
            } else {
                Write-Log "Corrupted: $($file.Name) ($date) - Hash mismatch" "ERROR"
                $corruptedFiles++
            }
        } catch {
            Write-Log "Error verifying file: $($file.Name) ($date) - $_" "ERROR"
            $corruptedFiles++
        }
    }
}

##### Output summary
Write-Log "======= VERIFICATION SUMMARY ======="
Write-Log "Total files checked: $totalFiles"
Write-Log "Successfully verified: $verifiedFiles"
Write-Log "Corrupted files: $corruptedFiles" $(if ($corruptedFiles -gt 0) { "ERROR" } else { "SUCCESS" })
Write-Log "Missing files: $missingFiles" $(if ($missingFiles -gt 0) { "ERROR" } else { "SUCCESS" })

##### Provide recommendations if issues found
if ($corruptedFiles -gt 0 -or $missingFiles -gt 0) {
    Write-Log "==== RECOMMENDED ACTIONS ===="
    Write-Log "1. Check backup procedure for potential issues" "WARNING"
    Write-Log "2. Restore corrupted files from alternative backup sources" "WARNING"
}

Write-Log "Verification process completed. Log saved to: $logFile"
Write-Host "Verification process completed. Log saved to: $logFile" 
