# Git-Backup.ps1
# A script to backup recently modified files and commit them to git

# Script parameters
param (
    [string]$TimePeriod = "today",  # Default to files modified today
    [string]$BackupExtension = "bak",  # Default backup extension
    [switch]$Verbose = $false  # Verbose output flag
)

# Function to write verbose output
function Write-VerboseOutput {
    param (
        [string]$Message
    )
    
    if ($Verbose) {
        Write-Host $Message -ForegroundColor Cyan
    }
}

# Function to check if git is installed
function Test-GitInstalled {
    try {
        $gitVersion = git --version
        Write-VerboseOutput "Git is installed: $gitVersion"
        return $true
    }
    catch {
        Write-Host "Git is not installed or not in PATH. Please install Git." -ForegroundColor Red
        return $false
    }
}

# Function to ensure we're in a git repository
function Initialize-GitRepo {
    # Check if current directory is a git repository
    if (-not (Test-Path -Path ".git" -PathType Container)) {
        Write-Host "Initializing new git repository..." -ForegroundColor Yellow
        git init
        
        # Create a .gitignore file if it doesn't exist
        if (-not (Test-Path -Path ".gitignore")) {
            Write-Host "Creating .gitignore file..." -ForegroundColor Yellow
            "*.bak" | Out-File -FilePath ".gitignore"
            git add .gitignore
            git commit -m "Initial commit: Add .gitignore"
        }
    }
    else {
        Write-VerboseOutput "Git repository already exists"
    }
}

# Function to find recently modified files
function Get-RecentlyModifiedFiles {
    param (
        [string]$TimePeriod
    )
    
    $currentDate = Get-Date
    
    switch ($TimePeriod) {
        "today" {
            $cutoffDate = $currentDate.Date
        }
        "yesterday" {
            $cutoffDate = $currentDate.Date.AddDays(-1)
        }
        "week" {
            $cutoffDate = $currentDate.Date.AddDays(-7)
        }
        "hour" {
            $cutoffDate = $currentDate.AddHours(-1)
        }
        default {
            # Try to parse as hours if it's a number
            if ($TimePeriod -match '^\d+$') {
                $hours = [int]$TimePeriod
                $cutoffDate = $currentDate.AddHours(-$hours)
            }
            else {
                Write-Host "Unrecognized time period: $TimePeriod. Using 'today'." -ForegroundColor Yellow
                $cutoffDate = $currentDate.Date
            }
        }
    }
    
    Write-VerboseOutput "Finding files modified since: $cutoffDate"
    
    # Get all files modified since the cutoff date, excluding .bak files
    $modifiedFiles = Get-ChildItem -Recurse -File | 
                     Where-Object { 
                         $_.LastWriteTime -ge $cutoffDate -and 
                         $_.Extension -ne ".bak" -and
                         -not $_.FullName.Contains("\.git\")
                     }
    
    return $modifiedFiles
}

# Function to create backup files
function Backup-Files {
    param (
        [System.IO.FileInfo[]]$Files,
        [string]$Extension
    )
    
    $backupFiles = @()
    
    foreach ($file in $Files) {
        $backupPath = "$($file.FullName).$Extension"
        Write-VerboseOutput "Creating backup: $backupPath"
        
        Copy-Item -Path $file.FullName -Destination $backupPath -Force
        $backupFiles += $backupPath
    }
    
    return $backupFiles
}

# Function to commit files to git
function Commit-Files {
    param (
        [System.IO.FileInfo[]]$Files
    )
    
    if ($Files.Count -eq 0) {
        Write-Host "No files to commit." -ForegroundColor Yellow
        return
    }
    
    foreach ($file in $Files) {
        $relativePath = Resolve-Path -Path $file.FullName -Relative
        Write-VerboseOutput "Adding to git: $relativePath"
        git add $relativePath
    }
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $commitMessage = "Automatic backup: $timestamp"
    
    Write-Host "Committing $($Files.Count) files with message: '$commitMessage'" -ForegroundColor Green
    git commit -m $commitMessage
}

# Main script execution
if (-not (Test-GitInstalled)) {
    exit 1
}

Initialize-GitRepo

Write-Host "Finding files modified $TimePeriod..." -ForegroundColor Blue
$modifiedFiles = Get-RecentlyModifiedFiles -TimePeriod $TimePeriod

if ($modifiedFiles.Count -eq 0) {
    Write-Host "No files were modified $TimePeriod." -ForegroundColor Yellow
    exit 0
}

Write-Host "Found $($modifiedFiles.Count) modified files" -ForegroundColor Green
if ($Verbose) {
    $modifiedFiles | ForEach-Object { Write-Host "- $($_.FullName)" -ForegroundColor Gray }
}

Write-Host "Creating .bak backups..." -ForegroundColor Blue
$backupFiles = Backup-Files -Files $modifiedFiles -Extension $BackupExtension

Write-Host "Committing files to git..." -ForegroundColor Blue
Commit-Files -Files $modifiedFiles

Write-Host "Operation completed successfully!" -ForegroundColor Green 