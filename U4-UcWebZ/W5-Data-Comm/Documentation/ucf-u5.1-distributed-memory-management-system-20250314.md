# Distributed Memory Management System (DMMS)
**Specification Document v1.0**  
*Created: 03-14-2025*

## 1. Overview

The Distributed Memory Management System (DMMS) is a comprehensive solution designed to prevent critical file loss and ensure data integrity across the cFish.io ecosystem. This system implements a distributed architecture for memory files across all UcF departments, with bi-directional synchronization, automated backup mechanisms, and a structured approach to file references.

### 1.1 Purpose

The primary purpose of DMMS is to address the following challenges:
- Prevent single-point-of-failure data loss for critical documentation
- Ensure consistency of memory files across all departments
- Provide automated backup and recovery mechanisms
- Facilitate improved cross-referencing between documentation files
- Support AI-compatible data formats for enhanced processing

### 1.2 Scope

This specification covers:
- The distributed architecture for memory files
- Synchronization protocols and mechanisms
- File reference and linking systems
- Backup and recovery procedures
- JSON conversion for AI-compatible storage
- Monitoring and validation systems
- Implementation timeline and phases

## 2. System Architecture

### 2.1 Directory Structure

The DMMS implements a hierarchical structure:

```
/
├── U1-Administration/
│   └── memory.md             # Department-specific memory file
├── U2-Research/
│   └── memory.md
├── U3-Operations/
│   └── memory.md
├── U4-Production/
│   └── memory.md
├── U5-Data/
│   ├── memory.md
│   ├── Master/
│   │   ├── master-memory.md  # Aggregated master memory file
│   │   └── memory.json       # JSON representation for AI ingestion
│   ├── Synchronization/
│   │   ├── ucf-u5.2-sync-memory-files-20250314.ps1
│   │   ├── memory-sync-config.json
│   │   └── memory-sync-watcher.ps1
│   └── Backups/
│       ├── backups/
│       │   └── daily/        # Daily backups with 7-day retention
│       └── emergency/        # Emergency recovery copies
├── U6-Marketing/
│   └── memory.md
└── U7-Systems/
    └── memory.md
```

### 2.2 Component Roles

1. **Department Memory Files**: Focused documentation relevant to each department's activities
2. **Master Memory Repository**: Aggregated content from all departments
3. **Synchronization Engine**: Bi-directional sync between department files and master repository
4. **JSON Converter**: Transforms Markdown files into AI-compatible JSON format
5. **File Reference System**: Extracts and maintains cross-references between files
6. **Monitoring System**: Watches for changes and triggers synchronization
7. **Backup Manager**: Maintains multiple backup copies with proper retention

## 3. Synchronization Protocol

### 3.1 Bi-directional Sync Engine

The synchronization engine supports bi-directional updates:
1. **Department → Master**: When department memory files are updated
2. **Master → Departments**: When global changes are made to the master file

```powershell
# Pseudocode for sync process
function Sync-MemoryFiles {
    # Get all department memory files
    $deptFiles = Get-DepartmentMemoryFiles
    
    # Extract entries from each department
    foreach ($file in $deptFiles) {
        $entries = Extract-MemoryEntries -File $file
        Add-ToMasterFile -Entries $entries
    }
    
    # Update departments with cross-references
    $masterEntries = Get-MasterEntries
    foreach ($file in $deptFiles) {
        Update-DepartmentReferences -File $file -MasterEntries $masterEntries
    }
    
    # Generate JSON representation
    Convert-ToJson -InputFile "U5-Data/Master/master-memory.md" -OutputFile "U5-Data/Master/memory.json"
}
```

### 3.2 Conflict Resolution

The system handles conflicts using the following rules:
1. **Timestamp Priority**: More recent changes take precedence
2. **Department Ownership**: Entries originating from a department cannot be modified by other departments
3. **Manual Resolution**: Critical conflicts trigger manual resolution workflow
4. **Version History**: All versions are preserved in the backup system

## 4. File Reference System

### 4.1 Reference Extraction

The system automatically extracts references to:
- File paths
- Directories
- Other memory entries
- External URLs

