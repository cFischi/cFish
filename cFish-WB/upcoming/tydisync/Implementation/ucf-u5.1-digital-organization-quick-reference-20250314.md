# cFish.io Digital Organization System - Quick Reference Guide

**Version:** 1.0.0  
**Date:** 2025-03-14  

## Directory Structure

### Main Department Categories
- **U1-Administration**: Planning, Finance, Legal, HR, Policies
- **U2-Research**: Projects, Analysis, Competitive, User-Feedback, Market-Trends
- **U3-Operations**: SOP, Maintenance, Monitoring, Support, Incidents
- **U4-Production**: WordPress, Design, Content, Media, Releases
- **U5-Data**: Analytics, Backups, Migrations, Reports, Synchronization
- **U6-Marketing**: Campaigns, Social-Media, Assets, SEO, Analytics
- **U7-Systems**: Infrastructure, Development, Integrations, Security, Tools

### Support Directories
- **_Resources**: Templates, Guidelines, References
- **_Archives**: Projects, Documents, Versions
- **Documentation**: Technical, Process, User

## File Naming Convention

Format: `[CompanyPrefix]-[DeptNumber].[FunctionNumber]-[TaskIdentifier]-[Date].[extension]`

**Example:** `ucf-u5.3-data-migration-20250313.js`

### Components
- **Company Prefix**: ucf, tyf, fh, ucw, uz, fe, ty
- **Department Number**: u1-u7 corresponding to UcF departments
- **Function Number**: Department-specific function identifier (1-9)
- **Task Identifier**: Brief, hyphen-separated description
- **Date**: Format: YYYYMMDD

### Critical Files Exception
WordPress files, critical tools, legal documents, and other essential software files maintain their original names but are placed in the appropriate directories.

## Common Commands

### File Naming Checker Tools

**Simple Checker** (Top-level-only, quick scan):
```
check-file-naming-simple.bat
```

**Standard Checker** (1 level of subdirectories):
```
check-file-naming-standard.bat
```

**Targeted Checker** (Specific directories):
```
check-file-naming-targeted.bat "docs" "U1-Administration"
```

**Full Checker** (Comprehensive scan):
```
powershell -ExecutionPolicy Bypass -File "U5-Data\Tools\FilenameCheckers\U5-development-check-file-naming-20250314.ps1"
```

**Rename Non-Compliant Files**:
```
powershell -ExecutionPolicy Bypass -File "U5-Data\Tools\FilenameCheckers\U5-development-check-file-naming-20250314.ps1" -fix
```

### System Maintenance

**Health Check**:
```
powershell -ExecutionPolicy Bypass -File "U5-Data\Tools\HealthCheck\U5-development-daily-health-check-20250314.ps1"
```

**Backup System**:
```
powershell -ExecutionPolicy Bypass -File "U5-Data\Tools\BackupSystem\U5-development-backup-system-20250314.ps1"
```

**Sync System Recovery**:
```
powershell -ExecutionPolicy Bypass -File "U5-Data\Tools\Recovery\U5-development-auto-recovery-sync-system-20250314.ps1"
```

## Daily Operations Checklist

1. ☐ Review health check report (8:00 AM automatic run)
2. ☐ Address any compliance issues identified
3. ☐ Ensure new files follow naming convention
4. ☐ Place files in appropriate directories

## Weekly Operations Checklist

1. ☐ Run full compliance check (Friday)
2. ☐ Verify backup system functionality
3. ☐ Update documentation with any changes

## Troubleshooting

| Issue | Solution |
|-------|----------|
| File naming checker not running | Run PowerShell scripts directly using the full path |
| Files not being renamed properly | Use the -detailedOutput flag to see specific issues |
| Critical WordPress files modified | Restore from backup and update exemption registry |
| tYDiSync~ system not synchronizing | Run auto-recovery mechanism and check logs |

## Support

For assistance with the Digital Organization System, contact:

- **System Administrator**: ext. 3458
- **Helpdesk**: helpdesk@cfish.io
- **Documentation**: U5-Data/Documentation/OrganizationSystem/

---

_Updated 03-14-2025 | AI: Cursor (Claude 3.7 Sonnet)_ 