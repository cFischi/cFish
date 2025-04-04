const TestResourceManager = require('./test-resource-manager');
const TestMetricsMonitor = require('./test-metrics');
const fs = require('fs').promises;
const path = require('path');
const StagedInstaller = require('./staged-installer');
const ResourceMonitor = require('./resource-monitor');
const config = require('../config/test-environment');
const { 
  runValidation,
  validateResourceMonitor,
  validateProgressMonitor,
  validateStagedInstaller
} = require('./test-validation');
const TestMetricsCollector = require('./test-metrics');
const ResourceDashboard = require('./resource-dashboard');
const PlatformValidationRunner = require('./validate-platforms');

class TestRunner {
  constructor(options = {}) {
    this.options = {
      testDir: path.join(__dirname, '../test-metrics'),
      parallelTests: 3,
      retries: 2,
      timeout: 30000,
      warningThreshold: 70,
      criticalThreshold: 90,
      ...options
    };

    this.metrics = new TestMetricsCollector(this.options);
    this.platformValidator = new PlatformValidationRunner(this.options);
    this.results = {
      tests: [],
      coverage: null,
      validation: null,
      startTime: null,
      endTime: null,
      duration: null
    };
  }

  async initialize() {
    try {
      await this.metrics.initialize();
      console.log('Test runner initialized');
    } catch (error) {
      console.error('Failed to initialize test runner:', error);
      throw error;
    }
  }

  async runTest(test) {
    const result = {
      name: test.name,
      status: 'pending',
      startTime: Date.now(),
      endTime: null,
      duration: null,
      error: null,
      retries: 0
    };

    try {
      for (let attempt = 0; attempt <= this.options.retries; attempt++) {
        if (attempt > 0) {
          console.log(`Retrying test "${test.name}" (attempt ${attempt + 1}/${this.options.retries + 1})`);
          await new Promise(resolve => setTimeout(resolve, 1000 * attempt));
        }

        try {
          await test.run();
          result.status = 'passed';
          break;
        } catch (error) {
          result.status = 'failed';
          result.error = error;
          result.retries = attempt + 1;
          
          if (attempt === this.options.retries) {
            console.error(`Test "${test.name}" failed after ${attempt + 1} attempts:`, error);
          }
        }
      }
    } catch (error) {
      result.status = 'failed';
      result.error = error;
      console.error(`Test "${test.name}" failed with error:`, error);
    } finally {
      result.endTime = Date.now();
      result.duration = result.endTime - result.startTime;
    }

    return result;
  }

  async runTestSuite(tests) {
    console.log('Starting test suite execution...');
    this.results.startTime = Date.now();

    try {
      // Start metrics collection
      await this.metrics.startCollection();

      // Record setup timing
      const setupStart = Date.now();
      await this.initialize();
      this.metrics.recordTiming('setup', Date.now() - setupStart);

      // Run tests
      const executionStart = Date.now();
      const testPromises = [];
      
      for (let i = 0; i < tests.length; i += this.options.parallelTests) {
        const batch = tests.slice(i, i + this.options.parallelTests);
        const batchPromises = batch.map(test => this.runTest(test));
        const batchResults = await Promise.all(batchPromises);
        
        for (const result of batchResults) {
          this.results.tests.push(result);
          this.metrics.recordTestResult(result);
        }
      }

      this.metrics.recordTiming('execution', Date.now() - executionStart);

      // Run platform validation
      console.log('\nRunning platform validation...');
      this.results.validation = await this.platformValidator.validateAll();

      // Generate coverage report
      if (global.__coverage__) {
        this.results.coverage = global.__coverage__;
        this.metrics.recordCoverage(this.results.coverage);
      }

    } catch (error) {
      console.error('Test suite execution failed:', error);
      throw error;
    } finally {
      // Record cleanup timing
      const cleanupStart = Date.now();
      await this.cleanup();
      this.metrics.recordTiming('cleanup', Date.now() - cleanupStart);

      // Stop metrics collection
      await this.metrics.stopCollection();

      // Calculate final timing
      this.results.endTime = Date.now();
      this.results.duration = this.results.endTime - this.results.startTime;
    }

    await this.generateReport();
    return this.results;
  }

  async cleanup() {
    try {
      // Cleanup tasks here
      console.log('Cleaning up test environment...');
    } catch (error) {
      console.error('Cleanup failed:', error);
      // Don't throw - cleanup failure shouldn't break the main process
    }
  }

  async generateReport() {
    try {
      const summary = await this.metrics.generateSummaryReport();
      
      const report = {
        timestamp: new Date().toISOString(),
        duration: this.results.duration,
        tests: {
          total: this.results.tests.length,
          passed: this.results.tests.filter(t => t.status === 'passed').length,
          failed: this.results.tests.filter(t => t.status === 'failed').length,
          skipped: this.results.tests.filter(t => t.status === 'skipped').length
        },
        coverage: this.results.coverage,
        validation: this.results.validation,
        metrics: summary
      };

      // Update memory.md with test results
      const memoryEntry = `## Test Suite Execution Results (${new Date().toLocaleDateString()})

### Test Summary
- Total Tests: ${report.tests.total}
- Passed: ${report.tests.passed}
- Failed: ${report.tests.failed}
- Skipped: ${report.tests.skipped}
- Duration: ${report.duration}ms

### Coverage
${report.coverage ? `- Statements: ${report.coverage.statements}%
- Branches: ${report.coverage.branches}%
- Functions: ${report.coverage.functions}%
- Lines: ${report.coverage.lines}%` : '- No coverage data available'}

### Performance
- Memory Usage: ${report.metrics.performance.memory.delta}
- Peak Memory: ${report.metrics.performance.memory.peak}
- Total Time: ${report.metrics.performance.timing.total}

### Status: ${report.tests.failed === 0 ? 'PASSED' : 'FAILED'}

### Next Steps
${report.tests.failed === 0 ? 
`1. Review performance metrics
2. Optimize resource usage
3. Enhance test coverage
4. Add integration tests
5. Document test patterns` : 
`1. Investigate test failures
2. Fix identified issues
3. Add regression tests
4. Re-run test suite
5. Update documentation`}

_Updated ${new Date().toLocaleDateString()} | AI: Cursor (Claude 3.7 Sonnet)_
`;

      const memoryFile = path.join(__dirname, '../md/memory.md');
      const currentContent = await fs.readFile(memoryFile, 'utf8');
      await fs.writeFile(memoryFile, memoryEntry + '\n\n' + currentContent);

      return report;
    } catch (error) {
      console.error('Failed to generate test report:', error);
      throw error;
    }
  }
}

module.exports = TestRunner;

// Execute tests if run directly
if (require.main === module) {
  const runner = new TestRunner();
  runner.runTestSuite([
    // Add test cases here
  ]).catch(console.error);
}

async function runTests() {
  console.log('Starting test suite...');
  
  try {
    // Run individual component tests
    console.log('\n=== Component Tests ===\n');
    
    console.log('Testing Enhanced Resource Monitor...');
    await validateResourceMonitor();
    
    console.log('\nTesting Install Progress Monitor...');
    await validateProgressMonitor();
    
    console.log('\nTesting Staged Installer...');
    await validateStagedInstaller();
    
    // Run integration validation
    console.log('\n=== Integration Tests ===\n');
    await runValidation();
    
    console.log('\nAll tests completed successfully!');
  } catch (error) {
    console.error('\nTest suite failed:', error);
    process.exit(1);
  }
}

// Run tests if called directly
if (require.main === module) {
  runTests();
}

module.exports = { runTests }; 