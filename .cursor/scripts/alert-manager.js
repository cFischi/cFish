const fs = require('fs').promises;
const path = require('path');
const nodemailer = require('nodemailer');
const EventEmitter = require('events');
const AlertCorrelation = require('./alert-correlation');

class AlertManager extends EventEmitter {
  constructor(config = {}) {
    super();
    this.config = {
      alertsDir: config.alertsDir || path.join(__dirname, '../logs/alerts'),
      historyLength: config.historyLength || 1000,
      escalationLevels: [
        {
          level: 1,
          name: 'warning',
          threshold: 70,
          timeout: 300000
        },
        {
          level: 2,
          name: 'critical',
          threshold: 80,
          timeout: 120000
        },
        {
          level: 3,
          name: 'emergency',
          threshold: 90,
          timeout: 60000
        }
      ],
      tokenThresholds: {
        warning: 45000,
        critical: 55000
      },
      contextThresholds: {
        warning: 90,
        target: 92
      },
      notifications: {
        email: {
          enabled: false,
          host: 'smtp.example.com',
          port: 587,
          secure: true,
          auth: {
            user: 'alerts@example.com',
            pass: 'your-password'
          },
          recipients: ['admin@example.com']
        },
        slack: {
          enabled: false,
          webhook: 'https://hooks.slack.com/services/your/webhook/url',
          channel: '#alerts'
        }
      },
      ...config
    };

    this.alerts = new Map();
    this.history = [];
    this.emailTransporter = null;
    this.correlation = new AlertCorrelation(config.correlation);

    // Listen for correlation events
    this.correlation.on('correlation_detected', this.handleCorrelation.bind(this));
    this.correlation.on('recommendations_available', this.handleRecommendations.bind(this));
    this.correlation.on('error', this.handleCorrelationError.bind(this));
  }

  async initialize() {
    console.log('Initializing alert manager...');

    // Create alerts directory if it doesn't exist
    await fs.mkdir(this.config.alertsDir, { recursive: true });

    // Initialize email transporter if enabled
    if (this.config.notifications.email.enabled) {
      this.emailTransporter = nodemailer.createTransport({
        host: this.config.notifications.email.host,
        port: this.config.notifications.email.port,
        secure: this.config.notifications.email.secure,
        auth: this.config.notifications.email.auth
      });
    }

    // Load alert history
    await this.loadHistory();

    console.log('Alert manager initialized');
  }

  async loadHistory() {
    try {
      const files = await fs.readdir(this.config.alertsDir);
      const alertFiles = files
        .filter(f => f.endsWith('.json'))
        .sort()
        .slice(-this.config.historyLength);

      for (const file of alertFiles) {
        const alert = JSON.parse(
          await fs.readFile(path.join(this.config.alertsDir, file), 'utf8')
        );
        this.history.push(alert);
      }

      console.log(`Loaded ${this.history.length} historical alerts`);
    } catch (error) {
      console.error('Error loading alert history:', error);
    }
  }

  async processMetrics(metrics) {
    const timestamp = new Date();
    const alerts = [];

    // Check token usage
    if (metrics.tokenStats) {
      const tokenUsage = metrics.tokenStats.usage;
      if (tokenUsage >= this.config.tokenThresholds.critical) {
        alerts.push({
          type: 'critical',
          resource: 'token_usage',
          message: `Token usage (${tokenUsage}) exceeded critical threshold (${this.config.tokenThresholds.critical})`,
          value: tokenUsage,
          threshold: this.config.tokenThresholds.critical
        });
      } else if (tokenUsage >= this.config.tokenThresholds.warning) {
        alerts.push({
          type: 'warning',
          resource: 'token_usage',
          message: `Token usage (${tokenUsage}) exceeded warning threshold (${this.config.tokenThresholds.warning})`,
          value: tokenUsage,
          threshold: this.config.tokenThresholds.warning
        });
      }
    }

    // Check context efficiency
    if (metrics.contextStats) {
      const efficiency = metrics.contextStats.efficiency;
      if (efficiency < this.config.contextThresholds.warning) {
        alerts.push({
          type: 'warning',
          resource: 'context_efficiency',
          message: `Context efficiency (${efficiency}%) below warning threshold (${this.config.contextThresholds.warning}%)`,
          value: efficiency,
          threshold: this.config.contextThresholds.warning
        });
      }
    }

    // Check CPU usage
    const cpuAlert = this.checkThreshold('cpu', metrics.resourceStats.resourceMetrics.cpu);
    if (cpuAlert) alerts.push(cpuAlert);

    // Check memory usage
    const memoryAlert = this.checkThreshold('memory', metrics.resourceStats.resourceMetrics.memory);
    if (memoryAlert) alerts.push(memoryAlert);

    // Check disk usage
    const diskAlert = this.checkThreshold('disk', metrics.resourceStats.resourceMetrics.disk);
    if (diskAlert) alerts.push(diskAlert);

    // Process test-related alerts
    if (metrics.testStats) {
      const failureRate = metrics.testStats.failed / 
        (metrics.testStats.completed + metrics.testStats.failed);
      
      if (failureRate > 0.2) {
        alerts.push({
          type: 'warning',
          resource: 'tests',
          message: `High test failure rate: ${(failureRate * 100).toFixed(1)}%`,
          value: failureRate * 100,
          threshold: 20
        });
      }

      if (metrics.testStats.queued > metrics.testStats.active * 3) {
        alerts.push({
          type: 'warning',
          resource: 'queue',
          message: `Large test queue: ${metrics.testStats.queued} tests queued`,
          value: metrics.testStats.queued,
          threshold: metrics.testStats.active * 3
        });
      }
    }

    // Process and escalate alerts
    for (const alert of alerts) {
      await this.processAlert(alert, timestamp);
    }

    // Clear resolved alerts
    this.clearResolvedAlerts(metrics);

    return alerts;
  }

