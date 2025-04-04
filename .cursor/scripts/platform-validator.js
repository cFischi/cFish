const os = require('os');
const { execSync } = require('child_process');

class PlatformValidator {
  constructor(options = {}) {
    this.options = {
      validateInterval: 5000,
      ...options
    };
    this.platform = os.platform();
    this.isWindows = this.platform === 'win32';
    this.validationResults = new Map();
  }

  async validateAll() {
    console.log('Starting platform validation...');
    
    const results = {
      platform: this.platform,
      timestamp: new Date().toISOString(),
      systemInfo: await this.getSystemInfo(),
      windowsFeatures: this.isWindows ? await this.validateWindowsFeatures() : null,
      performance: await this.validatePerformanceCounters(),
      compatibility: await this.checkCompatibility()
    };

    this.validationResults.set('latest', results);
    return results;
  }

  async getSystemInfo() {
    return {
      platform: this.platform,
      release: os.release(),
      arch: os.arch(),
      cpus: os.cpus().length,
      totalMemory: Math.round(os.totalmem() / (1024 * 1024 * 1024)), // GB
      freeMemory: Math.round(os.freemem() / (1024 * 1024 * 1024)), // GB
      uptime: os.uptime()
    };
  }

  async validateWindowsFeatures() {
    if (!this.isWindows) return null;

    try {
      // Check for TypePerf availability
      execSync('typeperf.exe /?', { stdio: 'ignore' });
      
      // Check for PowerShell availability
      execSync('powershell.exe Get-Host', { stdio: 'ignore' });
      
      return {
        typePerf: true,
        powerShell: true,
        performanceCounters: await this.checkPerformanceCounters()
      };
    } catch (error) {
      console.error('Error validating Windows features:', error.message);
      return {
        typePerf: false,
        powerShell: false,
        performanceCounters: false,
        error: error.message
      };
    }
  }

  async checkPerformanceCounters() {
    if (!this.isWindows) return false;

    try {
      // Try to access a basic performance counter
      execSync('typeperf "\\Processor(_Total)\\% Processor Time" -sc 1', { stdio: 'ignore' });
      return true;
    } catch (error) {
      console.error('Error checking performance counters:', error.message);
      return false;
    }
  }

  async validatePerformanceCounters() {
    const counters = {
      cpu: await this.validateCPUCounters(),
      memory: await this.validateMemoryCounters(),
      disk: await this.validateDiskCounters(),
      network: await this.validateNetworkCounters()
    };

    return {
      timestamp: new Date().toISOString(),
      status: Object.values(counters).every(c => c.available),
      counters
    };
  }

  async validateCPUCounters() {
    if (this.isWindows) {
      try {
        execSync('typeperf "\\Processor(_Total)\\% Processor Time" -sc 1', { stdio: 'ignore' });
        return { available: true, type: 'typeperf' };
      } catch (error) {
        return { available: false, error: error.message };
      }
    }
    
    return { available: true, type: 'os' };
  }

  async validateMemoryCounters() {
    if (this.isWindows) {
      try {
        execSync('typeperf "\\Memory\\Available MBytes" -sc 1', { stdio: 'ignore' });
        return { available: true, type: 'typeperf' };
      } catch (error) {
        return { available: false, error: error.message };
      }
    }
    
    return { available: true, type: 'os' };
  }

  async validateDiskCounters() {
    if (this.isWindows) {
      try {
        execSync('typeperf "\\PhysicalDisk(_Total)\\% Disk Time" -sc 1', { stdio: 'ignore' });
        return { available: true, type: 'typeperf' };
      } catch (error) {
        return { available: false, error: error.message };
      }
    }
    
    return { available: true, type: 'os' };
  }

  async validateNetworkCounters() {
    if (this.isWindows) {
      try {
        execSync('typeperf "\\Network Interface(*)\\Bytes Total/sec" -sc 1', { stdio: 'ignore' });
        return { available: true, type: 'typeperf' };
      } catch (error) {
        return { available: false, error: error.message };
      }
    }
    
    return { available: true, type: 'os' };
  }

  async checkCompatibility() {
    return {
      timestamp: new Date().toISOString(),
      nodeVersion: process.version,
      platform: this.platform,
      compatible: true, // Base compatibility
      features: {
        performanceCounters: await this.checkPerformanceCounters(),
        systemMetrics: true,
        processMetrics: true
      }
    };
  }

  async getHealthStatus() {
    const latest = this.validationResults.get('latest');
    if (!latest) {
      return {
        status: 'unknown',
        message: 'No validation results available'
      };
    }

    const systemInfo = await this.getSystemInfo();
    return {
      status: 'healthy',
      timestamp: new Date().toISOString(),
      systemInfo,
      performanceCounters: latest.performance,
      compatibility: latest.compatibility
    };
  }

  async generateReport() {
    const latest = this.validationResults.get('latest');
    if (!latest) {
      await this.validateAll();
    }

    return {
      timestamp: new Date().toISOString(),
      validation: this.validationResults.get('latest'),
      health: await this.getHealthStatus()
    };
  }
}

module.exports = { PlatformValidator }; 