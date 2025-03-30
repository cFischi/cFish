#Requires -Version 5.1
<#
.SYNOPSIS
    Quick file naming checker for cFish.io workspace.

.DESCRIPTION
    Lightweight version of the file naming checker that runs faster and only 
    shows summary information without listing every non-compliant file.

.PARAMETER report
    Generates a simple compliance report.

.PARAMETER summary
    Only shows summary statistics (default behavior).

.EXAMPLE
    .\check-file-naming-quick.ps1
    Runs a quick check of file naming compliance.

.EXAMPLE
    .\check-file-naming-quick.ps1 -report
    Runs a quick check and generates a simplified report.

.NOTES
    Author: Claude 3.7 Sonnet via Cursor
    Version: 1.0
    Date: April 20, 2025
#>

[CmdletBinding()]
param (
    [switch]$report,
    [switch]$summary
)

# Stopwatch to measure execution time
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

Write-Host "cFish.io Quick File Naming Check" -ForegroundColor Blue
Write-Host "===============================" -ForegroundColor Blue

##### Script configuration
$config = @{
    ##### Root directory of the workspace
    WorkspaceRoot = $PSScriptRoot

    ##### Exclude directories that shouldn't be checked
    ExcludeDirectories = @(
        ".git", "node_modules", "wp-content", "backup_*", "test*", 
        ".cursor*", "logs", "temp", "output", "results"
    )

    ##### Exclude file extensions that shouldn't be checked
    ExcludeExtensions = @(
        ".log", ".tmp", ".bak", ".old", ".vs", ".cache", ".temp"
    )

    ##### System/temp files to skip
    SystemFiles = @(
        "*.tmp", "*.log", "*.bak", "*.cache", "~*", ".DS_Store", "Thumbs.db", 
        "*.min.*", ".*", "*-output-*", "*-report-*", "file-naming-compliance*"
    )

    ##### Critical files that should maintain original names
    CriticalFiles = @(
        "wp-*.php", "index.php", "wp-admin/*", "wp-includes/*", "plugins/*", "themes/*",
        "wp-config.php", "*.config", "*.dll", "*.so", "*.exe", "vendor/*", "lib/*", 
        "dist/*", "build/*", "package.json", "composer.json", "*.lock"
    )

    ##### Report file
    ReportFile = Join-Path -Path $PSScriptRoot -ChildPath "file-naming-compliance-summary.md"
}

##### UcF naming pattern
$ucfPattern = "^(u[1-7])-[a-z0-9\-]+-\d{8}\.[a-z0-9]+$"
$altPattern = "^(0[1-7])_[a-z0-9\-_]+\.[a-z0-9]+$"

##### Process files
function Get-FileComplianceStatus {
    ##### Create inclusion filter for directories
    $excludeFilter = $config.ExcludeDirectories | ForEach-Object { "*\$_*" }
    
    ##### Get all files in workspace, filtering out excluded directories
    Write-Host "Scanning workspace... " -NoNewline
    $allFiles = Get-ChildItem -Path $config.WorkspaceRoot -File -Recurse | 
                Where-Object { 
                    $filePath = $_.FullName
                    -not ($excludeFilter | Where-Object { $filePath -like $_ })
                }
    Write-Host "Found $($allFiles.Count) files." -ForegroundColor Green

    Write-Host "Analyzing files... " -NoNewline
    
    ##### Initialize counters
    $stats = @{
        Total = $allFiles.Count
        Skipped = 0
        Exempt = 0
        Compliant = 0
        NonCompliant = 0
        NonCompliantList = @()
    }
    
    foreach ($file in $allFiles) {
        $fileName = $file.Name
        $extension = $file.Extension.ToLower()
        $relativePath = $file.FullName.Substring($config.WorkspaceRoot.Length + 1)
        
        ##### Skip files with excluded extensions
        if ($config.ExcludeExtensions -contains $extension) {
            $stats.Skipped++
            continue
        }
        
        ##### Skip system/temp files
        $skipFile = $false
        foreach ($pattern in $config.SystemFiles) {
            if ($fileName -like $pattern) {
                $skipFile = $true
                break
            }
        }
        
        if ($skipFile) {
            $stats.Skipped++
            continue
        }
        
        ##### Check if it's a critical file that's exempt
        $isExempt = $false
        foreach ($pattern in $config.CriticalFiles) {
            if ($fileName -like $pattern -or $relativePath -like $pattern) {
                $isExempt = $true
                break
            }
        }
        
        if ($isExempt) {
            $stats.Exempt++
            continue
        }
        
        ##### Check compliance with UcF naming convention
        $isCompliant = $fileName -match $ucfPattern -or $fileName -match $altPattern
        
        if ($isCompliant) {
            $stats.Compliant++
        }
        else {
            $stats.NonCompliant++
            
            ##### Only store non-compliant files if report is requested
            if ($report) {
                $stats.NonCompliantList += @{
                    Name = $fileName
                    Path = $relativePath
                }
            }
        }
    }
    
    Write-Host "Done!" -ForegroundColor Green
    return $stats
}

