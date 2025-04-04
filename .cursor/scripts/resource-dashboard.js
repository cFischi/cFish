/**
 * Resource Monitoring Dashboard with Predictive Analysis
 * This script provides real-time monitoring and predictive analysis for system resources.
 */

const fs = require('fs');
const path = require('path');
const os = require('os');
const { spawn, exec } = require('child_process');
const express = require('express');
const http = require('http');
const WebSocket = require('ws');
const si = require('systeminformation');

// Configuration
const config = {
  port: 3000,
  updateInterval: 1000, // 1 second update interval
  retentionPeriod: 3600, // 1 hour data retention in seconds
  logDir: path.join(__dirname, '..', 'logs'),
  metricsDir: path.join(__dirname, '..', 'metrics'),
  predictiveAnalysis: {
    enabled: true,
    predictionWindow: 300, // 5 minutes prediction
    trainingWindow: 1800, // 30 minutes training data
    thresholds: {
      memory: 0.85, // 85% memory usage warning
      cpu: 0.80, // 80% CPU usage warning
      processCount: 150 // Process count warning
    }
  },
  processManager: {
    scriptPath: path.join(__dirname, 'process-priority-queue.ps1'),
    monitorOnly: true, // Monitor only by default
    refreshInterval: 60000 // 60 seconds refresh
  },
  alertCorrelation: {
    enabled: true,
    timeWindow: 300, // 5 minutes correlation window
    patterns: ['sequence', 'frequency', 'threshold'],
    alerts: []
  }
};

// Initialize data storage
const metrics = {
  system: {
    memory: [],
    cpu: [],
    processes: [],
    timestamps: []
  },
  processes: {},
  alerts: [],
  predictions: {
    memory: null,
    cpu: null,
    processCount: null
  }
};

// Create directories if they don't exist
[config.logDir, config.metricsDir].forEach(dir => {
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
});

// Setup logging
const logFile = path.join(config.logDir, `resource-dashboard-${new Date().toISOString().replace(/:/g, '-')}.log`);
const log = (message, level = 'INFO') => {
  const timestamp = new Date().toISOString();
  const logMessage = `${timestamp} [${level}] ${message}`;
  console.log(logMessage);
  fs.appendFileSync(logFile, logMessage + '\n');
};

log('Starting Resource Monitoring Dashboard');

// Initialize express app for the web dashboard
const app = express();
const server = http.createServer(app);
const wss = new WebSocket.Server({ server });

// Serve static files
app.use(express.static(path.join(__dirname, '..', 'public')));

// API routes
app.get('/api/metrics/current', (req, res) => {
  const currentMetrics = {
    memory: metrics.system.memory.length > 0 ? metrics.system.memory[metrics.system.memory.length - 1] : null,
    cpu: metrics.system.cpu.length > 0 ? metrics.system.cpu[metrics.system.cpu.length - 1] : null,
    processCount: metrics.system.processes.length > 0 ? metrics.system.processes[metrics.system.processes.length - 1] : null,
    timestamp: metrics.system.timestamps.length > 0 ? metrics.system.timestamps[metrics.system.timestamps.length - 1] : null,
    predictions: metrics.predictions
  };
  res.json(currentMetrics);
});

app.get('/api/metrics/history', (req, res) => {
  res.json({
    memory: metrics.system.memory,
    cpu: metrics.system.cpu,
    processes: metrics.system.processes,
    timestamps: metrics.system.timestamps
  });
});

app.get('/api/processes', (req, res) => {
  res.json(metrics.processes);
});

app.get('/api/alerts', (req, res) => {
  res.json(metrics.alerts);
});

app.get('/api/processes/priority', async (req, res) => {
  try {
    const priorityData = await getProcessPriorityData();
    res.json(priorityData);
  } catch (err) {
    log(`Error fetching process priority data: ${err.message}`, 'ERROR');
    res.status(500).json({ error: err.message });
  }
});

app.post('/api/processes/terminate/:id', (req, res) => {
  const processId = req.params.id;
  
  // Validate that this is a number
  if (!/^\d+$/.test(processId)) {
    return res.status(400).json({ error: 'Invalid process ID' });
  }
  
  terminateProcess(processId)
    .then(result => {
      res.json(result);
    })
    .catch(err => {
      log(`Error terminating process ${processId}: ${err.message}`, 'ERROR');
      res.status(500).json({ error: err.message });
    });
});

