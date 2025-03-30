<#
.SYNOPSIS
    Updates the cFish.io workbench system with additional features.
.DESCRIPTION
    This script adds changelog files to all existing workbenches and
    creates a master cFish.io workbench folder at the top level.
.NOTES
    File Name      : ucf-u7.3-update-workbench-system-20250320.ps1
    Author         : Claude (AI Assistant)
    Prerequisite   : PowerShell
    Date           : March 20, 2025
#>

# Get all existing workbench folders
Write-Host "Finding all existing workbench folders..." -ForegroundColor Cyan
$workbenchFolders = Get-ChildItem -Path ".\*\*-WB" -Directory
Write-Host "Found $($workbenchFolders.Count) workbench folders." -ForegroundColor Green

##### Add changelog files to all existing workbenches
Write-Host "`nAdding changelog files to all workbenches..." -ForegroundColor Cyan
foreach ($wb in $workbenchFolders) {
    $changelogPath = Join-Path -Path $wb.FullName -ChildPath "WB-changelog.md"
    if (-not (Test-Path -Path $changelogPath)) {
        $wbName = $wb.Name
        $parentFolder = Split-Path -Path $wb.FullName -Parent
        $parentFolderName = Split-Path -Path $parentFolder -Leaf
        
        $currentDate = Get-Date -Format "MM-dd-yyyy"
        $changelogContent = @"
##### $wbName Changelog

This file tracks all significant changes made in the $parentFolderName workbench area.

###### Initial Workbench Setup ($currentDate)
- Created standardized workbench folder for $parentFolderName
- Implemented standard subfolder structure (active, WB-readme, next-WB, next-readme)
- Added WB-memory.md for tracking workbench activities
- Added WB-changelog.md for tracking significant changes

_Updated $currentDate | AI: Cursor (Claude 3.7 Sonnet)_
"@
        Write-Host "  Creating changelog file: $changelogPath"
        Set-Content -Path $changelogPath -Value $changelogContent
    }
    else {
        Write-Host "  Changelog file already exists: $changelogPath" -ForegroundColor Yellow
    }
}

##### Create master cFish.io workbench folder at the top level
Write-Host "`nCreating master cFish.io workbench folder..." -ForegroundColor Cyan
$masterWbName = "cFish-WB"
$masterWbPath = ".\" + $masterWbName