##### Generate report
function New-ComplianceReport {
    param (
        [Parameter(Mandatory=$true)]
        [hashtable]$Stats
    )
    
    Write-Host "Generating report... " -NoNewline
    
    ##### Calculate compliance percentage
    $totalAssessed = $Stats.Total - $Stats.Skipped
    $compliancePercentage = if ($totalAssessed -gt 0) { 
        [math]::Round((($Stats.Compliant + $Stats.Exempt) / $totalAssessed) * 100, 1)
    } else { 
        0 
    }
    
    $reportContent = @"
# cFish.io File Naming Compliance Summary

Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

## Summary

- **Total files found:** $($Stats.Total)
- **Files skipped:** $($Stats.Skipped) (system files, excluded extensions)
- **Files assessed:** $($totalAssessed)
  - **Compliant files:** $($Stats.Compliant)
  - **Exempt critical files:** $($Stats.Exempt)
  - **Non-compliant files:** $($Stats.NonCompliant)
- **Overall compliance:** $($compliancePercentage)%

"@

    ##### Add non-compliant files if needed
    if ($report -and $Stats.NonCompliant -gt 0 -and $Stats.NonCompliantList.Count -gt 0) {
        $reportContent += @"
## Non-Compliant Files

Showing top 20 non-compliant files:

| File | Path |
|------|------|
"@
        
        ##### Only show top 20 files to keep report manageable
        $filesToShow = [Math]::Min(20, $Stats.NonCompliantList.Count)
        
        for ($i = 0; $i -lt $filesToShow; $i++) {
            $file = $Stats.NonCompliantList[$i]
            $reportContent += "`n| $($file.Name) | $($file.Path) |"
        }
        
        if ($Stats.NonCompliantList.Count -gt 20) {
            $reportContent += "`n\n... and $($Stats.NonCompliantList.Count - 20) more files."
        }
    }
    
    $reportContent += @"

###### Recommendations

1. Run the full check-file-naming.ps1 with -report option to generate a detailed compliance report.
2. Use check-file-naming.ps1 with -fix option to automatically rename non-compliant files.
3. Update any references to renamed files.

---
_Updated $(Get-Date -Format 'MM-dd-yyyy') | AI: Cursor (Claude 3.7 Sonnet)_
"@
    
    # Write report to file
    $reportContent | Out-File -Path $config.ReportFile -Force
    
    Write-Host "Done!" -ForegroundColor Green
    Write-Host "Report saved to: $($config.ReportFile)" -ForegroundColor Green
}

##### Main execution
try {
    ##### Get file compliance statistics
    $stats = Get-FileComplianceStatus
    
    ##### Display results summary
    $totalAssessed = $stats.Total - $stats.Skipped
    $compliancePercentage = if ($totalAssessed -gt 0) { 
        [math]::Round((($stats.Compliant + $stats.Exempt) / $totalAssessed) * 100, 1) 
    } else { 
        0 
    }
    
    Write-Host "`nFile Naming Compliance Summary:" -ForegroundColor Cyan
    Write-Host "-----------------------------" -ForegroundColor Cyan
    Write-Host "Total files found: $($stats.Total)" -ForegroundColor White
    Write-Host "Files skipped: $($stats.Skipped) (system files, excluded extensions)" -ForegroundColor Gray
    Write-Host "Files assessed: $totalAssessed" -ForegroundColor White
    Write-Host "  Compliant files: $($stats.Compliant)" -ForegroundColor Green
    Write-Host "  Exempt critical files: $($stats.Exempt)" -ForegroundColor Yellow
    Write-Host "  Non-compliant files: $($stats.NonCompliant)" -ForegroundColor $(if ($stats.NonCompliant -eq 0) { "Green" } else { "Red" })
    Write-Host "Overall compliance: $compliancePercentage%" -ForegroundColor $(if ($compliancePercentage -gt 80) { "Green" } elseif ($compliancePercentage -gt 50) { "Yellow" } else { "Red" })
    
    ##### Generate report if requested
    if ($report) {
        New-ComplianceReport -Stats $stats
    }
    
    ##### Stop the stopwatch
    $stopwatch.Stop()
    $executionTime = $stopwatch.Elapsed.TotalSeconds
    
    Write-Host "`nCheck completed in $([math]::Round($executionTime, 2)) seconds." -ForegroundColor Cyan
}
catch {
    Write-Host "An error occurred during script execution:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    
    if ($stopwatch.IsRunning) {
        $stopwatch.Stop()
    }
    
    exit 1
} 
