const EventEmitter = require('events');
const fs = require('fs').promises;
const path = require('path');
const CircularBuffer = require('circular-buffer');

class QueuePriority extends EventEmitter {
  constructor(config = {}) {
    super();
    this.config = {
      queueFile: path.join(__dirname, '../queue.json'),
      maxConcurrent: 3,
      priorityLevels: {
        critical: {
          weight: 100,
          maxWaitTime: 30000, // 30 seconds
          resourceQuota: { cpu: 50, memory: 1024, io: 1000 },
          scalingFactor: 1.5
        },
        high: {
          weight: 75,
          maxWaitTime: 60000, // 1 minute
          resourceQuota: { cpu: 40, memory: 768, io: 750 },
          scalingFactor: 1.25
        },
        medium: {
          weight: 50,
          maxWaitTime: 180000, // 3 minutes
          resourceQuota: { cpu: 30, memory: 512, io: 500 },
          scalingFactor: 1.0
        },
        low: {
          weight: 25,
          maxWaitTime: 300000, // 5 minutes
          resourceQuota: { cpu: 20, memory: 256, io: 250 },
          scalingFactor: 0.75
        }
      },
      resourceThresholds: {
        cpu: 80,
        memory: 75,
        disk: 90,
        io: 1000,
        adjustmentFactor: 0.1,
        minThreshold: 20,
        maxThreshold: 95
      },
      monitoring: {
        enabled: true,
        interval: 1000, // 1 second
        metrics: ['latency', 'throughput', 'utilization', 'health'],
        history: 86400, // 24 hours
        aggregation: '1m',
        alertThresholds: {
          latency: 5000,
          errorRate: 0.1,
          queueGrowth: 0.2
        }
      },
      adaptivePriority: {
        enabled: true,
        factors: {
          waitTime: 0.4,
          resourceUsage: 0.3,
          urgency: 0.3,
          errorRate: 0.2,
          systemLoad: 0.2
        },
        updateInterval: 5000, // 5 seconds
        learningRate: 0.1,
        maxAdjustment: 0.5
      },
      ...config
    };

    this.queue = [];
    this.installing = new Set();
    this.completed = new Set();
    this.failed = new Set();
    
    this.metrics = {
      latency: new CircularBuffer(1000),
      throughput: new CircularBuffer(1000),
      utilization: new CircularBuffer(1000),
      health: new CircularBuffer(1000),
      resourceUsage: new Map(),
      errorRates: new Map(),
      lastUpdate: Date.now()
    };

    this.adaptiveState = {
      resourceLimits: { ...this.config.resourceThresholds },
      priorityWeights: new Map(),
      loadHistory: new CircularBuffer(100),
      errorHistory: new CircularBuffer(100)
    };

    this.queues = new Map([
      ['critical', []],
      ['high', []],
      ['medium', []],
      ['low', []]
    ]);

    // Initialize monitoring
    if (this.config.monitoring.enabled) {
      this.startMonitoring();
    }

    // Initialize adaptive priority
    if (this.config.adaptivePriority.enabled) {
      this.startAdaptivePriority();
    }

    // Load initial state
    this.loadState().catch(err => {
      this.emit('error', {
        message: 'Failed to load queue state',
        error: err
      });
    });

    // Start queue processing
    this.startQueueProcessor();
  }

  startQueueProcessor() {
    let isProcessing = false;
    const processor = async () => {
      if (isProcessing) return;
      
      try {
        isProcessing = true;
        await this.processQueue();
      } catch (error) {
        this.handleError(error);
      } finally {
        isProcessing = false;
      }
    };

    setInterval(processor, 1000);
  }

  handleError(error, context = {}) {
    this.emit('error', {
      message: error.message,
      error,
      context,
      timestamp: Date.now()
    });

    // Update error metrics
    this.updateErrorMetrics(error);
  }

