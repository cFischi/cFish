# Digital Organization System Guide

**URL:** https://cfish.io/docs/guides/digital-organization-system  
**Last Updated:** 03-14-2025  
**Document ID:** tyf-u5.1-digital-organization-system-guide-20250314  
**Department:** U5 - Data Management  
**Author:** tY FischEYe  

## Introduction

This guide provides a comprehensive overview of the cFish.io Digital Organization System implemented in March 2025. The system establishes standardized approaches to file management, automation, and documentation to improve efficiency, consistency, and reliability across all cFish.io operations.

## 1. Directory Structure

### 1.1 Root Directories

The cFish.io repository follows a structured directory layout:

```
cFish.io/
├── docs/                  # Documentation files
├── tools/                 # Scripts and utilities
├── resources/             # Resources and templates
├── backups/               # Backup files
├── logs/                  # Log files
├── sync-system/           # tYDiSync~ system files
├── config/                # Configuration files
└── src/                   # Source code
```

### 1.2 Documentation Subdirectories

```
docs/
├── procedures/            # Step-by-step guides
├── specifications/        # Technical specifications
├── quick-reference/       # Quick reference guides
├── guides/                # Comprehensive guides
├── u1-overheads/          # Executive department docs
├── u2-development/        # Development department docs
├── u3-marketing/          # Marketing department docs
├── u4-production/         # Operations department docs
├── u5-data-management/    # Data Management department docs
├── u6-social/             # Social department docs
└── u7-specialized/        # Specialized department docs
```

### 1.3 Implementation Details

- Each directory has a specific purpose to organize related files
- Directory names are lowercase with hyphens
- The structure supports future growth while maintaining organization
- Department-specific directories allow for proper categorization

## 2. File Naming Convention

### 2.1 Standard Format

All files should follow this naming convention:

```
[prefix]-[department].[function]-[description]-[date].[extension]
```

### 2.2 Prefixes

- `tyf` - tY FischEYe (personal)
- `ucf` - UcFish (company)
- `ext` - External

### 2.3 Department Codes

- `u1` - Executive
- `u2` - Development
- `u3` - Marketing
- `u4` - Operations
- `u5` - Data Management
- `u6` - Social
- `u7` - Specialized

### 2.4 Function Codes

- `.1` - Documentation
- `.2` - Configuration
- `.3` - Data Migration
- `.4` - Automation
- `.5` - Analysis

### 2.5 Examples

```
ucf-u5.3-file-migration-20250313.ps1
```
- `ucf` - Company file
- `u5` - Data Management department
- `.3` - Data Migration function
- `file-migration` - Description
- `20250313` - Date (YYYYMMDD)
- `.ps1` - PowerShell script extension

```
tyf-u2.1-wordpress-deployment-20250314.md
```
- `tyf` - Personal file
- `u2` - Development department
- `.1` - Documentation function
- `wordpress-deployment` - Description
- `20250314` - Date (YYYYMMDD)
- `.md` - Markdown extension

## 3. Key Scripts and Tools

### 3.1 Health Check System

The health check system monitors the health of various components:

- **Script:** `tools/daily-health-check.ps1`
- **Schedule:** Runs daily at 8:00 AM
- **Checks performed:**
  - Disk space availability
  - CPU and memory usage
  - Log size monitoring
  - Sync system status
  - Directory integrity

### 3.2 Backup System

The backup system ensures regular data protection:

- **Script:** `tools/daily-backup.ps1`
- **Schedule:** Runs daily at 5:00 PM
- **Backup types:**
  - Daily backups (retention: 7 days)
  - Weekly backups (retention: 4 weeks)
  - Monthly backups (retention: 6 months)

### 3.3 File Migration System

The file migration system helps organize existing files:

- **Script:** `tools/ucf-u5.3-file-migration-20250313.ps1`
- **Purpose:** Migrate files to follow the new naming convention and directory structure
- **Usage:** Run as needed when files need to be reorganized

### 3.4 Sync System

The sync system manages synchronization between Markdown and JSON files:

