const fs = require('fs').promises;
const path = require('path');
const os = require('os');

class TestMetricsCollector {
  constructor(options = {}) {
    this.options = {
      metricsDir: path.join(__dirname, '../test-metrics'),
      retentionDays: 30,
      aggregationInterval: 1000,
      warningThreshold: 70,
      criticalThreshold: 90,
      ...options
    };

    this.metrics = {
      tests: {
        total: 0,
        passed: 0,
        failed: 0,
        skipped: 0,
        duration: 0
      },
      coverage: {
        statements: 0,
        branches: 0,
        functions: 0,
        lines: 0
      },
      performance: {
        memory: {
          usage: 0,
          peak: 0,
          allocated: 0
        },
        cpu: {
          usage: 0,
          peak: 0
        },
        timing: {
          setup: 0,
          execution: 0,
          cleanup: 0,
          total: 0
        }
      },
      resources: {
        initialMemory: 0,
        finalMemory: 0,
        peakMemory: 0,
        initialCpu: 0,
        finalCpu: 0,
        peakCpu: 0
      },
      warnings: [],
      errors: [],
      startTime: null,
      endTime: null
    };

    this.isCollecting = false;
    this.aggregationInterval = null;
  }

  async initialize() {
    try {
      await fs.mkdir(this.options.metricsDir, { recursive: true });
      console.log('Metrics directory initialized:', this.options.metricsDir);
    } catch (error) {
      console.error('Failed to initialize metrics directory:', error);
      throw error;
    }
  }

  async startCollection() {
    if (this.isCollecting) {
      console.warn('Metrics collection already in progress');
      return;
    }

    try {
      await this.initialize();
      this.isCollecting = true;
      this.metrics.startTime = Date.now();
      this.metrics.resources.initialMemory = process.memoryUsage().heapUsed;
      this.metrics.resources.initialCpu = process.cpuUsage();

      // Start periodic metrics collection
      this.aggregationInterval = setInterval(() => {
        this.collectResourceMetrics();
      }, this.options.aggregationInterval);

      console.log('Started metrics collection');
    } catch (error) {
      console.error('Failed to start metrics collection:', error);
      throw error;
    }
  }

  async stopCollection() {
    if (!this.isCollecting) {
      console.warn('No metrics collection in progress');
      return;
    }

    try {
      clearInterval(this.aggregationInterval);
      this.isCollecting = false;
      this.metrics.endTime = Date.now();
      this.metrics.resources.finalMemory = process.memoryUsage().heapUsed;
      this.metrics.resources.finalCpu = process.cpuUsage(this.metrics.resources.initialCpu);
      
      await this.saveMetrics();
      console.log('Stopped metrics collection');
    } catch (error) {
      console.error('Failed to stop metrics collection:', error);
      throw error;
    }
  }

  collectResourceMetrics() {
    const memoryUsage = process.memoryUsage();
    const cpuUsage = process.cpuUsage();

    // Update memory metrics
    this.metrics.performance.memory.usage = memoryUsage.heapUsed;
    this.metrics.performance.memory.allocated = memoryUsage.heapTotal;
    if (memoryUsage.heapUsed > this.metrics.performance.memory.peak) {
      this.metrics.performance.memory.peak = memoryUsage.heapUsed;
    }
    if (memoryUsage.heapUsed > this.metrics.resources.peakMemory) {
      this.metrics.resources.peakMemory = memoryUsage.heapUsed;
    }

    // Update CPU metrics
    const totalCpu = cpuUsage.user + cpuUsage.system;
    this.metrics.performance.cpu.usage = totalCpu;
    if (totalCpu > this.metrics.performance.cpu.peak) {
      this.metrics.performance.cpu.peak = totalCpu;
    }

    // Check thresholds
    const memoryPercent = (memoryUsage.heapUsed / memoryUsage.heapTotal) * 100;
    if (memoryPercent >= this.options.criticalThreshold) {
      this.metrics.warnings.push({
        timestamp: Date.now(),
        type: 'memory',
        level: 'critical',
        message: `Memory usage critical: ${memoryPercent.toFixed(2)}%`
      });
    } else if (memoryPercent >= this.options.warningThreshold) {
      this.metrics.warnings.push({
        timestamp: Date.now(),
        type: 'memory',
        level: 'warning',
        message: `Memory usage high: ${memoryPercent.toFixed(2)}%`
      });
    }
  }

