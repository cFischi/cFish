# tYDiSync~ File Renaming Script
# Created: 03-14-2025

# Docs directory files
$docsFiles = @(
    @{Old = "docs/md-json-sync-testing-findings.md"; New = "docs/tydisync-testing-findings.md"},
    @{Old = "docs/md-json-sync-status-report.md"; New = "docs/tydisync-status-report.md"},
    @{Old = "docs/md-json-sync-implementation-verification.md"; New = "docs/tydisync-implementation-verification.md"},
    @{Old = "docs/md-json-sync-low-cpu-reference.md"; New = "docs/tydisync-low-cpu-reference.md"},
    @{Old = "docs/md-json-sync-next-steps.md"; New = "docs/tydisync-next-steps.md"},
    @{Old = "docs/md-json-sync-improvements.md"; New = "docs/tydisync-improvements.md"},
    @{Old = "docs/md-json-sync-quick-reference.md"; New = "docs/tydisync-quick-reference.md"},
    @{Old = "docs/md-json-sync-system-summary.md"; New = "docs/tydisync-system-summary.md"}
)

##### Root directory files
$rootFiles = @(
    @{Old = "md-json-sync.js.backup"; New = "tydisync.js.backup"},
    @{Old = "md-json-sync-enhanced.js"; New = "tydisync-enhanced.js"}
)

##### Core implementation files
$coreFiles = @(
    @{Old = "sync-system/core/md-json-sync.js"; New = "sync-system/core/tydisync.js"},
    @{Old = "sync-system/core/optimized-md-json-sync.js"; New = "sync-system/core/optimized-tydisync.js"},
    @{Old = "sync-system/core/dummy-md-json-sync.js"; New = "sync-system/core/dummy-tydisync.js"}
)

##### Function to rename a file
function Rename-FileIfExists {
    param(
        [string]$oldPath,
        [string]$newPath
    )
    
    if (Test-Path $oldPath) {
        Write-Host "Renaming: $oldPath → $newPath"
        
        ##### Create directory if it doesn't exist
        $newDir = Split-Path -Parent $newPath
        if (-not (Test-Path $newDir)) {
            New-Item -ItemType Directory -Path $newDir -Force | Out-Null
        }
        
        ##### Rename the file
        Rename-Item -Path $oldPath -NewName $newPath -Force
        return $true
    } else {
        Write-Host "File not found: $oldPath" -ForegroundColor Yellow
        return $false
    }
}

##### Rename docs files
Write-Host "Renaming files in docs directory..." -ForegroundColor Cyan
foreach ($file in $docsFiles) {
    Rename-FileIfExists -oldPath $file.Old -newPath $file.New
}

##### Rename root directory files
Write-Host "`nRenaming files in root directory..." -ForegroundColor Cyan
foreach ($file in $rootFiles) {
    Rename-FileIfExists -oldPath $file.Old -newPath $file.New
}

##### Rename core implementation files
Write-Host "`nRenaming core implementation files..." -ForegroundColor Cyan
foreach ($file in $coreFiles) {
    Rename-FileIfExists -oldPath $file.Old -newPath $file.New
}

Write-Host "`nFile renaming completed!" -ForegroundColor Green
Write-Host "Please run update-file-references.js to update references in the codebase." 
