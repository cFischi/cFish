/**
 * Process Tree Visualization Component
 * Implements virtual scrolling with node recycling for efficient process tree rendering
 */

const EventEmitter = require('events');
const { LRUCache } = require('lru-cache');

class ProcessTreeVisualization extends EventEmitter {
  constructor(config = {}) {
    super();
    this.config = {
      rendering: {
        mode: config.mode || 'virtual',
        updateInterval: config.updateInterval || 16, // 60fps
        batchSize: config.batchSize || 100,
        maxDepth: config.maxDepth || 10,
        compression: config.compression !== false,
        compressionThreshold: config.compressionThreshold || 1000 // bytes
      },
      optimization: {
        recycling: config.recycling !== false,
        memoryLimit: config.memoryLimit || 100 * 1024 * 1024, // 100MB
        cacheSize: config.cacheSize || 1000,
        cleanupInterval: config.cleanupInterval || 30000 // 30s
      },
      monitoring: {
        metrics: config.metrics || ['cpu', 'memory', 'io', 'network'],
        alerts: config.alerts !== false,
        history: config.history || 3600, // 1 hour
        aggregation: config.aggregation || '1s',
        thresholds: {
          cpu: { warning: 70, critical: 90 },
          memory: { warning: 70, critical: 85 },
          io: { warning: 1000, critical: 5000 },
          network: { warning: 80, critical: 95 }
        }
      },
      errorRecovery: {
        maxRetries: config.maxRetries || 3,
        retryDelay: config.retryDelay || 1000,
        recoveryStrategies: ['reconnect', 'reload', 'reset'],
        cacheRecoveryAttempts: config.cacheRecoveryAttempts || 3
      }
    };

    // Initialize virtual scrolling state
    this.virtualScroll = {
      offset: 0,
      visibleCount: 0,
      items: [],
      renderedRange: { start: 0, end: 0 }
    };

    // Initialize node recycling pool
    this.nodePool = {
      available: new Set(),
      inUse: new Map(),
      maxSize: this.config.optimization.cacheSize
    };

    // Initialize process cache with error handling and recovery
    this.initializeCache();

    // Initialize metrics collection
    this.metrics = {
      renderTime: [],
      memoryUsage: [],
      updateLatency: [],
      timestamp: [],
      cacheHits: 0,
      cacheMisses: 0,
      cacheErrors: 0,
      cacheRecoveries: 0
    };

    // Start cleanup interval
    this.startCleanup();
  }

  /**
   * Initializes the process cache with error handling and recovery
   */
  initializeCache() {
    try {
      this.processCache = new LRUCache({
        max: this.config.optimization.cacheSize,
        ttl: this.config.optimization.cleanupInterval,
        allowStale: true,  // Allow stale data during cache errors
        updateAgeOnGet: true,
        updateAgeOnHas: false,
        fetchMethod: async (pid, staleValue, { signal, context }) => {
          try {
            // If we have a stale value, use it temporarily
            if (staleValue) {
              return staleValue;
            }
            // Otherwise try to fetch fresh data
            return await this.getProcessInfo(pid);
          } catch (error) {
            this.emit('error', {
              message: `Cache fetch failed for process ${pid}`,
              error
            });
            this.metrics.cacheErrors++;
            return null;
          }
        }
      });

      // Add utility methods to handle different LRUCache versions
      this.addCacheUtilityMethods();

    } catch (error) {
      this.emit('error', {
        message: 'Failed to initialize process cache',
        error
      });
      // Create a fallback Map-based cache
      this.createFallbackCache();
    }
  }

