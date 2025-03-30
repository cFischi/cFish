# cFish.io File Organization System

## Overview

The cFish.io File Organization System is a comprehensive solution that automatically monitors, analyzes, and organizes files according to the cFish.io Digital Organization System standards. This document describes the components, functionality, and usage of this system.

## Components

The File Organization System consists of several key components:

1. **File Monitoring System**
   - Continuously monitors for new file creation
   - Analyzes file content to determine appropriate location
   - Automatically renames files according to UcF naming conventions
   - Updates memory.md with organization activities

2. **Directory Structure Management**
   - Ensures the proper directory hierarchy is maintained
   - Automatically creates required directories if missing
   - Organizes directories according to the specified order

3. **Batch Wrappers**
   - Simple interfaces to start the monitoring and reorganization processes
   - Includes confirmation prompts for potentially destructive operations

## Directory Structure

The cFish.io organization follows this specific directory structure, ordered as follows:

1. `.cursor/` - Cursor IDE configuration
   - `Resources/` - Templates, guidelines, and references
2. `Documentation/` - Technical, process, and user documentation
3. UcF department directories (ordered U1-U7):
   - `U1-Administration/` - Planning, Finance, Legal, HR, Policies
   - `U2-Research/` - Projects, Analysis, Competitive, User-Feedback, Market-Trends
   - `U3-Operations/` - SOP, Maintenance, Monitoring, Support, Incidents
   - `U4-Production/` - WordPress, Design, Content, Media, Releases
   - `U5-Data/` - Analytics, Backups, Migrations, Reports, Synchronization
   - `U6-Marketing/` - Campaigns, Social-Media, Assets, SEO, Analytics
   - `U7-Systems/` - Infrastructure, Development, Integrations, Security, Tools
4. `wp-content/` - WordPress content
   - `Archives/` - Projects, Documents, Versions
     - `Backups/` - Contains backup directories

## File Naming Convention

All files should follow this convention:
```
[CompanyPrefix]-[DeptNumber].[FunctionNumber]-[TaskIdentifier]-[Date].[extension]
```

Example: `ucf-u5.3-data-migration-20250315.js`

Components:
- **Company Prefix**: ucf, tyf, fh, ucw, uz, fe, ty
- **Department Number**: u1-u7 corresponding to UcF departments
- **Function Number**: Department-specific function identifier (1-9)
- **Task Identifier**: Brief, hyphen-separated description of file purpose
- **Date**: Format: YYYYMMDD for version-sensitive documents

### Exempted Files

Certain files are exempted from the naming convention to maintain functionality:
- WordPress core files and themes
- Third-party plugins and libraries
- Configuration files (wp-config.php, .htaccess, etc.)
- Legal documents with specific naming requirements

## Using the File Organization System

### Starting the File Monitoring System

1. Navigate to `U7-Systems/Tools/`
2. Run `start-file-monitoring.bat`
3. The system will begin monitoring for new files
4. Press Ctrl+C to stop monitoring

### Reorganizing the Directory Structure

If you need to realign the directory structure to match the required hierarchy:

1. Navigate to `U7-Systems/Tools/`
2. Run `reorganize-directory-structure.bat`
3. Confirm the operation when prompted
4. The script will:
   - Back up the current structure
   - Move Resources under .cursor
   - Move Archives under wp-content
   - Move Backups under Archives

### Processing Existing Files

To process files that were created before the monitoring system was implemented:

```powershell
# From PowerShell:
cd "path\to\cFish.io"
.\U7-Systems\Tools\monitor-file-organization.ps1 -ProcessExisting -ExistingFilesDirectory "path\to\files" -RecursiveProcessing
```

## How It Works

### File Analysis

The system follows this process to organize files:

1. Detects when a new file is created
2. Checks if the file is already exempt or compliant with naming conventions
3. For non-exempt/non-compliant files:
   - Analyzes file content and extension
   - Determines the appropriate department and function
   - Generates a UcF-compliant filename
   - Moves the file to the correct location
   - Updates memory.md with the action taken

### Directory Management

The directory structure management:

1. Creates a backup of the current structure
2. Safely moves directories to their specified locations
3. Preserves all content during moves
4. Verifies file counts before removing original directories
5. Logs all actions and updates memory.md

## Technical Details

### Logging

The system maintains detailed logs:

- File monitoring logs: `U5-Data/Reports/FileMonitoring/ucf-u5.1-file-monitoring-YYYYMMDD.log`
- Directory reorganization logs: `U5-Data/Reports/ucf-u5.1-directory-reorganization-YYYYMMDD.log`
- Error logs: `U5-Data/Reports/FileMonitoring/ucf-u5.1-file-monitoring-error-YYYYMMDD.log`

### Integration with memory.md

The system automatically updates memory.md with entries for:
- File organization activities
- Directory structure reorganization 
- New file processing

Each entry includes:
- Timestamp
- Activity description
- Detailed list of changes
- Standard signature line with date and AI identifier

## Troubleshooting

Common issues and solutions:

1. **File wasn't moved to the expected location**
   - Check the file extension mappings in monitor-file-organization.ps1
   - Review exemption patterns to ensure the file isn't being exempted

2. **Directory structure doesn't match expected hierarchy**
   - Run the reorganize-directory-structure.bat script
   - Check log files for any errors during reorganization

3. **File monitoring isn't detecting new files**
   - Ensure the monitoring script is running (look for PowerShell process)
   - Check if you have sufficient permissions in the directory

For detailed technical support, review the log files or contact the system administrator.

---

_Updated 03-15-2025 | AI: Cursor (Claude 3.7 Sonnet)_ 