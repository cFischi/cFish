# ucf-u7.3-update-workbench-system-20250320.ps1
# Purpose: Enhances existing workbench folders with changelog files and creates master workbench
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
Write-Host "   cFish.io Workbench System Enhancement Tool - v1.0"
Write-Host "   Creation Date: $(Get-Date -Format 'yyyy-MM-dd')"
Write-Host "==========================================================`n"

##### Function to add a changelog file to an existing workbench
function Add-WorkbenchChangelog {
    param (
        [Parameter(Mandatory=$true)]
        [string]$WorkbenchPath,
        
        [Parameter(Mandatory=$true)]
        [string]$Abbreviation,
        
        [Parameter(Mandatory=$false)]
        [string]$Description = ""
    )
    
    ##### Check if workbench exists
    if (-not (Test-Path $WorkbenchPath)) {
        Write-Host "Workbench doesn't exist: ${WorkbenchPath}" -ForegroundColor Red
        return $false
    }
    
    ##### Path to changelog file
    $changelogPath = Join-Path -Path $WorkbenchPath -ChildPath "WB-changelog.md"
    
    ##### Check if changelog already exists
    if (Test-Path $changelogPath) {
        Write-Host "Changelog already exists: ${changelogPath}" -ForegroundColor Yellow
        return $false
    }
    
    try {
        ##### Create changelog file
        $changelogContent = @"
# ${Abbreviation}-WB Changelog

This file tracks all significant changes made in the $Description workbench area.

## Initial Workbench Setup ($(Get-Date -Format 'MM-dd-yyyy'))
- Created standardized workbench folder for $Description
- Added standard subfolders (active, WB-readme, next-WB, next-readme)
- Added WB-memory.md for tracking workbench activities
- Added this WB-changelog.md file for tracking significant changes

_Updated $(Get-Date -Format 'MM-dd-yyyy') | AI: Cursor (Claude 3.7 Sonnet)_
"@
        Set-Content -Path $changelogPath -Value $changelogContent
        
        ##### Update the memory file with changelog creation information
        $memoryPath = Join-Path -Path $WorkbenchPath -ChildPath "WB-memory.md"
        if (Test-Path $memoryPath) {
            $memoryEntry = @"

###### ${Abbreviation}-WB Changelog Addition ($(Get-Date -Format 'MM-dd-yyyy'))
- Added WB-changelog.md to track significant changes to the workbench
- Supports better historical tracking of workbench evolution
- Follows standardized changelog format for consistency

_Updated $(Get-Date -Format 'MM-dd-yyyy') | AI: Cursor (Claude 3.7 Sonnet)_
"@
            Add-Content -Path $memoryPath -Value $memoryEntry
        }
        
        Write-Host "Added changelog to workbench: ${Abbreviation}-WB" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "Error adding changelog to ${Abbreviation}-WB: $_" -ForegroundColor Red
        return $false
    }
}

