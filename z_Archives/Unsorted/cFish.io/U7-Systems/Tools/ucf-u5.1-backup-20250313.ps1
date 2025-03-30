# ucf-u5.1-backup-20250313.ps1
# Backup Script for cFish.io Digital Organization System
# This script creates backups of critical files and directories

# Configuration
$CONFIG = @{
    # Backup settings
    BackupRoot = "cFish.io\U5-Data\Backups"
    DailyBackupsFolder = "cFish.io\U5-Data\Backups\Daily"
    WeeklyBackupsFolder = "cFish.io\U5-Data\Backups\Weekly"
    MonthlyBackupsFolder = "cFish.io\U5-Data\Backups\Monthly"
    
    ##### Retention policy (days)
    DailyRetention = 7
    WeeklyRetention = 28  ##### 4 weeks
    MonthlyRetention = 180  ##### ~6 months
    
    ##### Log settings
    LogFile = "cFish.io\U3-Operations\Monitoring\logs\backup-log.txt"
    
    ##### Critical files/directories to backup
    CriticalItems = @(
        ##### Documentation
        @{
            Source = "cFish.io\Documentation\memory.md"
            Destination = "Documentation"
            Type = "File"
        },
        @{
            Source = "cFish.io\Documentation\*.md"
            Destination = "Documentation"
            Type = "Files"
        },
        
        ##### tYDiSync configuration
        @{
            Source = "cFish.io\U5-Data\Synchronization\tydisync\config"
            Destination = "Synchronization\tydisync\config"
            Type = "Directory"
        },
        
        ##### Operations
        @{
            Source = "cFish.io\U3-Operations\SOP"
            Destination = "Operations\SOP"
            Type = "Directory"
        },
        
        ##### WordPress content
        @{
            Source = "cFish.io\U4-Production\WordPress"
            Destination = "Production\WordPress"
            Type = "Directory"
        },
        
        ##### System tools
        @{
            Source = "cFish.io\U7-Systems\Tools\*.ps1"
            Destination = "Systems\Tools"
            Type = "Files"
        }
    )
}

##### Create backup directories if they don't exist
foreach($dir in @($CONFIG.BackupRoot, $CONFIG.DailyBackupsFolder, $CONFIG.WeeklyBackupsFolder, $CONFIG.MonthlyBackupsFolder)) {
    if (-not (Test-Path $dir)) {
        New-Item -Path $dir -ItemType Directory -Force | Out-Null
        Write-Host "Created directory: $dir"
    }
}

##### Function to write to log file
function Write-Log {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [Parameter(Mandatory=$false)]
        [ValidateSet("INFO", "WARNING", "ERROR", "SUCCESS")]
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    ##### Write to console with appropriate color
    switch ($Level) {
        "INFO" { Write-Host $logMessage }
        "WARNING" { Write-Host $logMessage -ForegroundColor Yellow }
        "ERROR" { Write-Host $logMessage -ForegroundColor Red }
        "SUCCESS" { Write-Host $logMessage -ForegroundColor Green }
    }
    
    ##### Create log directory if it doesn't exist
    $logDir = Split-Path -Parent $CONFIG.LogFile
    if (-not (Test-Path $logDir)) {
        New-Item -Path $logDir -ItemType Directory -Force | Out-Null
    }
    
    ##### Write to log file
    Add-Content -Path $CONFIG.LogFile -Value $logMessage
}

