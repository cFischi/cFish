const os = require('os');
const fs = require('fs').promises;
const path = require('path');
const EventEmitter = require('events');

class ResourceMonitor extends EventEmitter {
  constructor(options = {}) {
    super();
    this.options = {
      interval: 1000,
      cpuThreshold: 80,
      memoryThreshold: 90,
      ...options
    };
    this.history = {
      cpu: [],
      memory: [],
      disk: []
    };
    this.isMonitoring = false;
  }

  async startMonitoring() {
    console.log('Starting resource monitoring...');
    
    this.isMonitoring = true;
    this.monitoringInterval = setInterval(() => {
      this.checkResources();
    }, this.options.interval);

    console.log('Resource monitoring started');
  }

  async stopMonitoring() {
    console.log('Stopping resource monitoring...');
    
    if (this.monitoringInterval) {
      clearInterval(this.monitoringInterval);
    }
    
    this.isMonitoring = false;
    console.log('Resource monitoring stopped');
  }

  async checkResources() {
    try {
      const cpuUsage = await this.getCPUUsage();
      const memoryUsage = this.getMemoryUsage();
      const diskUsage = await this.getDiskUsage();

      const metrics = {
        timestamp: new Date().toISOString(),
        cpu: cpuUsage,
        memory: memoryUsage,
        disk: diskUsage
      };

      // Store in history
      this.history.cpu.push(cpuUsage);
      this.history.memory.push(memoryUsage);
      this.history.disk.push(diskUsage);

      // Keep history size manageable
      if (this.history.cpu.length > 100) {
        this.history.cpu.shift();
        this.history.memory.shift();
        this.history.disk.shift();
      }

      // Check thresholds and emit events
      if (cpuUsage > this.options.cpuThreshold) {
        this.emit('highCPU', cpuUsage);
      }

      if (memoryUsage.percentUsed > this.options.memoryThreshold) {
        this.emit('highMemory', memoryUsage);
      }

      this.emit('metrics', metrics);
    } catch (error) {
      console.error('Error checking resources:', error);
      this.emit('error', error);
    }
  }

  async getCPUUsage() {
    return new Promise((resolve) => {
      const startMeasure = os.cpus().map(cpu => ({
        idle: cpu.times.idle,
        total: Object.values(cpu.times).reduce((acc, val) => acc + val, 0)
      }));

      setTimeout(() => {
        const endMeasure = os.cpus().map(cpu => ({
          idle: cpu.times.idle,
          total: Object.values(cpu.times).reduce((acc, val) => acc + val, 0)
        }));

        const cpuUsage = startMeasure.map((start, i) => {
          const end = endMeasure[i];
          const idleDiff = end.idle - start.idle;
          const totalDiff = end.total - start.total;
          const usagePercent = 100 - (100 * idleDiff / totalDiff);
          return Math.round(usagePercent * 100) / 100;
        });

        const averageUsage = cpuUsage.reduce((acc, val) => acc + val, 0) / cpuUsage.length;
        resolve(Math.round(averageUsage * 100) / 100);
      }, 100);
    });
  }

  getMemoryUsage() {
    const total = os.totalmem();
    const free = os.freemem();
    const used = total - free;
    const percentUsed = Math.round((used / total) * 100 * 100) / 100;

    return {
      total: Math.round(total / 1024 / 1024),  // MB
      free: Math.round(free / 1024 / 1024),    // MB
      used: Math.round(used / 1024 / 1024),    // MB
      percentUsed
    };
  }

  async getDiskUsage() {
    // Note: This is a simplified version. For production, you'd want to use a package
    // like 'diskusage' for more accurate cross-platform disk metrics
    return {
      timestamp: new Date().toISOString(),
      // Placeholder for actual disk metrics
      percentUsed: 0,
      available: 0,
      total: 0
    };
  }

  async getCurrentUsage() {
    const cpu = await this.getCPUUsage();
    const memory = this.getMemoryUsage();
    const disk = await this.getDiskUsage();

    return {
      timestamp: new Date().toISOString(),
      cpu,
      memory,
      disk
    };
  }

  getResourceHistory() {
    return {
      cpu: {
        average: this.calculateAverage(this.history.cpu),
        max: Math.max(...this.history.cpu),
        min: Math.min(...this.history.cpu),
        current: this.history.cpu[this.history.cpu.length - 1]
      },
      memory: {
        average: this.calculateAverage(this.history.memory.map(m => m.percentUsed)),
        max: Math.max(...this.history.memory.map(m => m.percentUsed)),
        min: Math.min(...this.history.memory.map(m => m.percentUsed)),
        current: this.history.memory[this.history.memory.length - 1]
      }
    };
  }

  calculateAverage(values) {
    if (!values || values.length === 0) return 0;
    return Math.round(values.reduce((a, b) => a + b, 0) / values.length * 100) / 100;
  }

  async generateReport() {
    const currentUsage = await this.getCurrentUsage();
    const history = this.getResourceHistory();

    return {
      timestamp: new Date().toISOString(),
      current: currentUsage,
      history,
      status: this.isMonitoring ? 'active' : 'stopped',
      thresholds: {
        cpu: this.options.cpuThreshold,
        memory: this.options.memoryThreshold
      }
    };
  }
}

module.exports = { ResourceMonitor }; 