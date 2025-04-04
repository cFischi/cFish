const { exec } = require('child_process');
const fs = require('fs/promises');
const os = require('os');
const path = require('path');

async function killPort(port) {
  return new Promise((resolve, reject) => {
    const command = process.platform === 'win32'
      ? `netstat -ano | findstr :${port}`
      : `lsof -i :${port}`;
    
    exec(command, (error, stdout, stderr) => {
      if (error) {
        // No process found on port
        resolve();
        return;
      }
      
      try {
        if (process.platform === 'win32') {
          const lines = stdout.split('\n');
          const pidMatch = lines[0]?.match(/\s+(\d+)\s*$/);
          if (pidMatch && pidMatch[1]) {
            exec(`taskkill /F /PID ${pidMatch[1]}`);
          }
        } else {
          const pid = stdout.split('\n')[1]?.split(/\s+/)[1];
          if (pid) {
            exec(`kill -9 ${pid}`);
          }
        }
        resolve();
      } catch (err) {
        reject(err);
      }
    });
  });
}

async function cleanup() {
  try {
    const testMetricsDir = path.join(os.tmpdir(), 'test-metrics');
    await killPort(3005);
    await fs.rm(testMetricsDir, { recursive: true, force: true });
    console.log('Cleanup completed successfully');
  } catch (error) {
    console.error('Cleanup error:', error);
  }
}

// Run cleanup if this script is executed directly
if (require.main === module) {
  cleanup();
} 