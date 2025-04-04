const { StagedInstaller } = require('../modules/staged-installer');
const { ResourceMonitor } = require('../modules/resource-monitor');
const { assert } = require('chai');
const path = require('path');

// Test configuration
const config = {
  stages: ['core', 'monitoring', 'ui'],
  thresholds: {
    memory: {
      warning: 70,
      critical: 80
    },
    cooldown: {
      normal: 30000,
      critical: 60000
    }
  },
  testPackages: {
    core: ['fs-extra', 'chalk'],
    monitoring: ['systeminformation', 'node-os-utils'],
    ui: ['cli-progress', 'moment']
  }
};

describe('Staged Installation System Tests', () => {
  let installer;
  let resourceMonitor;
  const testDir = path.join(__dirname, 'test-install');

  before(async () => {
    resourceMonitor = new ResourceMonitor(config.thresholds);
    installer = new StagedInstaller(config, resourceMonitor);
    await installer.initialize(testDir);
  });

  describe('Installation Stages', () => {
    it('should install core packages successfully', async () => {
      const result = await installer.installStage('core');
      assert.isTrue(result.success);
      assert.lengthOf(result.installed, config.testPackages.core.length);
    });

    it('should respect cooldown periods', async () => {
      const startTime = Date.now();
      await installer.triggerCooldown('normal');
      const duration = Date.now() - startTime;
      assert.isAtLeast(duration, config.thresholds.cooldown.normal);
    });

    it('should preserve state between stages', async () => {
      await installer.installStage('core');
      const state = await installer.getState();
      assert.include(state.completed, 'core');
      assert.isTrue(state.isValid());
    });
  });

  describe('Resource Management', () => {
    it('should pause installation at memory threshold', async () => {
      let paused = false;
      installer.on('installation-paused', () => paused = true);
      await resourceMonitor.simulateHighMemory(config.thresholds.memory.warning);
      assert.isTrue(paused);
    });

    it('should resume installation when resources available', async () => {
      let resumed = false;
      installer.on('installation-resumed', () => resumed = true);
      await resourceMonitor.simulateNormalMemory();
      assert.isTrue(resumed);
    });
  });

  describe('Error Handling', () => {
    it('should handle failed installations gracefully', async () => {
      const result = await installer.installPackage('non-existent-package');
      assert.isFalse(result.success);
      assert.exists(result.error);
      assert.isTrue(await installer.isStateValid());
    });

    it('should implement retry mechanism', async () => {
      const result = await installer.retryFailedInstallations();
      assert.exists(result.retriedCount);
      assert.exists(result.successCount);
    });
  });

  describe('Recovery Mechanisms', () => {
    it('should create recovery points', async () => {
      const point = await installer.createRecoveryPoint();
      assert.exists(point.id);
      assert.exists(point.timestamp);
      assert.exists(point.state);
    });

    it('should restore from recovery points', async () => {
      const point = await installer.createRecoveryPoint();
      await installer.simulateFailure();
      const restored = await installer.restoreFromPoint(point.id);
      assert.isTrue(restored);
      assert.isTrue(await installer.isStateValid());
    });
  });

  after(async () => {
    await installer.cleanup();
    await resourceMonitor.cleanup();
  });
});

// Run tests if executed directly
if (require.main === module) {
  describe('Staged Installer Integration Tests', function() {
    this.timeout(300000); // Allow up to 5 minutes for installation tests
    require('./test-staged-installer.js');
  });
} 