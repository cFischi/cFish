const { ResourceMonitor } = require('../modules/resource-monitor');
const { ProcessManager } = require('../modules/process-manager');
const { assert } = require('chai');

// Test configuration
const config = {
  memoryThresholds: {
    warning: 70,
    critical: 80
  },
  processLimits: {
    maxConcurrent: 3,
    timeout: 300000
  },
  cooldown: {
    normal: 30000,
    critical: 60000
  }
};

describe('Resource Monitoring System Tests', () => {
  let resourceMonitor;
  let processManager;

  before(async () => {
    resourceMonitor = new ResourceMonitor(config);
    processManager = new ProcessManager(config);
    await resourceMonitor.initialize();
    await processManager.initialize();
  });

  describe('Memory Management', () => {
    it('should track memory usage accurately', async () => {
      const metrics = await resourceMonitor.getMemoryMetrics();
      assert.exists(metrics.used);
      assert.exists(metrics.total);
      assert.isBelow(metrics.used / metrics.total * 100, config.memoryThresholds.critical);
    });

    it('should trigger warning at threshold', async () => {
      let warningTriggered = false;
      resourceMonitor.on('warning', () => warningTriggered = true);
      // Simulate high memory usage
      await resourceMonitor.simulateHighMemory(config.memoryThresholds.warning);
      assert.isTrue(warningTriggered);
    });
  });

  describe('Process Management', () => {
    it('should enforce process limits', async () => {
      const processes = [];
      for (let i = 0; i < config.processLimits.maxConcurrent + 1; i++) {
        processes.push(processManager.startProcess('test-process'));
      }
      const activeProcesses = await processManager.getActiveProcesses();
      assert.lengthOf(activeProcesses, config.processLimits.maxConcurrent);
    });

    it('should implement cooldown periods', async () => {
      const startTime = Date.now();
      await processManager.triggerCooldown('normal');
      const duration = Date.now() - startTime;
      assert.isAtLeast(duration, config.cooldown.normal);
    });
  });

  describe('Emergency Procedures', () => {
    it('should handle emergency shutdown', async () => {
      let shutdownTriggered = false;
      processManager.on('emergency-shutdown', () => shutdownTriggered = true);
      await processManager.triggerEmergencyShutdown();
      assert.isTrue(shutdownTriggered);
      const activeProcesses = await processManager.getActiveProcesses();
      assert.lengthOf(activeProcesses, 0);
    });
  });

  after(async () => {
    await resourceMonitor.cleanup();
    await processManager.cleanup();
  });
});

// Run tests if executed directly
if (require.main === module) {
  describe('Resource Monitoring Integration Tests', function() {
    this.timeout(10000); // Allow up to 10 seconds for tests
    require('./test-resource-monitoring.js');
  });
} 