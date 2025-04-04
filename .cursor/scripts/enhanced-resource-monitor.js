const os = require('os');
const fs = require('fs').promises;
const path = require('path');
const moment = require('moment');
const EventEmitter = require('events');
const { execFile } = require('child_process');
const util = require('util');
const execFileAsync = util.promisify(execFile);

class EnhancedResourceMonitor extends EventEmitter {
  constructor(config = {}) {
    super();
    
    this.config = {
      warningThreshold: config.warningThreshold || 70,
      criticalThreshold: config.criticalThreshold || 80,
      updateInterval: config.updateInterval || 1000,
      predictionWindow: config.predictionWindow || 5,
      historyLength: config.historyLength || 60, // Keep 60 data points
      metricsDir: config.metricsDir || path.join(__dirname, '../metrics'),
      stateFile: config.stateFile || path.join(__dirname, '../metrics/monitor-state.json'),
      isWindows: process.platform === 'win32',
      processCheckInterval: config.processCheckInterval || 5000,
      ...config
    };

    this.metrics = {
      memory: 0,
      cpu: 0,
      total: {
        memory: os.totalmem(),
        free: '0GB',
        used: '0GB',
        percentUsed: 0
      },
      processes: {
        total: 0,
        active: 0,
        memory: 0
      }
    };

    this.warnings = [];
    this.monitorId = null;
    this.initialized = false;
    this.monitoring = false;
    this.intervalId = null;
    this.processCheckId = null;
    this.lastWarning = 0;
    this.warningCooldown = 5000; // 5 seconds between warnings
    this.activeProcesses = new Map(); // Track active processes
  }

  async initialize() {
    if (this.initialized) return;

    await fs.mkdir(this.config.metricsDir, { recursive: true });
    
    // Restore previous state if exists
    await this.restoreState();

    this.metricsFile = path.join(
      this.config.metricsDir,
      `metrics-${moment().format('YYYYMMDD-HHmmss')}.json`
    );

    // Windows-specific initialization
    if (this.config.isWindows) {
      try {
        // Ensure Windows performance counters are available
        const { execSync } = require('child_process');
        execSync('typeperf "\\Processor(_Total)\\% Processor Time" -sc 1', { stdio: 'ignore' });
        
        // Set Windows-specific thresholds
        this.config.warningThreshold = Math.min(this.config.warningThreshold, 70); // More conservative for Windows
        this.config.criticalThreshold = Math.min(this.config.criticalThreshold, 80);
        
        console.log('Windows performance monitoring initialized');
      } catch (error) {
        console.warn('Windows performance counters not available:', error.message);
      }
    }

    // Initial resource check
    const initialMetrics = await this.getResourceMetrics();
    console.log('Initial resource metrics:', initialMetrics);

    this.initialized = true;
    return initialMetrics;
  }

  async saveState() {
    try {
      const state = {
        metrics: this.metrics,
        warnings: this.warnings,
        timestamp: Date.now(),
        processId: process.pid
      };

      const tempFile = `${this.config.stateFile}.tmp`;
      await fs.writeFile(tempFile, JSON.stringify(state, null, 2));
      await fs.rename(tempFile, this.config.stateFile);
    } catch (error) {
      console.error('Error saving monitor state:', error);
    }
  }

  async restoreState() {
    try {
      const data = await fs.readFile(this.config.stateFile, 'utf8');
      const state = JSON.parse(data);
      
      // Only restore state if it's from the same process or less than 5 minutes old
      const isRecent = (Date.now() - state.timestamp) < 300000;
      const isSameProcess = state.processId === process.pid;
      
      if (isRecent || isSameProcess) {
        this.metrics = state.metrics;
        this.warnings = state.warnings;
        console.log('Restored previous monitor state');
      }
    } catch (error) {
      if (error.code !== 'ENOENT') {
        console.warn('Error restoring monitor state:', error);
      }
    }
  }

  async start() {
    if (this.monitoring) {
      console.log('Resource monitor already running');
      return;
    }

    this.monitoring = true;
    
    // Resource monitoring interval
    this.intervalId = setInterval(async () => {
      await this.getResourceMetrics();
      this.emit('update', this.metrics);
    }, this.config.updateInterval);

    // Process monitoring interval
    this.processCheckId = setInterval(async () => {
      await this.checkProcesses();
    }, this.config.processCheckInterval);

    console.log('Resource and process monitoring started');
  }

