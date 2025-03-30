# tYDiSync~ - Optimized Synchronization System

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
tydisync/
├── src/                # Source code
│   ├── agents/         # Specialized sync agents
│   ├── core/           # Core implementation
│   ├── utils/          # Utility functions
│   ├── config/         # Configuration files
│   ├── docs/           # Documentation
│   ├── tests/          # Test files
│   └── web/            # Web interface components
├── backups/            # Backup storage
├── logs/               # Log files
├── state/              # State persistence
├── tools/              # Development tools
├── scripts/            # Utility scripts
├── resources/          # Static resources
└── web-interface/      # Web interface files
```

## Getting Started

1. Clone the repository
2. Install dependencies: `npm install`
3. Start the synchronization system: `npm start`

## Documentation

For detailed documentation, please refer to the `docs` directory.

## License

MIT

_Updated 03-13-2025 | AI: Cursor (Claude 3.7 Sonnet)_ 