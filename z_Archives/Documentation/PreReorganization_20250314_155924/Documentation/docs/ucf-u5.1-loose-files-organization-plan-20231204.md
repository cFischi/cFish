# Loose Files Organization Plan

## Overview

This document outlines the plan for organizing loose files across the cFish.io workspace according to the Digital Organization System. The files will be categorized based on their purpose and content, then placed in the appropriate UcF department-based directories.

## File Analysis and Organization

### WordPress Files
**Files identified**:
- `xmlrpc.php` (WordPress core file)

**Organization plan**:
- Move to `U4-Production/WordPress/` directory
- Do not rename (Critical Files Exception applies)

### Synchronization System Files
**Files identified**:
- `2way sync test.md` (Synchronization testing file)
- `sync-system/` directory
- `tydisync/` directory
- `create-tydisync-structure.ps1`

**Organization plan**:
- Move to `U5-Data/Synchronization/` directory
- Maintain original filenames for critical components
- Consider renaming non-critical files to follow convention: `ucf-u5.2-[description]-[date].[extension]`

### Script Files
**Files identified**:
- `scrape-ucfish-u.js`
- `scrape-cfish.js`
- `scripts/` directory
- Various PowerShell scripts (`.ps1` files)
- Batch files (`.bat` files)

**Organization plan**:
- Development scripts: Move to `U7-Systems/Development/Scripts/`
- Utility scripts: Move to `U7-Systems/Tools/`
- Scraping scripts: Move to `U2-Research/Analysis/Scraping/`
- Rename according to convention where appropriate: `ucf-u7.4-[script-purpose]-[date].[extension]`

### Documentation Files
**Files identified**:
- `cFish exec summary.md`
- `cFish-comprehensive-executive-summary.md`
- `cfish-io-file-management-summary-20250419.md`
- `cFish.io File Management System SOP.md`
- `cfish-io-organization-plan.md`
- `powershell-string-templates.md`
- `dreamflo-analysis-process.md`
- `dreamflo-system-analysis.md`
- Various markdown files

**Organization plan**:
- Executive documents: Move to `U1-Administration/Planning/`
- Technical documentation: Move to `Documentation/Technical/`
- Process documentation: Move to `Documentation/Process/`
- File naming checker docs: Keep in `docs/` directory
- Rename according to convention: `ucf-u1.1-[document-purpose]-[date].md`

### Log and Report Files
**Files identified**:
- `file-renaming-20250313_220438.log`
- `file-organization-continuation-20250313_220421.log`
- `file-naming-compliance-summary.md`
- `file-naming-standard-report.md`
- `file-naming-targeted-report.md`
- `logs/` directory

**Organization plan**:
- Move to `U5-Data/Reports/` directory
- Create subdirectories for different types of logs/reports
- Maintain original filenames for existing logs
- Ensure future logs follow naming convention

### Configuration and Data Files
**Files identified**:
- `package.json`
- `package-lock.json`
- `config/` directory

**Organization plan**:
- Move to `U7-Systems/Configuration/` directory
- Do not rename npm package files (Critical Files Exception)

### File Naming Checker Scripts
**Files identified**:
- `check-file-naming.ps1`
- `check-file-naming.bat`
- `check-file-naming-simple.ps1`
- `check-file-naming-simple.bat`
- `check-file-naming-standard.ps1`
- `check-file-naming-standard.bat`
- `check-file-naming-targeted.ps1`
- `check-file-naming-targeted.bat`
- `check-file-naming-quick.ps1`
- `check-file-naming-quick.bat`
- `check-file-naming-light.ps1`
- `check-file-naming-light.bat`

**Organization plan**:
- Move to `U5-Data/Tools/FilenameCheckers/` directory
- Create proper batch wrappers in root directory that reference tools in new location
- Rename according to convention: `ucf-u5.3-[checker-variant]-[date].[extension]`

### System Organization Scripts
**Files identified**:
- `create-cfish-organization.ps1`
- `organize-cfish-io.ps1`
- `organize-cfish-io.bat`
- `organize-dreamflo.ps1`
- `validate-directory-structure.ps1`
- `validate-directory-structure.bat`
- `create-test-environment.ps1`
- `create-test-environment.bat`
- `full-system-backup.ps1`
- `full-system-backup.bat`

**Organization plan**:
- Move to `U7-Systems/Tools/OrganizationSystem/` directory
- Create proper batch wrappers in root directory that reference tools in new location
- Rename according to convention: `ucf-u7.5-[script-purpose]-[date].[extension]`

