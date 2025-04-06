# MD-JSON Sync System - Cursor Integration

This document explains how to use the MD-JSON Synchronization System with Cursor IDE integration.

## Overview

The MD-JSON Sync System is designed to maintain perfect synchronization between Markdown (.md) files and their corresponding JSON representations. This Cursor integration ensures that the system:

1. Only runs when Cursor is active
2. Automatically starts and stops with Cursor
3. Avoids modifying files when the Windows environment (outside Cursor) is actively using them

## Installation

1. Ensure you have Node.js installed (version 14.0.0 or higher)
2. Clone or download this repository
3. Install dependencies:
   ```
   npm install
   ```
4. Run the setup script to configure the Cursor integration (requires administrator privileges):
   ```
   powershell -ExecutionPolicy Bypass -File setup-cursor-integration.ps1
   ```

## Manual Usage

If you prefer to start the system manually when using Cursor:

1. **Basic Version**: Run `start-tydisync.bat`
2. **Enhanced Version**: Run `start-enhanced-sync.bat`

The enhanced version includes:
- Memory management with automatic garbage collection
- Improved lock management with stale lock detection
- JSON validation and automatic repair
- Low CPU mode for reduced resource usage

## Troubleshooting

### Common Issues and Solutions

#### 1. "MdJsonSync is not a constructor" Error
If you see the error "MdJsonSync is not a constructor" when running the enhanced sync system:
- This indicates an issue with how the MD-JSON sync module is imported
- **Solution**: The fixed version uses `const MDJSONSync = require('./tydisync.js');` to properly import the module
- If you still encounter this issue, try:
  - Verify that tydisync.js exists in the same directory
  - Check if the tydisync.js file properly exports a constructor
  - Run `node cursor-md-json-enhanced.js` to test after fixes

#### 2. PowerShell Script Execution Issues
If you encounter problems running the setup script:
- **Issue**: Using incorrect extension (e.g., `.ps` instead of `.ps1`)
- **Issue**: Running from the wrong directory (e.g., from System32 instead of project folder)
- **Solution**:
  ```powershell
  # First change to the project directory
  cd C:\Users\Chris\cFish.io
  
  # Then execute with the proper extension
  powershell -ExecutionPolicy Bypass -File setup-cursor-integration.ps1
  ```

#### 3. Missing Dependencies
If you see errors about missing modules (e.g., 'chokidar'):
- **Solution**: Reinstall dependencies using `npm install`
- The enhanced script attempts to automatically reinstall dependencies if they're missing

### Advanced Troubleshooting

If you continue to experience issues:
1. Check if the `.cursor-running` flag file exists when Cursor is running
2. Manually delete the file if it persists after Cursor is closed
3. Check the Task Scheduler for any error messages in the task history
4. Verify Node.js is in your PATH environment variable

## How It Works

The integration uses:

1. **Wrapper Scripts**: `cursor-tydisync.js` and `cursor-md-json-enhanced.js` that explicitly load all dependencies
2. **Flag Files**: `.cursor-running` indicates the system is active
3. **Clean Shutdown**: Proper cleanup when Cursor is closed

## Configuration

You can modify the configuration in the wrapper scripts:

- `watchDirectories`: Specify which directories to monitor
- `excludePatterns`: Directories/files to exclude from monitoring
- `lowCpuMode`: Reduces CPU usage by batching operations
- Memory management, lock management, and backup settings

## License

MIT License 