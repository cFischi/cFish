# cFish.io File Management System SOP

## Standard Operating Procedure for UcF Ecosystem File Organization
_Document Version: 1.2_

## 1. Overview

This document establishes standard operating procedures for managing non-development files within the cFish.io ecosystem while preserving the integrity of the WordPress installation. The procedures outlined here are designed to create a structured, department-based file organization system that aligns with the UcF organizational structure.

### 1.1 Purpose

This SOP ensures:
- Consistent file organization across all departments
- Clear hierarchical structure reflecting the organizational structure
- Efficient file retrieval and discovery
- Reduced duplication of resources
- Improved collaboration between departments
- Preservation of WordPress website integrity

### 1.2 Scope

This SOP applies to:
- All digital assets within the cFish.io ecosystem
- All departments (U1-U7) and shared resources
- All team members working with digital files
- WordPress and non-WordPress content

### 1.3 UcF Organizational Hierarchy

cFish.io follows the Universal UcF departmental structure with seven primary departments:

- **U1 (OVR)**: Overheads ~ "Soul" - front office, sales, client work
- **U2 (R+D)**: Research and Development ~ "Mind" - innovations, markets, prototyping
- **U3 (OPz)**: Physical Operations ~ "Body" - facilities, logistics, resource allocation
- **U4 (PRO)**: Production ~ "Produce" - manufacturing, quality control
- **U5 (DMT)**: Data Management/Communications ~ "Communicate" - database, IT, support
- **U6 (SMC)**: Societal/Multi-Media/Connecting ~ "Connect" - campaigns, PR, content
- **U7 (SPEC)**: Specialized Operations ~ "Serve" - functions unique to each subsidiary

## 2. File Structure

### 2.1 Top-Level Directory Structure

```
cFish.io/
├── WordPress/         # Your actual website files (wp-content, etc.)
├── Backups/           # Website backups
├── U1-Production/     # Production department
├── U2-Management/     # Management department
├── U3-Research/       # Research department
├── U4-Production/     # Production department (different division)
├── U5-Intelligence/   # Intelligence department
├── U6-Operations/     # Operations department
├── U7-Innovation/     # Innovation department
└── UcF-Shared/        # Cross-departmental resources
```

### 2.2 Department Subfolder Structure

Each department folder (U1-U7) should contain the following standardized subfolders:

```
Ux-Department/
├── Documentation/ # Department-specific documentation
├── Planning/      # Department planning materials
├── Assets/        # Department-related assets
├── Development/   # Department development materials
├── Templates/     # Department-specific templates
├── Meetings/      # Meeting notes and recordings
├── Reports/       # Regular departmental reports
├── Analysis/      # Data analysis and insights
└── Training/      # Department-specific training materials
```

### 2.3 Cross-Departmental Resources

```
UcF-Shared/
├── Branding/      # Brand guidelines, logos used by all departments
├── Templates/     # Shared templates
├── Policies/      # Company-wide policies
├── Training/      # Cross-departmental training materials
├── Meetings/      # Cross-departmental meetings
└── Strategic/     # Strategic planning documents
```

### 2.4 Project-Based Organization

For project-based work that spans multiple departments:

```
UcF-Shared/Projects/
├── Project-Name/
│   ├── Brief/         # Project specifications and requirements
│   ├── Planning/      # Planning documents and timelines
│   ├── Resources/     # Shared project resources
│   ├── Deliverables/  # Final project outputs
│   ├── Archive/       # Archived project materials
│   └── README.md      # Project overview and navigation guide
```

Project folders should include a department identifier prefix when primarily owned by a specific department: `U3-Research-Project-Name/`

### 2.5 Alternative Department Folder Naming

For compatibility with some existing systems, the following alternative folder naming convention may be used:

```
01_OVR_Overheads/       # U1 - Overheads
02_RD_Research_Development/ # U2 - Research and Development
03_OPS_Physical_Operations/ # U3 - Operations
04_PRO_Production/      # U4 - Production
05_DMT_Data_Communications/ # U5 - Data Management
06_SMC_Societal_MultiMedia/ # U6 - Social Media/Communications
07_SPEC_Spec_Ops/       # U7 - Specialized Operations
```

When using this format, maintain the same internal subfolder structure as specified in section 2.2.

## 3. Naming Conventions

### 3.1 Directory Naming

