/**
 * Memory Manager for MD-JSON Sync System
 * 
 * This utility provides memory monitoring and management capabilities to prevent
 * out-of-memory crashes in the MD-JSON synchronization system.
 * 
 * Features:
 * - Memory usage monitoring
 * - Proactive garbage collection
 * - Graceful shutdown when approaching memory limits
 * - Memory usage statistics and reporting
 */

class MemoryManager {
  constructor(options = {}) {
    // Configuration
    this.options = {
      warningThreshold: options.warningThreshold || 0.7, // 70% of max memory
      criticalThreshold: options.criticalThreshold || 0.85, // 85% of max memory
      gcInterval: options.gcInterval || 60000, // Run GC every 60 seconds
      statsInterval: options.statsInterval || 300000, // Log stats every 5 minutes
      maxHeapSize: options.maxHeapSize || 0, // Will be detected if not provided
      enabled: options.enabled !== false, // Enabled by default
      debug: options.debug || false // Debug mode for verbose logging
    };

    // State
    this.isRunning = false;
    this.gcTimer = null;
    this.statsTimer = null;
    this.lastGC = 0;
    this.memoryWarningIssued = false;
    this.memoryStats = {
      collections: 0,
      warnings: 0,
      maxHeapUsed: 0,
      startTime: Date.now()
    };

    // Detect max heap size if not provided
    if (!this.options.maxHeapSize) {
      // Try to detect from NODE_OPTIONS or use a reasonable default
      const nodeOptions = process.env.NODE_OPTIONS || '';
      const maxOldSpaceMatch = nodeOptions.match(/--max-old-space-size=(\d+)/);
      
      if (maxOldSpaceMatch && maxOldSpaceMatch[1]) {
        this.options.maxHeapSize = parseInt(maxOldSpaceMatch[1], 10) * 1024 * 1024;
      } else {
        // Default to 2GB if not specified
        this.options.maxHeapSize = 2 * 1024 * 1024 * 1024;
      }
    }

    // Bind methods
    this.getMemoryUsage = this.getMemoryUsage.bind(this);
    this.runGarbageCollection = this.runGarbageCollection.bind(this);
    this.checkMemoryUsage = this.checkMemoryUsage.bind(this);
    this.logMemoryStats = this.logMemoryStats.bind(this);
    this.start = this.start.bind(this);
    this.stop = this.stop.bind(this);
    this.formatBytes = this.formatBytes.bind(this);
  }

  /**
   * Get current memory usage statistics
   * @returns {Object} Memory usage information
   */
  getMemoryUsage() {
    const memoryUsage = process.memoryUsage();
    
    // Calculate percentages
    const heapUsedPercent = memoryUsage.heapUsed / this.options.maxHeapSize;
    const rssPercent = memoryUsage.rss / this.options.maxHeapSize;
    
    // Update max values
    this.memoryStats.maxHeapUsed = Math.max(this.memoryStats.maxHeapUsed, memoryUsage.heapUsed);
    
    return {
      ...memoryUsage,
      heapUsedPercent,
      rssPercent,
      maxHeapSize: this.options.maxHeapSize
    };
  }

  /**
   * Format bytes to human-readable string
   * @param {number} bytes - Bytes to format
   * @returns {string} Formatted string
   */
  formatBytes(bytes) {
    if (bytes === 0) return '0 B';
    
    const sizes = ['B', 'KB', 'MB', 'GB', 'TB'];
    const i = Math.floor(Math.log(bytes) / Math.log(1024));
    
    return `${(bytes / Math.pow(1024, i)).toFixed(2)} ${sizes[i]}`;
  }

  /**
   * Run garbage collection if available
   * @returns {boolean} Whether GC was run
   */
  runGarbageCollection() {
    if (global.gc) {
      if (this.options.debug) {
        console.log('📊 Memory Manager: Running garbage collection');
      }
      
      global.gc();
      this.lastGC = Date.now();
      this.memoryStats.collections++;
      return true;
    }
    
    return false;
  }

