const path = require('path');

module.exports = {
  // Resource monitoring configuration
  resourceMonitor: {
    updateInterval: 1000,
    metricsDir: path.join(__dirname, '../metrics'),
    historyLength: 3600,
    thresholds: {
      cpu: {
        warning: 60,
        critical: 80,
        emergency: 90
      },
      memory: {
        warning: 65,
        critical: 80,
        emergency: 90
      },
      disk: {
        warning: 70,
        critical: 85,
        emergency: 95
      },
      oom: {
        warning: 60,
        critical: 75,
        emergency: 85
      }
    },
    earlyWarning: {
      enabled: true,
      checkInterval: 500,
      trendWindow: 5,
      growthRate: {
        warning: 5,
        critical: 10
      },
      predictionWindow: 300 // 5 minutes
    },
    cleanup: {
      interval: 5000,
      maxHistoryLength: 3600,
      maxProcessCache: 1000,
      fileRetention: 86400000 // 24 hours
    }
  },

  // Test optimizer configuration
  testOptimizer: {
    modelPath: path.join(__dirname, '../models/test-optimizer'),
    metricsDir: path.join(__dirname, '../metrics'),
    historyLength: 1000,
    predictionWindow: 10,
    trainingEpochs: 100,
    batchSize: 32,
    validationSplit: 0.2,
    metrics: ['accuracy', 'precision', 'recall']
  },

  // Alert manager configuration
  alertManager: {
    alertsDir: path.join(__dirname, '../logs/alerts'),
    historyLength: 1000,
    escalationLevels: [
      {
        level: 1,
        name: 'warning',
        threshold: 70,
        timeout: 300000, // 5 minutes
        channels: ['dashboard'],
        autoResolve: true,
        autoResolveThreshold: 65
      },
      {
        level: 2,
        name: 'critical',
        threshold: 80,
        timeout: 120000, // 2 minutes
        channels: ['dashboard', 'email'],
        autoResolve: true,
        autoResolveThreshold: 75
      },
      {
        level: 3,
        name: 'emergency',
        threshold: 90,
        timeout: 60000, // 1 minute
        channels: ['dashboard', 'email', 'slack'],
        autoResolve: false
      }
    ],
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
        recipients: ['admin@example.com'],
        throttle: {
          period: 300000, // 5 minutes
          maxAlerts: 5
        }
      },
      slack: {
        enabled: false,
        webhook: 'https://hooks.slack.com/services/your/webhook/url',
        channel: '#alerts',
        throttle: {
          period: 300000, // 5 minutes
          maxAlerts: 5
        }
      }
    },
    aggregation: {
      enabled: true,
      window: 300000, // 5 minutes
      similarityThreshold: 0.8,
      maxAlertsPerWindow: 10
    }
  },

  // Staged installer configuration
  stagedInstaller: {
    maxConcurrentInstalls: 1,
    cpuThreshold: 80,
    memoryThreshold: 80,
    retryAttempts: 3,
    cooldownPeriod: 5000,
    stages: [
      {
        name: 'core',
        priority: 'critical',
        dependencies: [
          { name: 'express', version: '^4.18.2' },
          { name: 'ws', version: '^8.13.0' }
        ]
      },
      {
        name: 'monitoring',
        priority: 'high',
        dependencies: [
          { name: '@tensorflow/tfjs-node', version: '^4.17.0' },
          { name: 'nodemailer', version: '^6.9.9' }
        ]
      },
      {
        name: 'utilities',
        priority: 'normal',
        dependencies: [
          { name: 'moment', version: '^2.30.1' },
          { name: 'chart.js', version: '^4.4.1' }
        ]
      }
    ]
  },

  // Test environment paths
  paths: {
    root: path.join(__dirname, '..'),
    logs: path.join(__dirname, '../logs'),
    metrics: path.join(__dirname, '../metrics'),
    models: path.join(__dirname, '../models'),
    public: path.join(__dirname, '../public')
  },

  // Test execution configuration
  testExecution: {
    maxConcurrency: 2,
    timeout: 30000,
    retries: 2,
    bail: true,
    isolatedProcesses: true
  },

  // Emergency procedures
  emergencyProcedures: {
    shutdownThreshold: 85,
    shutdownTimeout: 3000,
    processTerminationOrder: ['tests', 'optimizer', 'dashboard', 'monitor'],
    requireConfirmation: false,
    oomPrevention: {
      enabled: true,
      gcInterval: 30000,
      memoryLimit: '75%',
      swapThreshold: '90%'
    }
  },

  // Test environment settings
  testEnvironment: {
    cleanupOnExit: true,
    isolatedDirectories: true,
    randomPorts: true,
    portRange: {
      min: 50000,
      max: 60000
    },
    timeouts: {
      test: 5000,
      setup: 10000,
      teardown: 5000
    },
    retries: {
      enabled: true,
      maxAttempts: 3,
      backoff: {
        initial: 1000,
        factor: 2,
        maxDelay: 5000
      }
    }
  }
}; 