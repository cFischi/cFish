class MonitoringSystem extends EventEmitter {
  constructor() {
    super();
    this.config = require('./monitoring-config.json');
    this.metrics = {
      tokens: new Map(),
      performance: new Map(),
      health: new Map(),
      operational: new Map()
    };
    this.alerts = new Map();
    this.docGenerator = new DocumentationGenerator();
    this.lastDocUpdate = null;
    this.baselineData = new Map();
    this.operationalPhaseStartDate = new Date();
    
    // Initialize cache manager
    this.cacheManager = {
      data: new Map(),
      ttl: new Map(),
      defaultTTL: 300000, // 5 minutes
      
      set(key, value, ttl = this.defaultTTL) {
        this.data.set(key, value);
        this.ttl.set(key, Date.now() + ttl);
      },
      
      get(key) {
        if (!this.data.has(key)) return null;
        if (Date.now() > this.ttl.get(key)) {
          this.data.delete(key);
          this.ttl.delete(key);
          return null;
        }
        return this.data.get(key);
      },
      
      invalidate(key) {
        this.data.delete(key);
        this.ttl.delete(key);
      },
      
      cleanup() {
        const now = Date.now();
        for (const [key, expiry] of this.ttl.entries()) {
          if (now > expiry) {
            this.data.delete(key);
            this.ttl.delete(key);
          }
        }
      }
    };
    
    // Initialize data aggregator
    this.dataAggregator = {
      buffers: new Map(),
      aggregationWindows: new Map(),
      
      addMetric(metric, timestamp) {
        const window = this.getAggregationWindow(metric.type);
        const buffer = this.getBuffer(metric.type);
        
        buffer.push({ value: metric.value, timestamp });
        
        if (buffer.length >= window.sampleSize) {
          const aggregated = this.aggregate(buffer, window.method);
          this.emit('aggregated', {
            type: metric.type,
            value: aggregated,
            timestamp,
            window: window.duration
          });
          buffer.length = 0;
        }
      },
      
      getAggregationWindow(type) {
        if (!this.aggregationWindows.has(type)) {
          this.aggregationWindows.set(type, {
            duration: 60000, // 1 minute
            sampleSize: 60,  // 1 sample per second
            method: 'average'
          });
        }
        return this.aggregationWindows.get(type);
      },
      
      getBuffer(type) {
        if (!this.buffers.has(type)) {
          this.buffers.set(type, []);
        }
        return this.buffers.get(type);
      },
      
      aggregate(buffer, method) {
        switch (method) {
          case 'average':
            return buffer.reduce((sum, item) => sum + item.value, 0) / buffer.length;
          case 'max':
            return Math.max(...buffer.map(item => item.value));
          case 'min':
            return Math.min(...buffer.map(item => item.value));
          case 'sum':
            return buffer.reduce((sum, item) => sum + item.value, 0);
          default:
            return buffer[buffer.length - 1].value;
        }
      }
    };
    
    // Initialize metrics optimizer
    this.metricsOptimizer = {
      compressionThreshold: 1000, // number of data points before compression
      retentionPeriods: new Map([
        ['1m', 60 * 24 * 7],    // 1 week of 1-minute data
        ['5m', 60 * 24 * 30],   // 1 month of 5-minute data
        ['1h', 24 * 365],       // 1 year of hourly data
      ]),
      
      optimize(metrics, type) {
        if (metrics.length > this.compressionThreshold) {
          return this.compress(metrics, type);
        }
        return metrics;
      },
      
      compress(metrics, type) {
        const period = this.getRetentionPeriod(type);
        const windowSize = Math.ceil(metrics.length / period);
        const compressed = [];
        
        for (let i = 0; i < metrics.length; i += windowSize) {
          const window = metrics.slice(i, i + windowSize);
          compressed.push({
            timestamp: window[0].timestamp,
            value: this.aggregate(window),
            count: window.length
          });
        }
        
        return compressed;
      },
      
      getRetentionPeriod(type) {
        return this.retentionPeriods.get(type) || this.retentionPeriods.get('1h');
      },
      
      aggregate(window) {
        const sum = window.reduce((acc, metric) => acc + metric.value, 0);
        return sum / window.length;
      }
    };
    
    // Schedule periodic maintenance
    setInterval(() => {
      this.cacheManager.cleanup();
      this.optimizeMetrics();
    }, 300000); // 5 minutes
  }
  
  async processOperationalMetrics(metrics) {
    const cacheKey = `metrics_${metrics.timestamp}`;
    const cached = this.cacheManager.get(cacheKey);
    
    if (cached) {
      return cached;
    }
    
    // Store metrics
    this.metrics.operational.set(metrics.timestamp, metrics);
    
    // Process through data aggregator
    this.dataAggregator.addMetric(metrics, metrics.timestamp);
    
    // Update baseline if in establishment period
    const establishmentPeriod = this.parseTimeToMs(this.config.operationalPhase.dataCollection.performanceBaselines.establishment.period);
    const isInEstablishmentPeriod = (Date.now() - this.operationalPhaseStartDate) <= establishmentPeriod;
    
    if (isInEstablishmentPeriod) {
      await this.updateBaseline(metrics);
    }
    
    // Generate reports if due
    if (this.isWeeklyReportDue()) {
      await this.generateOperationalReport('weekly');
    }
    if (this.isMonthlyReportDue()) {
      await this.generateOperationalReport('monthly');
    }
    if (this.isQuarterlyReportDue()) {
      await this.generateOperationalReport('quarterly');
    }
    
    // Cache processed results
    this.cacheManager.set(cacheKey, metrics);
    
    return metrics;
  }
  
  async optimizeMetrics() {
    for (const [type, metrics] of Object.entries(this.metrics)) {
      if (metrics instanceof Map) {
        const optimized = this.metricsOptimizer.optimize(Array.from(metrics.values()), type);
        metrics.clear();
        optimized.forEach(metric => metrics.set(metric.timestamp, metric));
      }
    }
  }
  
  // ... existing code ...
}
// ... existing code ... 