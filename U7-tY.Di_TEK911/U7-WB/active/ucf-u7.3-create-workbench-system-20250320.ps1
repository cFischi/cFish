<#
.SYNOPSIS
    Creates a standardized workbench system across the cFish.io organization.
.DESCRIPTION
    This script creates a workbench (WB) folder in each main-level directory according
    to the specified naming convention. Each workbench contains standardized subfolders
    for active work, READMEs, and next items. Excludes backup folders.
.NOTES
    File Name      : ucf-u7.3-create-workbench-system-20250320.ps1
    Author         : Claude (AI Assistant)
    Prerequisite   : PowerShell
    Date           : March 20, 2025
#>

# Define the directories where workbench folders should be created
$targetDirectories = @(
    @{ Path = "U1-Administration"; Abbreviation = "U1" },
    @{ Path = "U2-Research"; Abbreviation = "U2" },
    @{ Path = "U3-Operations"; Abbreviation = "U3" },
    @{ Path = "U4-Production"; Abbreviation = "U4" },
    @{ Path = "U5-Data"; Abbreviation = "U5" },
    @{ Path = "U6-Marketing"; Abbreviation = "U6" },
    @{ Path = "U7-Systems"; Abbreviation = "U7" },
    @{ Path = "wp-content"; Abbreviation = "WP" },
    @{ Path = "_Archives"; Abbreviation = "arc" },
    @{ Path = "_Resources"; Abbreviation = "resour" },
    @{ Path = ".cursor"; Abbreviation = "curs" },
    @{ Path = "Documentation"; Abbreviation = "docs" }
)

##### Function to create a workbench folder with standard subfolders
function New-WorkbenchFolder {
    param (
        [string]$ParentPath,
        [string]$Abbreviation
    )

    ##### Create the workbench folder
    $workbenchName = "$Abbreviation-WB"
    $workbenchPath = Join-Path -Path $ParentPath -ChildPath $workbenchName
    
    if (-not (Test-Path -Path $workbenchPath)) {
        Write-Host "Creating workbench folder: $workbenchPath"
        New-Item -Path $workbenchPath -ItemType Directory -Force | Out-Null
        
        ##### Create standard subfolders in the workbench
        $subfolders = @(
            "active",
            "WB-readme",
            "next-WB",
            "next-readme"
        )
        
        foreach ($subfolder in $subfolders) {
            $subfolderPath = Join-Path -Path $workbenchPath -ChildPath $subfolder
            Write-Host "  Creating subfolder: $subfolderPath"
            New-Item -Path $subfolderPath -ItemType Directory -Force | Out-Null
        }
        
        ##### Create a WB-memory.md file in the workbench folder
        $memoryFilePath = Join-Path -Path $workbenchPath -ChildPath "WB-memory.md"
        $currentDate = Get-Date -Format "MM-dd-yyyy"
        $memoryContent = @"
###### $workbenchName Workbench Creation ($currentDate)
- Created standardized workbench folder for $ParentPath
- Implemented standard subfolder structure:
  - active: Contains 1-3 items currently being worked on
  - WB-readme: Contains README files for active items
  - next-WB: Contains items to be worked on next
  - next-readme: Contains README files for next items
- This workbench follows the cFish.io workbench system standardization

_Updated $currentDate | AI: Cursor (Claude 3.7 Sonnet)_
"@
        Write-Host "  Creating WB-memory.md file"
        Set-Content -Path $memoryFilePath -Value $memoryContent
    }
    else {
        Write-Host "Workbench folder already exists: $workbenchPath"
    }
    
    return $workbenchPath
}

##### Main execution
$createdWorkbenches = @()

foreach ($dir in $targetDirectories) {
    $path = $dir.Path
    $abbreviation = $dir.Abbreviation
    
    if (Test-Path -Path $path) {
        $workbenchPath = New-WorkbenchFolder -ParentPath $path -Abbreviation $abbreviation
        $createdWorkbenches += [PSCustomObject]@{
            Directory = $path
            Workbench = Split-Path -Path $workbenchPath -Leaf
        }
    }
    else {
        Write-Host "Directory not found: $path" -ForegroundColor Yellow
    }
}

##### Output summary
Write-Host "`nWorkbench System Creation Summary:" -ForegroundColor Cyan
Write-Host "--------------------------------" -ForegroundColor Cyan
$createdWorkbenches | Format-Table -AutoSize

##### Update memory.md with the workbench system creation
$memoryFilePath = "memory.md"
if (Test-Path -Path $memoryFilePath) {
    $currentDate = Get-Date -Format "MM-dd-yyyy"
    $memoryEntry = @"
###### Workbench System Implementation ($currentDate)
- Created standardized workbench system across all main directories in the cFish.io workspace
- Implemented ${$createdWorkbenches.Count} workbench folders with standard naming convention ([Abbreviation]-WB)
- Each workbench contains four standard subfolders:
  - active: Contains 1-3 items currently being worked on
  - WB-readme: Contains README files for active items
  - next-WB: Contains items to be worked on next
  - next-readme: Contains README files for next items
- Created individual WB-memory.md files in each workbench for tracking changes
- Workbench folders created:
$(foreach ($wb in $createdWorkbenches) { "  - $($wb.Directory): $($wb.Workbench)" })
- This system provides consistent working areas across all departments while maintaining UcF structure
- Each workbench follows proper naming conventions and documentation standards

_Updated $currentDate | AI: Cursor (Claude 3.7 Sonnet)_

"@
    
    ##### Get current content and add new entry after the first line
    $memoryContent = Get-Content -Path $memoryFilePath
    $newContent = @($memoryContent[0], $memoryEntry) + $memoryContent[1..($memoryContent.Length-1)]
    Set-Content -Path $memoryFilePath -Value $newContent
    
    Write-Host "`nUpdated memory.md with workbench system implementation details" -ForegroundColor Green
}
else {
    Write-Host "`nWarning: memory.md file not found. Could not update with implementation details." -ForegroundColor Yellow
}

Write-Host "`nWorkbench system creation completed successfully!" -ForegroundColor Green 
