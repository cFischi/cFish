# Daily-Backup.ps1
# This script performs daily backups for cFish.io systems
# Following UcFish digital organization standards
# File: ucf-u5.2-daily-backup.ps1

#-----------------------------------------------
# Configuration
#-----------------------------------------------
$CONFIG = @{
    BackupDirectory = "backups"
    LogDirectory = "logs"
    BackupSchedule = @{
        Daily = @{
            Retention = 7  ##### Number of daily backups to keep
            Directories = @(
                @{ Path = "md"; Description = "Markdown content" },
                @{ Path = "json"; Description = "JSON content" },
                @{ Path = "src"; Description = "Source code" },
                @{ Path = "sync-system\config"; Description = "Sync system configuration" },
                @{ Path = "memory.md"; Description = "Memory file"; Type = "File" },
                @{ Path = "changelog.md"; Description = "Changelog file"; Type = "File" }
            )
        }
        Weekly = @{
            Retention = 4  ##### Number of weekly backups to keep
            Directories = @(
                @{ Path = "wp-content"; Description = "WordPress content" },
                @{ Path = "config"; Description = "Configuration files" },
                @{ Path = "tools"; Description = "Utility scripts" }
            ) 
        }
        Monthly = @{
            Retention = 6  ##### Number of monthly backups to keep
            Directories = @(
                @{ Path = "."; Description = "Full repository"; Exclusions = @(
                    "node_modules", 
                    ".git", 
                    "backups",
                    "temp"
                )}
            )
        }
    }
}

#-----------------------------------------------
##### Initialize
#-----------------------------------------------
$ErrorActionPreference = "Stop"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$dateStamp = Get-Date -Format "yyyyMMdd"
$timeStamp = Get-Date -Format "HHmmss"
$logFile = "$($CONFIG.LogDirectory)\backup-$dateStamp.log"
$backupCount = 0
$errorCount = 0

##### Ensure directories exist
if (-not (Test-Path $CONFIG.BackupDirectory)) {
    New-Item -Path $CONFIG.BackupDirectory -ItemType Directory -Force | Out-Null
}

if (-not (Test-Path $CONFIG.LogDirectory)) {
    New-Item -Path $CONFIG.LogDirectory -ItemType Directory -Force | Out-Null
}

##### Create folder structure
$dailyBackupPath = Join-Path $CONFIG.BackupDirectory "daily"
$weeklyBackupPath = Join-Path $CONFIG.BackupDirectory "weekly"
$monthlyBackupPath = Join-Path $CONFIG.BackupDirectory "monthly"

foreach ($path in @($dailyBackupPath, $weeklyBackupPath, $monthlyBackupPath)) {
    if (-not (Test-Path $path)) {
        New-Item -Path $path -ItemType Directory -Force | Out-Null
    }
}

##### Function to log messages
function Write-BackupLog {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [Parameter(Mandatory=$false)]
        [ValidateSet("INFO", "WARNING", "ERROR")]
        [string]$Level = "INFO"
    )
    
    $logMessage = "[$timestamp] [$Level] $Message"
    
    switch ($Level) {
        "INFO" { 
            Write-Host $logMessage -ForegroundColor Green
        }
        "WARNING" { 
            Write-Host $logMessage -ForegroundColor Yellow
        }
        "ERROR" { 
            Write-Host $logMessage -ForegroundColor Red
            ${script}:errorCount++
        }
    }
    
    Add-Content -Path $logFile -Value $logMessage
}

#-----------------------------------------------
##### Backup Functions
#-----------------------------------------------
function Backup-Directory {
    param(
        [Parameter(Mandatory=$true)]
        [string]$SourcePath,
        
        [Parameter(Mandatory=$true)]
        [string]$DestinationPath,
        
        [Parameter(Mandatory=$true)]
        [string]$Description,
        
        [Parameter(Mandatory=$false)]
        [string]$Type = "Directory",
        
        [Parameter(Mandatory=$false)]
        [string[]]$Exclusions = @()
    )
    
    try {
        if (-not (Test-Path $SourcePath)) {
            Write-BackupLog "Source path not found: $SourcePath" -Level "ERROR"
            return $false
        }
        
        ##### Create destination directory if it doesn't exist
        if (-not (Test-Path $DestinationPath)) {
            New-Item -Path $DestinationPath -ItemType Directory -Force | Out-Null
        }
        
        if ($Type -eq "File") {
            $fileName = Split-Path $SourcePath -Leaf
            $destFile = Join-Path $DestinationPath $fileName
            Copy-Item -Path $SourcePath -Destination $destFile -Force
            Write-BackupLog "Backed up file: $SourcePath -> $destFile"
            ${script}:backupCount++
            return $true
        }
        else {
            ##### For directories, create a compressed archive
            $dirName = Split-Path $SourcePath -Leaf
            $archiveName = "{0}-{1}.zip" -f $dirName, $dateStamp
            $destArchive = Join-Path $DestinationPath $archiveName
            
            ##### Build exclusion parameters
            $excludeParams = @()
            foreach ($exclusion in $Exclusions) {
                $excludeParams += "-Exclude"
                $excludeParams += $exclusion
            }
            
            ##### Use Compress-Archive to create the backup
            if ($Exclusions.Count -gt 0) {
                ##### Get items with exclusions
                $itemsToBackup = Get-ChildItem -Path $SourcePath -Recurse | 
                                 Where-Object { $item = $_; -not ($Exclusions | Where-Object { $item.FullName -like "*\$_*" }) }
                
                ##### Create temp directory
                $tempDir = Join-Path $CONFIG.BackupDirectory "temp-$timeStamp"
                New-Item -Path $tempDir -ItemType Directory -Force | Out-Null
                
                ##### Copy items to temp directory maintaining structure
                foreach ($item in $itemsToBackup) {
                    $relativePath = $item.FullName.Substring($SourcePath.Length + 1)
                    $destPath = Join-Path $tempDir $relativePath
                    
                    if ($item.PSIsContainer) {
                        if (-not (Test-Path $destPath)) {
                            New-Item -Path $destPath -ItemType Directory -Force | Out-Null
                        }
                    }
                    else {
                        $destParent = Split-Path $destPath -Parent
                        if (-not (Test-Path $destParent)) {
                            New-Item -Path $destParent -ItemType Directory -Force | Out-Null
                        }
                        Copy-Item -Path $item.FullName -Destination $destPath -Force
                    }
                }
                
                ##### Compress temp directory
                Compress-Archive -Path "$tempDir\*" -DestinationPath $destArchive -Force
                
                ##### Cleanup temp directory
                Remove-Item -Path $tempDir -Recurse -Force
            }
            else {
                Compress-Archive -Path "$SourcePath\*" -DestinationPath $destArchive -Force
            }
            
            Write-BackupLog "Backed up directory: $SourcePath -> $destArchive"
            ${script}:backupCount++
            return $true
        }
    }
    catch {
        Write-BackupLog "Error backing up $Description ($SourcePath): $_" -Level "ERROR"
        return $false
    }
}

