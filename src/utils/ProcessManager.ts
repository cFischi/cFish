/// <reference types="node" />
import { EventEmitter } from 'events';
import * as os from 'os';

export interface ProcessStats {
  pid: number;
  memoryUsage: number;
  cpuUsage: number;
  startTime: number;
}

export interface SystemMetrics {
  totalMemory: number;
  freeMemory: number;
  cpuUsage: number;
}

export interface ProcessManager {
  on(event: 'error', listener: (error: Error) => void): this;
  on(event: 'process:registered', listener: (data: { pid: number; stats: ProcessStats }) => void): this;
  on(event: 'resource:threshold-exceeded', listener: (data: { pid: number; memoryUsage: number; cpuUsage: number }) => void): this;
  on(event: 'process:cleaned', listener: (data: { pid: number; stats: ProcessStats }) => void): this;
  on(event: 'shutdown:initiated', listener: () => void): this;
  on(event: 'shutdown:completed', listener: () => void): this;
  emit(event: string | symbol, ...args: any[]): boolean;
}

export class ProcessManager extends EventEmitter implements ProcessManager {
  private static instance: ProcessManager | null = null;
  private processes: Map<number, ProcessStats>;
  private readonly maxProcesses: number;
  private readonly memoryThreshold: number;
  private readonly cpuThreshold: number;

  private constructor() {
    super();
    this.processes = new Map<number, ProcessStats>();
    // Set conservative limits based on system resources
    this.maxProcesses = Math.max(5, Math.floor(os.cpus().length / 2));
    this.memoryThreshold = Math.floor(os.totalmem() * 0.7); // 70% of total memory
    this.cpuThreshold = 80; // 80% CPU threshold
  }

  public static getInstance(): ProcessManager {
    if (!ProcessManager.instance) {
      ProcessManager.instance = new ProcessManager();
    }
    return ProcessManager.instance;
  }

  public registerProcess(pid: number): boolean {
    try {
      if (this.processes.size >= this.maxProcesses) {
        this.emit('error', new Error('Maximum process limit reached'));
        return false;
      }

      const stats: ProcessStats = {
        pid,
        memoryUsage: 0,
        cpuUsage: 0,
        startTime: Date.now(),
      };

      this.processes.set(pid, stats);
      this.emit('process:registered', { pid, stats });
      return true;
    } catch (error) {
      this.emit('error', error instanceof Error ? error : new Error(String(error)));
      return false;
    }
  }

  public updateProcessStats(pid: number, memoryUsage: number, cpuUsage: number): void {
    try {
      const stats = this.processes.get(pid);
      if (!stats) return;

      stats.memoryUsage = memoryUsage;
      stats.cpuUsage = cpuUsage;

      if (memoryUsage > this.memoryThreshold || cpuUsage > this.cpuThreshold) {
        this.emit('resource:threshold-exceeded', { pid, memoryUsage, cpuUsage });
      }

      this.processes.set(pid, stats);
    } catch (error) {
      this.emit('error', error instanceof Error ? error : new Error(String(error)));
    }
  }

  public cleanupProcess(pid: number): void {
    try {
      const stats = this.processes.get(pid);
      if (!stats) return;

      process.kill(pid);
      this.processes.delete(pid);
      this.emit('process:cleaned', { pid, stats });
    } catch (error) {
      this.emit('error', error instanceof Error ? error : new Error(`Failed to cleanup process ${pid}: ${error}`));
    }
  }

  public emergencyShutdown(): void {
    try {
      this.emit('shutdown:initiated');
      
      for (const [pid] of this.processes) {
        try {
          process.kill(pid);
          this.processes.delete(pid);
        } catch (error) {
          console.error(`Failed to kill process ${pid}:`, error);
        }
      }

      this.emit('shutdown:completed');
    } catch (error) {
      this.emit('error', error instanceof Error ? error : new Error(String(error)));
    }
  }

  public getProcessStats(): Map<number, ProcessStats> {
    return new Map(this.processes);
  }

  public getSystemMetrics(): SystemMetrics {
    return {
      totalMemory: os.totalmem(),
      freeMemory: os.freemem(),
      cpuUsage: process.cpuUsage().user / 1000000, // Convert to milliseconds
    };
  }
}

export default ProcessManager; 