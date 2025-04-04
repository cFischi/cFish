#!/usr/bin/env node

const StagedTestRunner = require('./staged-test-runner');
const path = require('path');

async function main() {
  const args = process.argv.slice(2);
  const options = parseArgs(args);
  
  console.log('Starting staged test runner with options:', options);
  
  const runner = new StagedTestRunner();
  
  try {
    if (options.stage) {
      // Run specific stage
      await runSingleStage(runner, options.stage);
    } else {
      // Run all stages
      await runner.runTests();
    }
  } catch (error) {
    console.error('Test execution failed:', error);
    process.exit(1);
  }
}

function parseArgs(args) {
  const options = {
    stage: null,
    verbose: false,
    recovery: false
  };
  
  for (let i = 0; i < args.length; i++) {
    const arg = args[i];
    switch (arg) {
      case '--stage':
        options.stage = args[++i];
        break;
      case '--verbose':
        options.verbose = true;
        break;
      case '--recovery':
        options.recovery = true;
        break;
      case '--help':
        showHelp();
        process.exit(0);
    }
  }
  
  return options;
}

async function runSingleStage(runner, stageName) {
  const stage = runner.stages.find(s => s.name === stageName);
  if (!stage) {
    throw new Error(`Stage not found: ${stageName}`);
  }
  
  await runner.initialize();
  await runner.checkResourceState(stage);
  await runner.createRecoveryPoint(stage);
  await runner.runStage(stage);
  await runner.cooldown(stage);
  await runner.cleanup();
}

function showHelp() {
  console.log(`
Staged Test Runner

Usage:
  node run-staged-tests.js [options]

Options:
  --stage <name>    Run specific test stage (initialization, core, integration, stress)
  --verbose         Enable verbose logging
  --recovery       Start from last recovery point
  --help           Show this help message

Examples:
  node run-staged-tests.js                    # Run all stages
  node run-staged-tests.js --stage core       # Run only core stage
  node run-staged-tests.js --verbose          # Run with verbose logging
  `);
}

// Enable garbage collection if available
if (global.gc) {
  console.log('Garbage collection enabled');
} else {
  console.log('Warning: Garbage collection not available. Run with --expose-gc flag.');
}

// Run the program
main().catch(error => {
  console.error('Fatal error:', error);
  process.exit(1);
}); 