# Distributed Memory Management System (DMMS) - Comprehensive Documentation

**Version:** 2.0.0  
**Author:** tY FischEYe via Cursor/Claude  
**Date:** 2025-03-26  
**Department:** U5-Data  

## Table of Contents

1. [Overview](#overview)
2. [System Architecture](#system-architecture)
3. [Phase 1: Basic Synchronization](#phase-1-basic-synchronization)
4. [Phase 2: Advanced Features](#phase-2-advanced-features)
   - [Bi-directional Synchronization](#bi-directional-synchronization)
   - [File Locking System](#file-locking-system)
   - [Integrity Management](#integrity-management)
   - [Version History](#version-history)
   - [Collaboration Tools](#collaboration-tools)
5. [Installation and Setup](#installation-and-setup)
6. [Usage Guide](#usage-guide)
7. [Troubleshooting](#troubleshooting)
8. [Future Development (Phase 3)](#future-development-phase-3)
9. [Appendix](#appendix)

## Overview

The Distributed Memory Management System (DMMS) is a comprehensive solution for managing organizational memory across departments. It addresses the critical need for consistent information sharing while maintaining data integrity and preventing conflicts.

Key features include:
- Distributed memory files across all UcF departments
- Bi-directional synchronization with conflict resolution
- File locking to prevent concurrent edits
- Integrity scanning and repair
- Version history tracking
- Collaborative editing through branches and pull requests
- JSON conversion for AI ingestion

The DMMS follows a phased implementation approach:
- **Phase 1**: Basic Synchronization (Completed 2025-03-20)
- **Phase 2**: Advanced Features (Completed 2025-03-26)
- **Phase 3**: Extended Ecosystem (Planned for 2025-04-01 to 2025-04-30)

## System Architecture

The DMMS follows a modular architecture organized into layers:

```
┌─────────────────────────────────────────────────────────────┐
│                      DMMS Architecture                       │
└─────────────────────────────────────────────────────────────┘
                              │
              ┌───────────────┼───────────────┐
              │               │               │
┌─────────────▼─────────────┐ │ ┌─────────────▼─────────────┐
│    Synchronization Layer   │ │ │     Integrity Layer       │
│                           │ │ │                           │
│ - Bi-directional Sync     │ │ │ - File Locking            │
│ - Conflict Resolution     │ │ │ - Integrity Scanning      │
│ - Timestamp Tracking      │ │ │ - Automated Repairs       │
└───────────────────────────┘ │ └───────────────────────────┘
                              │
              ┌───────────────▼───────────────┐
              │                               │
┌─────────────▼─────────────┐ ┌───────────────▼─────────────┐
│   Collaboration Layer      │ │      Analytics Layer        │
│                           │ │                             │
│ - Version History         │ │ - Memory Analysis           │
│ - Branch & Merge          │ │ - Insights Generation       │
│ - Pull Requests           │ │ - Visualization             │
└───────────────────────────┘ └─────────────────────────────┘
```

### Directory Structure

The DMMS uses the following directory structure:

```
U5-Data/
├── Scripts/
│   ├── create-department-memory-files.ps1
│   ├── create-department-memory-files.bat
│   ├── sync-memory-files.ps1
│   ├── sync-memory-files.bat
│   ├── convert-md-to-json.ps1
│   ├── convert-md-to-json.bat
│   ├── sync-config.json
│   ├── setup-dmms.bat
│   ├── sync-bidirectional.ps1
│   ├── sync-bidirectional.bat
│   ├── file-locking.ps1
│   ├── manage-locks.bat
│   ├── scan-integrity.ps1
│   ├── schedule-integrity-scan.bat
│   ├── repair-integrity.ps1
│   ├── repair-dmms-integrity.bat
│   ├── version-history.ps1
│   ├── manage-versions.bat
│   ├── memory-branches.ps1
│   └── collaborate-memory.bat
├── Data/
│   ├── VersionHistory/
│   │   └── version-history.json
│   └── Branches/
│       ├── branches.json
│       └── pull-requests.json
├── Logs/
│   ├── sync.log
│   ├── integrity.log
│   ├── version-history.log
│   └── memory-branches.log
├── JSON/
│   └── memory.json
└── Documentation/
    └── ucf-u5.1-dmms-comprehensive-documentation-20250326.md
```

### Component Dependencies

```
                   ┌───────────────────┐
                   │    setup-dmms     │
                   └─────────┬─────────┘
                             │
           ┌─────────────────┼─────────────────┐
           │                 │                 │
┌──────────▼─────────┐ ┌─────▼──────┐ ┌────────▼─────────┐
│ create-department- │ │ sync-memory│ │   convert-md-    │
│   memory-files     │ │    files   │ │     to-json      │
└──────────┬─────────┘ └─────┬──────┘ └────────┬─────────┘
           │                 │                 │
┌──────────▼─────────┐ ┌─────▼──────┐ ┌────────▼─────────┐
│  department files  │ │ sync-config│ │    memory.json   │
└────────────────────┘ └────────────┘ └──────────────────┘

                   ┌───────────────────┐
                   │sync-bidirectional │
                   └─────────┬─────────┘
                             │
           ┌─────────────────┼─────────────────┐
           │                 │                 │
┌──────────▼─────────┐ ┌─────▼──────┐ ┌────────▼─────────┐
│   file-locking     │ │  version-  │ │  memory-branches │
│                    │ │  history   │ │                  │
└──────────┬─────────┘ └─────┬──────┘ └────────┬─────────┘
           │                 │                 │
┌──────────▼─────────┐ ┌─────▼──────┐ ┌────────▼─────────┐
│   manage-locks     │ │  manage-   │ │  collaborate-    │
│                    │ │  versions  │ │     memory       │
└────────────────────┘ └────────────┘ └──────────────────┘
```

## Phase 1: Basic Synchronization

Phase 1 of the DMMS implements the foundational components of the system, focusing on one-way synchronization from a master memory file to department-specific files.

### Key Components

#### Department Memory Files
- Creation of department-specific memory.md files in all 7 UcF departments:
  - U1-Administration/memory.md (45 entries)
  - U2-Research/memory.md (12 entries)
  - U3-Operations/memory.md (39 entries)
  - U4-Production/memory.md (24 entries)
  - U5-Data/memory.md (29 entries)
  - U6-Marketing/memory.md (2 entries)
  - U7-Systems/memory.md (28 entries)

#### One-way Synchronization
- `sync-memory-files.ps1/bat`: Synchronizes content from master memory.md to department files
- Uses department-specific keywords to determine content relevance
- Maintains unique entries in each department file

#### JSON Conversion
- `convert-md-to-json.ps1/bat`: Converts Markdown memory files to JSON format
- Enhances AI accessibility and programmatic interaction
- Maintains consistent structure for all memory content

#### Configuration
- `sync-config.json`: Central configuration for department keywords
- Supports department-specific settings and customization
- Enables fine-tuning of content distribution

### Usage

**Creating Department Memory Files**
```
create-department-memory-files.bat
```

**Synchronizing Memory Files**
```
sync-memory-files.bat
```

**Converting to JSON**
```
convert-md-to-json.bat
```

**Setup (All Operations)**
```
setup-dmms.bat
```

## Phase 2: Advanced Features

Phase 2 builds on the foundation of Phase 1, adding sophisticated features for enhanced management, integrity, and collaboration.

### Bi-directional Synchronization

The bi-directional synchronization system allows changes to flow in both directions between master and department memory files.

#### Features
- Multi-directional synchronization with timestamp tracking
- Conflict detection based on modification time
- Multiple conflict resolution strategies (newest wins, manual review)
- Comprehensive logging of all sync operations

#### Implementation
- `sync-bidirectional.ps1`: Core synchronization engine
- `sync-bidirectional.bat`: User-friendly wrapper

#### Usage
```
sync-bidirectional.bat
```

### File Locking System

The file locking system prevents concurrent edits to memory files, ensuring data integrity during modifications.

#### Features
- Lock/unlock functionality for memory files
- Stale lock detection and automatic resolution
- Process and user tracking for accountability
- Administrator override for stuck locks

#### Implementation
- `file-locking.ps1`: Core locking functionality
- `manage-locks.bat`: User interface for lock management

#### Usage
```
manage-locks.bat
```

### Integrity Management

The integrity management system ensures memory files maintain their proper structure and content integrity.

#### Features
- Validation of memory file structure and format
- Detection of inconsistencies, corruption, and format violations
- Scheduled scanning capabilities with configurable frequency
- Automated repair of common integrity issues

#### Implementation
- `scan-integrity.ps1`: Integrity scanning engine
- `schedule-integrity-scan.bat`: Scheduled scanning interface
- `repair-integrity.ps1`: Automated repair functionality
- `repair-dmms-integrity.bat`: User interface for repairs

#### Usage
```
schedule-integrity-scan.bat
repair-dmms-integrity.bat
```

### Version History

The version history system tracks changes to memory entries over time, allowing retrieval of previous versions.

#### Features
- Tracking changes to individual memory entries
- Storage of all historical versions
- Diff generation between versions
- Ability to view and restore previous versions

#### Implementation
- `version-history.ps1`: Core version history functionality
- `manage-versions.bat`: User interface for version management

#### Usage
```
manage-versions.bat
```

#### Version Storage

Versions are stored in the following structure:
```
U5-Data/Data/VersionHistory/
├── [EntryID-1]/
│   ├── v1.md
│   ├── v2.md
│   ├── v2_diff.json
│   ├── v3.md
│   └── v3_diff.json
├── [EntryID-2]/
│   └── ...
└── version-history.json
```

### Collaboration Tools

The collaboration tools enable multiple users to work on memory files simultaneously through branches and pull requests.

#### Features
- Branch creation for independent editing
- Pull request system for proposing changes
- Commenting and review functionality
- Conflict resolution during merges
- Complete history tracking of all operations

#### Implementation
- `memory-branches.ps1`: Core branch management functionality
- `collaborate-memory.bat`: User interface for collaboration

#### Usage
```
collaborate-memory.bat
```

#### Collaboration Storage

Collaboration data is stored in the following structure:
```
U5-Data/Data/Branches/
├── [BranchName-1]/
│   └── [memory-file.md]
├── [BranchName-2]/
│   └── [memory-file.md]
├── _backups/
│   └── [backup-files.bak]
├── branches.json
└── pull-requests.json
```

## Installation and Setup

### Prerequisites
- PowerShell 5.1 or higher
- Windows environment (for batch files)
- Write access to all department directories

### Initial Setup

1. **Run the complete setup script:**
   ```
   U5-Data/Scripts/setup-dmms.bat
   ```

2. **Verify installation:**
   - Check that all department memory files have been created
   - Verify that JSON files have been generated
   - Ensure log files are being created properly

### Configuration

The primary configuration file is `sync-config.json`, which contains department-specific settings:

```json
{
  "departments": [
    {
      "name": "U1-Administration",
      "file": "U1-Administration/memory.md",
      "keywords": [
        "Administration", "Policy", "Governance", "Management", 
        "Compliance", "Regulations", "HR", "Finance"
      ]
    },
    {
      "name": "U2-Research",
      "file": "U2-Research/memory.md",
      "keywords": [
        "Research", "Study", "Investigation", "Analysis", 
        "Testing", "Experiment", "Findings", "Hypothesis"
      ]
    },
    ...
  ]
}
```

## Usage Guide

### Day-to-Day Operations

#### Syncing Department Changes

To propagate changes between departments:

```
U5-Data/Scripts/sync-bidirectional.bat
```

#### Managing File Locks

Before editing a memory file:

```
U5-Data/Scripts/manage-locks.bat
```
1. Select "Lock a memory file"
2. Enter the file path
3. Edit the file
4. Select "Unlock a memory file" when done

#### Checking Integrity

To verify memory file integrity:

```
U5-Data/Scripts/schedule-integrity-scan.bat
```
1. Select "Run one-time scan"
2. Review scan results
3. If issues are found, run repair tool:
   ```
   U5-Data/Scripts/repair-dmms-integrity.bat
   ```

#### Managing Versions

To track or view versions:

```
U5-Data/Scripts/manage-versions.bat
```
- For tracking a new version: Select option 1
- For viewing history: Select option 2
- For retrieving an old version: Select option 3
- For restoring a previous version: Select option 4

#### Collaborative Editing

For collaborative work:

```
U5-Data/Scripts/collaborate-memory.bat
```

**Workflow:**
1. Create a branch (option 1)
2. Edit the branch file
3. Create a pull request (option 7)
4. Add reviewers (option 11)
5. Add comments (option 10)
6. Merge when ready (option 12)

## Troubleshooting

### Common Issues

#### Synchronization Failures

**Symptoms:** Error messages during sync, files not updating

**Solutions:**
- Check file permissions
- Ensure no files are locked or in use
- Verify network access to all department directories
- Check sync logs in `U5-Data/Logs/sync.log`

#### Integrity Issues

**Symptoms:** Integrity scan reports errors, malformed entries

**Solutions:**
- Run repair tool: `repair-dmms-integrity.bat`
- Check format of manually added entries
- Verify signature lines are present and correctly formatted
- Ensure dates use the MM-DD-YYYY format

#### Locking Problems

**Symptoms:** Unable to obtain locks, stale locks

**Solutions:**
- Use the "Force unlock" option for stale locks
- Check if the user/process that created the lock is still active
- Verify lock file permissions
- Restart the management script

### Log File Locations

- Synchronization: `U5-Data/Logs/sync.log`
- Integrity: `U5-Data/Logs/integrity.log`
- Version History: `U5-Data/Logs/version-history.log`
- Branch Management: `U5-Data/Logs/memory-branches.log`

## Future Development (Phase 3)

Phase 3 will extend the DMMS ecosystem with the following planned components:

### Integration with External Systems
- APIs for third-party access
- OAuth authentication
- Webhook capabilities
- Event-driven architecture

### Advanced Analytics
- Machine learning for memory analysis
- Predictive insights from historical patterns
- Dashboard for visualizing memory health
- Recommendation engine for related memories

### Mobile and Cross-platform
- Mobile applications for iOS and Android
- Browser extensions
- Desktop notification system
- Offline capabilities with sync

### Enterprise Features
- Role-based access control
- Compliance reporting
- Advanced audit trails
- Disaster recovery procedures

## Appendix

### Script Reference

| Script | Description | Parameters |
|--------|-------------|------------|
| `create-department-memory-files.ps1` | Creates department memory files | -Force: Overwrites existing files |
| `sync-memory-files.ps1` | One-way sync from master to departments | -Verbose: Detailed output |
| `convert-md-to-json.ps1` | Converts MD to JSON | -OutputFile: Custom output path |
| `sync-bidirectional.ps1` | Two-way sync between files | -Department: Limit to specific department |
| `file-locking.ps1` | File locking functionality | -File: Target file, -Operation: Lock/Unlock |
| `scan-integrity.ps1` | Scans for integrity issues | -Target: Target directory or file |
| `repair-integrity.ps1` | Repairs integrity issues | -Target: Target file, -Fix: Types of fixes |
| `version-history.ps1` | Version tracking | -EntryText: Content to track |
| `memory-branches.ps1` | Branch management | -BranchName, -SourceFile |

### Entry Format Rules

Each memory entry must follow this format:

```markdown
## Title of Entry (MM-DD-YYYY)
- Bullet point 1
- Bullet point 2
- Additional bullet points as needed

_Updated MM-DD-YYYY | AI: Cursor (Claude 3.7 Sonnet)_
```

or for human authors:

```markdown
## Title of Entry (MM-DD-YYYY)
- Bullet point 1
- Bullet point 2
- Additional bullet points as needed

_Updated MM-DD-YYYY | Human: tY FischEYe_
```

### Configuration Schema

```json
{
  "departments": [
    {
      "name": "string",
      "file": "string",
      "keywords": ["string", "string", ...]
    }
  ],
  "paths": {
    "masterMemory": "string",
    "jsonOutput": "string",
    "logs": "string"
  },
  "settings": {
    "syncFrequency": "number",
    "conflictResolution": "string",
    "backupEnabled": "boolean"
  }
}
```

_Updated 03-26-2025 | AI: Cursor (Claude 3.7 Sonnet)_ 