- Use kebab-case for directories (lowercase with hyphens): `project-planning/`
- Department directories should use the prefix "U" followed by the department number: `U1-Production`
- Begin each directory name with a capital letter after the department prefix: `U1-Production/Assets/`

### 3.2 File Naming

- Use descriptive prefixes that identify the department: `u1-production-workflow.md`
- Include dates in filenames for version-specific documents: `u3-research-findings-2025-03-15.pdf`
- Avoid spaces and special characters in all filenames
- Use lowercase for filenames with hyphens between words: `u5-intelligence-report-q1.xlsx`

### 3.3 File Categorization

Use the following prefixes to categorize files by type:

- `doc-` for documentation files: `doc-u2-management-process.md`
- `tpl-` for templates: `tpl-u5-intelligence-report.docx`
- `rpt-` for reports: `rpt-u1-production-monthly-2025-03.pdf`
- `mtg-` for meeting notes: `mtg-u6-operations-weekly-2025-03-15.md`
- `pol-` for policies: `pol-ucf-shared-security-2025.pdf`
- `res-` for research: `res-u3-research-findings-2025-03.pdf`

### 3.4 Version Control in Filenames

When version control system is not available, use the following version notation:

- Include version in filename: `u1-production-workflow-v1-2.md`
- Major version: Substantial changes (v1, v2)
- Minor version: Minor updates (v1-1, v1-2)
- Date-based: For daily or frequent updates `u7-innovation-daily-20250315.md`

### 3.5 UcF Hierarchical Naming Convention

For full compatibility with the UcF system, use the following hierarchical naming convention:

```
[CompanyPrefix]-[DeptNumber].[FunctionNumber]-[TaskIdentifier]-[Date].[extension]
```

Example: `ucf-u5.3-data-migration-20250313.js`

Components:
- **Company Prefix**: 
  - `ucf` - UcFish (company)
  - `tyf` - tY FischEYe (personal)
  - `fh` - FiscHouse
  - `ucw` - UcWebZ
  - `uz` - the UZ
  - `fe` - FischEYe
  - `ty` - tYberius Designz

- **Department Number**: u1-u7 corresponding to UcF departments

- **Function Number**: Department-specific function identifier (1-9)
  - `.1` - Documentation
  - `.2` - Configuration
  - `.3` - Tools/Scripts
  - `.4` - Development
  - `.5` - Testing
  - `.6` - Automation
  - `.7` - Infrastructure
  - `.8` - Business/Financial
  - `.9` - Miscellaneous

- **Task Identifier**: Brief, hyphen-separated description
- **Date**: Format: YYYYMMDD for version-sensitive documents

## 4. File Management Practices

### 4.1 Version Control

- Utilize Git for tracking all documentation and project files
- Create a .gitignore file that excludes:
  - Local configuration files
  - Temporary files
  - Large binary assets (use Git LFS if needed)
  - Sensitive information

### 4.2 Documentation Standards

- Maintain a centralized `memory.md` file in each department's Documentation directory
- Use markdown format for maximum compatibility
- Each department should maintain its own documentation index
- Follow the established documentation format:
  ```
  ## [Title] (MM-DD-2025)
  - [Bullet points with key information]
  - [More bullet points as needed]

  _Updated MM-DD-2025 | AI: Cursor (Claude 3.7 Sonnet)_
  ```

### 4.3 Changelog Maintenance

Each department should maintain a `changelog.md` file in its Documentation directory following this format:

```markdown
# [Department Name] Changelog

## [Version Number] - [YYYY-MM-DD]

### Added
- [New features or files added]

### Changed
- [Changes to existing functionality or files]

### Fixed
- [Bug or issue fixes]

### Removed
- [Deprecated features or files removed]
```

For example:

```markdown
# U1-Production Changelog

## 1.0.0 - 2025-03-10

### Added
- Created standard folder structure
- Added production workflow documentation
- Implemented asset naming convention

### Changed
- Updated project planning templates
- Migrated existing documents to new structure

### Fixed
- Corrected inconsistent file naming
- Resolved duplicate asset storage issues
```

### 4.4 Metadata and Tagging

To improve searchability and organization:

- Use consistent keywords in document headers
- Implement front matter in markdown files:
  ```
  ---
  title: Production Workflow Guide
  department: U1-Production
  author: Team Member Name
  created: 2025-03-10
  updated: 2025-03-15
  version: 1.2
  status: [Draft|Review|Approved|Archived]
  tags: [workflow, production, guide, onboarding]
  related: [u1-production-checklist.md, u1-production-roles.md]
  ---
  ```
