# File Naming Checker Suite - Quick Reference Guide

## Overview

The cFish.io Digital Organization System includes a suite of file naming checker tools designed for different use cases. This quick reference guide explains when and how to use each checker variant.

## Checker Variants

### 1. Simple Checker
**Files**: `check-file-naming-simple.ps1`, `check-file-naming-simple.bat`

**When to use**:
- For a quick snapshot of file naming compliance
- When you only need to check top-level directories
- For immediate feedback during daily work
- When performance is a priority

**Features**:
- Ultra-fast top-level-only scanning that completes in seconds
- Clear progress indicators
- Color-coded output for better readability
- No detailed report file (console output only)

**Usage**:
```
.\check-file-naming-simple.bat
```

### 2. Standard Checker
**Files**: `check-file-naming-standard.ps1`, `check-file-naming-standard.bat`

**When to use**:
- For regular compliance monitoring
- When you need a balance of thoroughness and performance
- For scheduled weekly or monthly checks
- When you need a comprehensive report but don't want to wait for a full scan

**Features**:
- Moderate-depth check (1 level of subdirectories)
- Detailed progress percentages and file counts
- Generated report file in Markdown format
- Good performance even with thousands of files

**Usage**:
```
.\check-file-naming-standard.bat
```

**Report location**: `file-naming-standard-report.md`

### 3. Targeted Checker
**Files**: `check-file-naming-targeted.ps1`, `check-file-naming-targeted.bat`

**When to use**:
- When you need to focus on specific directories
- For targeted compliance improvement efforts
- When investigating issues in particular areas
- When you need detailed information about non-compliant files

**Features**:
- Interactive selection of directories to check
- Command-line parameters for automation
- Detailed mode for listing all non-compliant files
- Generated report file in Markdown format

**Usage (interactive)**:
```
.\check-file-naming-targeted.bat
```

**Usage (command-line)**:
```
.\check-file-naming-targeted.ps1 -TargetDirectories "docs","U1-Administration" -Detailed
```

**Report location**: `file-naming-targeted-report.md`

### 4. Full Checker (Original)
**Files**: `check-file-naming.ps1`, `ucf-u5.3-check-file-naming-20250314.bat`

**When to use**:
- For comprehensive compliance audits
- When you need to check all files at all directory levels
- For monthly or quarterly compliance reporting
- When thoroughness is more important than speed

**Features**:
- Full-depth scanning of all directories
- Option to automatically rename non-compliant files
- Comprehensive reporting of all issues
- Most thorough but slowest option

**Usage (check only)**:
```
.\ucf-u5.3-check-file-naming-20250314.bat
```

**Usage (auto-rename)**:
```
.\ucf-u5.3-check-file-naming-20250314.bat -fix
```

## Recommended Usage Patterns

1. **Daily Work**: Use the Simple Checker for quick feedback during daily work
2. **Weekly Monitoring**: Schedule the Standard Checker to run weekly for regular compliance monitoring
3. **Targeted Improvement**: Use the Targeted Checker when working on improving compliance in specific areas
4. **Quarterly Audits**: Use the Full Checker for comprehensive quarterly compliance audits

## Scheduling Examples

### Weekly Standard Check
To schedule a weekly standard check on Monday at 9:00 AM:
```
schtasks /create /tn "Weekly File Naming Check" /tr "C:\Users\Chris\cFish.io\check-file-naming-standard.bat" /sc weekly /d MON /st 09:00
```

### Monthly Full Check
To schedule a monthly full check on the first day of each month:
```
schtasks /create /tn "Monthly Full File Naming Check" /tr "C:\Users\Chris\cFish.io\ucf-u5.3-check-file-naming-20250314.bat" /sc monthly /d 1 /st 02:00
```

## Interpreting Results

Each checker provides:
- **Total files**: The total number of files checked
- **Compliant files**: Files that follow the naming convention
- **Non-compliant files**: Files that don't follow the naming convention
- **Excluded files**: Files that are intentionally excluded from checking
- **Compliance rate**: The percentage of checked files that follow the convention

A healthy system should aim for a compliance rate of at least 90% for files that aren't excluded.

---

_Updated 12-04-2023 | AI: Cursor (Claude 3.7 Sonnet)_ 