  async stop() {
    if (!this.monitoring) {
      return;
    }

    clearInterval(this.intervalId);
    clearInterval(this.processCheckId);
    this.monitoring = false;
    this.intervalId = null;
    this.processCheckId = null;
    
    // Save final state
    await this.saveState();
    
    console.log('Resource and process monitoring stopped');
  }

  async getMetrics() {
    return this.metrics;
  }

  async getResourceMetrics() {
    const totalMem = os.totalmem();
    const freeMem = os.freemem();
    const usedMem = totalMem - freeMem;
    const percentUsed = (usedMem / totalMem) * 100;

    this.metrics = {
      memory: percentUsed,
      cpu: os.loadavg()[0],
      total: {
        memory: totalMem,
        free: `${(freeMem / 1024 / 1024 / 1024).toFixed(2)}GB`,
        used: `${(usedMem / 1024 / 1024 / 1024).toFixed(2)}GB`,
        percentUsed: percentUsed
      },
      processes: {
        total: 0,
        active: 0,
        memory: 0
      }
    };

    return this.metrics;
  }

  async getMemoryUsage() {
    const metrics = await this.getResourceMetrics();
    return metrics.memory;
  }

  async getCpuUsage() {
    const metrics = await this.getResourceMetrics();
    return metrics.cpu;
  }

  formatBytes(bytes) {
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    let size = bytes;
    let unitIndex = 0;
    
    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }
    