  /**
   * Adds utility methods to handle different LRUCache versions
   */
  addCacheUtilityMethods() {
    try {
      // Add purgeStale method if not available (compatibility with different lru-cache versions)
      if (!this.processCache.purgeStale) {
        if (typeof this.processCache.prune === 'function') {
          // If prune is available (older versions), use it
          this.processCache.purgeStale = () => {
            try {
              this.processCache.prune();
            } catch (error) {
              this.emit('error', {
                message: 'Error during cache prune operation',
                error
              });
            }
          };
        } else {
          // Otherwise provide a manual implementation
          this.processCache.purgeStale = () => {
            this.manualCacheCleanup();
          };
        }
      }

      // Add safe get method
      const originalGet = this.processCache.get.bind(this.processCache);
      this.processCache.get = (key) => {
        try {
          const value = originalGet(key);
          if (value !== undefined) {
            this.metrics.cacheHits++;
          } else {
            this.metrics.cacheMisses++;
          }
          return value;
        } catch (error) {
          this.emit('error', {
            message: `Error retrieving cache value for key ${key}`,
            error
          });
          this.metrics.cacheErrors++;
          return undefined;
        }
      };

      // Add safe set method
      const originalSet = this.processCache.set.bind(this.processCache);
      this.processCache.set = (key, value) => {
        try {
          return originalSet(key, value);
        } catch (error) {
          this.emit('error', {
            message: `Error setting cache value for key ${key}`,
            error
          });
          this.metrics.cacheErrors++;
          
          // Attempt cache recovery if too many errors
          if (this.metrics.cacheErrors > 10) {
            this.recoverFromCacheError();
          }
          return this.processCache;
        }
      };

    } catch (error) {
      this.emit('error', {
        message: 'Failed to add cache utility methods',
        error
      });
    }
  }

  /**
   * Creates a fallback Map-based cache when LRUCache initialization fails
   */
  createFallbackCache() {
    this.emit('warning', {
      message: 'Using fallback Map-based cache due to LRUCache initialization failure'
    });

    // Create a simplified cache using Map
    const cache = new Map();
    const cacheMetadata = new Map();
    
    this.processCache = {
      max: this.config.optimization.cacheSize,
      ttl: this.config.optimization.cleanupInterval,
      
      get: (key) => {
        try {
          const entry = cache.get(key);
          if (!entry) {
            this.metrics.cacheMisses++;
            return undefined;
          }
          
          const metadata = cacheMetadata.get(key) || { timestamp: Date.now() };
          if (this.processCache.ttl && Date.now() - metadata.timestamp > this.processCache.ttl) {
            cache.delete(key);
            cacheMetadata.delete(key);
            this.metrics.cacheMisses++;
            return undefined;
          }
          
          // Update timestamp on get
          metadata.timestamp = Date.now();
          cacheMetadata.set(key, metadata);
          this.metrics.cacheHits++;
          return entry;
        } catch (error) {
          this.metrics.cacheErrors++;
          return undefined;
        }
      },
      
      set: (key, value) => {
        try {
          // Enforce max size limit
          if (cache.size >= this.processCache.max) {
            // Remove oldest entry
            let oldestKey;
            let oldestTime = Infinity;
            
            for (const [k, metadata] of cacheMetadata.entries()) {
              if (metadata.timestamp < oldestTime) {
                oldestTime = metadata.timestamp;
                oldestKey = k;
              }
            }
            
            if (oldestKey) {
              cache.delete(oldestKey);
              cacheMetadata.delete(oldestKey);
            }
          }
          
          cache.set(key, value);
          cacheMetadata.set(key, { timestamp: Date.now() });
          return this.processCache;
        } catch (error) {
          this.metrics.cacheErrors++;
          return this.processCache;
        }
      },
      
      has: (key) => {
        try {
          const exists = cache.has(key);
          if (!exists) return false;
          
          // Check TTL
          const metadata = cacheMetadata.get(key);
          if (this.processCache.ttl && Date.now() - metadata.timestamp > this.processCache.ttl) {
            cache.delete(key);
            cacheMetadata.delete(key);
            return false;
          }
          
          return true;
        } catch (error) {
          return false;
        }
      },
      
      delete: (key) => {
        try {
          cacheMetadata.delete(key);
          return cache.delete(key);
        } catch (error) {
          return false;
        }
      },
      
      clear: () => {
        try {
          cache.clear();
          cacheMetadata.clear();
        } catch (error) {
          // Ignore error
        }
      },
      
      keys: () => {
        try {
          return cache.keys();
        } catch (error) {
          return [].values();
        }
      },
      
      purgeStale: () => {
        try {
          const now = Date.now();
          const keysToDelete = [];
          
          for (const [key, metadata] of cacheMetadata.entries()) {
            if (this.processCache.ttl && now - metadata.timestamp > this.processCache.ttl) {
              keysToDelete.push(key);
            }
          }
          
          for (const key of keysToDelete) {
            cache.delete(key);
            cacheMetadata.delete(key);
          }
        } catch (error) {
          // Ignore error
        }
      }
    };
  }

