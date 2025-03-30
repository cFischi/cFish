# Changelog

All notable changes to the cFish.io project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2025-03-14

### Added
- Memory management system to prevent out-of-memory crashes
- Lock management utility to handle stale locks and prevent race conditions
- JSON validation and recovery system to detect and fix JSON parsing errors
- Integration script combining all enhancements with the MD-JSON sync system
- Batch launcher with adaptive restart capabilities for memory-related crashes
- Automatic backup creation before attempting JSON repairs

### Changed
- Enhanced lock acquisition and release process with timeout-based expiration
- Improved error handling throughout the synchronization system
- Optimized memory usage with proactive garbage collection

### Fixed
- Resolved stale lock removal failures in the Delta Agent
- Fixed memory limitation issues causing "JavaScript heap out of memory" errors
- Addressed JSON parsing errors with robust validation and recovery

## [1.0.0] - 2025-03-12

### Added
- Distributed agent architecture for bidirectional synchronization
- Five specialized agents (Alpha, Beta, Gamma, Delta, Epsilon)
- Configuration system with support for watch directories and backup settings
- Safety features including backups, locks, and critical file protection
- Windows integration with startup options and background processing
- Test scripts for verifying MD-to-JSON and JSON-to-MD conversions
- Logging system for tracking synchronization activities

### Changed
- Improved file monitoring with Chokidar for better performance
- Enhanced conflict resolution strategies

### Fixed
- Resolved issues with root directory monitoring
- Fixed critical file protection to prevent memory.md data loss

## [Unreleased]

### Added
- Created shortlinks directory for managing URL redirects
- Added placeholder files for cfish, cfish-it, and ty URLs
- Created README.md with shortlinks usage documentation
- Optimized AI assistant interaction through improved cursor settings guidelines
- Implemented documentation signature system for memory.md entries
- Created Node.js script (update-memory.js) for standardized memory updates
- Added Windows batch wrapper (update-memory.bat) for easy execution
- Created multiple formats of WordPress guidelines (JSON, YAML, Markdown)
- Added comprehensive documentation practices section to .cursorrules
- Created JSON versions of all shortlinks in the /shortlinks/json/ directory for AI ingestion
- Developed comprehensive MD-JSON synchronization improvement plan with modular task structure
- Documented critical issues and solutions for MD-JSON synchronization system
- Created structured task assignments for parallel improvement implementation
- Added detailed testing plans for each synchronization fix component
- Established timeline estimates for sync system enhancements (7-10 hours total)
- Created detailed documentation of improvements in docs/md-json-sync-improvements.md

### Changed
- Restructured WordPress development guidelines in cursor settings
- Enhanced documentation structure with clearer section headers
- Prioritized core development principles in guidelines
- Improved .cursorrules with structured sections for AI guidance
- Standardized memory.md entry format with proper signatures
- Enhanced memory.md with full restoration of previously lost content
- Improved backup naming conventions for better traceability
- Updated merging algorithm to prioritize content preservation
- Enhanced file exclusion mechanism with .nosync marker detection

### Fixed
- Resolved memory.md data loss issue by implementing .nosync protection
- Restored complete content to memory.md from reliable backup
- Documented critical vulnerabilities in the MD-JSON synchronization system
- JSON-to-Markdown synchronization now works correctly
- File monitoring for JSON changes properly detects and processes modifications
- Path resolution for complex directory structures in JSON-to-MD conversion
- Prevent race conditions during bidirectional synchronization
- Fixed critical content loss in merging algorithm during JSON-to-MD conversion
- Added safeguards to prevent destruction of existing content
- Implemented content validation to detect and prevent data loss

## [0.0.1] - 2023-11-17

### Added
- Created Assembler child theme structure
- Set up GitHub repository for WordPress site
- Implemented initial deployment workflow
- Added comprehensive documentation suite
- Created automation scripts for development tasks

### Changed
- Shifted from WordPress Studio to wordpress.com-centric approach
- Updated development workflow to include Local by Flywheel

### Fixed
- GitHub Theme URI in child theme style.css 
- Simplified child theme functions.php to avoid conflicts

## [1.0.0] - 2025-05-10

### Added
- Initial release of cFish.io shortlinks system
- Shortlinks: cfish, cfish-it, and ty
- JSON versions of all shortlinks for AI ingestion
- Standardized metadata format and documentation

### Changed
- N/A

### Fixed
- N/A

## [1.5.0] - 2025-05-10

### Added
- Added Platform Integration section to SOP.md with detailed information from shortlinks
- Added Shortlinks Service section to spec.md with management procedures
- Added Emergency Protocols section to spec.md with system issue handling procedures

### Changed
- Updated documentation to maintain consistency between public-facing shortlinks and internal documentation
- Improved cross-referencing between documentation files

## [1.1.0] - [2025-05-10]

