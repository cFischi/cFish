const { PlatformValidator } = require('./platform-validator');
const path = require('path');
const fs = require('fs').promises;

class PlatformValidationRunner {
  constructor(options = {}) {
    this.options = {
      all: true,
      platforms: [],
      timeout: 30000,
      retries: 3,
      retryDelay: 1000,
      ...options
    };

    this.platforms = {
      windows: {
        name: 'Windows',
        validator: require('./validators/windows'),
        requirements: {
          memory: { min: 4096 }, // 4GB minimum
          cpu: { cores: 2 },
          disk: { free: 10240 } // 10GB minimum
        }
      },
      linux: {
        name: 'Linux',
        validator: require('./validators/linux'),
        requirements: {
          memory: { min: 2048 }, // 2GB minimum
          cpu: { cores: 1 },
          disk: { free: 5120 } // 5GB minimum
        }
      },
      macos: {
        name: 'macOS',
        validator: require('./validators/macos'),
        requirements: {
          memory: { min: 4096 }, // 4GB minimum
          cpu: { cores: 2 },
          disk: { free: 10240 } // 10GB minimum
        }
      }
    };

    this.results = {
      validations: [],
      errors: [],
      warnings: [],
      startTime: null,
      endTime: null,
      duration: null
    };
  }

  async sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  async retryOperation(operation, retries = this.options.retries) {
    let lastError;
    for (let i = 0; i < retries; i++) {
      try {
        return await operation();
      } catch (error) {
        lastError = error;
        console.warn(`Attempt ${i + 1} failed:`, error.message);
        if (i < retries - 1) {
          await this.sleep(this.options.retryDelay * Math.pow(2, i));
        }
      }
    }
    throw lastError;
  }

  async validatePlatform(platform, config) {
    console.log(`\nValidating ${config.name} platform...`);
    
    const result = {
      platform,
      name: config.name,
      status: 'pending',
      requirements: {},
      tests: {},
      warnings: [],
      errors: [],
      startTime: Date.now()
    };

    try {
      // Validate system requirements
      console.log('Checking system requirements...');
      const sysInfo = await this.retryOperation(() => config.validator.getSystemInfo());
      
      result.requirements = {
        memory: {
          required: config.requirements.memory.min,
          actual: sysInfo.memory,
          pass: sysInfo.memory >= config.requirements.memory.min
        },
        cpu: {
          required: config.requirements.cpu.cores,
          actual: sysInfo.cpu.cores,
          pass: sysInfo.cpu.cores >= config.requirements.cpu.cores
        },
        disk: {
          required: config.requirements.disk.free,
          actual: sysInfo.disk.free,
          pass: sysInfo.disk.free >= config.requirements.disk.free
        }
      };

      // Run platform-specific tests
      console.log('Running platform tests...');
      const testResults = await this.retryOperation(() => config.validator.runTests());
      result.tests = testResults;

      // Check for warnings
      if (sysInfo.memory < config.requirements.memory.min * 1.5) {
        result.warnings.push('Memory is close to minimum requirement');
      }
      if (sysInfo.disk.free < config.requirements.disk.free * 1.5) {
        result.warnings.push('Disk space is close to minimum requirement');
      }

      // Determine overall status
      const requirementsPassed = Object.values(result.requirements).every(r => r.pass);
      const testsPassed = Object.values(result.tests).every(t => t.status === 'passed');

      result.status = requirementsPassed && testsPassed ? 'passed' : 'failed';

    } catch (error) {
      result.status = 'failed';
      result.errors.push(error.message);
      console.error(`${config.name} validation failed:`, error);
    }

    result.endTime = Date.now();
    result.duration = result.endTime - result.startTime;

    return result;
  }

  async validateAll() {
    console.log('Starting cross-platform validation...');
    this.results.startTime = Date.now();
    
    const results = {
      timestamp: new Date().toISOString(),
      platforms: {},
      summary: {
        total: 0,
        passed: 0,
        failed: 0,
        warnings: 0,
        startTime: this.results.startTime,
        endTime: null,
        duration: null
      }
    };

    try {
      for (const [platform, config] of Object.entries(this.platforms)) {
        if (this.options.all || this.options.platforms.includes(platform)) {
          console.log(`\nValidating ${config.name}...`);
          const platformResult = await this.validatePlatform(platform, config);
          results.platforms[platform] = platformResult;
          
          // Update summary
          results.summary.total++;
          if (platformResult.status === 'passed') results.summary.passed++;
          if (platformResult.status === 'failed') results.summary.failed++;
          results.summary.warnings += platformResult.warnings.length;

          // Store validation result
          this.results.validations.push(platformResult);
          this.results.warnings.push(...platformResult.warnings);
          this.results.errors.push(...platformResult.errors);
        }
      }
    } catch (error) {
      console.error('Validation process failed:', error);
      this.results.errors.push(error.message);
    }

    this.results.endTime = Date.now();
    this.results.duration = this.results.endTime - this.results.startTime;

    results.summary.endTime = this.results.endTime;
    results.summary.duration = this.results.duration;

    await this.generateReport(results);
    return results;
  }

  async generateReport(results) {
    try {
      const memoryEntry = `## Cross-Platform Validation Results (${new Date().toLocaleDateString()})

### Validation Summary
- Duration: ${results.summary.duration}ms
- Total Platforms: ${results.summary.total}
- Passed: ${results.summary.passed}
- Failed: ${results.summary.failed}
- Warnings: ${results.summary.warnings}

### Platform Details
${Object.entries(results.platforms).map(([platform, result]) => `
#### ${result.name} (${platform})
- Status: ${result.status.toUpperCase()}
- Duration: ${result.duration}ms
${result.warnings.length > 0 ? `- Warnings:\n  ${result.warnings.map(w => `- ${w}`).join('\n  ')}` : ''}
${result.errors.length > 0 ? `- Errors:\n  ${result.errors.map(e => `- ${e}`).join('\n  ')}` : ''}`).join('\n')}

### Next Steps
${results.summary.failed === 0 ? 
`1. Deploy to validated platforms
2. Monitor platform-specific performance
3. Implement automated platform checks
4. Configure platform-specific alerts
5. Document platform requirements` : 
`1. Address platform-specific failures
2. Resolve identified issues
3. Re-run validation suite
4. Update platform requirements
5. Document resolutions`}

_Updated ${new Date().toLocaleDateString()} | AI: Cursor (Claude 3.7 Sonnet)_
`;

      const memoryFile = path.join(__dirname, '../md/memory.md');
      const currentContent = await fs.readFile(memoryFile, 'utf8');
      await fs.writeFile(memoryFile, memoryEntry + '\n\n' + currentContent);
      console.log('Validation report added to memory.md');
    } catch (error) {
      console.error('Failed to generate validation report:', error);
      this.results.errors.push(`Report generation failed: ${error.message}`);
    }
  }
}

// Command line handling
if (require.main === module) {
  const args = process.argv.slice(2);
  const options = {
    all: args.includes('--all'),
    platforms: args.includes('--platforms') ? 
      args[args.indexOf('--platforms') + 1].split(',') : [],
    verbose: args.includes('--verbose')
  };

  const runner = new PlatformValidationRunner(options);
  
  runner.validateAll().catch(error => {
    console.error('Error during platform validation:', error);
    process.exit(1);
  });
}

module.exports = PlatformValidationRunner; 