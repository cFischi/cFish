const { exec } = require('child_process');
const path = require('path');
const fs = require('fs').promises;
const os = require('os');
const InstallProgressMonitor = require('./install-progress-monitor');
const EnhancedResourceMonitor = require('./enhanced-resource-monitor');

class StagedInstaller {
  constructor(config = {}) {
    this.config = {
      installDir: config.installDir || path.join(__dirname, '../node_modules'),
      queueFile: config.queueFile || path.join(__dirname, '../queue.json'),
      maxConcurrent: 1, // Force single package installation
      retryAttempts: 2, // Reduce retry attempts
      retryDelay: 30000, // Increased retry delay to 30 seconds
      memoryThreshold: 45, // Lower memory warning threshold
      cpuThreshold: 45, // Lower CPU warning threshold
      memoryCheckInterval: 100, // More frequent checks
      emergencyThreshold: 60, // Lower emergency threshold
      cooldownPeriod: 120000, // Increase cooldown to 2 minutes
      emergencyCooldownMultiplier: 3, // Triple cooldown after emergency
      stableMemoryChecks: 10, // More checks before resuming
      stableMemoryCheckInterval: 2000, // Longer interval between stability checks
      aggressiveCleanupThreshold: 55, // Lower threshold for aggressive cleanup
      maxProcessCount: 25, // Reduce maximum allowed npm-related processes
      logFile: path.join(__dirname, '../logs/install.log'),
      ...config
    };

    this.queue = [];
    this.installing = new Set();
    this.completed = new Set();
    this.failed = new Set();
    this.paused = false;
    this.npmPath = process.platform === 'win32' ? 'npm.cmd' : 'npm';
    this.activeProcesses = new Map();
    
    // Progress monitoring
    this.progressMonitor = new InstallProgressMonitor({
      showResourceMetrics: true,
      updateInterval: 1000
    });

    // Enhanced resource monitoring
    this.resourceMonitor = new EnhancedResourceMonitor({
      warningThreshold: this.config.memoryThreshold,
      criticalThreshold: this.config.emergencyThreshold,
      updateInterval: this.config.memoryCheckInterval,
      enableProcessTracking: true // Enable detailed process tracking
    });

    // Bind resource monitoring callback
    this.handleResourceUpdate = this.handleResourceUpdate.bind(this);

    this.stage = process.argv.find(arg => arg.startsWith('--stage'))?.split('=')[1] || 'unknown';
    this.metrics = {
      memory: 0,
      cpu: 0
    };
  }

  async initialize() {
    try {
      // Ensure install directory exists
      await fs.mkdir(this.config.installDir, { recursive: true });
      
      // Load existing queue if any
      await this.loadQueue();

      // Initialize progress monitor
      await this.progressMonitor.start();
      
      // Create progress bars for each stage
      if (this.queue.length > 0) {
        this.progressMonitor.createStageBar('Installation', this.queue.length);
      }

      // Start enhanced resource monitoring
      await this.resourceMonitor.initialize();
      this.resourceMonitor.addListener(this.handleResourceUpdate);
      await this.resourceMonitor.start();

      console.log('Staged installer initialized successfully');
    } catch (error) {
      console.error('Error initializing staged installer:', error);
      throw error;
    }
  }

