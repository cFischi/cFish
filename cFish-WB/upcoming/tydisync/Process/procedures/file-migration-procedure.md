# File Migration Procedure for Digital Organization System

## Metadata
- **URL**: https://u.cfish.io/procedures/file-migration-procedure
- **Last Updated**: 03-13-2025
- **Purpose**: Guide for migrating existing files to the standardized directory structure
- **Target Audience**: cFish.io team members and contributors
- **Department**: U5 - Data Management (DMT)
- **Author**: tY FischEYe

---

## 1. Overview

This procedure guides the migration of existing files to the new standardized directory structure established by the Digital Organization System.

### 1.1 When to Use This Procedure

Use this procedure when:
- Implementing the new directory structure for the first time
- Migrating legacy files from an older structure
- Onboarding new projects to follow the organizational standard

### 1.2 Prerequisites

- Access to source files that need migration
- Permissions to create and modify files in the target directory structure
- Completed run of `create-directory-structure.ps1` to set up the directory structure
- Familiarity with file naming conventions in `docs/standards/file-naming-conventions.md`

### 1.3 Expected Outcome

- All files properly categorized in their appropriate department directories
- Files renamed according to the standard naming convention
- Documentation updated to reflect new file locations
- Successful verification of file integrity post-migration

## 2. Procedure Steps

### 2.1 Preparation

1. Run full backup before migration:
   ```powershell
   .\tools\daily-backup.ps1
   ```

2. Create a migration plan by listing files to be migrated with their source and destination:
   ```
   Source Path                 | Target Department | New File Name
   ---------------------------|------------------|------------------------------------
   /old-location/script.js    | u4-production    | ucw-u4.2-api-client-20250313.js
   /docs/architecture.md      | u5-data-management | ucf-u5.3-system-architecture-20250313.md
   ```

3. Review the migration plan to ensure all files are accounted for

### 2.2 File Categorization

1. For each file, determine the appropriate department based on its purpose:
   - Business administration code → u1-overheads
   - R&D projects and prototypes → u2-research
   - Operations management code → u3-operations
   - Production systems → u4-production
   - Data handling and analysis → u5-data-management
   - Social media and communications → u6-social
   - Specialized departmental tools → u7-specialized

2. For each file, determine the function number (1-9) based on department-specific functions

3. Create descriptive task identifiers for each file (use kebab-case)

### 2.3 File Migration

1. Create a PowerShell script to automate the migration process:
   ```powershell
   # migration-script.ps1
   $migrations = @(
     @{Source = "old-location/script.js"; Destination = "src/u4-production/ucw-u4.2-api-client-20250313.js"},
     @{Source = "docs/architecture.md"; Destination = "docs/u5-data-management/ucf-u5.3-system-architecture-20250313.md"}
   )

   foreach ($migration in $migrations) {
     # Create destination directory if it doesn't exist
     $destDir = Split-Path -Parent $migration.Destination
     if (!(Test-Path $destDir)) {
       New-Item -ItemType Directory -Path $destDir -Force
     }
     
     # Copy file to new location
     Copy-Item -Path $migration.Source -Destination $migration.Destination
     
     # Verify copy was successful
     if (Test-Path $migration.Destination) {
       Write-Host "Successfully migrated: $($migration.Source) -> $($migration.Destination)" -ForegroundColor Green
     } else {
       Write-Host "Failed to migrate: $($migration.Source)" -ForegroundColor Red
     }
   }
   ```

2. Execute the migration script:
   ```powershell
   .\migration-script.ps1
   ```

3. Verify each file has been migrated correctly

### 2.4 Post-Migration Verification

1. Run the health check to verify system integrity:
   ```powershell
   .\tools\daily-health-check.ps1
   ```

2. Update references to migrated files in documentation and code

3. Test functionality of migrated code files to ensure they work in the new location

4. Run a backup after migration is complete:
   ```powershell
   .\tools\daily-backup.ps1
   ```

## 3. Troubleshooting

### 3.1 Common Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| File not found after migration | Incorrect path in migration script | Double check source and destination paths |
| Code doesn't work after migration | Broken references due to path changes | Update import/include paths in code |
| Conflicts with existing files | Same file name already exists | Rename with unique identifier or date |
| Permission errors | Insufficient access to target directories | Ensure proper permissions on target directories |

### 3.2 When to Escalate

Escalate to the Data Management department (u5) if:
- Multiple migration errors occur that cannot be resolved
- System functionality is compromised after migration
- Files cannot be properly categorized into departments
- Significant conflicts arise between file classifications

## 4. Related Procedures

- [Standard Operating Procedure: Digital Organization](../sop.md)
- [File Naming Conventions](../standards/file-naming-conventions.md)
- [Daily Health Check Procedure](./daily-health-check-procedure.md)
- [Daily Backup Procedure](./daily-backup-procedure.md)

## 5. Document Control

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 0.1 | 03-13-2025 | tY FischEYe | Initial draft |
| 1.0 | 03-13-2025 | tY FischEYe | Published version |

---

_Updated 03-13-2025 | AI: Cursor (Claude 3.7 Sonnet)_ 