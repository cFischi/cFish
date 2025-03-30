#Requires -Version 5.1
<#
.SYNOPSIS
    PowerShell script for checking file naming against UcF conventions.

.DESCRIPTION
    This script analyzes files in the cFish.io workspace and checks if they follow
    the UcF naming conventions. It can generate reports on compliance and suggest
    renamed files.

.PARAMETER fix
    Attempts to rename non-compliant files to follow UcF conventions.

.PARAMETER report
    Generates a detailed report of file naming compliance.

.PARAMETER detailedOutput
    Provides detailed output during script execution.

.EXAMPLE
    .\check-file-naming.ps1
    Checks file naming against UcF conventions.

.EXAMPLE
    .\check-file-naming.ps1 -report
    Generates a detailed report of file naming compliance.

.EXAMPLE
    .\check-file-naming.ps1 -fix
    Attempts to rename non-compliant files.

.NOTES
    Author: Claude 3.7 Sonnet via Cursor
    Version: 1.0
    Date: April 19, 2025
#>

[CmdletBinding()]
param (
    [switch]$fix,
    [switch]$report,
    [switch]$detailedOutput
)

# Script configuration
${script}:config = @{
    # Root directory of the cFish.io workspace
    WorkspaceRoot = $PSScriptRoot

    # Department structure as per UcF standard
    Departments = @{
        "U1" = "Overheads"
        "U2" = "Research-and-Development"
        "U3" = "Operations"
        "U4" = "Production"
        "U5" = "Data-Management"
        "U6" = "Social-Media-Communications"
        "U7" = "Specialized-Projects"
    }
    
    ##### Alternative naming formats for departments
    AlternativeNaming = @{
        "U1" = "Administration"
        "U2" = "Research"
        "U3" = "Operations"
        "U4" = "Production"
        "U5" = "Data"
        "U6" = "Marketing"
        "U7" = "Systems"
    }
    
    ##### Standard subfolders for each department
    StandardSubfolders = @(
        "Documentation",
        "Planning",
        "Assets",
        "Development"
    )
    
    ##### Directories to exclude from checking
    ExcludedDirectories = @(
        "wp-content",
        "Backups",
        ".git",
        "node_modules",
        "backup_before_organization*",
        "test-environment",
        ".cursor-*",
        "logs",
        "temp",
        "tests",
        "results",
        "output"
    )
    
    ##### File extensions to exclude from checking
    ExcludedExtensions = @(
        ".log", 
        ".tmp",
        ".temp",
        ".cache",
        ".bak",
        ".old",
        ".vs"
    )
    
    ##### File patterns to skip (these won't even be reported as non-compliant)
    SkipPatterns = @(
        ##### Temporary/system files
        "*.tmp",
        "*.temp",
        "*.log",
        "*.bak",
        "*.cache",
        "~*",
        ".DS_Store",
        "Thumbs.db",
        
        ##### Development files
        "package-lock.json",
        "yarn.lock",
        "*.min.*",
        
        ##### Hidden files
        ".*",
        
        ##### Script outputs
        "*-output-*",
        "*-report-*",
        "file-naming-compliance-report.md"
    )
    
    ##### Critical file patterns to exempt from renaming
    ##### These files should maintain original names for functionality
    ExemptedFilePatterns = @(
        ##### WordPress core files
        "wp-*.php",
        "index.php",
        "wp-admin/*",
        "wp-includes/*",
        
        ##### Plugin and theme files
        "plugins/*",
        "themes/*",
        
        ##### Configuration files
        "wp-config.php",
        "*.config",
        "web.config",
        
        ##### Legal documents
        "license*.txt",
        "terms-of-service.pdf",
        "privacy-policy.pdf",
        
        ##### System files
        "*.dll",
        "*.so",
        "*.exe",
        
        ##### Third-party libraries
        "vendor/*",
        "lib/*",
        "dist/*",
        "build/*",
        
        ##### Package management
        "package.json",
        "composer.json",
        "*.lock"
    )
    
    ##### Report output file
    ReportFile = Join-Path -Path $PSScriptRoot -ChildPath "file-naming-compliance-report.md"
}

