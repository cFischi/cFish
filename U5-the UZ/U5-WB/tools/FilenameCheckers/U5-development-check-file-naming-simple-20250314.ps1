# Super-simple file naming checker
Write-Host "cFish.io Simple File Check - Starting..." -ForegroundColor Cyan

##### Only check top-level directories to make it fast
$topLevelDirs = Get-ChildItem -Path $PSScriptRoot -Directory | 
                Where-Object { $_.Name -match "^U[1-7]-" -or $_.Name -in @("docs", "tools", "src", "resources") }

Write-Host "Found $($topLevelDirs.Count) top-level directories to check" -ForegroundColor Green

##### Stats counters
$stats = @{
    Total = 0
    Compliant = 0
    NonCompliant = 0
    Exempt = 0
}

##### Process each directory with progress indicators
$currentDir = 0
foreach ($dir in $topLevelDirs) {
    $currentDir++
    Write-Host "Checking directory $currentDir of $($topLevelDirs.Count): $($dir.Name)... " -NoNewline
    
    ##### Get only files in the immediate directory, not recursively
    $files = Get-ChildItem -Path $dir.FullName -File
    $fileCount = $files.Count
    $stats.Total += $fileCount
    
    Write-Host "Found $fileCount files." -ForegroundColor Green
    
    ##### Very simple checking
    foreach ($file in $files) {
        if ($file.Name -match "^(u[1-7])-.*-\d{8}\." -or 
            $file.Name -match "^ucf-.*-\d{8}\.") {
            $stats.Compliant++
        }
        elseif ($file.Name -match "^(wp-|index\.php|\.)" -or 
               $file.Extension -in @(".dll", ".exe", ".so", ".lock")) {
            $stats.Exempt++
        }
        else {
            $stats.NonCompliant++
        }
    }
}

##### Display simple summary
Write-Host "`n----- SUMMARY -----" -ForegroundColor Cyan
Write-Host "Total files checked: $($stats.Total)" -ForegroundColor White
Write-Host "Compliant: $($stats.Compliant)" -ForegroundColor Green
Write-Host "Exempt: $($stats.Exempt)" -ForegroundColor Yellow
Write-Host "Non-compliant: $($stats.NonCompliant)" -ForegroundColor Red

Write-Host "`nCheck completed!" -ForegroundColor Cyan 