  /**
   * Updates the visible processes based on scroll position
   * @param {number} offset - New scroll offset
   */
  async updateVisibleProcesses(offset) {
    const startTime = performance.now();

    try {
      // Update scroll offset
      this.virtualScroll.offset = Math.max(0, offset);

      // Calculate visible range with overscan
      const { batchSize } = this.config.rendering;
      const start = Math.max(0, this.virtualScroll.offset - batchSize);
      const end = Math.min(
        this.virtualScroll.items.length,
        this.virtualScroll.offset + this.virtualScroll.visibleCount + batchSize
      );

      // Only update if range has changed
      if (
        start === this.virtualScroll.renderedRange.start &&
        end === this.virtualScroll.renderedRange.end
      ) {
        return;
      }

      // Update rendered range
      this.virtualScroll.renderedRange = { start, end };

      // Process items in batches with compression
      const visibleItems = [];
      let retryCount = 0;
      let lastError = null;

      while (retryCount <= this.config.errorRecovery.maxRetries) {
        try {
          for (let i = start; i < end; i += batchSize) {
            const batchEnd = Math.min(i + batchSize, end);
            const batchPromises = [];

            for (let j = i; j < batchEnd; j++) {
              const item = this.virtualScroll.items[j];
              if (!item) continue;

              // Try to get cached process info with error handling
              let processInfo;
              try {
                processInfo = this.processCache.get(item.pid);
              } catch (cacheError) {
                this.emit('error', {
                  message: `Cache get error for process ${item.pid}`,
                  error: cacheError
                });
                this.metrics.cacheErrors++;
                
                // Try to recover if we've had too many cache errors
                if (this.metrics.cacheErrors > 10) {
                  await this.recoverFromCacheError();
                }
              }

              if (!processInfo) {
                // Get fresh process info with compression
                batchPromises.push(
                  this.getProcessInfo(item.pid)
                    .then(info => {
                      if (info) {
                        // Compress data if needed
                        if (this.config.rendering.compression) {
                          info = this.compressProcessInfo(info);
                        }
                        
                        try {
                          this.processCache.set(item.pid, info);
                        } catch (setCacheError) {
                          this.emit('error', {
                            message: `Cache set error for process ${item.pid}`,
                            error: setCacheError
                          });
                          this.metrics.cacheErrors++;
                        }
                        
                        item.info = info;
                      }
                      return item;
                    })
                    .catch(error => {
                      this.emit('error', {
                        message: `Error fetching process info for PID ${item.pid}`,
                        error
                      });
                      return item;
                    })
                );
              } else {
                item.info = processInfo;
              }
              visibleItems.push(item);
            }

            if (batchPromises.length > 0) {
              await Promise.all(batchPromises).catch(error => {
                this.emit('error', {
                  message: 'Error processing batch promises',
                  error
                });
              });
              // Allow other operations between batches
              await new Promise(resolve => setTimeout(resolve, 0));
            }
          }

          // Update was successful, break retry loop
          break;

        } catch (error) {
          lastError = error;
          retryCount++;

          if (retryCount <= this.config.errorRecovery.maxRetries) {
            // Wait before retry
            await new Promise(resolve => 
              setTimeout(resolve, this.config.errorRecovery.retryDelay)
            );
            
            // Try recovery strategies
            await this.attemptRecovery(retryCount);
          }
        }
      }

      // If all retries failed, emit error
      if (retryCount > this.config.errorRecovery.maxRetries) {
        this.emit('error', {
          message: 'Failed to update visible processes after retries',
          error: lastError,
          retries: retryCount
        });
        return;
      }

      // Update visible items
      await this.renderProcessNodes(visibleItems);

      // Track metrics
      const endTime = performance.now();
      this.trackMetrics('renderTime', endTime - startTime);

    } catch (error) {
      this.emit('error', {
        message: 'Error updating visible processes',
        error,
        offset
      });
    }
  }