  updateErrorMetrics(error) {
    const now = Date.now();
    const errorType = error.name || 'UnknownError';
    
    if (!this.metrics.errorRates.has(errorType)) {
      this.metrics.errorRates.set(errorType, new CircularBuffer(100));
    }
    
    this.metrics.errorRates.get(errorType).push({
      timestamp: now,
      error: error.message
    });

    // Update health score
    this.updateHealthScore();
  }

  updateHealthScore() {
    const now = Date.now();
    const recentErrors = Array.from(this.metrics.errorRates.values())
      .flatMap(buffer => buffer.getRecent(300000)) // Last 5 minutes
      .length;
    
    const queueGrowth = this.calculateQueueGrowth();
    const resourceUtilization = this.calculateUtilization(this.getLatestResources());
    
    const healthScore = Math.max(0, Math.min(100, 100 - (
      (recentErrors * 10) +
      (queueGrowth * 20) +
      (resourceUtilization.average * 0.5)
    )));

    this.metrics.health.push({
      timestamp: now,
      score: healthScore,
      factors: {
        errors: recentErrors,
        queueGrowth,
        resourceUtilization
      }
    });
  }

  calculateQueueGrowth() {
    const recentMetrics = this.metrics.throughput.getRecent(300000);
    if (recentMetrics.length < 2) return 0;

    const oldestCount = recentMetrics[0].queueSize;
    const newestCount = recentMetrics[recentMetrics.length - 1].queueSize;
    
    return (newestCount - oldestCount) / Math.max(oldestCount, 1);
  }

  /**
   * Add a package to the installation queue
   */
  async addToQueue(pkg, priority = 'medium') {
    try {
      const queueItem = {
        name: pkg,
        priority,
        addedAt: Date.now(),
        weight: await this.calculateWeight(priority),
        attempts: 0,
        state: 'queued',
        metrics: {
          resourceUsage: {},
          errors: [],
          retries: 0
        }
      };

      this.queues.get(priority).push(queueItem);
      await this.sortQueue(priority);
      await this.saveState();

      this.emit('package_queued', queueItem);
      return queueItem;
    } catch (error) {
      this.handleError(error, { package: pkg, priority });
      throw error;
    }
  }

  /**
   * Calculate weight for priority sorting
   */
  async calculateWeight(priority) {
    const config = this.config.priorityLevels[priority];
    if (!config) return 0;

    const baseWeight = config.weight;
    const waitingTime = this.calculateWaitingTime(priority);
    const resourceScore = await this.calculateResourceScore(priority);
    const systemLoad = this.calculateSystemLoad();
    const errorFactor = this.calculateErrorFactor(priority);

    // Combine factors using adaptive weights
    const weights = this.adaptiveState.priorityWeights.get(priority) || {
      waiting: 0.4,
      resources: 0.3,
      load: 0.2,
      errors: 0.1
    };

    return Math.round(
      baseWeight * config.scalingFactor * (
        (waitingTime * weights.waiting) +
        (resourceScore * weights.resources) +
        (systemLoad * weights.load) +
        (errorFactor * weights.errors)
      )
    );
  }

  calculateWaitingTime(priority) {
    const queue = this.queues.get(priority);
    if (!queue.length) return 0;

    const maxWaitTime = this.config.priorityLevels[priority].maxWaitTime;
    const oldestItem = queue[0];
    const waitTime = Date.now() - oldestItem.addedAt;

    return Math.min(waitTime / maxWaitTime, 1);
  }

  calculateSystemLoad() {
    const recentLoad = this.adaptiveState.loadHistory.getRecent(60000);
    if (!recentLoad.length) return 0;

    return recentLoad.reduce((acc, val) => acc + val, 0) / recentLoad.length;
  }

  calculateErrorFactor(priority) {
    const queue = this.queues.get(priority);
    if (!queue.length) return 0;

    const errors = queue.reduce((acc, item) => acc + item.metrics.errors.length, 0);
    const totalItems = queue.length;

    return Math.min(errors / (totalItems * 3), 1); // Cap at 1
  }

