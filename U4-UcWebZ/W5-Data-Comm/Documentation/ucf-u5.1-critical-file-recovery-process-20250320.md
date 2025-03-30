# Critical File Recovery Process

## Overview

This document outlines comprehensive emergency recovery procedures for critical files within the cFish.io system, specifically memory.md and changelog.md. These files contain vital historical information, and this document provides step-by-step instructions for recovering the files in case of data loss, corruption, or other emergencies.

## Recovery Scenarios

### Scenario 1: File Corruption

**Symptoms:**
- File contains garbled text or non-text characters
- File verification fails with hash mismatch
- File shows unexpected formatting issues

**Recovery Procedure:**

1. **Immediate Actions:**
   - Do not make any further changes to the corrupted file
   - Run the verification script to confirm corruption:
   ```powershell
   .\U5-Data\Scripts\simple-verify.ps1
   ```

2. **Same-Day Backup Recovery:**
   - Recover from the most recent daily backup:
   ```powershell
   # List available backups
   Get-ChildItem -Path "U5-Data\Backups\critical\$(Get-Date -Format 'yyyyMMdd')"
   
   # Copy the most recent backup to restore
   Copy-Item -Path "U5-Data\Backups\critical\$(Get-Date -Format 'yyyyMMdd')\memory.md" -Destination "memory.md" -Force
   ```

3. **Verify Recovery:**
   - Run verification script to confirm restored file integrity:
   ```powershell
   .\U5-Data\Scripts\simple-verify.ps1
   ```

### Scenario 2: File Deletion

**Symptoms:**
- File is missing from expected location
- Error messages indicating file cannot be found

**Recovery Procedure:**

1. **Immediate Actions:**
   - Check for temporary or backup files in the same directory
   - Do not create an empty replacement file

2. **Same-Day Backup Recovery:**
   - Recover from the most recent daily backup:
   ```powershell
   # Find the most recent backup
   $mostRecentBackup = Get-ChildItem -Path "U5-Data\Backups\critical\" -Recurse -Filter "memory.md" | 
       Sort-Object LastWriteTime -Descending | 
       Select-Object -First 1
   
   # Restore the file
   Copy-Item -Path $mostRecentBackup.FullName -Destination "memory.md" -Force
   ```

3. **Verify Recovery:**
   - Run verification script to confirm restored file integrity:
   ```powershell
   .\U5-Data\Scripts\simple-verify.ps1
   ```

### Scenario 3: Content Loss

**Symptoms:**
- File exists but is missing expected entries
- File is truncated or incomplete
- Recent updates are missing

**Recovery Procedure:**

1. **Immediate Actions:**
   - Make a backup of the current partial file:
   ```powershell
   Copy-Item -Path "memory.md" -Destination "memory.md.partial" -Force
   ```

2. **Recent Content Recovery:**
   - Recover from the most recent daily backup:
   ```powershell
   Copy-Item -Path "U5-Data\Backups\critical\$(Get-Date -Format 'yyyyMMdd')\memory.md" -Destination "memory.md" -Force
   ```

3. **Content Comparison and Merging:**
   - If the partial file contained unique content not in the backup:
   ```powershell
   # Compare files to identify differences
   Compare-Object -ReferenceObject (Get-Content -Path "memory.md") -DifferenceObject (Get-Content -Path "memory.md.partial")
   
   # Manual merge may be required to preserve unique content
   ```

4. **Verify Recovery:**
   - Run verification script to confirm restored file integrity:
   ```powershell
   .\U5-Data\Scripts\simple-verify.ps1
   ```

## Advanced Recovery Procedures

### Historical Backup Recovery

If recent backups are unavailable or insufficient:

1. **Access Historical Backups:**
   ```powershell
   # List available historical backups (past 30 days)
   Get-ChildItem -Path "U5-Data\Backups\critical\" -Recurse -Filter "memory.md" | 
       Sort-Object LastWriteTime -Descending
   ```

2. **Restore Historical Backup:**
   ```powershell
   # Specify a date in the past for recovery
   $backupDate = "20250315"  # Format: YYYYMMDD
   
   # Find backups from that date
   $historicalBackups = Get-ChildItem -Path "U5-Data\Backups\critical\$backupDate" -Filter "memory.md"
   
   # Restore the file
   Copy-Item -Path $historicalBackups[0].FullName -Destination "memory.md" -Force
   ```

### DMMS Recovery (Once Implemented)

If the Distributed Memory Management System is active:

1. **Check Department Files:**
   ```powershell
   # List all department memory files
   Get-ChildItem -Path "U*\memory.md"
   ```

2. **Rebuild Master from Department Files:**
   ```powershell
   # Run the DMMS synchronization script in rebuild mode
   .\U5-Data\Scripts\sync-memory-files.ps1 -RebuildMaster
   ```

### Workbench Files Recovery

If workbench WB-memory.md files contain relevant information:

1. **Collect Workbench Files:**
   ```powershell
   # Create a collection directory
   New-Item -ItemType Directory -Path "U5-Data\Recovery\Workbench" -Force
   
   # Copy all workbench memory files
   Get-ChildItem -Path "*\WB-memory.md" -Recurse | 
       ForEach-Object { Copy-Item -Path $_.FullName -Destination "U5-Data\Recovery\Workbench\$($_.Directory.Name)-memory.md" }
   ```

2. **Extract Relevant Content:**
   - Manually review workbench files for content to be restored to the master memory.md

## Recovery Verification

After any recovery procedure:

1. **Integrity Verification:**
   ```powershell
   .\U5-Data\Scripts\simple-verify.ps1
   ```

2. **Content Verification:**
   - Check for expected section headings
   - Verify chronological order of entries in memory.md
   - Verify version sequence in changelog.md
   - Confirm signature lines are intact

3. **Update Fingerprints:**
   ```powershell
   .\U5-Data\Scripts\verify-critical-files.ps1 -UpdateFingerprints
   ```

## Post-Recovery Actions

After successful recovery:

1. **Create Fresh Backup:**
   ```powershell
   .\U5-Data\Scripts\simple-backup.ps1
   ```

2. **Document Recovery Incident:**
   - Add entry to memory.md documenting the recovery
   - Document in the workbench memory file
   - Note incident in operational logs

3. **Implement Additional Protection:**
   - Review protection mechanism effectiveness
   - Consider additional safeguards if needed
   - Schedule verification tasks more frequently
   ```powershell
   .\U5-Data\Scripts\schedule-verification.ps1 -Frequency Daily
   ```

## Prevention Measures

To prevent the need for recovery:

1. **Regular Verification:**
   - Run verification at least daily
   - Verify fingerprints after any file changes

2. **Multiple Backup Locations:**
   - Maintain backups in multiple locations
   - Consider cloud backup for critical files

3. **Proper Update Procedures:**
   - Always follow the Critical File Update Process
   - Never bypass verification steps

## Conclusion

This recovery process document provides comprehensive procedures for restoring critical files in various emergency scenarios. Following these procedures will ensure minimal data loss and rapid recovery of vital historical information.

_Created 03-20-2025 | AI: Cursor (Claude 3.7 Sonnet)_ 