### Legacy and Backup Directories
**Files identified**:
- `backup_before_organization_20250313_213527/` directory
- `backup_before_organization_20250313_213751/` directory
- `backup_before_organization_20250313_214239/` directory
- `dreamflo-system/` directory
- `dreamflo-system-organized/` directory

**Organization plan**:
- Move to `_Archives/SystemMigrations/` directory
- No renaming needed for backup directories

## Implementation Steps

1. **Preparation**:
   - Run `full-system-backup.bat` to create a complete backup before reorganization
   - Verify all UcF directory structure exists and is ready for file placement
   - Run `check-file-naming-standard.bat` to establish baseline compliance

2. **Phase 1: Critical System Files**:
   - Move WordPress files to appropriate U4-Production directory
   - Move synchronization system files to U5-Data/Synchronization
   - Update any references or configurations affected by the moves

3. **Phase 2: Tools and Scripts**:
   - Organize file naming checker scripts into U5-Data/Tools/FilenameCheckers
   - Organize system organization scripts into U7-Systems/Tools/OrganizationSystem
   - Create appropriate batch wrappers in the root directory

4. **Phase 3: Documentation and Reports**:
   - Move documentation files to appropriate directories
   - Organize log and report files

5. **Phase 4: Development and Configuration**:
   - Move remaining development scripts and configuration files
   - Organize test-related directories and files

6. **Phase 5: Archive and Clean-up**:
   - Move backup and legacy directories to _Archives
   - Remove any temporary files

7. **Verification**:
   - Run `validate-directory-structure.bat` to verify UcF structure integrity
   - Run `check-file-naming-standard.bat` to measure improvement in compliance

## PowerShell Implementation

A PowerShell script will be created to automate the organization process:

```powershell
# organize-loose-files.ps1
# Script to organize loose files according to UcF department structure

# Create necessary subdirectories if they don't exist
$directories = @(
    "U4-Production\WordPress",
    "U5-Data\Synchronization",
    "U5-Data\Reports",
    "U5-Data\Tools\FilenameCheckers",
    "U7-Systems\Development\Scripts",
    "U7-Systems\Tools\OrganizationSystem",
    "U7-Systems\Configuration",
    "U2-Research\Analysis\Scraping",
    "Documentation\Technical",
    "Documentation\Process",
    "_Archives\SystemMigrations"
)

foreach ($dir in $directories) {
    if (-not (Test-Path $dir)) {
        New-Item -Path $dir -ItemType Directory -Force
        Write-Host "Created directory: $dir" -ForegroundColor Green
    }
}

# Define file groups and their destinations
$fileGroups = @{
    "WordPress" = @{
        "Files" = @("xmlrpc.php"),
        "Destination" = "U4-Production\WordPress"
    }
    "Synchronization" = @{
        "Files" = @("2way sync test.md", "create-tydisync-structure.ps1"),
        "Directories" = @("sync-system", "tydisync"),
        "Destination" = "U5-Data\Synchronization"
    }
    # Add more file groups here
}

# Move files to their destinations
foreach ($group in $fileGroups.Keys) {
    $destination = $fileGroups[$group]["Destination"]
    
    if ($fileGroups[$group].ContainsKey("Files")) {
        foreach ($file in $fileGroups[$group]["Files"]) {
            if (Test-Path $file) {
                Move-Item -Path $file -Destination $destination -Force
                Write-Host "Moved $file to $destination" -ForegroundColor Yellow
            }
        }
    }
    
    if ($fileGroups[$group].ContainsKey("Directories")) {
        foreach ($dir in $fileGroups[$group]["Directories"]) {
            if (Test-Path $dir) {
                # For directories, we'll copy their contents to maintain any references
                $targetDir = Join-Path -Path $destination -ChildPath $dir
                if (-not (Test-Path $targetDir)) {
                    New-Item -Path $targetDir -ItemType Directory -Force
                }
                
                Copy-Item -Path "$dir\*" -Destination $targetDir -Recurse -Force
                Write-Host "Copied contents of $dir to $targetDir" -ForegroundColor Yellow
            }
        }
    }
}

# Create batch wrappers for important tools
# [Implementation would go here]

Write-Host "Organization of loose files completed successfully." -ForegroundColor Green
```

## Next Steps

1. Review this organization plan with the team
2. Create and test the implementation script
3. Execute the plan in phases
4. Update documentation to reflect the new organization
5. Train team members on the new file locations

---

_Updated 12-04-2023 | AI: Cursor (Claude 3.7 Sonnet)_ 