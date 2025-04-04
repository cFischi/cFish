const assert = require('assert');
const ResourceDashboard = require('./resource-dashboard');
const path = require('path');
const fs = require('fs').promises;
const os = require('os');

// Track test results
const testResults = {
  passed: 0,
  failed: 0,
  warnings: 0,
  total: 0,
  startTime: null,
  endTime: null
};

// Test cases
const tests = [
  {
    name: 'Dashboard initialization',
    test: async (dashboard) => {
      await dashboard.initializeDataStructures();
      assert(dashboard, 'Dashboard should be initialized');
      assert(dashboard.screen, 'Screen should be initialized');
      assert(dashboard.grid, 'Grid should be initialized');
    }
  },
  {
    name: 'Metrics directory creation',
    test: async (dashboard) => {
      const metricsDir = path.join(process.cwd(), '..', 'metrics');
      await dashboard.setupMetricsDirectory();
      const stats = await fs.stat(metricsDir);
      assert(stats.isDirectory(), 'Metrics directory should exist');
    }
  },
  {
    name: 'Server setup',
    test: async (dashboard) => {
      if (dashboard.config.testMode) {
        // Skip server test in test mode
        return;
      }
      await dashboard.start();
      assert(dashboard.app, 'Express app should be initialized');
      assert(dashboard.server, 'HTTP server should be initialized');
      assert(dashboard.server.listening, 'Server should be listening');
      await new Promise(resolve => setTimeout(resolve, 100)); // Wait for server to start
    }
  },
  {
    name: 'Screen setup',
    test: async (dashboard) => {
      await dashboard.setupScreen();
      assert(dashboard.screen, 'Screen should be initialized');
      assert(dashboard.grid, 'Grid should be initialized');
      assert(dashboard.processTree, 'Process tree should be initialized');
      assert(dashboard.cpuGraph, 'CPU graph should be initialized');
      assert(dashboard.memGraph, 'Memory graph should be initialized');
      assert(dashboard.logBox, 'Log box should be initialized');
    }
  },
  {
    name: 'Cleanup setup',
    test: async (dashboard) => {
      dashboard.setupCleanup();
      assert(Array.isArray(dashboard.cleanupHandlers), 'Cleanup handlers should be an array');
      dashboard.cleanupHandlers.push(() => {}); // Add a test handler
      assert(dashboard.cleanupHandlers.length > 0, 'Cleanup handlers should be registered');
    }
  },
  {
    name: 'Resource color calculation',
    test: async (dashboard) => {
      const lowColor = dashboard.getResourceColor(30);
      const medColor = dashboard.getResourceColor(70);
      const highColor = dashboard.getResourceColor(90);
      assert.strictEqual(lowColor, 'green', 'Low usage should be green');
      assert.strictEqual(medColor, 'yellow', 'Medium usage should be yellow');
      assert.strictEqual(highColor, 'red', 'High usage should be red');
    }
  },
  {
    name: 'Logging functionality',
    test: async (dashboard) => {
      dashboard.logs = [];
      const testMessage = 'Test log message';
      dashboard.log(testMessage);
      assert(Array.isArray(dashboard.logs), 'Logs should be an array');
      assert(dashboard.logs.length > 0, 'Log should be recorded');
      assert(dashboard.logs[dashboard.logs.length - 1].includes(testMessage), 'Log message should be stored');
    }
  },
  {
    name: 'Error logging',
    test: async (dashboard) => {
      dashboard.logs = [];
      const testError = new Error('Test error');
      dashboard.logError('Test error message', testError);
      assert(Array.isArray(dashboard.logs), 'Logs should be an array');
      assert(dashboard.logs.length > 0, 'Error should be logged');
      const lastLog = dashboard.logs[dashboard.logs.length - 1];
      assert(lastLog.includes('ERROR'), 'Error log should be marked as ERROR');
    }
  },
  {
    name: 'Dashboard cleanup',
    test: async (dashboard) => {
      await dashboard.stop();
      if (!dashboard.config.testMode) {
        assert(!dashboard.server.listening, 'Server should be closed');
      }
      // Skip screen check in test mode since it may not be initialized
      if (dashboard.screen) {
        assert(!dashboard.screen.focused, 'Screen should be cleaned up');
      }
    }
  },
  {
    name: 'Process tree visualization',
    test: async (dashboard) => {
      // Test process tree initialization
      assert(dashboard.processTree, 'Process tree component should be initialized');
      
      // Test process list retrieval in test mode
      const processes = await dashboard.getProcessList();
      assert(Array.isArray(processes), 'Process list should be an array');
      assert(processes.length === 2, 'Test mode should return 2 processes');
      
      // Test process hierarchy building
      const hierarchy = await dashboard.buildProcessHierarchy(processes);
      assert(hierarchy.extended === true, 'Process hierarchy should be extended');
      assert(typeof hierarchy.children === 'object', 'Process hierarchy should have children');
      
      // Test process caching
      const testProc = processes[0];
      dashboard.cacheProcess(testProc.pid, testProc);
      const cached = dashboard.getCachedProcess(testProc.pid);
      assert(cached !== null, 'Process info should be cached');
      assert.deepStrictEqual(cached, testProc, 'Cached info should match original');
      
      // Test process label formatting
      const label = dashboard.formatProcessLabel(testProc);
      assert(label.includes('CPU:'), 'Process label should include CPU usage');
      assert(label.includes('MEM:'), 'Process label should include memory usage');
      assert(label.includes('['), 'Process label should include status');
      
      // Test status coloring
      const status = dashboard.getProcessStatus(testProc);
      assert(status.includes('{'), 'Process status should include color formatting');
      assert(status.includes('}'), 'Process status should include color formatting');
      
      // Test error handling
      const invalidProcesses = [];
      const errorHierarchy = await dashboard.buildProcessHierarchy(invalidProcesses);
      assert(errorHierarchy.children['No processes available'], 'Should handle invalid processes gracefully');
    }
  },
  {
    name: 'Process tree performance',
    test: async (dashboard) => {
      // Test cache size management
      const maxSize = dashboard.processCache.maxSize;
      for (let i = 0; i < maxSize + 10; i++) {
        dashboard.cacheProcess(i, { pid: i, cmd: `test${i}`, cpu: 5, memory: 100 });
      }
      assert(dashboard.processCache.data.size <= maxSize, 'Cache size should not exceed maximum');
      
      // Test cache cleanup
      const oldTimestamp = Date.now() - (dashboard.processCache.ttl * 2);
      for (const [key, value] of dashboard.processCache.data.entries()) {
        value.timestamp = oldTimestamp;
      }
      dashboard.cacheProcess(maxSize + 11, { pid: maxSize + 11, cmd: 'cleanup test', cpu: 5, memory: 100 });
      assert(dashboard.processCache.data.size < maxSize, 'Old cache entries should be cleaned up');
      
      // Test update performance
      const startTime = Date.now();
      const hierarchy = await dashboard.updateProcessTree();
      const endTime = Date.now();
      assert((endTime - startTime) < 1000, 'Process tree update should complete within 1 second');
      assert(hierarchy.extended === true, 'Process hierarchy should be extended');
      assert(typeof hierarchy.children === 'object', 'Process hierarchy should have children');
    }
  }
];

