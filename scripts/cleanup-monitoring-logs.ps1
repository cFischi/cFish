# Monitoring Log Cleanup Script
# Purpose: Performs log rotation and cleanup for monitoring system logs
# Created: 05-09-2025
# Updated: 05-09-2025

[CmdletBinding()]
param(
    [Parameter()]
    [string]$LogBasePath = "$PSScriptRoot\..\cursor\logs\monitoring",
    
    [Parameter()]
    [int]$Days = 7,
    
    [Parameter()]
    [switch]$PreserveAlertHistory = $true,
    
    [Parameter()]
    [switch]$CompressOldLogs = $true,
    
    [Parameter()]
    [switch]$WhatIf = $false
)

# Create log file for this cleanup operation
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$cleanupLogDir = Join-Path $LogBasePath "cleanup"
$logFile = Join-Path $cleanupLogDir "log-cleanup-$timestamp.log"

if (-not (Test-Path $cleanupLogDir)) {
    try {
        New-Item -Path $cleanupLogDir -ItemType Directory -Force | Out-Null
    }
    catch {
        Write-Error "Failed to create cleanup log directory: $($_.Exception.Message)"
        exit 1
    }
}

function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    $logTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$logTime] [$Level] $Message"
    
    Add-Content -Path $logFile -Value $logMessage -ErrorAction SilentlyContinue
    
    switch ($Level) {
        "ERROR" { Write-Host $logMessage -ForegroundColor Red }
        "WARNING" { Write-Host $logMessage -ForegroundColor Yellow }
        "SUCCESS" { Write-Host $logMessage -ForegroundColor Green }
        default { Write-Host $logMessage }
    }
}

function Compress-LogFiles {
    param (
        [string]$SourcePath,
        [datetime]$CutoffDate
    )
    
    try {
        $files = Get-ChildItem -Path $SourcePath -File | Where-Object {
            $_.LastWriteTime -lt $CutoffDate -and 
            $_.Extension -ne ".zip" -and
            (-not $PreserveAlertHistory -or $_.Name -ne "alert-history.json")
        }
        
        if ($files.Count -eq 0) {
            Write-Log "No files to compress in $SourcePath" -Level "INFO"
            return
        }
        
        $archiveDir = Join-Path $SourcePath "archives"
        if (-not (Test-Path $archiveDir)) {
            New-Item -Path $archiveDir -ItemType Directory -Force | Out-Null
            Write-Log "Created archive directory: $archiveDir" -Level "INFO"
        }
        
        $yearMonth = Get-Date $CutoffDate -Format "yyyy-MM"
        $archiveFile = Join-Path $archiveDir "logs-$yearMonth.zip"
        
        if ($WhatIf) {
            Write-Log "WhatIf: Would compress $($files.Count) files to $archiveFile" -Level "INFO"
        }
        else {
            $tempDir = Join-Path $env:TEMP "MonitorLogCompress_$(Get-Random)"
            New-Item -Path $tempDir -ItemType Directory -Force | Out-Null
            
            foreach ($file in $files) {
                Copy-Item -Path $file.FullName -Destination $tempDir
            }
            
            if (Test-Path $archiveFile) {
                # Append to existing archive
                Compress-Archive -Path "$tempDir\*" -DestinationPath $archiveFile -Update
            }
            else {
                # Create new archive
                Compress-Archive -Path "$tempDir\*" -DestinationPath $archiveFile
            }
            
            # Clean up temp directory
            Remove-Item -Path $tempDir -Recurse -Force
            
            Write-Log "Compressed $($files.Count) files to $archiveFile" -Level "SUCCESS"
        }
    }
    catch {
        $errorMessage = $_.Exception.Message
        Write-Log "Error compressing log files in $SourcePath`:`n$errorMessage" -Level "ERROR"
    }
}

