# Enhanced MD-JSON Synchronization System

A robust system for bidirectional synchronization between Markdown and JSON files with advanced memory management, lock management, and JSON validation capabilities.

## Features

### Memory Management
- Continuous memory usage monitoring
- Proactive garbage collection
- Graceful shutdown when approaching memory limits
- Memory usage statistics and reporting
- Adaptive restart with reduced memory settings

### Lock Management
- Timeout-based lock expiration
- Automatic stale lock detection and cleanup
- Process-aware lock verification
- Detailed lock status reporting
- Race condition prevention

### JSON Validation and Recovery
- Robust JSON validation with detailed error reporting
- Automatic repair of common JSON issues
- Backup creation before repair attempts
- Intelligent recovery of valid JSON subsets
- Comprehensive error logging

## Components

### memory-manager.js
The memory management utility monitors memory usage and prevents out-of-memory crashes by:
- Tracking heap usage and comparing against configurable thresholds
- Running garbage collection proactively
- Providing detailed memory statistics
- Initiating graceful shutdown when approaching critical limits

### lock-manager.js
The lock management utility handles file locks to prevent race conditions by:
- Creating and managing lock files with process information
- Verifying that lock-owning processes are still running
- Automatically cleaning up stale locks
- Providing detailed lock statistics

### json-validator.js
The JSON validation utility ensures data integrity by:
- Validating JSON syntax with detailed error reporting
- Automatically fixing common JSON issues
- Creating backups before attempting repairs
- Recovering valid subsets from corrupted JSON

### tydisync-enhanced.js
The integration script demonstrates how these components work together:
- Integrates memory management, lock management, and JSON validation
- Implements graceful termination handling
- Provides comprehensive logging
- Ensures reliable synchronization even under resource constraints

## Usage

### Running the Enhanced System
Use the provided batch file to run the system with proper memory settings:

```
run-enhanced.bat
```

This will:
1. Check for required dependencies
2. Set appropriate memory limits
3. Create necessary directories
4. Start the synchronization process with all enhancements enabled
5. Automatically restart with reduced memory settings if needed

### Configuration
The system can be configured through environment variables or command-line arguments:

- `NODE_OPTIONS`: Memory settings for Node.js
- `MEMORY_WARNING_THRESHOLD`: Percentage at which to issue memory warnings (default: 70%)
- `MEMORY_CRITICAL_THRESHOLD`: Percentage at which to initiate shutdown (default: 85%)
- `LOCK_TIMEOUT`: Maximum age of locks in milliseconds (default: 30000)
- `LOCK_CLEANUP_INTERVAL`: Interval for checking stale locks in milliseconds (default: 60000)

## Requirements
- Node.js 14.x or higher
- chokidar package for file watching

## Troubleshooting

### Memory Issues
If you encounter memory-related crashes:
1. Check the logs for memory usage statistics
2. Reduce the number of watched directories
3. Increase the available memory in `run-enhanced.bat`
4. Consider running in low CPU mode with `--low-cpu-mode`

### Lock Issues
If you encounter lock-related issues:
1. Check the lock directory for stale lock files
2. Verify that the lock cleanup process is running
3. Manually remove lock files if necessary (only when the system is not running)

### JSON Validation Issues
If you encounter JSON validation issues:
1. Check the backup directory for backups of the affected files
2. Review the logs for detailed error information
3. Manually repair severely corrupted files if automatic repair fails

## License
MIT

## Author
cFish.io Development Team