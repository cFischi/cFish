const StagedInstaller = require('./staged-installer');
const path = require('path');

// Core dependencies in order of importance
const CORE_DEPENDENCIES = [
  'express@5.1.0',        // Web server
  'ws@8.18.1',           // WebSocket support
  'blessed@0.1.81',      // Terminal UI base
  'cli-progress@3.12.0', // Progress bars
  'colors@1.4.0',        // Terminal colors
  'moment@2.29.4',       // Time handling
  'lru-cache@10.2.0'     // Cache management
];

// Monitoring dependencies
const MONITORING_DEPENDENCIES = [
  'systeminformation@5.21.24',
  'node-os-utils@1.3.7',
  'process-list@2.0.0'
];

async function runMinimalInstallation() {
  console.log('Starting minimal installation with enhanced safety measures...');

  const installer = new StagedInstaller({
    maxConcurrent: 1,
    memoryThreshold: 70,
    cpuThreshold: 70,
    emergencyThreshold: 80,
    cooldownPeriod: 30000,
    retryAttempts: 2,
    retryDelay: 10000
  });

  try {
    // Initialize installer
    await installer.initialize();
    console.log('Installer initialized successfully');

    // Install core dependencies one by one
    console.log('\nInstalling core dependencies...');
    for (const dep of CORE_DEPENDENCIES) {
      console.log(`\nPreparing to install ${dep}`);
      
      // Pre-install cleanup
      await installer.cleanupResources();
      
      // Resource check before installation
      const resources = await installer.checkResources();
      if (resources.memory > installer.config.memoryThreshold || resources.cpu > installer.config.cpuThreshold) {
        console.log('Resource usage too high, waiting for system to stabilize...');
        await installer.sleep(installer.config.cooldownPeriod);
      }

      // Attempt installation
      const success = await installer.installPackage(dep);
      if (!success) {
        console.error(`Failed to install ${dep}, stopping installation`);
        process.exit(1);
      }

      // Post-install cooldown
      console.log(`Successfully installed ${dep}, cooling down...`);
      await installer.sleep(installer.config.cooldownPeriod);
    }

    // Optional: Install monitoring dependencies if core installation was successful
    const installMonitoring = process.argv.includes('--with-monitoring');
    if (installMonitoring) {
      console.log('\nInstalling monitoring dependencies...');
      for (const dep of MONITORING_DEPENDENCIES) {
        const success = await installer.installPackage(dep);
        if (!success) {
          console.error(`Failed to install ${dep}, skipping remaining monitoring dependencies`);
          break;
        }
        await installer.sleep(installer.config.cooldownPeriod);
      }
    }

    // Final cleanup
    await installer.cleanupResources();
    await installer.shutdown();
    
    console.log('\nMinimal installation completed successfully');
    console.log('Installation summary:');
    console.log(`- Completed: ${installer.completed.size} packages`);
    console.log(`- Failed: ${installer.failed.size} packages`);
    
  } catch (error) {
    console.error('Critical error during installation:', error);
    await installer.handleEmergency(100); // Force emergency cleanup
    process.exit(1);
  }
}

// Run the installation
runMinimalInstallation().catch(error => {
  console.error('Fatal error:', error);
  process.exit(1);
}); 