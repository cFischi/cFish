const ResourceMonitor = require('./resource-monitor');
const EventEmitter = require('events');

class ResourceOptimizer extends EventEmitter {
  constructor(config = {}) {
    super();
    this.config = {
      optimizationInterval: config.optimizationInterval || 5000, // ms
      maxConcurrentOperations: config.maxConcurrentOperations || 3,
      operationTimeout: config.operationTimeout || 30000, // ms
      ...config
    };

    this.monitor = new ResourceMonitor({
      checkInterval: 1000,
      thresholds: {
        cpu: 80,
        memory: 85,
        disk: 90
      },
      warningThresholds: {
        cpu: 70,
        memory: 75,
        disk: 80
      }
    });

    this.state = {
      isOptimizing: false,
      operationQueue: [],
      activeOperations: new Set(),
      resourceStats: {
        operations: {
          total: 0,
          completed: 0,
          failed: 0
        },
        optimizations: {
          applied: 0,
          skipped: 0
        }
      }
    };

    // Listen to monitor events
    this.monitor.on('alert', this.handleResourceAlert.bind(this));
    this.monitor.on('emergency_shutdown', this.handleEmergencyShutdown.bind(this));
  }

  async start() {
    console.log('Starting resource optimization system...');
    
    // Start resource monitoring
    await this.monitor.start();

    this.state.isOptimizing = true;
    this.optimizationInterval = setInterval(
      () => this.optimizeResources(),
      this.config.optimizationInterval
    );

    this.emit('started', {
      timestamp: new Date(),
      config: this.config
    });
  }

  async stop() {
    console.log('Stopping resource optimization system...');
    
    clearInterval(this.optimizationInterval);
    this.state.isOptimizing = false;
    
    // Stop resource monitoring
    await this.monitor.stop();

    this.emit('stopped', {
      timestamp: new Date(),
      stats: this.state.resourceStats
    });
  }

  async queueOperation(operation) {
    const operationId = Date.now().toString(36) + Math.random().toString(36).substr(2);
    
    const queuedOperation = {
      id: operationId,
      operation,
      timestamp: Date.now(),
      status: 'queued',
      priority: operation.priority || 'normal'
    };

    this.state.operationQueue.push(queuedOperation);
    this.emit('operation_queued', queuedOperation);

    // Sort queue by priority
    this.state.operationQueue.sort((a, b) => {
      const priorities = { high: 0, normal: 1, low: 2 };
      return priorities[a.priority] - priorities[b.priority];
    });

    return operationId;
  }

  async processOperation(operation) {
    if (this.state.activeOperations.size >= this.config.maxConcurrentOperations) {
      return false;
    }

    this.state.activeOperations.add(operation.id);
    operation.status = 'running';
    this.state.resourceStats.operations.total++;

    try {
      // Execute operation with timeout
      await Promise.race([
        operation.operation(),
        new Promise((_, reject) => 
          setTimeout(() => reject(new Error('Operation timed out')), this.config.operationTimeout)
        )
      ]);

      operation.status = 'completed';
      this.state.resourceStats.operations.completed++;
      this.emit('operation_completed', operation);

    } catch (error) {
      operation.status = 'failed';
      operation.error = error.message;
      this.state.resourceStats.operations.failed++;
      this.emit('operation_failed', { operation, error });

    } finally {
      this.state.activeOperations.delete(operation.id);
    }

    return true;
  }

  async optimizeResources() {
    if (!this.state.isOptimizing) return;

    const metrics = await this.monitor.checkResources();
    const recommendations = this.generateOptimizationRecommendations(metrics);

    for (const recommendation of recommendations) {
      try {
        await this.applyOptimization(recommendation);
        this.state.resourceStats.optimizations.applied++;
        this.emit('optimization_applied', recommendation);
      } catch (error) {
        this.state.resourceStats.optimizations.skipped++;
        this.emit('optimization_failed', { recommendation, error });
      }
    }

    // Process queued operations
    while (this.state.operationQueue.length > 0 && 
           this.state.activeOperations.size < this.config.maxConcurrentOperations) {
      const operation = this.state.operationQueue.shift();
      await this.processOperation(operation);
    }
  }

