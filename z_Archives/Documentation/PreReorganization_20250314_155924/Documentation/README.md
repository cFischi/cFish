# tYDiSync~

A robust bi-directional synchronization system for Markdown and JSON files, with memory optimization for preventing crashes and data loss.

## Overview

tYDiSync~ enables seamless two-way synchronization between Markdown files and their JSON representations. It powers cFish.io's AI-enhanced content workflows by allowing both human editing in Markdown and programmatic manipulation of structured data in JSON.

This system has been designed with reliability, performance, and scalability in mind. It includes advanced features such as memory optimization, error recovery, and robust file handling.

## Core Purpose

**Core Purpose**: tYDiSync~ creates a bidirectional synchronization system that maintains perfect harmony between human-readable Markdown files and machine-readable JSON files.

The key benefits include:

1. **Dual-Format Documentation**: Humans can work with easily readable and editable Markdown files, while AI tools and applications can efficiently parse the structured JSON versions of the same content.

2. **Real-Time Synchronization**: Any changes made to either format (Markdown or JSON) are automatically detected and propagated to the other format, ensuring content is always consistent across both formats.

3. **WordPress Integration**: The system works alongside WordPress development, providing structured data that can be consumed by various components of the cFish.io ecosystem.

4. **Content Preservation**: Advanced mechanisms ensure critical files like memory.md (the project's knowledge base) are protected from data loss during synchronization.

5. **Cross-Platform Compatibility**: Works across Windows, Linux, and macOS environments, ensuring consistent functionality regardless of development platform.

## Architecture

tYDiSync~ uses a distributed agent architecture with five specialized agents:

1. **Alpha Agent**: Monitors the filesystem for changes to Markdown and JSON files, serving as the entry point for synchronization
2. **Beta Agent**: Handles the conversion from Markdown to JSON, parsing Markdown structures into structured data
3. **Gamma Agent**: Serves as the conflict resolver, implementing intelligent section-level merging and preserving content
4. **Delta Agent**: Manages the conversion from JSON back to Markdown, ensuring changes to structured data are reflected correctly
5. **Epsilon Agent**: Acts as the process controller, managing process lifecycle, Cursor detection, and ensuring proper startup/shutdown

## Directory Structure

```
sync-system/
├── agents/         # Specialized sync agents
│   ├── alpha-agent.js    # Filesystem monitoring
│   ├── beta-agent.js     # Markdown to JSON conversion
│   ├── gamma-agent.js    # Conflict resolution
│   ├── delta-agent.js    # JSON to Markdown conversion
│   └── epsilon-agent.js  # Process management
├── config/         # Configuration files
├── core/           # Core implementation
│   ├── dummy-tydisync.js         # Base implementation
│   ├── memory-optimization.js    # Memory management utilities
│   ├── optimized-tydisync.js     # Memory-optimized implementation
│   └── tydisync.js               # Original implementation
├── docs/           # Documentation
├── json/           # JSON files for synchronization
├── md/             # Markdown files for synchronization
├── performance/    # Performance enhancement modules
│   └── differential-engine.ps1   # Differential update system
├── state/          # Runtime state storage
├── tests/          # Test scripts
│   └── memory-test.js            # Memory optimization tests
├── utils/          # Utility functions
│   ├── backup-manager.js         # Backup creation and rotation
│   ├── backup-restore.js         # Backup restoration
│   ├── lock-manager.js           # File locking mechanisms
│   ├── memory-manager.js         # Memory usage monitoring
│   └── json-validator.js         # JSON validation
├── web/            # Web interfaces
│   ├── dashboard/               # Web-based monitoring dashboard
│   └── wordpress-plugin/        # WordPress integration
├── README.md                     # This file
├── start-optimized-sync.bat      # Windows startup script with memory settings
└── start-optimized-sync.js       # Node.js startup script
```

## Key Features

- **Bi-directional Synchronization**: Changes in either Markdown or JSON files are automatically reflected in the counterpart format
- **Memory Optimization**: Prevents "JavaScript heap out of memory" errors and crashes
- **Streaming File Processing**: Efficiently handles large files by processing them in chunks
- **Error Recovery**: Robust mechanisms for handling errors and recovering from failures
- **Backup Creation**: Automatic backups before transformations for data safety
- **Batch Processing**: Efficiently processes multiple file changes as batches
- **Status Monitoring**: Real-time status updates and notifications
- **Conflict Resolution**: Sophisticated section-level merging when conflicts arise
- **Critical File Protection**: Special handling for essential files like memory.md

## Performance Enhancements

The system includes dedicated performance optimizations:

- **Differential Update Engine**: Identifies and transfers only changed portions of files
- **Multi-level Caching**: Memory and disk caching for frequent operations
- **Parallelization**: Multi-threaded operations for CPU-intensive tasks
- **I/O Batching**: Reduced disk access through batching and buffering

## Web Interfaces

### Dashboard

A comprehensive web dashboard provides:
- Real-time synchronization status monitoring
- Configuration management interface
- Job control (start, stop, pause, resume)
- Visual performance metrics

### WordPress Plugin

The WordPress integration enables:
- WordPress admin interface for tYDiSync~ configuration
- Shortcodes for displaying JSON-sourced content
- Content mapping between JSON sources and WordPress
- Direct integration with tYDiSync~ core functionality

## Getting Started

### Prerequisites

- Node.js 14.x or higher
- npm 6.x or higher

### Installation

1. Ensure you're in the project root directory (`cFish.io`)
2. Install dependencies:
   ```
   npm install
   ```

### Running tYDiSync~

For normal operation with memory optimization:

```
cd sync-system
start-optimized-sync.bat
```

For manual operation:

```
node --max-old-space-size=4096 --expose-gc sync-system/start-optimized-sync.js
```

## Configuration

The system is configured through `sync-system/config/sync-config.json`. Key configuration options include:

- **watchDirectories**: Markdown and JSON directories to monitor
- **exclusions**: Patterns for files to ignore
- **backupSettings**: Configuration for automatic backups
- **performanceSettings**: Batch processing and throttling options
- **errorRecoverySettings**: Error handling and recovery options
- **memoryOptimizationSettings**: Memory threshold and garbage collection settings

## Memory Optimization

The system includes advanced memory optimization to prevent crashes:

- **Memory Monitoring**: Tracks memory usage and responds to high usage conditions
- **Garbage Collection**: Automatically triggers garbage collection when needed
- **Streaming Processing**: Processes large files in chunks to reduce memory footprint
- **Emergency Cleanup**: Performs emergency cleanup when memory usage is critical

See the detailed documentation in `sync-system/docs/memory-optimization.md` for more information.

## Testing

Run the memory optimization test:

```
node sync-system/tests/memory-test.js
```

Add `--cleanup` to automatically remove test files after completion:

```
node sync-system/tests/memory-test.js --cleanup
```

## Cross-Platform Support

tYDiSync~ works consistently across:
- Windows (using both cmd.exe and PowerShell)
- Linux (with appropriate path handling)
- macOS (with compatible functionality)

## Contributing

1. Follow the code organization guidelines in this README
2. Include appropriate documentation for any new features
3. Write tests for new functionality
4. Update the memory.md file with any significant changes

## License

This project is proprietary and confidential to cFish.io.

_Updated 05-19-2025 | AI: Cursor (Claude 3.7 Sonnet)_
