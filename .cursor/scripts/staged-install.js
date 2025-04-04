const { exec } = require('child_process');
const { promisify } = require('util');
const si = require('systeminformation');
const execAsync = promisify(exec);

const MEMORY_THRESHOLD = 0.7; // 70% of available memory
const PAUSE_DURATION = 2000; // 2 seconds between installations

const INSTALLATION_STAGES = [
  {
    name: 'core',
    packages: [
      '@next/font@13.1.6',
      'next@13.1.6',
      'react@18.2.0',
      'react-dom@18.2.0'
    ]
  },
  {
    name: 'development',
    packages: [
      'typescript@4.9.5',
      '@types/node@18.13.0',
      '@types/react@18.0.28',
      '@types/react-dom@18.0.11'
    ]
  },
  {
    name: 'testing',
    packages: [
      'jest@29.4.3',
      '@testing-library/react@14.0.0',
      '@testing-library/jest-dom@5.16.5'
    ]
  }
];

async function checkMemoryPressure() {
  const mem = await si.mem();
  const usageRatio = mem.used / mem.total;
  return usageRatio > MEMORY_THRESHOLD;
}

async function cleanupResources() {
  console.log('Cleaning up resources...');
  await execAsync('npm cache clean --force');
  if (global.gc) global.gc();
  await new Promise(resolve => setTimeout(resolve, PAUSE_DURATION));
}

async function installPackage(pkg) {
  console.log(`Installing ${pkg}...`);
  try {
    await execAsync(`npm install ${pkg} --no-save --no-audit --no-fund`);
    console.log(`Successfully installed ${pkg}`);
  } catch (error) {
    console.error(`Failed to install ${pkg}:`, error.message);
    throw error;
  }
}

async function runStagedInstallation() {
  console.log('Starting staged installation...');

  for (const stage of INSTALLATION_STAGES) {
    console.log(`\nStarting ${stage.name} stage...`);
    
    for (const pkg of stage.packages) {
      // Check memory pressure before installing
      if (await checkMemoryPressure()) {
        console.log('High memory pressure detected, cleaning up...');
        await cleanupResources();
      }

      try {
        await installPackage(pkg);
        await new Promise(resolve => setTimeout(resolve, PAUSE_DURATION));
      } catch (error) {
        console.error(`Stage ${stage.name} failed at package ${pkg}`);
        process.exit(1);
      }
    }

    console.log(`Completed ${stage.name} stage`);
    await cleanupResources();
  }

  console.log('\nInstallation completed successfully!');
}

// Run the installation if called directly
if (require.main === module) {
  runStagedInstallation().catch(error => {
    console.error('Installation failed:', error);
    process.exit(1);
  });
}

module.exports = { runStagedInstallation }; 