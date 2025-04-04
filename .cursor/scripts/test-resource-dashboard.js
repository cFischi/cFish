const assert = require('assert');
const path = require('path');
const fs = require('fs/promises');
const ResourceDashboard = require('./resource-dashboard');
const os = require('os');
const { exec } = require('child_process');

const testResults = {
  passed: 0,
  failed: 0,
  total: 0,
  warnings: 0,
  startTime: null,
  endTime: null,
  duration: null
};

async function runTest(name, testFn) {
  testResults.total++;
  console.log(`\nRunning test: ${name}`);
  
  try {
    await testFn();
    console.log(`✓ ${name} passed`);
    testResults.passed++;
  } catch (error) {
    console.error(`✗ ${name} failed:`, error.message);
    testResults.failed++;
    throw error; // Re-throw to stop test suite on first failure
  }
}

async function validateMetrics(metrics) {
  assert(metrics.memory !== undefined, 'Memory metrics should be present');
  assert(metrics.cpu !== undefined, 'CPU metrics should be present');
  assert(metrics.processes !== undefined, 'Process metrics should be present');
  assert(typeof metrics.memory === 'number', 'Memory metrics should be numeric');
  assert(typeof metrics.cpu === 'number', 'CPU metrics should be numeric');
  assert(Array.isArray(metrics.processes), 'Process metrics should be an array');
  assert(metrics.memory >= 0 && metrics.memory <= 100, 'Memory usage should be between 0-100%');
  assert(metrics.cpu >= 0 && metrics.cpu <= 100, 'CPU usage should be between 0-100%');
  
  // Validate process information
  metrics.processes.forEach((process, index) => {
    assert(process.pid !== undefined, `Process ${index} should have PID`);
    assert(process.name !== undefined, `Process ${index} should have name`);
    assert(process.memory !== undefined, `Process ${index} should have memory usage`);
    assert(process.cpu !== undefined, `Process ${index} should have CPU usage`);
    assert(process.memory >= 0 && process.memory <= 100, `Process ${index} memory usage should be between 0-100%`);
    assert(process.cpu >= 0 && process.cpu <= 100, `Process ${index} CPU usage should be between 0-100%`);
  });
}

const testMetricsDir = path.join(os.tmpdir(), 'test-metrics');
let dashboard = null;

async function killPort(port) {
  return new Promise((resolve, reject) => {
    const command = process.platform === 'win32'
      ? `netstat -ano | findstr :${port}`
      : `lsof -i :${port}`;
    
    exec(command, (error, stdout, stderr) => {
      if (error) {
        // No process found on port
        resolve();
        return;
      }
      
      try {
        if (process.platform === 'win32') {
          const lines = stdout.split('\n');
          const pidMatch = lines[0]?.match(/\s+(\d+)\s*$/);
          if (pidMatch && pidMatch[1]) {
            exec(`taskkill /F /PID ${pidMatch[1]}`);
          }
        } else {
          const pid = stdout.split('\n')[1]?.split(/\s+/)[1];
          if (pid) {
            exec(`kill -9 ${pid}`);
          }
        }
        resolve();
      } catch (err) {
        reject(err);
      }
    });
  });
}

async function cleanup() {
  try {
    if (dashboard) {
      await dashboard.close();
    }
    await killPort(3005);
    await fs.rm(testMetricsDir, { recursive: true, force: true });
  } catch (error) {
    console.error('Cleanup error:', error);
  }
}

// Add cleanup handlers
process.on('exit', () => {
  try {
    cleanup();
  } catch (error) {
    console.error('Cleanup error:', error);
  }
});

process.on('SIGINT', async () => {
  try {
    await cleanup();
  } catch (error) {
    console.error('Cleanup error:', error);
  }
  process.exit();
});

process.on('uncaughtException', async (error) => {
  console.error('Uncaught exception:', error);
  try {
    await cleanup();
  } catch (cleanupError) {
    console.error('Cleanup error:', cleanupError);
  }
  process.exit(1);
});