// WebSocket connection handling
wss.on('connection', (ws) => {
  log('Dashboard client connected');
  
  // Send current data to newly connected client
  const initialData = {
    memory: metrics.system.memory,
    cpu: metrics.system.cpu,
    processes: metrics.system.processes,
    timestamps: metrics.system.timestamps,
    alerts: metrics.alerts,
    predictions: metrics.predictions,
    currentProcesses: metrics.processes
  };
  
  ws.send(JSON.stringify({
    type: 'initial',
    data: initialData
  }));
  
  // Handle client messages
  ws.on('message', (message) => {
    try {
      const msg = JSON.parse(message);
      
      if (msg.type === 'terminate-process' && msg.processId) {
        terminateProcess(msg.processId)
          .then(result => {
            ws.send(JSON.stringify({
              type: 'termination-result',
              data: result
            }));
          })
          .catch(err => {
            log(`Error terminating process ${msg.processId}: ${err.message}`, 'ERROR');
            ws.send(JSON.stringify({
              type: 'error',
              data: { message: err.message }
            }));
          });
      }
    } catch (err) {
      log(`Error handling WebSocket message: ${err.message}`, 'ERROR');
    }
  });
  
  ws.on('close', () => {
    log('Dashboard client disconnected');
  });
});

// Start the server
server.listen(config.port, () => {
  log(`Dashboard server listening on port ${config.port}`);
});

// System Metrics Collection
async function collectSystemMetrics() {
  try {
    // Collect basic system info
    const [cpuData, memData, processData] = await Promise.all([
      si.currentLoad(),
      si.mem(),
      si.processes()
    ]);
    
    const memoryUsage = memData.used / memData.total;
    const cpuUsage = cpuData.currentLoad / 100;
    const processCount = processData.all;
    
    // Trim data if it exceeds retention period
    const currentTime = Date.now();
    const retentionThreshold = currentTime - (config.retentionPeriod * 1000);
    
    if (metrics.system.timestamps.length > 0 && metrics.system.timestamps[0] < retentionThreshold) {
      const trimIndex = metrics.system.timestamps.findIndex(t => t >= retentionThreshold);
      if (trimIndex > 0) {
        metrics.system.memory = metrics.system.memory.slice(trimIndex);
        metrics.system.cpu = metrics.system.cpu.slice(trimIndex);
        metrics.system.processes = metrics.system.processes.slice(trimIndex);
        metrics.system.timestamps = metrics.system.timestamps.slice(trimIndex);
      }
    }
    
    // Add new data point
    metrics.system.memory.push(memoryUsage);
    metrics.system.cpu.push(cpuUsage);
    metrics.system.processes.push(processCount);
    metrics.system.timestamps.push(currentTime);
    
    // Update process list
    metrics.processes = {};
    
    if (processData.list) {
      processData.list.forEach(process => {
        metrics.processes[process.pid] = {
          name: process.name,
          pid: process.pid,
          memoryUsageMB: Math.round(process.pmem / 100 * memData.total / 1024 / 1024),
          cpuUsagePercent: process.cpu,
          state: process.state,
          user: process.user,
          startTime: process.started
        };
      });
    }
    
    // Run predictive analysis
    if (config.predictiveAnalysis.enabled) {
      runPredictiveAnalysis();
    }
    
    // Run alert correlation
    if (config.alertCorrelation.enabled) {
      checkForAlerts();
    }
    
    // Broadcast update to connected clients
    const update = {
      memory: memoryUsage,
      cpu: cpuUsage,
      processCount,
      timestamp: currentTime,
      predictions: metrics.predictions,
      alerts: metrics.alerts.slice(-5) // Send only last 5 alerts
    };
    
    wss.clients.forEach(client => {
      if (client.readyState === WebSocket.OPEN) {
        client.send(JSON.stringify({
          type: 'update',
          data: update
        }));
      }
    });
    
  } catch (err) {
    log(`Error collecting system metrics: ${err.message}`, 'ERROR');
  }
}

// Predictive Analysis
function runPredictiveAnalysis() {
  try {
    // Basic linear regression for predictions
    // In a production system, this would use more sophisticated ML techniques
    
    // We only predict if we have enough data points
    if (metrics.system.timestamps.length >= 30) { // At least 30 data points
      // Get data for the training window
      const windowSize = Math.min(metrics.system.memory.length, config.predictiveAnalysis.trainingWindow);
      const memoryData = metrics.system.memory.slice(-windowSize);
      const cpuData = metrics.system.cpu.slice(-windowSize);
      const processData = metrics.system.processes.slice(-windowSize);
      const timeData = metrics.system.timestamps.slice(-windowSize);
      
      // Convert timestamps to seconds from start for easier calculation
      const startTime = timeData[0];
      const normalizedTime = timeData.map(t => (t - startTime) / 1000);
      
      // Simple linear regression
      const memoryPredictor = linearRegression(normalizedTime, memoryData);
      const cpuPredictor = linearRegression(normalizedTime, cpuData);
      const processPredictor = linearRegression(normalizedTime, processData);
      
      // Predict for 5 minutes in the future
      const predictionPoint = config.predictiveAnalysis.predictionWindow;
      
      metrics.predictions = {
        memory: {
          value: memoryPredictor.predict(predictionPoint),
          slope: memoryPredictor.slope,
          timeToThreshold: memoryPredictor.slope > 0 ? 
            Math.max(0, Math.round((config.predictiveAnalysis.thresholds.memory - memoryData[memoryData.length - 1]) / memoryPredictor.slope)) : 
            null
        },
        cpu: {
          value: cpuPredictor.predict(predictionPoint),
          slope: cpuPredictor.slope,
          timeToThreshold: cpuPredictor.slope > 0 ? 
            Math.max(0, Math.round((config.predictiveAnalysis.thresholds.cpu - cpuData[cpuData.length - 1]) / cpuPredictor.slope)) : 
            null
        },
        processCount: {
          value: processPredictor.predict(predictionPoint),
          slope: processPredictor.slope,
          timeToThreshold: processPredictor.slope > 0 ? 
            Math.max(0, Math.round((config.predictiveAnalysis.thresholds.processCount - processData[processData.length - 1]) / processPredictor.slope)) : 
            null
        },
        timestamp: Date.now()
      };
      
      // Generate predictive alerts
      generatePredictiveAlerts();
    }
  } catch (err) {
    log(`Error in predictive analysis: ${err.message}`, 'ERROR');
  }
}