function Remove-OldLogFiles {
    param (
        [string]$SourcePath,
        [datetime]$CutoffDate
    )
    
    try {
        $files = Get-ChildItem -Path $SourcePath -File | Where-Object {
            $_.LastWriteTime -lt $CutoffDate -and 
            (-not $PreserveAlertHistory -or $_.Name -ne "alert-history.json")
        }
        
        if ($files.Count -eq 0) {
            Write-Log "No old files to remove in $SourcePath" -Level "INFO"
            return
        }
        
        if ($WhatIf) {
            Write-Log "WhatIf: Would remove $($files.Count) files from $SourcePath" -Level "INFO"
            foreach ($file in $files) {
                Write-Log "WhatIf: Would remove $($file.FullName) (Last modified: $($file.LastWriteTime))" -Level "INFO"
            }
        }
        else {
            foreach ($file in $files) {
                Remove-Item -Path $file.FullName -Force
                Write-Log "Removed $($file.FullName) (Last modified: $($file.LastWriteTime))" -Level "INFO"
            }
            Write-Log "Removed $($files.Count) files from $SourcePath" -Level "SUCCESS"
        }
    }
    catch {
        $errorMessage = $_.Exception.Message
        Write-Log "Error removing old log files from $SourcePath`:`n$errorMessage" -Level "ERROR"
    }
}

# Main execution starts here
Write-Log "Starting monitoring log cleanup" -Level "INFO"
Write-Log "Parameters: Days=$Days, PreserveAlertHistory=$PreserveAlertHistory, CompressOldLogs=$CompressOldLogs, WhatIf=$WhatIf" -Level "INFO"

$cutoffDate = (Get-Date).AddDays(-$Days)
Write-Log "Cutoff date: $cutoffDate" -Level "INFO"

# Get all subdirectories for log cleanup
$logDirs = @($LogBasePath)
Get-ChildItem -Path $LogBasePath -Directory | ForEach-Object {
    $logDirs += $_.FullName
}

# Log directories to process
Write-Log "Log directories to process: $($logDirs.Count)" -Level "INFO"
foreach ($dir in $logDirs) {
    Write-Log "  - $dir" -Level "INFO"
}

# Process each directory
foreach ($dir in $logDirs) {
    Write-Log "Processing directory: $dir" -Level "INFO"
    
    if ($CompressOldLogs) {
        Write-Log "Compressing old log files in $dir" -Level "INFO"
        Compress-LogFiles -SourcePath $dir -CutoffDate $cutoffDate
    }
    
    Write-Log "Removing old log files in $dir" -Level "INFO"
    Remove-OldLogFiles -SourcePath $dir -CutoffDate $cutoffDate
}

# Clean up old compressed archives (keep last 3 months)
if ($CompressOldLogs) {
    $archiveDirs = Get-ChildItem -Path $LogBasePath -Directory -Recurse | Where-Object { $_.Name -eq "archives" }
    
    foreach ($archiveDir in $archiveDirs) {
        Write-Log "Cleaning up old archives in $($archiveDir.FullName)" -Level "INFO"
        
        $archiveFiles = Get-ChildItem -Path $archiveDir.FullName -Filter "logs-*.zip" | Sort-Object LastWriteTime -Descending
        
        if ($archiveFiles.Count -gt 3) {
            $oldArchives = $archiveFiles | Select-Object -Skip 3
            
            if ($WhatIf) {
                Write-Log "WhatIf: Would remove $($oldArchives.Count) old archives" -Level "INFO"
                foreach ($archive in $oldArchives) {
                    Write-Log "WhatIf: Would remove $($archive.FullName)" -Level "INFO"
                }
            }
            else {
                foreach ($archive in $oldArchives) {
                    Remove-Item -Path $archive.FullName -Force
                    Write-Log "Removed old archive: $($archive.FullName)" -Level "INFO"
                }
                Write-Log "Removed $($oldArchives.Count) old archives" -Level "SUCCESS"
            }
        }
        else {
            Write-Log "No old archives to remove in $($archiveDir.FullName)" -Level "INFO"
        }
    }
}

# Generate statistics
$remainingFiles = Get-ChildItem -Path $LogBasePath -File -Recurse | Measure-Object
$remainingSize = Get-ChildItem -Path $LogBasePath -File -Recurse | Measure-Object -Property Length -Sum

Write-Log "Cleanup complete" -Level "SUCCESS"
Write-Log "Remaining log files: $($remainingFiles.Count)" -Level "INFO"
Write-Log "Total log size: $([math]::Round($remainingSize.Sum / 1MB, 2)) MB" -Level "INFO"

exit 0 