  /**
   * Renders process nodes with recycling
   * @param {Array} items - Process items to render
   */
  async renderProcessNodes(items) {
    try {
      // Recycle unused nodes
      this.recycleNodes();

      // Render each item
      for (const item of items) {
        let node = this.nodePool.inUse.get(item.pid);
        
        if (!node) {
          // Get recycled node or create new one
          node = this.getRecycledNode(item);
          this.nodePool.inUse.set(item.pid, node);
        }

        // Update node content
        this.updateNodeContent(node, item);
      }

      this.emit('render-complete');

    } catch (error) {
      this.emit('error', {
        message: 'Error rendering process nodes',
        error
      });
    }
  }

  /**
   * Gets a recycled node or creates a new one
   * @param {Object} item - Process item
   * @returns {Object} Node object
   */
  getRecycledNode(item) {
    let node;
    
    if (this.nodePool.available.size > 0) {
      // Get node from pool
      node = this.nodePool.available.values().next().value;
      this.nodePool.available.delete(node);
    } else if (this.nodePool.inUse.size < this.nodePool.maxSize) {
      // Create new node
      node = this.createNode();
    } else {
      // Recycle least recently used node
      const oldestPid = this.nodePool.inUse.keys().next().value;
      node = this.nodePool.inUse.get(oldestPid);
      this.nodePool.inUse.delete(oldestPid);
    }

    return node;
  }

  /**
   * Creates a new node object
   * @returns {Object} New node object
   */
  createNode() {
    return {
      element: document.createElement('div'),
      content: null,
      timestamp: Date.now()
    };
  }

  /**
   * Updates node content with process information
   * @param {Object} node - Node to update
   * @param {Object} item - Process item
   */
  updateNodeContent(node, item) {
    const { info } = item;
    if (!info) return;

    const content = this.formatProcessInfo(info);
    if (node.content !== content) {
      node.content = content;
      node.element.innerHTML = content;
      node.timestamp = Date.now();
    }
  }

  /**
   * Formats process information for display
   * @param {Object} info - Process information
   * @returns {string} Formatted HTML
   */
  formatProcessInfo(info) {
    const { cpu, memory, status } = info;
    const cpuClass = this.getMetricClass(cpu);
    const memoryClass = this.getMetricClass(memory);

    return `
      <div class="process-node">
        <span class="process-name">${info.name}</span>
        <span class="process-metric ${cpuClass}">CPU: ${cpu.toFixed(1)}%</span>
        <span class="process-metric ${memoryClass}">MEM: ${memory.toFixed(1)}%</span>
        <span class="process-status">[${status}]</span>
      </div>
    `;
  }

  /**
   * Gets CSS class based on metric value
   * @param {number} value - Metric value
   * @returns {string} CSS class
   */
  getMetricClass(value) {
    if (value >= this.config.monitoring.thresholds?.critical || 90) return 'critical';
    if (value >= this.config.monitoring.thresholds?.warning || 70) return 'warning';
    return 'normal';
  }

