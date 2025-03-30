# tYDiSync~ Prioritized Synchronization Script
# This script prioritizes JSON -> MD conversion first, then MD -> JSON

$ErrorActionPreference = "Continue"
$timestamp = Get-Date -Format "yyyy-MM-dd-HHmmss"
$logFile = "logs/prioritized-sync-$timestamp.log"
$backupDir = "backups/prioritized-sync-$timestamp"

##### Create logs directory if it doesn't exist
if (-not (Test-Path "logs")) {
    New-Item -Path "logs" -ItemType Directory | Out-Null
}

##### Create backup directory
if (-not (Test-Path $backupDir)) {
    New-Item -Path $backupDir -ItemType Directory -Force | Out-Null
    Write-Host "Created backup directory: $backupDir" -ForegroundColor Green
}

##### Helper function to write to log file and console
function Write-Log {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [Parameter(Mandatory=$false)]
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    ##### Write to log file
    Add-Content -Path $logFile -Value $logMessage
    
    ##### Write to console with color based on level
    switch ($Level) {
        "INFO" { Write-Host $logMessage -ForegroundColor White }
        "SUCCESS" { Write-Host $logMessage -ForegroundColor Green }
        "WARNING" { Write-Host $logMessage -ForegroundColor Yellow }
        "ERROR" { Write-Host $logMessage -ForegroundColor Red }
        default { Write-Host $logMessage }
    }
}

##### Helper function to create backup of a file
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

##### Print banner
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  tYDiSync~ - Prioritized JSON/MD Synchronization Script  " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""
Write-Log "Starting prioritized synchronization with JSON to MD as highest priority"
Write-Log "Backup directory: $backupDir" "INFO"

##### Directories to process - add more if needed
$directories = @(".", "docs", "sync-system", "scripts", "web", "tools")
Write-Log "Directories to process: $($directories -join ', ')"

##### Statistics tracking
$stats = @{
    JsonToMdSuccess = 0
    JsonToMdFailed = 0
    MdToJsonSuccess = 0
    MdToJsonFailed = 0
    SkippedFiles = 0
    BackedUpFiles = 0
    TotalFiles = 0
}

##### WordPress exclusion patterns for better filtering
$wpExclusionPatterns = @(
    "wp-admin",
    "wp-includes",
    "wp-content\\plugins\\akismet",
    "wp-content\\plugins\\hello\.php",
    "wp-content\\upgrade",
    "wp-content\\plugins\\gutenberg",
    "node_modules",
    "\.git",
    "package-lock\.json",
    "\.nosync"
)

##### Function to check if a file matches WordPress exclusion patterns
function Test-ShouldExcludeFile {
    param (
        [Parameter(Mandatory=$true)]
        [string]$FilePath
    )
    
    foreach ($pattern in $wpExclusionPatterns) {
        if ($FilePath -match $pattern) {
            return $true
        }
    }
    
    return $false
}

##### Function to convert a JSON file to MD
function Convert-JsonToMd {
    param (
        [Parameter(Mandatory=$true)]
        [string]$JsonFile
    )
    
    try {
        Write-Log "Converting JSON to MD: $JsonFile" "INFO"
        $stats.TotalFiles++
        
        ##### Exclusion check
        if (Test-ShouldExcludeFile -FilePath $JsonFile) {
            Write-Log "Skipping excluded file: $JsonFile" "INFO"
            $stats.SkippedFiles++
            return
        }

        ##### Prepare the expected MD file path to back it up if it exists
        $mdFile = $JsonFile -replace '\.json$', '.md'
        if (Test-Path $mdFile) {
            if (Backup-File -FilePath $mdFile) {
                $stats.BackedUpFiles++
                Write-Log "Backed up existing MD file: $mdFile" "INFO"
            }
        }

        ##### Execute the conversion using tydisync.js
        $output = node "sync-system\core\tydisync.js" --convert $JsonFile --verbose 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Log "Successfully converted: $JsonFile" "SUCCESS"
            $stats.JsonToMdSuccess++
        }
        else {
            Write-Log "Failed to convert: $JsonFile. Error: $output" "ERROR"
            $stats.JsonToMdFailed++
        }
    }
    catch {
        Write-Log "Exception while converting $JsonFile to MD: $_" "ERROR"
        $stats.JsonToMdFailed++
    }
}