- Tag files with appropriate categories in document properties
- Use descriptive commit messages when using version control

### 4.5 Digital Asset Management

For specialized file types:

#### 4.5.1 Images
- Store in `/Assets/Images/` within department directories
- Use web-optimized formats (JPEG, PNG, WebP)
- Include dimensions in filename for UI assets: `u1-hero-banner-1920x1080.jpg`
- Organize by project or purpose

#### 4.5.2 Documents
- Prefer markdown (.md) for documentation when possible
- Use PDF for finalized documents
- Store editable versions (.docx, .pptx) alongside finalized versions
- Include document type in filename: `sop-file-management.md`

#### 4.5.3 Data Files
- Store in `/Analysis/Data/` within department directories
- Include date and data source in filename: `u3-market-data-2025-03-q1.xlsx`
- Document data structure in accompanying README files
- Consider data versioning for critical datasets

### 4.6 Automation and Tooling

The following tools are available to assist with file management:

#### 4.6.1 File Organization Scripts
- `organize-cfish-io.ps1`: Main organization script
  - Creates directory structure
  - Copies files to appropriate locations
  - Updates documentation

- `create-cfish-organization.ps1`: Initial directory structure creation
  - Sets up the UcF department structure
  - Creates standardized subfolders
  - Generates README files

#### 4.6.2 File Naming Tools
- `check-file-naming.ps1`: File naming convention checker
  - Validates files against the naming convention
  - Generates compliance report
  - Suggests proper names for non-compliant files

- `rename-to-ucf-convention.ps1`: Automated renaming tool
  - Renames files to follow the UcF convention
  - Creates backup of original filenames
  - Logs all filename changes

#### 4.6.3 Scheduled Maintenance
- `daily-health-check.ps1`: System verification
  - Runs at 8:00 AM daily
  - Validates directory structure
  - Checks for non-compliant files
  - Reports issues via email

- `daily-backup.ps1`: Backup creation
  - Runs at 10:00 PM daily
  - Creates incremental backups
  - Implements retention policy

## 5. Security Considerations

### 5.1 Access Controls

- Implement role-based access control for department directories
- Use appropriate file permissions:
  - WordPress directories: 755 for folders, 644 for files
  - Configuration files: 600
  - Project management files: based on sensitivity

### 5.2 Sensitive Information

- Never store sensitive information (API keys, passwords) in plaintext files
- Use .env files (excluded from version control) for local configuration
- Consider encryption for highly sensitive documents

### 5.3 Data Classification

Implement data classification to determine proper handling:

- **Public**: General information, unrestricted
- **Internal**: For UcF team use only, not sensitive
- **Confidential**: Limited to specific departments/roles
- **Restricted**: Highly sensitive (financial, personal data)

Include classification prefixes in sensitive file directories:
- `INT-` for Internal
- `CONF-` for Confidential
- `REST-` for Restricted

## 6. WordPress Considerations

### 6.1 Website Integrity

- Never modify WordPress core files, theme files, or plugin files
- Do not rename any files that the website depends on
- Avoid storing non-website files within the WordPress directory structure

### 6.2 WordPress Documentation

- Document all custom themes and plugins in the appropriate department folder
- Maintain separate documentation for WordPress configurations
- Keep records of all WordPress customizations

### 6.3 WordPress-Related Files Organization

Organize WordPress-related development files outside the WordPress directory:

```
U1-Production/Development/WordPress/
├── Themes/           # Theme development files
├── Plugins/          # Plugin development files
├── Customizations/   # Custom code snippets
├── Content-Exports/  # Exported content
└── Databases/        # Database backups and migrations
```

## 7. Backup Procedures

### 7.1 Backup Strategy

- Create regular backups of your WordPress installation separate from development files
- Store backups in the dedicated Backups directory
- Implement a retention policy (daily for 7 days, weekly for 4 weeks, monthly for 12 months)
- Test restoration procedures quarterly

### 7.2 Department Backups

- Each department should create backups of critical documents
- Store department backups within the department's Documentation/Backups subdirectory

### 7.3 Digital Preservation

For long-term preservation of critical documents:

- Convert to archival formats (PDF/A)
- Store multiple copies in different locations
- Document retention periods for different file types
- Create catalog of archived materials
- Verify archives annually

## 8. Implementation Plan

### 8.1 Initial Setup

1. Create the top-level directory structure
2. Create department subfolders
3. Set up version control repository
4. Configure access controls

