# cFish.io Digital Organization System

## Introduction

The cFish.io Digital Organization System provides a structured, consistent, and maintainable approach to file and directory management across the organization. This guide outlines the key components of the system and provides instructions for working with it.

## Directory Structure

The system uses a UcF department-based organization with seven main categories:

- **U1-Administration**: Planning, Finance, Legal, HR, Policies
- **U2-Research**: Projects, Analysis, Competitive, User-Feedback, Market-Trends
- **U3-Operations**: SOP, Maintenance, Monitoring, Support, Incidents
- **U4-Production**: WordPress, Design, Content, Media, Releases
- **U5-Data**: Analytics, Backups, Migrations, Reports, Synchronization
- **U6-Marketing**: Campaigns, Social-Media, Assets, SEO, Analytics
- **U7-Systems**: Infrastructure, Development, Integrations, Security, Tools

Additional support directories include:
- **_Resources**: Templates, Guidelines, References
- **_Archives**: Projects, Documents, Versions
- **Documentation**: Technical, Process, User

## File Naming Conventions

All files should follow this naming convention:
```
[CompanyPrefix]-[DeptNumber].[FunctionNumber]-[TaskIdentifier]-[Date].[extension]
```

Example: `ucf-u5.3-data-migration-20250313.js`

Components:
- **Company Prefix**: ucf, tyf, fh, ucw, uz, fe, ty
- **Department Number**: u1-u7 corresponding to UcF departments
- **Function Number**: Department-specific function identifier (1-9)
- **Task Identifier**: Brief, hyphen-separated description of file purpose
- **Date**: Format: YYYYMMDD for version-sensitive documents

## Tools and Utilities

### File Naming Checker

The system includes a tool to check file naming conventions:

```
tools/ucf-u5.3-check-file-naming-20250314.bat
```

To check files without renaming them:
```
tools/ucf-u5.3-check-file-naming-20250314.bat
```

To automatically rename non-compliant files:
```
tools/ucf-u5.3-check-file-naming-20250314.bat -fix
```

### Health Check System

The health check system runs daily at 8:00 AM and verifies:
- System resource utilization (disk space, CPU, memory)
- tYDiSync~ system status and logs
- Content directories and file consistency
- Scheduled task execution status

Manual execution:
```
powershell -ExecutionPolicy Bypass -File "tools\daily-health-check.ps1"
```

### Backup System

The backup system runs daily at 10:00 PM and creates:
- Daily backups of critical files (retention: 7 days)
- Weekly backups of WordPress content and configuration (retention: 4 weeks)
- Monthly backups of the entire repository (retention: 6 months)

Manual execution:
```
powershell -ExecutionPolicy Bypass -File "tools\daily-backup.ps1"
```

### Auto-Recovery Mechanism

The auto-recovery system monitors the tYDiSync~ synchronization system hourly and:
- Validates required state files and creates placeholders if missing
- Automatically restarts the synchronization system if it fails

Manual execution:
```
powershell -ExecutionPolicy Bypass -File "tools\auto-recovery-sync-system.ps1"
```

### Scheduled Tasks Configuration

To configure all scheduled tasks:
```
tools/run-schedule-tasks-as-admin.bat
```

Note: This must be run with administrator privileges.

## Documentation

- **Standard Operating Procedure (SOP)**: `sop.md` - Detailed operational procedures
- **Technical Specification**: `spec.md` - Technical details of the tYDiSync~ system
- **Implementation Summary**: `docs/implementation-summary/ucf-u5.3-digital-organization-summary-20250314.md` - System implementation details
- **Daily Operations**: `memory.md` - Record of daily operations and achievements
- **Version History**: `changelog.md` - History of changes to the system

## Getting Started

1. Ensure your files are in the correct directories based on the U1-U7 structure
2. Run the file naming convention checker to identify non-compliant files
3. Gradually rename files to follow the standard naming conventions
4. Verify that the scheduled tasks are configured correctly
5. Monitor system logs to ensure everything is working as expected

## Troubleshooting

If you encounter issues with the system:

1. Check the logs in the `logs` directory for error messages
2. Verify that scheduled tasks are running properly
3. Ensure the tYDiSync~ system is running
4. Check disk space and system resources
5. Contact the system administrator if issues persist

## Contributing

When contributing to the digital organization system:

1. Follow the established file naming conventions
2. Place files in the appropriate directories based on their purpose
3. Update relevant documentation when making changes
4. Test any modifications thoroughly before deployment

---

_Updated 03-14-2025 | AI: Cursor (Claude 3.7 Sonnet)_ 