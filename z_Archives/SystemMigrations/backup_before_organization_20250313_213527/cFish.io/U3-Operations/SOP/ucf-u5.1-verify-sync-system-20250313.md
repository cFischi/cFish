# Standard Operating Procedure: Verifying tYDiSync System

**Document ID:** ucf-u5.1-verify-sync-system-20250313  
**Version:** 1.0  
**Created:** 03-13-2025  
**Last Updated:** 03-13-2025  
**Department:** U3-Operations  
**Category:** Synchronization  

## Purpose

This Standard Operating Procedure (SOP) outlines the process for verifying the proper functioning of the tYDiSync system, which is responsible for synchronizing markdown and JSON files in the cFish.io Digital Organization System.

## Scope

This procedure applies to the tYDiSync synchronization system located at `cFish.io\U5-Data\Synchronization\tydisync`. It covers verification of installation, process status, log analysis, and synchronization functionality.

## Responsibilities

- **System Administrator:** Responsible for implementing and maintaining the tYDiSync system
- **Operations Team:** Responsible for regular verification and troubleshooting
- **All Users:** Responsible for reporting any observed synchronization issues

## Prerequisites

- Access to the cFish.io system
- Familiarity with PowerShell scripting
- Understanding of the tYDiSync system architecture
- Basic knowledge of markdown and JSON file formats

## Procedure

### 1. Automated Verification

The system includes an automated verification script (`ucf-u5.1-verify-sync-system-20250313.ps1`) that runs daily at 3:00 AM to check the status of the tYDiSync system.

#### 1.1 Automated Checks Performed

The automated verification performs the following checks:

1. **Installation Check:** Verifies that all required tYDiSync components are installed
2. **Process Check:** Confirms that the tYDiSync process is running
3. **Log Analysis:** Examines sync logs for errors or warnings
4. **Functionality Test:** Creates test files to verify synchronization is working

#### 1.2 Automated Reporting

The verification script automatically:

1. Writes detailed logs to `cFish.io\U3-Operations\Monitoring\logs\sync-verification.log`
2. Adds a summary entry to `cFish.io\Documentation\memory.md`
3. Attempts to restart the tYDiSync system if it's not running

### 2. Manual Verification Procedure

In addition to automated verification, manual checks should be performed weekly to ensure system health.

#### 2.1 Check Installation

1. Verify that the tYDiSync directory exists at `cFish.io\U5-Data\Synchronization\tydisync`
2. Confirm the presence of key components:
   - `start-optimized-sync.bat` - System startup script
   - `start-optimized-sync.js` - Main synchronization script
   - `config/` - Configuration directory
   - `md/` - Markdown files directory
   - `json/` - JSON files directory

#### 2.2 Verify Process Status

1. Open Task Manager or use PowerShell to check for running Node.js processes
2. Look for processes with command line containing "start-optimized-sync.js"
3. If no process is found, restart the system using the procedure in section 4.1

#### 2.3 Analyze Log Files

1. Open the tYDiSync log file at `cFish.io\U5-Data\Synchronization\tydisync\tydisync-debug.log`
2. Review recent entries for errors or warnings
3. Check for patterns of recurring issues
4. Verify that synchronization events are being logged regularly

#### 2.4 Test Synchronization Functionality

1. Create a test markdown file in the `md/` directory with the following content:
   ```markdown
   # Manual Verification Test
   
   This is a test file created on [current date] to verify tYDiSync functionality.
   
   ## Test Details
   - Created by: [your name]
   - Purpose: Manual verification
   - Test ID: [random identifier]
   ```

2. Wait for 1-2 minutes to allow synchronization to occur
3. Check the `json/` directory for a corresponding JSON file with the same base name
4. Verify that the JSON file contains the content from the markdown file
5. Make a change to the markdown file and verify that the change is reflected in the JSON file

### 3. Verification Checklist

Use the following checklist for manual verification:

- [ ] tYDiSync directory exists and contains all required components
- [ ] tYDiSync process is running
- [ ] Log files show regular synchronization activity
- [ ] No critical errors in log files
- [ ] Test markdown file successfully synchronizes to JSON
- [ ] Changes to markdown files are reflected in JSON files
- [ ] Changes to JSON files are reflected in markdown files (if bidirectional sync is enabled)

### 4. Troubleshooting Procedures

#### 4.1 Restarting tYDiSync System

If the tYDiSync process is not running:

1. Open PowerShell
2. Navigate to the tYDiSync directory:
   ```powershell
   cd "C:\Users\Chris\cFish.io\cFish.io\U5-Data\Synchronization\tydisync"
   ```
3. Run the start script:
   ```powershell
   .\start-optimized-sync.bat
   ```
4. Verify that the process has started
5. Check logs for startup messages

#### 4.2 Common Issues and Solutions

| Issue | Possible Causes | Solutions |
|-------|----------------|-----------|
| Process not running | System crash, script error | Restart using start-optimized-sync.bat |
| Files not synchronizing | Configuration issue, file permissions | Check config files, verify permissions |
| Sync errors in logs | Invalid file format, path issues | Fix file format, check paths in config |
| High CPU usage | Too many files, infinite loop | Optimize config, check for circular references |
| Missing directories | Incomplete installation | Recreate directories, reinstall if necessary |

### 5. Reporting and Documentation

#### 5.1 Verification Report

After manual verification, create a brief report that includes:

1. Date and time of verification
2. Status of each checklist item
3. Any issues identified and their resolution
4. Recommendations for system improvements

#### 5.2 Update memory.md

For significant issues or changes, add an entry to `cFish.io\Documentation\memory.md` with:

1. Description of the issue
2. Steps taken to resolve it
3. Preventive measures implemented
4. Follow the standard memory.md update format

## tYDiSync System Overview

### System Architecture

The tYDiSync system consists of the following components:

- **Core Engine:** Node.js-based synchronization engine
- **Configuration:** JSON configuration files defining sync behavior
- **Watchers:** File system watchers that detect changes
- **Transformers:** Convert between markdown and JSON formats
- **Logging:** Detailed logging of all synchronization activities

### Key Configuration Files

- **paths.json:** Defines directories to monitor
- **sync-config.json:** Configures synchronization behavior
- **transformers.json:** Defines transformation rules

### Synchronization Modes

- **One-way (md → json):** Changes to markdown files are reflected in JSON
- **One-way (json → md):** Changes to JSON files are reflected in markdown
- **Bidirectional:** Changes in either format are synchronized to the other

## References

- cFish.io Digital Organization System Guide
- tYDiSync System Documentation
- Node.js Documentation

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 03-13-2025 | AI: Cursor (Claude 3.7 Sonnet) | Initial document creation |

_Updated 03-13-2025 | AI: Cursor (Claude 3.7 Sonnet)_ 