  /**
   * Recycles unused nodes
   */
  recycleNodes() {
    const now = Date.now();
    const maxAge = this.config.optimization.cleanupInterval;

    // Move old nodes to available pool
    for (const [pid, node] of this.nodePool.inUse) {
      if (now - node.timestamp > maxAge) {
        this.nodePool.inUse.delete(pid);
        this.nodePool.available.add(node);
      }
    }

    // Limit available pool size
    while (this.nodePool.available.size > this.nodePool.maxSize) {
      const oldestNode = this.nodePool.available.values().next().value;
      this.nodePool.available.delete(oldestNode);
    }
  }

  /**
   * Starts the cleanup interval
   */
  startCleanup() {
    this.cleanupInterval = setInterval(() => {
      try {
        this.recycleNodes();
        
        // Safely call purgeStale on the cache with proper fallbacks
        this.safePurgeStaleCache();
        
        this.cleanupMetrics();
      } catch (error) {
        this.emit('error', {
          message: 'Error during cleanup',
          error
        });
        
        // Attempt recovery for serious errors
        if (this.metrics.cacheErrors > 10) {
          this.recoverFromCacheError();
        }
      }
    }, this.config.optimization.cleanupInterval);
  }

  /**
   * Safely purge stale cache entries with error handling
   */
  safePurgeStaleCache() {
    try {
      // Check if cache exists
      if (!this.processCache) {
        this.initializeCache();
        return;
      }
      
      // Try to call purgeStale
      if (typeof this.processCache.purgeStale === 'function') {
        this.processCache.purgeStale();
      } else {
        // Fall back to manual cleanup
        this.manualCacheCleanup();
      }
    } catch (error) {
      this.emit('error', {
        message: 'Error during cache purge',
        error
      });
      this.metrics.cacheErrors++;
      
      // If we've had too many errors, attempt recovery
      if (this.metrics.cacheErrors > 10) {
        this.recoverFromCacheError();
      }
    }
  }

  /**
   * Manual cache cleanup for compatibility with different lru-cache versions
   */
  manualCacheCleanup() {
    try {
      // Get all cache keys
      const keys = Array.from(this.processCache.keys());
      const now = Date.now();
      const ttl = this.config.optimization.cleanupInterval;
      
      // For each key, check if the entry is stale
      for (const key of keys) {
        try {
          const entry = this.processCache.get(key);
          if (!entry) continue;
          
          // Check if we can access the entry timestamp
          let timestamp = null;
          
          // Try different ways to get timestamp depending on lru-cache version
          if (entry._timestamp) {
            timestamp = entry._timestamp;
          } else if (entry.timestamp) {
            timestamp = entry.timestamp;
          } else if (this.processCache.getRemainingTTL) {
            // If getRemainingTTL is available, use it to check staleness
            const remaining = this.processCache.getRemainingTTL(key);
            if (remaining <= 0) {
              this.processCache.delete(key);
            }
            continue;
          }
          
          // If we have a timestamp, check if the entry is stale
          if (timestamp && now - timestamp > ttl) {
            this.processCache.delete(key);
          }
        } catch (entryError) {
          // Ignore errors for individual entries
          console.error(`Error processing cache entry for key ${key}:`, entryError);
        }
      }
    } catch (error) {
      // If manual cleanup fails, emit an error but don't throw
      this.emit('error', {
        message: 'Manual cache cleanup failed',
        error
      });
      this.metrics.cacheErrors++;
    }
  }