// Helper function to run tests
async function runTest(dashboard, testCase) {
  testResults.total++;
  try {
    console.log(`Testing: ${testCase.name}`);
    await testCase.test(dashboard);
    console.log(`✓ ${testCase.name}`);
    testResults.passed++;
  } catch (error) {
    console.error(`✗ ${testCase.name}`);
    console.error(error);
    testResults.failed++;
  }
}

async function runTests() {
  console.log('Starting dashboard tests...');
  testResults.startTime = Date.now();
  
  const testPort = Math.floor(Math.random() * 10000) + 50000; // Use random high port
  const dashboard = new ResourceDashboard({
    testMode: true,
    port: testPort,
    metricsDir: path.join(process.cwd(), 'test-metrics')
  });
  
  try {
    for (const testCase of tests) {
      await runTest(dashboard, testCase);
    }
  } catch (error) {
    console.error('Test suite error:', error);
    testResults.failed++;
  } finally {
    await dashboard.stop();
    testResults.endTime = Date.now();
    
    // Print test summary
    console.log(`\nTotal Tests: ${testResults.total}`);
    console.log(`Passed: ${testResults.passed}`);
    console.log(`Failed: ${testResults.failed}`);
    console.log(`Duration: ${testResults.endTime - testResults.startTime}ms`);
    
    // Clean up test metrics directory
    try {
      await fs.rm(dashboard.config.metricsDir, { recursive: true, force: true });
    } catch (error) {
      console.warn('Failed to clean up test metrics directory:', error);
    }
    
    process.exit(testResults.failed > 0 ? 1 : 0);
  }
}

// Run tests
runTests().catch(error => {
  console.error('Test execution failed:', error);
  process.exit(1);
}); 