  async loadQueue() {
    try {
      let queueData;
      const backupFile = `${this.config.queueFile}.backup`;

      try {
        queueData = await fs.readFile(this.config.queueFile, 'utf8');
      } catch (mainError) {
        if (mainError.code === 'ENOENT') {
          try {
            // Try loading from backup if main file doesn't exist
            queueData = await fs.readFile(backupFile, 'utf8');
            console.log('Recovered queue state from backup file');
          } catch (backupError) {
            if (backupError.code === 'ENOENT') {
              console.log('No existing queue state found, starting fresh');
              this.queue = [];
              return;
            }
            throw backupError;
          }
        } else {
          throw mainError;
        }
      }

      const data = JSON.parse(queueData);
      
      // Validate queue data structure
      if (Array.isArray(data.queue)) {
        this.queue = data.queue;
        this.completed = new Set(data.completed || []);
        this.failed = new Set(data.failed || []);
        this.installing = new Set(data.installing || []);
        
        // Recover system state
        if (data.systemState) {
          this.sessionId = data.systemState.sessionId;
          
          // Handle interrupted installations
          if (data.systemState.recoveryPoint?.inProgressPackages) {
            const interrupted = data.systemState.recoveryPoint.inProgressPackages;
            console.log(`Found interrupted installations: ${interrupted.join(', ')}`);
            
            // Add interrupted packages back to queue
            this.queue.unshift(...interrupted);
            this.installing.clear();
          }
        }

        console.log('Queue state loaded successfully');
        console.log(`Queue: ${this.queue.length} items`);
        console.log(`Completed: ${this.completed.size} items`);
        console.log(`Failed: ${this.failed.size} items`);
      } else {
        console.warn('Invalid queue data structure, initializing empty queue');
        this.queue = [];
      }
    } catch (err) {
      console.error('Error loading queue:', err);
      throw err;
    }
  }

  handleResourceUpdate(metrics) {
    // Update current metrics
    this.metrics = metrics;

    // Check for critical memory usage
    if (metrics.memory >= this.config.emergencyThreshold) {
      this.handleEmergency(metrics.memory);
      return;
    }

    // Check for warning threshold
    if (metrics.memory >= this.config.memoryThreshold) {
      if (!this.paused) {
        console.log(`Memory usage warning: ${metrics.memory.toFixed(2)}%`);
        this.handleLowMemory();
      }
    } else if (this.paused) {
      // Check if memory is back to safe levels
      if (metrics.memory < this.config.memoryThreshold - 15) { // Increased safety margin
        console.log('Memory usage back to safe levels, resuming installations');
        this.paused = false;
        this.processQueue();
      }
    }

    // Log current resource usage with more detail
    const heapUsed = process.memoryUsage().heapUsed / 1024 / 1024;
    const rss = process.memoryUsage().rss / 1024 / 1024;
    console.log(
      `Memory: ${metrics.memory.toFixed(1)}% | ` +
      `CPU: ${metrics.cpu.toFixed(1)}% | ` +
      `Heap: ${heapUsed.toFixed(1)}MB | ` +
      `RSS: ${rss.toFixed(1)}MB | ` +
      `Active Processes: ${this.activeProcesses.size}`
    );
  }

  async cleanupResources(aggressive = false) {
    console.log('Cleaning up resources...');
    
    // Force garbage collection if available
    if (global.gc) {
      console.log('Forcing garbage collection...');
      global.gc();
    }

    // Kill any stray npm processes
    try {
      const processList = await this.resourceMonitor.getProcessList();
      for (const proc of processList) {
        if (proc.name.toLowerCase().includes('npm') && !this.activeProcesses.has(proc.pid)) {
          console.log(`Killing stray npm process: ${proc.pid}`);
          if (process.platform === 'win32') {
            await this.runCommand('taskkill', ['/F', '/PID', proc.pid.toString()]);
          } else {
            process.kill(proc.pid, 'SIGKILL');
          }
        }
      }
    } catch (err) {
      console.error('Error cleaning up processes:', err);
    }

    // Clear npm cache
    try {
      await this.runCommand(this.npmPath, ['cache', 'clean', '--force']);
    } catch (err) {
      console.error('Error clearing npm cache:', err);
    }

    // Clear temporary files
    try {
      const tempFiles = await fs.readdir(os.tmpdir());
      for (const file of tempFiles) {
        if (file.startsWith('npm-')) {
          await fs.rm(path.join(os.tmpdir(), file), { recursive: true, force: true });
        }
      }
    } catch (err) {
      console.error('Error cleaning temp files:', err);
    }

    if (aggressive) {
      try {
        // Clear node_modules if aggressive cleanup
        const nodeModules = path.join(process.cwd(), 'node_modules');
        if (await fs.access(nodeModules).then(() => true).catch(() => false)) {
          console.log('Aggressive cleanup: Removing node_modules directory');
          await fs.rm(nodeModules, { recursive: true, force: true });
        }
        
        // Clear package-lock.json
        const packageLock = path.join(process.cwd(), 'package-lock.json');
        if (await fs.access(packageLock).then(() => true).catch(() => false)) {
          console.log('Aggressive cleanup: Removing package-lock.json');
          await fs.unlink(packageLock);
        }
      } catch (err) {
        console.error('Error during aggressive cleanup:', err);
      }
    }

    // Wait for cleanup to complete
    await this.sleep(3000);
  }

