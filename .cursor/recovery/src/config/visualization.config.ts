import { ProcessPriority } from '../utils/types';

export interface VisualizationConfig {
  rendering: {
    mode: 'virtual' | 'standard';
    updateInterval: number;
    batchSize: number;
    maxDepth: number;
    compression: boolean;
    compressionThreshold: number;
  };
  optimization: {
    recycling: boolean;
    memoryLimit: number;
    cacheSize: number;
    cleanupInterval: number;
  };
  monitoring: {
    metrics: string[];
    alerts: boolean;
    history: number;
    aggregation: string;
    thresholds: {
      cpu: { warning: number; critical: number };
      memory: { warning: number; critical: number };
      io: { warning: number; critical: number };
      network: { warning: number; critical: number };
    };
  };
  errorRecovery: {
    maxRetries: number;
    retryDelay: number;
    recoveryStrategies: string[];
  };
  appearance: {
    theme: {
      light: {
        background: string;
        nodeStroke: string;
        nodeText: string;
        linkColor: string;
        controlsBackground: string;
      };
      dark: {
        background: string;
        nodeStroke: string;
        nodeText: string;
        linkColor: string;
        controlsBackground: string;
      };
    };
    nodeColors: {
      [key in ProcessPriority]: string;
    };
    statusColors: {
      active: string;
      completed: string;
      pending: string;
      error: string;
      warning: string;
    };
  };
}

export const defaultConfig: VisualizationConfig = {
  rendering: {
    mode: 'virtual',
    updateInterval: 16, // 60fps
    batchSize: 100,
    maxDepth: 10,
    compression: true,
    compressionThreshold: 1000,
  },
  optimization: {
    recycling: true,
    memoryLimit: 100 * 1024 * 1024, // 100MB
    cacheSize: 1000,
    cleanupInterval: 30000, // 30s
  },
  monitoring: {
    metrics: ['cpu', 'memory', 'io', 'network'],
    alerts: true,
    history: 3600, // 1 hour
    aggregation: '1s',
    thresholds: {
      cpu: { warning: 70, critical: 90 },
      memory: { warning: 70, critical: 85 },
      io: { warning: 1000, critical: 5000 },
      network: { warning: 80, critical: 95 },
    },
  },
  errorRecovery: {
    maxRetries: 3,
    retryDelay: 1000,
    recoveryStrategies: ['reconnect', 'reload', 'reset'],
  },
  appearance: {
    theme: {
      light: {
        background: '#f5f5f5',
        nodeStroke: '#333333',
        nodeText: '#333333',
        linkColor: '#BDBDBD',
        controlsBackground: 'rgba(255, 255, 255, 0.9)',
      },
      dark: {
        background: '#1e1e1e',
        nodeStroke: '#e0e0e0',
        nodeText: '#e0e0e0',
        linkColor: '#666666',
        controlsBackground: 'rgba(30, 30, 30, 0.9)',
      },
    },
    nodeColors: {
      critical: '#F44336',
      high: '#FF9800',
      medium: '#2196F3',
      low: '#4CAF50',
      background: '#9E9E9E',
    },
    statusColors: {
      active: '#4CAF50',
      completed: '#2196F3',
      pending: '#FFC107',
      error: '#F44336',
      warning: '#FF9800',
    },
  },
}; 