  /**
   * Sort queue based on priority weights
   */
  async sortQueue(priority) {
    const queue = this.queues.get(priority);
    queue.sort((a, b) => {
      // Update weights
      a.weight = this.calculateWeight(priority);
      b.weight = this.calculateWeight(priority);
      
      // Sort by weight descending
      return b.weight - a.weight;
    });
  }

  /**
   * Process the installation queue
   */
  async processQueue() {
    try {
      // Check resource availability
      const resources = await this.checkResources();
      if (!this.canProcessMore(resources)) {
        this.emit('queue_paused', {
          reason: 'resource_limits',
          resources
        });
        return;
      }

      // Process items while we can
      while (this.installing.size < this.config.maxConcurrent && this.queues.get('critical').length > 0) {
        const item = this.queues.get('critical').shift();
        if (item) {
          await this.installPackage(item);
        }
      }

      while (this.installing.size < this.config.maxConcurrent && this.queues.get('high').length > 0) {
        const item = this.queues.get('high').shift();
        if (item) {
          await this.installPackage(item);
        }
      }

      while (this.installing.size < this.config.maxConcurrent && this.queues.get('medium').length > 0) {
        const item = this.queues.get('medium').shift();
        if (item) {
          await this.installPackage(item);
        }
      }

      while (this.installing.size < this.config.maxConcurrent && this.queues.get('low').length > 0) {
        const item = this.queues.get('low').shift();
        if (item) {
          await this.installPackage(item);
        }
      }
    } catch (error) {
      this.handleError(error);
    }
  }

  /**
   * Check if we can process more items
   */
  canProcessMore(resources) {
    return (
      this.installing.size < this.config.maxConcurrent &&
      resources.cpu < this.config.resourceThresholds.cpu &&
      resources.memory < this.config.resourceThresholds.memory &&
      resources.disk < this.config.resourceThresholds.disk
    );
  }

  /**
   * Install a package
   */
  async installPackage(item) {
    try {
      item.state = 'installing';
      item.startedAt = Date.now();
      item.attempts++;
      this.installing.add(item.name);
      
      this.emit('installation_started', item);
      await this.saveState();

      // Simulate installation (replace with actual installation logic)
      await new Promise(resolve => setTimeout(resolve, 2000));

      // Mark as completed
      this.installing.delete(item.name);
      this.completed.add(item.name);
      item.state = 'completed';
      item.completedAt = Date.now();
      
      this.emit('installation_completed', item);
      await this.saveState();
    } catch (error) {
      // Handle failure
      this.installing.delete(item.name);
      this.failed.add(item.name);
      item.state = 'failed';
      item.error = error.message;
      
      this.emit('installation_failed', {
        item,
        error
      });

      // Retry if possible
      if (item.attempts < 3) {
        item.state = 'queued';
        this.queues.get(item.priority).push(item);
        await this.sortQueue(item.priority);
      }

      await this.saveState();
    }
  }

  /**
   * Check system resources
   */
  async checkResources() {
    // This should be replaced with actual resource checking logic
    return {
      cpu: 50,
      memory: 60,
      disk: 70
    };
  }

  /**
   * Load queue state from file
   */
  async loadState() {
    try {
      const data = await fs.readFile(this.config.queueFile, 'utf8');
      const state = JSON.parse(data);

      this.queues = new Map(state.queues || [
        ['critical', []],
        ['high', []],
        ['medium', []],
        ['low', []]
      ]);
      this.installing = new Set(state.installing || []);
      this.completed = new Set(state.completed || []);
      this.failed = new Set(state.failed || []);

      // Resort queues after loading
      for (const [priority, queue] of this.queues) {
        await this.sortQueue(priority);
      }
    } catch (error) {
      if (error.code !== 'ENOENT') {
        throw error;
      }
      // File doesn't exist, use default empty state
      await this.saveState();
    }
  }

