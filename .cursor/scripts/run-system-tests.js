const { createLogger } = require('./logger');
const SafeInstaller = require('./safe-install');
const verifyDependencies = require('./verify-dependencies');
const path = require('path');
const fs = require('fs').promises;
const os = require('os');

const logger = createLogger('system-tests');

class SystemTests {
  constructor() {
    this.tests = {
      core: this.testCore.bind(this),
      monitoring: this.testMonitoring.bind(this),
      all: this.testAll.bind(this)
    };
    this.maxRetries = 3;
    this.retryDelay = 2000;
    this.isWindows = process.platform === 'win32';
  }

  async run(testType = 'all') {
    try {
      logger.info(`Starting system tests: ${testType} on ${os.platform()} ${os.release()}`);
      
      const testFn = this.tests[testType];
      if (!testFn) {
        throw new Error(`Unknown test type: ${testType}`);
      }

      await this.withRetry(() => testFn());
      
      logger.info('System tests completed successfully');
      await this.saveTestResults('success');
    } catch (error) {
      logger.error(`System tests failed: ${error.message}`);
      await this.saveTestResults('failure', error);
      throw error;
    }
  }

  async withRetry(fn, retries = this.maxRetries) {
    for (let attempt = 1; attempt <= retries; attempt++) {
      try {
        return await fn();
      } catch (error) {
        if (attempt === retries) throw error;
        logger.warn(`Attempt ${attempt} failed, retrying in ${this.retryDelay}ms: ${error.message}`);
        await new Promise(resolve => setTimeout(resolve, this.retryDelay));
      }
    }
  }

  async testCore() {
    logger.info('Testing core functionality...');

    // Test dependency verification with retry
    const deps = await this.withRetry(async () => {
      const result = await verifyDependencies();
      if (result.results.missing.length > 0) {
        throw new Error(`Missing dependencies: ${result.results.missing.join(', ')}`);
      }
      if (result.results.errors.length > 0) {
        throw new Error(`Dependency errors: ${JSON.stringify(result.results.errors)}`);
      }
      return result;
    });

    // Test installation process with enhanced error handling
    const installer = new SafeInstaller();
    await this.withRetry(() => installer.run());

    // Verify installation state with platform-specific checks
    await this.withRetry(async () => {
      const stateFile = path.join(__dirname, '../metrics/installation-state.json');
      const state = JSON.parse(await fs.readFile(stateFile, 'utf8'));
      if (state.status !== 'complete') {
        throw new Error('Installation state indicates incomplete process');
      }
      return state;
    });

    logger.info('Core functionality tests passed');
  }

  async testMonitoring() {
    logger.info('Testing monitoring functionality...');

    // Test directory access with enhanced error handling
    await this.withRetry(async () => {
      const dirs = ['../logs', '../metrics'];
      for (const dir of dirs) {
        try {
          await fs.access(path.join(__dirname, dir));
          logger.info(`Directory ${dir} is accessible`);
        } catch (error) {
          throw new Error(`Failed to access ${dir}: ${error.message}`);
        }
      }
    });

    // Windows-specific process monitoring checks
    if (this.isWindows) {
      await this.testWindowsProcessMonitoring();
    }

    // Verify monitoring dependencies with platform awareness
    await this.withRetry(async () => {
      const deps = await verifyDependencies();
      const monitoringDeps = this.isWindows 
        ? ['systeminformation', 'node-os-utils', 'windows-process-tree']
        : ['systeminformation', 'node-os-utils'];
      
      for (const dep of monitoringDeps) {
        if (!deps.results.verified.includes(dep)) {
          throw new Error(`Required monitoring dependency not verified: ${dep}`);
        }
      }
    });

    logger.info('Monitoring functionality tests passed');
  }

  async testWindowsProcessMonitoring() {
    logger.info('Testing Windows-specific process monitoring...');
    try {
      // Test Windows process information access
      const { snapshot } = require('process-list');
      const processes = await snapshot('pid', 'name', 'ppid');
      
      if (!processes || processes.length === 0) {
        throw new Error('No processes found in process list');
      }
      
      // Verify we can read process information
      const processInfo = processes[0];
      if (!processInfo.pid || !processInfo.name || !processInfo.ppid) {
        throw new Error('Failed to read process information');
      }
      
      logger.info(`Windows process monitoring test passed (found ${processes.length} processes)`);
    } catch (error) {
      throw new Error(`Windows process monitoring test failed: ${error.message}`);
    }
  }

  async testAll() {
    logger.info('Running all system tests...');
    await this.testCore();
    await this.testMonitoring();
    logger.info('All system tests passed');
  }

  async saveTestResults(status, error = null) {
    const resultsFile = path.join(__dirname, '../metrics/test-results.json');
    const results = {
      timestamp: new Date().toISOString(),
      platform: {
        os: os.platform(),
        release: os.release(),
        arch: os.arch()
      },
      status,
      error: error ? {
        message: error.message,
        stack: error.stack,
        code: error.code
      } : null
    };

    await fs.mkdir(path.dirname(resultsFile), { recursive: true });
    await fs.writeFile(resultsFile, JSON.stringify(results, null, 2));
  }
}

// Parse command line arguments
function parseArgs() {
  const args = process.argv.slice(2);
  const options = {
    testType: 'all'
  };

  for (const arg of args) {
    if (arg === '--core-only') options.testType = 'core';
    if (arg === '--monitoring-only') options.testType = 'monitoring';
  }

  return options;
}

// Run tests if called directly
if (require.main === module) {
  const options = parseArgs();
  const tests = new SystemTests();
  tests.run(options.testType).catch(error => {
    logger.error('Tests failed:', error);
    process.exit(1);
  });
}

module.exports = SystemTests; 