  generateOptimizationRecommendations(metrics) {
    const recommendations = [];

    // CPU optimization recommendations
    if (metrics.cpu > this.monitor.config.warningThresholds.cpu) {
      recommendations.push({
        type: 'cpu',
        action: 'reduce_concurrency',
        current: metrics.cpu,
        target: this.monitor.config.warningThresholds.cpu,
        priority: metrics.cpu > this.monitor.config.thresholds.cpu ? 'high' : 'normal'
      });
    }

    // Memory optimization recommendations
    if (metrics.memory > this.monitor.config.warningThresholds.memory) {
      recommendations.push({
        type: 'memory',
        action: 'gc_collect',
        current: metrics.memory,
        target: this.monitor.config.warningThresholds.memory,
        priority: metrics.memory > this.monitor.config.thresholds.memory ? 'high' : 'normal'
      });
    }

    return recommendations;
  }

  async applyOptimization(recommendation) {
    switch (recommendation.type) {
      case 'cpu':
        await this.applyCPUOptimization(recommendation);
        break;
      case 'memory':
        await this.applyMemoryOptimization(recommendation);
        break;
      default:
        throw new Error(`Unknown optimization type: ${recommendation.type}`);
    }
  }

  async applyCPUOptimization(recommendation) {
    switch (recommendation.action) {
      case 'reduce_concurrency':
        // Temporarily reduce max concurrent operations
        const reduction = Math.ceil(this.config.maxConcurrentOperations * 0.25);
        this.config.maxConcurrentOperations = Math.max(1, 
          this.config.maxConcurrentOperations - reduction);
        break;
      default:
        throw new Error(`Unknown CPU optimization action: ${recommendation.action}`);
    }
  }

  async applyMemoryOptimization(recommendation) {
    switch (recommendation.action) {
      case 'gc_collect':
        if (global.gc) {
          global.gc();
        }
        break;
      default:
        throw new Error(`Unknown memory optimization action: ${recommendation.action}`);
    }
  }

  async handleResourceAlert(alert) {
    if (alert.type === 'warning') {
      // Implement preemptive optimization
      const recommendation = {
        type: alert.resource,
        action: alert.resource === 'cpu' ? 'reduce_concurrency' : 'gc_collect',
        current: alert.value,
        target: alert.threshold,
        priority: 'high'
      };

      try {
        await this.applyOptimization(recommendation);
        this.emit('preemptive_optimization', recommendation);
      } catch (error) {
        this.emit('preemptive_optimization_failed', { recommendation, error });
      }
    }
  }

  async handleEmergencyShutdown(event) {
    console.log('Handling emergency shutdown...');
    
    try {
      // Stop accepting new operations
      this.state.isOptimizing = false;
      
      // Cancel all queued operations
      this.state.operationQueue.forEach(operation => {
        operation.status = 'cancelled';
        this.emit('operation_cancelled', operation);
      });
      this.state.operationQueue = [];

      // Wait for active operations to complete or timeout
      const timeout = setTimeout(() => {
        this.state.activeOperations.clear();
      }, 5000);

      while (this.state.activeOperations.size > 0) {
        await new Promise(resolve => setTimeout(resolve, 100));
      }

      clearTimeout(timeout);

      // Stop the optimizer
      await this.stop();

      this.emit('shutdown_complete', {
        timestamp: new Date(),
        trigger: event,
        stats: this.state.resourceStats
      });

    } catch (error) {
      console.error('Error during emergency shutdown:', error);
      this.emit('error', error);
    }
  }

  getStats() {
    return {
      ...this.state.resourceStats,
      currentOperations: {
        active: this.state.activeOperations.size,
        queued: this.state.operationQueue.length
      },
      resourceMetrics: this.monitor.getState().metrics
    };
  }
}

module.exports = ResourceOptimizer; 