### 8.2 Migration

1. Inventory existing files
2. Map files to their appropriate department and subfolder
3. Migrate files according to the new structure
4. Update any internal links or references

### 8.3 Training

1. Document the new file system
2. Train team members on the new structure
3. Provide reference guides for each department

### 8.4 Cross-Departmental Collaboration

1. Establish clear ownership and access policies
2. Create shared workspaces for collaborative projects
3. Implement notification system for file updates
4. Document collaboration workflows
5. Develop conflict resolution procedures for shared resources

### 8.5 Implementation Scripts

The complete implementation process is supported by the following scripts:

1. **Step 1: Backup Current Files**
   ```powershell
   # Run backup script:
   ./organize-cfish-io.ps1 -backupOnly
   ```

2. **Step 2: Create Directory Structure**
   ```powershell
   # Create directory structure:
   ./create-cfish-organization.ps1
   ```

3. **Step 3: Organize Files**
   ```powershell
   # Organize files:
   ./organize-cfish-io.ps1 -organize
   ```

4. **Step 4: Generate Documentation**
   ```powershell
   # Create mapping documentation:
   ./organize-cfish-io.ps1 -documentation
   ```

5. **Step 5: Verify Organization**
   ```powershell
   # Check file naming:
   ./check-file-naming.ps1 -verbose
   ```

6. **Step 6: Update Documentation**
   ```powershell
   # Update memory.md and changelog.md:
   ./update-memory.ps1
   ```

## 9. Maintenance Schedule

### 9.1 Regular Reviews

- Weekly: Quick check for adherence to naming conventions
- Monthly: Department leads review their file organization
- Quarterly: Full system review and cleanup

### 9.2 Auditing

- Quarterly: Audit file permissions and access controls
- Semi-annually: Comprehensive structure review
- Annually: Full system evaluation and optimization

### 9.3 Continuous Improvement

- Monthly: Collect feedback from team members on usability
- Quarterly: Assess file retrieval efficiency
- Semi-annually: Review and update documentation
- Annually: Evaluate and improve metadata strategy

## 10. Digital Workflow Integration

### 10.1 File Handoff Procedures

For files transferred between departments:

1. Use standardized handoff templates
2. Document file status at transfer time
3. Maintain version history across transfers
4. Track file custody through metadata

### 10.2 Digital Workspace Integration

- Link digital workspace tools to file structure
- Ensure consistency between cloud storage and local files
- Establish rules for file synchronization
- Document workflows for accessing files from different platforms

### 10.3 Cross-Platform Integration

#### 10.3.1 WordPress Integration
- Use tYDiSync~ to maintain MD-JSON parity
- Deploy WordPress content via established pipelines
- Document content updates in ClickUp

#### 10.3.2 ClickUp Integration
- Align ClickUp tasks with directory structure
- Use consistent task naming conventions
- Link tasks to relevant documentation

#### 10.3.3 Notion Integration
- Organize Notion pages by department
- Maintain consistent page templates
- Regularly update cross-references

## 11. Governance and Compliance

### 11.1 File System Governance

- Establish file system governance committee with representatives from each department
- Review and approve changes to directory structure
- Enforce naming conventions and organization standards
- Periodically audit compliance with the SOP

### 11.2 Regulatory Compliance

- Identify files subject to regulatory requirements
- Document retention and deletion policies
- Implement necessary controls for protected information
- Maintain audit trails for compliance verification

### 11.3 UcF Department Governance

Each UcF department has specific governance responsibilities:

- **U1 (OVR)**: Oversee compliance with business standards and policies
- **U2 (R+D)**: Manage innovation documentation and research assets
- **U3 (OPz)**: Ensure operational documentation follows standards
- **U4 (PRO)**: Maintain production documentation and assets
- **U5 (DMT)**: Govern data management practices and technical documentation
- **U6 (SMC)**: Oversee media asset organization and campaign documentation
- **U7 (SPEC)**: Manage specialized documentation needs across subsidiaries

---

# Change Log

## Version 1.2 - 2025-04-18

### Added
- Incorporated UcF hierarchical naming convention with company prefixes and function numbers
- Added alternative department folder naming format (01_OVR_Overheads)
- Included detailed UcF organizational hierarchy and department descriptions
- Added implementation scripts with specific commands for each step
- Incorporated cross-platform integration for WordPress, ClickUp, and Notion
- Added UcF department governance responsibilities

