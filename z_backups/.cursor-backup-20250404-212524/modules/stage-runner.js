const EventEmitter = require('events');

class StageRunner extends EventEmitter {
  constructor(stageName) {
    super();
    this.stageName = stageName;
    this.running = false;
    this.paused = false;
    this.currentTest = null;
    this.results = [];
  }

  async runStage(options = {}) {
    if (this.running) {
      throw new Error('Stage already running');
    }

    console.log(`[Stage] Starting ${this.stageName} stage`);
    this.running = true;
    
    try {
      // Initialize stage
      await this._initializeStage();
      
      // Run stage tests
      await this._runTests(options);
      
      // Generate stage report
      const report = this._generateReport();
      
      // Notify completion
      if (options.onStageComplete) {
        await options.onStageComplete(report);
      }
      
      return report;
      
    } catch (error) {
      console.error(`[Stage] Error in ${this.stageName} stage:`, error);
      throw error;
      
    } finally {
      this.running = false;
      console.log(`[Stage] Completed ${this.stageName} stage`);
    }
  }

  async applyCooldown(duration) {
    if (this.paused) return;
    
    console.log(`[Stage] Applying cooldown for ${duration}ms`);
    this.paused = true;
    
    await new Promise(resolve => setTimeout(resolve, duration));
    
    this.paused = false;
    console.log('[Stage] Cooldown complete');
  }

  async _initializeStage() {
    console.log(`[Stage] Initializing ${this.stageName} stage`);
    
    // Reset state
    this.results = [];
    this.currentTest = null;
    
    // Load stage configuration
    const config = await this._loadStageConfig();
    
    // Initialize resources
    await this._initializeResources(config);
    
    console.log(`[Stage] Initialized ${this.stageName} stage`);
  }

  async _loadStageConfig() {
    // Load stage-specific configuration
    const config = {
      optimization: {
        tests: [
          {
            name: 'memory-optimization',
            duration: 5000,
            metrics: ['memory', 'cpu']
          },
          {
            name: 'cpu-optimization',
            duration: 5000,
            metrics: ['cpu', 'performance']
          },
          {
            name: 'resource-allocation',
            duration: 5000,
            metrics: ['memory', 'cpu', 'performance']
          }
        ],
        thresholds: {
          memory: {
            warning: 70,
            critical: 85
          },
          cpu: {
            warning: 60,
            critical: 75
          }
        }
      }
    };

    return config[this.stageName] || {};
  }

  async _initializeResources(config) {
    // Initialize any resources needed for the stage
    console.log('[Stage] Initializing resources with config:', config);
  }

  async _runTests(options) {
    const config = await this._loadStageConfig();
    
    for (const test of config.tests) {
      if (!this.running) break;
      
      console.log(`[Stage] Running test: ${test.name}`);
      this.currentTest = test;
      
      try {
        // Run the test
        const result = await this._runTest(test, options);
        this.results.push(result);
        
        // Update metrics
        if (options.onMetricsUpdate) {
          options.onMetricsUpdate({
            test: test.name,
            metrics: result.metrics
          });
        }
        
        // Check resource warnings
        if (result.warnings.length > 0 && options.onResourceWarning) {
          await options.onResourceWarning({
            test: test.name,
            warnings: result.warnings
          });
        }
        
      } catch (error) {
        console.error(`[Stage] Error in test ${test.name}:`, error);
        this.results.push({
          test: test.name,
          status: 'error',
          error: error.message,
          duration: 0,
          metrics: {},
          warnings: []
        });
      }
      
      // Apply cooldown between tests
      if (this.running && config.tests.indexOf(test) < config.tests.length - 1) {
        await this.applyCooldown(1000);
      }
    }
  }

  async _runTest(test, options) {
    const startTime = Date.now();
    const warnings = [];
    const metrics = {};
    
    // Simulate test execution
    await new Promise(resolve => setTimeout(resolve, test.duration));
    
    // Collect metrics
    test.metrics.forEach(metric => {
      metrics[metric] = Math.random() * 100;
      
      // Check thresholds
      const config = this._loadStageConfig();
      if (config.thresholds?.[metric]) {
        if (metrics[metric] > config.thresholds[metric].critical) {
          warnings.push({
            metric,
            level: 'critical',
            value: metrics[metric],
            threshold: config.thresholds[metric].critical
          });
        } else if (metrics[metric] > config.thresholds[metric].warning) {
          warnings.push({
            metric,
            level: 'warning',
            value: metrics[metric],
            threshold: config.thresholds[metric].warning
          });
        }
      }
    });
    
    return {
      test: test.name,
      status: 'completed',
      duration: Date.now() - startTime,
      metrics,
      warnings
    };
  }

  _generateReport() {
    return {
      stage: this.stageName,
      timestamp: Date.now(),
      results: this.results,
      summary: this._generateSummary(),
      recommendations: this._generateRecommendations()
    };
  }

  _generateSummary() {
    const total = this.results.length;
    const completed = this.results.filter(r => r.status === 'completed').length;
    const errors = this.results.filter(r => r.status === 'error').length;
    
    const warnings = this.results.reduce((acc, r) => acc + r.warnings.length, 0);
    
    const metrics = {};
    this.results.forEach(result => {
      Object.entries(result.metrics).forEach(([metric, value]) => {
        if (!metrics[metric]) {
          metrics[metric] = [];
        }
        metrics[metric].push(value);
      });
    });
    
    const averageMetrics = {};
    Object.entries(metrics).forEach(([metric, values]) => {
      averageMetrics[metric] = values.reduce((a, b) => a + b, 0) / values.length;
    });
    
    return {
      total,
      completed,
      errors,
      warnings,
      metrics: averageMetrics
    };
  }

  _generateRecommendations() {
    const recommendations = [];
    const summary = this._generateSummary();
    
    // Check completion rate
    if (summary.errors > 0) {
      recommendations.push({
        priority: 'high',
        message: `${summary.errors} tests failed to complete`,
        action: 'Review error logs and fix failing tests'
      });
    }
    
    // Check warning count
    if (summary.warnings > 0) {
      recommendations.push({
        priority: 'medium',
        message: `${summary.warnings} resource warnings detected`,
        action: 'Review resource utilization and optimize where needed'
      });
    }
    
    // Check metrics
    Object.entries(summary.metrics).forEach(([metric, value]) => {
      const config = this._loadStageConfig();
      if (config.thresholds?.[metric]) {
        if (value > config.thresholds[metric].warning) {
          recommendations.push({
            priority: value > config.thresholds[metric].critical ? 'high' : 'medium',
            message: `${metric} usage (${value.toFixed(1)}%) exceeds warning threshold`,
            action: `Optimize ${metric} usage and review resource allocation`
          });
        }
      }
    });
    
    return recommendations;
  }
}

module.exports = { StageRunner }; 