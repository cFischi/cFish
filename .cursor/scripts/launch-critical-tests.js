const { spawn } = require('child_process');
const os = require('os');
const fs = require('fs').promises;
const path = require('path');
const pidtree = require('pidtree');
const si = require('systeminformation');
const {
  memoryConstraintsTests,
  crossPlatformTests,
  performanceTests,
  securityTests
} = require('./test-cases');

// Test configuration
const CONFIG = {
  memoryLimits: {
    perProcess: 128 * 1024 * 1024, // 128MB in bytes (reduced from 256MB)
    totalAllowed: 1.5 * 1024 * 1024 * 1024, // 1.5GB in bytes (reduced from 2GB)
    swapThreshold: 512 * 1024 * 1024 // 512MB in bytes (reduced from 1GB)
  },
  cpuLimits: {
    perProcess: 20, // Reduced from 25%
    totalAllowed: 60, // Reduced from 75%
    throttleThreshold: 75 // Reduced from 85%
  },
  testEnvironments: {
    wordpress: { port: 8080, isolation: 'container', maxMemory: '256m' },
    clickup: { port: 8081, isolation: 'process', maxMemory: '256m' },
    notion: { port: 8082, isolation: 'container', maxMemory: '256m' },
    vendasta: { port: 8083, isolation: 'process', maxMemory: '256m' }
  }
};

// Resource monitoring
class ResourceMonitor {
  constructor() {
    this.metrics = {
      memory: {},
      cpu: {},
      processes: []
    };
    this.warningThresholds = {
      memory: CONFIG.memoryLimits.totalAllowed * 0.8,
      cpu: CONFIG.cpuLimits.totalAllowed * 0.8
    };
    this.cleanupInProgress = false;
  }

  async checkMemory() {
    const mem = await si.mem();
    this.metrics.memory = {
      total: mem.total,
      available: mem.available,
      used: mem.used,
      swapUsed: mem.swapused
    };

    // Proactive warning
    if (mem.used > this.warningThresholds.memory && !this.cleanupInProgress) {
      console.warn('Memory usage approaching limit, initiating proactive cleanup');
      await this.performCleanup();
    }

    return this.metrics.memory;
  }

  async checkCPU() {
    const cpu = await si.currentLoad();
    this.metrics.cpu = {
      currentLoad: cpu.currentLoad,
      avgLoad: cpu.avgLoad
    };

    // Proactive warning
    if (cpu.currentLoad > this.warningThresholds.cpu && !this.cleanupInProgress) {
      console.warn('CPU usage approaching limit, initiating proactive cleanup');
      await this.performCleanup();
    }

    return this.metrics.cpu;
  }

  async checkProcesses() {
    const pids = await pidtree(-1, { root: true });
    const processes = await Promise.all(
      pids.map(async pid => {
        try {
          const proc = await si.processLoad(pid);
          return {
            pid,
            cpu: proc.cpu,
            memory: proc.mem,
            command: proc.command
          };
        } catch (e) {
          return null;
        }
      })
    );
    this.metrics.processes = processes.filter(p => p !== null);
    return this.metrics.processes;
  }

  async performCleanup() {
    this.cleanupInProgress = true;
    try {
      const processes = await this.checkProcesses();
      
      // Sort processes by memory usage
      const sortedByMemory = [...processes].sort((a, b) => b.memory - a.memory);
      
      // Terminate processes exceeding thresholds
      for (const proc of sortedByMemory) {
        if (proc.memory > CONFIG.memoryLimits.perProcess * 0.8 || 
            proc.cpu > CONFIG.cpuLimits.perProcess * 0.8) {
          try {
            process.kill(proc.pid);
            console.log(`Terminated process ${proc.pid} due to resource usage`);
          } catch (e) {
            console.error(`Failed to terminate process ${proc.pid}:`, e);
          }
        }
      }

      // Force garbage collection if available
      if (global.gc) {
        global.gc();
      }
    } finally {
      this.cleanupInProgress = false;
    }
  }

  async enforceResourceLimits() {
    const { memory, cpu, processes } = this.metrics;

    // Check memory limits
    if (memory.used > CONFIG.memoryLimits.totalAllowed) {
      throw new Error(`Total memory usage exceeds limit: ${memory.used} > ${CONFIG.memoryLimits.totalAllowed}`);
    }

    // Check CPU limits
    if (cpu.currentLoad > CONFIG.cpuLimits.totalAllowed) {
      throw new Error(`Total CPU usage exceeds limit: ${cpu.currentLoad}% > ${CONFIG.cpuLimits.totalAllowed}%`);
    }

    // Check per-process limits
    for (const proc of processes) {
      if (proc.memory > CONFIG.memoryLimits.perProcess) {
        throw new Error(`Process ${proc.pid} memory exceeds limit: ${proc.memory} > ${CONFIG.memoryLimits.perProcess}`);
      }
      if (proc.cpu > CONFIG.cpuLimits.perProcess) {
        throw new Error(`Process ${proc.pid} CPU exceeds limit: ${proc.cpu}% > ${CONFIG.cpuLimits.perProcess}%`);
      }
    }
  }
}

// Test execution
class TestRunner {
  constructor() {
    this.monitor = new ResourceMonitor();
    this.results = [];
  }

  async runTest(name, fn) {
    console.log(`Running test: ${name}`);
    try {
      // Check resources before test
      await this.monitor.checkMemory();
      await this.monitor.checkCPU();
      await this.monitor.checkProcesses();
      await this.monitor.enforceResourceLimits();

      // Run the test
      const startTime = Date.now();
      await fn();
      const duration = Date.now() - startTime;

      // Check resources after test
      await this.monitor.checkMemory();
      await this.monitor.checkCPU();
      await this.monitor.checkProcesses();
      await this.monitor.enforceResourceLimits();

      this.results.push({
        name,
        status: 'passed',
        duration,
        metrics: {
          memory: this.monitor.metrics.memory,
          cpu: this.monitor.metrics.cpu
        }
      });
      console.log(`✓ Test passed: ${name} (${duration}ms)`);
    } catch (error) {
      this.results.push({
        name,
        status: 'failed',
        error: error.message,
        metrics: {
          memory: this.monitor.metrics.memory,
          cpu: this.monitor.metrics.cpu
        }
      });
      console.error(`✗ Test failed: ${name}\n`, error);
    }
  }

  async saveResults() {
    const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
    const resultsPath = path.join(__dirname, '..', 'test-metrics', `results-${timestamp}.json`);
    await fs.writeFile(resultsPath, JSON.stringify(this.results, null, 2));
    console.log(`Results saved to: ${resultsPath}`);
  }
}

// Main test execution
async function runLaunchCriticalTests() {
  const runner = new TestRunner();

  // System Resource Management Tests
  await runner.runTest('Memory Constraints', async () => {
    await memoryConstraintsTests();
  });

  // Cross-Platform Integration Tests
  await runner.runTest('Cross-Platform Integration', async () => {
    await crossPlatformTests();
  });

  // Performance Optimization Tests
  await runner.runTest('Performance Optimization', async () => {
    await performanceTests();
  });

  // Security Implementation Tests
  await runner.runTest('Security Implementation', async () => {
    await securityTests();
  });

  await runner.saveResults();
}

// Run tests if called directly
if (require.main === module) {
  runLaunchCriticalTests().catch(console.error);
}

module.exports = {
  ResourceMonitor,
  TestRunner,
  runLaunchCriticalTests
}; 