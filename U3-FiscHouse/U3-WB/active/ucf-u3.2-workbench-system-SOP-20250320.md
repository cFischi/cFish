# Standard Operating Procedure: cFish.io Workbench System

**Document ID**: UCF-U3.2-WB-SOP-20250320  
**Version**: 1.0  
**Department**: U3-Operations  
**Category**: Standard Operating Procedure  
**Status**: Active  
**Effective Date**: March 20, 2025  
**Review Date**: March 20, 2026  

## 1. Purpose
This Standard Operating Procedure (SOP) establishes guidelines for the implementation, use, and maintenance of the cFish.io Workbench System. The system provides standardized workspaces across all major directories to improve organization, consistency, and collaboration.

## 2. Scope
This SOP applies to all departments and team members working within the cFish.io digital workspace. It covers the creation, usage, documentation, and maintenance of workbench folders across all specified directories, excluding backup folders.

## 3. Definitions

- **Workbench (WB)**: A standardized folder structure for active development and upcoming work
- **Active**: Subfolder containing 1-3 current work items
- **WB-readme**: Subfolder containing README files for active items
- **next-WB**: Subfolder containing items to be worked on next
- **next-readme**: Subfolder containing README files for next items
- **UcF**: Universal cFish, the organizational structure and naming conventions for cFish.io

## 4. Responsibilities

### 4.1 Department Heads
- Ensure workbench folders in their departments follow this SOP
- Conduct monthly audits of department workbench compliance
- Approve transfers of completed items from workbenches to permanent locations

### 4.2 Team Members
- Place active work in appropriate workbench folders
- Create and maintain README files for all workbench items
- Update workbench memory files with significant changes
- Move completed items to permanent locations

### 4.3 Systems Department (U7)
- Maintain workbench system tools and scripts
- Provide technical support for workbench implementation
- Develop and update automation for workbench tasks
- Monitor system-wide workbench compliance

## 5. Procedure

### 5.1 Workbench Folder Structure
Each main directory contains a workbench folder named according to the format `[Abbreviation]-WB`:
- U1-WB, U2-WB, U3-WB, U4-WB, U5-WB, U6-WB, U7-WB
- WP-WB, arc-WB, resour-WB, curs-WB, docs-WB

Each workbench folder contains:
- active/
- WB-readme/
- next-WB/
- next-readme/
- WB-memory.md

### 5.2 Adding Items to Workbenches

1. Identify the appropriate workbench based on item's primary department/function
2. Add the item to the "active" subfolder (maintain 1-3 item limit)
3. Create a README file in the "WB-readme" subfolder following naming convention: `[item-name]-README.md`
4. Update WB-memory.md with:
   - Date of addition
   - Brief description
   - Expected timeline
   - Dependencies or related items

### 5.3 Working with Workbench Items

1. Always work with items in the workbench location, not duplicated elsewhere
2. Update README files to reflect current progress
3. Document significant changes in WB-memory.md
4. For items requiring cross-department collaboration:
   - Keep the item in the primary responsible department's workbench
   - Create symbolic links in secondary departments' workbenches if needed
   - Document the connection in both workbench memory files

### 5.4 Completing Workbench Items

1. Verify item meets completion criteria
2. Document completion in item's README file
3. Move item from "active" to its permanent location following UcF structure
4. Document in WB-memory.md:
   - Completion date
   - Final location
   - Any follow-up tasks
5. Move the highest priority item from "next-WB" to "active"
6. Move corresponding README from "next-readme" to "WB-readme"

### 5.5 Managing "next-WB" Items

1. Review "next-WB" folder weekly to ensure it reflects current priorities
2. Add new items to "next-WB" as they are identified
3. Create corresponding README files in "next-readme"
4. Document all additions and priority changes in WB-memory.md
5. Limit "next-WB" to a reasonable number of items (recommended: 5-10)

### 5.6 Documentation Requirements

All items in workbench folders must have README files containing:
1. Purpose and objectives
2. Current status
3. Implementation details or design specifications
4. Dependencies and related components
5. Completion criteria or next steps
6. Contact information of primary responsible person

### 5.7 Workbench Maintenance

1. Weekly: Review and update workbench contents
2. Monthly: Conduct departmental compliance audits
3. Quarterly: Perform system-wide workbench review

## 6. Quality Control

### 6.1 Compliance Monitoring
- Monthly audits by department heads
- Quarterly system-wide review by U7-Systems

### 6.2 Success Metrics
- All active work items properly located in workbenches
- All workbench items have complete README files
- WB-memory.md files updated with all significant changes
- No more than 3 items in any "active" folder
- Clean transition of completed items to permanent locations

## 7. References
- ucf-u5.1-workbench-system-README-20250320.md
- ucf-u7.3-create-workbench-system-20250320.ps1
- Universal cFish (UcF) File Naming Convention Documentation

## 8. Appendices

### Appendix A: Workbench Naming Reference
| Directory | Workbench Name |
|-----------|----------------|
| U1-Administration | U1-WB |
| U2-Research | U2-WB |
| U3-Operations | U3-WB |
| U4-Production | U4-WB |
| U5-Data | U5-WB |
| U6-Marketing | U6-WB |
| U7-Systems | U7-WB |
| wp-content | WP-WB |
| _Archives | arc-WB |
| _Resources | resour-WB |
| .cursor | curs-WB |
| Documentation | docs-WB |

### Appendix B: README Template
```markdown
# [Item Name] README

## Overview
[Brief description of the item/tool/project]

## Status
- Start Date: [Date]
- Current Status: [In Progress/Paused/Completed]
- Progress: [%]
- Expected Completion: [Date]

## Implementation Details
[Specific details about the implementation, design, or approach]

## Dependencies
[List of dependencies or related components]

## Completion Criteria
[Specific criteria that must be met for this item to be considered complete]

## Responsible Person
[Name and contact information]

## Notes
[Additional information or special considerations]

_Updated [Date] | [Author]_
```

## Revision History
| Version | Date | Description | Author |
|---------|------|-------------|--------|
| 1.0 | 03-20-2025 | Initial SOP | Claude (AI Assistant) |

_Updated 03-20-2025 | AI: Cursor (Claude 3.7 Sonnet)_ 