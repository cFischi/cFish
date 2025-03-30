param(
    [Parameter(Mandatory=$false)]
    [string[]]$TargetDirectories = @(),
    
    [Parameter(Mandatory=$false)]
    [string]$OutputFormat = "console",
    
    [Parameter(Mandatory=$false)]
    [switch]$Detailed = $false
)

##### Targeted file naming checker
##### Set error action preference to continue
$ErrorActionPreference = "Continue"

##### Start timer
$startTime = Get-Date

##### Header
Write-Host "cFish.io Targeted File Check - Starting..." -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

##### If no target directories provided, let user choose
if ($TargetDirectories.Count -eq 0) {
    Write-Host "No target directories specified. Choose directories to scan:" -ForegroundColor Yellow
    
    ##### Get all top-level directories
    $allDirs = Get-ChildItem -Path $PSScriptRoot -Directory | 
               Where-Object { 
                   ##### Exclude common system/temporary directories
                   $_.Name -notmatch "^\." -and
                   $_.Name -notmatch "^node_modules$" -and
                   $_.Name -notmatch "^backup_" -and
                   $_.Name -notmatch "^\.git$"
               }
    
    ##### Display numbered list
    $dirMap = @{}
    for ($i = 0; $i -lt $allDirs.Count; $i++) {
        $dirMap.Add(($i + 1), $allDirs[$i].Name)
        Write-Host "  $($i + 1). $($allDirs[$i].Name)" -ForegroundColor White
    }
    
    ##### Get selection
    Write-Host "`nEnter directory numbers to scan (comma-separated, e.g. '1,3,5'), or 'all' for all:" -ForegroundColor Yellow
    $selection = Read-Host
    
    if ($selection -eq "all") {
        $TargetDirectories = $dirMap.Values
    }
    else {
        $selectedIndices = $selection -split ',' | ForEach-Object { $_.Trim() }
        $TargetDirectories = @()
        foreach ($idx in $selectedIndices) {
            if ($dirMap.ContainsKey([int]$idx)) {
                $TargetDirectories += $dirMap[[int]$idx]
            }
        }
    }
}

##### Check if we have any target directories
if ($TargetDirectories.Count -eq 0) {
    Write-Host "No directories selected. Exiting..." -ForegroundColor Red
    exit
}

Write-Host "Scanning directories: $($TargetDirectories -join ', ')" -ForegroundColor Green

##### Directories to exclude when processing subdirectories
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

##### Track non-compliant files if detailed mode is on
$nonCompliantFiles = @()

##### Process each directory
$dirCount = 0
foreach ($dirName in $TargetDirectories) {
    $dirCount++
    
    ##### Find the directory
    $dir = Get-ChildItem -Path $PSScriptRoot -Directory | Where-Object { $_.Name -eq $dirName } | Select-Object -First 1
    
    if ($null -eq $dir) {
        Write-Host "Directory not found: $dirName" -ForegroundColor Red
        continue
    }
    
    ##### Show progress percentage
    $progressPercent = [math]::Round(($dirCount / $TargetDirectories.Count) * 100)
    Write-Host "[$progressPercent%] Checking directory $dirCount of $($TargetDirectories.Count): $($dir.Name)" -ForegroundColor Cyan
    
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
            $isCompliant = $false
            if ($fileName -match "^(u[1-7])-.*-\d{8}\." -or
                $fileName -match "^ucf-.*-\d{8}\." -or
                $fileName -match "^(0[1-7])_[A-Z]{2,3}_") {
                $stats.Compliant++
                $isCompliant = $true
            }
            else {
                $stats.NonCompliant++
                
                ##### Track non-compliant files in detailed mode
                if ($Detailed) {
                    $relativePath = $file.FullName.Replace($PSScriptRoot, "").TrimStart('\')
                    $nonCompliantFiles += [PSCustomObject]@{
                        File = $relativePath
                        Path = $file.DirectoryName
                        Extension = $extension
                        Size = $file.Length
                    }
                }
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

##### If detailed mode, show list of non-compliant files
if ($Detailed -and $nonCompliantFiles.Count -gt 0) {
    Write-Host "`nNon-compliant files:" -ForegroundColor Yellow
    
    ##### Display first 20 files
    $nonCompliantFiles | Select-Object -First 20 | ForEach-Object {
        Write-Host "  - $($_.File)" -ForegroundColor Gray
    }
    
    if ($nonCompliantFiles.Count -gt 20) {
        Write-Host "  ... and $($nonCompliantFiles.Count - 20) more files" -ForegroundColor Gray
    }
}

##### Save report
$reportFile = Join-Path -Path $PSScriptRoot -ChildPath "file-naming-targeted-report.md"
$report = @"
##### cFish.io Targeted File Naming Check Report

Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

###### Target Directories
$(($TargetDirectories | ForEach-Object { "- $PSItem" }) -join "`n")

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
"@

# Add non-compliant files to report if detailed mode is on
if ($Detailed -and $nonCompliantFiles.Count -gt 0) {
    $report += "`n`n###### Non-Compliant Files`n"
    
    # Group by directory to make the report more readable
    $groupedFiles = $nonCompliantFiles | Group-Object -Property Path
    
    foreach ($group in $groupedFiles) {
        $relativePath = $group.Name.Replace($PSScriptRoot, "").TrimStart('\')
        $report += "`n####### $relativePath`n"
        
        foreach ($file in $group.Group) {
            $fileName = Split-Path -Leaf $file.File
            $report += "- $fileName`n"
        }
    }
}

$report | Out-File -FilePath $reportFile -Force

Write-Host "Report saved to: $reportFile" -ForegroundColor Green 
