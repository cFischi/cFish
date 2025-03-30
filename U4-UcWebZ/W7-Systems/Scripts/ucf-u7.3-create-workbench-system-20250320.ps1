# ucf-u7.3-create-workbench-system-20250320.ps1
# Purpose: Creates standardized workbench folders across all main directories in the cFish.io workspace
# Author: Claude 3.7 Sonnet
# Date: 2025-03-20
# Version: 1.0

# Strict mode for better error detection
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

##### Workspace root directory (get parent of current script location)
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$workspaceRoot = (Get-Item $scriptDir).Parent.Parent.FullName

##### Output header
Write-Host "`n=========================================================="
Write-Host "   cFish.io Workbench System Creation Tool - v1.0"
Write-Host "   Creation Date: $(Get-Date -Format 'yyyy-MM-dd')"
Write-Host "==========================================================`n"

##### Function to create a standardized workbench folder structure
function New-WorkbenchFolder {
    param (
        [Parameter(Mandatory=$true)]
        [string]$DirectoryPath,
        
        [Parameter(Mandatory=$true)]
        [string]$Abbreviation,
        
        [Parameter(Mandatory=$false)]
        [string]$Description = ""
    )
    
    ##### Full path to the workbench folder
    $workbenchPath = Join-Path -Path $DirectoryPath -ChildPath "${Abbreviation}-WB"
    
    ##### Check if workbench already exists
    if (Test-Path $workbenchPath) {
        Write-Host "Workbench already exists: ${workbenchPath}" -ForegroundColor Yellow
        return $false
    }
    
    try {
        ##### Create main workbench folder
        New-Item -Path $workbenchPath -ItemType Directory -Force | Out-Null
        
        ##### Create standard subfolders
        New-Item -Path (Join-Path -Path $workbenchPath -ChildPath "active") -ItemType Directory -Force | Out-Null
        New-Item -Path (Join-Path -Path $workbenchPath -ChildPath "WB-readme") -ItemType Directory -Force | Out-Null
        New-Item -Path (Join-Path -Path $workbenchPath -ChildPath "next-WB") -ItemType Directory -Force | Out-Null
        New-Item -Path (Join-Path -Path $workbenchPath -ChildPath "next-readme") -ItemType Directory -Force | Out-Null
        
        ##### Create WB-memory.md file
        $memoryContent = @"
## ${Abbreviation}-WB Workbench Creation ($(Get-Date -Format 'MM-dd-yyyy'))
- Created standardized workbench folder for $Description
- Added four standard subfolders:
  - active: Contains 1-3 items currently being worked on
  - WB-readme: Contains README files for active items
  - next-WB: Contains items to be worked on next
  - next-readme: Contains README files for next items
- This workbench follows the cFish.io workbench system standardization

_Updated $(Get-Date -Format 'MM-dd-yyyy') | AI: Cursor (Claude 3.7 Sonnet)_
"@
        Set-Content -Path (Join-Path -Path $workbenchPath -ChildPath "WB-memory.md") -Value $memoryContent
        
        Write-Host "Created workbench: ${Abbreviation}-WB for $Description" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "Error creating workbench ${Abbreviation}-WB: $_" -ForegroundColor Red
        return $false
    }
}

##### Main directories to create workbenches in
$mainDirectories = @(
    @{Path = (Join-Path -Path $workspaceRoot -ChildPath "U1-Administration"); Abbr = "U1"; Desc = "U1-Administration"},
    @{Path = (Join-Path -Path $workspaceRoot -ChildPath "U2-Research"); Abbr = "U2"; Desc = "U2-Research"},
    @{Path = (Join-Path -Path $workspaceRoot -ChildPath "U3-Operations"); Abbr = "U3"; Desc = "U3-Operations"},
    @{Path = (Join-Path -Path $workspaceRoot -ChildPath "U4-Production"); Abbr = "U4"; Desc = "U4-Production"},
    @{Path = (Join-Path -Path $workspaceRoot -ChildPath "U5-Data"); Abbr = "U5"; Desc = "U5-Data"},
    @{Path = (Join-Path -Path $workspaceRoot -ChildPath "U6-Marketing"); Abbr = "U6"; Desc = "U6-Marketing"},
    @{Path = (Join-Path -Path $workspaceRoot -ChildPath "U7-Systems"); Abbr = "U7"; Desc = "U7-Systems"},
    @{Path = (Join-Path -Path $workspaceRoot -ChildPath "wp-content"); Abbr = "WP"; Desc = "wp-content"},
    @{Path = (Join-Path -Path $workspaceRoot -ChildPath "_Archives"); Abbr = "arc"; Desc = "_Archives"},
    @{Path = (Join-Path -Path $workspaceRoot -ChildPath "_Resources"); Abbr = "resour"; Desc = "_Resources"},
    @{Path = (Join-Path -Path $workspaceRoot -ChildPath ".cursor"); Abbr = "curs"; Desc = ".cursor"},
    @{Path = (Join-Path -Path $workspaceRoot -ChildPath "Documentation"); Abbr = "docs"; Desc = "Documentation"}
)

##### Create workbenches in all specified directories
$created = 0
$skipped = 0
$failed = 0

Write-Host "Creating workbench folders...`n"

foreach ($dir in $mainDirectories) {
    ##### Skip if directory doesn't exist
    if (-not (Test-Path $dir.Path)) {
        Write-Host "Directory doesn't exist, skipping: $($dir.Path)" -ForegroundColor Yellow
        $skipped++
        continue
    }
    
    ##### Create workbench
    $result = New-WorkbenchFolder -DirectoryPath $dir.Path -Abbreviation $dir.Abbr -Description $dir.Desc
    
    if ($result) {
        $created++
    } else {
        $failed++
    }
}

##### Output summary
Write-Host "`n=========================================================="
Write-Host "                    SUMMARY"
Write-Host "==========================================================`n"
Write-Host "Workbenches created: $created"
Write-Host "Directories skipped: $skipped"
Write-Host "Failures: $failed"
Write-Host "`nTotal directories processed: $($mainDirectories.Count)"
Write-Host "`nWorkbench system creation complete!"
Write-Host "`nNext Steps:"
Write-Host "1. Update the memory.md file with workbench implementation details"
Write-Host "2. Run ucf-u7.3-update-workbench-system-20250320.ps1 to enhance workbenches"
Write-Host "3. Begin organizing active projects into appropriate workbenches"
Write-Host "==========================================================`n" 