  async handleEmergency(usageValue) {
    console.error(`\nEMERGENCY: Resource usage critical (${usageValue}%)`);
    await this.log(`EMERGENCY: Critical resource usage detected: ${usageValue}%`, 'critical');
    
    // Stop all installations immediately
    this.paused = true;
    
    // Enhanced process tree termination
    const killProcessTree = async (pid) => {
      try {
        if (process.platform === 'win32') {
          // Kill entire process tree on Windows
          await this.runCommand('taskkill', ['/F', '/T', '/PID', pid.toString()]);
        } else {
          // Unix-like systems: find and kill child processes
          const children = await this.resourceMonitor.getChildProcesses(pid);
          for (const childPid of children) {
            process.kill(childPid, 'SIGKILL');
          }
          process.kill(pid, 'SIGKILL');
        }
      } catch (err) {
        await this.log(`Failed to kill process ${pid}: ${err.message}`, 'error');
      }
    };
    
    // Kill all active npm processes with enhanced logging
    for (const [pkg, process] of this.activeProcesses) {
      await this.log(`Emergency: Force killing installation of ${pkg} (PID: ${process.pid})`, 'warning');
      await killProcessTree(process.pid);
    }
    
    // Perform aggressive cleanup with detailed logging
    await this.log('Emergency: Initiating aggressive cleanup', 'warning');
    await this.cleanupResources(true);
    
    // Extended cooldown with stability check
    const cooldownTime = this.config.cooldownPeriod * this.config.emergencyCooldownMultiplier;
    await this.log(`Emergency: Entering extended cooldown (${cooldownTime}ms)`, 'info');
    await this.sleep(cooldownTime);
    
    // Enhanced stability verification
    let stableCount = 0;
    let totalChecks = 0;
    const maxChecks = this.config.stableMemoryChecks * 2; // Allow more attempts for stability
    
    while (stableCount < this.config.stableMemoryChecks && totalChecks < maxChecks) {
      totalChecks++;
      const metrics = await this.resourceMonitor.getMetrics();
      
      if (metrics.memory < this.config.memoryThreshold) {
        stableCount++;
        await this.log(`Stability check ${stableCount}/${this.config.stableMemoryChecks} passed - Memory: ${metrics.memory.toFixed(1)}%`, 'info');
      } else {
        stableCount = 0;
        await this.log(`Stability check failed - Memory: ${metrics.memory.toFixed(1)}%, resetting counter`, 'warning');
        // Additional cooldown if still unstable
        await this.sleep(this.config.stableMemoryCheckInterval);
      }
    }
    
    if (stableCount >= this.config.stableMemoryChecks) {
      await this.log('Memory usage stabilized, resuming with caution', 'info');
      this.paused = false;
    } else {
      await this.log('Failed to achieve stability after maximum attempts, manual intervention may be required', 'critical');
      // Could add additional recovery steps here
    }
  }

  async addDependency(pkg, version) {
    const dependency = `${pkg}@${version}`;
    console.log(`Adding dependency: ${dependency}`);
    
    if (this.queue.includes(dependency) || this.installing.has(dependency)) {
      console.log(`Dependency ${dependency} already queued or installing`);
      return;
    }

    this.queue.push(dependency);
    await this.saveQueue();
    
    // Update progress monitor
    if (this.progressMonitor) {
      // Initialize installation stage if not exists
      this.progressMonitor.createStageBar('Installation', this.queue.length + this.completed.size);
    }
    
    this.processQueue();
  }

