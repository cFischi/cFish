# update-command-chaining.ps1
# Purpose: Update command chaining syntax from && to ; in PowerShell scripts
# Created: 2025-03-13

# Set preferences
$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

##### Initialize variables
$logFile = "logs/command-chaining-update-$(Get-Date -Format 'yyyyMMdd').log"
$scriptsDir = "."
$backupDir = "../backups/command-chaining-update"

##### Ensure directories exist
$logDir = Split-Path -Parent $logFile
if (-not (Test-Path $logDir)) {
    New-Item -Path $logDir -ItemType Directory -Force | Out-Null
}

if (-not (Test-Path $backupDir)) {
    New-Item -Path $backupDir -ItemType Directory -Force | Out-Null
}

##### Function to write to log file and console
function Write-Log {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [Parameter(Mandatory=$false)]
        [ValidateSet("INFO", "SUCCESS", "WARNING", "ERROR")]
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    Add-Content -Path $logFile -Value $logMessage
    
    switch ($Level) {
        "INFO" { Write-Host $logMessage -ForegroundColor Gray }
        "SUCCESS" { Write-Host $logMessage -ForegroundColor Green }
        "WARNING" { Write-Host $logMessage -ForegroundColor Yellow }
        "ERROR" { Write-Host $logMessage -ForegroundColor Red }
        default { Write-Host $logMessage }
    }
}

##### Function to backup a file
function Backup-File {
    param (
        [Parameter(Mandatory=$true)]
        [string]$FilePath
    )
    
    try {
        $fileName = Split-Path -Leaf $FilePath
        $backupPath = Join-Path -Path $backupDir -ChildPath $fileName
        Copy-Item -Path $FilePath -Destination $backupPath -Force
        Write-Log "Created backup: $backupPath" "INFO"
        return $true
    }
    catch {
        Write-Log "Failed to create backup for $FilePath : $_" "ERROR"
        return $false
    }
}

##### Function to update command chaining in a file
function Update-CommandChaining {
    param (
        [Parameter(Mandatory=$true)]
        [string]$FilePath
    )
    
    try {
        $content = Get-Content -Path $FilePath -Raw
        
        ##### Check if file contains && command chaining
        if ($content -match '&&') {
            Write-Log "Found && in $FilePath" "INFO"
            
            ##### Create backup before modifying
            if (-not (Backup-File -FilePath $FilePath)) {
                return
            }
            
            ##### Replace && with ; for command chaining
            $updatedContent = $content -replace '(?<=\s)&&(?=\s)', ';'
            Set-Content -Path $FilePath -Value $updatedContent
            Write-Log "Updated command chaining in $FilePath" "SUCCESS"
        }
    }
    catch {
        Write-Log "Error processing $FilePath : $_" "ERROR"
    }
}

##### Main execution
Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "      Updating Command Chaining Syntax in PowerShell Scripts      " -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host ""

Write-Log "Starting command chaining syntax update..." "INFO"

##### Get all PowerShell and batch files
$files = Get-ChildItem -Path $scriptsDir -Include "*.ps1","*.bat" -Recurse
$fileCount = if ($files) { $files.Count } else { 0 }
Write-Log "Found $fileCount script files to process" "INFO"

foreach ($file in $files) {
    Write-Log "Processing $($file.Name)..." "INFO"
    Update-CommandChaining -FilePath $file.FullName
}

Write-Log "Command chaining syntax update completed" "SUCCESS"
Write-Host "`nBackups of modified files are stored in: $backupDir" -ForegroundColor Yellow
Write-Host "Review the log file for details: $logFile" -ForegroundColor Yellow 