```powershell
function Extract-References {
    param($Content)
    
    $references = @()
    
    # Extract file paths (supports various formats)
    $filePattern = '(?<![`])\b(?:(?:[A-Za-z]:\\)|(?:\/)|(?:\.\/)|(?:\.\.\/))(?:[\w\-\. \/\\]+)+(?:\.\w+)?\b'
    $fileMatches = [regex]::Matches($Content, $filePattern)
    foreach ($match in $fileMatches) {
        $references += @{
            Type = "File"
            Path = $match.Value
            LineNumber = Get-LineNumber -Content $Content -Position $match.Index
        }
    }
    
    # Extract directory references
    $dirPattern = '\b(?:U\d-[A-Za-z]+|_[A-Za-z]+)\b'
    # Additional patterns for URLs, entry references, etc.
    
    return $references
}
```

### 4.2 Link Generation

The system generates:
1. **Internal Links**: Between memory entries using standard Markdown syntax
2. **File Links**: To actual files in the system using appropriate paths
3. **Cross-department References**: Linking content between departments

### 4.3 Reference Counting

The system tracks reference counts to identify:
- Most referenced files/directories (importance metrics)
- Orphaned content (no references)
- Reference chains and dependencies

## 5. JSON Conversion

### 5.1 Markdown to JSON Structure

The system converts Markdown content to a structured JSON format:

```json
{
  "entries": [
    {
      "id": "unique-entry-id",
      "title": "Entry Title",
      "date": "2025-03-14",
      "department": "U5-Data",
      "content": "Entry content...",
      "references": [
        {
          "type": "file",
          "path": "path/to/file.ext",
          "line": 45
        },
        {
          "type": "entry",
          "id": "another-entry-id"
        }
      ],
      "tags": ["tag1", "tag2"],
      "lastModified": "2025-03-14T14:30:00Z",
      "author": "AI: Cursor (Claude 3.7 Sonnet)"
    }
  ]
}
```

### 5.2 JSON Schema Validation

JSON output is validated against a schema to ensure:
- Required fields are present
- Data types are correct
- References are valid
- Dates follow ISO format

## 6. Backup and Recovery

### 6.1 Automated Backup System

The system implements:
1. **Pre-change Backups**: Before any synchronization
2. **Daily Backups**: With 7-day retention policy
3. **Weekly Backups**: With 4-week retention policy
4. **Monthly Snapshots**: With 12-month retention policy

### 6.2 Emergency Recovery Protocol

In case of file corruption or loss:
1. System automatically detects size/content anomalies
2. Recovery is attempted from the most recent valid backup
3. If automatic recovery fails, manual recovery procedure is initiated
4. Recovery logs record all actions for audit purposes

```powershell
function Emergency-Recovery {
    param($TargetFile)
    
    # Check if file exists but is corrupted (sudden size change)
    if (Test-Path $TargetFile) {
        $fileSize = (Get-Item $TargetFile).Length
        $expectedSize = Get-ExpectedFileSize -File $TargetFile
        
        if ($fileSize -lt ($expectedSize * 0.5)) {
            # File likely corrupted - attempt recovery
            $backupFile = Find-LatestValidBackup -File $TargetFile
            if ($backupFile) {
                Copy-Item -Path $backupFile -Destination $TargetFile
                Write-Log "Emergency recovery completed using backup: $backupFile"
                return $true
            }
        }
    } else {
        # File missing - attempt recovery
        $backupFile = Find-LatestValidBackup -File $TargetFile
        if ($backupFile) {
            Copy-Item -Path $backupFile -Destination $TargetFile
            Write-Log "Emergency recovery completed for missing file using: $backupFile"
            return $true
        }
    }
    
    # If we reached here, automated recovery failed
    Initiate-ManualRecovery -File $TargetFile
    return $false
}
```

## 7. Monitoring System

### 7.1 File Watcher

A file watcher monitors all memory files for changes:
- Uses PowerShell's `FileSystemWatcher` for real-time monitoring
- Debounces rapid changes to prevent excessive synchronization
- Logs all detected changes with timestamps and user information

### 7.2 Validation System

The system validates:
- File integrity (no corruption)
- Compliance with expected format
- Presence of required metadata
- Consistency between cross-references

### 7.3 Alerting

The system generates alerts for:
- Failed synchronization
- File corruption detection
- Critical conflicts requiring manual resolution
- Backup failures

## 8. Implementation Plan

### 8.1 Phase 1: Core Infrastructure (Days 1-2)

1. Create base directory structure
2. Implement basic synchronization engine
3. Set up automated backup system
4. Create initial department memory files

### 8.2 Phase 2: Reference System (Days 3-4)

1. Implement reference extraction
2. Create link generation system
3. Develop reference counting mechanism
4. Test with sample memory files

### 8.3 Phase 3: JSON Conversion & Validation (Day 5)

1. Create JSON converter
2. Implement schema validation
3. Test with edge cases
4. Document JSON structure

### 8.4 Phase 4: Monitoring & Alerting (Day 6)

1. Implement file watcher
2. Create validation system
3. Set up alerting mechanism
4. Test monitoring components

### 8.5 Phase 5: Testing & Deployment (Days 7-8)

1. Comprehensive system testing
2. Documentation finalization
3. Training materials creation
4. Full deployment across all departments

## 9. Success Metrics

The DMMS implementation will be measured by:

1. **Data Loss Prevention**
   - Zero instances of unrecoverable file loss
   - All critical files backed up in at least 3 locations
   - Recovery time under 5 minutes for any critical file

2. **Synchronization Efficiency**
   - All department files synchronized within 60 seconds of changes
   - Zero synchronization conflicts requiring manual intervention
   - 100% consistency between master and department files

3. **Reference Integrity**
   - All file references resolvable to actual files
   - Zero broken internal links
   - Complete reference graph for all system components

4. **User Experience**
   - Transparent operation with no user workflow disruption
   - Intuitive recovery procedures when needed
   - Comprehensive logs for all system activities

## 10. Conclusion

The Distributed Memory Management System provides a robust, fault-tolerant approach to managing critical documentation across the cFish.io ecosystem. By implementing distributed storage, automated synchronization, comprehensive backups, and intelligent reference management, the system ensures data integrity while enhancing usability and AI compatibility.

---

*Document version: 1.0*  
*Created: 03-14-2025*  
*Author: Claude 3.7 Sonnet (Cursor)* 