### Changed
- Updated file naming conventions to include both categorization prefixes and UcF hierarchical naming
- Enhanced automation and tooling section with specific scripts and descriptions
- Expanded implementation plan with detailed steps and commands
- Updated digital workspace integration with platform-specific requirements

## Version 1.1 - 2025-04-15

### Added
- Expanded overview with purpose and scope sections
- Added project-based organization structure
- Introduced file categorization and prefixing system
- Added metadata and tagging guidelines
- Created digital asset management section for specialized file types
- Added data classification framework
- Expanded WordPress-related files organization
- Added digital preservation guidelines
- Included cross-departmental collaboration workflows
- Added continuous improvement processes
- Created digital workflow integration section
- Added governance and compliance section

### Changed
- Updated document version to 1.1
- Enhanced file naming conventions with additional examples
- Expanded security considerations with data classification
- Improved maintenance schedule with feedback mechanisms

## Version 1.0.0 - 2025-03-10

### Added
- Created initial SOP document
- Defined department-based file structure
- Established naming conventions
- Set up security and backup procedures
- Developed implementation plan

---

# Implementation Steps

## Immediate (Week 1):
1. Create the top-level directory structure (WordPress, Backups, U1-U7, UcF-Shared)
2. Set up the standard subfolder structure in each department directory
3. Implement version control for the file system

## Short-term (Weeks 2-3):
4. Inventory all existing files across the current system
5. Develop a mapping plan for file migration
6. Begin migrating files to their appropriate locations
7. Document the migration process in each department's changelog

## Medium-term (Weeks 4-6):
8. Complete file migration
9. Create department-specific memory.md files
10. Establish documentation indexes for each department
11. Train team members on the new file system

## Long-term (Months 2-3):
12. Conduct first quarterly review
13. Optimize file organization based on usage patterns
14. Implement automated backup procedures
15. Develop a comprehensive metadata strategy for improved searchability

## Extended (Months 4-6):
16. Implement metadata strategy
17. Establish governance committee
18. Deploy collaboration workflow
19. Create digital preservation system
20. Conduct usability assessment

## JSON Format for AI Ingestion

