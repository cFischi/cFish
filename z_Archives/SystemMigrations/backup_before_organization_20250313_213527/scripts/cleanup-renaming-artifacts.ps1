#!/usr/bin/env pwsh
# cleanup-renaming-artifacts.ps1
# Script to clean up temporary files and backup files created during the tYDiSync~ renaming process

Write-Host "=== tYDiSync~ Renaming Cleanup Script ===" -ForegroundColor Green
Write-Host "This script will remove temporary files and backup files created during the renaming process." -ForegroundColor Yellow
Write-Host "Started at: $(Get-Date)" -ForegroundColor Cyan
Write-Host ""

##### Configuration
$rootDir = (Get-Item -Path "..\").FullName
$backupDir = Join-Path -Path $rootDir -ChildPath "backups"
$logsDir = Join-Path -Path $rootDir -ChildPath "logs"
$archiveDir = Join-Path -Path $rootDir -ChildPath "archive\renaming-scripts"

##### Create archive directory if it doesn't exist
if (-not (Test-Path -Path $archiveDir)) {
    New-Item -Path $archiveDir -ItemType Directory -Force | Out-Null
    Write-Host "Created archive directory: $archiveDir" -ForegroundColor Green
}

##### Function to delete files with confirmation
function Remove-FilesWithPattern {
    param (
        [string]$Directory,
        [string]$Pattern,
        [string]$Description,
        [switch]$RequireConfirmation
    )

    Write-Host "Looking for $Description in $Directory..." -ForegroundColor Cyan
    $files = Get-ChildItem -Path $Directory -Filter $Pattern -Recurse -File -ErrorAction SilentlyContinue
    
    if ($files.Count -eq 0) {
        Write-Host "No $Description found." -ForegroundColor Yellow
        return
    }
    
    Write-Host "Found $($files.Count) $Description" -ForegroundColor Yellow
    $files | ForEach-Object { Write-Host "  - $($_.FullName)" }
    
    $confirmation = "Y"
    if ($RequireConfirmation) {
        $confirmation = Read-Host "Do you want to delete these files? (Y/N)"
    }
    
    if ($confirmation -eq "Y" -or $confirmation -eq "y") {
        $files | ForEach-Object { 
            Remove-Item -Path $_.FullName -Force
            Write-Host "Deleted: $($_.FullName)" -ForegroundColor Red
        }
        Write-Host "All $Description have been deleted." -ForegroundColor Green
    } else {
        Write-Host "No files were deleted." -ForegroundColor Yellow
    }
}

##### Function to archive scripts
function Archive-RenameScripts {
    $renameScripts = @(
        "rename-tydisync-files.ps1",
        "update-imports.js",
        "update-batch-files.js",
        "update-documentation.js",
        "update-docs-directory.js",
        "update-remaining-references.js",
        "update-remaining-references-simple.js",
        "update-sync-system-references.js",
        "verify-tydisync-references.js",
        "verify-tydisync-renaming.js",
        "update-final-memory-entry.js",
        "update-file-references.js",
        "rename-files-tydisync.bat",
        "complete-tydisync-renaming.bat",
        "update-changelog-for-renaming.js"
    )
    
    Write-Host "Archiving renaming scripts..." -ForegroundColor Cyan
    $count = 0
    
    foreach ($script in $renameScripts) {
        $scriptPath = Join-Path -Path $rootDir -ChildPath $script
        if (Test-Path -Path $scriptPath) {
            $destPath = Join-Path -Path $archiveDir -ChildPath $script
            Copy-Item -Path $scriptPath -Destination $destPath -Force
            Write-Host "Archived: $script" -ForegroundColor Green
            $count++
        }
    }
    
    if ($count -eq 0) {
        Write-Host "No scripts were found for archiving." -ForegroundColor Yellow
        return
    }
    
    $confirmation = Read-Host "Do you want to delete the original scripts after archiving? (Y/N)"
    if ($confirmation -eq "Y" -or $confirmation -eq "y") {
        foreach ($script in $renameScripts) {
            $scriptPath = Join-Path -Path $rootDir -ChildPath $script
            if (Test-Path -Path $scriptPath) {
                Remove-Item -Path $scriptPath -Force
                Write-Host "Deleted original: $script" -ForegroundColor Red
            }
        }
        Write-Host "All original scripts have been deleted." -ForegroundColor Green
    } else {
        Write-Host "Original scripts were preserved." -ForegroundColor Yellow
    }
}

##### 1. Delete .bak files
Remove-FilesWithPattern -Directory $rootDir -Pattern "*.bak" -Description "backup files" -RequireConfirmation

##### 2. Delete temporary files created during testing
Remove-FilesWithPattern -Directory $rootDir -Pattern "*_temp_*" -Description "temporary files" -RequireConfirmation
Remove-FilesWithPattern -Directory $rootDir -Pattern "temp_*" -Description "temporary files" -RequireConfirmation

##### 3. Archive renaming scripts
Archive-RenameScripts

##### 4. Clean up old debug logs
$oldLogs = Get-ChildItem -Path $logsDir -Filter "md-json-sync-*.log" -File -ErrorAction SilentlyContinue
if ($oldLogs.Count -gt 0) {
    Write-Host "Found $($oldLogs.Count) old debug logs:" -ForegroundColor Yellow
    $oldLogs | ForEach-Object { Write-Host "  - $($_.Name)" }
    
    $confirmation = Read-Host "Do you want to delete these old logs? (Y/N)"
    if ($confirmation -eq "Y" -or $confirmation -eq "y") {
        $oldLogs | ForEach-Object { 
            Remove-Item -Path $_.FullName -Force
            Write-Host "Deleted: $($_.Name)" -ForegroundColor Red
        }
        Write-Host "All old logs have been deleted." -ForegroundColor Green
    } else {
        Write-Host "Old logs were preserved." -ForegroundColor Yellow
    }
}

##### 5. Create a summary of the cleanup
$scriptList = (Get-ChildItem -Path $archiveDir -File | ForEach-Object { "- " + $_.Name }) -join "`n"
$dateFormatted = Get-Date -Format "MM-dd-yyyy"

$summary = @"
##### tYDiSync~ Renaming Cleanup Summary

- **Date**: $(Get-Date)
- **Cleanup Actions**:
  - Removed backup files (*.bak)
  - Removed temporary files created during testing
  - Archived renaming scripts to $archiveDir
  - Cleaned up old debug logs

This cleanup was performed as part of the post-renaming tasks to ensure a clean codebase after the 
successful completion of the tYDiSync~ file renaming project.

###### Archived Scripts

The following renaming scripts have been archived for future reference:

$scriptList

###### Next Steps

1. Run the functional tests using `scripts\test-tydisync-functionality.bat`
2. Review all documentation to ensure consistency
3. Commit all changes to the repository

_Cleanup completed on $dateFormatted_
"@

$summaryPath = Join-Path -Path $rootDir -ChildPath "tydisync-cleanup-summary.md"
$summary | Out-File -FilePath $summaryPath -Force -Encoding utf8
Write-Host "Cleanup summary written to: $summaryPath" -ForegroundColor Green

Write-Host ""
Write-Host "Cleanup completed at: $(Get-Date)" -ForegroundColor Cyan
Write-Host "Check the cleanup summary file for details: tydisync-cleanup-summary.md" -ForegroundColor Green 