  /**
   * Save queue state to file
   */
  async saveState() {
    const state = {
      queues: Array.from(this.queues.entries()).map(([priority, queue]) => [priority, queue.map(item => item.name)]),
      installing: Array.from(this.installing),
      completed: Array.from(this.completed),
      failed: Array.from(this.failed),
      systemState: {
        sessionId: process.pid.toString(),
        timestamp: Date.now(),
        recoveryPoint: {
          inProgressPackages: Array.from(this.installing)
        }
      }
    };

    await fs.writeFile(
      this.config.queueFile,
      JSON.stringify(state, null, 2),
      'utf8'
    );
  }

  /**
   * Get queue statistics
   */
  getStats() {
    return {
      queued: this.queues.get('critical').length + this.queues.get('high').length + this.queues.get('medium').length + this.queues.get('low').length,
      installing: this.installing.size,
      completed: this.completed.size,
      failed: this.failed.size,
      byPriority: this.queues.reduce((acc, [priority, queue]) => {
        acc[priority] = queue.length;
        return acc;
      }, {}),
      averageWaitTime: this.calculateAverageWaitTime()
    };
  }

  /**
   * Calculate average wait time for queued items
   */
  calculateAverageWaitTime() {
    const totalWaitTime = this.queues.reduce((sum, [priority, queue]) => {
      if (queue.length > 0) {
        const now = Date.now();
        const total = queue.reduce(
          (sum, item) => sum + (now - item.addedAt),
          0
        );
        return sum + (total / queue.length);
      }
      return sum;
    }, 0);
    
    return totalWaitTime / this.queues.size;
  }

  /**
   * Start monitoring system
   */
  startMonitoring() {
    setInterval(async () => {
      try {
        const resources = await this.checkResources();
        const now = Date.now();

        // Update resource usage metrics
        this.metrics.resourceUsage.set(now, resources);

        // Calculate and store metrics
        this.updateMetrics({
          timestamp: now,
          latency: this.calculateLatency(),
          throughput: this.calculateThroughput(),
          utilization: this.calculateUtilization(resources)
        });

        // Cleanup old metrics
        this.cleanupMetrics();

        // Emit monitoring update
        this.emit('monitoring_update', {
          metrics: this.getMetrics(),
          resources
        });
      } catch (error) {
        this.emit('error', {
          message: 'Failed to update monitoring metrics',
          error
        });
      }
    }, this.config.monitoring.interval);
  }

  /**
   * Start adaptive priority system
   */
  startAdaptivePriority() {
    setInterval(() => {
      try {
        this.updatePriorities();
      } catch (error) {
        this.emit('error', {
          message: 'Failed to update priorities',
          error
        });
      }
    }, this.config.adaptivePriority.updateInterval);
  }

  /**
   * Update queue item priorities based on multiple factors
   */
  updatePriorities() {
    const now = Date.now();
    const resources = this.getLatestResources();

    for (const [priority, queue] of this.queues) {
      for (const item of queue) {
        const waitTime = now - item.addedAt;
        const waitScore = Math.min(1, waitTime / this.config.priorityLevels[priority].maxWaitTime);
        
        const resourceScore = this.calculateResourceScore(priority, resources);
        const urgencyScore = this.calculateUrgencyScore(item);

        // Calculate new weight using configured factors
        const { factors } = this.config.adaptivePriority;
        item.weight = 
          factors.waitTime * waitScore +
          factors.resourceUsage * resourceScore +
          factors.urgency * urgencyScore;

        // Scale weight by base priority
        item.weight *= this.config.priorityLevels[priority].weight;
      }

      // Resort queue with new weights
      this.sortQueue(priority);
    }
  }

