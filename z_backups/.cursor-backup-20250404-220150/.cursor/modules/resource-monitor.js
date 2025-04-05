const os = require('os');
const EventEmitter = require('events');

class ResourceMonitor extends EventEmitter {
  constructor(config = {}) {
    super();
    this.config = {
      memory: {
        warning: 70,
        critical: 85,
        threshold: 95,
        checkInterval: 1000,
        ...config.memory
      },
      cpu: {
        warning: 60,
        critical: 75,
        threshold: 90,
        checkInterval: 1000,
        ...config.cpu
      },
      cooldown: {
        duration: 5000,
        threshold: 80,
        ...config.cooldown
      }
    };
    
    this.monitoring = false;
    this.intervals = new Map();
    this.metrics = new Map();
    this.state = {
      memory: 'normal',
      cpu: 'normal'
    };
  }

  async start() {
    if (this.monitoring) return;
    
    console.log('[Monitor] Starting resource monitoring');
    this.monitoring = true;
    
    // Start memory monitoring
    this.intervals.set('memory', setInterval(() => {
      this._checkMemory();
    }, this.config.memory.checkInterval));
    
    // Start CPU monitoring
    this.intervals.set('cpu', setInterval(() => {
      this._checkCPU();
    }, this.config.cpu.checkInterval));
    
    // Initialize metrics collection
    this.metrics.set('memory', []);
    this.metrics.set('cpu', []);
    
    this.emit('started');
  }

  async stop() {
    if (!this.monitoring) return;
    
    console.log('[Monitor] Stopping resource monitoring');
    this.monitoring = false;
    
    // Clear all monitoring intervals
    for (const interval of this.intervals.values()) {
      clearInterval(interval);
    }
    this.intervals.clear();
    
    // Generate final report
    const report = this.generateReport();
    this.emit('stopped', report);
    
    return report;
  }

  _checkMemory() {
    const used = process.memoryUsage();
    const total = os.totalmem();
    const free = os.freemem();
    
    const usedPercent = (used.heapUsed / total) * 100;
    const timestamp = Date.now();
    
    // Record metric
    const memoryMetrics = this.metrics.get('memory');
    memoryMetrics.push({ usedPercent, timestamp });
    
    // Keep last 1000 measurements
    if (memoryMetrics.length > 1000) {
      memoryMetrics.shift();
    }
    
    // Check thresholds
    const prevState = this.state.memory;
    if (usedPercent >= this.config.memory.threshold) {
      this.state.memory = 'critical';
      this.emit('memory-critical', { usedPercent, threshold: this.config.memory.threshold });
    } else if (usedPercent >= this.config.memory.critical) {
      this.state.memory = 'warning';
      this.emit('memory-warning', { usedPercent, threshold: this.config.memory.critical });
    } else {
      this.state.memory = 'normal';
    }
    
    // Emit state change if needed
    if (prevState !== this.state.memory) {
      this.emit('memory-state-change', {
        from: prevState,
        to: this.state.memory,
        usedPercent
      });
    }
    
    // Emit metric update
    this.emit('memory-metric', { usedPercent, timestamp });
  }

  _checkCPU() {
    const cpus = os.cpus();
    const totalCPU = cpus.reduce((acc, cpu) => {
      const total = Object.values(cpu.times).reduce((a, b) => a + b);
      const used = total - cpu.times.idle;
      return acc + (used / total) * 100;
    }, 0) / cpus.length;
    
    const timestamp = Date.now();
    
    // Record metric
    const cpuMetrics = this.metrics.get('cpu');
    cpuMetrics.push({ usage: totalCPU, timestamp });
    
    // Keep last 1000 measurements
    if (cpuMetrics.length > 1000) {
      cpuMetrics.shift();
    }
    
    // Check thresholds
    const prevState = this.state.cpu;
    if (totalCPU >= this.config.cpu.threshold) {
      this.state.cpu = 'critical';
      this.emit('cpu-critical', { usage: totalCPU, threshold: this.config.cpu.threshold });
    } else if (totalCPU >= this.config.cpu.critical) {
      this.state.cpu = 'warning';
      this.emit('cpu-warning', { usage: totalCPU, threshold: this.config.cpu.critical });
    } else {
      this.state.cpu = 'normal';
    }
    
    // Emit state change if needed
    if (prevState !== this.state.cpu) {
      this.emit('cpu-state-change', {
        from: prevState,
        to: this.state.cpu,
        usage: totalCPU
      });
    }
    
    // Emit metric update
    this.emit('cpu-metric', { usage: totalCPU, timestamp });
  }

  generateReport() {
    const memoryMetrics = this.metrics.get('memory');
    const cpuMetrics = this.metrics.get('cpu');
    
    return {
      timestamp: Date.now(),
      duration: {
        start: memoryMetrics[0]?.timestamp || Date.now(),
        end: Date.now()
      },
      memory: {
        current: this.state.memory,
        metrics: this._analyzeMetrics(memoryMetrics),
        config: this.config.memory
      },
      cpu: {
        current: this.state.cpu,
        metrics: this._analyzeMetrics(cpuMetrics),
        config: this.config.cpu
      },
      recommendations: this._generateRecommendations()
    };
  }

  _analyzeMetrics(metrics) {
    if (!metrics || metrics.length === 0) {
      return {
        min: 0,
        max: 0,
        avg: 0,
        count: 0
      };
    }
    
    const values = metrics.map(m => m.usage || m.usedPercent);
    
    return {
      min: Math.min(...values),
      max: Math.max(...values),
      avg: values.reduce((a, b) => a + b, 0) / values.length,
      count: metrics.length,
      trend: this._calculateTrend(metrics)
    };
  }

  _calculateTrend(metrics) {
    if (metrics.length < 2) return 'stable';
    
    const recent = metrics.slice(-10);
    const values = recent.map(m => m.usage || m.usedPercent);
    const average = values.reduce((a, b) => a + b, 0) / values.length;
    const firstHalf = values.slice(0, 5).reduce((a, b) => a + b, 0) / 5;
    const secondHalf = values.slice(-5).reduce((a, b) => a + b, 0) / 5;
    
    if (Math.abs(secondHalf - firstHalf) < 5) return 'stable';
    return secondHalf > firstHalf ? 'increasing' : 'decreasing';
  }

  _generateRecommendations() {
    const recommendations = [];
    
    // Memory recommendations
    const memoryMetrics = this._analyzeMetrics(this.metrics.get('memory'));
    if (memoryMetrics.trend === 'increasing' && memoryMetrics.avg > this.config.memory.warning) {
      recommendations.push({
        category: 'memory',
        priority: 'high',
        message: 'Memory usage trending upward',
        actions: [
          'Implement memory optimization',
          'Consider increasing memory limits',
          'Review memory-intensive operations'
        ]
      });
    }
    
    // CPU recommendations
    const cpuMetrics = this._analyzeMetrics(this.metrics.get('cpu'));
    if (cpuMetrics.trend === 'increasing' && cpuMetrics.avg > this.config.cpu.warning) {
      recommendations.push({
        category: 'cpu',
        priority: 'high',
        message: 'CPU usage trending upward',
        actions: [
          'Optimize CPU-intensive operations',
          'Consider task scheduling',
          'Review background processes'
        ]
      });
    }
    
    return recommendations;
  }
}

module.exports = { ResourceMonitor }; 