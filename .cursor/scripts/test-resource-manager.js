const ResourceOptimizer = require('./resource-optimization');
const path = require('path');
const fs = require('fs').promises;

class TestResourceManager {
  constructor(config = {}) {
    this.config = {
      logDir: path.join(__dirname, '../logs'),
      metricsDir: path.join(__dirname, '../metrics'),
      maxTestConcurrency: config.maxTestConcurrency || 2,
      testTimeout: config.testTimeout || 60000, // 1 minute
      optimizationConfig: {
        optimizationInterval: 2000,
        maxConcurrentOperations: config.maxTestConcurrency || 2,
        operationTimeout: config.testTimeout || 60000
      },
      ...config
    };

    this.optimizer = new ResourceOptimizer(this.config.optimizationConfig);
    this.testQueue = [];
    this.activeTests = new Map();
    this.testResults = new Map();

    // Bind event handlers
    this.optimizer.on('alert', this.handleResourceAlert.bind(this));
    this.optimizer.on('emergency_shutdown', this.handleEmergencyShutdown.bind(this));
    this.optimizer.on('optimization_applied', this.handleOptimization.bind(this));
  }

  async initialize() {
    console.log('Initializing test resource manager...');

    // Ensure directories exist
    await fs.mkdir(this.config.logDir, { recursive: true });
    await fs.mkdir(this.config.metricsDir, { recursive: true });

    // Start resource optimization
    await this.optimizer.start();

    console.log('Test resource manager initialized');
  }

  async shutdown() {
    console.log('Shutting down test resource manager...');

    // Stop resource optimization
    await this.optimizer.stop();

    // Save final metrics
    await this.saveMetrics();

    console.log('Test resource manager shutdown complete');
  }

  async queueTest(test) {
    const testId = Date.now().toString(36) + Math.random().toString(36).substr(2);
    
    const queuedTest = {
      id: testId,
      test,
      type: test.type || 'unit',
      priority: test.priority || 'normal',
      status: 'queued',
      timestamp: Date.now()
    };

    this.testQueue.push(queuedTest);
    await this.logTestEvent(testId, 'queued', { test: queuedTest });

    // Queue as resource operation
    await this.optimizer.queueOperation({
      priority: queuedTest.priority,
      operation: async () => this.runTest(queuedTest)
    });

    return testId;
  }

  async runTest(queuedTest) {
    const { id, test } = queuedTest;
    
    try {
      this.activeTests.set(id, {
        ...queuedTest,
        status: 'running',
        startTime: Date.now()
      });

      await this.logTestEvent(id, 'started');

      // Execute test with timeout
      const result = await Promise.race([
        test.execute(),
        new Promise((_, reject) => 
          setTimeout(() => reject(new Error('Test timed out')), this.config.testTimeout)
        )
      ]);

      const testDuration = Date.now() - this.activeTests.get(id).startTime;
      
      this.testResults.set(id, {
        ...queuedTest,
        status: 'completed',
        result,
        duration: testDuration,
        timestamp: Date.now()
      });

      await this.logTestEvent(id, 'completed', { 
        result, 
        duration: testDuration 
      });

    } catch (error) {
      this.testResults.set(id, {
        ...queuedTest,
        status: 'failed',
        error: error.message,
        timestamp: Date.now()
      });

      await this.logTestEvent(id, 'failed', { error: error.message });

    } finally {
      this.activeTests.delete(id);
    }
  }

  async handleResourceAlert(alert) {
    await this.logEvent('resource_alert', {
      alert,
      activeTests: Array.from(this.activeTests.values()),
      queuedTests: this.testQueue.length
    });

    if (alert.type === 'critical') {
      // Pause test execution
      this.testQueue.forEach(test => {
        test.status = 'paused';
        this.logTestEvent(test.id, 'paused', { reason: 'resource_critical' });
      });
    }
  }

  async handleEmergencyShutdown(event) {
    console.log('Handling emergency shutdown in test manager...');

    try {
      // Mark all active tests as interrupted
      for (const [id, test] of this.activeTests) {
        this.testResults.set(id, {
          ...test,
          status: 'interrupted',
          error: 'Emergency shutdown',
          timestamp: Date.now()
        });

        await this.logTestEvent(id, 'interrupted', { 
          reason: 'emergency_shutdown',
          event 
        });
      }

      // Clear active tests
      this.activeTests.clear();

      // Mark all queued tests as cancelled
      this.testQueue.forEach(test => {
        test.status = 'cancelled';
        this.logTestEvent(test.id, 'cancelled', { 
          reason: 'emergency_shutdown' 
        });
      });
      this.testQueue = [];

      // Save final state
      await this.saveMetrics();

    } catch (error) {
      console.error('Error during test manager emergency shutdown:', error);
    }
  }

  async handleOptimization(optimization) {
    await this.logEvent('optimization_applied', {
      optimization,
      activeTests: Array.from(this.activeTests.values()),
      queuedTests: this.testQueue.length
    });

    // Adjust test concurrency based on optimization
    if (optimization.type === 'cpu' && optimization.action === 'reduce_concurrency') {
      this.config.maxTestConcurrency = Math.max(1, 
        Math.floor(this.config.maxTestConcurrency * 0.75)
      );
    }
  }

  async logTestEvent(testId, event, data = {}) {
    const logEntry = {
      timestamp: new Date().toISOString(),
      testId,
      event,
      ...data
    };

    const logFile = path.join(this.config.logDir, `test-${testId}.log`);
    await fs.appendFile(logFile, JSON.stringify(logEntry) + '\n');
  }

  async logEvent(event, data = {}) {
    const logEntry = {
      timestamp: new Date().toISOString(),
      event,
      ...data
    };

    const logFile = path.join(this.config.logDir, 'test-manager.log');
    await fs.appendFile(logFile, JSON.stringify(logEntry) + '\n');
  }

  async saveMetrics() {
    const metrics = {
      timestamp: new Date().toISOString(),
      resourceStats: this.optimizer.getStats(),
      testStats: {
        active: this.activeTests.size,
        queued: this.testQueue.length,
        completed: Array.from(this.testResults.values()).filter(t => t.status === 'completed').length,
        failed: Array.from(this.testResults.values()).filter(t => t.status === 'failed').length
      }
    };

    const metricsFile = path.join(
      this.config.metricsDir, 
      `metrics-${new Date().toISOString().split('T')[0]}.json`
    );

    await fs.writeFile(metricsFile, JSON.stringify(metrics, null, 2));
  }

  getTestStatus(testId) {
    if (this.activeTests.has(testId)) {
      return this.activeTests.get(testId);
    }
    if (this.testResults.has(testId)) {
      return this.testResults.get(testId);
    }
    const queuedTest = this.testQueue.find(t => t.id === testId);
    return queuedTest || null;
  }

  getStats() {
    return {
      tests: {
        active: this.activeTests.size,
        queued: this.testQueue.length,
        results: {
          total: this.testResults.size,
          completed: Array.from(this.testResults.values()).filter(t => t.status === 'completed').length,
          failed: Array.from(this.testResults.values()).filter(t => t.status === 'failed').length,
          interrupted: Array.from(this.testResults.values()).filter(t => t.status === 'interrupted').length
        }
      },
      resources: this.optimizer.getStats()
    };
  }
}

module.exports = TestResourceManager; 