##### Regular expressions for file naming patterns
${script}:patterns = @{
    ##### UcF department-based naming
    ##### Format: department-category-descriptive-name-YYYYMMDD.ext
    UcFPattern = "^(U[1-7])-(documentation|planning|assets|development)-[a-z0-9\-]+-\d{8}\.[a-z0-9]+$"
    
    ##### Alternative naming format (for backwards compatibility)
    ##### Format: 01_OVR_descriptive-name.ext
    AltPattern = "^(0[1-7])_(OVR|RD|OPZ|PRO|DMT|SMC|SPEC)_[a-z0-9\-_]+\.[a-z0-9]+$"
    
    ##### Date pattern for file names: YYYYMMDD
    DatePattern = "\d{8}"
}

##### Function to check if a file should be exempted from naming conventions
function Test-ExemptedFile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [System.IO.FileInfo]$File
    )
    
    $relativePath = $File.FullName.Replace(${script}:config.WorkspaceRoot, "").TrimStart("\")
    
    ##### Check if file matches any exempted patterns
    foreach ($pattern in ${script}:config.ExemptedFilePatterns) {
        if ($relativePath -like $pattern) {
            if (${script}:detailedOutput) {
                Write-Host "Exempting critical file: $relativePath (matches pattern: $pattern)" -ForegroundColor Yellow
            }
            return $true
        }
    }
    
    return $false
}

##### Function to check if a file name follows UcF naming conventions
function Test-UcFNamingConvention {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$FileName
    )
    
    $fileName = $FileName.ToLower()
    
    ##### Check if file name matches UcF pattern
    if ($fileName -match ${script}:patterns.UcFPattern) {
        return $true
    }
    
    ##### Check if file name matches alternative pattern
    if ($fileName -match ${script}:patterns.AltPattern) {
        return $true
    }
    
    return $false
}

##### Function to suggest a renamed file name that follows UcF conventions
function Get-SuggestedFileName {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [System.IO.FileInfo]$File,
        
        [Parameter(Mandatory=$false)]
        [string]$Department = "",
        
        [Parameter(Mandatory=$false)]
        [string]$Category = ""
    )
    
    $baseName = $File.BaseName
    $extension = $File.Extension.ToLower()
    
    ##### Clean the base name (replace spaces with hyphens, remove special characters)
    $cleanName = $baseName -replace '[^\w\-\.]', '-' -replace '(-)\1+', '$1' -replace '\s+', '-'
    $cleanName = $cleanName.ToLower()
    
    ##### Extract date from file name if it exists
    $date = ""
    if ($cleanName -match ${script}:patterns.DatePattern) {
        $date = $Matches[0]
    }
    else {
        ##### Use current date if no date in filename
        $date = Get-Date -Format 'yyyyMMdd'
    }
    
    ##### Determine department if not provided
    if (-not $Department) {
        ##### Try to extract from file path
        $relativePath = $File.FullName.Substring(${script}:config.WorkspaceRoot.Length + 1)
        
        foreach ($dept in ${script}:config.Departments.GetEnumerator()) {
            if ($relativePath -like "$($dept.Key)-$($dept.Value)\*") {
                $Department = $dept.Key
                break
            }
            
            ##### Check alternative naming format
            $altName = (${script}:config.AlternativeNaming.GetEnumerator() | Where-Object { $_.Key -eq $dept.Key }).Value
            if ($altName -and $relativePath -like "$altName\*") {
                $Department = $dept.Key
                break
            }
        }
        
        ##### Default to U5 if department can't be determined
        if (-not $Department) {
            $Department = "U5"
        }
    }
    
    ##### Determine category if not provided
    if (-not $Category) {
        ##### Try to extract from file path
        $relativePath = $File.FullName.Substring(${script}:config.WorkspaceRoot.Length + 1)
        
        foreach ($subfolder in ${script}:config.StandardSubfolders) {
            if ($relativePath -like "*\$subfolder\*") {
                $Category = $subfolder.ToLower()
                break
            }
        }
        
        ##### Determine category based on file extension if not found in path
        if (-not $Category) {
            if ($extension -in @('.md', '.pdf', '.doc', '.docx', '.txt')) {
                $Category = "documentation"
            }
            elseif ($extension -in @('.mpp', '.xlsx', '.csv', '.json')) {
                $Category = "planning"
            }
            elseif ($extension -in @('.jpg', '.png', '.gif', '.svg', '.mp4', '.wav', '.mp3')) {
                $Category = "assets"
            }
            elseif ($extension -in @('.js', '.css', '.php', '.html', '.sql', '.ps1', '.py')) {
                $Category = "development"
            }
            else {
                $Category = "documentation"
            }
        }
    }
    
    ##### Format: department-category-descriptive-name-YYYYMMDD.ext
    return "$Department-$Category-$cleanName-$date$extension"
}

