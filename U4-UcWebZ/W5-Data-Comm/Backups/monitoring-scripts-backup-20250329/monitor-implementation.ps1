# monitor-implementation.ps1
# Script to monitor cFish.io Digital Organization System implementation progress
# Created: 2025-03-14

# Set strict mode to catch common scripting mistakes
Set-StrictMode -Version Latest

# Set error action preference to stop on errors
$ErrorActionPreference = "Stop"

##### Define base path (current directory)
$basePath = Get-Location

##### Define log file path
$logFile = Join-Path $basePath "ucf-u5.1-implementation-monitoring-$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

##### Function to log messages with timestamps
function Write-Log {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet("Info", "Warning", "Error", "Success", "Progress")]
        [string]$Level = "Info"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    ##### Set color based on log level
    switch ($Level) {
        "Info" { $color = "White" }
        "Warning" { $color = "Yellow" }
        "Error" { $color = "Red" }
        "Success" { $color = "Green" }
        "Progress" { $color = "Cyan" }
        default { $color = "White" }
    }
    
    ##### Output to console
    Write-Host $logMessage -ForegroundColor $color
    
    ##### Output to log file
    $logMessage | Out-File -FilePath $logFile -Append
}

##### Function to check directory structure
function Check-DirectoryStructure {
    Write-Log -Message "Checking directory structure..." -Level "Progress"
    
    $departments = @{
        "U1-Administration" = @("Planning", "Finance", "Legal", "HR", "Policies")
        "U2-Research" = @("Projects", "Analysis", "Competitive", "User-Feedback", "Market-Trends")
        "U3-Operations" = @("SOP", "Maintenance", "Monitoring", "Support", "Incidents")
        "U4-Production" = @("WordPress", "Design", "Content", "Media", "Releases")
        "U5-Data" = @("Analytics", "Backups", "Migrations", "Reports", "Synchronization")
        "U6-Marketing" = @("Campaigns", "Social-Media", "Assets", "SEO", "Analytics")
        "U7-Systems" = @("Infrastructure", "Development", "Integrations", "Security", "Tools")
    }
    
    $supportDirs = @("_Resources", "_Archives", "Documentation")
    
    $missingDirs = @()
    $extraDirs = @()
    
    ##### Check main UcF directories
    foreach ($dept in $departments.Keys) {
        $deptPath = Join-Path $basePath $dept
        if (Test-Path -Path $deptPath -PathType Container) {
            Write-Log -Message "Department directory exists: $dept" -Level "Success"
            
            ##### Check subdirectories
            foreach ($subDir in $departments[$dept]) {
                $subDirPath = Join-Path $deptPath $subDir
                if (Test-Path -Path $subDirPath -PathType Container) {
                    Write-Log -Message "Subdirectory exists: $dept\$subDir" -Level "Success"
                }
                else {
                    Write-Log -Message "Missing subdirectory: $dept\$subDir" -Level "Error"
                    $missingDirs += "$dept\$subDir"
                }
            }
        }
        else {
            Write-Log -Message "Missing department directory: $dept" -Level "Error"
            $missingDirs += $dept
        }
    }
    
    ##### Check support directories
    foreach ($dir in $supportDirs) {
        $dirPath = Join-Path $basePath $dir
        if (Test-Path -Path $dirPath -PathType Container) {
            Write-Log -Message "Support directory exists: $dir" -Level "Success"
        }
        else {
            Write-Log -Message "Missing support directory: $dir" -Level "Error"
            $missingDirs += $dir
        }
    }
    
    return @{
        MissingDirectories = $missingDirs
        ExtraDirectories = $extraDirs
        IsValid = ($missingDirs.Count -eq 0)
    }
}

##### Function to check for loose files
function Check-LooseFiles {
    Write-Log -Message "Checking for loose files..." -Level "Progress"
    
    $excludeFiles = @(
        "organize-cfish-directory-structure.ps1",
        "organize-cfish-directory.bat",
        "verify-directory-structure.ps1",
        "verify-directory-structure.bat",
        "monitor-implementation.ps1",
        "*.log",
        ".gitignore",
        "README.md"
    )
    
    $looseFiles = Get-ChildItem -Path $basePath -File | Where-Object {
        $exclude = $false
        foreach ($pattern in $excludeFiles) {
            if ($_.Name -like $pattern) {
                $exclude = $true
                break
            }
        }
        -not $exclude
    }
    
    if ($looseFiles.Count -gt 0) {
        Write-Log -Message "Found $($looseFiles.Count) loose files in root directory" -Level "Warning"
        foreach ($file in $looseFiles) {
            Write-Log -Message "Loose file: $($file.Name)" -Level "Warning"
        }
    }
    else {
        Write-Log -Message "No loose files found in root directory" -Level "Success"
    }
    
    return $looseFiles
}

##### Function to check backup status
function Check-BackupStatus {
    Write-Log -Message "Checking backup status..." -Level "Progress"
    
    $backupDirs = Get-ChildItem -Path $basePath -Directory | Where-Object { $_.Name -like "backup_before_organization_*" }
    
    if ($backupDirs.Count -gt 0) {
        Write-Log -Message "Found $($backupDirs.Count) backup directories" -Level "Success"
        foreach ($backup in $backupDirs) {
            Write-Log -Message "Backup directory: $($backup.Name)" -Level "Info"
        }
    }
    else {
        Write-Log -Message "No backup directories found" -Level "Warning"
    }
    
    return $backupDirs
}

