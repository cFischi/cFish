# MD-JSON Sync System Memory Optimization

## Overview

This document describes the memory optimization implementation for the MD-JSON Synchronization System. The optimization addresses memory leaks that were causing the system to crash with "JavaScript heap out of memory" errors during extended operation.

## Problem Description

The original MD-JSON Sync implementation (`dummy-tydisync.js`) suffered from several memory-related issues:

1. **Memory Leaks**: The system did not properly release memory after processing files, resulting in growing memory usage over time.
2. **Large File Handling**: Processing large files fully in memory caused spikes in memory usage.
3. **Unbounded Queue Growth**: The queues for pending files could grow without limits during high load periods.
4. **No Memory Monitoring**: The system had no way to detect or respond to high memory conditions.

## Solution Components

The memory optimization solution consists of several components:

### 1. OptimizedMdJsonSync Class

Located in `sync-system/core/optimized-tydisync.js`, this class extends the original `MdJsonSync` class with memory optimization features:

- Memory usage monitoring and tracking
- Streaming file processing for large files
- Garbage collection triggers
- Emergency cleanup procedures for high memory conditions
- State saving and recovery mechanisms

### 2. Memory Monitoring

The `MemoryMonitor` class (from `memory-optimization.js`) provides:

- Regular memory usage checks
- Warning and critical threshold notifications
- Automatic garbage collection triggering
- Memory usage statistics

### 3. Streaming File Processing

The `StreamingFileProcessor` class processes files in chunks rather than loading them entirely into memory:

- Processes files in configurable chunk sizes (default: 64KB)
- Reduces memory footprint for large file operations
- Implements backpressure handling for improved performance

### 4. Process Management

The `ProcessManager` handles process-level events and recovery:

- Graceful shutdown procedures
- Uncaught exception handling
- State saving before crashes
- Process restart capabilities

## Implementation Details

### Memory Usage Tracking

The system now tracks memory usage over time and responds to different thresholds:

- **Warning Threshold** (default: 60%): Triggers cleanup operations
- **Critical Threshold** (default: 80%): Triggers emergency procedures

### Garbage Collection

The optimized system uses Node.js's garbage collector more aggressively:

- Forced garbage collection after processing large files
- Automatic garbage collection at warning threshold
- Exposed GC using the `--expose-gc` flag

### Batch Processing Improvements

File processing has been improved:

- Smaller batch sizes (3 files instead of 5)
- Increased batch timeout (3000ms instead of 2000ms)
- Limited concurrent tasks (2 instead of 3)
- Increased throttling delay (1000ms instead of 500ms)

### Error Recovery

Enhanced error recovery mechanisms:

- Retry with exponential backoff
- Multiple recovery strategies (backup restore, partial sync, recreate)
- State persistence for resuming after crashes

## Usage

To use the optimized system:

1. Run the system with increased memory limits using the provided batch file:
   ```
   sync-system\start-optimized-sync.bat
   ```

2. Or run manually with the following Node.js options:
   ```
   node --max-old-space-size=4096 --expose-gc sync-system/start-optimized-sync.js
   ```

## Configuration

The system can be configured via `sync-system/config/sync-config.json`. Key memory-related settings include:

```json
{
  "memoryOptimizationSettings": {
    "memoryWarningThreshold": 60,
    "memoryCriticalThreshold": 80,
    "memoryCheckInterval": 5000,
    "enableAutoGC": true,
    "streamChunkSize": 65536
  },
  "performanceSettings": {
    "batchProcessingEnabled": true,
    "batchSize": 3,
    "batchTimeout": 3000,
    "throttlingEnabled": true,
    "maxConcurrentTasks": 2,
    "throttleDelay": 1000
  }
}
```

## Monitoring

The optimized system provides several monitoring capabilities:

1. **Status File**: A JSON file with system status (`sync-system/state/tydisync-status.json`)
2. **Notifications**: A JSON file with system notifications (`sync-system/state/tydisync-notifications.json`)
3. **Log Files**: Detailed logs in the `logs` directory
4. **Console Output**: Real-time status indicators in the console

## Troubleshooting

If memory issues persist:

1. Decrease `batchSize` and `maxConcurrentTasks` in the configuration
2. Increase the `--max-old-space-size` value in the batch file
3. Lower the `memoryWarningThreshold` to trigger cleanup earlier
4. Ensure the system is not watching too many directories or files

## Future Improvements

Planned enhancements:

1. Complete streaming implementation for JSON to Markdown conversion
2. Add memory usage visualization tools
3. Implement worker threads for parallel processing
4. Add automatic configuration tuning based on system capabilities
5. Improve test coverage for memory optimization components

---

Document created on March 12, 2025 