##### Function to create the master workbench
function New-MasterWorkbench {
    try {
        ##### Master workbench path
        $masterWbPath = Join-Path -Path $workspaceRoot -ChildPath "cFish-WB"
        
        ##### Create master workbench if it doesn't exist
        if (Test-Path $masterWbPath) {
            Write-Host "Master workbench already exists: ${masterWbPath}" -ForegroundColor Yellow
            return $false
        }
        
        ##### Create main workbench folder
        New-Item -Path $masterWbPath -ItemType Directory -Force | Out-Null
        
        ##### Create standard subfolders
        New-Item -Path (Join-Path -Path $masterWbPath -ChildPath "active") -ItemType Directory -Force | Out-Null
        New-Item -Path (Join-Path -Path $masterWbPath -ChildPath "WB-readme") -ItemType Directory -Force | Out-Null
        New-Item -Path (Join-Path -Path $masterWbPath -ChildPath "next-WB") -ItemType Directory -Force | Out-Null
        New-Item -Path (Join-Path -Path $masterWbPath -ChildPath "next-readme") -ItemType Directory -Force | Out-Null
        
        ##### Create WB-memory.md file
        $memoryContent = @"
## Master Workbench Creation ($(Get-Date -Format 'MM-dd-yyyy'))
- Created master cFish.io workbench at the top level of the workspace
- This workbench serves as the central point for all cFish.io master UcF projects
- Added four standard subfolders:
  - active: Contains 1-3 organization-wide items currently being worked on
  - WB-readme: Contains README files for active organization-wide items
  - next-WB: Contains organization-wide items to be worked on next
  - next-readme: Contains README files for next organization-wide items
- The master workbench provides a hierarchical structure with department workbenches

_Updated $(Get-Date -Format 'MM-dd-yyyy') | AI: Cursor (Claude 3.7 Sonnet)_
"@
        Set-Content -Path (Join-Path -Path $masterWbPath -ChildPath "WB-memory.md") -Value $memoryContent
        
        ##### Create WB-changelog.md file
        $changelogContent = @"
# Master Workbench Changelog

This file tracks all significant changes made in the cFish.io master workbench.

## Initial Master Workbench Setup ($(Get-Date -Format 'MM-dd-yyyy'))
- Created master workbench at the top level of the workspace
- Added standard subfolders (active, WB-readme, next-WB, next-readme)
- Added WB-memory.md for tracking master workbench activities
- Added this WB-changelog.md file for tracking significant changes
- Positioned as the top-level workbench in the hierarchical structure

_Updated $(Get-Date -Format 'MM-dd-yyyy') | AI: Cursor (Claude 3.7 Sonnet)_
"@
        Set-Content -Path (Join-Path -Path $masterWbPath -ChildPath "WB-changelog.md") -Value $changelogContent
        
        ##### Create README.md for master workbench
        $readmeContent = @"
# cFish.io Master Workbench

This is the master workbench for cFish.io, serving as the central point for organization-wide UcF projects and cross-departmental coordination.

## Purpose

The master workbench provides a hierarchical structure for all workbenches in the cFish.io system:

- **Master Workbench (cFish-WB)** - For organization-wide UcF projects
  - **Department Workbenches (U1-WB through U7-WB)** - For department-specific projects
  - **Supporting Workbenches** - For area-specific projects

## Structure

The master workbench follows the standard workbench structure:

- **active/** - Contains 1-3 organization-wide items currently being worked on
- **WB-readme/** - Contains README files for active organization-wide items
- **next-WB/** - Contains organization-wide items to be worked on next
- **next-readme/** - Contains README files for next organization-wide items

## Documentation

- **WB-memory.md** - Records all activities and changes in the master workbench
- **WB-changelog.md** - Records significant structural or functional changes to the master workbench

## Example Projects

Place organization-wide projects that span multiple departments in this workbench. Examples include:

- Company-wide reorganization initiatives
- Cross-departmental process improvements
- Major system upgrades affecting all departments
- Strategic planning documents

_Created $(Get-Date -Format 'MM-dd-yyyy') | AI: Cursor (Claude 3.7 Sonnet)_
"@
        Set-Content -Path (Join-Path -Path $masterWbPath -ChildPath "README.md") -Value $readmeContent
        
        ##### Create example project in active folder
        $exampleDir = Join-Path -Path $masterWbPath -ChildPath "active\workbench-integration-example"
        New-Item -Path $exampleDir -ItemType Directory -Force | Out-Null
        
        $exampleProjectContent = @"
##### Workbench Integration Example

This is an example project to demonstrate how to use the workbench system for organization-wide initiatives.

###### Project Details

- **Project Name:** Workbench System Integration
- **Start Date:** $(Get-Date -Format 'yyyy-MM-dd')
- **Estimated Completion:** $(Get-Date).AddDays(30).ToString('yyyy-MM-dd')
- **Owner:** U1-Administration
- **Status:** In Progress

###### Departments Involved

- U1-Administration: Overall coordination
- U5-Data: Documentation and tracking
- U7-Systems: Technical implementation and support

###### Key Deliverables

1. Department briefing materials
2. Training documentation
3. Project migration guidelines
4. Compliance review process

###### Next Steps

See the corresponding README in the WB-readme folder for detailed implementation steps.

_Created $(Get-Date -Format 'MM-dd-yyyy') | AI: Cursor (Claude 3.7 Sonnet)_
"@
        Set-Content -Path (Join-Path -Path $exampleDir -ChildPath "workbench-integration-plan.md") -Value $exampleProjectContent
        
        ##### Create example README in WB-readme folder
        $exampleReadmeContent = @"
# Workbench Integration Example - README

This README provides detailed guidance for implementing the Workbench System Integration project.

## Implementation Plan

### Phase 1: Awareness (Days 1-7)
- Schedule department briefing
- Distribute introduction materials
- Begin initial project migration

### Phase 2: Adoption (Days 8-30)
- Complete project migration
- Conduct staff training
- Develop supporting tools

### Phase 3: Integration (Days 31-90)
- Integrate with other systems
- Implement automation
- Document best practices

### Phase 4: Optimization (Beyond Day 90)
- Review effectiveness
- Implement improvements
- Extend functionality

## Specific Department Responsibilities

### U1-Administration
- Schedule and lead department briefing
- Develop training materials
- Monitor adoption rates

### U5-Data
- Update existing documentation
- Track implementation metrics
- Integrate with DMMS

### U7-Systems
- Develop synchronization tools
- Create reporting system
- Provide technical support

## Success Metrics

- 100% project migration by day 30
- 100% departmental compliance by day 45
- 100% documentation quality by day 60
- 90% cross-departmental integration by day 90
- 85% user satisfaction by day 90

_Created $(Get-Date -Format 'MM-dd-yyyy') | AI: Cursor (Claude 3.7 Sonnet)_
"@
        Set-Content -Path (Join-Path -Path $masterWbPath -ChildPath "WB-readme\workbench-integration-example-README.md") -Value $exampleReadmeContent
        
        Write-Host "Created master workbench: cFish-WB" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "Error creating master workbench: $_" -ForegroundColor Red
        return $false
    }
}

##### Function to update memory.md with workbench enhancement information
function Update-MemoryMd {
    try {
        $memoryPath = Join-Path -Path $workspaceRoot -ChildPath "memory.md"
        if (-not (Test-Path $memoryPath)) {
            Write-Host "memory.md file not found at: $memoryPath" -ForegroundColor Red
            return $false
        }
        
        $memoryEntry = @"
###### Workbench System Enhancement ($(Get-Date -Format 'MM-dd-yyyy'))
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

_Updated $(Get-Date -Format 'MM-dd-yyyy') | AI: Cursor (Claude 3.7 Sonnet)_

"@ + (Get-Content -Path $memoryPath -Raw)
        
        Set-Content -Path $memoryPath -Value $memoryEntry
        
        Write-Host "Updated memory.md with workbench enhancement information" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "Error updating memory.md: $_" -ForegroundColor Red
        return $false
    }
}

##### Find all existing workbench folders
$workbenches = @()
$mainDirectories = @(
    (Join-Path -Path $workspaceRoot -ChildPath "U1-Administration"),
    (Join-Path -Path $workspaceRoot -ChildPath "U2-Research"),
    (Join-Path -Path $workspaceRoot -ChildPath "U3-Operations"),
    (Join-Path -Path $workspaceRoot -ChildPath "U4-Production"),
    (Join-Path -Path $workspaceRoot -ChildPath "U5-Data"),
    (Join-Path -Path $workspaceRoot -ChildPath "U6-Marketing"),
    (Join-Path -Path $workspaceRoot -ChildPath "U7-Systems"),
    (Join-Path -Path $workspaceRoot -ChildPath "wp-content"),
    (Join-Path -Path $workspaceRoot -ChildPath "_Archives"),
    (Join-Path -Path $workspaceRoot -ChildPath "_Resources"),
    (Join-Path -Path $workspaceRoot -ChildPath ".cursor"),
    (Join-Path -Path $workspaceRoot -ChildPath "Documentation")
)

Write-Host "Finding existing workbench folders...`n"

foreach ($dir in $mainDirectories) {
    if (Test-Path $dir) {
        $dirInfo = Get-Item $dir
        $abbr = switch ($dirInfo.Name) {
            "U1-Administration" { "U1"; break }
            "U2-Research" { "U2"; break }
            "U3-Operations" { "U3"; break }
            "U4-Production" { "U4"; break }
            "U5-Data" { "U5"; break }
            "U6-Marketing" { "U6"; break }
            "U7-Systems" { "U7"; break }
            "wp-content" { "WP"; break }
            "_Archives" { "arc"; break }
            "_Resources" { "resour"; break }
            ".cursor" { "curs"; break }
            "Documentation" { "docs"; break }
            default { $null; break }
        }
        
        if ($abbr) {
            $workbenchPath = Join-Path -Path $dir -ChildPath "${abbr}-WB"
            if (Test-Path $workbenchPath) {
                $workbenches += @{
                    Path = $workbenchPath
                    Abbr = $abbr
                    Desc = $dirInfo.Name
                }
            }
        }
    }
}

##### Enhance each workbench with a changelog file
$enhanced = 0
$skipped = 0
$failed = 0

Write-Host "Enhancing existing workbenches with changelog files...`n"

foreach ($wb in $workbenches) {
    $result = Add-WorkbenchChangelog -WorkbenchPath $wb.Path -Abbreviation $wb.Abbr -Description $wb.Desc
    
    if ($result) {
        $enhanced++
    } else {
        $skipped++
    }
}

##### Create master workbench
Write-Host "`nCreating master workbench at top level...`n"
$masterResult = New-MasterWorkbench
$masterStatus = if ($masterResult) { "Created" } else { "Skipped/Failed" }

##### Update memory.md with enhancement information
Write-Host "`nUpdating memory.md with workbench enhancement information...`n"
$memoryResult = Update-MemoryMd
$memoryStatus = if ($memoryResult) { "Updated" } else { "Failed" }

##### Output summary
Write-Host "`n=========================================================="
Write-Host "                    SUMMARY"
Write-Host "==========================================================`n"
Write-Host "Workbenches enhanced with changelog files: $enhanced"
Write-Host "Workbenches skipped (changelog already exists): $skipped"
Write-Host "Enhancement failures: $failed"
Write-Host "Master workbench: $masterStatus"
Write-Host "Memory.md update: $memoryStatus"
Write-Host "`nTotal workbenches processed: $($workbenches.Count)"
Write-Host "`nWorkbench system enhancement complete!"
Write-Host "`nNext Steps:"
Write-Host "1. Create comprehensive documentation for the workbench system"
Write-Host "2. Begin department briefings for organization-wide adoption"
Write-Host "3. Start migrating active projects to appropriate workbenches"
Write-Host "==========================================================`n" 