  /**
   * Recover from cache error
   */
  async recoverFromCacheError() {
    // Check if we've already attempted too many recoveries
    if (this.metrics.cacheRecoveries >= this.config.errorRecovery.cacheRecoveryAttempts) {
      this.emit('error', {
        message: `Cache recovery limit reached (${this.metrics.cacheRecoveries} attempts)`,
        recoveryAttempts: this.metrics.cacheRecoveries
      });
      return;
    }
    
    this.metrics.cacheRecoveries++;
    
    try {
      // Emit recovery attempt event
      this.emit('cache-recovery-attempt', {
        message: `Attempting cache recovery (attempt ${this.metrics.cacheRecoveries})`,
        timestamp: Date.now()
      });
      
      // Try to backup existing cache data
      const backupData = new Map();
      try {
        if (this.processCache && typeof this.processCache.keys === 'function') {
          for (const key of this.processCache.keys()) {
            try {
              const value = this.processCache.get(key);
              if (value) {
                backupData.set(key, value);
              }
            } catch (backupError) {
              // Ignore individual entry errors
            }
          }
        }
      } catch (backupError) {
        this.emit('warning', {
          message: 'Failed to backup cache data',
          error: backupError
        });
      }
      
      // Recreate the cache
      this.initializeCache();
      
      // Try to restore data
      if (backupData.size > 0) {
        try {
          let restoredCount = 0;
          for (const [key, value] of backupData.entries()) {
            try {
              this.processCache.set(key, value);
              restoredCount++;
            } catch (restoreError) {
              // Ignore individual entry errors
            }
          }
          
          this.emit('cache-recovered', {
            message: 'Cache recovered successfully',
            entriesRestored: restoredCount,
            totalEntries: backupData.size
          });
        } catch (restoreError) {
          this.emit('warning', {
            message: 'Failed to restore cache data',
            error: restoreError
          });
        }
      }
      
      // Reset error count after successful recovery
      this.metrics.cacheErrors = 0;
      
    } catch (recoveryError) {
      this.emit('error', {
        message: 'Failed to recover from cache error',
        error: recoveryError,
        recoveryAttempt: this.metrics.cacheRecoveries
      });
      
      // If we've failed multiple times and hit our limit, fall back to Map-based cache
      if (this.metrics.cacheRecoveries >= this.config.errorRecovery.cacheRecoveryAttempts) {
        this.createFallbackCache();
      }
    }
  }

  /**
   * Tracks performance metrics
   * @param {string} metric - Metric name
   * @param {number} value - Metric value
   */
  trackMetrics(metric, value) {
    const now = Date.now();
    this.metrics[metric].push(value);
    this.metrics.timestamp.push(now);

    // Limit metrics history
    const maxHistory = this.config.monitoring.history;
    if (this.metrics[metric].length > maxHistory) {
      this.metrics[metric].shift();
      this.metrics.timestamp.shift();
    }

    // Emit metric update
    this.emit('metric', {
      name: metric,
      value,
      timestamp: now
    });
  }

  /**
   * Cleans up old metrics
   */
  cleanupMetrics() {
    const now = Date.now();
    const maxAge = this.config.monitoring.history * 1000;

    // Remove metrics older than maxAge
    while (this.metrics.timestamp.length > 0 && now - this.metrics.timestamp[0] > maxAge) {
      Object.keys(this.metrics).forEach(key => {
        if (Array.isArray(this.metrics[key])) {
          this.metrics[key].shift();
        }
      });
    }
  }

  /**
   * Gets process information
   * @param {number} pid - Process ID
   * @returns {Promise<Object>} Process information
   */
  async getProcessInfo(pid) {
    // This should be implemented by the parent class
    throw new Error('getProcessInfo must be implemented');
  }

  /**
   * Compresses process information
   * @param {Object} info - Process information
   * @returns {Object} Compressed process information
   */
  compressProcessInfo(info) {
    if (!this.config.rendering.compression) return info;

    const compressed = {
      name: info.name,
      status: info.status,
      metrics: {}
    };

    // Round numeric values to reduce size
    for (const metric of this.config.monitoring.metrics) {
      if (typeof info[metric] === 'number') {
        compressed.metrics[metric] = Math.round(info[metric] * 10) / 10;
      }
    }

    return compressed;
  }