// Simple linear regression
function linearRegression(x, y) {
  const n = x.length;
  let sumX = 0;
  let sumY = 0;
  let sumXY = 0;
  let sumXX = 0;
  
  for (let i = 0; i < n; i++) {
    sumX += x[i];
    sumY += y[i];
    sumXY += x[i] * y[i];
    sumXX += x[i] * x[i];
  }
  
  const slope = (n * sumXY - sumX * sumY) / (n * sumXX - sumX * sumX);
  const intercept = (sumY - slope * sumX) / n;
  
  return {
    slope,
    intercept,
    predict: (x) => intercept + slope * x
  };
}

// Generate predictive alerts
function generatePredictiveAlerts() {
  const predictions = metrics.predictions;
  const currentTime = Date.now();
  
  // Memory prediction alert
  if (predictions.memory.timeToThreshold !== null && predictions.memory.timeToThreshold < 300) { // Alert if threshold will be reached in less than 5 minutes
    addAlert({
      type: 'PREDICTIVE',
      category: 'MEMORY',
      level: 'WARNING',
      message: `Memory usage predicted to reach ${Math.round(config.predictiveAnalysis.thresholds.memory * 100)}% in ${formatTimeRemaining(predictions.memory.timeToThreshold)}`,
      timestamp: currentTime,
      value: predictions.memory.value,
      timeToThreshold: predictions.memory.timeToThreshold
    });
  }
  
  // CPU prediction alert
  if (predictions.cpu.timeToThreshold !== null && predictions.cpu.timeToThreshold < 300) {
    addAlert({
      type: 'PREDICTIVE',
      category: 'CPU',
      level: 'WARNING',
      message: `CPU usage predicted to reach ${Math.round(config.predictiveAnalysis.thresholds.cpu * 100)}% in ${formatTimeRemaining(predictions.cpu.timeToThreshold)}`,
      timestamp: currentTime,
      value: predictions.cpu.value,
      timeToThreshold: predictions.cpu.timeToThreshold
    });
  }
  
  // Process count prediction alert
  if (predictions.processCount.timeToThreshold !== null && predictions.processCount.timeToThreshold < 300) {
    addAlert({
      type: 'PREDICTIVE',
      category: 'PROCESS',
      level: 'WARNING',
      message: `Process count predicted to reach ${config.predictiveAnalysis.thresholds.processCount} in ${formatTimeRemaining(predictions.processCount.timeToThreshold)}`,
      timestamp: currentTime,
      value: predictions.processCount.value,
      timeToThreshold: predictions.processCount.timeToThreshold
    });
  }
}

// Format time remaining for alerts
function formatTimeRemaining(seconds) {
  if (seconds < 60) {
    return `${seconds} seconds`;
  } else {
    const minutes = Math.floor(seconds / 60);
    const remainingSeconds = seconds % 60;
    return `${minutes} minute${minutes !== 1 ? 's' : ''} ${remainingSeconds} second${remainingSeconds !== 1 ? 's' : ''}`;
  }
}