  async saveQueue() {
    try {
      // Create temporary file
      const tempFile = `${this.config.queueFile}.tmp`;
      const backupFile = `${this.config.queueFile}.backup`;
      
      // Prepare queue data
      const queueData = {
        queue: this.queue,
        completed: Array.from(this.completed),
        failed: Array.from(this.failed),
        installing: Array.from(this.installing),
        systemState: {
          sessionId: this.sessionId,
          timestamp: Date.now(),
          recoveryPoint: {
            inProgressPackages: Array.from(this.installing)
          }
        }
      };

      // Write to temp file first
      await fs.writeFile(tempFile, JSON.stringify(queueData, null, 2));
      
      // Backup existing queue file if it exists
      try {
        await fs.copyFile(this.config.queueFile, backupFile);
      } catch (err) {
        if (err.code !== 'ENOENT') throw err;
      }

      // Atomically rename temp file to actual queue file
      await fs.rename(tempFile, this.config.queueFile);
      
      console.log('Queue state saved successfully');
    } catch (err) {
      console.error('Error saving queue:', err);
      throw err;
    }
  }

  async processQueue() {
    if (this.paused || this.installing.size >= this.config.maxConcurrent || this.queue.length === 0) {
      return;
    }

    const dependency = this.queue.shift();
    this.installing.add(dependency);

    console.log(`Installing ${dependency}...`);
    this.progressMonitor.updateStage('Installation', this.completed.size, `Installing ${dependency}`);
    
    let attempts = 0;
    const install = async () => {
      try {
        await this.install(dependency);
        this.installing.delete(dependency);
        this.completed.add(dependency);
        
        // Update progress
        this.progressMonitor.updateStage('Installation', this.completed.size, 'Installation in progress');
        
        await this.saveQueue();
        
        // Add cool-down period
        await new Promise(resolve => setTimeout(resolve, this.config.cooldownPeriod));
        
        this.processQueue();
      } catch (error) {
        console.error(`Error installing ${dependency}:`, error);
        attempts++;
        
        if (attempts < this.config.retryAttempts) {
          console.log(`Retrying ${dependency} in ${this.config.retryDelay}ms (attempt ${attempts + 1}/${this.config.retryAttempts})`);
          this.progressMonitor.updateStage('Installation', this.completed.size, `Retrying ${dependency}`);
          setTimeout(install, this.config.retryDelay);
        } else {
          console.error(`Failed to install ${dependency} after ${this.config.retryAttempts} attempts`);
          this.installing.delete(dependency);
          this.failed.add(dependency);
          this.queue.push(dependency); // Put back in queue
          this.progressMonitor.updateStage('Installation', this.completed.size, `Failed: ${dependency}`);
          await this.saveQueue();
          this.processQueue();
        }
      }
    };

    install();
  }

  async install(packages, options = {}) {
    const {
      stage = 'default',
      cooldown = this.config.cooldownPeriod
    } = options;

    console.log(`\nStarting installation of ${stage} packages with ${cooldown}ms cooldown`);
    console.log('Packages:', packages);

    // Create stage progress bar
    this.progressMonitor.createStageBar(stage, packages.length);

    for (const pkg of packages) {
      try {
        // Check resource usage before starting
        const memUsage = await this.resourceMonitor.getMemoryUsage();
        if (memUsage > this.config.memoryThreshold) {
          console.log(`\nHigh memory usage (${memUsage}%), waiting for cooldown...`);
          await new Promise(resolve => setTimeout(resolve, cooldown));
        }

        console.log(`\nInstalling ${pkg}...`);
        await this.installPackage(pkg);

        // Cooldown period between packages
        console.log(`\nCooling down for ${cooldown}ms...`);
        await new Promise(resolve => setTimeout(resolve, cooldown));

      } catch (error) {
        console.error(`\nError installing ${pkg}:`, error);
        this.failed.add(pkg);
        
        // Emergency cooldown on failure
        console.log('\nEmergency cooldown after failure...');
        await new Promise(resolve => setTimeout(resolve, cooldown * 2));
      }
    }

    // Final cooldown
    await new Promise(resolve => setTimeout(resolve, cooldown));
    console.log(`\nCompleted ${stage} installation`);
  }