if (-not (Test-Path -Path $masterWbPath)) {
    Write-Host "  Creating master workbench folder: $masterWbPath"
    New-Item -Path $masterWbPath -ItemType Directory -Force | Out-Null
    
    ##### Create standard subfolders in the master workbench
    $subfolders = @(
        "active",
        "WB-readme",
        "next-WB",
        "next-readme"
    )
    
    foreach ($subfolder in $subfolders) {
        $subfolderPath = Join-Path -Path $masterWbPath -ChildPath $subfolder
        Write-Host "  Creating subfolder: $subfolderPath"
        New-Item -Path $subfolderPath -ItemType Directory -Force | Out-Null
    }
    
    ##### Create memory and changelog files for the master workbench
    $currentDate = Get-Date -Format "MM-dd-yyyy"
    
    ##### Memory file
    $memoryFilePath = Join-Path -Path $masterWbPath -ChildPath "WB-memory.md"
    $memoryContent = @"
###### $masterWbName Master Workbench Creation ($currentDate)
- Created master workbench folder for all cFish.io UcF projects
- Implemented standard subfolder structure:
  - active: Contains 1-3 items currently being worked on at the cFish.io organization level
  - WB-readme: Contains README files for active items
  - next-WB: Contains items to be worked on next at the organization level
  - next-readme: Contains README files for next items
- This workbench serves as the master workbench for all cFish.io master UcF projects
- Located at the top level of the cFish.io workspace to signify its master status

_Updated $currentDate | AI: Cursor (Claude 3.7 Sonnet)_
"@
    Write-Host "  Creating WB-memory.md file"
    Set-Content -Path $memoryFilePath -Value $memoryContent
    
    ##### Changelog file
    $changelogFilePath = Join-Path -Path $masterWbPath -ChildPath "WB-changelog.md"
    $changelogContent = @"
##### $masterWbName Master Changelog

This file tracks all significant changes made in the master cFish.io workbench area.

###### Initial Master Workbench Setup ($currentDate)
- Created master workbench folder for all cFish.io UcF projects
- Implemented standard subfolder structure (active, WB-readme, next-WB, next-readme)
- Added WB-memory.md for tracking workbench activities
- Added WB-changelog.md for tracking significant changes
- Positioned as the top-level folder in the cFish.io workspace

_Updated $currentDate | AI: Cursor (Claude 3.7 Sonnet)_
"@
    Write-Host "  Creating WB-changelog.md file"
    Set-Content -Path $changelogFilePath -Value $changelogContent
    
    ##### Create README for the master workbench
    $readmeFilePath = Join-Path -Path $masterWbPath -ChildPath "README.md"
    $readmeContent = @"
##### cFish.io Master Workbench

This is the master workbench for all cFish.io Universal cFish (UcF) projects at the organization level. It serves as the central point for coordinating and tracking work across all departments and workbenches.

###### Purpose
- Manage organization-wide initiatives that span multiple departments
- Track high-level UcF projects that impact the entire cFish.io workspace
- Provide a centralized view of the most critical active and upcoming work
- Coordinate cross-departmental collaboration

###### Usage Guidelines
- Only organization-wide initiatives should be placed in this workbench
- Department-specific work should remain in the appropriate departmental workbench
- All items must have corresponding documentation following UcF standards
- Regular review of the master workbench should be conducted by all department heads

###### Relationship to Other Workbenches
The master workbench coordinates with but does not replace departmental workbenches. Work items in the master workbench may have components in multiple departmental workbenches, which should be clearly documented.

_Updated $currentDate | AI: Cursor (Claude 3.7 Sonnet)_
"@
    Write-Host "  Creating README.md file"
    Set-Content -Path $readmeFilePath -Value $readmeContent
}
else {
    Write-Host "  Master workbench folder already exists: $masterWbPath" -ForegroundColor Yellow
}

##### Update memory.md with the workbench system update information
$memoryFilePath = "memory.md"
if (Test-Path -Path $memoryFilePath) {
    $currentDate = Get-Date -Format "MM-dd-yyyy"
    $memoryEntry = @"
###### Workbench System Enhancement ($currentDate)
- Added WB-changelog.md files to all workbench folders for better change tracking
- Created master cFish.io workbench (cFish-WB) at the top level of the workspace
- The master workbench serves as the central point for all cFish.io master UcF projects
- Enhanced workbench system follows a hierarchical structure with the master workbench at the top
- Each workbench now contains four standard subfolders plus two tracking files:
  - active: Contains 1-3 items currently being worked on
  - WB-readme: Contains README files for active items
  - next-WB: Contains items to be worked on next
  - next-readme: Contains README files for next items
  - WB-memory.md: Tracks changes and activities in the workbench
  - WB-changelog.md: Records significant changes and their rationale
- This enhancement provides consistent documentation and tracking across all workbench levels

_Updated $currentDate | AI: Cursor (Claude 3.7 Sonnet)_

"@
    
    # Get current content and add new entry after the first line
    $memoryContent = Get-Content -Path $memoryFilePath
    $newContent = @($memoryContent[0], $memoryEntry) + $memoryContent[1..($memoryContent.Length-1)]
    Set-Content -Path $memoryFilePath -Value $newContent
    
    Write-Host "`nUpdated memory.md with workbench system enhancement details" -ForegroundColor Green
}
else {
    Write-Host "`nWarning: memory.md file not found. Could not update with enhancement details." -ForegroundColor Yellow
}

Write-Host "`nWorkbench system update completed successfully!" -ForegroundColor Green 