```json
{
  "document_type": "cFish.io File Management System",
  "version": "1.2.0",
  "date_created": "2025-03-10",
  "date_updated": "2025-04-18",
  "author": "Claude 3.7 Sonnet via Cursor",
  "key_decisions": [
    {
      "id": 1,
      "title": "Department-First Organization",
      "description": "Adopted a department-first organization structure (U1-U7)",
      "impact": "Aligns file system with organizational structure"
    },
    {
      "id": 2,
      "title": "Consistent Subdirectory Structure",
      "description": "Established consistent subdirectory structure within each department",
      "impact": "Creates predictable navigation and file discovery"
    },
    {
      "id": 3,
      "title": "Shared Resources",
      "description": "Created a UcF-Shared directory for cross-departmental resources",
      "impact": "Eliminates duplication and centralizes common materials"
    },
    {
      "id": 4,
      "title": "WordPress Preservation",
      "description": "Preserved WordPress and Backups directories at the top level",
      "impact": "Maintains website integrity and protects critical files"
    },
    {
      "id": 5,
      "title": "Documentation Standards",
      "description": "Documented naming conventions and file management practices",
      "impact": "Ensures consistency and improves findability"
    },
    {
      "id": 6,
      "title": "Change Tracking",
      "description": "Created change log standards for tracking modifications",
      "impact": "Provides audit trail and version history"
    },
    {
      "id": 7,
      "title": "Metadata Strategy",
      "description": "Implemented comprehensive metadata and tagging approach",
      "impact": "Improves searchability and file relationships"
    },
    {
      "id": 8,
      "title": "Digital Asset Management",
      "description": "Created specialized handling for different file types",
      "impact": "Optimizes storage and improves asset utilization"
    },
    {
      "id": 9,
      "title": "File Categorization",
      "description": "Established prefix system for file categorization",
      "impact": "Enhances visual identification and organization"
    },
    {
      "id": 10,
      "title": "Data Classification",
      "description": "Implemented security-based classification system",
      "impact": "Ensures appropriate handling of sensitive information"
    },
    {
      "id": 11,
      "title": "Governance Structure",
      "description": "Created file system governance framework",
      "impact": "Ensures ongoing compliance and system maintenance"
    },
    {
      "id": 12,
      "title": "UcF Hierarchical Naming",
      "description": "Incorporated UcF hierarchical naming conventions",
      "impact": "Ensures compatibility with existing UcF ecosystem"
    },
    {
      "id": 13,
      "title": "Implementation Automation",
      "description": "Created scripts for automated implementation",
      "impact": "Streamlines transition to new organization system"
    },
    {
      "id": 14,
      "title": "Cross-Platform Integration",
      "description": "Established guidelines for WordPress, ClickUp, and Notion integration",
      "impact": "Creates consistent experience across all platforms"
    }
  ],
  "implementation_plan": {
    "phases": [
      {
        "phase": "Immediate",
        "timeframe": "Week 1",
        "steps": [
          {
            "id": 1,
            "action": "Create the top-level directory structure",
            "details": "WordPress, Backups, U1-U7, UcF-Shared",
            "responsible": "System administrator",
            "dependencies": [],
            "command": "./create-cfish-organization.ps1"
          },
          {
            "id": 2,
            "action": "Set up standard subfolder structure",
            "details": "Create consistent subfolders in each department directory",
            "responsible": "System administrator",
            "dependencies": [1],
            "command": "./create-cfish-organization.ps1 -subfoldersOnly"
          },
          {
            "id": 3,
            "action": "Implement version control",
            "details": "Set up Git repository with appropriate .gitignore",
            "responsible": "Development team",
            "dependencies": [1],
            "command": "git init && git add .gitignore README.md && git commit -m 'Initial commit'"
          }
        ]
      },
      {
        "phase": "Short-term",
        "timeframe": "Weeks 2-3",
        "steps": [
          {
            "id": 4,
            "action": "Inventory existing files",
            "details": "Catalog all files across current system",
            "responsible": "Department leads",
            "dependencies": []
          },
          {
            "id": 5,
            "action": "Develop migration mapping",
            "details": "Plan for file relocation to new structure",
            "responsible": "Department leads",
            "dependencies": [4]
          },
          {
            "id": 6,
            "action": "Begin file migration",
            "details": "Start moving files to appropriate locations",
            "responsible": "All team members",
            "dependencies": [2, 5]
          },
          {
            "id": 7,
            "action": "Document migration process",
            "details": "Record changes in department changelogs",
            "responsible": "Department leads",
            "dependencies": [6]
          }
        ]
      },
      {
        "phase": "Medium-term",
        "timeframe": "Weeks 4-6",
        "steps": [
          {
            "id": 8,
            "action": "Complete file migration",
            "details": "Finish relocating all files to new structure",
            "responsible": "All team members",
            "dependencies": [6]
          },
          {
            "id": 9,
            "action": "Create memory.md files",
            "details": "Establish department documentation records",
            "responsible": "Department leads",
            "dependencies": [8]
          },
          {
            "id": 10,
            "action": "Establish documentation indexes",
            "details": "Create file finding aids for each department",
            "responsible": "Documentation team",
            "dependencies": [8]
          },
          {
            "id": 11,
            "action": "Train team members",
            "details": "Educate all staff on new file system",
            "responsible": "Training coordinator",
            "dependencies": [9, 10]
          }
        ]
      },
      {
        "phase": "Long-term",
        "timeframe": "Months 2-3",
        "steps": [
          {
            "id": 12,
            "action": "Conduct quarterly review",
            "details": "First comprehensive system evaluation",
            "responsible": "System administrator",
            "dependencies": [8]
          },
          {
            "id": 13,
            "action": "Optimize file organization",
            "details": "Refine structure based on usage patterns",
            "responsible": "Department leads",
            "dependencies": [12]
          },
          {
            "id": 14,
            "action": "Implement automated backups",
            "details": "Set up scheduled backup procedures",
            "responsible": "System administrator",
            "dependencies": [8]
          },
          {
            "id": 15,
            "action": "Develop metadata strategy",
            "details": "Create tagging system for improved searchability",
            "responsible": "Documentation team",
            "dependencies": [13]
          }
        ]
      },
      {
        "phase": "Extended",
        "timeframe": "Months 4-6",
        "steps": [
          {
            "id": 16,
            "action": "Implement metadata strategy",
            "details": "Deploy file tagging and metadata framework across departments",
            "responsible": "Documentation team",
            "dependencies": [15]
          },
          {
            "id": 17,
            "action": "Establish governance committee",
            "details": "Form cross-departmental governance structure",
            "responsible": "Department leads",
            "dependencies": [11]
          },
          {
            "id": 18,
            "action": "Deploy collaboration workflow",
            "details": "Implement cross-departmental file sharing procedures",
            "responsible": "System administrator",
            "dependencies": [16]
          },
          {
            "id": 19,
            "action": "Create digital preservation system",
            "details": "Establish long-term archival procedures",
            "responsible": "Documentation team",
            "dependencies": [14]
          },
          {
            "id": 20,
            "action": "Conduct usability assessment",
            "details": "Evaluate system effectiveness and user satisfaction",
            "responsible": "Training coordinator",
            "dependencies": [16, 17, 18, 19]
          },
          {
            "id": 21,
            "action": "Cross-platform integration",
            "details": "Implement integration with WordPress, ClickUp, and Notion",
            "responsible": "Integration specialist",
            "dependencies": [16, 18],
            "command": "./setup-platform-integration.ps1"
          }
        ]
      }
    ]
  },
  "file_structure": {
    "top_level": [
      "WordPress/",
      "Backups/",
      "U1-Production/",
      "U2-Management/",
      "U3-Research/",
      "U4-Production/",
      "U5-Intelligence/",
      "U6-Operations/",
      "U7-Innovation/",
      "UcF-Shared/"
    ],
    "department_subfolders": [
      "Documentation/",
      "Planning/",
      "Assets/",
      "Development/",
      "Templates/",
      "Meetings/",
      "Reports/",
      "Analysis/",
      "Training/"
    ],
    "shared_subfolders": [
      "Branding/",
      "Templates/",
      "Policies/",
      "Training/",
      "Meetings/",
      "Strategic/"
    ],
    "project_subfolders": [
      "Brief/",
      "Planning/",
      "Resources/",
      "Deliverables/",
      "Archive/",
      "README.md"
    ],
    "alternative_naming": {
      "pattern": "Number_Abbreviation_FullName",
      "examples": [
        "01_OVR_Overheads/",
        "02_RD_Research_Development/",
        "03_OPS_Physical_Operations/",
        "04_PRO_Production/",
        "05_DMT_Data_Communications/",
        "06_SMC_Societal_MultiMedia/",
        "07_SPEC_Spec_Ops/"
      ]
    }
  },
  "naming_conventions": {
    "directories": {
      "pattern": "kebab-case with capital first letter",
      "examples": ["U1-Production/", "Assets/", "Project-Planning/"]
    },
    "files": {
      "pattern": "lowercase kebab-case with department prefix",
      "examples": ["u1-production-workflow.md", "u3-research-findings-2025-03-15.pdf"]
    },
    "file_categorization": {
      "pattern": "type-prefix-department-name-version",
      "examples": ["doc-u2-management-process.md", "rpt-u1-production-monthly-2025-03.pdf"]
    },
    "versioning": {
      "pattern": "major.minor versioning in filename",
      "examples": ["u1-production-workflow-v1-2.md", "u7-innovation-daily-20250315.md"]
    },
    "ucf_hierarchical": {
      "pattern": "[CompanyPrefix]-[DeptNumber].[FunctionNumber]-[TaskIdentifier]-[Date]",
      "examples": ["ucf-u5.3-data-migration-20250313.js", "tyf-u1.1-documentation-20250418.md"],
      "company_prefixes": ["ucf", "tyf", "fh", "ucw", "uz", "fe", "ty"],
      "function_numbers": {
        "1": "Documentation",
        "2": "Configuration",
        "3": "Tools/Scripts",
        "4": "Development",
        "5": "Testing",
        "6": "Automation",
        "7": "Infrastructure",
        "8": "Business/Financial",
        "9": "Miscellaneous"
      }
    }
  },
  "departments": {
    "structure": [
      {
        "code": "U1",
        "abbreviation": "OVR",
        "name": "Overheads",
        "description": "Front office, sales, client work",
        "metaphor": "Soul"
      },
      {
        "code": "U2",
        "abbreviation": "R+D",
        "name": "Research and Development",
        "description": "Innovations, markets, prototyping",
        "metaphor": "Mind"
      },
      {
        "code": "U3",
        "abbreviation": "OPz",
        "name": "Physical Operations",
        "description": "Facilities, logistics, resource allocation",
        "metaphor": "Body"
      },
      {
        "code": "U4",
        "abbreviation": "PRO",
        "name": "Production",
        "description": "Manufacturing, quality control",
        "metaphor": "Produce"
      },
      {
        "code": "U5",
        "abbreviation": "DMT",
        "name": "Data Management/Communications",
        "description": "Database, IT, support",
        "metaphor": "Communicate"
      },
      {
        "code": "U6",
        "abbreviation": "SMC",
        "name": "Societal/Multi-Media/Connecting",
        "description": "Campaigns, PR, content",
        "metaphor": "Connect"
      },
      {
        "code": "U7",
        "abbreviation": "SPEC",
        "name": "Specialized Operations",
        "description": "Functions unique to each subsidiary",
        "metaphor": "Serve"
      }
    ]
  },
  "automation": {
    "scripts": [
      {
        "name": "organize-cfish-io.ps1",
        "purpose": "Main organization script",
        "functions": ["Create directory structure", "Copy files to appropriate locations", "Update documentation"]
      },
      {
        "name": "check-file-naming.ps1",
        "purpose": "File naming convention checker",
        "functions": ["Validate files against naming convention", "Generate compliance report", "Suggest proper names"]
      },
      {
        "name": "rename-to-ucf-convention.ps1",
        "purpose": "Automated renaming tool",
        "functions": ["Rename files to follow UcF convention", "Create backup of original filenames", "Log changes"]
      },
      {
        "name": "daily-health-check.ps1",
        "purpose": "System verification",
        "functions": ["Validate directory structure", "Check for non-compliant files", "Report issues"]
      },
      {
        "name": "daily-backup.ps1",
        "purpose": "Backup creation",
        "functions": ["Create incremental backups", "Implement retention policy", "Verify backup integrity"]
      }
    ]
  },
  "changelog_format": {
    "structure": [
      "# [Department Name] Changelog",
      "## [Version Number] - [YYYY-MM-DD]",
      "### Added",
      "- [New features or files added]",
      "### Changed",
      "- [Changes to existing functionality or files]",
      "### Fixed",
      "- [Bug or issue fixes]",
      "### Removed",
      "- [Deprecated features or files removed]"
    ]
  },
  "documentation_format": {
    "memory_md": {
      "structure": [
        "## [Title] (MM-DD-2025)",
        "- [Bullet points with key information]",
        "- [More bullet points as needed]",
        "",
        "_Updated MM-DD-2025 | AI: Cursor (Claude 3.7 Sonnet)_"
      ]
    }
  },
  "maintenance_schedule": {
    "weekly": [
      "Check adherence to naming conventions"
    ],
    "monthly": [
      "Department leads review file organization"
    ],
    "quarterly": [
      "Full system review and cleanup",
      "Audit file permissions and access controls"
    ],
    "semi_annually": [
      "Comprehensive structure review"
    ],
    "annually": [
      "Full system evaluation and optimization"
    ],
    "continuous_improvement": [
      "Monthly user feedback collection",
      "Quarterly file retrieval efficiency assessment",
      "Semi-annual documentation update",
      "Annual metadata strategy evaluation"
    ]
  },
  "cross_platform_integration": {
    "platforms": [
      {
        "name": "WordPress",
        "integration_points": [
          "Content synchronization via tYDiSync~",
          "Custom post type mapping",
          "Media asset organization"
        ]
      },
      {
        "name": "ClickUp",
        "integration_points": [
          "Task alignment with directory structure",
          "Consistent task naming conventions",
          "Document linking to relevant files"
        ]
      },
      {
        "name": "Notion",
        "integration_points": [
          "Department-based page organization",
          "Consistent templates across platforms",
          "Cross-reference maintenance"
        ]
      }
    ]
  },
  "conclusion": {
    "summary": "The new file management system creates a structured approach that aligns with the UcF organizational structure while preserving the integrity of the WordPress installation. By organizing files by department first, then by type, we've created a system that is both intuitive and scalable.",
    "implementation_notes": "The implementation plan provides a clear roadmap for migration, with defined responsibilities and timelines. Regular maintenance procedures will ensure the system remains effective over time.",
    "document_status": "This SOP should be treated as a living document, with updates made as needed to reflect evolving requirements and best practices.",
    "future_enhancements": {
      "potential_improvements": [
        "Integration with digital asset management software",
        "Automated metadata extraction and tagging",
        "Machine learning for content categorization",
        "Enhanced search capabilities across departments",
        "Integration with project management workflows"
      ],
      "evaluation_timeline": "Assess potential enhancements annually"
    }
  }
}
```

_Updated 04-18-2025 | AI: Cursor (Claude 3.7 Sonnet)_ 