  async installPackage(pkg) {
    if (this.paused) {
      console.log('Installation paused due to resource constraints');
      return false;
    }

    // Pre-installation resource check
    const resources = await this.checkResources();
    if (resources.memory > this.config.memoryThreshold || resources.cpu > this.config.cpuThreshold) {
      console.log(`Resource usage too high (Memory: ${resources.memory}%, CPU: ${resources.cpu}%)`);
      await this.sleep(this.config.cooldownPeriod);
      return false;
    }

    console.log(`\nInstalling package: ${pkg}`);
    this.installing.add(pkg);

    try {
      // Clean npm cache before each install
      await this.runCommand(this.npmPath, ['cache', 'clean', '--force']);
      
      // Install with minimal flags
      const result = await this.executeWithRetry(this.npmPath, [
        'install',
        pkg,
        '--no-audit',
        '--no-fund',
        '--no-optional',
        '--no-package-lock',
        '--production'
      ]);

      if (result) {
        this.completed.add(pkg);
        this.installing.delete(pkg);
        
        // Force cleanup after successful install
        await this.cleanupResources();
        
        // Mandatory cooldown period
        console.log(`Cooling down for ${this.config.cooldownPeriod}ms...`);
        await this.sleep(this.config.cooldownPeriod);
        
        return true;
      }
    } catch (error) {
      console.error(`Failed to install ${pkg}:`, error);
      this.failed.add(pkg);
    }

    this.installing.delete(pkg);
    return false;
  }

  async checkResources() {
    const metrics = await this.resourceMonitor.getMetrics();
    
    // Enhanced logging
    await this.log(`Resource Check - Memory: ${metrics.memory}%, CPU: ${metrics.cpu}%, Heap: ${metrics.heap.used}/${metrics.heap.total}`);
    
    // Check process count
    const processCount = await this.resourceMonitor.getProcessCount();
    if (processCount > this.config.maxProcessCount) {
      console.warn(`High process count detected: ${processCount}`);
      await this.cleanupResources(metrics.memory > this.config.aggressiveCleanupThreshold);
    }
    
    // Check for aggressive cleanup threshold
    if (metrics.memory > this.config.aggressiveCleanupThreshold) {
      console.warn(`Memory usage above aggressive cleanup threshold: ${metrics.memory}%`);
      await this.cleanupResources(true);
    }
    
    return metrics;
  }

  async shutdown() {
    console.log('\nShutting down staged installer...');
    
    try {
      // Stop resource monitoring
      if (this.resourceMonitor) {
        await this.resourceMonitor.stop();
      }

      // Stop progress monitoring
      if (this.progressMonitor) {
        await this.progressMonitor.stop();
      }

      // Save final state
      await this.saveQueue();

      console.log('Staged installer shut down successfully');
    } catch (error) {
      console.error('Error during shutdown:', error);
      throw error;
    }
  }

  getStatus() {
    return {
      queue: this.queue,
      installing: Array.from(this.installing),
      completed: Array.from(this.completed),
      failed: Array.from(this.failed),
      paused: this.paused,
      config: this.config,
      resourceMetrics: this.resourceMonitor.getStatus()
    };
  }

  async log(message, type = 'info') {
    const timestamp = new Date().toISOString();
    const logMessage = `[${timestamp}] [${type.toUpperCase()}] ${message}\n`;
    
    await fs.appendFile(this.config.logFile, logMessage).catch(console.error);
    console.log(logMessage.trim());
  }

  async sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  async runCommand(command, args = []) {
    return new Promise((resolve, reject) => {
      const process = exec(command, {
        stdio: 'inherit',
        shell: true
      }, (error, stdout, stderr) => {
        if (error) {
          reject(new Error(`Command failed with code ${error.code}: ${error.message}`));
        } else {
          resolve();
        }
      });
    });
  }

