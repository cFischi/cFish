# Standard file naming checker
# Set error action preference to continue
$ErrorActionPreference = "Continue"

##### Start timer
$startTime = Get-Date

Write-Host "cFish.io Standard File Check - Starting..." -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Scanning for top-level directories..." -NoNewline

##### Get the current location (not the script location)
$currentDir = Get-Location

##### Top-level directories to check
$topLevelDirs = Get-ChildItem -Path $currentDir -Directory | 
                Where-Object { 
                    ##### Standard UcF directories
                    $_.Name -match "^U\d-" -or 
                    ##### Common project directories
                    $_.Name -in @("docs", "tools", "src", "resources", "config", "scripts") -or
                    ##### Support directories
                    $_.Name -in @("_Resources", "_Archives", "Documentation")
                }

Write-Host " Found $($topLevelDirs.Count)" -ForegroundColor Green

##### Directories to exclude
$excludeDirs = @(
    ".git", "node_modules", "backup_*", "test-environment", 
    ".cursor-*", "logs", "temp", "wp-content", "test-cross-platform"
)

##### File patterns to exclude
$excludePatterns = @(
    "*.log", "*.tmp", "*.bak", ".DS_Store", "Thumbs.db", "*.cache", 
    "*.lock", "*.min.*"
)

##### Critical files that are exempt from naming
$exemptPatterns = @(
    "wp-*.php", "index.php", "*.config", "*.dll", "*.exe", "*.so",
    "package.json", "composer.json"
)

##### Stats counters
$stats = @{
    Total = 0
    Compliant = 0
    NonCompliant = 0
    Exempt = 0
    Excluded = 0
}

##### Process each directory
$dirCount = 0
foreach ($dir in $topLevelDirs) {
    $dirCount++
    
    ##### Show progress percentage
    $progressPercent = [math]::Round(($dirCount / $topLevelDirs.Count) * 100)
    Write-Host "[$progressPercent%] Checking directory $dirCount of $($topLevelDirs.Count): $($dir.Name)" -ForegroundColor Cyan
    
    ##### Get all files in this directory and immediate subdirectories (depth 1)
    try {
        $allFiles = @()
        
        ##### First get files in the top directory
        $topFiles = Get-ChildItem -Path $dir.FullName -File -ErrorAction SilentlyContinue
        $allFiles += $topFiles
        
        ##### Then get one level of subdirectories
        $subDirs = Get-ChildItem -Path $dir.FullName -Directory -ErrorAction SilentlyContinue | 
                  Where-Object { 
                      $subDir = $_.Name
                      -not ($excludeDirs | Where-Object { $subDir -like $_ })
                  }
        
        ##### Show subdirectories being checked
        if ($subDirs.Count -gt 0) {
            Write-Host "  - Processing $($subDirs.Count) subdirectories" -ForegroundColor Gray
        }
        
        ##### Get files from subdirectories
        foreach ($subDir in $subDirs) {
            $subFiles = Get-ChildItem -Path $subDir.FullName -File -ErrorAction SilentlyContinue
            $allFiles += $subFiles
        }
        
        ##### Count total files found
        $fileCount = $allFiles.Count
        Write-Host "  - Found $fileCount files to check" -ForegroundColor White
        
        ##### Process each file
        $processed = 0
        foreach ($file in $allFiles) {
            $processed++
            
            ##### Show periodic progress updates (every 50 files)
            if ($processed % 50 -eq 0) {
                Write-Host "    - Processed $processed of $fileCount files..." -ForegroundColor Gray
            }
            
            $fileName = $file.Name
            $extension = $file.Extension.ToLower()
            
            ##### Skip excluded file patterns
            $excluded = $false
            foreach ($pattern in $excludePatterns) {
                if ($fileName -like $pattern) {
                    $stats.Excluded++
                    $excluded = $true
                    break
                }
            }
            if ($excluded) { continue }
            
            ##### Check if exempt
            $exempt = $false
            foreach ($pattern in $exemptPatterns) {
                if ($fileName -like $pattern) {
                    $stats.Exempt++
                    $exempt = $true
                    break
                }
            }
            if ($exempt) { 
                $stats.Total++
                continue 
            }
            
            ##### Check if compliant
            if ($fileName -match "^(u[1-7])-.*-\d{8}\." -or
                $fileName -match "^ucf-.*-\d{8}\." -or
                $fileName -match "^(0[1-7])_[A-Z]{2,3}_") {
                $stats.Compliant++
            }
            else {
                $stats.NonCompliant++
            }
            
            ##### Count total assessed files
            $stats.Total++
        }
    }
    catch {
        Write-Host "  - Error processing directory: $_" -ForegroundColor Red
    }
}

##### Calculate percentages
$compliancePercent = if ($stats.Total -gt 0) { 
    [math]::Round((($stats.Compliant + $stats.Exempt) / $stats.Total) * 100, 1) 
} else { 
    0 
}

##### End timer
$endTime = Get-Date
$duration = $endTime - $startTime
$seconds = [math]::Round($duration.TotalSeconds, 1)

##### Display summary
Write-Host "`n========== SUMMARY ==========" -ForegroundColor Cyan
Write-Host "Total files assessed: $($stats.Total)" -ForegroundColor White
Write-Host "  - Compliant files: $($stats.Compliant)" -ForegroundColor Green
Write-Host "  - Exempt files: $($stats.Exempt)" -ForegroundColor Yellow
Write-Host "  - Non-compliant files: $($stats.NonCompliant)" -ForegroundColor $(if ($stats.NonCompliant -eq 0) { "Green" } else { "Red" })
Write-Host "Files excluded: $($stats.Excluded)" -ForegroundColor Gray
Write-Host "Overall compliance: $compliancePercent%" -ForegroundColor $(if ($compliancePercent -gt 80) { "Green" } elseif ($compliancePercent -gt 50) { "Yellow" } else { "Red" })
Write-Host "Check completed in $seconds seconds" -ForegroundColor Cyan
Write-Host "==============================" -ForegroundColor Cyan

##### Save report
$reportFile = Join-Path -Path $currentDir -ChildPath "file-naming-standard-report.md"
@"
##### cFish.io Standard File Naming Check Report

Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

###### Summary

- **Total files assessed:** $($stats.Total)
- **Compliant files:** $($stats.Compliant)
- **Exempt files:** $($stats.Exempt)
- **Non-compliant files:** $($stats.NonCompliant)
- **Files excluded:** $($stats.Excluded)
- **Overall compliance:** $compliancePercent%
- **Check duration:** $seconds seconds

###### Recommendations

1. Review non-compliant files and rename them according to UcF naming convention.
2. Use check-file-naming.ps1 with -fix parameter to automatically rename files.
3. For detailed reports, run check-file-naming.ps1 with -report parameter.

_Updated $(Get-Date -Format 'MM-dd-yyyy') | AI: Cursor (Claude 3.7 Sonnet)_
"@ | Out-File -FilePath $reportFile -Force

Write-Host "Report saved to: $reportFile" -ForegroundColor Green 
