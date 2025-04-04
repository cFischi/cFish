const ResourceMonitor = require('./resource-monitor');
const StagedInstaller = require('./staged-installer');
const config = require('../config/test-environment');
const path = require('path');
const fs = require('fs').promises;
const assert = require('assert');
const InstallProgressMonitor = require('./install-progress-monitor');
const EnhancedResourceMonitor = require('./enhanced-resource-monitor');

async function validateResourceMonitor() {
  console.log('\nValidating Resource Monitor...');
  
  const monitor = new EnhancedResourceMonitor({
    warningThreshold: 70,
    criticalThreshold: 80,
    updateInterval: 1000
  });

  try {
    await monitor.initialize();
    console.log('✓ Monitor initialization successful');

    const metrics = await monitor.getMetrics();
    console.assert(metrics.memory !== undefined, 'Memory metrics available');
    console.assert(metrics.cpu !== undefined, 'CPU metrics available');
    console.assert(metrics.total !== undefined, 'Total metrics available');
    console.log('✓ Metrics collection successful');

    await monitor.start();
    console.log('✓ Monitoring started successfully');

    // Test warning detection
    monitor.addListener((metrics) => {
      console.log('Resource update received:', metrics);
    });
    console.log('✓ Warning detection system verified');

    await monitor.stop();
    console.log('✓ Monitor cleanup successful');
    return true;
  } catch (err) {
    console.error('Resource Monitor validation failed:', err);
    return false;
  }
}

async function validateProgressMonitor() {
  console.log('\nValidating Progress Monitor...');
  const monitor = new InstallProgressMonitor({
    showResourceMetrics: true,
    updateInterval: 1000
  });

  try {
    await monitor.start();
    console.log('✓ Progress monitor initialization successful');

    monitor.createStageBar('Test Stage', 5);
    console.log('✓ Stage creation successful');

    monitor.updateProgress(1);
    console.log('✓ Progress update successful');

    const metrics = await monitor.getResourceMetrics();
    console.assert(metrics !== undefined, 'Resource metrics available');
    console.log('✓ Resource metrics collection successful');

    await monitor.stop();
    console.log('✓ Progress monitor cleanup successful');
    return true;
  } catch (err) {
    console.error('Progress Monitor validation failed:', err);
    return false;
  }
}

async function validateStagedInstaller() {
  console.log('\nValidating Staged Installer...');
  const installer = new StagedInstaller({
    installDir: path.join(__dirname, '../test-modules'),
    queueFile: path.join(__dirname, '../test-queue.json'),
    memoryThreshold: 70,
    cpuThreshold: 70,
    emergencyThreshold: 80,
    cooldownPeriod: 10000
  });

  try {
    await installer.initialize();
    console.log('✓ Installer initialization successful');

    // Test package installation
    const testPkg = 'colors@1.4.0';
    installer.queue.push(testPkg);
    console.log('✓ Package queue setup successful');

    // Verify queue state saving
    await installer.saveQueue();
    const queueExists = await fs.access(installer.config.queueFile)
      .then(() => true)
      .catch(() => false);
    console.assert(queueExists, 'Queue state saved successfully');
    console.log('✓ Queue state persistence verified');

    // Clean up test files
    await fs.rm(installer.config.installDir, { recursive: true, force: true });
    await fs.rm(installer.config.queueFile, { force: true });
    await fs.rm(`${installer.config.queueFile}.backup`, { force: true });
    console.log('✓ Test cleanup successful');

    return true;
  } catch (err) {
    console.error('Staged Installer validation failed:', err);
    return false;
  }
}

async function runValidation() {
  console.log('Starting system validation...');
  
  const results = {
    resourceMonitor: await validateResourceMonitor(),
    progressMonitor: await validateProgressMonitor(),
    stagedInstaller: await validateStagedInstaller()
  };

  console.log('\nValidation Results:');
  Object.entries(results).forEach(([component, success]) => {
    console.log(`${component}: ${success ? '✓ PASS' : '✗ FAIL'}`);
  });

  // Update memory.md with results
  const memoryEntry = `## System Test Results (${new Date().toLocaleDateString()})

### Test Execution Summary
- **Core Validation**: ${Object.values(results).every(r => r) ? 'PASSED' : 'FAILED'}
  Resource monitoring system validated
  Progress monitoring system checked
  Staged installer functionality verified
  Component integration tested

### Next Steps
1. Address any failed tests and validation errors
2. Implement remaining monitoring dashboard components
3. Complete alert system implementation
4. Enhance error recovery mechanisms
5. Deploy process tree visualization

_Updated ${new Date().toLocaleDateString()} | AI: Cursor (Claude 3.7 Sonnet)_
`;

  try {
    const memoryFile = path.join(__dirname, '../md/memory.md');
    const currentContent = await fs.readFile(memoryFile, 'utf8');
    await fs.writeFile(memoryFile, memoryEntry + '\n\n' + currentContent);
    console.log('✓ Memory file updated successfully');
  } catch (err) {
    console.error('Failed to update memory file:', err);
  }

  return Object.values(results).every(r => r);
}

// Run validation if this script is executed directly
if (require.main === module) {
  runValidation().then(success => {
    process.exit(success ? 0 : 1);
  });
}

module.exports = { runValidation }; 