async function testResourceDashboard() {
  try {
    // Create test metrics directory
    await fs.mkdir(testMetricsDir, { recursive: true });

    // Initialize dashboard
    dashboard = new ResourceDashboard({
      testMode: true,
      port: 3005,
      metricsDir: testMetricsDir,
      updateInterval: 1000,
      cleanupInterval: 5000,
      warningThreshold: 70,
      criticalThreshold: 90,
      maxHistoryLength: 100,
      maxProcessCache: 50,
      virtualScrolling: {
        itemHeight: 24,
        containerHeight: 480,
        overscanCount: 5,
        batchSize: 10
      }
    });

    // Test dashboard initialization
    console.log('\nStarting ResourceDashboard tests...\n');
    testResults.startTime = Date.now();

    // Test dashboard initialization
    await runTest('Dashboard initialization', async () => {
      assert(dashboard instanceof ResourceDashboard, 'Dashboard should be initialized');
      assert(dashboard.config.testMode === true, 'Test mode should be enabled');
      assert(dashboard.config.warningThreshold === 70, 'Warning threshold should be set');
      assert(dashboard.config.criticalThreshold === 90, 'Critical threshold should be set');
      assert(dashboard.config.updateInterval === 1000, 'Update interval should be set');
      assert(dashboard.config.cleanupInterval === 5000, 'Cleanup interval should be set');
      assert(dashboard.config.maxHistoryLength === 100, 'Max history length should be set');
      assert(dashboard.config.maxProcessCache === 50, 'Max process cache should be set');
    });

    // Test metrics directory creation
    await runTest('Metrics directory creation', async () => {
      const exists = await fs.access(testMetricsDir).then(() => true).catch(() => false);
      assert(exists, 'Metrics directory should exist');
      const stats = await fs.stat(testMetricsDir);
      assert(stats.isDirectory(), 'Metrics path should be a directory');
    });

    // Test server setup
    await runTest('Server setup', async () => {
      assert(dashboard.config.port === 3005, 'Server port should be configured');
      assert(dashboard.server, 'WebSocket server should be initialized');
      assert(typeof dashboard.handleConnection === 'function', 'Connection handler should exist');
      assert(typeof dashboard.broadcastMetrics === 'function', 'Broadcast function should exist');
    });

    // Test screen setup
    await runTest('Screen setup', async () => {
      assert(dashboard.screen && typeof dashboard.screen.render === 'function', 'Screen mock should be initialized');
      assert(dashboard.grid && typeof dashboard.grid.set === 'function', 'Grid mock should be initialized');
      assert(dashboard.processTree && typeof dashboard.processTree.setData === 'function', 'Process tree mock should be initialized');
      assert(dashboard.memoryChart && typeof dashboard.memoryChart.setData === 'function', 'Memory chart mock should be initialized');
      assert(dashboard.cpuChart && typeof dashboard.cpuChart.setData === 'function', 'CPU chart mock should be initialized');
      assert(dashboard.logBox && typeof dashboard.logBox.log === 'function', 'Log box mock should be initialized');
    });

    // Test cleanup setup
    await runTest('Cleanup setup', async () => {
      assert(dashboard.config.cleanupInterval === 5000, 'Cleanup interval should be set');
      assert(typeof dashboard.performCleanup === 'function', 'Cleanup function should exist');
      assert(typeof dashboard.stop === 'function', 'Stop function should exist');
      
      // Test cleanup functionality
      await dashboard.performCleanup();
      assert(dashboard.logs.length <= dashboard.config.maxHistoryLength, 'Logs should be trimmed');
      assert(dashboard.metrics.cpu.length <= dashboard.metrics.maxLength, 'CPU metrics should be trimmed');
      assert(dashboard.metrics.memory.length <= dashboard.metrics.maxLength, 'Memory metrics should be trimmed');
    });

    // Test resource color calculation
    await runTest('Resource color calculation', () => {
      const mockDashboard = {
        config: {
          warningThreshold: 70,
          criticalThreshold: 90
        }
      };

      const getResourceColor = ResourceDashboard.prototype.getResourceColor.bind(mockDashboard);

      assert.strictEqual(getResourceColor(95), 'red', 'Critical usage (>=90%) should be red');
      assert.strictEqual(getResourceColor(75), 'yellow', 'Warning usage (>=70%) should be yellow');
      assert.strictEqual(getResourceColor(50), 'green', 'Normal usage (<70%) should be green');
      assert.strictEqual(getResourceColor(0), 'green', 'Zero usage should be green');
      assert.strictEqual(getResourceColor(100), 'red', 'Maximum usage should be red');
    });

    // Test metrics collection
    await runTest('Metrics collection', async () => {
      const metrics = await dashboard.getMetrics();
      await validateMetrics(metrics);
      assert(metrics.timestamp, 'Metrics should include timestamp');
      assert(metrics.hostname === require('os').hostname(), 'Metrics should include hostname');
    });

    // Test logging functionality
    await runTest('Logging functionality', async () => {
      const testLogs = ['Test log 1', 'Test log 2', 'Test log 3'];
      testLogs.forEach(log => {
        dashboard.log(log);
      });
      assert(dashboard.logBox.content.includes('Test log 1'), 'Log should contain test message 1');
      assert(dashboard.logBox.content.includes('Test log 2'), 'Log should contain test message 2');
      assert(dashboard.logBox.content.includes('Test log 3'), 'Log should contain test message 3');
      assert(dashboard.logs.length <= dashboard.config.maxHistoryLength, 'Logs should not exceed max length');
    });

    // Test error logging
    await runTest('Error logging', async () => {
      const testError = new Error('Test error');
      dashboard.logError('Test error:', testError);
      assert(dashboard.logBox.content.includes('Test error'), 'Log should contain error message');
      assert(dashboard.logBox.content.includes(testError.stack), 'Log should contain error stack');
    });

    // Test WebSocket communication
    await runTest('WebSocket communication', async () => {
      assert(typeof dashboard.broadcastMetrics === 'function', 'Broadcast function should exist');
      const metrics = await dashboard.getMetrics();
      await dashboard.broadcastMetrics(metrics);
    });

    // Test virtual scrolling
    console.log('Testing virtual scrolling...');
    const mockProcesses = Array.from({ length: 1000 }, (_, i) => ({
      pid: i + 1,
      ppid: Math.floor(i / 10) || 1,
      name: `Process ${i + 1}`,
      cpu: Math.random() * 100,
      memory: Math.random() * 100
    }));
    
    dashboard.virtualScroll.items = mockProcesses;
    dashboard.virtualScroll.visibleCount = 20;
    dashboard.virtualScroll.offset = 0;
    
    // Test initial range
    await dashboard.updateVisibleProcesses();
    assert.strictEqual(dashboard.virtualScroll.renderedRange.start, 0, 'Initial start should be 0');
    assert.strictEqual(dashboard.virtualScroll.renderedRange.end, 25, 'Initial end should include overscan');
    
    // Test scrolling
    await dashboard.setScrollOffset(50);
    assert.strictEqual(dashboard.virtualScroll.renderedRange.start, 45, 'Start should update with scroll');
    assert.strictEqual(dashboard.virtualScroll.renderedRange.end, 75, 'End should update with scroll');
    
    // Test scroll bounds
    await dashboard.setScrollOffset(-10);
    assert.strictEqual(dashboard.virtualScroll.offset, 0, 'Offset should be clamped to minimum');
    
    await dashboard.setScrollOffset(1000);
    assert.strictEqual(dashboard.virtualScroll.offset, 980, 'Offset should be clamped to maximum');
    
    console.log('Virtual scrolling tests passed');

    // Test WebSocket load testing
    await runTest('WebSocket load testing', async () => {
      const wsOptimizer = dashboard.wsOptimizer;
      
      // Test metrics initialization
      assert(wsOptimizer.metrics.messagesSent === 0, 'Initial messages sent should be 0');
      assert(wsOptimizer.metrics.errors === 0, 'Initial errors should be 0');
      
      // Test compression
      const largeMessage = {
        type: 'test',
        data: Array(1000).fill('test data')
      };
      
      const compressed = await wsOptimizer.compressMessage(largeMessage);
      assert(compressed.compressed, 'Large message should be compressed');
      assert(wsOptimizer.metrics.compressionRatio > 0, 'Compression ratio should be calculated');
      
      // Test load test execution
      const results = await wsOptimizer.startLoadTest(100, 1);
      assert(results.messagesSent > 0, 'Load test should send messages');
      assert(results.avgLatency >= 0, 'Average latency should be calculated');
      assert(results.maxLatency >= results.avgLatency, 'Max latency should be >= average');
      assert(results.compressionRatio > 0, 'Load test should track compression ratio');
    });

    // Test dashboard cleanup
    console.log('\nRunning test: Dashboard cleanup');
    await dashboard.stop();
    
    try {
      await fs.access(testMetricsDir);
      throw new Error('Test metrics directory still exists after cleanup');
    } catch (err) {
      if (err.code === 'ENOENT') {
        console.log('✓ Dashboard cleanup passed');
      } else {
        throw err;
      }
    }

    // Add path resolution tests
    await runTest('Path resolution performance', async () => {
      const startTime = performance.now();
      const processes = Array.from({ length: 1000 }, (_, i) => ({
        pid: i + 1,
        ppid: Math.floor(i / 10) || 1,
        name: `Process ${i + 1}`,
        info: {
          cpu: Math.random() * 100,
          memory: Math.random() * 100
        }
      }));

      dashboard.virtualScroll.items = processes;
      
      // Test path resolution for each process
      const paths = await Promise.all(processes.map(proc => {
        const pathStartTime = performance.now();
        const path = dashboard.getProcessPath(proc);
        const pathTime = performance.now() - pathStartTime;
        assert(pathTime < 0.5, `Path resolution time (${pathTime}ms) exceeds target (0.5ms)`);
        return path;
      }));

      // Validate paths
      paths.forEach((path, i) => {
        assert(Array.isArray(path), 'Path should be an array');
        assert(path.length > 0, 'Path should not be empty');
        assert(path[path.length - 1].includes(String(i + 1)), 'Path should end with correct process');
      });

      const totalTime = performance.now() - startTime;
      const avgTime = totalTime / processes.length;
      console.log(`Average path resolution time: ${avgTime.toFixed(3)}ms`);
    });

    // Add cache performance tests
    await runTest('Cache performance', async () => {
      const maxSize = 50;
      const testData = Array.from({ length: maxSize * 2 }, (_, i) => ({
        pid: i,
        name: `Process ${i}`,
        cpu: Math.random() * 100,
        memory: Math.random() * 100,
        accessCount: Math.floor(Math.random() * 10) // Simulate varying access patterns
      }));

      // Test cache warm-up
      const warmupStart = performance.now();
      await dashboard.processCache.warmup(testData.slice(0, maxSize));
      const warmupTime = performance.now() - warmupStart;
      console.log(`Cache warm-up time: ${warmupTime.toFixed(2)}ms`);
      assert(warmupTime < 1000, 'Cache warm-up should complete within 1s');

      // Simulate real-world access patterns
      const accessPatterns = 1000;
      for (let i = 0; i < accessPatterns; i++) {
        // 80% of accesses to frequently used items
        const useFrequent = Math.random() < 0.8;
        const pid = useFrequent ? 
          Math.floor(Math.random() * (maxSize * 0.2)) : // Access top 20% frequent items
          Math.floor(Math.random() * maxSize); // Access any cached item
        
        dashboard.getCachedProcess(pid);
      }

      // Test hit rate after simulated usage
      const cacheMetrics = dashboard.processCache.data.getMetrics();
      console.log('Cache metrics after simulation:', cacheMetrics);
      assert(cacheMetrics.hitRate >= 90, 'Cache hit rate should be at least 90%');
      assert(cacheMetrics.averageAccessTime < 0.1, 'Average access time should be under 0.1ms');

      // Test eviction under pressure
      console.log('Testing cache eviction...');
      const beforeSize = dashboard.processCache.data.cache.size;
      testData.slice(maxSize).forEach(proc => {
        dashboard.cacheProcess(proc.pid, proc);
      });
      const afterSize = dashboard.processCache.data.cache.size;
      console.log(`Cache size before: ${beforeSize}, after: ${afterSize}`);
      assert(afterSize <= maxSize, 'Cache size should not exceed maximum');
      assert(afterSize === maxSize, 'Cache should be at maximum capacity');
    });

    // Add cross-platform validation tests
    await runTest('Cross-platform validation', async () => {
      const platforms = ['win32', 'linux', 'darwin'];
      const testProcess = {
        pid: 1,
        name: 'test-process',
        info: {
          cpu: 50,
          memory: 50
        }
      };

      platforms.forEach(platform => {
        const originalPlatform = process.platform;
        Object.defineProperty(process, 'platform', { value: platform });

        try {
          const path = dashboard.getProcessPath(testProcess);
          assert(Array.isArray(path), `Path should be array on ${platform}`);
          assert(path.length > 0, `Path should not be empty on ${platform}`);
          
          const status = dashboard.getProcessStatus(testProcess);
          assert(typeof status === 'string', `Status should be string on ${platform}`);
        } finally {
          Object.defineProperty(process, 'platform', { value: originalPlatform });
        }
      });
    });

    // Add error recovery tests
    await runTest('Error recovery', async () => {
      // Test invalid process handling
      const invalidPath = dashboard.getProcessPath(null);
      assert(Array.isArray(invalidPath), 'Should handle null process');
      assert(invalidPath[0] === 'Unknown', 'Should return Unknown for null process');

      // Test cycle detection
      const cyclicProcess = {
        pid: 1,
        ppid: 2,
        name: 'cyclic1',
        info: {}
      };
      const cyclicParent = {
        pid: 2,
        ppid: 1,
        name: 'cyclic2',
        info: {}
      };
      dashboard.virtualScroll.items = [cyclicProcess, cyclicParent];
      
      const cyclicPath = dashboard.getProcessPath(cyclicProcess);
      assert(cyclicPath.length <= 10, 'Should handle cyclic process relationships');

      // Test error recovery during cache operations
      const errorProcess = {
        pid: 'invalid',
        name: null,
        info: undefined
      };
      dashboard.cacheProcess(errorProcess.pid, errorProcess);
      const recovered = dashboard.getCachedProcess(errorProcess.pid);
      assert(!recovered, 'Should handle invalid cache entries gracefully');
    });

    console.log('\nAll tests completed successfully!');
  } finally {
    testResults.endTime = Date.now();
    testResults.duration = testResults.endTime - testResults.startTime;

    // Print test results
    console.log('\nTest Results:');
    console.log(`Duration: ${testResults.duration}ms`);
    console.log(`Tests Passed: ${testResults.passed}`);
    console.log(`Tests Failed: ${testResults.failed}`);
    console.log(`Warnings: ${testResults.warnings}`);
    console.log(`Total Tests: ${testResults.total}`);

    // Update memory.md with test results
    const memoryEntry = `## Resource Dashboard Test Results (${new Date().toLocaleDateString()})

### Test Execution Summary
- Duration: ${testResults.duration}ms
- Tests Passed: ${testResults.passed}
- Tests Failed: ${testResults.failed}
- Warnings: ${testResults.warnings}
- Total Tests: ${testResults.total}

### Status: ${testResults.failed === 0 ? 'PASSED' : 'FAILED'}

### Next Steps
${testResults.failed === 0 ? `
1. Monitor performance metrics
2. Implement remaining features
3. Enhance error recovery
4. Add process filtering
5. Deploy to production` : `
1. Address failed tests
2. Fix identified issues
3. Re-run test suite
4. Verify fixes
5. Document resolutions`}

_Updated ${new Date().toLocaleDateString()} | AI: Cursor (Claude 3.7 Sonnet)_
`;

    try {
      const memoryFile = path.join(__dirname, '../md/memory.md');
      const currentContent = await fs.readFile(memoryFile, 'utf8');
      await fs.writeFile(memoryFile, memoryEntry + '\n\n' + currentContent);
    } catch (error) {
      console.error('Failed to update memory.md:', error);
    }

    await cleanup();
  }
}

// Export the test function
module.exports = testResourceDashboard;

// Run tests
testResourceDashboard().catch(error => {
  console.error('Test suite failed:', error);
  process.exit(1);
}); 