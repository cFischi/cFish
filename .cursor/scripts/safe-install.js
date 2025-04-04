const { spawn } = require('child_process');
const { createLogger } = require('./logger');
const path = require('path');
const fs = require('fs').promises;

const logger = createLogger('safe-install');

class SafeInstaller {
  constructor() {
    this.stages = [
      { name: 'core', script: 'install:core' },
      { name: 'monitoring', script: 'install:monitoring' },
      { name: 'ui', script: 'install:ui' }
    ];
    this.currentStage = 0;
    this.retryCount = 0;
    this.maxRetries = 3;
    this.cooldownPeriod = 5000; // 5 seconds between stages
  }

  async run() {
    try {
      logger.info('Starting safe installation process...');
      
      for (const stage of this.stages) {
        await this.runStage(stage);
        await this.cooldown();
      }

      logger.info('Installation completed successfully');
      await this.verifyInstallation();
    } catch (error) {
      logger.error(`Installation failed: ${error.message}`);
      process.exit(1);
    }
  }

  async runStage(stage) {
    logger.info(`Starting installation stage: ${stage.name}`);
    
    return new Promise((resolve, reject) => {
      const npm = process.platform === 'win32' ? 'npm.cmd' : 'npm';
      const install = spawn(npm, ['run', stage.script], {
        stdio: 'inherit',
        shell: true
      });

      install.on('close', (code) => {
        if (code === 0) {
          logger.info(`Stage ${stage.name} completed successfully`);
          this.retryCount = 0;
          resolve();
        } else {
          logger.error(`Stage ${stage.name} failed with code ${code}`);
          this.handleFailure(stage).then(resolve).catch(reject);
        }
      });

      install.on('error', (error) => {
        logger.error(`Stage ${stage.name} failed with error: ${error.message}`);
        this.handleFailure(stage).then(resolve).catch(reject);
      });
    });
  }

  async handleFailure(stage) {
    if (this.retryCount < this.maxRetries) {
      this.retryCount++;
      logger.warn(`Retrying stage ${stage.name} (attempt ${this.retryCount}/${this.maxRetries})`);
      await this.cooldown();
      return this.runStage(stage);
    } else {
      throw new Error(`Stage ${stage.name} failed after ${this.maxRetries} attempts`);
    }
  }

  async cooldown() {
    logger.info(`Cooling down for ${this.cooldownPeriod}ms...`);
    await new Promise(resolve => setTimeout(resolve, this.cooldownPeriod));
  }

  async verifyInstallation() {
    logger.info('Verifying installation...');
    
    const verifyDeps = require('./verify-dependencies');
    try {
      const report = await verifyDeps();
      logger.info('Installation verification completed successfully');
      
      // Save installation state
      const stateFile = path.join(__dirname, '../metrics/installation-state.json');
      await fs.mkdir(path.dirname(stateFile), { recursive: true });
      await fs.writeFile(stateFile, JSON.stringify({
        timestamp: new Date().toISOString(),
        status: 'complete',
        report
      }, null, 2));
    } catch (error) {
      logger.error('Installation verification failed:', error);
      throw error;
    }
  }
}

// Run installer if called directly
if (require.main === module) {
  const installer = new SafeInstaller();
  installer.run().catch(error => {
    logger.error('Installation failed:', error);
    process.exit(1);
  });
}

module.exports = SafeInstaller; 