function Remove-OldBackups {
    param(
        [Parameter(Mandatory=$true)]
        [string]$BackupPath,
        
        [Parameter(Mandatory=$true)]
        [int]$RetentionCount,
        
        [Parameter(Mandatory=$true)]
        [string]$BackupType
    )
    
    try {
        $backupFiles = Get-ChildItem -Path $BackupPath -File | Sort-Object LastWriteTime -Descending
        
        if ($backupFiles.Count -gt $RetentionCount) {
            $filesToRemove = $backupFiles | Select-Object -Skip $RetentionCount
            
            foreach ($file in $filesToRemove) {
                Remove-Item -Path $file.FullName -Force
                Write-BackupLog "Removed old $BackupType backup: $($file.Name)"
            }
        }
    }
    catch {
        Write-BackupLog "Error cleaning up old $BackupType backups: $_" -Level "ERROR"
    }
}

#-----------------------------------------------
##### Determine Backup Type
#-----------------------------------------------
function Get-BackupTypes {
    $currentDate = Get-Date
    $dayOfWeek = $currentDate.DayOfWeek
    $dayOfMonth = $currentDate.Day
    
    $backupTypes = @("Daily")
    
    ##### Check if it's Sunday (weekly backup)
    if ($dayOfWeek -eq "Sunday") {
        $backupTypes += "Weekly"
    }
    
    ##### Check if it's the 1st of the month (monthly backup)
    if ($dayOfMonth -eq 1) {
        $backupTypes += "Monthly"
    }
    
    return $backupTypes
}

#-----------------------------------------------
##### Main Backup Process
#-----------------------------------------------
try {
    Write-BackupLog "===== cFish.io Daily Backup - $timestamp ====="
    
    $backupTypes = Get-BackupTypes
    Write-BackupLog "Executing backup types: $($backupTypes -join ', ')"
    
    ##### Process each backup type
    foreach ($backupType in $backupTypes) {
        Write-BackupLog "Starting $backupType backup..."
        
        $backupConfig = $CONFIG.BackupSchedule[$backupType]
        $backupPath = Join-Path $CONFIG.BackupDirectory $backupType.ToLower()
        
        ##### Create directory for today's backup
        $todayBackupPath = Join-Path $backupPath $dateStamp
        if (-not (Test-Path $todayBackupPath)) {
            New-Item -Path $todayBackupPath -ItemType Directory -Force | Out-Null
        }
        
        ##### Backup each source
        foreach ($source in $backupConfig.Directories) {
            $sourcePath = $source.Path
            $description = $source.Description
            $type = if ($source.Type) { $source.Type } else { "Directory" }
            $exclusions = if ($source.Exclusions) { $source.Exclusions } else { @() }
            
            Backup-Directory -SourcePath $sourcePath -DestinationPath $todayBackupPath -Description $description -Type $type -Exclusions $exclusions
        }
        
        ##### Cleanup old backups
        Remove-OldBackups -BackupPath $backupPath -RetentionCount $backupConfig.Retention -BackupType $backupType
    }
    
    ##### Create backup summary
    Write-BackupLog "===== Backup Complete: $backupCount items backed up with $errorCount errors ====="
    
    ##### Update memory.md
    $memoryContent = @"
## Daily Backup System Execution ($dateStamp)
- ✅ Executed backup types: $($backupTypes -join ', ')
- ✅ Backed up $backupCount items successfully
- $(if ($errorCount -eq 0) { "✅" } else { "❌" }) Encountered $errorCount errors during backup
- ✅ Retained daily backups: $($CONFIG.BackupSchedule.Daily.Retention) days
- ✅ Retained weekly backups: $($CONFIG.BackupSchedule.Weekly.Retention) weeks
- ✅ Retained monthly backups: $($CONFIG.BackupSchedule.Monthly.Retention) months

_Updated $(Get-Date -Format "MM-dd-yyyy") | AI: Cursor (Claude 3.7 Sonnet)_

"@
    
    ##### Add to memory.md
    $memoryPath = "memory.md"
    if (Test-Path $memoryPath) {
        $existingContent = Get-Content $memoryPath -Raw
        $updatedContent = $memoryContent + $existingContent
        Set-Content -Path $memoryPath -Value $updatedContent
        Write-BackupLog "Updated memory.md with backup summary"
    }
    
    if ($errorCount -gt 0) {
        exit 1
    }
    else {
        exit 0
    }
}
catch {
    Write-BackupLog "Critical error during backup process: $_" -Level "ERROR"
    exit 1
} 
