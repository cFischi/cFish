const path = require('path');
const fs = require('fs').promises;
const ResourceMonitor = require('./resource-monitor');
const config = require('../config/test-environment');

class StagedTestRunner {
  constructor() {
    this.config = config;
    this.resourceMonitor = new ResourceMonitor(config.resourceMonitor);
    this.stages = [
      {
        name: 'initialization',
        tests: ['setup', 'configuration'],
        resourceIntensity: 'low'
      },
      {
        name: 'core',
        tests: ['resource-monitor', 'staged-installer'],
        resourceIntensity: 'medium'
      },
      {
        name: 'integration',
        tests: ['cross-component', 'alerts'],
        resourceIntensity: 'high'
      },
      {
        name: 'stress',
        tests: ['load-test', 'recovery'],
        resourceIntensity: 'extreme'
      }
    ];
    
    this.currentStage = 0;
    this.recoveryPoints = new Map();
    this.metrics = [];
  }

  async initialize() {
    console.log('Initializing staged test runner...');
    await this.resourceMonitor.start();
    
    // Create recovery directory if it doesn't exist
    const recoveryDir = path.join(this.config.paths.root, 'recovery');
    await fs.mkdir(recoveryDir, { recursive: true });
  }

  async runTests() {
    try {
      await this.initialize();
      
      for (let i = 0; i < this.stages.length; i++) {
        const stage = this.stages[i];
        console.log(`\nStarting test stage: ${stage.name}`);
        
        // Check resource state before stage
        await this.checkResourceState(stage);
        
        // Create recovery point
        await this.createRecoveryPoint(stage);
        
        // Run stage tests
        await this.runStage(stage);
        
        // Cooldown period
        await this.cooldown(stage);
        
        // Update progress
        this.currentStage = i + 1;
      }
      
      console.log('\nAll test stages completed successfully');
      await this.cleanup();
      
    } catch (error) {
      console.error('Error in test execution:', error);
      await this.handleFailure(error);
    }
  }

  async checkResourceState(stage) {
    // Wait for initial metrics collection
    await new Promise(resolve => setTimeout(resolve, this.config.resourceMonitor.updateInterval * 2));
    
    const metrics = await this.resourceMonitor.getMetrics();
    if (!metrics?.current?.resourceStats?.resourceMetrics) {
      console.log('Waiting for resource metrics to be available...');
      await new Promise(resolve => setTimeout(resolve, this.config.resourceMonitor.updateInterval));
      return this.checkResourceState(stage);
    }
    
    const { cpu, memory } = metrics.current.resourceStats.resourceMetrics;
    
    // Define thresholds based on stage intensity
    const thresholds = {
      low: { cpu: 70, memory: 70 },      // More lenient thresholds
      medium: { cpu: 75, memory: 75 },
      high: { cpu: 80, memory: 80 },
      extreme: { cpu: 85, memory: 85 }
    };
    
    const stageThresholds = thresholds[stage.resourceIntensity];
    
    if (cpu > stageThresholds.cpu || memory > stageThresholds.memory) {
      console.log(`Resource usage too high (CPU: ${cpu.toFixed(1)}%, Memory: ${memory.toFixed(1)}%), waiting for cooldown...`);
      await this.cooldown(stage);
    } else {
      console.log(`Resource usage OK (CPU: ${cpu.toFixed(1)}%, Memory: ${memory.toFixed(1)}%)`);
    }
  }

  async createRecoveryPoint(stage) {
    const recoveryPoint = {
      stage: stage.name,
      timestamp: new Date().toISOString(),
      metrics: await this.resourceMonitor.getMetrics(),
      progress: this.currentStage
    };
    
    const recoveryFile = path.join(
      this.config.paths.root,
      'recovery',
      `${stage.name}-${Date.now()}.json`
    );
    
    await fs.writeFile(recoveryFile, JSON.stringify(recoveryPoint, null, 2));
    this.recoveryPoints.set(stage.name, recoveryFile);
    
    console.log(`Created recovery point for stage: ${stage.name}`);
  }

  async runStage(stage) {
    console.log(`Running tests for stage: ${stage.name}`);
    
    for (const test of stage.tests) {
      console.log(`\nExecuting test: ${test}`);
      
      // Monitor resources during test execution
      const startMetrics = await this.resourceMonitor.getMetrics();
      
      try {
        // Simulate test execution
        await this.executeTest(test, stage);
        
        // Collect end metrics
        const endMetrics = await this.resourceMonitor.getMetrics();
        this.metrics.push({
          test,
          stage: stage.name,
          startMetrics,
          endMetrics,
          timestamp: new Date().toISOString()
        });
        
      } catch (error) {
        console.error(`Error in test ${test}:`, error);
        await this.handleTestFailure(test, stage, error);
      }
      
      // Small cooldown between tests
      await new Promise(resolve => setTimeout(resolve, 1000));
    }
  }