// Check for real-time alerts
function checkForAlerts() {
  const latestMemory = metrics.system.memory.length > 0 ? metrics.system.memory[metrics.system.memory.length - 1] : null;
  const latestCpu = metrics.system.cpu.length > 0 ? metrics.system.cpu[metrics.system.cpu.length - 1] : null;
  const latestProcessCount = metrics.system.processes.length > 0 ? metrics.system.processes[metrics.system.processes.length - 1] : null;
  const currentTime = Date.now();
  
  // Current threshold alerts
  if (latestMemory !== null && latestMemory >= config.predictiveAnalysis.thresholds.memory) {
    addAlert({
      type: 'IMMEDIATE',
      category: 'MEMORY',
      level: 'CRITICAL',
      message: `Memory usage at ${Math.round(latestMemory * 100)}%, exceeding threshold of ${Math.round(config.predictiveAnalysis.thresholds.memory * 100)}%`,
      timestamp: currentTime,
      value: latestMemory
    });
  }
  
  if (latestCpu !== null && latestCpu >= config.predictiveAnalysis.thresholds.cpu) {
    addAlert({
      type: 'IMMEDIATE',
      category: 'CPU',
      level: 'CRITICAL',
      message: `CPU usage at ${Math.round(latestCpu * 100)}%, exceeding threshold of ${Math.round(config.predictiveAnalysis.thresholds.cpu * 100)}%`,
      timestamp: currentTime,
      value: latestCpu
    });
  }
  
  if (latestProcessCount !== null && latestProcessCount >= config.predictiveAnalysis.thresholds.processCount) {
    addAlert({
      type: 'IMMEDIATE',
      category: 'PROCESS',
      level: 'CRITICAL',
      message: `Process count at ${latestProcessCount}, exceeding threshold of ${config.predictiveAnalysis.thresholds.processCount}`,
      timestamp: currentTime,
      value: latestProcessCount
    });
  }
  
  // Run alert correlation engine
  correlateAlerts();
}

// Add a new alert
function addAlert(alert) {
  // Check if we already have a similar alert in the last minute
  const oneMinuteAgo = Date.now() - 60000;
  const similarAlert = metrics.alerts.find(a => 
    a.category === alert.category && 
    a.level === alert.level && 
    a.timestamp > oneMinuteAgo
  );
  
  // Only add if no similar alert exists
  if (!similarAlert) {
    metrics.alerts.push(alert);
    
    // Limit alerts array size
    if (metrics.alerts.length > 100) {
      metrics.alerts = metrics.alerts.slice(-100);
    }
    
    log(`Alert: ${alert.message}`, alert.level);
    
    // If critical alert, trigger process priority queue
    if (alert.level === 'CRITICAL') {
      runProcessPriorityQueue();
    }
  }
}

// Alert correlation engine
function correlateAlerts() {
  try {
    // Define time window
    const windowStart = Date.now() - (config.alertCorrelation.timeWindow * 1000);
    
    // Get alerts in the window
    const windowAlerts = metrics.alerts.filter(alert => alert.timestamp >= windowStart);
    
    // Skip if not enough alerts for correlation
    if (windowAlerts.length < 3) return;
    
    // Check for sequence patterns (e.g., CPU spike followed by memory spike)
    const cpuAlerts = windowAlerts.filter(a => a.category === 'CPU');
    const memoryAlerts = windowAlerts.filter(a => a.category === 'MEMORY');
    
    if (cpuAlerts.length > 0 && memoryAlerts.length > 0) {
      // Find closest CPU and memory alerts
      const latestCpuAlert = cpuAlerts.reduce((latest, current) => 
        current.timestamp > latest.timestamp ? current : latest, cpuAlerts[0]);
      
      const latestMemoryAlert = memoryAlerts.reduce((latest, current) => 
        current.timestamp > latest.timestamp ? current : latest, memoryAlerts[0]);
      
      // CPU spike followed by memory increase within 30 seconds suggests potential issue
      if (Math.abs(latestCpuAlert.timestamp - latestMemoryAlert.timestamp) < 30000) {
        addAlert({
          type: 'CORRELATED',
          category: 'SYSTEM',
          level: 'WARNING',
          message: 'Correlated CPU and memory spikes detected, suggesting potential system stress',
          timestamp: Date.now(),
          correlatedAlerts: [latestCpuAlert, latestMemoryAlert]
        });
      }
    }
    
    // Check frequency patterns (multiple alerts of same type)
    const categoryCounts = {};
    windowAlerts.forEach(alert => {
      categoryCounts[alert.category] = (categoryCounts[alert.category] || 0) + 1;
    });
    
    Object.entries(categoryCounts).forEach(([category, count]) => {
      if (count >= 3) { // 3 or more alerts of same type
        addAlert({
          type: 'CORRELATED',
          category: 'FREQUENCY',
          level: 'WARNING',
          message: `High frequency of ${category} alerts detected (${count} in ${config.alertCorrelation.timeWindow} seconds)`,
          timestamp: Date.now(),
          count
        });
      }
    });
    
  } catch (err) {
    log(`Error in alert correlation: ${err.message}`, 'ERROR');
  }
}

