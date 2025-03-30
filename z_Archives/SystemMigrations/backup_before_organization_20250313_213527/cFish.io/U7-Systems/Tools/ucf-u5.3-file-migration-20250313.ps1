# ucf-u5.3-file-migration-20250313.ps1
# File Migration Script for cFish.io Digital Organization

# Define file movement rules
$fileRules = @{
    # WordPress files
    "wp-content*" = "cFish.io/U4-Production/WordPress"
    "wordpress*.md" = "cFish.io/U4-Production/WordPress"
    
    ##### Sync system files
    "sync-system*" = "cFish.io/U5-Data/Synchronization/tydisync"
    "sync-*.md" = "cFish.io/U5-Data/Synchronization"
    "*-sync-*.md" = "cFish.io/U5-Data/Synchronization"
    "*-sync-*.json" = "cFish.io/U5-Data/Synchronization"
    
    ##### tYDiSync files 
    "tydisync*" = "cFish.io/U7-Systems/Development/tYDiSync"
    
    ##### DreamFlo files
    "dreamflo*" = "cFish.io/U7-Systems/Development/DreamFlo"
    
    ##### Documentation files
    "memory.md" = "cFish.io/Documentation"
    "README.md" = "cFish.io/Documentation"
    "sop.md" = "cFish.io/U3-Operations/SOP"
    "spec.md" = "cFish.io/Documentation/Technical"
    "changelog.md" = "cFish.io/Documentation"
    
    ##### Scripts
    "*.js" = "cFish.io/U7-Systems/Development/scripts"
    "create-cfish-organization.ps1" = "cFish.io/U7-Systems/Tools"
    "create-tydisync-structure.ps1" = "cFish.io/U7-Systems/Tools"
    "create-assessment-report.ps1" = "cFish.io/U7-Systems/Tools"
    "create-directory-structure.ps1" = "cFish.io/U7-Systems/Tools"
    "*.bat" = "cFish.io/U7-Systems/Tools"
    
    ##### Test files
    "test-*" = "cFish.io/U7-Systems/Development/tests"
    "tests/*" = "cFish.io/U7-Systems/Development/tests"
    
    ##### Logs
    "logs/*" = "cFish.io/U3-Operations/Monitoring/logs"
    
    ##### Backups
    "backups/*" = "cFish.io/U5-Data/Backups"
    
    ##### Configuration
    "config/*" = "cFish.io/U7-Systems/Development/config"
    
    ##### Tools
    "tools/*" = "cFish.io/U7-Systems/Tools"
    
    ##### Markdown reference files
    "*.md" = "cFish.io/_Resources/References"
}

##### Function to move files based on rules
function Move-Files {
    $movedCount = 0
    $skippedCount = 0
    
    foreach ($pattern in $fileRules.Keys) {
        $destination = $fileRules[$pattern]
        $filesToMove = Get-ChildItem -Path $pattern -ErrorAction SilentlyContinue
        
        foreach ($file in $filesToMove) {
            ##### Skip directories with important subdirectories
            if ($file.PSIsContainer -and 
                ($file.Name -eq "cFish.io" -or 
                 $file.Name -eq ".git" -or 
                 $file.Name -eq "node_modules")) {
                Write-Host "Skipping directory: $($file.FullName)"
                $skippedCount++
                continue
            }
            
            ##### Skip the migration script itself
            if ($file.Name -eq "ucf-u5.3-file-migration-20250313.ps1") {
                Write-Host "Skipping migration script: $($file.FullName)"
                $skippedCount++
                continue
            }
            
            $destPath = Join-Path -Path $destination -ChildPath $file.Name
            
            ##### Create destination directory if it doesn't exist
            if (-not (Test-Path (Split-Path -Path $destPath -Parent))) {
                New-Item -Path (Split-Path -Path $destPath -Parent) -ItemType Directory -Force | Out-Null
            }
            
            ##### Move file if it doesn't already exist at destination
            if (-not (Test-Path $destPath)) {
                try {
                    ##### For directories, copy content instead of moving
                    if ($file.PSIsContainer) {
                        ##### Create destination if it doesn't exist
                        if (-not (Test-Path $destPath)) {
                            New-Item -Path $destPath -ItemType Directory -Force | Out-Null
                        }
                        
                        ##### Copy contents recursively
                        Get-ChildItem -Path $file.FullName -Recurse | 
                        ForEach-Object {
                            $relativePath = $_.FullName.Substring($file.FullName.Length)
                            $targetPath = Join-Path -Path $destPath -ChildPath $relativePath
                            
                            if ($_.PSIsContainer) {
                                if (-not (Test-Path $targetPath)) {
                                    New-Item -Path $targetPath -ItemType Directory -Force | Out-Null
                                }
                            }
                            else {
                                Copy-Item -Path $_.FullName -Destination $targetPath -Force
                            }
                        }
                        Write-Host "Copied directory: $($file.FullName) -> $destPath"
                    }
                    else {
                        Move-Item -Path $file.FullName -Destination $destPath -Force
                        Write-Host "Moved file: $($file.FullName) -> $destPath"
                    }
                    $movedCount++
                }
                catch {
                    Write-Host "Error moving $($file.FullName): $_" -ForegroundColor Red
                    $skippedCount++
                }
            }
            else {
                Write-Host "Destination already exists: $destPath" -ForegroundColor Yellow
                $skippedCount++
            }
        }
    }
    
    return @{
        Moved = $movedCount
        Skipped = $skippedCount
    }
}

##### Main execution
Write-Host "Starting file migration..."
Write-Host "This script will organize files according to cFish.io structure."
Write-Host "Files will be migrated to their proper locations based on naming patterns."

$result = Move-Files

Write-Host "`nMigration completed!"
Write-Host "Files moved: $($result.Moved)"
Write-Host "Files skipped: $($result.Skipped)"
Write-Host "`nNext steps: Verify file migration and continue with system integration."

