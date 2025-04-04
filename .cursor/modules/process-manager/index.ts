import pidtree from 'pidtree';
import { spawn } from 'child_process';
import { EventEmitter } from 'events';

interface ProcessInfo {
  pid: number;
  name: string;
  cpu: number;
  memory: number;
  children?: ProcessInfo[];
}

class ProcessManager extends EventEmitter {
  private updateInterval: number;
  private running: boolean = false;
  private intervalId?: NodeJS.Timeout;

  constructor(updateInterval: number = 1000) {
    super();
    this.updateInterval = updateInterval;
  }

  async getProcessTree(): Promise<ProcessInfo[]> {
    try {
      const pids = await pidtree(-1, { root: true });
      const processInfo: ProcessInfo[] = [];

      for (const pid of pids) {
        try {
          const info = await this.getProcessInfo(pid);
          if (info) {
            processInfo.push(info);
          }
        } catch (error) {
          console.error(`Error getting info for PID ${pid}:`, error);
        }
      }

      return this.buildProcessTree(processInfo);
    } catch (error) {
      console.error('Error getting process tree:', error);
      throw error;
    }
  }

  private async getProcessInfo(pid: number): Promise<ProcessInfo | null> {
    try {
      const cmd = process.platform === 'win32' ? 
        `powershell -Command "Get-Process -Id ${pid} | Select-Object Name,CPU,WorkingSet"` :
        `ps -p ${pid} -o pid,comm,%cpu,%mem --no-headers`;

      const output = await new Promise<string>((resolve, reject) => {
        const proc = spawn(process.platform === 'win32' ? 'cmd' : 'sh', 
          [process.platform === 'win32' ? '/c' : '-c', cmd]);
        
        let stdout = '';
        let stderr = '';

        proc.stdout.on('data', (data) => stdout += data);
        proc.stderr.on('data', (data) => stderr += data);
        
        proc.on('close', (code) => {
          if (code === 0) {
            resolve(stdout);
          } else {
            reject(new Error(`Process exited with code ${code}: ${stderr}`));
          }
        });
      });

      const parts = output.trim().split(/\s+/);
      return {
        pid,
        name: parts[1],
        cpu: parseFloat(parts[2]),
        memory: parseFloat(parts[3])
      };
    } catch (error) {
      console.error(`Error getting process info for PID ${pid}:`, error);
      return null;
    }
  }

  private buildProcessTree(processes: ProcessInfo[]): ProcessInfo[] {
    const pidMap = new Map<number, ProcessInfo>();
    processes.forEach(proc => pidMap.set(proc.pid, proc));

    const tree: ProcessInfo[] = [];
    processes.forEach(proc => {
      const parent = pidMap.get(proc.pid);
      if (parent) {
        if (!parent.children) {
          parent.children = [];
        }
        parent.children.push(proc);
      } else {
        tree.push(proc);
      }
    });

    return tree;
  }

  startMonitoring(): void {
    if (this.running) return;
    
    this.running = true;
    this.intervalId = setInterval(async () => {
      try {
        const tree = await this.getProcessTree();
        this.emit('update', tree);
      } catch (error) {
        this.emit('error', error);
      }
    }, this.updateInterval);
  }

  stopMonitoring(): void {
    if (this.intervalId) {
      clearInterval(this.intervalId);
      this.intervalId = undefined;
    }
    this.running = false;
  }
}

export default ProcessManager; 