  checkThreshold(resource, value) {
    for (const level of [...this.config.escalationLevels].reverse()) {
      if (value >= level.threshold) {
        return {
          type: level.name,
          resource,
          message: `${resource.toUpperCase()} usage ${value.toFixed(1)}% exceeds ${level.threshold}% threshold`,
          value,
          threshold: level.threshold
        };
      }
    }
    return null;
  }

  async processAlert(alert, timestamp) {
    const alertId = `${alert.resource}-${alert.type}`;
    const existingAlert = this.alerts.get(alertId);

    if (existingAlert) {
      // Update existing alert
      existingAlert.count++;
      existingAlert.lastUpdate = timestamp;
      existingAlert.value = alert.value;

      // Check for escalation
      if (this.shouldEscalate(existingAlert)) {
        await this.escalateAlert(existingAlert);
      }
    } else {
      // Create new alert
      const newAlert = {
        id: alertId,
        ...alert,
        firstSeen: timestamp,
        lastUpdate: timestamp,
        count: 1,
        escalationLevel: this.getEscalationLevel(alert),
        notifications: new Set()
      };

      this.alerts.set(alertId, newAlert);
      await this.notifyAlert(newAlert);
    }

    // Process alert for correlation
    try {
      await this.correlation.processAlert({
        id: alertId,
        ...alert,
        timestamp
      });
    } catch (error) {
      this.emit('error', {
        message: 'Failed to process alert correlation',
        error,
        alert
      });
    }

    // Save alert to history
    await this.saveAlert(alert, timestamp);
  }

  getEscalationLevel(alert) {
    return this.config.escalationLevels.findIndex(level => level.name === alert.type) + 1;
  }

  shouldEscalate(alert) {
    const level = this.config.escalationLevels[alert.escalationLevel - 1];
    if (!level) return false;

    const timeSinceNotification = Date.now() - alert.lastNotification;
    return timeSinceNotification >= level.timeout;
  }

  async escalateAlert(alert) {
    const nextLevel = Math.min(
      alert.escalationLevel + 1,
      this.config.escalationLevels.length
    );

    if (nextLevel !== alert.escalationLevel) {
      alert.escalationLevel = nextLevel;
      alert.lastNotification = Date.now();
      await this.notifyAlert(alert);
    }
  }

  async notifyAlert(alert) {
    const level = this.config.escalationLevels[alert.escalationLevel - 1];
    if (!level) return;

    for (const channel of level.channels) {
      if (!alert.notifications.has(channel)) {
        await this.sendNotification(channel, alert);
        alert.notifications.add(channel);
      }
    }

    alert.lastNotification = Date.now();
  }

  async sendNotification(channel, alert) {
    try {
      switch (channel) {
        case 'email':
          if (this.config.notifications.email.enabled) {
            await this.sendEmailNotification(alert);
          }
          break;

        case 'slack':
          if (this.config.notifications.slack.enabled) {
            await this.sendSlackNotification(alert);
          }
          break;

        case 'dashboard':
          // Dashboard notifications are handled by the dashboard itself
          break;
      }
    } catch (error) {
      console.error(`Error sending ${channel} notification:`, error);
    }
  }

