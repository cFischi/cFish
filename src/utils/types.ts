export type ProcessStatus = 'active' | 'completed' | 'pending' | 'error' | 'default';
export type ProcessType = 'user' | 'system' | 'service' | 'background' | 'unknown' | 'cursor' | 'node';
export type ProcessPriority = 'critical' | 'high' | 'medium' | 'low' | 'background';
export type TerminationStatus = 'idle' | 'pending' | 'success' | 'error';

export interface ProcessNode {
  name: string;
  id?: number;
  status?: ProcessStatus;
  type?: ProcessType;
  description?: string;
  children?: ProcessNode[];
  onClick?: (node: ProcessNode) => void;
  onRefresh?: () => void;
  memoryUsageMB?: number;
  cpuUsagePercent?: number;
  startTime?: string;
  runningForSeconds?: number;
  commandLine?: string;
  threadCount?: number;
  handleCount?: number;
  priorityLevel?: ProcessPriority;
  priorityScore?: number;
  isProtected?: boolean;
  metadata?: {
    [key: string]: unknown;
  };
}

export interface ProcessHierarchyData {
  rootProcesses: ProcessNode[];
  allProcesses: { [id: string]: ProcessNode };
  timestamp: string;
}

export interface SystemResources {
  totalMemoryGB: number;
  freeMemoryGB: number;
  memoryUsedPercent: number;
  cpuUsagePercent: number;
  totalProcessCount: number;
  activeProcessCount: number;
}

export interface ProcessMetrics {
  totalProcesses: number;
  highMemoryProcesses: number;
  systemProcesses: number;
  totalMemoryUsage: number;
  cursorProcesses: number;
  nodeProcesses: number;
}

export interface ProcessAnomalyInfo {
  processId: number;
  name: string;
  reasons: string[];
  timestamp: string;
  severity: 'HIGH' | 'MEDIUM' | 'LOW';
}

export interface D3ProcessNode {
  data: ProcessNode;
  x: number;
  y: number;
  depth: number;
  height: number;
  parent?: D3ProcessNode;
  children?: D3ProcessNode[];
}

export interface D3ProcessLink {
  source: D3ProcessNode;
  target: D3ProcessNode;
} 