#!/usr/bin/env node

/**
 * tYDiSync~ - Optimized Launcher Script
 * 
 * This script starts the tYDiSync~ system with memory optimization.
 * It handles garbage collection, memory monitoring, and graceful shutdown.
 */

const fs = require('fs');
const path = require('path');
const { spawn } = require('child_process');

// Configuration
const config = {
  memoryThreshold: 0.8, // 80% memory threshold
  gcInterval: 60000, // Run GC every 60 seconds
  statusUpdateInterval: 5000, // Update status every 5 seconds
  restartDelay: 5000, // Wait 5 seconds before restart after crash
  logDirectory: '../logs',
  logFile: `tydisync-${new Date().toISOString().replace(/:/g, '-').replace(/\..+/, '')}.log`,
  stateFile: 'state/system-state.json'
};

// Ensure log directory exists
if (!fs.existsSync(config.logDirectory)) {
  fs.mkdirSync(config.logDirectory, { recursive: true });
}

// Ensure state directory exists
if (!fs.existsSync('state')) {
  fs.mkdirSync('state', { recursive: true });
}

// Full path to log file
const logFilePath = path.join(config.logDirectory, config.logFile);

// Create log stream
const logStream = fs.createWriteStream(logFilePath, { flags: 'a' });

// Log helper function
function log(message) {
  const timestamp = new Date().toISOString();
  const logMessage = `[${timestamp}] ${message}`;
  console.log(logMessage);
  logStream.write(logMessage + '\n');
}

log('tYDiSync~ - Starting optimized system...');
log(`Node.js version: ${process.version}`);
log(`Memory limit: ${process.env.NODE_OPTIONS || 'Default'}`);

// Try to require the optimized version first, fall back to regular
let syncSystem;
try {
  log('Loading optimized tYDiSync~ implementation...');
  syncSystem = require('./core/optimized-tydisync');
  log('Successfully loaded optimized implementation');
} catch (error) {
  log(`Failed to load optimized implementation: ${error.message}`);
  log('Falling back to standard implementation...');
  try {
    syncSystem = require('./core/tydisync');
    log('Successfully loaded standard implementation');
  } catch (innerError) {
    log(`FATAL: Failed to load any implementation: ${innerError.message}`);
    process.exit(1);
  }
}

// Handle process events
process.on('uncaughtException', (error) => {
  log(`FATAL: Uncaught exception: ${error.message}`);
  log(error.stack);
  cleanup();
  process.exit(1);
});

process.on('unhandledRejection', (reason, promise) => {
  log(`FATAL: Unhandled rejection at ${promise}: ${reason}`);
  cleanup();
  process.exit(1);
});

process.on('SIGINT', () => {
  log('Received SIGINT - Shutting down gracefully...');
  cleanup();
  process.exit(0);
});

process.on('SIGTERM', () => {
  log('Received SIGTERM - Shutting down gracefully...');
  cleanup();
  process.exit(0);
});

// Cleanup function
function cleanup() {
  log('Cleaning up resources...');
  logStream.end();
}

// Start the sync system
try {
  log('Starting tYDiSync~ with memory optimization...');
  
  // If global gc is available, schedule periodic garbage collection
  if (global.gc) {
    log('Garbage collection is enabled');
    setInterval(() => {
      log('Running scheduled garbage collection');
      global.gc();
    }, config.gcInterval);
  } else {
    log('WARNING: Garbage collection is not available');
    log('Run with --expose-gc flag to enable garbage collection');
  }
  
  // Start the system
  syncSystem.start();
  log('tYDiSync~ started successfully');
  
} catch (error) {
  log(`FATAL: Failed to start tYDiSync~: ${error.message}`);
  log(error.stack);
  cleanup();
  process.exit(1);
}

// Export information for testing
module.exports = {
  syncSystem,
  config,
  cleanup
}; 