  /**
   * Attempts to recover from errors
   * @param {number} retryCount - Current retry attempt
   */
  async attemptRecovery(retryCount) {
    const strategy = this.config.errorRecovery.recoveryStrategies[
      Math.min(retryCount - 1, this.config.errorRecovery.recoveryStrategies.length - 1)
    ];

    switch (strategy) {
      case 'reconnect':
        // Attempt to reconnect WebSocket
        this.emit('recovery_attempt', {
          strategy: 'reconnect',
          attempt: retryCount
        });
        break;

      case 'reload':
        // Clear cache and reload data
        try {
          this.processCache.clear();
        } catch (clearError) {
          // If clear fails, try to recreate the cache
          this.initializeCache();
        }
        
        this.emit('recovery_attempt', {
          strategy: 'reload',
          attempt: retryCount
        });
        break;

      case 'reset':
        // Reset component state
        this.resetState();
        this.emit('recovery_attempt', {
          strategy: 'reset',
          attempt: retryCount
        });
        break;
        
      default:
        // Unknown strategy, fall back to reset
        this.resetState();
        this.emit('recovery_attempt', {
          strategy: 'reset (default)',
          attempt: retryCount
        });
    }
  }

  /**
   * Resets the component state
   */
  resetState() {
    this.virtualScroll = {
      offset: 0,
      visibleCount: 0,
      items: [],
      renderedRange: { start: 0, end: 0 }
    };

    this.nodePool.available.clear();
    this.nodePool.inUse.clear();
    
    // Reset cache
    try {
      this.processCache.clear();
    } catch (clearError) {
      // If clear fails, recreate the cache
      this.initializeCache();
    }

    // Reset metrics
    Object.keys(this.metrics).forEach(key => {
      if (Array.isArray(this.metrics[key])) {
        this.metrics[key] = [];
      } else if (typeof this.metrics[key] === 'number') {
        this.metrics[key] = 0;
      }
    });
  }

  /**
   * Destroys the component and cleans up resources
   */
  destroy() {
    // Clear intervals
    clearInterval(this.cleanupInterval);

    // Clear caches
    try {
      this.processCache.clear();
    } catch (error) {
      // Ignore errors during destroy
    }
    
    this.nodePool.available.clear();
    this.nodePool.inUse.clear();

    // Clear metrics
    Object.keys(this.metrics).forEach(key => {
      if (Array.isArray(this.metrics[key])) {
        this.metrics[key] = [];
      } else if (typeof this.metrics[key] === 'number') {
        this.metrics[key] = 0;
      }
    });

    // Remove all listeners
    this.removeAllListeners();
  }
  
  /**
   * Get cache statistics and status
   * @returns {Object} Cache statistics
   */
  getCacheStats() {
    try {
      const stats = {
        size: 0,
        hits: this.metrics.cacheHits,
        misses: this.metrics.cacheMisses,
        errors: this.metrics.cacheErrors,
        recoveries: this.metrics.cacheRecoveries,
        hitRate: 0,
        status: 'unknown'
      };
      
      // Try to get current cache size
      if (this.processCache) {
        if (typeof this.processCache.size === 'number') {
          stats.size = this.processCache.size;
        } else if (this.processCache instanceof Map) {
          stats.size = this.processCache.size;
        } else {
          // Try to count keys
          try {
            stats.size = Array.from(this.processCache.keys()).length;
          } catch (error) {
            stats.size = -1; // Unknown size
          }
        }
      }
      
      // Calculate hit rate
      const totalAccesses = stats.hits + stats.misses;
      if (totalAccesses > 0) {
        stats.hitRate = (stats.hits / totalAccesses) * 100;
      }
      
      // Determine cache status
      if (stats.errors > 10) {
        stats.status = 'degraded';
      } else if (this.processCache instanceof Map && !(this.processCache instanceof LRUCache)) {
        stats.status = 'fallback';
      } else if (stats.recoveries > 0) {
        stats.status = 'recovered';
      } else {
        stats.status = 'healthy';
      }
      
      return stats;
      
    } catch (error) {
      return {
        size: -1,
        hits: this.metrics.cacheHits,
        misses: this.metrics.cacheMisses,
        errors: this.metrics.cacheErrors + 1,
        recoveries: this.metrics.cacheRecoveries,
        hitRate: 0,
        status: 'error',
        errorMessage: error.message
      };
    }
  }
}

module.exports = ProcessTreeVisualization; 