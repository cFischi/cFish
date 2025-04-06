# Digital Organization System Quick Reference

**URL:** https://cfish.io/docs/digital-organization-quick-reference  
**Last Updated:** 03-13-2025  
**Department:** U5 - Data Management  
**Author:** tY FischEYe  

## Directory Structure

```
cFish.io/
├── docs/                  # Documentation files
│   ├── procedures/        # Step-by-step guides
│   ├── specifications/    # Technical specifications
│   ├── quick-reference/   # Quick reference guides
│   └── sop/               # Standard Operating Procedures
├── tools/                 # Scripts and utilities
├── resources/             # Resources and templates
│   └── templates/         # Document templates
├── content/               # Content files
│   ├── markdown/          # Markdown content
│   ├── json/              # JSON data files
│   └── wordpress/         # WordPress content
├── backups/               # Backup files
│   ├── daily/             # Daily backups
│   ├── weekly/            # Weekly backups
│   └── monthly/           # Monthly backups
├── logs/                  # Log files
│   └── sync-system/       # Sync system logs
└── sync-system/           # tYDiSync~ system files
```

## File Naming Convention

### Format
`[prefix]-[department].[function]-[description]-[date].[extension]`

### Prefixes
- `tyf` - tY FischEYe (personal)
- `ucf` - UcFish (company)
- `ext` - External

### Department Codes
- `u1` - Executive
- `u2` - Development
- `u3` - Marketing
- `u4` - Operations
- `u5` - Data Management

### Function Codes
- `.1` - Documentation
- `.2` - Configuration
- `.3` - Data Migration
- `.4` - Automation
- `.5` - Analysis

### Example
`ucf-u5.3-file-migration-20250313.ps1`
- `ucf` - Company file
- `u5` - Data Management department
- `.3` - Data Migration function
- `file-migration` - Description
- `20250313` - Date (YYYYMMDD)
- `.ps1` - PowerShell script extension

## Key Scripts

| Script | Purpose | Usage |
|--------|---------|-------|
| `daily-health-check.ps1` | System health monitoring | Run daily to check system status |
| `daily-backup.ps1` | Automated backups | Run daily for content backup |
| `create-directory-structure.ps1` | Create standard directories | Run once for setup |
| `ucf-u5.3-file-migration-20250313.ps1` | Migrate files to new structure | Run for file migration |

## Templates

| Template | Purpose | Location |
|----------|---------|----------|
| Standard Document | General documentation | `resources/templates/standard-document-template.md` |
| Procedure | Step-by-step guides | `resources/templates/procedure-template.md` |
| Technical Specification | System specifications | `resources/templates/technical-spec-template.md` |

## Common Procedures

1. **Daily Health Check**
   ```powershell
   .\tools\daily-health-check.ps1
   ```

2. **Daily Backup**
   ```powershell
   .\tools\daily-backup.ps1
   ```

3. **File Migration**
   ```powershell
   .\tools\ucf-u5.3-file-migration-20250313.ps1
   ```

## Support

For assistance with the digital organization system, contact the Data Management department.

_Updated 03-13-2025 | Human: tY FischEYe_ 