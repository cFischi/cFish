const { ResourceMonitor } = require('./resource-monitor');
const { MetricsCollector } = require('./metrics-collector');

class ResourceAnalyzer {
  constructor(options = {}) {
    this.resourceMonitor = new ResourceMonitor();
    this.metricsCollector = new MetricsCollector();
    this.options = {
      recommendations: false,
      threshold: 70,
      interval: 5000,
      duration: 60000,
      ...options
    };
  }

  async analyze() {
    console.log('Starting resource analysis...');
    
    // Start monitoring
    await this.resourceMonitor.startMonitoring();
    await this.metricsCollector.startCollection();
    
    const startTime = Date.now();
    const samples = [];
    
    // Collect samples over the specified duration
    while (Date.now() - startTime < this.options.duration) {
      const sample = {
        timestamp: new Date().toISOString(),
        resources: await this.resourceMonitor.getCurrentUsage(),
        metrics: await this.metricsCollector.getCurrentMetrics()
      };
      
      samples.push(sample);
      
      // Wait for the next interval
      await new Promise(resolve => setTimeout(resolve, this.options.interval));
    }
    
    // Stop monitoring
    await this.resourceMonitor.stopMonitoring();
    await this.metricsCollector.stopCollection();
    
    // Analyze the collected data
    const analysis = this.analyzeData(samples);
    
    // Generate and display the report
    await this.generateReport(analysis);
    
    return analysis;
  }

  analyzeData(samples) {
    const analysis = {
      summary: {
        sampleCount: samples.length,
        duration: this.options.duration,
        interval: this.options.interval
      },
      resources: {
        memory: this.calculateResourceMetrics(samples, 'memory'),
        cpu: this.calculateResourceMetrics(samples, 'cpu'),
        disk: this.calculateResourceMetrics(samples, 'disk')
      },
      performance: {
        average: this.calculateAveragePerformance(samples),
        trends: this.analyzeTrends(samples)
      },
      issues: this.identifyIssues(samples),
      recommendations: this.options.recommendations ? 
        this.generateRecommendations(samples) : []
    };

    return analysis;
  }

  calculateResourceMetrics(samples, resourceType) {
    const values = samples.map(s => s.resources[resourceType]);
    
    return {
      min: Math.min(...values),
      max: Math.max(...values),
      average: values.reduce((a, b) => a + b, 0) / values.length,
      trend: this.calculateTrend(values)
    };
  }

  calculateAveragePerformance(samples) {
    const performanceValues = samples.map(s => s.metrics.performance);
    return performanceValues.reduce((a, b) => a + b, 0) / performanceValues.length;
  }

  calculateTrend(values) {
    if (values.length < 2) return 'stable';
    
    const changes = values.slice(1).map((value, index) => value - values[index]);
    const averageChange = changes.reduce((a, b) => a + b, 0) / changes.length;
    
    if (Math.abs(averageChange) < 0.1) return 'stable';
    return averageChange > 0 ? 'increasing' : 'decreasing';
  }

  analyzeTrends(samples) {
    return {
      memory: this.calculateTrend(samples.map(s => s.resources.memory)),
      cpu: this.calculateTrend(samples.map(s => s.resources.cpu)),
      performance: this.calculateTrend(samples.map(s => s.metrics.performance))
    };
  }

  identifyIssues(samples) {
    const issues = [];
    
    // Check for resource threshold violations
    samples.forEach((sample, index) => {
      if (sample.resources.memory > this.options.threshold) {
        issues.push({
          type: 'memory',
          severity: 'high',
          timestamp: sample.timestamp,
          message: `Memory usage exceeded threshold: ${sample.resources.memory}%`
        });
      }
      
      if (sample.resources.cpu > this.options.threshold) {
        issues.push({
          type: 'cpu',
          severity: 'high',
          timestamp: sample.timestamp,
          message: `CPU usage exceeded threshold: ${sample.resources.cpu}%`
        });
      }
    });
    
    return issues;
  }

  generateRecommendations(samples) {
    const recommendations = [];
    const analysis = this.analyzeData(samples);
    
    // Memory recommendations
    if (analysis.resources.memory.average > this.options.threshold) {
      recommendations.push({
        type: 'memory',
        severity: 'high',
        message: 'High average memory usage detected',
        actions: [
          'Review memory-intensive operations',
          'Implement memory pooling where applicable',
          'Consider increasing memory capacity'
        ]
      });
    }
    
    // CPU recommendations
    if (analysis.resources.cpu.average > this.options.threshold) {
      recommendations.push({
        type: 'cpu',
        severity: 'high',
        message: 'High average CPU usage detected',
        actions: [
          'Optimize CPU-intensive tasks',
          'Consider task scheduling improvements',
          'Review background processes'
        ]
      });
    }
    
    // Performance recommendations
    if (analysis.performance.average < 85) {
      recommendations.push({
        type: 'performance',
        severity: 'medium',
        message: 'Performance below optimal levels',
        actions: [
          'Review recent performance changes',
          'Analyze resource allocation',
          'Consider optimization opportunities'
        ]
      });
    }
    
    return recommendations;
  }

  async generateReport(analysis) {
    const report = {
      title: 'Resource Analysis Report',
      timestamp: new Date().toISOString(),
      analysis: analysis
    };

    console.log('\nResource Analysis Report:');
    console.log(JSON.stringify(report, null, 2));

    return report;
  }
}

// Command line handling
if (require.main === module) {
  const args = process.argv.slice(2);
  const options = {
    recommendations: args.includes('--recommendations'),
    threshold: args.includes('--threshold') ? 
      parseInt(args[args.indexOf('--threshold') + 1]) : 70,
    interval: args.includes('--interval') ? 
      parseInt(args[args.indexOf('--interval') + 1]) : 5000,
    duration: args.includes('--duration') ? 
      parseInt(args[args.indexOf('--duration') + 1]) : 60000
  };

  const analyzer = new ResourceAnalyzer(options);
  
  analyzer.analyze().catch(error => {
    console.error('Error during resource analysis:', error);
    process.exit(1);
  });
}

module.exports = { ResourceAnalyzer }; 