##### Function to create a backup
function New-Backup {
    param(
        [Parameter(Mandatory=$true)]
        [string]$BackupType  ##### Daily, Weekly, or Monthly
    )
    
    ##### Determine backup folder based on type
    switch ($BackupType) {
        "Daily" { $backupFolder = $CONFIG.DailyBackupsFolder }
        "Weekly" { $backupFolder = $CONFIG.WeeklyBackupsFolder }
        "Monthly" { $backupFolder = $CONFIG.MonthlyBackupsFolder }
        default { 
            Write-Log "Invalid backup type: $BackupType" -Level "ERROR"
            return $false
        }
    }
    
    ##### Create timestamp for backup folder
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $backupDestination = Join-Path -Path $backupFolder -ChildPath $timestamp
    
    ##### Create backup destination folder
    New-Item -Path $backupDestination -ItemType Directory -Force | Out-Null
    
    Write-Log "Creating $BackupType backup at $backupDestination..."
    
    $successCount = 0
    $failCount = 0
    
    ##### Process each critical item
    foreach ($item in $CONFIG.CriticalItems) {
        Write-Log "Processing backup of $($item.Source)..."
        
        ##### Create destination folder if needed
        $itemDestination = Join-Path -Path $backupDestination -ChildPath $item.Destination
        if (-not (Test-Path $itemDestination)) {
            New-Item -Path $itemDestination -ItemType Directory -Force | Out-Null
        }
        
        ##### Backup based on item type
        try {
            switch ($item.Type) {
                "File" {
                    if (Test-Path $item.Source) {
                        Copy-Item -Path $item.Source -Destination $itemDestination -Force
                        Write-Log "Backed up file: $($item.Source) -> $itemDestination" -Level "SUCCESS"
                        $successCount++
                    } else {
                        Write-Log "Source file not found: $($item.Source)" -Level "WARNING"
                        $failCount++
                    }
                }
                "Files" {
                    $files = Get-ChildItem -Path $item.Source -ErrorAction SilentlyContinue
                    if ($files.Count -gt 0) {
                        foreach ($file in $files) {
                            Copy-Item -Path $file.FullName -Destination $itemDestination -Force
                        }
                        Write-Log "Backed up $($files.Count) files from $($item.Source) -> $itemDestination" -Level "SUCCESS"
                        $successCount++
                    } else {
                        Write-Log "No files found matching: $($item.Source)" -Level "WARNING"
                        $failCount++
                    }
                }
                "Directory" {
                    if (Test-Path $item.Source) {
                        Copy-Item -Path $item.Source -Destination $itemDestination -Recurse -Force
                        Write-Log "Backed up directory: $($item.Source) -> $itemDestination" -Level "SUCCESS"
                        $successCount++
                    } else {
                        Write-Log "Source directory not found: $($item.Source)" -Level "WARNING"
                        $failCount++
                    }
                }
            }
        } catch {
            Write-Log "Error backing up $($item.Source): $_" -Level "ERROR"
            $failCount++
        }
    }
    
    ##### Summary
    Write-Log "Backup complete: $successCount items backed up successfully, $failCount items failed" -Level (($failCount -eq 0) ? "SUCCESS" : "WARNING")
    
    ##### Create a metadata file with backup information
    $metadataContent = @"
Backup Type: $BackupType
Created: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
Items: $($CONFIG.CriticalItems.Count)
Success: $successCount
Failed: $failCount
"@
    
    Set-Content -Path (Join-Path -Path $backupDestination -ChildPath "backup-info.txt") -Value $metadataContent
    
    return @{
        Path = $backupDestination
        Success = $successCount
        Failed = $failCount
        Total = $CONFIG.CriticalItems.Count
    }
}

##### Function to clean up old backups
function Remove-OldBackups {
    ##### Clean daily backups
    $dailyBackups = Get-ChildItem -Path $CONFIG.DailyBackupsFolder -Directory |
                    Sort-Object CreationTime
    $cutoffDate = (Get-Date).AddDays(-$CONFIG.DailyRetention)
    
    foreach ($backup in $dailyBackups) {
        if ($backup.CreationTime -lt $cutoffDate) {
            Write-Log "Removing old daily backup: $($backup.FullName)"
            Remove-Item -Path $backup.FullName -Recurse -Force
        }
    }
    
    ##### Clean weekly backups
    $weeklyBackups = Get-ChildItem -Path $CONFIG.WeeklyBackupsFolder -Directory |
                     Sort-Object CreationTime
    $cutoffDate = (Get-Date).AddDays(-$CONFIG.WeeklyRetention)
    
    foreach ($backup in $weeklyBackups) {
        if ($backup.CreationTime -lt $cutoffDate) {
            Write-Log "Removing old weekly backup: $($backup.FullName)"
            Remove-Item -Path $backup.FullName -Recurse -Force
        }
    }
    
    ##### Clean monthly backups
    $monthlyBackups = Get-ChildItem -Path $CONFIG.MonthlyBackupsFolder -Directory |
                      Sort-Object CreationTime
    $cutoffDate = (Get-Date).AddDays(-$CONFIG.MonthlyRetention)
    
    foreach ($backup in $monthlyBackups) {
        if ($backup.CreationTime -lt $cutoffDate) {
            Write-Log "Removing old monthly backup: $($backup.FullName)"
            Remove-Item -Path $backup.FullName -Recurse -Force
        }
    }
}