### Added
- MD-to-JSON synchronization system for creating AI-optimized versions of documentation
- Node.js script (md-to-json.js) for converting Markdown to structured JSON
- Batch scripts for easy execution (md-to-json.bat, start-md-to-json-watcher.bat)
- NPM scripts in package.json for the conversion process
- Documentation for the synchronization system in docs/json-sync-system.md

### Changed
- Updated Cursor rules to instruct AI assistants to prioritize JSON versions of files
- Modified README files to mention the JSON synchronization
- Enhanced project structure with organized JSON output directories

## [1.1.1] - [2025-05-11]

### Added
- Windows startup automation for MD-to-JSON conversion system
- Silent VBS script runner for background execution
- Windows Task Scheduler configuration script
- Automated startup removal script
- Comprehensive README for the MD-to-JSON system

### Changed
- Enhanced MD-to-JSON system to run continuously without user intervention
- Improved background execution with no visible windows

## [1.2.0] - [2025-03-12]

### Added
- MD-JSON Synchronization System with distributed agent architecture
- Five specialized agents for different synchronization responsibilities:
  - Alpha Agent: File system monitoring
  - Beta Agent: Content transformation between Markdown and JSON
  - Gamma Agent: Conflict resolution
  - Delta Agent: Safety management (backups, locks)
  - Epsilon Agent: Process control and Cursor integration
- Configuration system with support for multiple watch directories
- Windows integration with startup options and background processing
- Test scripts for verifying conversion functionality
- Logging system for tracking synchronization activities

### Changed
- Improved file handling with safety measures to prevent data loss
- Enhanced content transformation with validation checks

### Fixed
- Resolved memory.md data loss issues with critical file protection
- Fixed synchronization loops with improved file change detection

### Known Issues
- JSON-to-Markdown synchronization requires further refinement
- File monitoring for JSON changes needs improvement

## [1.2.0] - 2025-03-14

### Added
- Low-CPU mode with verified performance improvements (CPU reduction from 90-100% to 20-30%)
- Memory-optimized launcher script with automatic dependency checking
- Advanced diagnostic logging with CPU mode indicators
- New documentation: md-json-sync-low-cpu-reference.md

### Changed
- Updated action timeline in md-json-sync-next-steps.md with immediate, short-term, and long-term tasks
- Enhanced configuration options for WordPress directory exclusions
- Improved throttling mechanisms with configurable batch sizes and delays
- Fixed JSON parsing error in md-json-sync-quick-reference.json

### Fixed
- Resolved critical issue with nodejs memory heap limitations
- Fixed race conditions in file locking system
- Addressed corrupt JSON handling with improved error detection
- Resolved WordPress directory monitoring issues causing high CPU usage

## [1.2.0] - 2025-05-28

### Added
- Recursive directory monitoring with configurable depth
- Enhanced exclusion patterns with negation support (!*.md, !*.json)
- Backup rotation system with configurable limits
- Backup restoration utility with date-based and file-based recovery
- Comprehensive testing suite with complex document generation

### Changed
- Improved memory management integration with backup system
- Enhanced error handling for file system operations
- Optimized startup process with dependency verification

### Fixed
- Issue with stale lock detection in nested directories
- Memory leaks during large file transformations
- JSON parsing failures with partial recovery capabilities

## [1.3.0] - 2025-03-12

### Added
- Enhanced MD-JSON synchronization system with improved stability and reliability
- Directory monitoring with chokidar for reliable file change detection
- Backup system with timestamped backups and automatic rotation
- Memory management with automatic garbage collection
- Lock management with stale lock detection and cleanup
- JSON validation and automatic repair functionality
- Low CPU mode for reduced resource usage
- Test scripts for verifying synchronization and backup functionality

### Changed
- Improved file watching with configurable depth and recursive monitoring
- Enhanced exclusion patterns to filter non-document files
- Upgraded backup system with configurable limits and automatic cleanup
- Improved error handling and graceful shutdown procedures

### Fixed
- Resolved issues with file locking during concurrent modifications
- Fixed memory leaks in long-running synchronization processes
- Addressed JSON parsing errors with validation and repair
- Fixed directory monitoring to properly detect all file changes

## How to Use This Changelog

**Entry Format:**

```
## [Version] - YYYY-MM-DD

### Added
- New features or components

### Changed
- Changes to existing functionality

### Fixed
- Bug fixes

### Removed
- Removed features or components
```

**When to Update:**

1. Update this file BEFORE pushing changes to GitHub
2. Document ALL significant changes
3. Group changes by type (Added, Changed, Fixed, Removed)
4. Keep entries concise but descriptive
5. Include ticket/issue numbers when applicable

**Version Numbering:**

- MAJOR version: Significant redesigns or functionality changes
- MINOR version: New features or substantial enhancements
- PATCH version: Bug fixes and minor improvements

**Sample Entry:**

```