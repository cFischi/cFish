# Digital Organization Quick Reference Guide

## Metadata
- **URL**: https://u.cfish.io/guides/digital-organization-reference
- **Last Updated**: 03-13-2025
- **Purpose**: Quick reference for cFish.io digital organization practices
- **Target Audience**: All cFish.io team members

---

## Key Files & Documentation

- **SOP**: `sop.md` - Comprehensive Standard Operating Procedure
- **File Naming Conventions**: `docs/standards/file-naming-conventions.md`
- **Technical Specification**: `spec.md` - tYDiSync~ system specification
- **Directory Structure Script**: `create-directory-structure.ps1`
- **Health Check Script**: `tools/daily-health-check.ps1`
- **Backup Script**: `tools/daily-backup.ps1`

## Directory Structure Overview

```
cFish.io/
├── src/                           # Source code by department
│   ├── u1-overheads/              # Business administration
│   ├── u2-research/               # R&D projects
│   ├── u3-operations/             # Operations management
│   ├── u4-production/             # Production systems
│   ├── u5-data-management/        # Data handling and security
│   ├── u6-social/                 # Social media and communications
│   └── u7-specialized/            # Specialized tools
├── docs/                          # Documentation
│   ├── api/                       # API documentation
│   ├── guides/                    # User guides and tutorials
│   ├── procedures/                # Standard operating procedures
│   └── standards/                 # Coding and org standards
├── tests/                         # Testing infrastructure
│   ├── unit/                      # Unit tests
│   ├── integration/               # Integration tests
│   └── performance/               # Performance tests
├── resources/                     # Shared resources
│   ├── templates/                 # Document and code templates
│   ├── assets/                    # Images, fonts, and media
│   └── schemas/                   # Data schemas and definitions
├── config/                        # Configuration files
├── tools/                         # Utility scripts and tools
├── wp-content/                    # WordPress specific files
├── sync-system/                   # tYDiSync~ system
├── memory.md                      # Project memory file
└── changelog.md                   # Project changelog
```

## File Naming Convention

### Standard Format
```
[CompanyPrefix]-[DeptNumber].[FunctionNumber]-[TaskIdentifier]-[Date].[extension]
```

Example: `ucf-u5.3-data-migration-20250313.js`

### Company Prefixes
- `ucf` - UcFish trust? + holdingz companY
- `tyf` - tYFeAiz
- `fh` - FiscHouse
- `ucw` - UcWebZ
- `uz` - the UZ
- `fe` - FischEYe
- `ty` - tYberius Designz

### Department Numbers
- `u1` - Overheads (OVR)
- `u2` - Research & Development (R+D)
- `u3` - Physical Operations (OPz)
- `u4` - Production (PRO)
- `u5` - Data Management (DMT)
- `u6` - Social Media/Communications (SMC)
- `u7` - Specialized Operations (SPEC)

## Daily Workflow Summary

### 1. Morning Routine (8:00-9:00 AM)
- Run health check: `.\tools\daily-health-check.ps1`
- Review ClickUp tasks and Notion documentation
- Verify sync status: `.\sync-system\start-optimized-sync.bat` if needed

### 2. Midday Tasks (12:00-1:00 PM)
- Update task statuses in ClickUp
- Document completed work in Notion
- Commit code changes with proper naming

### 3. End-of-Day (4:00-5:00 PM)
- Update memory.md with daily achievements
- Run backups: `.\tools\daily-backup.ps1`
- Prepare task list for next day

## Documentation Templates

### Standard Markdown Metadata Block
```markdown
## Metadata
- **URL**: https://u.cfish.io/path/to/resource
- **Last Updated**: MM-DD-YYYY
- **Purpose**: Brief description of document purpose
- **Target Audience**: Intended readers
```

### memory.md Entry Format
```markdown
## [Title] (MM-DD-YYYY)
- ✅ [Achievement or completed task]
- ✅ [Additional completed items]

_Updated MM-DD-YYYY | AI: Cursor (Claude 3.7 Sonnet)_
```

### changelog.md Entry Format
```markdown
## [Version] - [YYYY-MM-DD]

### Added
- [New feature description]

### Changed
- [Change description]

### Fixed
- [Bug fix description]
```

## Git Workflow

### Branch Naming Convention
- Feature branches: `feature/[brief-description]`
- Bug fixes: `bugfix/[issue-number]-[brief-description]`
- Hotfixes: `hotfix/[brief-description]`

### Commit Message Format
```
[Department]: [Brief description]

- Detailed explanation of changes
- Additional context if needed

Ref: [ClickUp task ID or Notion page link]
```

## Emergency Procedures

### Data Loss Prevention
- Check `.\backups\` for recent backups
- Use daily/weekly/monthly backups as needed
- See `docs/procedures/disaster-recovery.md` for detailed steps

### Sync System Issues
- Check sync logs at `.\sync-system\tydisync-debug.log`
- Restart sync system: `.\sync-system\start-optimized-sync.bat`
- Fix any conflicts between MD and JSON files manually if needed

---

_Updated 03-13-2025 | AI: Cursor (Claude 3.7 Sonnet)_ 