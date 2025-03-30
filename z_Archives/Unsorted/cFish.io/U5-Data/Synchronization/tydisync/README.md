# tYDiSync~

A robust bi-directional synchronization system for Markdown and JSON files, with memory optimization for preventing crashes and data loss.

## Overview

tYDiSync~ enables seamless two-way synchronization between Markdown files and their JSON representations. It powers cFish.io's AI-enhanced content workflows by allowing both human editing in Markdown and programmatic manipulation of structured data in JSON.

This system has been designed with reliability, performance, and scalability in mind. It includes advanced features such as memory optimization, error recovery, and robust file handling.

## Purpose

**Core Purpose**: tYDiSync~ creates a bidirectional synchronization system that maintains perfect harmony between human-readable Markdown files and machine-readable JSON files.

The key benefits include:

1. **Dual-Format Documentation**: Humans can work with easily readable and editable Markdown files, while AI tools and applications can efficiently parse the structured JSON versions of the same content.

2. **Real-Time Synchronization**: Any changes made to either format (Markdown or JSON) are automatically detected and propagated to the other format, ensuring content is always consistent across both formats.

3. **WordPress Integration**: The system works alongside WordPress development, providing structured data that can be consumed by various components of the cFish.io ecosystem.

4. **Content Preservation**: Advanced mechanisms ensure critical files like memory.md (the project's knowledge base) are protected from data loss during synchronization.

5. **Cross-Platform Compatibility**: Works across Windows, Linux, and macOS environments, ensuring consistent functionality regardless of development platform.

tYDiSync~ bridges the gap between human-readable documentation and machine-parseable structured data, creating a seamless workflow where changes in either format are immediately reflected in the other. This is particularly valuable for AI tools that need structured data but want to preserve the readability and ease of editing that Markdown provides for humans.

## Directory Structure

```
sync-system/
├── agents/         # Specialized sync agents
├── config/         # Configuration files
├── core/           # Core implementation
│   ├── dummy-tydisync.js         # Base implementation
│   ├── memory-optimization.js        # Memory management utilities
│   ├── optimized-tydisync.js     # Memory-optimized implementation
│   └── tydisync.js               # Original implementation
├── docs/           # Documentation
├── state/          # Runtime state storage
├── tests/          # Test scripts
│   └── memory-test.js                # Memory optimization tests
├── utils/          # Utility functions
├── README.md                         # This file
├── start-optimized-sync.bat          # Windows startup script with memory settings
└── start-optimized-sync.js           # Node.js startup script
```

## Key Features

- **Bi-directional Synchronization**: Changes in either Markdown or JSON files are automatically reflected in the counterpart format
- **Memory Optimization**: Prevents "JavaScript heap out of memory" errors and crashes
- **Streaming File Processing**: Efficiently handles large files by processing them in chunks
- **Error Recovery**: Robust mechanisms for handling errors and recovering from failures
- **Backup Creation**: Automatic backups before transformations for data safety
- **Batch Processing**: Efficiently processes multiple file changes as batches
- **Status Monitoring**: Real-time status updates and notifications

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

## Contributing

1. Follow the code organization guidelines in the project README
2. Include appropriate documentation for any new features
3. Write tests for new functionality
4. Update the memory.md file with any significant changes

## License

This project is proprietary and confidential to cFish.io.

_Updated 05-18-2025 | AI: Cursor (Claude 3.7 Sonnet)_ 