##### Function to check file naming across the workspace
function Check-FileNaming {
    [CmdletBinding()]
    param()
    
    if ($detailedOutput) { Write-Host "Checking file naming against UcF conventions..." -ForegroundColor Cyan }
    
    ##### Get all files excluding those in excluded directories
    $excludeFilter = ${script}:config.ExcludedDirectories | ForEach-Object { "$_\*" }
    $allFiles = Get-ChildItem -Path ${script}:config.WorkspaceRoot -Recurse -File
    
    ##### First filter out files in excluded directories
    $filteredFiles = $allFiles | Where-Object { 
        $fileFullPath = $_.FullName
        -not ($excludeFilter | Where-Object { $fileFullPath -like "*\$_" -or $fileFullPath -like "*\$_\*" })
    }
    
    ##### Then filter out files with excluded extensions
    $filteredFiles = $filteredFiles | Where-Object {
        $extension = $_.Extension.ToLower()
        -not (${script}:config.ExcludedExtensions -contains $extension)
    }
    
    ##### Finally filter out files matching skip patterns
    $filesToCheck = $filteredFiles | Where-Object {
        $fileName = $_.Name
        $relativePath = $_.FullName.Replace(${script}:config.WorkspaceRoot, "").TrimStart("\")
        
        ##### Check if file should be skipped based on skip patterns
        foreach ($pattern in ${script}:config.SkipPatterns) {
            if ($fileName -like $pattern -or $relativePath -like $pattern) {
                if ($detailedOutput) {
                    Write-Host "Skipping: $fileName (matches skip pattern: $pattern)" -ForegroundColor Gray
                }
                return $false
            }
        }
        
        return $true
    }
    
    $totalFiles = $filesToCheck.Count
    $compliantFiles = 0
    $nonCompliantFiles = @()
    $exemptedFiles = 0
    $skippedFiles = $allFiles.Count - $filesToCheck.Count
    
    foreach ($file in $filesToCheck) {
        ##### First check if this is an exempted critical file
        $isExempted = Test-ExemptedFile -File $file
        
        if ($isExempted) {
            $exemptedFiles++
            
            if ($detailedOutput) {
                Write-Host "Exempted: $($file.Name) (Critical file - will not be renamed)" -ForegroundColor Yellow
            }
            continue
        }
        
        ##### Check if file name is compliant
        $isCompliant = Test-UcFNamingConvention -FileName $file.Name
        
        if ($isCompliant) {
            $compliantFiles++
            
            if ($detailedOutput) {
                Write-Host "Compliant: $($file.Name)" -ForegroundColor Green
            }
        }
        else {
            if ($detailedOutput) {
                Write-Host "Non-compliant: $($file.Name)" -ForegroundColor Red
            }
            
            ##### Get suggested name
            $suggestedName = Get-SuggestedFileName -File $file
            
            $nonCompliantFiles += @{
                File = $file
                SuggestedName = $suggestedName
                OriginalName = $file.Name
                FullPath = $file.FullName
            }
        }
    }
    
    ##### Return results
    return @{
        TotalFiles = $totalFiles
        CompliantFiles = $compliantFiles
        NonCompliantFiles = $nonCompliantFiles
        ExemptedFiles = $exemptedFiles
        SkippedFiles = $skippedFiles
        CompliancePercentage = if ($totalFiles -gt 0) { [math]::Round((($compliantFiles + $exemptedFiles) / $totalFiles) * 100, 2) } else { 0 }
    }
}

##### Function to attempt to rename non-compliant files
function Fix-FileNaming {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [array]$NonCompliantFiles
    )
    
    if ($detailedOutput) { Write-Host "Attempting to rename non-compliant files..." -ForegroundColor Cyan }
    
    $successCount = 0
    $failureCount = 0
    
    foreach ($fileInfo in $NonCompliantFiles) {
        $file = $fileInfo.File
        $suggestedName = $fileInfo.SuggestedName
        $directory = Split-Path -Path $file.FullName -Parent
        $newPath = Join-Path -Path $directory -ChildPath $suggestedName
        
        try {
            ##### Rename the file
            Rename-Item -Path $file.FullName -NewName $suggestedName -ErrorAction Stop
            $successCount++
            
            if ($detailedOutput) {
                Write-Host "Renamed: $($file.Name) -> $suggestedName" -ForegroundColor Green
            }
        }
        catch {
            $failureCount++
            
            if ($detailedOutput) {
                Write-Host "Failed to rename: $($file.Name) -> $suggestedName" -ForegroundColor Red
                Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    }
    
    Write-Host "File renaming completed." -ForegroundColor Green
    Write-Host "Successfully renamed: $successCount" -ForegroundColor Green
    Write-Host "Failed to rename: $failureCount" -ForegroundColor $(if ($failureCount -eq 0) { "Green" } else { "Red" })
    
    return @{
        SuccessCount = $successCount
        FailureCount = $failureCount
    }
}

##### Function to generate a detailed report of file naming compliance
function Generate-Report {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [hashtable]$CheckResults
    )
    
    if ($detailedOutput) { Write-Host "Generating file naming compliance report..." -ForegroundColor Cyan }
    
    ##### Calculate percentages safely
    $compliantPercent = if ($CheckResults.TotalFiles -gt 0) { [math]::Round(($CheckResults.CompliantFiles / $CheckResults.TotalFiles) * 100, 2) } else { 0 }
    $exemptedPercent = if ($CheckResults.TotalFiles -gt 0) { [math]::Round(($CheckResults.ExemptedFiles / $CheckResults.TotalFiles) * 100, 2) } else { 0 }
    $nonCompliantPercent = if ($CheckResults.TotalFiles -gt 0) { [math]::Round(($CheckResults.NonCompliantFiles.Count / $CheckResults.TotalFiles) * 100, 2) } else { 0 }
    
    $reportContent = @"
# cFish.io File Naming Compliance Report

**Generated:** $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

This report provides an analysis of file naming compliance against the UcF naming conventions.

## Summary Statistics

- **Total files checked:** $($CheckResults.TotalFiles)
- **Compliant files:** $($CheckResults.CompliantFiles) (${compliantPercent}%)
- **Exempted critical files:** $($CheckResults.ExemptedFiles) (${exemptedPercent}%)
- **Non-compliant files:** $($CheckResults.NonCompliantFiles.Count) (${nonCompliantPercent}%)
- **Overall compliance:** $([math]::Round($CheckResults.CompliancePercentage, 2))% (includes both compliant and exempted files)

## Critical Files Exemption

The following categories of files are exempted from UcF naming conventions to preserve functionality:

- WordPress core files and themes
- Third-party plugins and libraries
- Legal documents and compliance files
- Licensed software and tools with specific naming requirements
- Configuration files that other systems depend on

These files maintain their original names but are still organized in the appropriate category directories.

## Compliance by Department

"@
    
    ##### Calculate compliance by department
    $deptCompliance = @{}
    foreach ($dept in ${script}:config.Departments.GetEnumerator()) {
        $deptDir = "$($dept.Key)-$($dept.Value)"
        $deptFiles = $CheckResults.NonCompliantFiles | Where-Object { $_.FullPath -like "*\$deptDir\*" }
        $deptCompliance[$dept.Key] = @{
            Department = "$($dept.Key) - $($dept.Value)"
            NonCompliantCount = $deptFiles.Count
        }
    }
    
    ##### Add department compliance to report
    foreach ($dept in $deptCompliance.GetEnumerator() | Sort-Object { $_.Value.NonCompliantCount } -Descending) {
        $reportContent += @"

- **$($dept.Value.Department):** $($dept.Value.NonCompliantCount) non-compliant files
"@
    }
    
    ##### Add non-compliant files to report
    if ($CheckResults.NonCompliantFiles.Count -gt 0) {
        $reportContent += @"

## Non-Compliant Files

| Original Name | Suggested Name | Path |
|--------------|---------------|------|
"@
        
        foreach ($fileInfo in $CheckResults.NonCompliantFiles) {
            $relativePath = $fileInfo.FullPath.Substring(${script}:config.WorkspaceRoot.Length + 1)
            $reportContent += @"

| $($fileInfo.OriginalName) | $($fileInfo.SuggestedName) | $relativePath |
"@
        }
    }
    
    ##### Add recommendations to report
    $reportContent += @"

## Recommendations

1. **Compliance Status:** Overall compliance is at $([math]::Round($CheckResults.CompliancePercentage, 2))%.
2. **Critical Files:** $($CheckResults.ExemptedFiles) critical files are properly exempted from renaming.
3. **Next Steps:**
   - Run the check-file-naming.ps1 script with the -fix parameter to rename non-compliant files.
   - Update any references to renamed files.
   - Review file naming guidelines in the SOP document.
   - Maintain the exemption list for critical files to ensure proper functionality.

_Updated $(Get-Date -Format 'MM-dd-yyyy') | AI: Cursor (Claude 3.7 Sonnet)_
"@
    
    ##### Write report to file
    $reportContent | Out-File -FilePath ${script}:config.ReportFile -Force
    
    if ($detailedOutput) { 
        Write-Host "Report generated: $(${script}:config.ReportFile)" -ForegroundColor Green 
    }
}

##### Main script execution
try {
    Write-Host "cFish.io File Naming Compliance Check" -ForegroundColor Blue
    Write-Host "===================================" -ForegroundColor Blue
    
    ##### Check file naming
    $checkResults = Check-FileNaming
    
    ##### Display results summary
    Write-Host "`nFile naming compliance check completed." -ForegroundColor Green
    Write-Host "Total files checked: $($checkResults.TotalFiles)" -ForegroundColor Cyan
    Write-Host "Skipped files: $($checkResults.SkippedFiles)" -ForegroundColor Gray
    Write-Host "Compliant files: $($checkResults.CompliantFiles)" -ForegroundColor Green
    Write-Host "Exempted critical files: $($checkResults.ExemptedFiles)" -ForegroundColor Yellow
    Write-Host "Non-compliant files: $($checkResults.NonCompliantFiles.Count)" -ForegroundColor $(if ($checkResults.NonCompliantFiles.Count -eq 0) { "Green" } else { "Red" })
    Write-Host "Overall compliance: $([math]::Round($checkResults.CompliancePercentage, 2))%" -ForegroundColor $(if ($checkResults.CompliancePercentage -gt 80) { "Green" } elseif ($checkResults.CompliancePercentage -gt 50) { "Yellow" } else { "Red" })
    
    ##### Fix file naming if requested
    if ($fix -and $checkResults.NonCompliantFiles.Count -gt 0) {
        $fixResults = Fix-FileNaming -NonCompliantFiles $checkResults.NonCompliantFiles
    }
    
    ##### Generate report if requested
    if ($report) {
        Generate-Report -CheckResults $checkResults
    }
    
    Write-Host "`nScript execution completed successfully." -ForegroundColor Green
}
catch {
    Write-Host "An error occurred during script execution:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host "Stack Trace: $($_.ScriptStackTrace)" -ForegroundColor Red
} 
