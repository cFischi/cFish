const { MetricsCollector } = require('./metrics-collector');
const { ResourceMonitor } = require('./resource-monitor');
const { PlatformValidator } = require('./platform-validator');
const os = require('os');
const { execSync } = require('child_process');

class PerformanceMonitor {
  constructor(options = {}) {
    this.metricsCollector = new MetricsCollector();
    this.resourceMonitor = new ResourceMonitor();
    this.platformValidator = new PlatformValidator();
    this.options = {
      extended: false,
      interval: 5000,
      windowsCounters: false,
      ...options
    };
    this.isWindows = os.platform() === 'win32';
  }

  async start() {
    console.log('Starting performance monitoring...');
    
    // Initialize monitoring components
    await this.metricsCollector.startCollection();
    await this.resourceMonitor.startMonitoring();
    
    // Set up Windows performance counters if enabled
    if (this.options.windowsCounters && this.isWindows) {
      console.log('Windows performance counters enabled');
      await this.initializeWindowsCounters();
      this.windowsCounterInterval = setInterval(() => {
        this.collectWindowsMetrics();
      }, this.options.interval);
    }
    
    // Set up extended monitoring if enabled
    if (this.options.extended) {
      console.log('Extended monitoring enabled');
      this.extendedMonitoringInterval = setInterval(() => {
        this.collectExtendedMetrics();
      }, this.options.interval);
    }

    // Start platform validation
    await this.platformValidator.validateAll();
  }

  async stop() {
    console.log('Stopping performance monitoring...');
    
    if (this.extendedMonitoringInterval) {
      clearInterval(this.extendedMonitoringInterval);
    }

    if (this.windowsCounterInterval) {
      clearInterval(this.windowsCounterInterval);
    }
    
    await this.metricsCollector.stopCollection();
    await this.resourceMonitor.stopMonitoring();
    
    // Generate final report
    await this.generateReport();
  }

  async initializeWindowsCounters() {
    try {
      // Verify TypePerf is available
      execSync('typeperf.exe /?', { stdio: 'ignore' });
      
      // Initialize key performance counters
      this.windowsCounters = [
        '\\Processor(_Total)\\% Processor Time',
        '\\Memory\\Available MBytes',
        '\\PhysicalDisk(_Total)\\Avg. Disk Queue Length',
        '\\Network Interface(*)\\Bytes Total/sec'
      ];
      
      console.log('Windows performance counters initialized successfully');
    } catch (error) {
      console.error('Failed to initialize Windows performance counters:', error.message);
      this.windowsCounters = null;
    }
  }

  async collectWindowsMetrics() {
    if (!this.windowsCounters) return;

    try {
      const result = execSync(`typeperf -sc 1 "${this.windowsCounters.join('" "')}"`, { encoding: 'utf8' });
      const lines = result.trim().split('\n');
      if (lines.length >= 2) {
        const values = lines[1].split(',').map(v => parseFloat(v.trim().replace('"', '')));
        
        const metrics = {
          timestamp: new Date().toISOString(),
          cpu: values[0],
          memoryAvailable: values[1],
          diskQueue: values[2],
          networkBytes: values[3]
        };

        await this.metricsCollector.recordMetrics('windows', metrics);
        console.log('Windows metrics collected:', metrics);
      }
    } catch (error) {
      console.error('Error collecting Windows metrics:', error.message);
    }
  }

  async collectExtendedMetrics() {
    const metrics = {
      timestamp: new Date().toISOString(),
      resources: await this.resourceMonitor.getCurrentUsage(),
      performance: await this.metricsCollector.getCurrentMetrics(),
      platform: await this.platformValidator.getHealthStatus()
    };

    await this.metricsCollector.recordMetrics('extended', metrics);
  }

  async generateReport() {
    const report = {
      summary: await this.metricsCollector.generateSummaryReport(),
      resources: await this.resourceMonitor.generateReport(),
      platform: await this.platformValidator.generateReport(),
      recommendations: await this.generateRecommendations()
    };

    console.log('Performance Monitoring Report:');
    console.log(JSON.stringify(report, null, 2));
    
    return report;
  }

  async generateRecommendations() {
    const metrics = await this.metricsCollector.getMetricsHistory();
    const resources = await this.resourceMonitor.getResourceHistory();
    
    const recommendations = [];
    
    // Analyze memory usage patterns
    if (resources.memory.average > 80) {
      recommendations.push({
        type: 'memory',
        severity: 'high',
        message: 'High memory usage detected. Consider optimizing memory-intensive operations.'
      });
    }
    
    // Analyze CPU usage patterns
    if (resources.cpu.average > 70) {
      recommendations.push({
        type: 'cpu',
        severity: 'medium',
        message: 'Elevated CPU usage. Review background tasks and processing operations.'
      });
    }
    
    // Analyze performance metrics
    if (metrics.performance.average < 85) {
      recommendations.push({
        type: 'performance',
        severity: 'medium',
        message: 'Performance below target threshold. Review recent changes and optimization opportunities.'
      });
    }
    
    return recommendations;
  }
}

// Command line handling
if (require.main === module) {
  const args = process.argv.slice(2);
  const options = {
    extended: args.includes('--extended'),
    windowsCounters: args.includes('--windows-counters'),
    interval: args.includes('--interval') ? 
      parseInt(args[args.indexOf('--interval') + 1]) : 5000
  };

  const monitor = new PerformanceMonitor(options);
  
  process.on('SIGINT', async () => {
    console.log('\nReceived SIGINT. Shutting down...');
    await monitor.stop();
    process.exit(0);
  });

  monitor.start().catch(error => {
    console.error('Error starting performance monitor:', error);
    process.exit(1);
  });
}

module.exports = { PerformanceMonitor }; 