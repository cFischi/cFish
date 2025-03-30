# SOP Monitoring System: Essential Files Reference

This document provides a central reference to all essential files related to the cFish.io Digital Organization System and its SOP monitoring capabilities.

## Core Documentation Files

1. **Digital Organization System README**
   - Path: `docs/digital-organization-system-README.md`
   - Purpose: Main README documenting the digital organization system
   - Lines: 237
   - Type: README

2. **File Management System SOP**
   - Path: `Documentation/Process/cFish.io File Management System SOP.md`
   - Purpose: Main comprehensive SOP
   - Lines: 1205
   - Type: FileOrganization

3. **File Naming Conventions**
   - Path: `Documentation/Technical/standards/file-naming-conventions.md`
   - Purpose: Detailed file naming conventions
   - Lines: 101
   - Type: FileNaming

4. **File Organization Standards**
   - Path: `Documentation/Implementation/file-organization-standards.md`
   - Purpose: UcF departments organization standards
   - Lines: 197
   - Type: DirectoryStructure

## Configuration Files

These JSON configuration files are automatically updated by the SOP monitoring system whenever the source documentation changes:

5. **File Naming Configuration**
   - Path: `U7-Systems/Tools/Config/file-naming-config.json`
   - Purpose: Configuration for file naming conventions
   - Source: `Documentation/Technical/standards/file-naming-conventions.md`
   - Auto-updated: Yes

6. **Directory Structure Configuration**
   - Path: `U7-Systems/Tools/Config/directory-structure-config.json`
   - Purpose: Configuration for directory structure
   - Source: `Documentation/Implementation/file-organization-standards.md`
   - Auto-updated: Yes

7. **File Organization Configuration**
   - Path: `U7-Systems/Tools/Config/file-organization-config.json`
   - Purpose: Configuration for file organization rules
   - Source: `Documentation/Process/cFish.io File Management System SOP.md`
   - Auto-updated: Yes

## SOP Monitoring System Script

8. **SOP Monitoring Script**
   - Path: `U7-Systems/Tools/ucf-u7.3-monitor-sop-changes-20250314.ps1`
   - Purpose: Self-updating script that monitors SOP documentation for changes
   - Auto-updates: All configuration files

## How the Self-Updating System Works

The SOP monitoring system works through the following process:

1. The monitoring script regularly scans the documentation files for changes
2. When changes are detected, it extracts relevant patterns and rules
3. Configuration files are automatically updated to reflect these changes
4. System tools that rely on these configuration files immediately adapt to the new rules
5. Changes are logged in `memory.md` and version information is updated in `changelog.md`

This self-updating approach ensures that:

- Documentation remains the single source of truth
- Tools automatically adapt to documentation changes
- No manual code updates are required when SOP rules change
- Implementation consistency is maintained across the organization

## Usage

To run the SOP monitoring system manually:

```powershell
powershell -ExecutionPolicy Bypass -File "U7-Systems\Tools\ucf-u7.3-monitor-sop-changes-20250314.ps1"
```

The system is also scheduled to run automatically at 2:00 AM daily.

---

_Updated 03-14-2025 | AI: Cursor (Claude 3.7 Sonnet)_ 