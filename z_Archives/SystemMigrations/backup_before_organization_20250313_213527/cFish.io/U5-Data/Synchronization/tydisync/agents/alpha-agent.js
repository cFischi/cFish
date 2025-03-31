/**
 * tYDiSync~ - Alpha Agent
 * 
 * The Alpha Agent is responsible for monitoring the filesystem and detecting
 * changes to Markdown and JSON files. It serves as the entry point for 
 * the synchronization process by notifying other agents of file changes.
 * 
 * Part of the tY FischEYe ecosystem connecting with the "Dreamflo ~" philosophy
 * 
 * @version 1.2.0
 */

const fs = require('fs');
const path = require('path');
const chokidar = require('chokidar');
const EventEmitter = require('events');

class AlphaAgent extends EventEmitter {
  constructor(config) {
    super();
    this.config = config;
    this.watchers = [];
    this.debounceTime = config.debounceTime || 800;
    this.pendingChanges = new Map();
    this.recursiveWatching = config.recursiveWatching || true;
    this.exclusions = new Set(config.exclusions || []);
    this.syncMarker = '.nosync';
    this.lowCpuMode = config.lowCpuMode || false;
    
    // Enhanced throttling configuration
    this.throttling = config.throttling || {
      maxConcurrent: 1,
      delayBetweenFiles: this.lowCpuMode ? 5000 : 2000,
      batchSize: this.lowCpuMode ? 5 : 10,
      batchDelay: this.lowCpuMode ? 10000 : 5000
    };
    
    // Polling configuration (for low CPU mode)
    this.polling = config.polling || {
      usePolling: this.lowCpuMode,
      interval: 5000,
      binaryInterval: 10000
    };
    
    // Watching configuration
    this.watching = config.watching || {
      depth: this.lowCpuMode ? 1 : 2,
      awaitWriteFinish: {
        stabilityThreshold: this.lowCpuMode ? 2000 : 1000,
        pollInterval: this.lowCpuMode ? 500 : 200
      },
      ignoreInitial: true,
      alwaysStat: false,
      disableGlobbing: this.lowCpuMode
    };
    
    // Memory management configuration
    this.memoryManagement = config.memoryManagement || {
      gcIntervalMs: this.lowCpuMode ? 60000 : 30000,
      heapThresholdMb: this.lowCpuMode ? 500 : 1024,
      statsIntervalMs: this.lowCpuMode ? 120000 : 30000
    };
    
    // Runtime statistics
    this.stats = {
      processedFiles: 0,
      skippedFiles: 0,
      currentBatchSize: 0,
      batchCount: 0,
      lastMemoryUsage: process.memoryUsage(),
      cpuMode: this.lowCpuMode ? "LOW" : "NORMAL"
    };
  }

  /**
   * Initialize the file monitoring system
   */
  initialize() {
    console.log(`🔍 Alpha Agent: Initializing file monitoring system (CPU Mode: ${this.stats.cpuMode})`);
    
    // Clear any existing watchers
    this.stopWatching();
    
    // Set up workspace monitoring
    this.setupWorkspaceMonitoring();
    
    // Set up memory monitoring
    this.setupMemoryMonitoring();
    
    console.log('✅ Alpha Agent: File monitoring system initialized');
    return this;
  }

  /**
   * Setup monitoring for memory usage
   */
  setupMemoryMonitoring() {
    // Set up interval to check memory usage periodically
    this.memoryMonitorInterval = setInterval(() => {
      const used = process.memoryUsage();
      const diff = {};
      
      // Calculate difference from last check
      for (const key in used) {
        diff[key] = Math.round((used[key] - this.stats.lastMemoryUsage[key]) / 1024 / 1024 * 100) / 100;
        this.stats.lastMemoryUsage[key] = used[key];
      }
      
      console.log('\n📊 Alpha Agent: Memory usage:');
      for (const key in used) {
        console.log(`${key}: ${Math.round(used[key] / 1024 / 1024 * 100) / 100} MB (${diff[key] >= 0 ? '+' : ''}${diff[key]} MB)`);
      }
      console.log(`Processed files: ${this.stats.processedFiles}, Skipped: ${this.stats.skippedFiles}, Batches: ${this.stats.batchCount}, CPU Mode: ${this.stats.cpuMode}\n`);
      
      // If memory usage is too high, trigger garbage collection
      if (used.heapUsed > this.memoryManagement.heapThresholdMb * 1024 * 1024) { 
        console.log(`⚠️ Alpha Agent: High memory usage detected (${Math.round(used.heapUsed / 1024 / 1024 * 100) / 100} MB), attempting to free memory...`);
        // This is a hint to the garbage collector
        if (global.gc) {
          global.gc();
        }
      }
    }, this.memoryManagement.statsIntervalMs);
    
    // Setup periodic garbage collection in low CPU mode
    if (this.lowCpuMode && global.gc) {
      this.gcInterval = setInterval(() => {
        console.log('♻️ Alpha Agent: Running preventive garbage collection (low CPU mode)');
        global.gc();
      }, this.memoryManagement.gcIntervalMs);
    }
  }

