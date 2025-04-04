const EventEmitter = require('events');
const fs = require('fs').promises;
const path = require('path');
const cliProgress = require('cli-progress');
const colors = require('colors');
const moment = require('moment');
const os = require('os');
const EnhancedResourceMonitor = require('./enhanced-resource-monitor');

class InstallProgressMonitor extends EventEmitter {
  constructor(config = {}) {
    super();
    this.config = {
      logFile: path.join(__dirname, '../logs/install-progress.log'),
      statsFile: path.join(__dirname, '../logs/install-stats.json'),
      detailedLogging: true,
      showResourceMetrics: config.showResourceMetrics || true,
      updateInterval: config.updateInterval || 1000,
      format: config.format || '{bar} {percentage}% | {stage}: {value}/{total} | {status}',
      ...config
    };

    this.stats = {
      startTime: Date.now(),
      totalPackages: 0,
      completed: 0,
      failed: 0,
      retries: 0,
      emergencies: 0,
      resourceWarnings: 0,
      avgMemoryUsage: 0,
      peakMemoryUsage: 0,
      memoryReadings: [],
      timeouts: 0,
      cleanups: 0,
      lastEmergency: null,
      packageStats: new Map()
    };

    this.bars = new Map();
    this.active = false;
    this.startTime = null;
    this.resourceMonitor = new EnhancedResourceMonitor({
      warningThreshold: 70,
      criticalThreshold: 80,
      updateInterval: this.config.updateInterval
    });

    this.initialize();
  }

  async initialize() {
    await fs.mkdir(path.dirname(this.config.logFile), { recursive: true });
    await this.log('Installation monitoring started');

    if (this.config.showResourceMetrics) {
      await this.resourceMonitor.initialize();
      await this.resourceMonitor.start();
    }
  }

  async log(message, type = 'info') {
    const timestamp = new Date().toISOString();
    const logEntry = `[${timestamp}] [${type.toUpperCase()}] ${message}\n`;
    
    await fs.appendFile(this.config.logFile, logEntry).catch(err => {
      console.error('Error writing to log:', err);
    });

    if (type === 'emergency' || type === 'error') {
      console.error(logEntry.trim());
    } else {
      console.log(logEntry.trim());
    }
  }

  recordPackageStart(packageName) {
    const stats = {
      startTime: Date.now(),
      retries: 0,
      warnings: 0,
      peakMemory: 0,
      status: 'installing'
    };
    this.stats.packageStats.set(packageName, stats);
    this.emit('packageStart', packageName);
  }

  recordPackageComplete(packageName, success = true) {
    const pkgStats = this.stats.packageStats.get(packageName);
    if (pkgStats) {
      pkgStats.endTime = Date.now();
      pkgStats.duration = pkgStats.endTime - pkgStats.startTime;
      pkgStats.status = success ? 'completed' : 'failed';
      
      this.stats[success ? 'completed' : 'failed']++;
      this.saveStats();
      
      this.emit('packageComplete', {
        package: packageName,
        success,
        stats: pkgStats
      });
    }
  }

  recordResourceWarning(type, value) {
    this.stats.resourceWarnings++;
    this.log(`Resource warning: ${type} at ${value}%`, 'warning');
    this.emit('resourceWarning', { type, value });
  }

  recordEmergency(memoryUsage) {
    this.stats.emergencies++;
    this.stats.lastEmergency = Date.now();
    this.log(`Emergency triggered at ${memoryUsage}% memory usage`, 'emergency');
    this.emit('emergency', { memoryUsage });
  }

  recordMemoryUsage(usage) {
    this.stats.memoryReadings.push(usage);
    if (this.stats.memoryReadings.length > 100) {
      this.stats.memoryReadings.shift();
    }
    
    this.stats.avgMemoryUsage = this.stats.memoryReadings.reduce((a, b) => a + b, 0) / this.stats.memoryReadings.length;
    this.stats.peakMemoryUsage = Math.max(this.stats.peakMemoryUsage, usage);
    
    this.emit('memoryUpdate', {
      current: usage,
      average: this.stats.avgMemoryUsage,
      peak: this.stats.peakMemoryUsage
    });
  }

  recordCleanup(aggressive = false) {
    this.stats.cleanups++;
    this.log(`Resource cleanup performed (${aggressive ? 'aggressive' : 'normal'})`, 'info');
    this.emit('cleanup', { aggressive });
  }

  getProgress() {
    return {
      completed: this.stats.completed,
      failed: this.stats.failed,
      total: this.stats.totalPackages,
      duration: Date.now() - this.stats.startTime,
      memoryStats: {
        current: this.stats.memoryReadings[this.stats.memoryReadings.length - 1] || 0,
        average: this.stats.avgMemoryUsage,
        peak: this.stats.peakMemoryUsage
      },
      incidents: {
        emergencies: this.stats.emergencies,
        warnings: this.stats.resourceWarnings,
        cleanups: this.stats.cleanups
      }
    };
  }

  async saveStats() {
    try {
      const statsData = {
        ...this.stats,
        packageStats: Object.fromEntries(this.stats.packageStats)
      };
      
      await fs.writeFile(
        this.config.statsFile,
        JSON.stringify(statsData, null, 2)
      );
    } catch (err) {
      console.error('Error saving stats:', err);
    }
  }

  createStageBar(name, total) {
    const bar = new cliProgress.SingleBar({
      format: `{bar} {percentage}% | ${name}: {value}/{total} | {status}`,
      barCompleteChar: '█',
      barIncompleteChar: '░',
      hideCursor: true,
      clearOnComplete: false,
      stopOnComplete: true
    });

    bar.start(total, 0, { status: 'Starting...' });
    this.bars.set(name, { bar, total, current: 0 });
  }

  updateProgress(value, status = '') {
    for (const [name, data] of this.bars) {
      data.current = value;
      data.bar.update(value, { status });
      if (value >= data.total) {
        data.bar.stop();
      }
    }
  }

  updateResourceMetrics(metrics) {
    if (this.config.showResourceMetrics && this.active) {
      const { memory, cpu } = metrics;
      console.log(
        `\nResource Usage - Memory: ${colors.yellow(memory.toFixed(1))}% | CPU: ${colors.yellow(cpu.toFixed(1))}%`
      );
    }
  }

  async getResourceMetrics() {
    if (!this.config.showResourceMetrics) return null;
    return await this.resourceMonitor.getMetrics();
  }

  getElapsedTime() {
    if (!this.startTime) return '0:00';
    return moment.duration(Date.now() - this.startTime).humanize();
  }

  async start() {
    if (this.active) return;

    console.log('\nInitializing installation progress monitor...\n');
    console.log('System Resources:');
    
    this.active = true;
    this.startTime = Date.now();

    if (this.config.showResourceMetrics) {
      await this.resourceMonitor.initialize();
      await this.resourceMonitor.start();
    }
  }

  async stop() {
    if (!this.active) return;

    for (const { bar } of this.bars.values()) {
      bar.stop();
    }
    this.bars.clear();

    if (this.config.showResourceMetrics) {
      await this.resourceMonitor.stop();
    }

    this.active = false;
  }

  getStatus() {
    const status = {
      elapsedTime: this.getElapsedTime(),
      stages: {}
    };

    for (const [name, data] of this.bars) {
      status.stages[name] = {
        completed: data.current,
        total: data.total,
        percentage: ((data.current / data.total) * 100).toFixed(1)
      };
    }

    return status;
  }
}

module.exports = InstallProgressMonitor; 