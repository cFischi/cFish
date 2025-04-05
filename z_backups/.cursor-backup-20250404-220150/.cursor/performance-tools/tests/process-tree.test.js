const ProcessTreeVisualization = require('../optimization/process-tree');

describe('ProcessTreeVisualization', () => {
  let processTree;
  let mockProcessInfo;

  beforeEach(() => {
    // Mock process info data
    mockProcessInfo = {
      name: 'test-process',
      pid: 1234,
      cpu: 50,
      memory: 60,
      status: 'running'
    };

    // Create instance with test configuration
    processTree = new ProcessTreeVisualization({
      rendering: {
        mode: 'virtual',
        updateInterval: 16,
        batchSize: 10,
        maxDepth: 5
      },
      optimization: {
        recycling: true,
        memoryLimit: 1024 * 1024, // 1MB
        cacheSize: 100,
        cleanupInterval: 1000 // 1s
      },
      monitoring: {
        metrics: ['cpu', 'memory'],
        alerts: true,
        history: 60, // 1 minute
        aggregation: '1s',
        thresholds: {
          warning: 70,
          critical: 90
        }
      }
    });

    // Mock getProcessInfo method
    processTree.getProcessInfo = jest.fn().mockResolvedValue(mockProcessInfo);
  });

  afterEach(() => {
    processTree.destroy();
    jest.clearAllMocks();
  });

  describe('Configuration', () => {
    test('should initialize with default config when none provided', () => {
      const defaultTree = new ProcessTreeVisualization();
      expect(defaultTree.config.rendering.mode).toBe('virtual');
      expect(defaultTree.config.optimization.recycling).toBe(true);
      expect(defaultTree.config.monitoring.alerts).toBe(true);
    });

    test('should override default config with provided values', () => {
      expect(processTree.config.rendering.batchSize).toBe(10);
      expect(processTree.config.optimization.cacheSize).toBe(100);
      expect(processTree.config.monitoring.history).toBe(60);
    });
  });

  describe('Virtual Scrolling', () => {
    beforeEach(() => {
      // Setup test data
      processTree.virtualScroll.items = Array(100).fill(null).map((_, i) => ({
        pid: i,
        name: `process-${i}`
      }));
      processTree.virtualScroll.visibleCount = 20;
    });

    test('should update visible processes based on scroll offset', async () => {
      await processTree.updateVisibleProcesses(50);
      expect(processTree.virtualScroll.renderedRange.start).toBe(40);
      expect(processTree.virtualScroll.renderedRange.end).toBe(80);
    });

    test('should not update if range has not changed', async () => {
      await processTree.updateVisibleProcesses(50);
      const spy = jest.spyOn(processTree, 'renderProcessNodes');
      await processTree.updateVisibleProcesses(50);
      expect(spy).not.toHaveBeenCalled();
    });

    test('should process items in batches', async () => {
      const spy = jest.spyOn(processTree, 'getProcessInfo');
      await processTree.updateVisibleProcesses(0);
      expect(spy).toHaveBeenCalledTimes(30); // batchSize + overscan
    });
  });

  describe('Node Recycling', () => {
    test('should recycle nodes when pool is full', () => {
      // Fill the node pool
      for (let i = 0; i < processTree.nodePool.maxSize + 1; i++) {
        const node = processTree.createNode();
        processTree.nodePool.inUse.set(i, node);
      }

      processTree.recycleNodes();
      expect(processTree.nodePool.available.size).toBeGreaterThan(0);
    });

    test('should reuse recycled nodes', () => {
      const node = processTree.createNode();
      processTree.nodePool.available.add(node);
      const recycledNode = processTree.getRecycledNode({ pid: 1 });
      expect(recycledNode).toBe(node);
    });

    test('should create new node when pool is empty', () => {
      const node = processTree.getRecycledNode({ pid: 1 });
      expect(node.element).toBeDefined();
      expect(node.content).toBeNull();
    });
  });

  describe('Metrics Tracking', () => {
    test('should track render time metrics', async () => {
      const spy = jest.spyOn(processTree, 'trackMetrics');
      await processTree.updateVisibleProcesses(0);
      expect(spy).toHaveBeenCalledWith('renderTime', expect.any(Number));
    });

    test('should limit metrics history', () => {
      // Add metrics beyond history limit
      const limit = processTree.config.monitoring.history;
      for (let i = 0; i < limit + 10; i++) {
        processTree.trackMetrics('renderTime', i);
      }
      expect(processTree.metrics.renderTime.length).toBe(limit);
    });

    test('should cleanup old metrics', () => {
      const now = Date.now();
      processTree.metrics.timestamp = [now - 3600000, now]; // 1 hour old
      processTree.metrics.renderTime = [100, 200];
      processTree.cleanupMetrics();
      expect(processTree.metrics.renderTime.length).toBe(1);
    });
  });

  describe('Error Handling', () => {
    test('should emit error on process info fetch failure', async () => {
      processTree.getProcessInfo.mockRejectedValue(new Error('Fetch failed'));
      const errorSpy = jest.fn();
      processTree.on('error', errorSpy);
      await processTree.updateVisibleProcesses(0);
      expect(errorSpy).toHaveBeenCalled();
    });

    test('should handle cleanup errors gracefully', () => {
      const errorSpy = jest.fn();
      processTree.on('error', errorSpy);
      processTree.processCache.purgeStale = () => {
        throw new Error('Cache error');
      };
      processTree.startCleanup();
      expect(errorSpy).toHaveBeenCalled();
    });
  });

  describe('Resource Cleanup', () => {
    test('should clear all resources on destroy', () => {
      processTree.nodePool.inUse.set(1, processTree.createNode());
      processTree.nodePool.available.add(processTree.createNode());
      processTree.processCache.set(1, mockProcessInfo);
      processTree.metrics.renderTime = [100, 200];

      processTree.destroy();

      expect(processTree.nodePool.inUse.size).toBe(0);
      expect(processTree.nodePool.available.size).toBe(0);
      expect(processTree.processCache.size).toBe(0);
      expect(processTree.metrics.renderTime.length).toBe(0);
    });
  });
}); 