  async sendEmailNotification(alert) {
    if (!this.emailTransporter) return;

    const subject = `[${alert.type.toUpperCase()}] ${alert.resource} Alert`;
    const text = `
      Resource: ${alert.resource}
      Type: ${alert.type}
      Message: ${alert.message}
      Value: ${alert.value}
      Threshold: ${alert.threshold}
      First Seen: ${alert.firstSeen}
      Count: ${alert.count}
      Escalation Level: ${alert.escalationLevel}
    `;

    await this.emailTransporter.sendMail({
      from: this.config.notifications.email.auth.user,
      to: this.config.notifications.email.recipients.join(','),
      subject,
      text
    });
  }

  async sendSlackNotification(alert) {
    if (!this.config.notifications.slack.webhook) return;

    const color = alert.type === 'critical' ? '#ff0000' : 
      alert.type === 'warning' ? '#ffcc00' : '#36a64f';

    const message = {
      channel: this.config.notifications.slack.channel,
      attachments: [{
        color,
        title: `${alert.resource} Alert`,
        text: alert.message,
        fields: [
          {
            title: 'Type',
            value: alert.type,
            short: true
          },
          {
            title: 'Value',
            value: `${alert.value.toFixed(1)}%`,
            short: true
          },
          {
            title: 'Threshold',
            value: `${alert.threshold}%`,
            short: true
          },
          {
            title: 'Count',
            value: alert.count.toString(),
            short: true
          }
        ],
        footer: `Escalation Level: ${alert.escalationLevel}`
      }]
    };

    await fetch(this.config.notifications.slack.webhook, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(message)
    });
  }

  async saveAlert(alert, timestamp) {
    const fileName = `alert-${timestamp.toISOString()}.json`;
    const filePath = path.join(this.config.alertsDir, fileName);

    await fs.writeFile(filePath, JSON.stringify({
      ...alert,
      timestamp
    }, null, 2));

    this.history.push(alert);
    if (this.history.length > this.config.historyLength) {
      this.history.shift();
    }
  }

  clearResolvedAlerts(metrics) {
    for (const [alertId, alert] of this.alerts.entries()) {
      const value = metrics.resourceStats.resourceMetrics[alert.resource];
      const threshold = this.config.escalationLevels[0].threshold;

      if (value < threshold) {
        this.alerts.delete(alertId);
      }
    }
  }

  getActiveAlerts() {
    return Array.from(this.alerts.values());
  }

  getAlertHistory() {
    return this.history;
  }

  getAlertStats() {
    const stats = {
      active: this.alerts.size,
      history: this.history.length,
      byType: {},
      byResource: {}
    };

    for (const alert of this.history) {
      // Count by type
      stats.byType[alert.type] = (stats.byType[alert.type] || 0) + 1;
      
      // Count by resource
      stats.byResource[alert.resource] = (stats.byResource[alert.resource] || 0) + 1;
    }

    return stats;
  }

  async handleCorrelation(correlation) {
    this.emit('correlation', correlation);

    // Log correlation details
    console.log('Alert correlation detected:', {
      primaryAlert: correlation.primaryAlert.resource,
      relatedCount: correlation.relatedAlerts.length,
      pattern: {
        resources: Array.from(correlation.pattern.resources),
        severity: correlation.pattern.severity
      }
    });

    // Update related alerts with correlation info
    for (const alert of [correlation.primaryAlert, ...correlation.relatedAlerts]) {
      const existingAlert = this.alerts.get(alert.id);
      if (existingAlert) {
        existingAlert.correlations = existingAlert.correlations || new Set();
        existingAlert.correlations.add(correlation.pattern.id);
      }
    }
  }

  async handleRecommendations({ correlation, recommendations }) {
    this.emit('recommendations', { correlation, recommendations });

    // Log recommendations
    console.log('Alert recommendations available:', {
      patternId: correlation.pattern.id,
      recommendations: recommendations.map(r => ({
        type: r.type,
        action: r.action,
        priority: r.priority
      }))
    });

    // Store recommendations with the correlation
    const primaryAlert = this.alerts.get(correlation.primaryAlert.id);
    if (primaryAlert) {
      primaryAlert.recommendations = recommendations;
    }
  }

  handleCorrelationError(error) {
    this.emit('error', {
      message: 'Alert correlation error',
      error: error.error,
      alert: error.alert
    });
  }

  getStats() {
    const baseStats = {
      active: this.alerts.size,
      history: this.history.length,
      byType: {},
      byResource: {}
    };

    for (const alert of this.history) {
      // Count by type
      baseStats.byType[alert.type] = (baseStats.byType[alert.type] || 0) + 1;
      
      // Count by resource
      baseStats.byResource[alert.resource] = (baseStats.byResource[alert.resource] || 0) + 1;
    }

    // Add correlation stats
    return {
      ...baseStats,
      correlation: this.correlation.getStats()
    };
  }
}

module.exports = AlertManager; 