  /**
   * Check memory usage and take action if needed
   * @returns {Object} Memory status
   */
  checkMemoryUsage() {
    const memoryUsage = this.getMemoryUsage();
    
    // Check if we're approaching memory limits
    if (memoryUsage.heapUsedPercent > this.options.criticalThreshold) {
      console.warn(`⚠️ CRITICAL: Memory usage at ${(memoryUsage.heapUsedPercent * 100).toFixed(1)}% of limit`);
      console.warn(`Heap used: ${this.formatBytes(memoryUsage.heapUsed)} of ${this.formatBytes(this.options.maxHeapSize)}`);
      
      // Run garbage collection
      this.runGarbageCollection();
      
      // If still critical after GC, recommend restart
      const postGCUsage = this.getMemoryUsage();
      if (postGCUsage.heapUsedPercent > this.options.criticalThreshold) {
        console.error('🚨 MEMORY CRITICAL: System should be restarted');
        
        // Emit event for graceful shutdown
        if (this.options.onCriticalMemory) {
          this.options.onCriticalMemory(postGCUsage);
        }
        
        return { status: 'critical', usage: postGCUsage };
      }
      
      return { status: 'warning', usage: postGCUsage };
    } 
    else if (memoryUsage.heapUsedPercent > this.options.warningThreshold) {
      if (!this.memoryWarningIssued) {
        console.warn(`⚠️ WARNING: Memory usage at ${(memoryUsage.heapUsedPercent * 100).toFixed(1)}% of limit`);
        console.warn(`Heap used: ${this.formatBytes(memoryUsage.heapUsed)} of ${this.formatBytes(this.options.maxHeapSize)}`);
        this.memoryWarningIssued = true;
        this.memoryStats.warnings++;
        
        // Run garbage collection
        this.runGarbageCollection();
      }
      
      return { status: 'warning', usage: memoryUsage };
    } 
    else {
      // Reset warning flag if we're back to normal
      if (this.memoryWarningIssued) {
        console.log('✅ Memory usage returned to normal levels');
        this.memoryWarningIssued = false;
      }
      
      return { status: 'normal', usage: memoryUsage };
    }
  }

  /**
   * Log memory statistics
   */
  logMemoryStats() {
    const memoryUsage = this.getMemoryUsage();
    const uptime = (Date.now() - this.memoryStats.startTime) / 1000;
    
    console.log('📊 Memory Manager: Statistics');
    console.log(`Uptime: ${Math.floor(uptime / 3600)}h ${Math.floor((uptime % 3600) / 60)}m ${Math.floor(uptime % 60)}s`);
    console.log(`Heap used: ${this.formatBytes(memoryUsage.heapUsed)} (${(memoryUsage.heapUsedPercent * 100).toFixed(1)}%)`);
    console.log(`RSS: ${this.formatBytes(memoryUsage.rss)}`);
    console.log(`External: ${this.formatBytes(memoryUsage.external)}`);
    console.log(`Max heap used: ${this.formatBytes(this.memoryStats.maxHeapUsed)}`);
    console.log(`GC collections: ${this.memoryStats.collections}`);
    console.log(`Memory warnings: ${this.memoryStats.warnings}`);
  }

  /**
   * Start memory monitoring
   */
  start() {
    if (this.isRunning || !this.options.enabled) {
      return;
    }
    
    console.log('📊 Memory Manager: Starting monitoring');
    
    // Check if we have access to garbage collection
    if (!global.gc && this.options.debug) {
      console.warn('⚠️ Memory Manager: Garbage collection not available. Run Node.js with --expose-gc flag for better memory management.');
    }
    
    // Set up periodic garbage collection
    this.gcTimer = setInterval(() => {
      this.runGarbageCollection();
    }, this.options.gcInterval);
    
    // Set up periodic stats logging
    this.statsTimer = setInterval(() => {
      this.logMemoryStats();
    }, this.options.statsInterval);
    
    // Make sure timers don't prevent process exit
    this.gcTimer.unref();
    this.statsTimer.unref();
    
    this.isRunning = true;
    
    // Initial memory check
    this.checkMemoryUsage();
    
    return true;
  }

  /**
   * Stop memory monitoring
   */
  stop() {
    if (!this.isRunning) {
      return;
    }
    
    console.log('📊 Memory Manager: Stopping monitoring');
    
    if (this.gcTimer) {
      clearInterval(this.gcTimer);
      this.gcTimer = null;
    }
    
    if (this.statsTimer) {
      clearInterval(this.statsTimer);
      this.statsTimer = null;
    }
    
    this.isRunning = false;
    
    // Final stats
    this.logMemoryStats();
    
    return true;
  }
}

// Export the MemoryManager class
module.exports = MemoryManager; 