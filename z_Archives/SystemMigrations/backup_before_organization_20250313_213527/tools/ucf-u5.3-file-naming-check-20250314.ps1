#!/usr/bin/env pwsh
# ucf-u5.3-file-naming-check-20250314.ps1
# File naming convention checker for cFish.io
# Following UcFish digital organization standards
# Department: U5 - Data Management
# Function: 3 - File Management

#-----------------------------------------------
# Configuration
#-----------------------------------------------
$CONFIG = @{
    NamingPattern = "^(ucf|tyf|fh|ucw|uz|fe|ty)-u[1-7]\.[1-9]-[a-z0-9-]+-\d{8}\.[a-z]+$"
    ExcludedDirs = @(
        "node_modules",
        ".git",
        "temp",
        "backups"
    )
    ExcludedExtensions = @(
        ".log", 
        ".tmp",
        ".bak",
        ".vs"
    )
    LogFile = "logs\file-naming-check-$(Get-Date -Format 'yyyyMMdd').log"
    FixMode = $false  ##### Set to true to automatically rename files
    ExcludedPrefixes = @(
        "README",
        "LICENSE",
        "package",
        "webpack",
        "tsconfig",
        "node_modules",
        ".git",
        "temp-"
    )
}

#-----------------------------------------------
##### Initialize
#-----------------------------------------------
$ErrorActionPreference = "Stop"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$complianceIssues = @()
$totalFiles = 0
$nonCompliantFiles = 0

##### Create log directory if it doesn't exist
$logDir = Split-Path -Parent $CONFIG.LogFile
if (-not (Test-Path $logDir)) {
    New-Item -Path $logDir -ItemType Directory -Force | Out-Null
}

#-----------------------------------------------
##### Functions
#-----------------------------------------------
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    ##### Write to console with color
    switch ($Level) {
        "ERROR" { Write-Host $logMessage -ForegroundColor Red }
        "WARNING" { Write-Host $logMessage -ForegroundColor Yellow }
        "SUCCESS" { Write-Host $logMessage -ForegroundColor Green }
        default { Write-Host $logMessage }
    }
    
    ##### Write to log file
    Add-Content -Path $CONFIG.LogFile -Value $logMessage
}

function Test-FileNameCompliance {
    param(
        [string]$FilePath
    )
    
    $fileName = Split-Path -Leaf $FilePath
    $extension = [System.IO.Path]::GetExtension($fileName).ToLower()
    
    ##### Skip excluded extensions
    if ($CONFIG.ExcludedExtensions -contains $extension) {
        return $true
    }
    
    ##### Skip excluded file prefixes
    foreach ($prefix in $CONFIG.ExcludedPrefixes) {
        if ($fileName.StartsWith($prefix)) {
            return $true
        }
    }
    
    ##### Check if the file name matches the pattern
    if ($fileName -match $CONFIG.NamingPattern) {
        return $true
    }
    
    return $false
}

function Get-SuggestedFileName {
    param(
        [string]$FilePath
    )
    
    $fileName = Split-Path -Leaf $FilePath
    $extension = [System.IO.Path]::GetExtension($fileName).ToLower()
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($fileName)
    
    ##### Default values
    $companyPrefix = "ucf"
    $departmentNumber = "u5"
    $functionNumber = "3"
    $taskIdentifier = $baseName.ToLower() -replace "[^a-z0-9-]", "-"
    $date = Get-Date -Format "yyyyMMdd"
    
    ##### Determine department based on file path
    if ($FilePath -match "U([1-7])-") {
        $departmentNumber = "u$($matches[1])"
    }
    
    ##### Create the new file name
    $newFileName = "$companyPrefix-$departmentNumber.$functionNumber-$taskIdentifier-$date$extension"
    
    return $newFileName
}

function Rename-NonCompliantFile {
    param(
        [string]$FilePath
    )
    
    $directoryPath = Split-Path -Parent $FilePath
    $newFileName = Get-SuggestedFileName -FilePath $FilePath
    $newFilePath = Join-Path -Path $directoryPath -ChildPath $newFileName
    
    try {
        if (Test-Path $newFilePath) {
            $uniqueId = Get-Random -Minimum 1000 -Maximum 9999
            $newFileNameBase = [System.IO.Path]::GetFileNameWithoutExtension($newFileName)
            $newFileExt = [System.IO.Path]::GetExtension($newFileName)
            $newFileName = "$newFileNameBase-$uniqueId$newFileExt"
            $newFilePath = Join-Path -Path $directoryPath -ChildPath $newFileName
        }
        
        Rename-Item -Path $FilePath -NewName $newFileName -Force
        Write-Log "Renamed file: $FilePath -> $newFileName" -Level "SUCCESS"
        return $true
    }
    catch {
        Write-Log "Failed to rename file: $FilePath. Error: $_" -Level "ERROR"
        return $false
    }
}

#-----------------------------------------------
##### Main process
#-----------------------------------------------
Write-Log "Starting file naming convention check" -Level "INFO"

##### Get all files recursively, excluding specified directories
$allFiles = Get-ChildItem -Path "." -Recurse -File | Where-Object {
    $file = $_
    $exclude = $false
    
    foreach ($dir in $CONFIG.ExcludedDirs) {
        if ($file.FullName -like "*\$dir\*") {
            $exclude = $true
            break
        }
    }
    
    return -not $exclude
}

$totalFiles = $allFiles.Count
Write-Log "Checking naming conventions for $totalFiles files" -Level "INFO"

foreach ($file in $allFiles) {
    $isCompliant = Test-FileNameCompliance -FilePath $file.FullName
    
    if (-not $isCompliant) {
        $nonCompliantFiles++
        $suggestedName = Get-SuggestedFileName -FilePath $file.FullName
        
        $complianceIssues += [PSCustomObject]@{
            Path = $file.FullName
            CurrentName = $file.Name
            SuggestedName = $suggestedName
        }
        
        Write-Log "Non-compliant file: $($file.FullName)" -Level "WARNING"
        Write-Log "  Suggested name: $suggestedName" -Level "INFO"
        
        if ($CONFIG.FixMode) {
            Rename-NonCompliantFile -FilePath $file.FullName
        }
    }
}

##### Output summary
$complianceRate = 100 - [math]::Round(($nonCompliantFiles / $totalFiles) * 100, 2)
Write-Log "File naming compliance check complete" -Level "INFO"
Write-Log "Total files checked: $totalFiles" -Level "INFO"
Write-Log "Non-compliant files: $nonCompliantFiles" -Level "WARNING"
Write-Log "Compliance rate: $complianceRate%" -Level "INFO"

##### Create report file
$reportFile = "logs\file-naming-report-$(Get-Date -Format 'yyyyMMdd').csv"
$complianceIssues | Export-Csv -Path $reportFile -NoTypeInformation

Write-Log "Detailed report saved to: $reportFile" -Level "SUCCESS"

if ($CONFIG.FixMode) {
    Write-Log "Fix mode was enabled. Non-compliant files were renamed." -Level "INFO"
} else {
    Write-Log "Fix mode was disabled. To automatically rename files, set FixMode to true." -Level "INFO"
    Write-Log "Manual review recommended before enabling Fix mode." -Level "WARNING"
}

Write-Log "To enable automatic renaming, run this script with the -FixMode parameter" -Level "INFO" 
