# Minimal Installation System Fixes

## Overview
This document outlines the implementation plan for fixing critical issues discovered during minimal installation testing on 05-07-2025.

## Current Issues

### 1. Process Management
```javascript
// Current implementation (failing)
async cleanupResources() {
  const processList = await this.resourceMonitor.getProcessList(); // Missing method
  // ... incomplete cleanup logic
}
```

### 2. Resource Monitoring
```javascript
// Current thresholds (too high)
this.config = {
  memoryThreshold: 70,    // Warning threshold
  cpuThreshold: 70,       // CPU warning
  emergencyThreshold: 80  // Critical threshold
};
```

### 3. Error Handling
```javascript
// Current implementation (incomplete)
async checkResources() {
  const metrics = this.metrics.total; // Undefined access
  return {
    memory: metrics.used / metrics.memory * 100,
    cpu: this.metrics.cpu
  };
}
```

## Implementation Plan

### Phase 1: Process Management (2hr)

#### 1.1 ResourceMonitor Enhancement
```javascript
class EnhancedResourceMonitor {
  async getProcessList() {
    if (process.platform === 'win32') {
      return this.getWindowsProcesses();
    }
    return this.getUnixProcesses();
  }

  async getWindowsProcesses() {
    const { execFile } = require('child_process');
    const util = require('util');
    const execFileAsync = util.promisify(execFile);
    
    try {
      const { stdout } = await execFileAsync('tasklist', ['/FO', 'CSV']);
      return this.parseWindowsProcessList(stdout);
    } catch (error) {
      this.log('Error getting Windows process list:', error);
      return [];
    }
  }

  async getUnixProcesses() {
    const { execFile } = require('child_process');
    const util = require('util');
    const execFileAsync = util.promisify(execFile);
    
    try {
      const { stdout } = await execFileAsync('ps', ['aux']);
      return this.parseUnixProcessList(stdout);
    } catch (error) {
      this.log('Error getting Unix process list:', error);
      return [];
    }
  }
}
```

#### 1.2 Process Cleanup Enhancement
```javascript
class StagedInstaller {
  async cleanupResources() {
    console.log('Cleaning up resources...');
    
    try {
      // Get current process list
      const processes = await this.resourceMonitor.getProcessList();
      
      // Track cleanup operations
      const cleanupResults = {
        processesKilled: 0,
        cachesCleared: false,
        gcCalled: false
      };

      // Kill stray npm processes
      for (const proc of processes) {
        if (proc.name.includes('npm') && !this.activeProcesses.has(proc.pid)) {
          try {
            process.kill(proc.pid);
            cleanupResults.processesKilled++;
          } catch (err) {
            this.log(`Error killing process ${proc.pid}:`, err);
          }
        }
      }

      // Clear npm cache
      try {
        await this.runCommand('npm', ['cache', 'clean', '--force']);
        cleanupResults.cachesCleared = true;
      } catch (err) {
        this.log('Error clearing npm cache:', err);
      }

      // Force garbage collection if available
      if (global.gc) {
        global.gc();
        cleanupResults.gcCalled = true;
      }

      return cleanupResults;
    } catch (err) {
      this.log('Error during cleanup:', err);
      throw err;
    }
  }
}
```

### Phase 2: Resource Management (2hr)

#### 2.1 Adjusted Thresholds
```javascript
class StagedInstaller {
  constructor(config = {}) {
    this.config = {
      memoryThreshold: 60,    // Lower warning threshold
      cpuThreshold: 60,       // Lower CPU warning
      emergencyThreshold: 70,  // Lower critical threshold
      memoryCheckInterval: 1000,
      cooldownPeriod: 30000,
      ...config
    };
  }
}
```

#### 2.2 Memory Optimization
```javascript
class StagedInstaller {
  async optimizeMemory() {
    const results = {
      initialMemory: process.memoryUsage(),
      gcCalled: false,
      defragAttempted: false
    };

    // Force garbage collection
    if (global.gc) {
      global.gc();
      results.gcCalled = true;
    }

    // Attempt memory defragmentation
    try {
      await this.defragmentMemory();
      results.defragAttempted = true;
    } catch (err) {
      this.log('Memory defragmentation failed:', err);
    }

    results.finalMemory = process.memoryUsage();
    return results;
  }

  async defragmentMemory() {
    // Implementation depends on Node.js version and platform
    if (process.platform === 'win32') {
      return this.defragmentWindowsMemory();
    }
    return this.defragmentUnixMemory();
  }
}
```

### Phase 3: Error Handling (2hr)