  /**
   * Setup monitoring for the entire workspace with proper exclusions
   */
  setupWorkspaceMonitoring() {
    // Create a single watcher for the entire workspace
    const workspaceRoot = process.cwd();
    console.log(`🔍 Alpha Agent: Setting up monitoring for workspace: ${workspaceRoot} (CPU Mode: ${this.stats.cpuMode})`);
    
    // Define patterns to watch and ignore
    const watchPatterns = [
      // Root directory files (most critical)
      '*.md',                       // Root directory markdown files
      'json/*.json',                // Root JSON directory JSON files
      
      // Documentation directories
      'docs/*.md',                  // Docs directory markdown files (not recursive)
      'shortlinks/*.md',            // Shortlinks directory markdown files (not recursive)
      
      // Only add deeper patterns if not in low CPU mode
      ...(!this.lowCpuMode ? [
        'docs/**/*.md',               // Docs subdirectories markdown files
        'shortlinks/**/*.md',         // Shortlinks subdirectories markdown files
        'docs/json/**/*.json',        // Docs JSON subdirectories JSON files
        'shortlinks/json/**/*.json',  // Shortlinks JSON subdirectories JSON files
      ] : []),
      
      // Watch .nosync marker files for exclusion management
      '*.nosync',
      'docs/*.nosync',
      ...(!this.lowCpuMode ? [
        'docs/**/*.nosync',
        'shortlinks/**/*.nosync',
        'json/**/*.nosync'
      ] : [])
    ];
    
    // Create very strict ignored patterns
    const ignoredPatterns = [
      // WordPress directories - match more aggressively
      '**/wp-content/**',
      '**/wp-admin/**',
      '**/wp-includes/**',
      '**/wp-*/**',                // Any wp- prefixed directory
      '**/plugins/**',             // WordPress plugins directory
      '**/themes/**',              // WordPress themes directory
      '**/wordpress/**',           // WordPress directory
      '**/WordPress/**',           // Case insensitive match
      
      // Common large directories
      '**/node_modules/**',
      '**/.git/**',
      '**/.cursor/**',
      '**/backups/**',
      '**/vendor/**',
      '**/cache/**',
      '**/tmp/**',
      '**/temp/**',
      '**/logs/**',
      
      // Test directories for large files
      '**/test-data/large-files/**',
      
      // Add custom exclusions from config
      ...Array.from(this.exclusions).map(excl => `**/${excl}/**`)
    ];
    
    console.log(`🔍 Alpha Agent: Watching specific patterns: ${watchPatterns.join(', ')}`);
    console.log(`🔍 Alpha Agent: Ignoring patterns: ${ignoredPatterns.slice(0, 5).join(', ')} and ${ignoredPatterns.length - 5} more...`);
    
    // Create the watcher with improved options based on CPU mode
    const watcherOptions = {
      cwd: workspaceRoot,
      ignored: ignoredPatterns,
      persistent: true,
      ignoreInitial: this.watching.ignoreInitial,
      awaitWriteFinish: this.watching.awaitWriteFinish,
      depth: this.watching.depth,
      alwaysStat: this.watching.alwaysStat,
      disableGlobbing: this.watching.disableGlobbing,
      usePolling: this.polling.usePolling,
      interval: this.polling.interval,
      binaryInterval: this.polling.binaryInterval
    };
    
    console.log(`🔄 Alpha Agent: Using${this.polling.usePolling ? ' polling with interval ' + this.polling.interval + 'ms' : ' native events'} (CPU Mode: ${this.stats.cpuMode})`);
    
    // Create the watcher with improved options
    const watcher = chokidar.watch(watchPatterns, watcherOptions);
    
    // Set up event handlers
    watcher
      .on('add', path => this.handleFileChange('add', path))
      .on('change', path => this.handleFileChange('change', path))
      .on('unlink', path => this.handleFileChange('unlink', path))
      .on('error', error => console.error(`🔥 Alpha Agent: Watcher error: ${error}`));
    
    this.watchers.push(watcher);
    
    console.log('✅ Alpha Agent: Workspace monitoring setup complete');
  }