    return `${size.toFixed(2)}${units[unitIndex]}`;
  }

  addListener(callback) {
    this.on('update', callback);
  }

  removeListener(callback) {
    this.off('update', callback);
  }

  checkResources() {
    // Update metrics
    this.updateMemoryMetrics();
    this.updateCpuMetrics();
    this.updateHeapMetrics();

    // Analyze trends and predict thresholds
    this.analyzeTrends();

    // Generate warnings
    this.generateWarnings();

    // Emit update event with analysis
    this.emit('update', this.getAnalysis());
  }

  updateMemoryMetrics() {
    const totalMemory = os.totalmem();
    const freeMemory = os.freemem();
    const usedMemory = totalMemory - freeMemory;
    const memoryUsage = (usedMemory / totalMemory) * 100;

    this.updateMetric('memory', memoryUsage);
  }

  updateCpuMetrics() {
    const currentCpuInfo = os.cpus().map(cpu => ({
      idle: cpu.times.idle,
      total: Object.values(cpu.times).reduce((acc, time) => acc + time, 0)
    }));

    const cpuUsage = currentCpuInfo.map((cpu, i) => {
      const idleDiff = cpu.idle - this.lastCpuInfo[i].idle;
      const totalDiff = cpu.total - this.lastCpuInfo[i].total;
      return 100 - (idleDiff / totalDiff) * 100;
    });

    this.lastCpuInfo = currentCpuInfo;
    this.updateMetric('cpu', cpuUsage.reduce((acc, usage) => acc + usage, 0) / cpuUsage.length);
  }

  updateHeapMetrics() {
    const heap = process.memoryUsage();
    const heapUsage = (heap.heapUsed / heap.heapTotal) * 100;
    this.updateMetric('heap', heapUsage);
  }

  updateMetric(name, value) {
    const metric = this.metrics[name];
    metric.history.push(value);
    if (metric.history.length > this.config.historyLength) {
      metric.history.shift();
    }
    metric.current = value;
  }

  analyzeTrends() {
    for (const [name, metric] of Object.entries(this.metrics)) {
      if (metric.history.length < 2) continue;

      // Calculate trend using linear regression
      const xValues = Array.from({ length: metric.history.length }, (_, i) => i);
      const yValues = metric.history;
      
      const n = xValues.length;
      const sumX = xValues.reduce((a, b) => a + b, 0);
      const sumY = yValues.reduce((a, b) => a + b, 0);
      const sumXY = xValues.reduce((acc, x, i) => acc + x * yValues[i], 0);
      const sumXX = xValues.reduce((acc, x) => acc + x * x, 0);
      
      const slope = (n * sumXY - sumX * sumY) / (n * sumXX - sumX * sumX);
      metric.trend = slope;

      // Predict time to thresholds
      if (slope > 0) {
        const currentValue = metric.current;
        metric.timeToThreshold.warning = slope !== 0 ? 
          Math.ceil((this.config.warningThreshold - currentValue) / slope) : null;
        metric.timeToThreshold.critical = slope !== 0 ? 
          Math.ceil((this.config.criticalThreshold - currentValue) / slope) : null;
      } else {
        metric.timeToThreshold.warning = null;
        metric.timeToThreshold.critical = null;
      }
    }
  }

  generateWarnings() {
    this.warnings = [];

    for (const [name, metric] of Object.entries(this.metrics)) {
      if (metric.current >= this.config.criticalThreshold) {
        this.warnings.push({
          level: 'critical',
          resource: name,
          value: metric.current,
          message: `${name} usage critical: ${metric.current.toFixed(2)}%`
        });
      } else if (metric.current >= this.config.warningThreshold) {
        this.warnings.push({
          level: 'warning',
          resource: name,
          value: metric.current,
          message: `${name} usage high: ${metric.current.toFixed(2)}%`
        });
      }

      // Add predictive warnings
      if (metric.timeToThreshold.critical !== null && metric.timeToThreshold.critical <= this.config.predictionWindow) {
        this.warnings.push({
          level: 'warning',
          resource: name,
          value: metric.current,
          message: `${name} usage predicted to reach critical in ${metric.timeToThreshold.critical} intervals`
        });
      }
    }
  }

  getAnalysis() {
    return {
      metrics: this.metrics,
      warnings: this.warnings,
      timestamp: Date.now()
    };
  }

  getStatus() {
    return {
      monitoring: this.monitoring,
      metrics: this.metrics,
      thresholds: {
        warning: this.config.warningThreshold,
        critical: this.config.criticalThreshold
      }
    };
  }

  // Windows-specific CPU monitoring
  async getWindowsCpuUsage() {
    if (!this.config.isWindows) return null;
    
    try {
      const psCommand = `
        (Get-WmiObject Win32_Processor).LoadPercentage
      `;
      
      const { stdout } = await execFileAsync('powershell', ['-Command', psCommand]);
      const cpuUsage = parseFloat(stdout.trim());
      return isNaN(cpuUsage) ? null : cpuUsage;
    } catch (error) {
      console.warn('Error getting Windows CPU usage with PowerShell:', error.message);
      // Fallback to typeperf
      return await this.getWindowsCpuUsageBasic();
    }
  }

  async getWindowsCpuUsageBasic() {
    try {
      const { execSync } = require('child_process');
      const result = execSync('typeperf "\\Processor(_Total)\\% Processor Time" -sc 1', { encoding: 'utf8' });
      const lines = result.trim().split('\n');
      if (lines.length >= 2) {
        const values = lines[1].split(',');
        if (values.length >= 2) {
          return parseFloat(values[1].replace(/["\r]/g, ''));
        }
      }
    } catch (error) {
      console.warn('Error getting Windows CPU usage with typeperf:', error.message);
    }
    return null;
  }

  isMemoryWarning() {
    return this.metrics.memory >= this.config.warningThreshold;
  }

  isMemoryCritical() {
    return this.metrics.memory >= this.config.criticalThreshold;
  }

  async getProcessList() {
    try {
      if (this.config.isWindows) {
        return await this.getWindowsProcesses();
      }
      return await this.getUnixProcesses();
    } catch (error) {
      console.error('Error getting process list:', error);
      return [];
    }
  }

  async getWindowsProcesses() {
    try {
      // PowerShell command to get detailed process information
      const psCommand = `
        Get-Process | Select-Object Name, Id, CPU, WorkingSet, Path, StartTime |
        ConvertTo-Csv -NoTypeInformation
      `;
      
      const { stdout } = await execFileAsync('powershell', ['-Command', psCommand]);
      
      const processes = stdout.split('\n')
        .slice(1) // Skip header
        .filter(line => line.trim())
        .map(line => {
          const [name, pid, cpu, workingSet, path, startTime] = line.replace(/"/g, '').split(',');
          return {
            name: name.trim(),
            pid: parseInt(pid),
            cpu: parseFloat(cpu || 0),
            memory: parseInt(workingSet || 0),
            path: path?.trim() || '',
            startTime: startTime ? new Date(startTime) : null,
            uptime: startTime ? (Date.now() - new Date(startTime).getTime()) : 0
          };
        })
        .filter(proc => proc.pid > 0); // Filter out invalid processes

      // Enhanced metrics calculation
      const totalMemory = os.totalmem();
      const processMetrics = {
        count: processes.length,
        totalMemory: processes.reduce((sum, p) => sum + p.memory, 0),
        memoryPercent: (processes.reduce((sum, p) => sum + p.memory, 0) / totalMemory) * 100,
        topMemoryUsers: processes
          .sort((a, b) => b.memory - a.memory)
          .slice(0, 5)
          .map(p => ({ name: p.name, pid: p.pid, memory: this.formatBytes(p.memory) })),
        topCpuUsers: processes
          .sort((a, b) => b.cpu - a.cpu)
          .slice(0, 5)
          .map(p => ({ name: p.name, pid: p.pid, cpu: p.cpu.toFixed(1) }))
      };

      // Update process metrics
      this.metrics.processes = {
        ...this.metrics.processes,
        ...processMetrics
      };

      return processes;
    } catch (error) {
      console.error('Error getting Windows processes with PowerShell:', error);
      // Fallback to basic tasklist if PowerShell fails
      return this.getWindowsProcessesBasic();
    }
  }

  async getWindowsProcessesBasic() {
    try {
      const { stdout } = await execFileAsync('tasklist', ['/FO', 'CSV', '/NH']);
      const processes = stdout.split('\n')
        .filter(line => line.trim())
        .map(line => {
          const [name, pid, ...rest] = line.replace(/"/g, '').split(',');
          return {
            name: name.trim(),
            pid: parseInt(pid.trim()),
            memory: parseInt(rest[3]?.replace(/[^\d]/g, '') || 0)
          };
        });
      return processes;
    } catch (error) {
      console.error('Error getting Windows processes with tasklist:', error);
      return [];
    }
  }

  async getUnixProcesses() {
    try {
      const { stdout } = await execFileAsync('ps', ['aux']);
      const lines = stdout.split('\n').slice(1); // Skip header
      return lines
        .filter(line => line.trim())
        .map(line => {
          const parts = line.split(/\s+/);
          return {
            name: parts[10] || '',
            pid: parseInt(parts[1]),
            memory: parseFloat(parts[3])
          };
        });
    } catch (error) {
      console.error('Error getting Unix processes:', error);
      return [];
    }
  }

  async checkProcesses() {
    try {
      const processes = await this.getProcessList();
      const currentPids = new Set(processes.map(p => p.pid));
      
      // Check for terminated processes
      for (const [pid, process] of this.activeProcesses.entries()) {
        if (!currentPids.has(pid)) {
          this.emit('processClosed', { pid, process });
          this.activeProcesses.delete(pid);
        }
      }

      // Check for new processes
      for (const process of processes) {
        if (!this.activeProcesses.has(process.pid)) {
          this.activeProcesses.set(process.pid, process);
          this.emit('processStarted', process);
        }
      }

      // Update metrics
      this.metrics.processes = {
        total: processes.length,
        active: this.activeProcesses.size,
        memory: processes.reduce((sum, p) => sum + p.memory, 0)
      };

      return processes;
    } catch (error) {
      console.error('Error checking processes:', error);
      return [];
    }
  }

  async killProcess(pid) {
    try {
      process.kill(pid);
      this.activeProcesses.delete(pid);
      return true;
    } catch (error) {
      console.error(`Error killing process ${pid}:`, error);
      return false;
    }
  }

  async killProcessesByName(name) {
    const killed = [];
    for (const [pid, process] of this.activeProcesses.entries()) {
      if (process.name.includes(name)) {
        if (await this.killProcess(pid)) {
          killed.push(pid);
        }
      }
    }
    return killed;
  }
}

module.exports = EnhancedResourceMonitor; 