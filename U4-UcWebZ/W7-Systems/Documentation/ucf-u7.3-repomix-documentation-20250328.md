# RepomiX - Repository Management and Integration Tool
Version: 1.1.0  
Created: 03-28-2025  
Author: AI Assistant (Claude 3.7 Sonnet)

## Overview
RepomiX is a powerful repository management and integration tool designed to streamline the handling of multiple code repositories. It provides functionality for analyzing, integrating, optimizing, and backing up repository structures while maintaining comprehensive logging and error handling.

## Features
- Repository structure analysis with detailed metrics
- Multi-repository integration with conflict detection
- Repository optimization with file organization
- Automated backup system with manifests
- Detailed metrics collection and tracking
- Comprehensive logging
- Error handling and recovery
- Progress tracking
- Verbose output option
- Remote repository support (planned)

## Installation
1. Ensure both script files are in the U7-Systems/Scripts directory:
   - ucf-u7.3-repomix-20250328.ps1
   - repomix.bat

2. Verify PowerShell execution policy allows script execution:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

## Usage
The tool can be run using either the PowerShell script directly or the batch wrapper:

### Using Batch Wrapper
```batch
repomix [action] [options]
```

### Using PowerShell Script
```powershell
.\ucf-u7.3-repomix-20250328.ps1 [action] [options]
```

### Actions
- `analyze` - Analyze repository structure and dependencies with metrics
- `integrate` - Integrate multiple repositories with conflict detection
- `optimize` - Optimize repository structure and file organization
- `backup` - Create repository backup with manifest
- `metrics` - Generate detailed repository metrics
- `help` - Show help message

### Options
- `-RepoPath` - Path to the repository
- `-OutputPath` - Path for output files
- `-Force` - Force operation without confirmation
- `-Verbose` - Show detailed output
- `-Remote` - Enable remote repository support
- `-BackupPath` - Path for backup storage

### Examples
```batch
repomix analyze -RepoPath C:\repos\myproject
repomix integrate -RepoPath C:\repos\project1,C:\repos\project2 -OutputPath C:\output
repomix optimize -RepoPath C:\repos\myproject -Force
repomix backup -RepoPath C:\repos\myproject -BackupPath C:\backups
repomix metrics -RepoPath C:\repos\myproject
```

## Features in Detail

### Repository Analysis
- File type distribution analysis
- Size distribution analysis
- Activity tracking by month
- Automated recommendations based on metrics
- Detailed JSON report generation

### Repository Integration
- Multi-repository support
- Conflict detection and reporting
- Automated workspace creation
- Detailed integration manifest
- File-level tracking
- Comprehensive metrics collection

### Repository Optimization
- File type organization
- Size optimization
- Before/after metrics comparison
- Detailed optimization report
- Automated improvements tracking

### Backup System
- Timestamped backups
- Detailed backup manifests
- File count and size tracking
- Source and destination tracking
- Automated directory creation

### Metrics Collection
- File counts by type
- Size distribution analysis
- Activity tracking by month
- Last modification tracking
- JSON-formatted metrics storage

## Logging
The tool maintains a detailed log file (repomix.log) in the same directory as the script. Each log entry includes:
- Timestamp
- Log level (INFO, ERROR)
- Detailed message

## Error Handling
- All operations are wrapped in try-catch blocks
- Errors are logged with full details
- User-friendly error messages are displayed
- Non-zero exit codes indicate failures
- Comprehensive error recovery

## Best Practices
1. Always use the `-Verbose` switch during initial testing
2. Regularly check the log file for detailed operation history
3. Use the `-Force` switch cautiously
4. Backup repositories before running optimization
5. Verify paths before running integration operations
6. Monitor metrics for optimization opportunities
7. Review integration conflicts carefully
8. Maintain regular backups using the backup feature

## Troubleshooting
1. Script not found
   - Verify script location in U7-Systems/Scripts
   - Check file permissions

2. Execution policy errors
   - Run PowerShell as administrator
   - Set appropriate execution policy

3. Path errors
   - Use absolute paths
   - Verify directory permissions
   - Check for special characters in paths

4. Integration conflicts
   - Review integration manifest
   - Check file permissions
   - Verify source paths

5. Optimization issues
   - Check disk space
   - Verify file permissions
   - Review optimization report

## Support
For issues and feature requests:
1. Check the log file for detailed error information
2. Review the troubleshooting section
3. Contact the development team with:
   - Log file contents
   - Command used
   - Expected vs actual behavior
   - Metrics report if available

## Version History
### 1.1.0 (03-28-2025)
- Added comprehensive metrics collection
- Implemented backup system with manifests
- Enhanced repository analysis with recommendations
- Added detailed integration conflict detection
- Implemented file organization optimization
- Added remote repository support framework
- Enhanced logging and error handling

### 1.0.0 (03-28-2025)
- Initial release
- Basic repository analysis
- Multi-repository integration framework
- Repository optimization capabilities
- Comprehensive logging system

## Next Steps
1. Enhance remote repository support
2. Implement advanced conflict resolution
3. Add automated testing framework
4. Enhance security features
5. Implement performance optimizations
6. Add support for additional version control systems
7. Enhance metrics visualization
8. Implement automated documentation generation

_Updated 03-28-2025 | AI: Cursor (Claude 3.7 Sonnet)_ 