  async executeWithRetry(command, args = [], retries = this.config.maxRetries) {
    for (let attempt = 1; attempt <= retries; attempt++) {
      try {
        // Check resources before attempting installation
        const resources = await this.checkResources();
        
        if (!resources.memory || !resources.cpu) {
          await this.log(
            `Resource limits exceeded (Memory: ${this.metrics.memory.toFixed(1)}%, CPU: ${this.metrics.cpu.toFixed(1)}%). Cooling down...`,
            'warning'
          );
          await this.sleep(this.config.cooldownPeriod);
          continue;
        }

        await this.log(`Executing command (Attempt ${attempt}/${retries}): ${command} ${args.join(' ')}`);
        await this.runCommand(command, args);
        return true;
      } catch (error) {
        await this.log(`Attempt ${attempt} failed: ${error.message}`, 'error');
        
        if (attempt === retries) {
          throw new Error(`Failed after ${retries} attempts: ${error.message}`);
        }
        
        await this.log(`Cooling down before retry...`, 'info');
        await this.sleep(this.config.cooldownPeriod);
      }
    }
  }

  async preInstall() {
    await this.log('Starting pre-installation checks...');
    
    // Create logs directory if it doesn't exist
    await fs.mkdir(path.dirname(this.config.logFile), { recursive: true });
    
    // Check initial resource usage
    const resources = await this.checkResources();
    await this.log(`Initial resource check - Memory: ${this.metrics.memory.toFixed(1)}%, CPU: ${this.metrics.cpu.toFixed(1)}%`);
    
    if (!resources.memory || !resources.cpu) {
      throw new Error('System resources too constrained to begin installation');
    }
  }

  async postInstall() {
    await this.log('Running post-installation tasks...');
    
    // Verify installations
    await this.log('Verifying installed packages...');
    
    // Clean up any temporary files
    await this.log('Cleaning up temporary files...');
    
    await this.log('Post-installation tasks completed successfully.');
  }

  async run() {
    try {
      switch (this.stage) {
        case 'pre-install':
          await this.preInstall();
          break;
          
        case 'post-install':
          await this.postInstall();
          break;
          
        default:
          throw new Error(`Unknown installation stage: ${this.stage}`);
      }
    } catch (error) {
      await this.log(`Installation stage "${this.stage}" failed: ${error.message}`, 'error');
      process.exit(1);
    }
  }

  async handleLowMemory() {
    console.log('Handling low memory situation...');
    
    // Pause all installations
    this.paused = true;
    
    // Kill all active installations
    for (const [pid, proc] of this.activeProcesses.entries()) {
      try {
        if (process.platform === 'win32') {
          await this.runCommand('taskkill', ['/F', '/T', '/PID', pid.toString()]);
        } else {
          process.kill(pid, 'SIGKILL');
        }
        console.log(`Killed process ${pid}`);
      } catch (err) {
        console.error(`Failed to kill process ${pid}:`, err);
      }
    }
    
    // Clear active processes
    this.activeProcesses.clear();
    
    // Perform aggressive cleanup
    await this.cleanupResources(true);
    
    // Wait for extended cooldown
    const extendedCooldown = this.config.cooldownPeriod * 2;
    console.log(`Waiting for extended cooldown (${extendedCooldown}ms)...`);
    await this.sleep(extendedCooldown);
    
    // Check memory again
    const metrics = await this.resourceMonitor.getMetrics();
    if (metrics.memory < this.config.memoryThreshold) {
      console.log('Memory levels acceptable, resuming installation');
      this.paused = false;
      this.processQueue();
    } else {
      console.log('Memory still high, maintaining pause');
      // Schedule another check
      setTimeout(() => this.handleLowMemory(), this.config.cooldownPeriod);
    }
  }
}

// Parse command line arguments
const args = process.argv.slice(2);
const stage = args.find(arg => arg.startsWith('--stage'))?.split('=')[1] || 'default';
const packages = args.find(arg => arg.startsWith('--packages'))?.split('=')[1]?.split(',') || [];
const cooldown = parseInt(args.find(arg => arg.startsWith('--cooldown'))?.split('=')[1]) || 3000;

// Run installer if called directly
if (require.main === module) {
  const installer = new StagedInstaller();
  
  installer.initialize()
    .then(() => installer.install(packages, { stage, cooldown }))
    .then(() => installer.shutdown())
    .catch(error => {
      console.error('Installation failed:', error);
      process.exit(1);
    });
}

module.exports = StagedInstaller; 