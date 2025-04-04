const { ResourceMonitor } = require('../modules/resource-monitor');
const { StageRunner } = require('../modules/stage-runner');
const { MetricsCollector } = require('../modules/metrics-collector');

// Enhanced resource management configuration
const resourceConfig = {
  memory: {
    warning: 70,
    critical: 85,
    threshold: 95,
    checkInterval: 1000
  },
  cpu: {
    warning: 60,
    critical: 75,
    threshold: 90,
    checkInterval: 1000
  },
  cooldown: {
    duration: 5000,
    threshold: 80
  }
};

// Optimization stage metrics configuration
const metricsConfig = {
  performance: {
    responseTime: true,
    throughput: true,
    reliability: true
  },
  resources: {
    memory: true,
    cpu: true,
    storage: true
  },
  integration: {
    syncSuccess: true,
    dataAccuracy: true,
    latency: true
  }
};

async function runOptimizationStage() {
  console.log('[Optimization] Starting optimization stage with enhanced resource management');
  
  const monitor = new ResourceMonitor(resourceConfig);
  const metrics = new MetricsCollector(metricsConfig);
  const runner = new StageRunner('optimization');

  try {
    // Initialize monitoring
    await monitor.start();
    console.log('[Optimization] Resource monitoring initialized');

    // Start metrics collection
    metrics.startCollection();
    console.log('[Optimization] Metrics collection started');

    // Run optimization tests with resource awareness
    await runner.runStage({
      onResourceWarning: (stats) => {
        console.log('[Optimization] Resource warning:', stats);
        return runner.applyCooldown(resourceConfig.cooldown.duration);
      },
      onMetricsUpdate: (data) => {
        console.log('[Optimization] Metrics update:', data);
        metrics.record(data);
      },
      onStageComplete: async () => {
        const report = await metrics.generateReport();
        console.log('[Optimization] Stage complete. Report:', report);
      }
    });

  } catch (error) {
    console.error('[Optimization] Stage error:', error);
    throw error;
  } finally {
    await monitor.stop();
    metrics.stopCollection();
    console.log('[Optimization] Stage resources cleaned up');
  }
}

// Run the optimization stage
runOptimizationStage().catch(console.error); 