- **Scripts:** `sync-system/start-optimized-sync.bat`
- **Purpose:** Maintain synchronized versions of content in different formats
- **Features:**
  - Bidirectional synchronization
  - Real-time monitoring
  - Error handling
  - Path normalization

## 4. Working with the System

### 4.1 Creating New Files

1. Determine the appropriate directory based on file type
2. Choose the correct prefix based on ownership
3. Select department and function codes
4. Add a descriptive name
5. Include the current date in YYYYMMDD format
6. Use the appropriate file extension

Example: Creating a new document for WordPress deployment:
```
docs/u2-development/tyf-u2.1-wordpress-deployment-20250314.md
```

### 4.2 Documentation Standards

When creating documentation:

1. Use consistent metadata headers:
   ```
   # Document Title
   
   **URL:** https://cfish.io/docs/...  
   **Last Updated:** MM-DD-YYYY  
   **Document ID:** [prefix]-[department].[function]-[description]-[date]  
   **Department:** [Department Name]  
   **Author:** [Author Name]  
   ```

2. Include appropriate sections:
   - Overview/Introduction
   - Prerequisites
   - Detailed content
   - Conclusion
   - Related documents

3. End with signature line:
   ```
   _Updated MM-DD-2025 | [Human/AI]: [Name]_
   ```

### 4.3 Updating memory.md

memory.md is a central record of system activities and changes:

1. Always add new entries at the top
2. Format sections with heading level 2 (##)
3. Use bullet points for information
4. Include the current date in the section title
5. End with signature line
6. Example:
   ```
   ## Daily Health Check Report (03-14-2025)
   - ✅ Disk space: 45.3 GB available
   - ✅ CPU utilization: 23% (normal)
   - ✅ Memory utilization: 38% (normal)
   - ✅ Log files: All within size limits
   
   _Updated 03-14-2025 | Human: tY FischEYe_
   ```

### 4.4 Updating changelog.md

changelog.md tracks version changes:

1. Follow semantic versioning (MAJOR.MINOR.PATCH)
2. Group changes by type: Added, Changed, Fixed, Removed
3. Include date in ISO format (YYYY-MM-DD)
4. Reference issue numbers when applicable
5. Example:
   ```
   ## [0.5.2] - 2025-03-14
   
   ### Added
   - New verification script for sync system
   - Scheduled task monitoring system
   
   ### Fixed
   - Path handling in sync system configuration
   ```

## 5. Monitoring and Maintenance

### 5.1 Daily Procedures

1. Review health check results in memory.md
2. Verify scheduled tasks executed properly
3. Check backup completion status
4. Review any warning or error logs

### 5.2 Weekly Procedures

1. Run sync system verification
2. Clean up temporary files
3. Review disk space usage
4. Check for outdated documentation

### 5.3 Monthly Procedures

1. Review retention policies
2. Archive old backups
3. Update documentation as needed
4. Perform system-wide review

## 6. References and Resources

### 6.1 Quick Reference Guide

For a condensed overview of the system:
- [Digital Organization Quick Reference Guide](../quick-reference/tyf-u5.2-digital-organization-quick-reference-20250313.md)

### 6.2 Procedure Documents

Key procedures:
- [Monitoring Scheduled Tasks](../procedures/ucf-u5.1-monitor-scheduled-tasks-20250314.md)
- [Verifying Sync System](../procedures/ucf-u5.1-verify-sync-system-20250314.md)
- [File Migration Process](../procedures/ucf-u5.3-file-migration-procedure-20250313.md)

### 6.3 Configuration Files

Important configurations:
- Health check configuration: `tools/daily-health-check.ps1` (CONFIG section)
- Backup configuration: `tools/daily-backup.ps1` (CONFIG section)
- Sync system configuration: `sync-system/config/sync-config.json`

## Conclusion

By following this digital organization system, all team members can contribute to a well-structured, efficiently managed codebase. The standardized approaches to file management, automation, and documentation will lead to improved productivity and better collaboration across departments.

If you have questions or need assistance with any aspect of the digital organization system, please contact the Data Management department.

_Updated 03-14-2025 | AI: Cursor (Claude 3.7 Sonnet)_ 