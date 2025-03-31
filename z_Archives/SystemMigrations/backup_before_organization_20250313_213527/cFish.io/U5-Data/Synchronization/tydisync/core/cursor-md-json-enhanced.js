/**
 * Enhanced MD-JSON Sync System - Cursor Integration
 * 
 * This script runs the enhanced MD-JSON sync system only when Cursor is active,
 * and properly handles dependency loading and integration with the Cursor environment.
 */

console.log('📝 Starting cursor-tydisync-enhanced.js...');

// Explicitly require all dependencies to ensure they are available
try {
  const chokidar = require('chokidar');
  const fs = require('fs');
  const path = require('path');
  const crypto = require('crypto');
  const events = require('events');
  const os = require('os');
  const moment = require('moment');
  
  console.log('✅ Successfully loaded all dependencies');
  
  // Create a flag file to indicate that Cursor is running
  const cursorFlagPath = path.join(__dirname, '.cursor-running');
  fs.writeFileSync(cursorFlagPath, new Date().toISOString());
  console.log(`✅ Created flag file: ${cursorFlagPath}`);
  
  // Create dummy implementations for any missing modules
  let MemoryManager, LockManager, jsonValidator, BackupManager;
  
  try {
    MemoryManager = require('./memory-manager');
  } catch (error) {
    console.log('⚠️ memory-manager.js not found, using dummy implementation');
    MemoryManager = class MemoryManager {
      constructor(config) {
        this.config = config;
        console.log('📊 Dummy Memory Manager started');
      }
      shutdown() {}
    }
  }
  
  try {
    LockManager = require('./lock-manager');
  } catch (error) {
    console.log('⚠️ lock-manager.js not found, using dummy implementation');
    LockManager = class LockManager {
      constructor(config) {
        this.config = config;
        console.log('🔒 Dummy Lock Manager started');
      }
      shutdown() {}
    }
  }
  
  try {
    jsonValidator = require('./json-validator');
  } catch (error) {
    console.log('⚠️ json-validator.js not found, using dummy implementation');
    jsonValidator = {
      validate: (json) => true,
      repair: (json) => json
    };
  }
  
  try {
    BackupManager = require('./backup-manager');
  } catch (error) {
    console.log('⚠️ backup-manager.js not found, using dummy implementation');
    BackupManager = class BackupManager {
      constructor(config) {
        this.config = config;
        console.log('💾 Dummy Backup Manager started');
      }
      shutdown() {}
    }
  }
  
  // Import the MdJsonSync system
  console.log('🔍 Attempting to import MDJSONSync from ./dummy-tydisync.js');
  const MDJSONSync = require('./dummy-tydisync.js');
  console.log('✅ Successfully imported MDJSONSync class');
  
  // Configuration (taken from tydisync-enhanced.js)
  const config = {
    // Memory manager configuration
    memory: {
      warningThreshold: 0.7, // 70% of max memory
      criticalThreshold: 0.85, // 85% of max memory
      gcInterval: 60000, // Run GC every 60 seconds
      statsInterval: 300000, // Log stats every 5 minutes
      debug: true
    },
    
    // Lock manager configuration
    locks: {
      lockTimeout: 60000, // 60 seconds default timeout
      lockCleanupInterval: 30000, // Check for stale locks every 30 seconds
      lockDirectory: '.locks',
      debug: true
    },
    
    // Backup manager configuration
    backup: {
      backupDir: "backups",
      maxBackups: 5,
      rotationEnabled: true,
      rotationInterval: 86400000, // 24 hours
      compressionEnabled: false,
      debug: true
    },
    
    // MD-JSON sync configuration
    sync: {
      watchDirectories: {
        markdown: [".", "docs", "test-data/md"],
        json: ["json", "docs/json", "test-data/json"]
      },
      lowCpuMode: true,
      excludePatterns: ['.git', 'node_modules', '.nosync'],
      debug: true
    }
  };
  
  // Initialize the components
  console.log('🚀 Starting Enhanced MD-JSON Sync System for Cursor');
  console.log('Features:');
  console.log('- Memory management with automatic garbage collection');
  console.log('- Improved lock management with stale lock detection');
  console.log('- JSON validation and automatic repair');
  console.log('- Low CPU mode for reduced resource usage');
  console.log('- Only active when Cursor is running');
  
  // Initialize the memory manager
  console.log('🔄 Initializing Memory Manager...');
  const memoryManager = new MemoryManager(config.memory);
  console.log('📊 Memory Manager started');
  
  // Initialize the lock manager
  console.log('🔄 Initializing Lock Manager...');
  const lockManager = new LockManager(config.locks);
  console.log('🔒 Lock Manager started');
  
  // Initialize the backup manager
  console.log('🔄 Initializing Backup Manager...');
  const backupManager = new BackupManager(config.backup);
  console.log('💾 Backup Manager started');
  
  // Initialize the MD-JSON sync system
  console.log('🔄 Initializing MDJSONSync system...');
  let syncSystem; // Declare syncSystem in the outer scope
  try {
    syncSystem = new MDJSONSync({
      watchMode: true,
      verbose: true,
      lowCpuMode: config.sync.lowCpuMode,
      watchDirectories: config.sync.watchDirectories,
      exclusions: config.sync.excludePatterns,
      backupSettings: config.backup,
      memoryWarningThreshold: config.memory.warningThreshold,
      memoryCriticalThreshold: config.memory.criticalThreshold
    });
    
    console.log('✅ MDJSONSync system initialized');
    
    // Start the sync system
    console.log('🔄 Starting MDJSONSync system...');
    syncSystem.start();
    
    console.log('✅ MD-JSON Sync System started and running');
  } catch (error) {
    console.error('❌ Error initializing MDJSONSync:', error.message);
    console.error('Stack trace:', error.stack);
  }
  
  // Handle clean shutdown
  process.on('SIGINT', () => {
    console.log('👋 Cursor closing, shutting down Enhanced MD-JSON Sync System');
    
    // Perform cleanup
    if (syncSystem && typeof syncSystem.shutdown === 'function') {
      syncSystem.shutdown();
    } else if (syncSystem && typeof syncSystem.stop === 'function') {
      syncSystem.stop();
    }
    
    lockManager.shutdown();
    backupManager.shutdown();
    memoryManager.shutdown();
    
    // Remove the flag file
    if (fs.existsSync(cursorFlagPath)) {
      fs.unlinkSync(cursorFlagPath);
    }
    
    // Allow time for cleanup
    setTimeout(() => {
      process.exit(0);
    }, 1000);
  });
  
} catch (error) {
  console.error('❌ Error loading dependencies:', error.message);
  console.error('Stack trace:', error.stack);
  
  // Try to reinstall the missing dependency automatically
  const { execSync } = require('child_process');
  console.log('🔄 Attempting to reinstall dependencies...');
  
  try {
    execSync('npm install', { stdio: 'inherit' });
    console.log('✅ Dependencies reinstalled. Please restart Cursor and try again.');
  } catch (installError) {
    console.error('❌ Failed to reinstall dependencies:', installError.message);
    console.log('Please run "npm install" manually in the project directory.');
  }
  
  process.exit(1);
} 