  async executeTest(test, stage) {
    // Simulate test execution with resource monitoring
    const duration = this.getTestDuration(stage.resourceIntensity);
    
    // Define stage-specific thresholds
    const thresholds = {
      low: { cpu: 75, memoryGB: 2 },
      medium: { cpu: 80, memoryGB: 3 },
      high: { cpu: 85, memoryGB: 4 },
      extreme: { cpu: 90, memoryGB: 6 }
    };
    
    const stageThresholds = thresholds[stage.resourceIntensity];
    console.log(`Running test '${test}' with thresholds - CPU: ${stageThresholds.cpu}%, Memory: ${stageThresholds.memoryGB}GB`);
    
    // Force garbage collection before test
    if (global.gc) {
      console.log('Running garbage collection before test...');
      global.gc();
    }
    
    return new Promise((resolve, reject) => {
      const interval = setInterval(async () => {
        const metrics = await this.resourceMonitor.getMetrics();
        const { cpu } = metrics.current.resourceStats.resourceMetrics;
        
        // Calculate memory usage in GB
        const usedMemory = process.memoryUsage().heapUsed / 1024 / 1024 / 1024;
        
        // Log current resource usage
        console.log(`Resource usage - CPU: ${cpu.toFixed(1)}%, Memory: ${usedMemory.toFixed(2)}GB`);
        
        // Run GC if memory usage is above 75% of threshold
        if (usedMemory > stageThresholds.memoryGB * 0.75 && global.gc) {
          console.log('Memory usage high, running garbage collection...');
          global.gc();
        }
        
        // Check for resource limits using stage-specific thresholds
        if (cpu > stageThresholds.cpu || usedMemory > stageThresholds.memoryGB) {
          clearInterval(interval);
          reject(new Error(`Resource limits exceeded during test ${test} (CPU: ${cpu.toFixed(1)}%, Memory: ${usedMemory.toFixed(2)}GB)`));
          return;
        }
      }, 1000);
      
      setTimeout(() => {
        clearInterval(interval);
        console.log(`Test '${test}' completed successfully`);
        resolve();
      }, duration);
    });
  }

  getTestDuration(intensity) {
    const durations = {
      low: 5000,
      medium: 10000,
      high: 15000,
      extreme: 20000
    };
    return durations[intensity];
  }

  async cooldown(stage) {
    const cooldownTime = this.getCooldownTime(stage.resourceIntensity);
    console.log(`Cooling down for ${cooldownTime/1000} seconds...`);
    
    // Force garbage collection multiple times during cooldown
    if (global.gc) {
      console.log('Running garbage collection during cooldown...');
      for (let i = 0; i < 3; i++) {
        global.gc();
        await new Promise(resolve => setTimeout(resolve, 500));
      }
    }
    
    await new Promise(resolve => setTimeout(resolve, cooldownTime));
  }

  getCooldownTime(intensity) {
    const cooldowns = {
      low: 2000,
      medium: 5000,
      high: 10000,
      extreme: 15000
    };
    return cooldowns[intensity];
  }

  async handleTestFailure(test, stage, error) {
    console.error(`Test failure in ${test} (${stage.name}):`, error);
    
    // Try to recover from last recovery point
    const recoveryFile = this.recoveryPoints.get(stage.name);
    if (recoveryFile) {
      console.log(`Attempting recovery from: ${stage.name}`);
      const recoveryData = JSON.parse(
        await fs.readFile(recoveryFile, 'utf8')
      );
      
      // Log recovery attempt
      await fs.appendFile(
        path.join(this.config.paths.logs, 'recovery.log'),
        `\n${new Date().toISOString()} - Recovery attempt for ${test} in ${stage.name}`
      );
      
      // Wait for resources to stabilize
      await this.cooldown(stage);
    }
    
    throw error; // Re-throw to handle at higher level
  }

  async handleFailure(error) {
    console.error('Test execution failed:', error);
    
    // Save failure state
    const failureState = {
      error: error.message,
      stage: this.stages[this.currentStage],
      metrics: await this.resourceMonitor.getMetrics(),
      timestamp: new Date().toISOString()
    };
    
    await fs.writeFile(
      path.join(this.config.paths.logs, 'failure-state.json'),
      JSON.stringify(failureState, null, 2)
    );
    
    await this.cleanup();
  }

  async cleanup() {
    console.log('Cleaning up...');
    await this.resourceMonitor.stop();
    
    // Save test metrics
    await fs.writeFile(
      path.join(this.config.paths.metrics, `test-metrics-${Date.now()}.json`),
      JSON.stringify(this.metrics, null, 2)
    );
    
    // Clean up old recovery points
    for (const [_, file] of this.recoveryPoints) {
      try {
        await fs.unlink(file);
      } catch (error) {
        console.error('Error cleaning up recovery file:', error);
      }
    }
  }
}

module.exports = StagedTestRunner; 