##### Function to convert a MD file to JSON
function Convert-MdToJson {
    param (
        [Parameter(Mandatory=$true)]
        [string]$MdFile
    )
    
    try {
        Write-Log "Converting MD to JSON: $MdFile" "INFO"
        $stats.TotalFiles++
        
        ##### Exclusion check
        if (Test-ShouldExcludeFile -FilePath $MdFile) {
            Write-Log "Skipping excluded file: $MdFile" "INFO"
            $stats.SkippedFiles++
            return
        }

        ##### Execute the conversion using tydisync.js
        $output = node "sync-system\core\tydisync.js" --convert $MdFile --verbose 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Log "Successfully converted: $MdFile" "SUCCESS"
            $stats.MdToJsonSuccess++
        }
        else {
            Write-Log "Failed to convert: $MdFile. Error: $output" "ERROR"
            $stats.MdToJsonFailed++
        }
    }
    catch {
        Write-Log "Exception while converting $MdFile to JSON: $_" "ERROR"
        $stats.MdToJsonFailed++
    }
}

##### PHASE 1: Process all JSON files first (HIGHEST PRIORITY)
Write-Log "============= PHASE 1: JSON TO MD CONVERSION (HIGHEST PRIORITY) =============" "INFO"

foreach ($dir in $directories) {
    if (Test-Path $dir) {
        Write-Log "Scanning directory for JSON files: $dir" "INFO"
        
        try {
            ##### Get all JSON files in the directory and its subdirectories
            $jsonFiles = Get-ChildItem -Path $dir -Filter "*.json" -Recurse -ErrorAction Continue
            Write-Log "Found $($jsonFiles.Count) JSON files in $dir" "INFO"
            
            ##### Process each JSON file
            foreach ($file in $jsonFiles) {
                Convert-JsonToMd -JsonFile $file.FullName
                ##### Add a small delay to prevent overwhelming the system
                Start-Sleep -Milliseconds 100
            }
        }
        catch {
            Write-Log "Error scanning directory $dir for JSON files: $_" "ERROR"
        }
    }
    else {
        Write-Log "Directory does not exist: $dir" "WARNING"
    }
}

##### PHASE 2: Process all MD files after JSON files are processed
Write-Log "============= PHASE 2: MD TO JSON CONVERSION =============" "INFO"

foreach ($dir in $directories) {
    if (Test-Path $dir) {
        Write-Log "Scanning directory for MD files: $dir" "INFO"
        
        try {
            ##### Get all MD files in the directory and its subdirectories
            $mdFiles = Get-ChildItem -Path $dir -Filter "*.md" -Recurse -ErrorAction Continue
            Write-Log "Found $($mdFiles.Count) MD files in $dir" "INFO"
            
            ##### Process each MD file
            foreach ($file in $mdFiles) {
                Convert-MdToJson -MdFile $file.FullName
                ##### Add a small delay to prevent overwhelming the system
                Start-Sleep -Milliseconds 100
            }
        }
        catch {
            Write-Log "Error scanning directory $dir for MD files: $_" "ERROR"
        }
    }
    else {
        Write-Log "Directory does not exist: $dir" "WARNING"
    }
}

##### Final Summary
Write-Log "============= SYNCHRONIZATION COMPLETE =============" "INFO"
Write-Log "Total files processed: $($stats.TotalFiles)" "INFO"
Write-Log "JSON → MD Successful: $($stats.JsonToMdSuccess)" "SUCCESS"
Write-Log "JSON → MD Failed: $($stats.JsonToMdFailed)" "WARNING"
Write-Log "MD → JSON Successful: $($stats.MdToJsonSuccess)" "SUCCESS"
Write-Log "MD → JSON Failed: $($stats.MdToJsonFailed)" "WARNING"
Write-Log "Files backed up: $($stats.BackedUpFiles)" "INFO"
Write-Log "Skipped files: $($stats.SkippedFiles)" "INFO"
Write-Log "Log file: $logFile" "INFO"
Write-Log "Backup directory: $backupDir" "INFO"

Write-Host ""
Write-Host "===========================================================" -ForegroundColor Cyan
Write-Host "  Prioritized Synchronization Complete                    " -ForegroundColor Cyan
Write-Host "===========================================================" -ForegroundColor Cyan 
