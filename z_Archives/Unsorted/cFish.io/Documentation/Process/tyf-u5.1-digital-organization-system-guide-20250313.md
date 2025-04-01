# cFish.io Digital Organization System Guide

**Version:** 1.0.0  
**Last Updated:** 03-13-2025  
**Author:** AI: Cursor (Claude 3.7 Sonnet)

## Table of Contents

1. [Introduction](#introduction)
2. [Directory Structure](#directory-structure)
3. [File Naming Conventions](#file-naming-conventions)
4. [System Components](#system-components)
5. [Automation and Monitoring](#automation-and-monitoring)
6. [Standard Procedures](#standard-procedures)
7. [Best Practices](#best-practices)
8. [Troubleshooting](#troubleshooting)
9. [Maintenance and Updates](#maintenance-and-updates)
10. [Appendix](#appendix)

## Introduction

The cFish.io Digital Organization System provides a comprehensive framework for organizing all digital assets related to the cFish.io website and operations. This system follows tY & UcF best practices and is designed to create a consistent, efficient, and maintainable environment for all digital files and systems.

This guide serves as the authoritative reference for the organization system, providing detailed information on directory structure, naming conventions, system components, standard procedures, and best practices.

### Purpose

The primary goals of the Digital Organization System are to:

- Establish a clear, logical structure for all digital assets
- Implement consistent naming conventions
- Automate routine maintenance tasks
- Ensure proper synchronization of critical files
- Provide monitoring and reporting of system health
- Facilitate efficient collaboration and file access
- Reduce time spent searching for files
- Prevent data loss through automated backups

### Scope

This system encompasses all digital assets related to cFish.io, including:

- Website content and design files
- Administrative documents
- Research and analytics data
- Operational procedures
- Production materials
- Development code and scripts
- Marketing assets
- System configuration and documentation

## Directory Structure

The Digital Organization System is based on a hierarchical structure with seven main categories (U-folders) and several specialized directories.

### Main Categories (U-folders)

#### U1-Administration
Business management and administrative files
- **Planning** - Strategic planning, roadmaps, and schedules
- **Finance** - Financial records, budgets, and reports
- **Legal** - Contracts, agreements, and legal documents
- **HR** - Human resources documents and policies
- **Policies** - Organizational policies and guidelines

#### U2-Research
Research, analysis, and market intelligence
- **Projects** - Research project materials and findings
- **Analysis** - Data analysis reports and methods
- **Competitive** - Competitive analysis and market research
- **User-Feedback** - User surveys, feedback, and user research
- **Market-Trends** - Industry trends and market analysis

#### U3-Operations
Day-to-day operations and procedures
- **SOP** - Standard Operating Procedures
- **Maintenance** - System maintenance procedures and logs
- **Monitoring** - Monitoring reports and data
- **Support** - Support documentation and resources
- **Incidents** - Incident reports and resolutions

#### U4-Production
Content creation and production
- **WordPress** - WordPress themes, plugins, and assets
- **Design** - Design files, mockups, and templates
- **Content** - Content files, articles, and resources
- **Media** - Images, videos, and multimedia assets
- **Releases** - Release notes and deployment records

#### U5-Data
Data management, analytics, and synchronization
- **Analytics** - Analytics reports and data
- **Backups** - System and file backups
- **Migrations** - Data migration scripts and records
- **Reports** - Generated reports and data outputs
- **Synchronization** - File synchronization systems and logs

#### U6-Marketing
Marketing campaigns and assets
- **Campaigns** - Marketing campaign materials
- **Social-Media** - Social media assets and content
- **Assets** - Marketing assets and resources
- **SEO** - SEO documentation and analysis
- **Analytics** - Marketing analytics and performance data

#### U7-Systems
Technical systems and development
- **Infrastructure** - Infrastructure documentation and diagrams
- **Development** - Development projects and code
- **Integrations** - System integration documentation and code
- **Security** - Security policies, procedures, and tools
- **Tools** - System tools, scripts, and utilities

### Special Directories

#### Resources
Templates, guidelines, and reference materials
- **Templates** - Document and file templates
- **Guidelines** - Style guides and usage guidelines
- **References** - Reference materials and resources

#### Archives
Archived projects and documents
- **Projects** - Archived project files
- **Documents** - Archived documents
- **Versions** - Historical versions of files

#### Documentation
Technical and process documentation
- **Technical** - Technical documentation and specifications
- **Process** - Process documentation and guides
- **User** - User guides and documentation

## File Naming Conventions

Consistent file naming is crucial for maintaining organization and facilitating search and access to files.

### File Naming Pattern

Files should follow this pattern:
```
[department-code]-[system-code]-[descriptive-name]-[yyyyMMdd].[ext]
```

#### Examples:
- `ucf-u5.1-health-check-20250313.ps1`
- `tyf-u5.1-digital-organization-system-guide-20250313.md`

### File Naming Rules

1. Use lowercase with hyphens for readability
2. Include department code prefix (ucf/tyf)
3. Include system code (u1-u7)
4. Use descriptive names that indicate the file's purpose
5. Include version number in filename when applicable
6. Add date in format yyyyMMdd when appropriate
7. Use standard file extensions

### Directory Naming Pattern

Directories follow this pattern:
```
[Category-Name]
```

#### Examples:
- `U1-Administration`
- `U3-Operations/SOP`

### Directory Naming Rules

1. Main categories use U-prefix with number
2. Subcategories use PascalCase
3. Special directories use underscore prefix where appropriate

## System Components

The Digital Organization System consists of several integrated components that work together to maintain organization, ensure synchronization, provide monitoring, and automate routine tasks.

### tYDiSync System

The tYDiSync System provides optimized synchronization between markdown files and JSON data. It automatically keeps content in sync across different formats to ensure consistency and reduce manual updating.

#### Location
`cFish.io/U5-Data/Synchronization/tydisync`

#### Key Components
- **start-optimized-sync.bat** - Launches the synchronization system
- **config/** - Configuration files for the synchronization system
- **core/** - Core synchronization engine
- **md/** - Markdown files for synchronization
- **json/** - JSON files for synchronization

### Monitoring System

The Monitoring System regularly checks the health of all system components and provides reports on their status.

#### Key Scripts
- **ucf-u5.1-health-check-20250313.ps1** - Performs daily health checks
- **ucf-u5.1-verify-sync-system-20250313.ps1** - Verifies tYDiSync functionality

### Backup System

The Backup System creates regular backups of critical files and manages backup retention according to configurable policies.

#### Key Scripts
- **ucf-u5.1-backup-20250313.ps1** - Creates daily, weekly, and monthly backups

### Task Scheduling

The Task Scheduling system automates routine tasks and ensures they run at appropriate intervals.

#### Key Scripts
- **ucf-u5.1-schedule-monitor-20250313.ps1** - Monitors scheduled task execution
- **ucf-u5.1-schedule-tasks-20250313.ps1** - Configures scheduled tasks

## Automation and Monitoring

The Digital Organization System includes comprehensive automation and monitoring to ensure smooth operation and early detection of issues.

### Scheduled Tasks

The following tasks are scheduled to run automatically:

#### Daily Health Check
- **Schedule:** Daily at 1:00 AM
- **Script:** `ucf-u5.1-health-check-20250313.ps1`
- **Purpose:** Verifies system health and reports status

#### Daily Backup
- **Schedule:** Daily at 2:00 AM
- **Script:** `ucf-u5.1-backup-20250313.ps1`
- **Purpose:** Creates backups of critical files

#### Sync System Verification
- **Schedule:** Daily at 3:00 AM
- **Script:** `ucf-u5.1-verify-sync-system-20250313.ps1`
- **Purpose:** Verifies tYDiSync system functionality

#### Schedule Monitoring
- **Schedule:** Daily at 6:00 AM
- **Script:** `ucf-u5.1-schedule-monitor-20250313.ps1`
- **Purpose:** Monitors execution of scheduled tasks

### Monitoring Procedures

The monitoring system performs several checks to ensure system health:

1. **tYDiSync Status Check**
   - Verifies tYDiSync process is running
   - Attempts automatic restart if necessary

2. **Log Analysis**
   - Scans logs for error patterns
   - Reports potential issues

3. **Scheduled Task Verification**
   - Confirms scheduled tasks executed successfully
   - Logs issues with task execution

4. **Synchronization Testing**
   - Creates test files to verify sync functionality
   - Validates file modifications are properly synchronized

### Reporting

All system activities are logged and reported through:

1. **Log Files**
   - Located in `cFish.io/U3-Operations/Monitoring/logs`
   - Detailed logs of all system operations

2. **memory.md Updates**
   - Located in `cFish.io/Documentation/memory.md`
   - Summary entries for all major system activities

3. **Email Notifications**
   - Optional alerts for critical system issues
   - Configurable notification thresholds

## Standard Procedures

This section documents standard procedures for routine operations involving the Digital Organization System.

### Daily Health Check

A comprehensive check of system health is performed daily:

1. Verify tYDiSync system is running
2. Check for errors in log files
3. Verify scheduled tasks executed successfully
4. Update memory.md with status

### Daily Backup

Critical files are backed up on a regular schedule:

1. Backup critical files to Backups directory
2. Retain daily backups for 7 days
3. Retain weekly backups for 4 weeks
4. Retain monthly backups for 6 months
5. Update memory.md with backup status

### Schedule Monitoring

Scheduled tasks are regularly monitored:

1. Verify scheduled tasks executed successfully
2. Check for task failures
3. Update memory.md with monitoring results

### Sync System Verification

The tYDiSync system is verified daily:

1. Verify tYDiSync system is running
2. Check for errors in sync logs
3. Verify file synchronization is working
4. Update memory.md with verification results

### Adding New Files

Follow these steps when adding new files:

1. Determine the appropriate directory based on file type/purpose
2. Apply the proper naming convention
3. Include necessary metadata in the file
4. Update memory.md if the file is significant

### Archiving Old Files

When files are no longer actively used:

1. Move the file to the appropriate Archives subdirectory
2. Maintain the original file structure
3. Add an "archived-" prefix to the filename if appropriate
4. Document significant archives in memory.md

## Best Practices

These best practices should be followed to maintain the integrity and efficiency of the Digital Organization System.

### File Management

- Store files in appropriate department folders
- Follow naming conventions consistently
- Include dates in filenames for versioned documents
- Store templates in Resources/Templates
- Move outdated files to Archives instead of deleting

### Documentation

- Update memory.md for all significant changes
- Include AI signature in markdown files
- Document procedures in U3-Operations/SOP
- Create technical documentation in Documentation/Technical
- Maintain comprehensive system guides in Documentation/Process

### Automation

- Schedule routine tasks using Task Scheduler
- Monitor scheduled tasks daily
- Create automation scripts in U7-Systems/Tools
- Log all automated actions
- Implement error handling in all scripts

### Synchronization

- Use tYDiSync for markdown/JSON synchronization
- Verify sync system daily
- Store sync logs in proper location
- Document sync system issues in memory.md
- Maintain backup copies of critical files

## Troubleshooting

This section provides guidance for addressing common issues with the Digital Organization System.

### tYDiSync Issues

#### Synchronization Not Working

**Symptoms:**
- Files not being synchronized between markdown and JSON
- Error messages in sync logs

**Solutions:**
1. Verify tYDiSync process is running
2. Check logs for specific error messages
3. Restart tYDiSync using start-optimized-sync.bat
4. Verify file paths in configuration files

### Scheduled Task Failures

**Symptoms:**
- Tasks not running at scheduled times
- Error messages in task logs

**Solutions:**
1. Check task status in Windows Task Scheduler
2. Verify script paths are correct
3. Check for permission issues
4. Review task logs for specific errors

### File Organization Issues

**Symptoms:**
- Files in unexpected locations
- Inconsistent naming conventions

**Solutions:**
1. Review directory structure documentation
2. Correct file locations manually
3. Implement file migration script
4. Provide additional training on naming conventions

## Maintenance and Updates

Regular maintenance is essential to keep the Digital Organization System functioning optimally.

### Weekly Maintenance

1. Review system logs for patterns or recurring issues
2. Verify all automated tasks are running successfully
3. Check free disk space for backup storage

### Monthly Maintenance

1. Review and clean up temporary files
2. Verify backup integrity by performing test restores
3. Update documentation with any system changes

### Quarterly Maintenance

1. Review and update scheduled tasks if needed
2. Assess storage requirements and adjust if necessary
3. Review access permissions and security settings

### System Updates

When updating system components:

1. Document the proposed changes
2. Test changes in a non-production environment
3. Implement changes during low-usage periods
4. Update all relevant documentation
5. Add detailed entry to memory.md

## Appendix

### Glossary of Terms

- **U-folders** - Main organizational categories (U1-U7)
- **tYDiSync** - Synchronization system for markdown and JSON files
- **SOP** - Standard Operating Procedure
- **UCF** - Universal Content Framework

### Script Reference

| Script Name | Purpose | Location |
|-------------|---------|----------|
| ucf-u5.1-health-check-20250313.ps1 | System health checks | cFish.io/U7-Systems/Tools |
| ucf-u5.1-backup-20250313.ps1 | File backups | cFish.io/U7-Systems/Tools |
| ucf-u5.1-verify-sync-system-20250313.ps1 | Verify sync system | cFish.io/U7-Systems/Tools |
| ucf-u5.1-schedule-monitor-20250313.ps1 | Monitor scheduled tasks | cFish.io/U7-Systems/Tools |
| ucf-u5.1-schedule-tasks-20250313.ps1 | Configure scheduled tasks | cFish.io/U7-Systems/Tools |

### Directory Structure Quick Reference

```
cFish.io/
├── U1-Administration/
│   ├── Planning/
│   ├── Finance/
│   ├── Legal/
│   ├── HR/
│   └── Policies/
├── U2-Research/
│   ├── Projects/
│   ├── Analysis/
│   ├── Competitive/
│   ├── User-Feedback/
│   └── Market-Trends/
├── U3-Operations/
│   ├── SOP/
│   ├── Maintenance/
│   ├── Monitoring/
│   ├── Support/
│   └── Incidents/
├── U4-Production/
│   ├── WordPress/
│   ├── Design/
│   ├── Content/
│   ├── Media/
│   └── Releases/
├── U5-Data/
│   ├── Analytics/
│   ├── Backups/
│   ├── Migrations/
│   ├── Reports/
│   └── Synchronization/
├── U6-Marketing/
│   ├── Campaigns/
│   ├── Social-Media/
│   ├── Assets/
│   ├── SEO/
│   └── Analytics/
├── U7-Systems/
│   ├── Infrastructure/
│   ├── Development/
│   ├── Integrations/
│   ├── Security/
│   └── Tools/
├── _Resources/
│   ├── Templates/
│   ├── Guidelines/
│   └── References/
├── _Archives/
│   ├── Projects/
│   ├── Documents/
│   └── Versions/
└── Documentation/
    ├── Technical/
    ├── Process/
    └── User/
```

_Updated 03-13-2025 | AI: Cursor (Claude 3.7 Sonnet)_ 