const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

// Memory-optimized configuration
const MEMORY_CONFIG = {
  maxOldSpaceSize: 2048, // 2GB max for Node
  chunkSize: 5, // Install dependencies in chunks of 5
  cleanupInterval: 60000, // Cleanup every minute
};

// Essential dependencies to install first
const CORE_DEPENDENCIES = [
  '@types/node',
  'typescript',
  'ts-node',
  'jest',
  'ts-jest'
];

// Secondary dependencies
const SECONDARY_DEPENDENCIES = [
  '@types/jest',
  'chai',
  'moment',
  'pidtree'
];

async function setupTestEnvironment() {
  console.log('Setting up test environment with memory optimization...');
  
  try {
    // Create necessary directories
    const dirs = [
      '../logs',
      '../logs/test-reports',
      'test-install',
      '../coverage',
      '../modules/process-manager'
    ];
    
    for (const dir of dirs) {
      if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir, { recursive: true });
        console.log(`Created directory: ${dir}`);
      }
    }

    // Install PowerShell modules first
    await installPowerShellModules();

    // Stage 1: Install core dependencies
    console.log('Stage 1: Installing core dependencies...');
    for (const dep of CORE_DEPENDENCIES) {
      try {
        execSync(`npm install ${dep} --no-save --production=false`, {
          stdio: 'inherit',
          env: { ...process.env, NODE_OPTIONS: `--max-old-space-size=${MEMORY_CONFIG.maxOldSpaceSize}` }
        });
        console.log(`Installed ${dep}`);
        
        // Force garbage collection between installations
        if (global.gc) global.gc();
        await new Promise(resolve => setTimeout(resolve, 1000));
      } catch (err) {
        console.error(`Failed to install ${dep}:`, err);
        throw err;
      }
    }

    // Stage 2: Install secondary dependencies in chunks
    console.log('Stage 2: Installing secondary dependencies...');
    for (let i = 0; i < SECONDARY_DEPENDENCIES.length; i += MEMORY_CONFIG.chunkSize) {
      const chunk = SECONDARY_DEPENDENCIES.slice(i, i + MEMORY_CONFIG.chunkSize);
      try {
        execSync(`npm install ${chunk.join(' ')} --no-save --production=false`, {
          stdio: 'inherit',
          env: { ...process.env, NODE_OPTIONS: `--max-old-space-size=${MEMORY_CONFIG.maxOldSpaceSize}` }
        });
        console.log(`Installed chunk: ${chunk.join(', ')}`);
        
        // Force cleanup between chunks
        if (global.gc) global.gc();
        await new Promise(resolve => setTimeout(resolve, 2000));
      } catch (err) {
        console.error(`Failed to install chunk ${i}:`, err);
        throw err;
      }
    }

    // Stage 3: Configure Jest
    console.log('Stage 3: Configuring Jest...');
    const jestConfig = {
      preset: 'ts-jest',
      testEnvironment: 'node',
      roots: ['<rootDir>/src'],
      testMatch: ['**/__tests__/**/*.ts', '**/?(*.)+(spec|test).ts'],
      transform: {
        '^.+\\.tsx?$': 'ts-jest'
      },
      moduleFileExtensions: ['ts', 'tsx', 'js', 'jsx', 'json', 'node'],
      coverageDirectory: '../coverage',
      setupFiles: ['./test-setup.js'],
      maxWorkers: 2, // Limit workers for memory optimization
      maxConcurrency: 1 // Run tests sequentially
    };

    fs.writeFileSync('jest.config.json', JSON.stringify(jestConfig, null, 2));
    console.log('Jest configuration created');

    console.log('Test environment setup completed successfully');
  } catch (error) {
    console.error('Failed to setup test environment:', error);
    process.exit(1);
  }
}

async function installPowerShellModules() {
  console.log('Installing PowerShell modules...');
  try {
    execSync('powershell -Command "& {Set-ExecutionPolicy RemoteSigned -Scope Process}"', { stdio: 'inherit' });
    execSync('powershell -File install-powershell-modules.ps1', { stdio: 'inherit' });
    console.log('PowerShell modules installed successfully');
  } catch (error) {
    console.error('Failed to install PowerShell modules:', error);
    throw error;
  }
}

// Run setup
setupTestEnvironment().catch(console.error);

// Run setup if executed directly
if (require.main === module) {
  setupTestEnvironment().catch(error => {
    console.error('Setup failed:', error);
    process.exit(1);
  });
} 