# cFish.io Emergency Recovery Guide
**Date**: 2025-03-15  
**Version**: 1.0  
**Created By**: Claude 3.7 Sonnet (Cursor)

## Purpose

This document provides comprehensive procedures for recovering from data loss, corruption, or system failure in the cFish.io Digital Organization System. It outlines step-by-step recovery processes, identifies critical files and backup locations, and establishes clear escalation procedures.

## Critical Files and Their Locations

### Primary Files
| File | Location | Purpose | Recovery Priority |
|------|----------|---------|------------------|
| memory.md | Root directory | System memory and change history | Critical |
| changelog.md | Root directory | Version tracking and change documentation | Critical |
| ucf-u7.3-directory-visual-order-20250314.ps1 | U7-Systems/Scripts | Visual directory organization tool | High |
| show-directory-order.bat | U7-Systems/Scripts | User interface for directory tool | High |
| verify-backup-integrity.ps1 | U5-Data/Backups | Backup verification functionality | High |
| scheduled-backup.ps1 | U5-Data/Backups | Scheduled backup functionality | High |

### Configuration Files
| File | Location | Purpose | Recovery Priority |
|------|----------|---------|------------------|
| ucf-u7.3-directory-visual-order-config-20250315.json | U7-Systems/Scripts | Visual directory tool configuration | Medium |
| [Additional configuration files] | [Locations] | [Purposes] | [Priorities] |

## Backup Locations

### Primary Backup
- **Location**: U5-Data/Backups/backups/daily/[YYYYMMDD]
- **Retention**: 7 days
- **Content**: Critical files (memory.md, changelog.md, and system scripts)
- **Verification**: Daily integrity checks using SHA256 hash comparison

### Alternative Backup Sources
- **Windows Backup**: [location]
- **Cloud Backup**: [details if applicable]
- **Git Repository**: [if applicable]

## Recovery Procedures

### 1. Memory File Loss or Corruption
1. **Verify issue**: Confirm memory.md is missing or corrupted
2. **Check recent backups**:
   ```powershell
   # Navigate to backup location
   cd U5-Data/Backups/backups/daily/[YYYYMMDD]
   
   # Verify integrity of backup
   ..\..\verify-backup-integrity.ps1 -BackupDate [YYYYMMDD]
   
   # Copy file to original location
   Copy-Item memory.md ..\..\..\..\memory.md
   ```
3. **Verify recovery**:
   ```powershell
   # Check file content and integrity
   Get-Content ..\..\..\..\memory.md | Select-Object -First 10
   ```

### 2. Backup System Failure
1. **Verify issue**: Check error logs in U5-Data/Backups/logs
2. **Restart backup system**:
   ```powershell
   # Run manual backup
   U5-Data/Backups/scheduled-backup.ps1 -Verbose
   
   # Verify backup integrity
   U5-Data/Backups/verify-backup-integrity.ps1 -VerifyAll
   ```
3. **Fix backup scripts** if necessary and retest

### 3. Visual Directory Organization Tool Failure
1. **Verify issue**: Test tool functionality
   ```powershell
   U7-Systems/Scripts/test-visual-directory-tool.bat
   ```
2. **Restore from backup** if necessary
3. **Update configuration** if needed

### 4. Complete System Recovery
[Step-by-step procedure for full system recovery]

## Recovery Verification Procedures

### Post-Recovery Testing
1. **File integrity verification**:
   ```powershell
   U5-Data/Backups/verify-backup-integrity.ps1 -VerifyAll
   ```
2. **Visual Directory Tool testing**:
   ```powershell
   U7-Systems/Scripts/test-visual-directory-tool.bat
   ```
3. **WordPress integration verification** (when implemented)

### Success Criteria
- All critical files are present and intact
- Backup system is functioning
- Visual Directory Organization Tool works correctly
- File naming compliance is at pre-incident levels or higher

## Escalation Procedures

### When to Escalate
- Backup verification fails for multiple days
- Recovery procedures fail to restore critical files
- Multiple systems fail simultaneously
- Data loss affects WordPress content

### Escalation Path
1. **Level 1**: Systems Team Lead
2. **Level 2**: Data Management Team
3. **Level 3**: Senior Leadership

## Prevention Strategies

### Regular Maintenance Tasks
- Daily backup verification
- Weekly file naming compliance checks
- Monthly recovery drill (simulated recovery)

### Early Warning Signs
- Increasing backup verification time
- Growing differences between source and backup hashes
- Configuration drift between components
- Unexpected script errors or timeouts

## Appendix: Recovery Commands Quick Reference

```powershell
# Backup verification
U5-Data/Backups/verify-backups.bat

# Manual backup
U5-Data/Backups/scheduled-backup.ps1 -Verbose

# Test Visual Directory Organization Tool
U7-Systems/Scripts/test-visual-directory-tool.bat

# File naming check
[Command for file naming check script]
```

---

**Note**: This guide should be updated whenever the system architecture changes or new critical components are added.

_Document ends_ 