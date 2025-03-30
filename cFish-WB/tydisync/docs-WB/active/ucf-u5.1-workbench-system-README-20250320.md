# cFish.io Workbench System

## Overview
The cFish.io Workbench System implements a standardized workspace for active development across all major directories in the cFish.io digital organization. Each department, content area, and resource location has a dedicated workbench (WB) folder with consistent structure and naming conventions.

## Purpose
The Workbench System serves to:
- Provide clearly designated areas for active work
- Standardize the location of in-progress items across departments
- Separate active development from completed content
- Create a consistent approach to documenting work in progress
- Enhance cross-department collaboration through uniform structure

## Workbench Naming Convention
Workbenches follow a consistent naming pattern:
- `[Directory Abbreviation]-WB`

Examples:
- `U1-WB`: Administration Workbench
- `U2-WB`: Research Workbench
- `U3-WB`: Operations Workbench
- `U4-WB`: Production Workbench
- `U5-WB`: Data Workbench
- `U6-WB`: Marketing Workbench
- `U7-WB`: Systems Workbench
- `WP-WB`: WordPress Workbench
- `arc-WB`: Archives Workbench
- `resour-WB`: Resources Workbench
- `curs-WB`: Cursor Workbench
- `docs-WB`: Documentation Workbench

## Workbench Structure
Each workbench contains four standard subfolders:

1. **active**
   - Contains 1-3 items or tools currently being worked on
   - Limit to current active projects to prevent clutter
   - Move completed items to their permanent locations

2. **WB-readme**
   - Contains README files for items in the "active" folder
   - Use standard README naming: `[item-name]-README.md`
   - Keep documentation current with ongoing work

3. **next-WB**
   - Contains items or tools that will be worked on next
   - Functions as a prioritized to-do list for the department/area
   - Regularly review and update based on changing priorities

4. **next-readme**
   - Contains README files for items in the "next-WB" folder
   - Use standard README naming: `[item-name]-README.md`
   - Document requirements and plans for upcoming work

Additionally, each workbench contains:
- `WB-memory.md`: Changelog tracking all workbench activity

## Usage Guidelines

### Adding Items to Workbench
1. Place current work items in the appropriate department/area workbench "active" folder
2. Create corresponding README files in the "WB-readme" folder
3. Update `WB-memory.md` with details about the addition

### Moving Items Between Workbenches
1. For cross-department projects, use the main responsible department's workbench
2. Consider creating symbolic links between related workbenches when needed
3. Document all cross-department connections in both workbench memory files

### Completing Workbench Items
1. Move completed items from "active" to their permanent location in the appropriate department
2. Update the workbench memory file noting the completion and final destination
3. Move the next priority item from "next-WB" to "active"

### Documentation Requirements
All workbench items should have corresponding documentation that includes:
- Purpose and scope of the item
- Current status and progress
- Dependencies and related components
- Next steps or completion criteria

## Implementation
The Workbench System has been implemented across the following directories:
- U1-Administration through U7-Systems
- wp-content
- _Archives
- _Resources
- .cursor
- Documentation

Backup directories are intentionally excluded from the workbench system.

## Maintenance
1. Review workbench contents weekly to ensure they reflect current priorities
2. Clean up completed items promptly to prevent workbench clutter
3. Update workbench memory files with all significant changes
4. Conduct monthly audits to verify workbench compliance across all directories

This document serves as the official standard for the cFish.io Workbench System. All departments and team members should follow these guidelines when using workbench areas.

_Updated 03-20-2025 | AI: Cursor (Claude 3.7 Sonnet)_ 