  /**
   * Handle file changes with debouncing
   * @param {string} eventType The event type (add, change, unlink)
   * @param {string} filePath The path to the changed file
   */
  handleFileChange(eventType, filePath) {
    // Get absolute path
    const absPath = path.resolve(process.cwd(), filePath);
    
    // Check if this is a nosync marker file
    if (filePath.endsWith(this.syncMarker)) {
      // Extract the target file name that should be excluded
      const targetFile = filePath.substring(0, filePath.length - this.syncMarker.length);
      if (eventType === 'add' || eventType === 'change') {
        console.log(`⚠️ Alpha Agent: Found nosync marker for ${targetFile}, excluding from synchronization`);
        this.exclusions.add(targetFile);
      } else if (eventType === 'unlink') {
        console.log(`ℹ️ Alpha Agent: Nosync marker for ${targetFile} removed, will include in synchronization`);
        this.exclusions.delete(targetFile);
      }
      return;
    }
    
    // Additional WordPress directory check (more aggressive)
    if (filePath.includes('wp-content') || 
        filePath.includes('wp-admin') || 
        filePath.includes('wp-includes') ||
        filePath.includes('plugins') ||
        filePath.includes('themes') ||
        filePath.includes('wordpress') ||
        filePath.includes('WordPress')) {
      console.log(`⚠️ Alpha Agent: Skipping WordPress-related file: ${filePath}`);
      this.stats.skippedFiles++;
      return;
    }
    
    // Check if file is excluded
    if (this.isExcluded(filePath)) {
      console.log(`⚠️ Alpha Agent: Skipping excluded file: ${filePath}`);
      this.stats.skippedFiles++;
      return;
    }
    
    // Clear any pending changes for this file
    if (this.pendingChanges.has(absPath)) {
      clearTimeout(this.pendingChanges.get(absPath));
    }
    
    // Set a new timeout for this file with timestamp
    this.pendingChanges.set(absPath, setTimeout(() => {
      console.log(`📄 Alpha Agent: Change detected in ${filePath}, notifying...`);
      
      // Determine file type and emit appropriate event
      if (filePath.endsWith('.md')) {
        this.emit('markdown-changed', { path: absPath, type: eventType });
      } else if (filePath.endsWith('.json')) {
        this.emit('json-changed', { path: absPath, type: eventType });
      }
      
      // Increment processed files counter
      this.stats.processedFiles++;
      this.stats.currentBatchSize++;
      
      // Check if we need to pause for batch processing
      if (this.stats.currentBatchSize >= this.throttling.batchSize) {
        this.stats.batchCount++;
        this.stats.currentBatchSize = 0;
        console.log(`\n⏸️ Alpha Agent: Batch ${this.stats.batchCount} completed, pausing for ${this.throttling.batchDelay}ms...\n`);
        
        // This doesn't actually pause, but logs the message
        // The actual throttling happens in the Beta/Gamma agents
      }
      
      // Remove from pending changes
      this.pendingChanges.delete(absPath);
    }, this.debounceTime));
  }

  /**
   * Check if a file is excluded from synchronization
   * @param {string} filePath The path to check
   * @returns {boolean} True if the file should be excluded
   */
  isExcluded(filePath) {
    // Check direct exclusions
    if (this.exclusions.has(filePath)) {
      return true;
    }
    
    // Check for nosync marker file
    const nosyncPath = `${filePath}${this.syncMarker}`;
    if (fs.existsSync(nosyncPath)) {
      return true;
    }
    
    // Check for exclusions from file path patterns
    for (const exclusion of this.exclusions) {
      if (filePath.includes(exclusion)) {
        return true;
      }
    }
    
    return false;
  }

  /**
   * Stop all file watching activities
   */
  stopWatching() {
    console.log('ℹ️ Alpha Agent: Stopping all file watchers');
    
    // Close all watchers
    this.watchers.forEach(watcher => {
      watcher.close().catch(err => {
        console.error(`Error closing watcher: ${err}`);
      });
    });
    
    // Clear watchers array
    this.watchers = [];
    
    // Clear any pending changes
    for (const timeout of this.pendingChanges.values()) {
      clearTimeout(timeout);
    }
    this.pendingChanges.clear();
    
    // Clear memory monitoring interval
    if (this.memoryMonitorInterval) {
      clearInterval(this.memoryMonitorInterval);
      this.memoryMonitorInterval = null;
    }
    
    console.log('✅ Alpha Agent: All file watchers stopped');
  }
}

module.exports = AlphaAgent; 