#### 3.1 Resource Checking
```javascript
class StagedInstaller {
  async checkResources() {
    try {
      // Validate metrics object
      if (!this.metrics || !this.metrics.total) {
        throw new Error('Resource metrics not available');
      }

      const { total, cpu } = this.metrics;
      
      // Validate required properties
      if (typeof total.memory !== 'number' || typeof total.used !== 'number') {
        throw new Error('Invalid memory metrics format');
      }

      return {
        memory: (total.used / total.memory) * 100,
        cpu: typeof cpu === 'number' ? cpu : 0,
        heap: process.memoryUsage()
      };
    } catch (error) {
      this.log('Error checking resources:', error);
      // Return safe defaults
      return {
        memory: 0,
        cpu: 0,
        heap: process.memoryUsage()
      };
    }
  }
}
```

#### 3.2 Emergency Handling
```javascript
class StagedInstaller {
  async handleEmergency(usageValue) {
    this.log(`EMERGENCY: Resource usage critical (${usageValue}%)`);
    
    try {
      // Stop all ongoing operations
      this.paused = true;
      
      // Kill all active processes
      await this.killAllProcesses();
      
      // Clear npm cache
      await this.clearNpmCache();
      
      // Force garbage collection
      if (global.gc) {
        global.gc();
      }
      
      // Wait for resources to stabilize
      await this.waitForResourceStabilization();
      
      // Save current state
      await this.saveQueue();
      
      return true;
    } catch (error) {
      this.log('Error during emergency handling:', error);
      // Exit process as last resort
      process.exit(1);
    }
  }

  async waitForResourceStabilization() {
    this.log('Waiting for memory to stabilize...');
    
    let stableCount = 0;
    const requiredStableChecks = 5;
    
    while (stableCount < requiredStableChecks) {
      const resources = await this.checkResources();
      
      if (resources.memory < this.config.memoryThreshold) {
        stableCount++;
      } else {
        stableCount = 0;
      }
      
      await this.sleep(1000);
    }
  }
}
```

## Testing Plan

### 1. Process Management Tests
```javascript
describe('Process Management', () => {
  test('getProcessList returns valid process list', async () => {
    const monitor = new EnhancedResourceMonitor();
    const processes = await monitor.getProcessList();
    expect(Array.isArray(processes)).toBe(true);
    expect(processes.length).toBeGreaterThan(0);
  });

  test('cleanupResources kills stray processes', async () => {
    const installer = new StagedInstaller();
    const results = await installer.cleanupResources();
    expect(results.processesKilled).toBeGreaterThanOrEqual(0);
    expect(results.cachesCleared).toBe(true);
  });
});
```

### 2. Resource Management Tests
```javascript
describe('Resource Management', () => {
  test('memory optimization reduces memory usage', async () => {
    const installer = new StagedInstaller();
    const results = await installer.optimizeMemory();
    expect(results.finalMemory.heapUsed).toBeLessThan(results.initialMemory.heapUsed);
  });

  test('resource checks handle invalid metrics', async () => {
    const installer = new StagedInstaller();
    installer.metrics = null;
    const resources = await installer.checkResources();
    expect(resources).toHaveProperty('memory', 0);
    expect(resources).toHaveProperty('cpu', 0);
  });
});
```

### 3. Error Handling Tests
```javascript
describe('Error Handling', () => {
  test('emergency handling stops all processes', async () => {
    const installer = new StagedInstaller();
    const result = await installer.handleEmergency(90);
    expect(result).toBe(true);
    expect(installer.paused).toBe(true);
  });

  test('resource stabilization waits for stable state', async () => {
    const installer = new StagedInstaller();
    await installer.waitForResourceStabilization();
    const resources = await installer.checkResources();
    expect(resources.memory).toBeLessThan(installer.config.memoryThreshold);
  });
});
```

## Success Criteria

1. Process Management
   - All processes properly tracked and managed
   - No stray processes after cleanup
   - Successful npm cache management
   - Proper process isolation

2. Resource Management
   - Memory usage stays below 60% warning threshold
   - Successful garbage collection cycles
   - Effective memory defragmentation
   - Proper resource monitoring

3. Error Handling
   - No undefined property access errors
   - Successful emergency recovery
   - Proper state preservation
   - Comprehensive error logging

## Next Steps

1. Implement the changes in phases as outlined above
2. Run comprehensive tests after each phase
3. Monitor system performance during installation
4. Document any new issues or required adjustments

_Updated 05-07-2025 | AI: Cursor (Claude 3.7 Sonnet)_ 