# MD-JSON Synchronization System

## Overview

The MD-JSON Synchronization System is a robust solution designed to maintain perfect synchronization between Markdown (.md) files and their corresponding JSON representations across all Cursor projects. This system operates exclusively within the Cursor IDE environment, ensuring data integrity and optimal AI integration.

## Purpose

This system addresses several critical needs:

1. **Perfect Markdown-JSON Synchronization** - Maintains exact content mirroring between Markdown documents and their JSON counterparts.
2. **Cursor-Specific Operation** - Only operates when Cursor is running and only monitors file changes made within Cursor.
3. **Content Safety** - Implements automatic backups and validation to prevent data loss.
4. **AI Optimization** - Structures JSON files for efficient AI consumption and reduced token usage.

## Features

- **Cursor-Aware Processing**: Only activates when Cursor is open
- **Two-Way Synchronization**: Changes in either format are reflected in the other
- **Intelligent Content Transformation**: Preserves document structure and formatting
- **Versioned Backups**: Automatic backups before modifications
- **Content Validation**: Ensures synchronization accuracy
- **Windows Integration**: Seamless startup with Windows

## Implementation Plan

### Phase 1: Core Architecture (1-2 hours)

1. **Process Detection and Management**
   - Create `cursor-sync-controller.js` that:
     - Checks for running Cursor process before activating
     - Registers to Windows startup but only activates when Cursor is running
     - Monitors Cursor process and gracefully terminates when Cursor exits

2. **File Watching Logic**
   - Implement a cursor-specific file watcher that:
     - Only monitors files modified by Cursor (using process ID filtering)
     - Implements robust debouncing (500ms) to prevent rapid update cycles
     - Uses file locks to prevent concurrent modifications

### Phase 2: Synchronization Engine (2-3 hours)

1. **Content Transformation**
   - Build intelligent MD⟷JSON converter that:
     - Preserves document structure exactly
     - Handles special cases like tables, code blocks, and metadata
     - Properly escapes special characters in both directions

2. **Conflict Resolution**
   - Implement timestamp-based conflict resolution that:
     - Compares modification times at the section level, not just file level
     - Intelligently merges changes when possible
     - Prioritizes content preservation over formatting

### Phase 3: Safety and Stability Features (1-2 hours)

1. **Backup System**
   - Create versioned backup mechanism that:
     - Takes incremental backups before any modification
     - Maintains a configurable history (default: 5 versions)
     - Provides automatic restoration in case of corruption

2. **Validation**
   - Build content verification system that:
     - Validates structure and content after every transformation
     - Rejects changes that would result in data loss
     - Records validation issues in a detailed log file

### Phase 4: System Integration (1-2 hours)

1. **Cursor Integration**
   - Create Cursor-specific hooks that:
     - Detect when Cursor is opening or closing files
     - Integrate with Cursor's event system if possible
     - Ensure sync activities don't interfere with Cursor operations

2. **Windows Service**
   - Build lightweight launcher that:
     - Uses Task Scheduler for reliable startup
     - Checks for Cursor process before activating sync
     - Handles multiple instances of Cursor appropriately

### Phase 5: Testing and Deployment (2-3 hours)

1. **Test Suite**
   - Create comprehensive tests that:
     - Verify behavior with various file types and content
     - Simulate intermittent Cursor usage (open/close cycles)
     - Test recovery from various error conditions

2. **Deployment**
   - Prepare deployment package that:
     - Includes all necessary dependencies
     - Provides easy installation/uninstallation
     - Configures Windows startup integration

## Installation

1. Clone this repository to your local machine.
2. Run `npm install` to install dependencies:
   ```
   npm install chokidar fs-extra node-watch path moment
   ```
3. Configure the system using the `config.js` file.
4. Run `npm run setup` to set up the Windows startup integration.

## Usage

Once installed, the system operates automatically:

1. The synchronization process starts when Cursor is launched.
2. All Markdown files in specified directories are synchronized with their JSON counterparts.
3. Changes to either format are automatically reflected in the other.
4. The process stops when Cursor is closed.

## Configuration

Edit the `config.js` file to customize settings:

```javascript
module.exports = {
  watchDirs: [
    { md: './docs', json: './docs/json' },
    { md: './shortlinks', json: './shortlinks/json' }
  ],
  backupSettings: {
    enabled: true,
    maxVersions: 5,
    backupDir: './backups'
  },
  debounceTime: 500, // milliseconds
  exclusions: ['node_modules', '.git']
};
```

## File Exclusion Mechanism

The system provides a way to exclude specific files from synchronization using a simple marker file:

### Using `.nosync` Files

To exclude a file from synchronization:

1. Create an empty file with the same name as the file you want to exclude, but with `.nosync` extension.
   Example: To exclude `memory.md`, create `memory.md.nosync`

2. The file's content is not important, but you can add a description like:
   ```
   This file tells the sync system to ignore memory.md
   ```

3. The synchronization system will check for the presence of this marker file before processing any MD or JSON file.

### When to Use Exclusions

- **Critical Manual Content**: Files that should never be auto-synchronized
- **Temporary Work Areas**: Files that contain work-in-progress content
- **Large Reference Files**: Files that would create unnecessarily large JSON representations

### Managing Exclusions

- `.nosync` files are automatically tracked by git to ensure exclusion settings are shared across the team
- Modifying `.nosync` files will trigger warnings in the pre-commit hook
- The system logs when it skips files due to exclusion markers

## Troubleshooting

Common issues and their solutions:

- **Sync Not Starting**: Ensure Cursor is running and the script is properly installed in Windows startup.
- **Synchronization Loops**: Check exclusions to ensure JSON directories aren't being recursively processed.
- **File Locking Issues**: Verify no other processes are modifying the same files.

## Known Issues and Limitations

### Root Directory Monitoring Limitation

The current implementation only watches specific directories (docs, shortlinks) and the root JSON directory. Markdown files in the root directory are not automatically monitored, which means:

- Root-level Markdown files will not be converted to JSON automatically
- Changes to root-level Markdown files will not be synchronized
- JSON changes will not be propagated back to root-level Markdown files

**Workarounds:**

1. **Move files to monitored directories**: Place your Markdown files in the docs/ or shortlinks/ directories
2. **Use manual sync**: For one-time synchronization, use `node tydisync.js --sync "your-file.md" --force`
3. **See complete solutions**: Refer to `docs/root-directory-monitoring-workarounds.md` for implementation plans

This limitation will be addressed in the next update. For detailed information about solutions, see the workarounds document.

### Content Preservation Issues

There is a critical issue with the merging algorithm that can cause content loss during synchronization:

- The system may overwrite content in Markdown files during JSON-to-MD sync operations
- Even when logs show "merged" designations, content can still be lost
- This issue particularly affects files with complex structures like memory.md

**Prevention Measures:**

1. **Use the Exclusion Mechanism**:
   - Create a `.nosync` file for critical documents (e.g., `memory.md.nosync`)
   - This prevents automatic synchronization of the file

2. **Keep Frequent Backups**:
   - The system creates backups before modifications in the `backups` directory
   - Additional manual backups for critical files are recommended

3. **Monitor Sync Logs**:
   - Watch for `JSON → MD (merged)` operations in logs
   - Verify content integrity after such operations

This issue is the highest priority for the next system update.

## License

MIT

---

_This project was created specifically for cFish.io and related Cursor projects._

_Updated 03-13-2025 | AI: Cursor (Claude 3.7 Sonnet)_ 

_Updated 03-13-2025 | AI: Cursor (Claude 3.7 Sonnet)_

_Updated 03-13-2025 | AI: Cursor (Claude 3.7 Sonnet)_