// Run the PowerShell process priority queue script
async function runProcessPriorityQueue() {
  try {
    log('Running process priority queue');
    
    const scriptPath = config.processManager.scriptPath;
    const monitorFlag = config.processManager.monitorOnly ? '-MonitorOnly' : '';
    
    // Execute PowerShell script
    return new Promise((resolve, reject) => {
      exec(`powershell -ExecutionPolicy Bypass -File "${scriptPath}" ${monitorFlag}`, (error, stdout, stderr) => {
        if (error) {
          log(`Error running process priority queue: ${error.message}`, 'ERROR');
          reject(error);
          return;
        }
        
        if (stderr) {
          log(`Process priority queue stderr: ${stderr}`, 'WARNING');
        }
        
        log('Process priority queue completed successfully');
        log(`Output: ${stdout.slice(0, 200)}...`);
        resolve(stdout);
      });
    });
  } catch (err) {
    log(`Error running process priority queue: ${err.message}`, 'ERROR');
    throw err;
  }
}

// Fetch process priority data
async function getProcessPriorityData() {
  try {
    log('Fetching process priority data');
    
    // Find latest process priorities file
    const metricsDir = config.metricsDir;
    const files = fs.readdirSync(path.join(metricsDir, '..')).filter(f => 
      f.startsWith('process-priorities-') && f.endsWith('.json'));
    
    if (files.length === 0) {
      // No data files yet, run the process priority queue
      await runProcessPriorityQueue();
      
      // Check again
      const newFiles = fs.readdirSync(path.join(metricsDir, '..')).filter(f => 
        f.startsWith('process-priorities-') && f.endsWith('.json'));
      
      if (newFiles.length === 0) {
        throw new Error('No process priority data files found after running queue');
      }
      
      files.push(...newFiles);
    }
    
    // Sort by timestamp (newest first)
    files.sort().reverse();
    
    // Read the latest file
    const latestFile = path.join(metricsDir, '..', files[0]);
    const data = JSON.parse(fs.readFileSync(latestFile, 'utf8'));
    
    return data;
  } catch (err) {
    log(`Error fetching process priority data: ${err.message}`, 'ERROR');
    throw err;
  }
}

// Terminate a process
async function terminateProcess(processId) {
  try {
    log(`Attempting to terminate process ${processId}`);
    
    // Use platform-specific termination approach
    if (process.platform === 'win32') {
      return new Promise((resolve, reject) => {
        exec(`taskkill /F /PID ${processId}`, (error, stdout, stderr) => {
          if (error) {
            log(`Error terminating process ${processId}: ${error.message}`, 'ERROR');
            reject(error);
            return;
          }
          
          log(`Process ${processId} terminated successfully`);
          resolve({
            success: true,
            message: `Process ${processId} terminated successfully`
          });
        });
      });
    } else {
      return new Promise((resolve, reject) => {
        exec(`kill -9 ${processId}`, (error, stdout, stderr) => {
          if (error) {
            log(`Error terminating process ${processId}: ${error.message}`, 'ERROR');
            reject(error);
            return;
          }
          
          log(`Process ${processId} terminated successfully`);
          resolve({
            success: true,
            message: `Process ${processId} terminated successfully`
          });
        });
      });
    }
  } catch (err) {
    log(`Error terminating process ${processId}: ${err.message}`, 'ERROR');
    throw err;
  }
}

// Create a minimal dashboard HTML if it doesn't exist
const dashboardHtmlPath = path.join(__dirname, '..', 'public', 'index.html');
if (!fs.existsSync(path.dirname(dashboardHtmlPath))) {
  fs.mkdirSync(path.dirname(dashboardHtmlPath), { recursive: true });
}

