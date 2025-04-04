const fs = require('fs').promises;
const path = require('path');

class MetricsCollector {
  constructor(options = {}) {
    this.options = {
      metricsDir: path.join(__dirname, '../metrics'),
      retentionDays: 7,
      ...options
    };
    this.metrics = new Map();
    this.isCollecting = false;
  }

  async startCollection() {
    console.log('Starting metrics collection...');
    
    // Ensure metrics directory exists
    await fs.mkdir(this.options.metricsDir, { recursive: true });
    
    // Clean up old metrics files
    await this.cleanupOldMetrics();
    
    this.isCollecting = true;
    console.log('Metrics collection started');
  }

  async stopCollection() {
    console.log('Stopping metrics collection...');
    this.isCollecting = false;
    
    // Save final metrics
    await this.saveMetrics();
    
    console.log('Metrics collection stopped');
  }

  async recordMetrics(type, metrics) {
    if (!this.isCollecting) return;

    if (!this.metrics.has(type)) {
      this.metrics.set(type, []);
    }

    this.metrics.get(type).push({
      ...metrics,
      timestamp: metrics.timestamp || new Date().toISOString()
    });

    // Save metrics periodically
    if (this.metrics.get(type).length >= 100) {
      await this.saveMetrics(type);
    }
  }

  async saveMetrics(type = null) {
    const timestamp = new Date().toISOString().split('T')[0];
    const types = type ? [type] : Array.from(this.metrics.keys());

    for (const metricType of types) {
      const metrics = this.metrics.get(metricType);
      if (!metrics || metrics.length === 0) continue;

      const filename = path.join(
        this.options.metricsDir,
        `${metricType}-${timestamp}.json`
      );

      await fs.writeFile(
        filename,
        JSON.stringify(metrics, null, 2),
        'utf8'
      );

      // Clear saved metrics
      this.metrics.set(metricType, []);
    }
  }

  async cleanupOldMetrics() {
    const files = await fs.readdir(this.options.metricsDir);
    const now = new Date();

    for (const file of files) {
      const filePath = path.join(this.options.metricsDir, file);
      const stats = await fs.stat(filePath);
      const daysOld = (now - stats.mtime) / (1000 * 60 * 60 * 24);

      if (daysOld > this.options.retentionDays) {
        await fs.unlink(filePath);
      }
    }
  }

  async getCurrentMetrics() {
    const allMetrics = {};
    for (const [type, metrics] of this.metrics.entries()) {
      if (metrics.length > 0) {
        allMetrics[type] = metrics[metrics.length - 1];
      }
    }
    return allMetrics;
  }

  async getMetricsHistory() {
    const history = {};
    for (const [type, metrics] of this.metrics.entries()) {
      history[type] = {
        count: metrics.length,
        latest: metrics[metrics.length - 1],
        average: this.calculateAverage(metrics)
      };
    }
    return history;
  }

  calculateAverage(metrics) {
    if (!metrics || metrics.length === 0) return null;

    const numericMetrics = {};
    metrics.forEach(metric => {
      Object.entries(metric).forEach(([key, value]) => {
        if (typeof value === 'number') {
          if (!numericMetrics[key]) numericMetrics[key] = [];
          numericMetrics[key].push(value);
        }
      });
    });

    const averages = {};
    Object.entries(numericMetrics).forEach(([key, values]) => {
      averages[key] = values.reduce((a, b) => a + b, 0) / values.length;
    });

    return averages;
  }

  async generateSummaryReport() {
    const history = await this.getMetricsHistory();
    const current = await this.getCurrentMetrics();

    return {
      timestamp: new Date().toISOString(),
      history,
      current,
      collectionStatus: this.isCollecting ? 'active' : 'stopped'
    };
  }
}

module.exports = { MetricsCollector }; 