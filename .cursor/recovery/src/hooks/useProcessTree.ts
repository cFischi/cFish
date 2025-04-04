import { useState, useEffect, useCallback, useRef } from 'react';
import { ProcessNode, ProcessMetrics, ProcessAnomalyInfo } from '../utils/types';
import { VisualizationConfig, defaultConfig } from '../config/visualization.config';
import { LRUCache } from 'lru-cache';

interface UseProcessTreeOptions {
  config?: Partial<VisualizationConfig>;
  onAnomalyDetected?: (anomaly: ProcessAnomalyInfo) => void;
  onMetricsUpdate?: (metrics: ProcessMetrics) => void;
}

interface ProcessTreeState {
  metrics: ProcessMetrics;
  anomalies: ProcessAnomalyInfo[];
  lastUpdate: number;
  renderCount: number;
}

export function useProcessTree(data: ProcessNode, options: UseProcessTreeOptions = {}) {
  const config = { ...defaultConfig, ...options.config };
  const [state, setState] = useState<ProcessTreeState>({
    metrics: {
      totalProcesses: 0,
      highMemoryProcesses: 0,
      systemProcesses: 0,
      totalMemoryUsage: 0,
      cursorProcesses: 0,
      nodeProcesses: 0,
    },
    anomalies: [],
    lastUpdate: Date.now(),
    renderCount: 0,
  });

  // Initialize caches
  const processCache = useRef(new LRUCache<number, ProcessNode>({
    max: config.optimization.cacheSize,
    ttl: config.optimization.cleanupInterval,
  }));

  const metricsHistory = useRef<{
    timestamps: number[];
    values: { [metric: string]: number[] };
  }>({
    timestamps: [],
    values: {},
  });

  // Calculate metrics from process tree
  const calculateMetrics = useCallback((node: ProcessNode): ProcessMetrics => {
    const result: ProcessMetrics = {
      totalProcesses: 1,
      highMemoryProcesses: 0,
      systemProcesses: 0,
      totalMemoryUsage: node.memoryUsageMB || 0,
      cursorProcesses: 0,
      nodeProcesses: 0,
    };

    if (node.memoryUsageMB && node.memoryUsageMB > config.monitoring.thresholds.memory.warning) {
      result.highMemoryProcesses++;
    }

    if (node.type === 'system') {
      result.systemProcesses++;
    } else if (node.type === 'cursor') {
      result.cursorProcesses++;
    } else if (node.type === 'node') {
      result.nodeProcesses++;
    }

    if (node.children) {
      node.children.forEach(child => {
        const childMetrics = calculateMetrics(child);
        result.totalProcesses += childMetrics.totalProcesses;
        result.highMemoryProcesses += childMetrics.highMemoryProcesses;
        result.systemProcesses += childMetrics.systemProcesses;
        result.totalMemoryUsage += childMetrics.totalMemoryUsage;
        result.cursorProcesses = (result.cursorProcesses || 0) + (childMetrics.cursorProcesses || 0);
        result.nodeProcesses = (result.nodeProcesses || 0) + (childMetrics.nodeProcesses || 0);
      });
    }

    return result;
  }, [config.monitoring.thresholds.memory.warning]);

  // Detect anomalies in process tree
  const detectAnomalies = useCallback((node: ProcessNode): ProcessAnomalyInfo[] => {
    const anomalies: ProcessAnomalyInfo[] = [];
    const { thresholds } = config.monitoring;

    const checkNode = (n: ProcessNode) => {
      const reasons: string[] = [];

      if (n.cpuUsagePercent && n.cpuUsagePercent > thresholds.cpu.critical) {
        reasons.push(`High CPU usage: ${n.cpuUsagePercent}%`);
      }
      if (n.memoryUsageMB && n.memoryUsageMB > thresholds.memory.critical) {
        reasons.push(`High memory usage: ${n.memoryUsageMB}MB`);
      }

      if (reasons.length > 0) {
        anomalies.push({
          processId: n.id || 0,
          name: n.name,
          reasons,
          timestamp: new Date().toISOString(),
          severity: reasons.length > 1 ? 'HIGH' : 'MEDIUM',
        });
      }

      if (n.children) {
        n.children.forEach(checkNode);
      }
    };

    checkNode(node);
    return anomalies;
  }, [config.monitoring.thresholds]);

  // Update metrics history
  const updateMetricsHistory = useCallback((metrics: ProcessMetrics) => {
    const now = Date.now();
    metricsHistory.current.timestamps.push(now);

    Object.entries(metrics).forEach(([key, value]) => {
      if (!metricsHistory.current.values[key]) {
        metricsHistory.current.values[key] = [];
      }
      metricsHistory.current.values[key].push(value);
    });

    // Cleanup old metrics
    const maxAge = config.monitoring.history * 1000;
    const cutoffIndex = metricsHistory.current.timestamps.findIndex(
      timestamp => now - timestamp <= maxAge
    );

    if (cutoffIndex > 0) {
      metricsHistory.current.timestamps = metricsHistory.current.timestamps.slice(cutoffIndex);
      Object.keys(metricsHistory.current.values).forEach(key => {
        metricsHistory.current.values[key] = metricsHistory.current.values[key].slice(cutoffIndex);
      });
    }
  }, [config.monitoring.history]);

  // Process tree update effect
  useEffect(() => {
    if (!data) return;

    const metrics = calculateMetrics(data);
    const anomalies = detectAnomalies(data);
    const now = Date.now();

    setState(prev => ({
      metrics,
      anomalies,
      lastUpdate: now,
      renderCount: prev.renderCount + 1,
    }));

    updateMetricsHistory(metrics);

    // Cache process nodes
    const cacheNodes = (node: ProcessNode) => {
      if (node.id) {
        processCache.current.set(node.id, node);
      }
      if (node.children) {
        node.children.forEach(cacheNodes);
      }
    };
    cacheNodes(data);

    // Notify listeners
    if (options.onMetricsUpdate) {
      options.onMetricsUpdate(metrics);
    }

    if (options.onAnomalyDetected && anomalies.length > 0) {
      anomalies.forEach(anomaly => options.onAnomalyDetected!(anomaly));
    }
  }, [data, calculateMetrics, detectAnomalies, updateMetricsHistory, options]);

  return {
    metrics: state.metrics,
    anomalies: state.anomalies,
    lastUpdate: state.lastUpdate,
    renderCount: state.renderCount,
    metricsHistory: metricsHistory.current,
  };
} 