if (!fs.existsSync(dashboardHtmlPath)) {
  const htmlContent = `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Resource Monitoring Dashboard</title>
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Arial, sans-serif; margin: 0; padding: 20px; background-color: #f5f5f5; }
    .dashboard { display: flex; flex-wrap: wrap; gap: 20px; }
    .card { background-color: white; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,.1); padding: 16px; flex: 1; min-width: 300px; }
    .metric { font-size: 32px; font-weight: bold; margin: 10px 0; }
    .chart { width: 100%; height: 200px; margin-top: 20px; }
    .critical { color: #d32f2f; }
    .warning { color: #f57c00; }
    .normal { color: #388e3c; }
    .alert-list { height: 300px; overflow-y: auto; margin-top: 10px; }
    .alert { padding: 8px; margin-bottom: 8px; border-radius: 4px; }
    .alert.CRITICAL { background-color: rgba(211, 47, 47, 0.1); border-left: 4px solid #d32f2f; }
    .alert.WARNING { background-color: rgba(245, 124, 0, 0.1); border-left: 4px solid #f57c00; }
    .process-table { width: 100%; border-collapse: collapse; margin-top: 10px; }
    .process-table th, .process-table td { text-align: left; padding: 8px; border-bottom: 1px solid #eee; }
    .process-table th { background-color: #f5f5f5; }
    .process-table tr:hover { background-color: #f5f5f5; }
    .terminate-btn { background-color: #d32f2f; color: white; border: none; border-radius: 4px; padding: 4px 8px; cursor: pointer; }
    .terminate-btn:hover { background-color: #b71c1c; }
    .terminate-btn:disabled { background-color: #e0e0e0; color: #9e9e9e; cursor: not-allowed; }
  </style>
</head>
<body>
  <h1>Resource Monitoring Dashboard</h1>
  
  <div class="dashboard">
    <div class="card">
      <h2>Memory Usage</h2>
      <div id="memory-usage" class="metric normal">0%</div>
      <div id="memory-prediction"></div>
      <canvas id="memory-chart" class="chart"></canvas>
    </div>
    
    <div class="card">
      <h2>CPU Usage</h2>
      <div id="cpu-usage" class="metric normal">0%</div>
      <div id="cpu-prediction"></div>
      <canvas id="cpu-chart" class="chart"></canvas>
    </div>
    
    <div class="card">
      <h2>Process Count</h2>
      <div id="process-count" class="metric normal">0</div>
      <div id="process-prediction"></div>
      <canvas id="process-chart" class="chart"></canvas>
    </div>
    
    <div class="card">
      <h2>Alerts</h2>
      <div class="alert-list" id="alert-list"></div>
    </div>
    
    <div class="card" style="flex-basis: 100%;">
      <h2>Processes</h2>
      <input type="text" id="process-filter" placeholder="Filter processes..." style="width: 100%; padding: 8px; margin-bottom: 10px; box-sizing: border-box;">
      <div style="max-height: 500px; overflow-y: auto;">
        <table class="process-table" id="process-table">
          <thead>
            <tr>
              <th>PID</th>
              <th>Name</th>
              <th>Memory (MB)</th>
              <th>CPU (%)</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody></tbody>
        </table>
      </div>
    </div>
  </div>

  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
  <script>
    // Initialize charts
    const memoryCtx = document.getElementById('memory-chart').getContext('2d');
    const cpuCtx = document.getElementById('cpu-chart').getContext('2d');
    const processCtx = document.getElementById('process-chart').getContext('2d');
    
    const timeLabels = [];
    const memoryData = [];
    const cpuData = [];
    const processData = [];
    
    // Create charts
    const memoryChart = new Chart(memoryCtx, {
      type: 'line',
      data: {
        labels: timeLabels,
        datasets: [{
          label: 'Memory Usage',
          data: memoryData,
          borderColor: 'rgba(54, 162, 235, 1)',
          backgroundColor: 'rgba(54, 162, 235, 0.2)',
          tension: 0.4
        }]
      },
      options: {
        scales: {
          y: {
            beginAtZero: true,
            max: 1,
            ticks: {
              callback: value => \`\${Math.round(value * 100)}%\`
            }
          }
        },
        plugins: {
          tooltip: {
            callbacks: {
              label: context => \`\${Math.round(context.parsed.y * 100)}%\`
            }
          }
        }
      }
    });
    
    const cpuChart = new Chart(cpuCtx, {
      type: 'line',
      data: {
        labels: timeLabels,
        datasets: [{
          label: 'CPU Usage',
          data: cpuData,
          borderColor: 'rgba(255, 99, 132, 1)',
          backgroundColor: 'rgba(255, 99, 132, 0.2)',
          tension: 0.4
        }]
      },
      options: {
        scales: {
          y: {
            beginAtZero: true,
            max: 1,
            ticks: {
              callback: value => \`\${Math.round(value * 100)}%\`
            }
          }
        },
        plugins: {
          tooltip: {
            callbacks: {
              label: context => \`\${Math.round(context.parsed.y * 100)}%\`
            }
          }
        }
      }
    });
    
    const processChart = new Chart(processCtx, {
      type: 'line',
      data: {
        labels: timeLabels,
        datasets: [{
          label: 'Process Count',
          data: processData,
          borderColor: 'rgba(75, 192, 192, 1)',
          backgroundColor: 'rgba(75, 192, 192, 0.2)',
          tension: 0.4
        }]
      },
      options: {
        scales: {
          y: {
            beginAtZero: true
          }
        }
      }
    });
    
    // Update metrics display
    function updateMetricsDisplay(memory, cpu, processCount) {
      const memoryElement = document.getElementById('memory-usage');
      const cpuElement = document.getElementById('cpu-usage');
      const processElement = document.getElementById('process-count');
      
      const memoryPercentage = Math.round(memory * 100);
      const cpuPercentage = Math.round(cpu * 100);
      
      memoryElement.textContent = \`\${memoryPercentage}%\`;
      cpuElement.textContent = \`\${cpuPercentage}%\`;
      processElement.textContent = processCount;
      
      // Update classes based on thresholds
      memoryElement.className = 'metric ' + getMetricClass(memory, 0.85, 0.75);
      cpuElement.className = 'metric ' + getMetricClass(cpu, 0.8, 0.6);
      processElement.className = 'metric ' + getMetricClass(processCount / 200, 0.75, 0.5);
    }
    
    function getMetricClass(value, criticalThreshold, warningThreshold) {
      if (value >= criticalThreshold) return 'critical';
      if (value >= warningThreshold) return 'warning';
      return 'normal';
    }
    
    // Update prediction display
    function updatePredictionDisplay(predictions) {
      if (!predictions) return;
      
      const memoryElement = document.getElementById('memory-prediction');
      const cpuElement = document.getElementById('cpu-prediction');
      const processElement = document.getElementById('process-prediction');
      
      if (predictions.memory && predictions.memory.timeToThreshold !== null) {
        const timeString = formatTimeRemaining(predictions.memory.timeToThreshold);
        memoryElement.textContent = \`Predicted to reach 85% in \${timeString}\`;
        memoryElement.className = predictions.memory.timeToThreshold < 300 ? 'warning' : '';
      } else {
        memoryElement.textContent = predictions.memory && predictions.memory.slope > 0 ? 
          'Increasing' : (predictions.memory && predictions.memory.slope < 0 ? 'Decreasing' : 'Stable');
        memoryElement.className = '';
      }
      
      if (predictions.cpu && predictions.cpu.timeToThreshold !== null) {
        const timeString = formatTimeRemaining(predictions.cpu.timeToThreshold);
        cpuElement.textContent = \`Predicted to reach 80% in \${timeString}\`;
        cpuElement.className = predictions.cpu.timeToThreshold < 300 ? 'warning' : '';
      } else {
        cpuElement.textContent = predictions.cpu && predictions.cpu.slope > 0 ? 
          'Increasing' : (predictions.cpu && predictions.cpu.slope < 0 ? 'Decreasing' : 'Stable');
        cpuElement.className = '';
      }
      
      if (predictions.processCount && predictions.processCount.timeToThreshold !== null) {
        const timeString = formatTimeRemaining(predictions.processCount.timeToThreshold);
        processElement.textContent = \`Predicted to reach 150 in \${timeString}\`;
        processElement.className = predictions.processCount.timeToThreshold < 300 ? 'warning' : '';
      } else {
        processElement.textContent = predictions.processCount && predictions.processCount.slope > 0 ? 
          'Increasing' : (predictions.processCount && predictions.processCount.slope < 0 ? 'Decreasing' : 'Stable');
        processElement.className = '';
      }
    }
    
    // Format time remaining
    function formatTimeRemaining(seconds) {
      if (seconds < 60) {
        return \`\${seconds} seconds\`;
      } else {
        const minutes = Math.floor(seconds / 60);
        const remainingSeconds = seconds % 60;
        return \`\${minutes} minute\${minutes !== 1 ? 's' : ''} \${remainingSeconds} second\${remainingSeconds !== 1 ? 's' : ''}\`;
      }
    }
    
    // Update alerts display
    function updateAlertsDisplay(alerts) {
      const alertList = document.getElementById('alert-list');
      alertList.innerHTML = '';
      
      alerts.forEach(alert => {
        const alertElement = document.createElement('div');
        alertElement.className = \`alert \${alert.level}\`;
        
        const timestamp = new Date(alert.timestamp).toLocaleTimeString();
        
        alertElement.innerHTML = \`
          <div><strong>\${alert.level} - \${alert.category}</strong> [\${timestamp}]</div>
          <div>\${alert.message}</div>
        \`;
        
        alertList.appendChild(alertElement);
      });
    }
    
    // Update process table
    function updateProcessTable(processes) {
      const tableBody = document.querySelector('#process-table tbody');
      const filterValue = document.getElementById('process-filter').value.toLowerCase();
      
      tableBody.innerHTML = '';
      
      // Convert processes object to array and sort by memory usage (descending)
      const processArray = Object.values(processes).sort((a, b) => b.memoryUsageMB - a.memoryUsageMB);
      
      // Filter processes
      const filteredProcesses = processArray.filter(process => 
        process.name.toLowerCase().includes(filterValue) || 
        process.pid.toString().includes(filterValue)
      );
      
      filteredProcesses.forEach(process => {
        const row = document.createElement('tr');
        
        row.innerHTML = \`
          <td>\${process.pid}</td>
          <td>\${process.name}</td>
          <td>\${process.memoryUsageMB}</td>
          <td>\${process.cpuUsagePercent ? process.cpuUsagePercent.toFixed(1) : '0.0'}</td>
          <td>
            <button class="terminate-btn" data-pid="\${process.pid}">Terminate</button>
          </td>
        \`;
        
        tableBody.appendChild(row);
      });
      
      // Add event listeners to terminate buttons
      document.querySelectorAll('.terminate-btn').forEach(button => {
        button.addEventListener('click', () => {
          const pid = button.getAttribute('data-pid');
          if (confirm(\`Are you sure you want to terminate process \${pid}?\`)) {
            button.disabled = true;
            button.textContent = 'Terminating...';
            
            fetch(\`/api/processes/terminate/\${pid}\`, { method: 'POST' })
              .then(response => response.json())
              .then(result => {
                if (result.success) {
                  button.textContent = 'Terminated';
                  setTimeout(() => {
                    // Remove the row or refresh the process list
                    const row = button.closest('tr');
                    if (row) row.remove();
                  }, 1000);
                } else {
                  button.textContent = 'Failed';
                  button.disabled = false;
                  alert(\`Failed to terminate process: \${result.error || 'Unknown error'}\`);
                }
              })
              .catch(error => {
                button.textContent = 'Failed';
                button.disabled = false;
                alert(\`Error: \${error.message}\`);
              });
          }
        });
      });
    }
    
    // Setup WebSocket connection
    const ws = new WebSocket(\`ws://\${window.location.host}\`);
    
    ws.onopen = () => {
      console.log('Connected to server');
    };
    
    ws.onmessage = (event) => {
      const message = JSON.parse(event.data);
      
      if (message.type === 'initial') {
        // Initialize charts with historical data
        const data = message.data;
        
        timeLabels.length = 0;
        memoryData.length = 0;
        cpuData.length = 0;
        processData.length = 0;
        
        data.timestamps.forEach((timestamp, index) => {
          const date = new Date(timestamp);
          timeLabels.push(date.toLocaleTimeString());
          memoryData.push(data.memory[index]);
          cpuData.push(data.cpu[index]);
          processData.push(data.processes[index]);
        });
        
        memoryChart.update();
        cpuChart.update();
        processChart.update();
        
        // Update current displays
        if (data.memory.length > 0) {
          updateMetricsDisplay(
            data.memory[data.memory.length - 1], 
            data.cpu[data.cpu.length - 1], 
            data.processes[data.processes.length - 1]
          );
        }
        
        // Update predictions
        if (data.predictions) {
          updatePredictionDisplay(data.predictions);
        }
        
        // Update alerts
        if (data.alerts) {
          updateAlertsDisplay(data.alerts);
        }
        
        // Update process table
        if (data.currentProcesses) {
          updateProcessTable(data.currentProcesses);
        }
      } else if (message.type === 'update') {
        // Update with new data point
        const data = message.data;
        
        const date = new Date(data.timestamp);
        
        // Limit data points to 60 (1 minute at 1s intervals)
        if (timeLabels.length >= 60) {
          timeLabels.shift();
          memoryData.shift();
          cpuData.shift();
          processData.shift();
        }
        
        timeLabels.push(date.toLocaleTimeString());
        memoryData.push(data.memory);
        cpuData.push(data.cpu);
        processData.push(data.processCount);
        
        memoryChart.update();
        cpuChart.update();
        processChart.update();
        
        // Update current displays
        updateMetricsDisplay(data.memory, data.cpu, data.processCount);
        
        // Update predictions
        if (data.predictions) {
          updatePredictionDisplay(data.predictions);
        }
        
        // Update alerts
        if (data.alerts) {
          updateAlertsDisplay(data.alerts);
        }
        
        // Refresh process list every 5 seconds
        if (data.timestamp % 5000 < 1000) {
          fetch('/api/processes')
            .then(response => response.json())
            .then(processes => {
              updateProcessTable(processes);
            })
            .catch(error => console.error('Error fetching processes:', error));
        }
      }
    };
    
    ws.onclose = () => {
      console.log('Disconnected from server');
      // Attempt to reconnect after 5 seconds
      setTimeout(() => {
        location.reload();
      }, 5000);
    };
    
    // Setup process filter
    document.getElementById('process-filter').addEventListener('input', function() {
      fetch('/api/processes')
        .then(response => response.json())
        .then(processes => {
          updateProcessTable(processes);
        })
        .catch(error => console.error('Error fetching processes:', error));
    });
  </script>
</body>
</html>
  `;
  
  fs.writeFileSync(dashboardHtmlPath, htmlContent);
  log(`Created dashboard HTML at ${dashboardHtmlPath}`);
}

// Start metrics collection
setInterval(collectSystemMetrics, config.updateInterval);

// Periodically refresh process data using process-priority-queue
setInterval(() => {
  runProcessPriorityQueue().catch(err => {
    log(`Error in scheduled process priority queue: ${err.message}`, 'ERROR');
  });
}, config.processManager.refreshInterval);

// Initial data collection
collectSystemMetrics();

// Log startup complete
log('Resource Monitoring Dashboard started successfully');

module.exports = { app, server, wss, metrics, config }; 