##### Function to check documentation status
function Check-DocumentationStatus {
    Write-Log -Message "Checking documentation status..." -Level "Progress"
    
    $requiredDocs = @(
        "memory.md",
        "changelog.md",
        "ucf-u5.1-digital-organization-comprehensive-implementation-20250314.md",
        "ucf-u5.1-digital-organization-comprehensive-implementation-20250314.json",
        "ucf-u5.1-digital-organization-presentation-20250314.md",
        "ucf-u5.1-digital-organization-presentation-20250314.json"
    )
    
    $missingDocs = @()
    
    foreach ($doc in $requiredDocs) {
        $docPath = Join-Path $basePath $doc
        if (Test-Path -Path $docPath -PathType Leaf) {
            Write-Log -Message "Document exists: $doc" -Level "Success"
        }
        else {
            Write-Log -Message "Missing document: $doc" -Level "Error"
            $missingDocs += $doc
        }
    }
    
    return @{
        MissingDocuments = $missingDocs
        IsValid = ($missingDocs.Count -eq 0)
    }
}

##### Function to generate progress report
function Generate-ProgressReport {
    param (
        [Parameter(Mandatory = $true)]
        [hashtable]$DirectoryResults,
        
        [Parameter(Mandatory = $true)]
        [array]$LooseFiles,
        
        [Parameter(Mandatory = $true)]
        [array]$BackupDirs,
        
        [Parameter(Mandatory = $true)]
        [hashtable]$DocumentationResults
    )
    
    Write-Log -Message "Generating progress report..." -Level "Progress"
    
    $reportFile = Join-Path $basePath "ucf-u5.1-implementation-progress-$(Get-Date -Format 'yyyyMMdd_HHmmss').md"
    
    $report = @"
##### cFish.io Digital Organization System - Implementation Progress Report

**Date:** $(Get-Date -Format "yyyy-MM-dd")
**Time:** $(Get-Date -Format "HH:mm:ss")

###### Overall Status

Implementation Status: **$(if ($DirectoryResults.IsValid) { "IN PROGRESS" } else { "NEEDS ATTENTION" })**

####### Directory Structure
"@
    
    if ($DirectoryResults.MissingDirectories.Count -eq 0) {
        $report += "`n- ✅ All required directories are present"
    }
    else {
        $report += "`n- ❌ Missing required directories: $($DirectoryResults.MissingDirectories.Count)"
        foreach ($dir in $DirectoryResults.MissingDirectories) {
            $report += "`n  - $dir"
        }
    }
    
    $report += "`n`n####### Loose Files"
    
    if ($LooseFiles.Count -eq 0) {
        $report += "`n- ✅ No loose files found in root directory"
    }
    else {
        $report += "`n- ⚠️ Found $($LooseFiles.Count) loose files in root directory"
        foreach ($file in $LooseFiles) {
            $report += "`n  - $($file.Name)"
        }
    }
    
    $report += "`n`n####### Backup Status"
    
    if ($BackupDirs.Count -gt 0) {
        $report += "`n- ✅ Found $($BackupDirs.Count) backup directories"
        foreach ($backup in $BackupDirs) {
            $report += "`n  - $($backup.Name)"
        }
    }
    else {
        $report += "`n- ⚠️ No backup directories found"
    }
    
    $report += "`n`n####### Documentation Status"
    
    if ($DocumentationResults.IsValid) {
        $report += "`n- ✅ All required documentation is present"
    }
    else {
        $report += "`n- ❌ Missing required documentation: $($DocumentationResults.MissingDocuments.Count)"
        foreach ($doc in $DocumentationResults.MissingDocuments) {
            $report += "`n  - $doc"
        }
    }
    
    $report += @"
    
###### Next Steps

1. $(if ($DirectoryResults.IsValid) { "Run file naming compliance check" } else { "Address directory structure issues" })
2. $(if ($DirectoryResults.IsValid) { "Begin implementing file naming conventions" } else { "Re-run organization script" })
3. Update documentation with latest progress
4. Run final verification after all issues are resolved

---

_Updated $(Get-Date -Format "MM-dd-yyyy") | AI: Cursor (Claude 3.7 Sonnet)_ 
"@
    
    $report | Out-File -FilePath $reportFile -Encoding utf8
    Write-Log -Message "Progress report generated: $reportFile" -Level "Success"
    
    return $reportFile
}

##### Main execution function
function Main {
    Write-Log -Message "Starting cFish.io implementation monitoring..." -Level "Info"
    
    ##### Check directory structure
    $directoryResults = Check-DirectoryStructure
    
    ##### Check for loose files
    $looseFiles = Check-LooseFiles
    
    ##### Check backup status
    $backupDirs = Check-BackupStatus
    
    ##### Check documentation status
    $documentationResults = Check-DocumentationStatus
    
    ##### Generate progress report
    $reportFile = Generate-ProgressReport -DirectoryResults $directoryResults -LooseFiles $looseFiles -BackupDirs $backupDirs -DocumentationResults $documentationResults
    
    ##### Output summary
    Write-Log -Message "Implementation monitoring completed" -Level "Success"
    Write-Log -Message "Progress report available at: $reportFile" -Level "Info"
    
    if ($directoryResults.IsValid -and $looseFiles.Count -eq 0 -and $documentationResults.IsValid) {
        Write-Log -Message "Implementation is proceeding as expected" -Level "Success"
    }
    else {
        Write-Log -Message "Implementation requires attention. Please review the progress report." -Level "Warning"
    }
}

# Execute main function
Main 