  recordTestResult(result) {
    this.metrics.tests.total++;
    if (result.status === 'passed') {
      this.metrics.tests.passed++;
    } else if (result.status === 'failed') {
      this.metrics.tests.failed++;
      this.metrics.errors.push({
        timestamp: Date.now(),
        test: result.name,
        error: result.error
      });
    } else if (result.status === 'skipped') {
      this.metrics.tests.skipped++;
    }

    this.metrics.tests.duration += result.duration || 0;
  }

  recordCoverage(coverage) {
    this.metrics.coverage = {
      statements: coverage.statements.pct,
      branches: coverage.branches.pct,
      functions: coverage.functions.pct,
      lines: coverage.lines.pct
    };
  }

  recordTiming(phase, duration) {
    this.metrics.performance.timing[phase] = duration;
    this.metrics.performance.timing.total += duration;
  }

  async saveMetrics() {
    try {
      const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
      const metricsFile = path.join(this.options.metricsDir, `metrics-${timestamp}.json`);
      
      await fs.writeFile(
        metricsFile,
        JSON.stringify(this.metrics, null, 2),
        'utf8'
      );

      console.log('Metrics saved to:', metricsFile);
      await this.cleanupOldMetrics();
    } catch (error) {
      console.error('Failed to save metrics:', error);
      throw error;
    }
  }

  async cleanupOldMetrics() {
    try {
      const files = await fs.readdir(this.options.metricsDir);
      const now = Date.now();
      const maxAge = this.options.retentionDays * 24 * 60 * 60 * 1000;

      for (const file of files) {
        const filePath = path.join(this.options.metricsDir, file);
        const stats = await fs.stat(filePath);
        const age = now - stats.mtime.getTime();

        if (age > maxAge) {
          await fs.unlink(filePath);
          console.log('Removed old metrics file:', file);
        }
      }
    } catch (error) {
      console.error('Failed to cleanup old metrics:', error);
      // Don't throw - cleanup failure shouldn't break the main process
    }
  }

  async generateSummaryReport() {
    const duration = this.metrics.endTime - this.metrics.startTime;
    const memoryDelta = this.metrics.resources.finalMemory - this.metrics.resources.initialMemory;
    const memoryPeakDelta = this.metrics.resources.peakMemory - this.metrics.resources.initialMemory;

    return {
      timestamp: new Date().toISOString(),
      duration: duration,
      tests: {
        total: this.metrics.tests.total,
        passed: this.metrics.tests.passed,
        failed: this.metrics.tests.failed,
        skipped: this.metrics.tests.skipped,
        successRate: (this.metrics.tests.passed / this.metrics.tests.total * 100).toFixed(2) + '%'
      },
      coverage: {
        statements: this.metrics.coverage.statements.toFixed(2) + '%',
        branches: this.metrics.coverage.branches.toFixed(2) + '%',
        functions: this.metrics.coverage.functions.toFixed(2) + '%',
        lines: this.metrics.coverage.lines.toFixed(2) + '%'
      },
      performance: {
        memory: {
          initial: this.formatBytes(this.metrics.resources.initialMemory),
          final: this.formatBytes(this.metrics.resources.finalMemory),
          peak: this.formatBytes(this.metrics.resources.peakMemory),
          delta: this.formatBytes(memoryDelta),
          peakDelta: this.formatBytes(memoryPeakDelta)
        },
        timing: {
          setup: this.metrics.performance.timing.setup + 'ms',
          execution: this.metrics.performance.timing.execution + 'ms',
          cleanup: this.metrics.performance.timing.cleanup + 'ms',
          total: this.metrics.performance.timing.total + 'ms'
        }
      },
      issues: {
        warnings: this.metrics.warnings.length,
        errors: this.metrics.errors.length
      }
    };
  }

  formatBytes(bytes) {
    const units = ['B', 'KB', 'MB', 'GB'];
    let size = bytes;
    let unitIndex = 0;

    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    return `${size.toFixed(2)} ${units[unitIndex]}`;
  }
}

module.exports = TestMetricsCollector; 