##### Function to update memory.md with backup results
function Update-MemoryFile {
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$BackupResults
    )
    
    $timestamp = Get-Date -Format "MM-dd-2025"
    $backupType = $BackupResults.Type
    $memoryFile = "cFish.io\Documentation\memory.md"
    
    if (-not (Test-Path $memoryFile)) {
        Write-Log "Memory file not found: $memoryFile" -Level "ERROR"
        return $false
    }
    
    ##### Create the entry content
    $entryContent = @"
## $backupType Backup ($timestamp)
- Created $backupType backup of critical cFish.io files
- Backup location: $($BackupResults.Path)
- Items processed: $($BackupResults.Total)
- Successful backups: $($BackupResults.Success)
- Failed backups: $($BackupResults.Failed)
- Removed old backups according to retention policy
- Daily backups retained for $($CONFIG.DailyRetention) days
- Weekly backups retained for $($CONFIG.WeeklyRetention) days
- Monthly backups retained for $($CONFIG.MonthlyRetention) days

_Updated $timestamp | AI: Cursor (Claude 3.7 Sonnet)_

"@
    
    ##### Read the content of memory.md
    $memoryContent = Get-Content $memoryFile -Raw
    
    ##### Find the position to insert the new entry (after existing entries, before "Next Steps" if present)
    $nextStepsIndex = $memoryContent.IndexOf("###### Next Steps")
    
    if ($nextStepsIndex -gt 0) {
        # Insert before Next Steps
        $updatedContent = $memoryContent.Substring(0, $nextStepsIndex) + 
                          $entryContent + 
                          $memoryContent.Substring($nextStepsIndex)
    } else {
        # Append to the end
        $updatedContent = $memoryContent + "`n" + $entryContent
    }
    
    ##### Write the updated content back to the file
    $updatedContent | Set-Content $memoryFile
    
    Write-Log "memory.md updated successfully with backup results"
    return $true
}

##### Main execution
$date = Get-Date
$dayOfWeek = $date.DayOfWeek
$dayOfMonth = $date.Day

Write-Host "Starting cFish.io Backup Process..."
Write-Log "Starting backup process..."

##### Determine backup type
$backupType = "Daily"  ##### Default to daily

if ($dayOfMonth -eq 1) {
    $backupType = "Monthly"
} elseif ($dayOfWeek -eq "Sunday") {
    $backupType = "Weekly"
}

Write-Log "Performing $backupType backup..."

##### Create backup
$backupResults = New-Backup -BackupType $backupType
$backupResults.Type = $backupType

##### Clean up old backups
Write-Log "Cleaning up old backups..."
Remove-OldBackups

##### Update memory.md
Write-Log "Updating memory.md with backup results..."
Update-MemoryFile -BackupResults $backupResults

##### Final summary
Write-Host "`nBackup Process Complete!"
Write-Host "======================="
Write-Host "Backup Type: $backupType"
Write-Host "Location: $($backupResults.Path)"
Write-Host "Items Processed: $($backupResults.Total)"
Write-Host "Successful: $($backupResults.Success)"
Write-Host "Failed: $($backupResults.Failed)"
Write-Host "=======================" 