  /**
   * Calculate resource score based on availability
   */
  calculateResourceScore(priority, resources) {
    const quota = this.config.priorityLevels[priority].resourceQuota;
    const scores = [];

    // Calculate score for each resource type
    for (const [resource, usage] of Object.entries(resources)) {
      if (quota[resource]) {
        const available = Math.max(0, this.config.resourceThresholds[resource] - usage);
        const score = available / quota[resource];
        scores.push(Math.min(1, score));
      }
    }

    // Return average score
    return scores.length > 0 ? 
      scores.reduce((a, b) => a + b, 0) / scores.length : 0;
  }

  /**
   * Calculate urgency score based on item properties
   */
  calculateUrgencyScore(item) {
    // Consider factors like dependencies, user impact, etc.
    return item.urgency || 0.5; // Default medium urgency
  }

  /**
   * Update monitoring metrics
   */
  updateMetrics(data) {
    const { timestamp, latency, throughput, utilization } = data;

    this.metrics.latency.push({ timestamp, value: latency });
    this.metrics.throughput.push({ timestamp, value: throughput });
    this.metrics.utilization.push({ timestamp, value: utilization });
  }

  /**
   * Calculate average latency
   */
  calculateLatency() {
    if (this.completed.size === 0) return 0;
    
    const latencies = Array.from(this.completed).map(id => {
      const item = this.queues.get('critical').find(i => i.name === id) || this.queues.get('high').find(i => i.name === id) || this.queues.get('medium').find(i => i.name === id) || this.queues.get('low').find(i => i.name === id);
      return item ? item.completedAt - item.addedAt : 0;
    });

    return latencies.reduce((a, b) => a + b, 0) / latencies.length;
  }

  /**
   * Calculate current throughput
   */
  calculateThroughput() {
    const window = 60000; // 1 minute
    const now = Date.now();
    const recentCompleted = Array.from(this.completed).filter(id => {
      const item = this.queues.get('critical').find(i => i.name === id) || this.queues.get('high').find(i => i.name === id) || this.queues.get('medium').find(i => i.name === id) || this.queues.get('low').find(i => i.name === id);
      return item && now - item.completedAt < window;
    });

    return recentCompleted.length;
  }

  /**
   * Calculate resource utilization
   */
  calculateUtilization(resources) {
    const utilizationScores = [];

    for (const [resource, usage] of Object.entries(resources)) {
      const threshold = this.config.resourceThresholds[resource];
      if (threshold) {
        utilizationScores.push(usage / threshold);
      }
    }

    return utilizationScores.length > 0 ?
      utilizationScores.reduce((a, b) => a + b, 0) / utilizationScores.length : 0;
  }

  /**
   * Get latest resource measurements
   */
  getLatestResources() {
    const entries = Array.from(this.metrics.resourceUsage.entries());
    if (entries.length === 0) return {};
    
    // Get most recent entry
    entries.sort((a, b) => b[0] - a[0]);
    return entries[0][1];
  }

  /**
   * Clean up old metrics
   */
  cleanupMetrics() {
    const cutoff = Date.now() - (this.config.monitoring.history * 1000);

    // Clean up each metric type
    for (const metricType of Object.keys(this.metrics)) {
      if (Array.isArray(this.metrics[metricType])) {
        this.metrics[metricType] = this.metrics[metricType].filter(
          m => m.timestamp >= cutoff
        );
      }
    }

    // Clean up resource usage history
    for (const [timestamp] of this.metrics.resourceUsage) {
      if (timestamp < cutoff) {
        this.metrics.resourceUsage.delete(timestamp);
      }
    }
  }

  /**
   * Get current metrics
   */
  getMetrics() {
    const metrics = {};

    // Calculate aggregated metrics
    for (const [type, data] of Object.entries(this.metrics)) {
      if (Array.isArray(data)) {
        metrics[type] = {
          current: data[data.length - 1]?.value || 0,
          average: data.reduce((sum, m) => sum + m.value, 0) / data.length || 0,
          min: Math.min(...data.map(m => m.value)),
          max: Math.max(...data.map(m => m.value))
        };
      }
    }

    return metrics;
  }
} 