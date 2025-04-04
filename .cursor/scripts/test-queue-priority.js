const assert = require('assert');
const path = require('path');
const fs = require('fs').promises;
const QueuePriority = require('./queue-priority');

describe('QueuePriority', () => {
  let queue;
  const testQueueFile = path.join(__dirname, '../test-queue.json');

  beforeEach(async () => {
    // Clean up test file if it exists
    try {
      await fs.unlink(testQueueFile);
    } catch (error) {
      if (error.code !== 'ENOENT') throw error;
    }

    queue = new QueuePriority({
      queueFile: testQueueFile,
      maxConcurrent: 2,
      priorityLevels: {
        critical: {
          weight: 100,
          maxWaitTime: 1000
        },
        high: {
          weight: 75,
          maxWaitTime: 2000
        },
        medium: {
          weight: 50,
          maxWaitTime: 3000
        },
        low: {
          weight: 25,
          maxWaitTime: 4000
        }
      }
    });
  });

  afterEach(async () => {
    // Clean up test file
    try {
      await fs.unlink(testQueueFile);
    } catch (error) {
      if (error.code !== 'ENOENT') throw error;
    }
  });

  describe('Queue Management', () => {
    it('should add packages to queue', async () => {
      const item = await queue.addToQueue('test-package', 'high');
      assert.strictEqual(item.name, 'test-package');
      assert.strictEqual(item.priority, 'high');
      assert(item.weight >= 75); // Base weight for high priority
    });

    it('should sort queue by priority', async () => {
      await queue.addToQueue('low-priority', 'low');
      await queue.addToQueue('high-priority', 'high');
      await queue.addToQueue('critical-priority', 'critical');

      assert.strictEqual(queue.queue[0].name, 'critical-priority');
      assert.strictEqual(queue.queue[1].name, 'high-priority');
      assert.strictEqual(queue.queue[2].name, 'low-priority');
    });

    it('should respect maxConcurrent limit', async () => {
      // Mock resource check to always return low usage
      queue.checkResources = async () => ({
        cpu: 20,
        memory: 30,
        disk: 40
      });

      await queue.addToQueue('package-1', 'medium');
      await queue.addToQueue('package-2', 'medium');
      await queue.addToQueue('package-3', 'medium');

      // Wait for queue processing
      await new Promise(resolve => setTimeout(resolve, 100));

      assert.strictEqual(queue.installing.size, 2);
      assert.strictEqual(queue.queue.length, 1);
    });

    it('should handle installation failures and retries', async () => {
      // Mock installation to fail
      queue.installPackage = async (item) => {
        throw new Error('Installation failed');
      };

      await queue.addToQueue('failing-package', 'high');
      
      // Wait for processing and retries
      await new Promise(resolve => setTimeout(resolve, 100));

      assert.strictEqual(queue.queue[0].attempts, 1);
      assert.strictEqual(queue.queue[0].state, 'queued');
    });
  });

  describe('Priority Weighting', () => {
    it('should increase weight based on waiting time', async () => {
      const item = await queue.addToQueue('test-package', 'medium');
      const initialWeight = item.weight;

      // Simulate waiting
      item.addedAt = Date.now() - 2000;
      const newWeight = queue.calculateWeight(item.priority);

      assert(newWeight > initialWeight);
    });

    it('should cap weight increase at maxWaitTime', async () => {
      const item = await queue.addToQueue('test-package', 'medium');
      
      // Simulate waiting beyond maxWaitTime
      item.addedAt = Date.now() - 5000;
      const weight1 = queue.calculateWeight(item.priority);
      
      // Simulate even longer wait
      item.addedAt = Date.now() - 10000;
      const weight2 = queue.calculateWeight(item.priority);

      assert.strictEqual(weight1, weight2);
    });
  });

  describe('Resource Management', () => {
    it('should pause queue when resources are constrained', async () => {
      // Mock resource check to return high usage
      queue.checkResources = async () => ({
        cpu: 90,
        memory: 85,
        disk: 95
      });

      let queuePaused = false;
      queue.on('queue_paused', () => {
        queuePaused = true;
      });

      await queue.addToQueue('test-package', 'high');
      await queue.processQueue();

      assert(queuePaused);
      assert.strictEqual(queue.installing.size, 0);
    });

    it('should resume queue when resources are available', async () => {
      let resourceUsage = {
        cpu: 90,
        memory: 85,
        disk: 95
      };

      // Mock resource check
      queue.checkResources = async () => resourceUsage;

      await queue.addToQueue('test-package', 'high');
      await queue.processQueue();
      assert.strictEqual(queue.installing.size, 0);

      // Simulate resources becoming available
      resourceUsage = {
        cpu: 50,
        memory: 60,
        disk: 70
      };

      await queue.processQueue();
      assert.strictEqual(queue.installing.size, 1);
    });
  });

  describe('State Management', () => {
    it('should save and load state correctly', async () => {
      await queue.addToQueue('test-package-1', 'high');
      await queue.addToQueue('test-package-2', 'medium');

      // Create new instance with same file
      const newQueue = new QueuePriority({
        queueFile: testQueueFile
      });

      await new Promise(resolve => setTimeout(resolve, 100));

      assert.strictEqual(newQueue.queue.length, 2);
      assert.strictEqual(newQueue.queue[0].name, 'test-package-1');
      assert.strictEqual(newQueue.queue[1].name, 'test-package-2');
    });

    it('should track installation progress', async () => {
      await queue.addToQueue('test-package', 'high');
      
      let installationStarted = false;
      let installationCompleted = false;

      queue.on('installation_started', () => {
        installationStarted = true;
      });

      queue.on('installation_completed', () => {
        installationCompleted = true;
      });

      await queue.processQueue();
      await new Promise(resolve => setTimeout(resolve, 2500));

      assert(installationStarted);
      assert(installationCompleted);
      assert.strictEqual(queue.completed.size, 1);
    });
  });

  describe('Statistics', () => {
    it('should track queue statistics', async () => {
      await queue.addToQueue('package-1', 'high');
      await queue.addToQueue('package-2', 'medium');
      await queue.addToQueue('package-3', 'low');

      const stats = queue.getStats();
      assert.strictEqual(stats.queued, 3);
      assert.strictEqual(stats.installing, 0);
      assert.strictEqual(stats.completed, 0);
      assert.strictEqual(stats.failed, 0);
      assert.strictEqual(stats.byPriority.high, 1);
      assert.strictEqual(stats.byPriority.medium, 1);
      assert.strictEqual(stats.byPriority.low, 1);
    });

    it('should calculate average wait time', async () => {
      await queue.addToQueue('package-1', 'high');
      await new Promise(resolve => setTimeout(resolve, 1000));
      await queue.addToQueue('package-2', 'medium');

      const stats = queue.getStats();
      assert(stats.averageWaitTime > 0);
      assert(stats.averageWaitTime < 2000);
    });
  });
}); 