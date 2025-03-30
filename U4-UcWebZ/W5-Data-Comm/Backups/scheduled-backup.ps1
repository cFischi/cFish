# Scheduled Backup Script
# U5-Data/Backups/scheduled-backup.ps1
# This script performs scheduled backups of critical files with retention policy

param (
    [int]$RetentionDays = 7,
    [switch]$Verbose
)

$ErrorActionPreference = "Stop"

##### Define log file
$logDir = Join-Path -Path $PSScriptRoot -ChildPath "logs"
if (-not (Test-Path $logDir)) {
    New-Item -Path $logDir -ItemType Directory | Out-Null
}
$logFile = Join-Path -Path $logDir -ChildPath "backup-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"

function Write-Log {
    param (
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $logEntry = "[$timestamp] [$Level] $Message"
    Add-Content -Path $logFile -Value $logEntry
    
    ##### Also output to console if verbose
    if ($Verbose) {
        switch ($Level) {
            "ERROR" { Write-Host $logEntry -ForegroundColor Red }
            "WARNING" { Write-Host $logEntry -ForegroundColor Yellow }
            "SUCCESS" { Write-Host $logEntry -ForegroundColor Green }
            default { Write-Host $logEntry }
        }
    }
}

Write-Log "Starting scheduled backup process"

##### Define critical files to backup
$criticalFiles = @(
    @{
        Name = "memory.md"
        SourcePath = "../../memory.md"
        Description = "Main memory file"
        Priority = "Critical"
    },
    @{
        Name = "changelog.md"
        SourcePath = "../../changelog.md"
        Description = "Changelog file"
        Priority = "Critical"
    },
    @{
        Name = "ucf-u7.3-directory-visual-order-20250314.ps1"
        SourcePath = "../../ucf-u7.3-directory-visual-order-20250314.ps1"
        Description = "Visual Directory Organization Tool"
        Priority = "High"
    },
    @{
        Name = "show-directory-order.bat"
        SourcePath = "../../show-directory-order.bat"
        Description = "Visual Directory Organization Batch Wrapper"
        Priority = "High"
    }
)

##### Define backup directory
$todayDate = Get-Date -Format 'yyyyMMdd'
$backupRoot = Join-Path -Path $PSScriptRoot -ChildPath "backups/daily"
$backupDir = Join-Path -Path $backupRoot -ChildPath $todayDate

##### Create backup directory if it doesn't exist
if (-not (Test-Path $backupDir)) {
    try {
        New-Item -Path $backupDir -ItemType Directory | Out-Null
        Write-Log "Created backup directory: $backupDir" "SUCCESS"
    } catch {
        Write-Log "Failed to create backup directory: $backupDir - $_" "ERROR"
        exit 1
    }
} else {
    Write-Log "Backup directory already exists: $backupDir" "INFO"
}

##### Backup files
$successCount = 0
$failureCount = 0
foreach ($file in $criticalFiles) {
    $sourcePath = Resolve-Path -Path $file.SourcePath -ErrorAction SilentlyContinue
    $destinationPath = Join-Path -Path $backupDir -ChildPath $file.Name
    
    if (-not $sourcePath) {
        Write-Log "Source file not found: $($file.SourcePath)" "ERROR"
        $failureCount++
        continue
    }
    
    try {
        Copy-Item -Path $sourcePath -Destination $destinationPath -Force
        Write-Log "Successfully backed up: $($file.Name) (Priority: $($file.Priority))" "SUCCESS"
        $successCount++
    } catch {
        Write-Log "Failed to backup: $($file.Name) - $_" "ERROR"
        $failureCount++
    }
}

##### Apply retention policy
try {
    $oldBackups = Get-ChildItem -Path $backupRoot -Directory | Where-Object {
        $creationDate = [DateTime]::ParseExact($_.Name, 'yyyyMMdd', $null)
        $creationDate -lt (Get-Date).AddDays(-$RetentionDays)
    }
    
    foreach ($oldBackup in $oldBackups) {
        Remove-Item -Path $oldBackup.FullName -Recurse -Force
        Write-Log "Removed old backup: $($oldBackup.Name) (Retention policy: $RetentionDays days)" "INFO"
    }
    
    Write-Log "Applied retention policy - removed $($oldBackups.Count) old backup(s)" "SUCCESS"
} catch {
    Write-Log "Failed to apply retention policy - $_" "ERROR"
}

##### Generate summary
Write-Log "======= BACKUP SUMMARY ======="
Write-Log "Total files processed: $($criticalFiles.Count)"
Write-Log "Successfully backed up: $successCount" $(if ($successCount -eq $criticalFiles.Count) { "SUCCESS" } else { "WARNING" })
Write-Log "Failed to backup: $failureCount" $(if ($failureCount -gt 0) { "ERROR" } else { "SUCCESS" })

##### Calculate hash for verification
Write-Log "Calculating file hashes for integrity verification" "INFO"
foreach ($file in $criticalFiles) {
    $sourcePath = Resolve-Path -Path $file.SourcePath -ErrorAction SilentlyContinue
    $backupPath = Join-Path -Path $backupDir -ChildPath $file.Name
    
    if ((Test-Path $sourcePath) -and (Test-Path $backupPath)) {
        try {
            $sourceHash = Get-FileHash -Path $sourcePath -Algorithm SHA256
            $backupHash = Get-FileHash -Path $backupPath -Algorithm SHA256
            
            if ($sourceHash.Hash -eq $backupHash.Hash) {
                Write-Log "Integrity verified: $($file.Name)" "SUCCESS"
            } else {
                Write-Log "Integrity check failed: $($file.Name) - Hash mismatch" "ERROR"
            }
        } catch {
            Write-Log "Failed to verify integrity: $($file.Name) - $_" "ERROR"
        }
    }
}

Write-Log "Backup process completed. Log saved to: $logFile"
if ($Verbose) {
    Write-Host "Backup process completed. Log saved to: $logFile" -ForegroundColor Cyan
}

# Return success status
if ($failureCount -eq 0) {
    exit 0
} else {
    exit 1
} 
