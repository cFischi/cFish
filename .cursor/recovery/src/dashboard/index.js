/**
 * Monitoring Dashboard Application
 * Displays real-time system metrics and alerts
 * Version: 1.0.0
 */

const fs = require('fs');
const path = require('path');
const http = require('http');
const { exec } = require('child_process');

// Parse command line arguments
const args = process.argv.slice(2);
let configPath = '';
let metricsPath = '';
let refreshInterval = 5;

for (let i = 0; i < args.length; i++) {
  if (args[i].startsWith('--config=')) {
    configPath = args[i].substring('--config='.length);
  } else if (args[i].startsWith('--metrics=')) {
    metricsPath = args[i].substring('--metrics='.length);
  } else if (args[i].startsWith('--refresh=')) {
    refreshInterval = parseInt(args[i].substring('--refresh='.length));
  }
}

if (!configPath || !metricsPath) {
  console.error('Error: Missing required parameters');
  console.error('Usage: node dashboard.js --config=<path> --metrics=<path> [--refresh=<seconds>]');
  process.exit(1);
}

// Load configuration
let config;
try {
  const configData = fs.readFileSync(configPath, 'utf8');
  config = JSON.parse(configData);
  console.log(`Loaded configuration from ${configPath}`);
} catch (error) {
  console.error(`Error loading configuration: ${error.message}`);
  process.exit(1);
}

// Create HTTP server for the dashboard
const server = http.createServer((req, res) => {
  if (req.url === '/') {
    // Serve main dashboard UI
    res.writeHead(200, { 'Content-Type': 'text/html' });
    res.end(generateDashboardHTML());
  } else if (req.url === '/metrics') {
    // Serve metrics data as JSON for AJAX requests
    try {
      const metricsData = fs.readFileSync(metricsPath, 'utf8');
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(metricsData);
    } catch (error) {
      res.writeHead(500, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ error: `Failed to read metrics: ${error.message}` }));
    }
  } else if (req.url === '/styles.css') {
    // Serve dashboard CSS
    res.writeHead(200, { 'Content-Type': 'text/css' });
    res.end(dashboardStyles());
  } else if (req.url === '/dashboard.js') {
    // Serve dashboard JavaScript
    res.writeHead(200, { 'Content-Type': 'application/javascript' });
    res.end(dashboardJavaScript(refreshInterval));
  } else {
    res.writeHead(404, { 'Content-Type': 'text/plain' });
    res.end('Not Found');
  }
});

// Start the server on port 3000
const PORT = 3000;
server.listen(PORT, () => {
  console.log(`Monitoring dashboard running at http://localhost:${PORT}/`);
  console.log(`Data refresh interval: ${refreshInterval} seconds`);
  
  // Open dashboard in default browser
  const startCommand = process.platform === 'win32' 
    ? `start http://localhost:${PORT}/` 
    : `open http://localhost:${PORT}/`;
  
  exec(startCommand, (error) => {
    if (error) {
      console.error(`Failed to open browser: ${error.message}`);
    }
  });
});

// Generate the dashboard HTML
function generateDashboardHTML() {
  return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>cFish.io Monitoring Dashboard</title>
  <link rel="stylesheet" href="/styles.css">
</head>
<body>
  <header>
    <h1>cFish.io Monitoring Dashboard</h1>
    <div class="refresh-info">
      <span>Auto-refresh: <span id="refresh-countdown">${refreshInterval}</span>s</span>
      <button id="manual-refresh">Refresh Now</button>
    </div>
  </header>
  
  <div class="dashboard-container">
    <div class="sidebar">
      <nav>
        <ul>
          <li><a href="#system" class="active">System</a></li>
          <li><a href="#processes">Processes</a></li>
          <li><a href="#applications">Applications</a></li>
          <li><a href="#alerts">Alerts</a></li>
        </ul>
      </nav>
      <div class="system-summary">
        <h3>System Summary</h3>
        <div id="summary-data">Loading...</div>
      </div>
    </div>
    
    <main class="content">
      <div id="system" class="dashboard-tab active">
        <h2>System Metrics</h2>
        <div class="metrics-grid">
          <div class="metric-card">
            <h3>Memory</h3>
            <div class="gauge-container">
              <canvas id="memory-gauge" width="150" height="150"></canvas>
            </div>
            <div class="metric-details" id="memory-details">Loading...</div>
          </div>
          
          <div class="metric-card">
            <h3>CPU</h3>
            <div class="gauge-container">
              <canvas id="cpu-gauge" width="150" height="150"></canvas>
            </div>
            <div class="metric-details" id="cpu-details">Loading...</div>
          </div>
          
          <div class="metric-card">
            <h3>Disk</h3>
            <div class="gauge-container">
              <canvas id="disk-gauge" width="150" height="150"></canvas>
            </div>
            <div class="metric-details" id="disk-details">Loading...</div>
          </div>
          
          <div class="metric-card">
            <h3>Network</h3>
            <div id="network-chart"></div>
            <div class="metric-details" id="network-details">Loading...</div>
          </div>
        </div>
      </div>
      
      <div id="processes" class="dashboard-tab">
        <h2>Process Information</h2>
        <div class="search-filter">
          <input type="text" id="process-search" placeholder="Search processes...">
          <select id="process-filter">
            <option value="all">All Processes</option>
            <option value="cursor">Cursor Processes</option>
            <option value="node">Node Processes</option>
            <option value="system">System Processes</option>
          </select>
        </div>
        <div class="process-stats">
          <div class="stat-box">
            <span class="stat-label">Total Processes</span>
            <span class="stat-value" id="total-processes">0</span>
          </div>
          <div class="stat-box">
            <span class="stat-label">Cursor Processes</span>
            <span class="stat-value" id="cursor-processes">0</span>
          </div>
          <div class="stat-box">
            <span class="stat-label">Node Processes</span>
            <span class="stat-value" id="node-processes">0</span>
          </div>
          <div class="stat-box">
            <span class="stat-label">High Memory</span>
            <span class="stat-value" id="high-memory-processes">0</span>
          </div>
        </div>
        <div class="table-container">
          <table id="process-table">
            <thead>
              <tr>
                <th>Name</th>
                <th>PID</th>
                <th>Memory (MB)</th>
                <th>CPU (%)</th>
                <th>Type</th>
              </tr>
            </thead>
            <tbody id="process-list">
              <tr>
                <td colspan="5">Loading process data...</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
      
      <div id="applications" class="dashboard-tab">
        <h2>Application Performance</h2>
        <div class="apps-grid">
          <div class="app-card" id="process-tree-card">
            <h3>Process Tree Visualization</h3>
            <div class="status-indicator" data-status="unknown"></div>
            <div class="app-metrics">
              <div class="metric">
                <span class="metric-label">Render Time</span>
                <span class="metric-value" id="pt-render-time">-- ms</span>
              </div>
              <div class="metric">
                <span class="metric-label">Memory Usage</span>
                <span class="metric-value" id="pt-memory">-- MB</span>
              </div>
              <div class="metric">
                <span class="metric-label">Status</span>
                <span class="metric-value" id="pt-status">Unknown</span>
              </div>
            </div>
          </div>
          
          <div class="app-card" id="alert-engine-card">
            <h3>Alert Correlation Engine</h3>
            <div class="status-indicator" data-status="unknown"></div>
            <div class="app-metrics">
              <div class="metric">
                <span class="metric-label">Latency</span>
                <span class="metric-value" id="ae-latency">-- ms</span>
              </div>
              <div class="metric">
                <span class="metric-label">Accuracy</span>
                <span class="metric-value" id="ae-accuracy">--%</span>
              </div>
              <div class="metric">
                <span class="metric-label">Status</span>
                <span class="metric-value" id="ae-status">Unknown</span>
              </div>
            </div>
          </div>
          
          <div class="app-card" id="queue-system-card">
            <h3>Queue Priority System</h3>
            <div class="status-indicator" data-status="unknown"></div>
            <div class="app-metrics">
              <div class="metric">
                <span class="metric-label">Queue Length</span>
                <span class="metric-value" id="qs-queue-length">--</span>
              </div>
              <div class="metric">
                <span class="metric-label">Throughput</span>
                <span class="metric-value" id="qs-throughput">-- ops/s</span>
              </div>
              <div class="metric">
                <span class="metric-label">Status</span>
                <span class="metric-value" id="qs-status">Unknown</span>
              </div>
            </div>
          </div>
          
          <div class="app-card" id="monitoring-card">
            <h3>Monitoring Dashboard</h3>
            <div class="status-indicator" data-status="active"></div>
            <div class="app-metrics">
              <div class="metric">
                <span class="metric-label">Update Interval</span>
                <span class="metric-value" id="md-interval">${refreshInterval}s</span>
              </div>
              <div class="metric">
                <span class="metric-label">Uptime</span>
                <span class="metric-value" id="md-uptime">0m</span>
              </div>
              <div class="metric">
                <span class="metric-label">Status</span>
                <span class="metric-value" id="md-status">Active</span>
              </div>
            </div>
          </div>
        </div>
      </div>
      
      <div id="alerts" class="dashboard-tab">
        <h2>Alert History</h2>
        <div class="alert-filters">
          <select id="alert-level-filter">
            <option value="all">All Levels</option>
            <option value="critical">Critical</option>
            <option value="warning">Warning</option>
            <option value="info">Info</option>
          </select>
          <button id="clear-alerts">Clear Resolved</button>
        </div>
        <div class="alerts-container">
          <div id="alerts-list">
            <div class="alert-placeholder">No alerts to display</div>
          </div>
        </div>
      </div>
    </main>
  </div>
  
  <footer>
    <div>cFish.io Monitoring System v1.0.0</div>
    <div id="last-update">Last update: Never</div>
  </footer>
  
  <script src="/dashboard.js"></script>
</body>
</html>`;
}

// Dashboard CSS styles
function dashboardStyles() {
  return `/* cFish.io Monitoring Dashboard Styles */
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Open Sans', 'Helvetica Neue', sans-serif;
}

:root {
  --primary-color: #2c3e50;
  --secondary-color: #3498db;
  --accent-color: #e74c3c;
  --success-color: #2ecc71;
  --warning-color: #f39c12;
  --critical-color: #e74c3c;
  --unknown-color: #95a5a6;
  --bg-color: #f5f7fa;
  --card-bg: #ffffff;
  --text-color: #333333;
  --border-color: #e0e0e0;
}

body {
  background-color: var(--bg-color);
  color: var(--text-color);
  line-height: 1.6;
}

header {
  background-color: var(--primary-color);
  color: white;
  padding: 1rem 2rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

header h1 {
  font-size: 1.5rem;
  font-weight: 500;
}

.refresh-info {
  display: flex;
  align-items: center;
  gap: 1rem;
}

button {
  background-color: var(--secondary-color);
  color: white;
  border: none;
  padding: 0.5rem 1rem;
  border-radius: 4px;
  cursor: pointer;
  transition: background-color 0.3s;
}

button:hover {
  background-color: #2980b9;
}

.dashboard-container {
  display: flex;
  height: calc(100vh - 120px);
}

.sidebar {
  width: 250px;
  background-color: var(--card-bg);
  border-right: 1px solid var(--border-color);
  display: flex;
  flex-direction: column;
}

.sidebar nav ul {
  list-style: none;
  margin-top: 1rem;
}

.sidebar nav ul li a {
  display: block;
  padding: 0.75rem 1.5rem;
  color: var(--text-color);
  text-decoration: none;
  transition: background-color 0.3s;
}

.sidebar nav ul li a:hover, 
.sidebar nav ul li a.active {
  background-color: rgba(52, 152, 219, 0.1);
  color: var(--secondary-color);
  border-left: 3px solid var(--secondary-color);
}

.system-summary {
  margin-top: auto;
  padding: 1rem;
  border-top: 1px solid var(--border-color);
}

.system-summary h3 {
  margin-bottom: 0.5rem;
}

.content {
  flex: 1;
  padding: 1.5rem;
  overflow-y: auto;
}

.dashboard-tab {
  display: none;
}

.dashboard-tab.active {
  display: block;
}

.dashboard-tab h2 {
  margin-bottom: 1.5rem;
  color: var(--primary-color);
}

.metrics-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 1.5rem;
}

.metric-card {
  background-color: var(--card-bg);
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  padding: 1.5rem;
}

.metric-card h3 {
  margin-bottom: 1rem;
  color: var(--primary-color);
}

.gauge-container {
  display: flex;
  justify-content: center;
  margin-bottom: 1rem;
}

.metric-details {
  font-size: 0.9rem;
  color: #666;
}

.search-filter {
  display: flex;
  gap: 1rem;
  margin-bottom: 1rem;
}

.search-filter input, 
.search-filter select {
  padding: 0.5rem;
  border: 1px solid var(--border-color);
  border-radius: 4px;
}

.search-filter input {
  flex: 1;
}

.process-stats {
  display: flex;
  justify-content: space-between;
  margin-bottom: 1rem;
}

.stat-box {
  background-color: var(--card-bg);
  padding: 1rem;
  border-radius: 4px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  display: flex;
  flex-direction: column;
  align-items: center;
  width: calc(25% - 0.75rem);
}

.stat-label {
  font-size: 0.85rem;
  color: #666;
}

.stat-value {
  font-size: 1.5rem;
  font-weight: bold;
  color: var(--primary-color);
}

.table-container {
  background-color: var(--card-bg);
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  overflow: hidden;
}

table {
  width: 100%;
  border-collapse: collapse;
}

table th {
  background-color: #f8f9fa;
  text-align: left;
  padding: 0.75rem 1rem;
  font-weight: 500;
  color: var(--primary-color);
  border-bottom: 1px solid var(--border-color);
}

table td {
  padding: 0.75rem 1rem;
  border-bottom: 1px solid var(--border-color);
}

table tr:last-child td {
  border-bottom: none;
}

.apps-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 1.5rem;
}

.app-card {
  position: relative;
  background-color: var(--card-bg);
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  padding: 1.5rem;
}

.app-card h3 {
  margin-bottom: 1.5rem;
  color: var(--primary-color);
}

.status-indicator {
  position: absolute;
  top: 1.5rem;
  right: 1.5rem;
  width: 12px;
  height: 12px;
  border-radius: 50%;
}

.status-indicator[data-status="active"] {
  background-color: var(--success-color);
  box-shadow: 0 0 6px var(--success-color);
}

.status-indicator[data-status="warning"] {
  background-color: var(--warning-color);
  box-shadow: 0 0 6px var(--warning-color);
}

.status-indicator[data-status="critical"] {
  background-color: var(--critical-color);
  box-shadow: 0 0 6px var(--critical-color);
}

.status-indicator[data-status="unknown"] {
  background-color: var(--unknown-color);
}

.app-metrics {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.metric {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.metric-label {
  color: #666;
}

.metric-value {
  font-weight: 500;
}

.alert-filters {
  display: flex;
  justify-content: space-between;
  margin-bottom: 1rem;
}

.alerts-container {
  background-color: var(--card-bg);
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  padding: 1rem;
  max-height: 500px;
  overflow-y: auto;
}

.alert-item {
  padding: 1rem;
  margin-bottom: 0.75rem;
  border-radius: 4px;
  border-left: 4px solid;
}

.alert-item:last-child {
  margin-bottom: 0;
}

.alert-item.critical {
  background-color: rgba(231, 76, 60, 0.1);
  border-left-color: var(--critical-color);
}

.alert-item.warning {
  background-color: rgba(243, 156, 18, 0.1);
  border-left-color: var(--warning-color);
}

.alert-item.info {
  background-color: rgba(52, 152, 219, 0.1);
  border-left-color: var(--secondary-color);
}

.alert-header {
  display: flex;
  justify-content: space-between;
  margin-bottom: 0.5rem;
}

.alert-level {
  font-weight: bold;
}

.alert-timestamp {
  font-size: 0.85rem;
  color: #666;
}

.alert-message {
  margin-bottom: 0.5rem;
}

.alert-placeholder {
  text-align: center;
  color: #666;
  padding: 2rem;
}

footer {
  background-color: var(--primary-color);
  color: rgba(255, 255, 255, 0.7);
  padding: 1rem 2rem;
  font-size: 0.85rem;
  display: flex;
  justify-content: space-between;
}

/* Responsive adjustments */
@media (max-width: 1024px) {
  .dashboard-container {
    flex-direction: column;
    height: auto;
  }
  
  .sidebar {
    width: 100%;
    flex-direction: row;
    justify-content: space-between;
    align-items: center;
  }
  
  .sidebar nav ul {
    display: flex;
    margin: 0;
  }
  
  .sidebar nav ul li a {
    padding: 0.75rem 1rem;
  }
  
  .system-summary {
    display: none;
  }
}

@media (max-width: 768px) {
  .process-stats {
    flex-wrap: wrap;
    gap: 1rem;
  }
  
  .stat-box {
    width: calc(50% - 0.5rem);
  }
  
  header {
    flex-direction: column;
    align-items: flex-start;
    gap: 0.5rem;
  }
  
  .refresh-info {
    width: 100%;
    justify-content: space-between;
  }
  
  .metrics-grid, .apps-grid {
    grid-template-columns: 1fr;
  }
}`;
}

// Dashboard JavaScript
function dashboardJavaScript(refreshInterval) {
  return `// cFish.io Monitoring Dashboard JavaScript
document.addEventListener('DOMContentLoaded', function() {
  // Dashboard tab switching
  const tabs = document.querySelectorAll('.sidebar nav ul li a');
  const tabContents = document.querySelectorAll('.dashboard-tab');
  
  tabs.forEach(tab => {
    tab.addEventListener('click', function(e) {
      e.preventDefault();
      
      // Remove active class from all tabs and content
      tabs.forEach(t => t.classList.remove('active'));
      tabContents.forEach(c => c.classList.remove('active'));
      
      // Add active class to clicked tab and corresponding content
      this.classList.add('active');
      const target = this.getAttribute('href').substring(1);
      document.getElementById(target).classList.add('active');
    });
  });
  
  // Auto-refresh countdown
  let countdown = ${refreshInterval};
  const countdownElement = document.getElementById('refresh-countdown');
  
  function updateCountdown() {
    countdown--;
    countdownElement.textContent = countdown;
    
    if (countdown <= 0) {
      fetchMetrics();
      countdown = ${refreshInterval};
    }
  }
  
  setInterval(updateCountdown, 1000);
  
  // Manual refresh button
  document.getElementById('manual-refresh').addEventListener('click', function() {
    fetchMetrics();
    countdown = ${refreshInterval};
    countdownElement.textContent = countdown;
  });
  
  // Dashboard uptime tracking
  let startTime = new Date();
  
  function updateUptime() {
    const now = new Date();
    const diff = Math.floor((now - startTime) / 1000);
    
    let uptime = '';
    const hours = Math.floor(diff / 3600);
    const minutes = Math.floor((diff % 3600) / 60);
    
    if (hours > 0) {
      uptime = \`\${hours}h \${minutes}m\`;
    } else {
      uptime = \`\${minutes}m\`;
    }
    
    document.getElementById('md-uptime').textContent = uptime;
  }
  
  setInterval(updateUptime, 60000);
  updateUptime();
  
  // Dashboard gauges
  function createGauge(canvasId, value, maxValue, colors) {
    const canvas = document.getElementById(canvasId);
    if (!canvas) return;
    
    const ctx = canvas.getContext('2d');
    const width = canvas.width;
    const height = canvas.height;
    const radius = Math.min(width, height) / 2 * 0.8;
    const centerX = width / 2;
    const centerY = height / 2;
    const startAngle = Math.PI * 0.8;
    const endAngle = Math.PI * 2.2;
    const totalAngle = endAngle - startAngle;
    
    // Clear canvas
    ctx.clearRect(0, 0, width, height);
    
    // Draw background arc
    ctx.beginPath();
    ctx.arc(centerX, centerY, radius, startAngle, endAngle);
    ctx.lineWidth = 15;
    ctx.strokeStyle = '#e0e0e0';
    ctx.stroke();
    
    // Calculate color based on value
    let color;
    const percentage = value / maxValue;
    
    if (percentage <= 0.6) {
      color = colors.good;
    } else if (percentage <= 0.8) {
      color = colors.warning;
    } else {
      color = colors.critical;
    }
    
    // Draw value arc
    const valueAngle = startAngle + totalAngle * (percentage);
    
    ctx.beginPath();
    ctx.arc(centerX, centerY, radius, startAngle, valueAngle);
    ctx.lineWidth = 15;
    ctx.strokeStyle = color;
    ctx.stroke();
    
    // Draw center text
    ctx.fillStyle = '#333';
    ctx.font = 'bold 24px Arial';
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';
    ctx.fillText(\`\${Math.round(value)}%\`, centerX, centerY);
  }
  
  // Process table filtering
  const processSearch = document.getElementById('process-search');
  const processFilter = document.getElementById('process-filter');
  
  if (processSearch && processFilter) {
    processSearch.addEventListener('input', filterProcessTable);
    processFilter.addEventListener('change', filterProcessTable);
  }
  
  function filterProcessTable() {
    const searchTerm = processSearch.value.toLowerCase();
    const filterType = processFilter.value;
    const rows = document.querySelectorAll('#process-list tr');
    
    rows.forEach(row => {
      const name = row.querySelector('td:first-child')?.textContent.toLowerCase() || '';
      const type = row.querySelector('td:nth-child(5)')?.textContent.toLowerCase() || '';
      
      const matchesSearch = name.includes(searchTerm);
      const matchesFilter = filterType === 'all' || type === filterType;
      
      row.style.display = matchesSearch && matchesFilter ? '' : 'none';
    });
  }
  
  // Alert level filtering
  const alertLevelFilter = document.getElementById('alert-level-filter');
  
  if (alertLevelFilter) {
    alertLevelFilter.addEventListener('change', filterAlerts);
  }
  
  function filterAlerts() {
    const filterLevel = alertLevelFilter.value;
    const alerts = document.querySelectorAll('.alert-item');
    
    alerts.forEach(alert => {
      if (filterLevel === 'all' || alert.classList.contains(filterLevel)) {
        alert.style.display = '';
      } else {
        alert.style.display = 'none';
      }
    });
  }
  
  // Clear resolved alerts button
  const clearAlertsButton = document.getElementById('clear-alerts');
  
  if (clearAlertsButton) {
    clearAlertsButton.addEventListener('click', function() {
      const alerts = document.querySelectorAll('.alert-item.resolved');
      alerts.forEach(alert => alert.remove());
      
      const alertsList = document.getElementById('alerts-list');
      if (alertsList.children.length === 0) {
        alertsList.innerHTML = '<div class="alert-placeholder">No alerts to display</div>';
      }
    });
  }
  
  // Fetch and update metrics
  function fetchMetrics() {
    fetch('/metrics')
      .then(response => {
        if (!response.ok) {
          throw new Error(\`HTTP error! Status: \${response.status}\`);
        }
        return response.json();
      })
      .then(data => {
        updateDashboard(data);
        document.getElementById('last-update').textContent = \`Last update: \${new Date().toLocaleTimeString()}\`;
      })
      .catch(error => {
        console.error('Error fetching metrics:', error);
      });
  }
  
  function updateDashboard(data) {
    // Update system metrics
    updateSystemMetrics(data.SystemMetrics);
    
    // Update process metrics
    updateProcessMetrics(data.ProcessMetrics);
    
    // Update application metrics
    updateApplicationMetrics(data.ApplicationMetrics);
    
    // Update alerts
    updateAlerts(data.AlertHistory);
    
    // Update system summary
    updateSystemSummary(data);
  }
  
  function updateSystemMetrics(metrics) {
    // Memory gauge
    createGauge('memory-gauge', metrics.Memory.UsedPercent, 100, {
      good: '#2ecc71',
      warning: '#f39c12',
      critical: '#e74c3c'
    });
    
    // Memory details
    document.getElementById('memory-details').innerHTML = \`
      <div>Total: \${metrics.Memory.Total.toFixed(2)} MB</div>
      <div>Used: \${metrics.Memory.Used.toFixed(2)} MB (\${metrics.Memory.UsedPercent.toFixed(1)}%)</div>
      <div>Available: \${metrics.Memory.Available.toFixed(2)} MB</div>
    \`;
    
    // CPU gauge
    createGauge('cpu-gauge', metrics.CPU.LoadPercent, 100, {
      good: '#2ecc71',
      warning: '#f39c12',
      critical: '#e74c3c'
    });
    
    // CPU details
    document.getElementById('cpu-details').innerHTML = \`
      <div>Load: \${metrics.CPU.LoadPercent.toFixed(1)}%</div>
    \`;
    
    // Disk gauge
    createGauge('disk-gauge', metrics.Disk.UsedPercent, 100, {
      good: '#2ecc71',
      warning: '#f39c12',
      critical: '#e74c3c'
    });
    
    // Disk details
    document.getElementById('disk-details').innerHTML = \`
      <div>Total: \${metrics.Disk.Total.toFixed(2)} GB</div>
      <div>Used: \${metrics.Disk.Used.toFixed(2)} GB (\${metrics.Disk.UsedPercent.toFixed(1)}%)</div>
      <div>Available: \${metrics.Disk.Available.toFixed(2)} GB</div>
    \`;
    
    // Network details
    const kbSent = (metrics.Network.BytesSent / 1024).toFixed(2);
    const kbReceived = (metrics.Network.BytesReceived / 1024).toFixed(2);
    
    document.getElementById('network-details').innerHTML = \`
      <div>Sent: \${kbSent} KB</div>
      <div>Received: \${kbReceived} KB</div>
      <div>Connections: \${metrics.Network.ConnectionCount}</div>
    \`;
  }
  
  function updateProcessMetrics(metrics) {
    // Update process counts
    document.getElementById('total-processes').textContent = metrics.TotalCount;
    document.getElementById('cursor-processes').textContent = metrics.CursorCount;
    document.getElementById('node-processes').textContent = metrics.NodeCount;
    document.getElementById('high-memory-processes').textContent = metrics.HighMemoryCount;
    
    // Update process table
    const processList = document.getElementById('process-list');
    
    if (metrics.ProcessList && metrics.ProcessList.length > 0) {
      let tableHtml = '';
      
      metrics.ProcessList.forEach(process => {
        tableHtml += \`
          <tr>
            <td>\${process.Name}</td>
            <td>\${process.Id}</td>
            <td>\${process.MemoryMB.toFixed(2)}</td>
            <td>\${process.CPU ? process.CPU.toFixed(1) : '0.0'}</td>
            <td>\${process.Type}</td>
          </tr>
        \`;
      });
      
      processList.innerHTML = tableHtml;
    } else {
      processList.innerHTML = '<tr><td colspan="5">No process data available</td></tr>';
    }
    
    // Re-apply filtering if active
    if (processSearch.value || processFilter.value !== 'all') {
      filterProcessTable();
    }
  }
  
  function updateApplicationMetrics(metrics) {
    // For demo purposes, we'll use placeholder data if not available
    // In a real implementation, this would use actual component metrics
    
    // Process Tree Visualization Component
    document.querySelector('#process-tree-card .status-indicator').setAttribute('data-status', 'active');
    document.getElementById('pt-render-time').textContent = '15 ms';
    document.getElementById('pt-memory').textContent = '85 MB';
    document.getElementById('pt-status').textContent = 'Running';
    
    // Alert Correlation Engine
    document.querySelector('#alert-engine-card .status-indicator').setAttribute('data-status', 'active');
    document.getElementById('ae-latency').textContent = '0.5 s';
    document.getElementById('ae-accuracy').textContent = '99.7%';
    document.getElementById('ae-status').textContent = 'Running';
    
    // Queue Priority System
    document.querySelector('#queue-system-card .status-indicator').setAttribute('data-status', 'active');
    document.getElementById('qs-queue-length').textContent = '12';
    document.getElementById('qs-throughput').textContent = '1250 ops/s';
    document.getElementById('qs-status').textContent = 'Running';
  }
  
  function updateAlerts(alerts) {
    const alertsList = document.getElementById('alerts-list');
    
    if (alerts && alerts.length > 0) {
      let alertsHtml = '';
      
      alerts.forEach(alert => {
        const level = alert.Level.toLowerCase();
        const timestamp = new Date(alert.Timestamp).toLocaleTimeString();
        
        alertsHtml += \`
          <div class="alert-item \${level}">
            <div class="alert-header">
              <span class="alert-level">\${alert.Level}</span>
              <span class="alert-timestamp">\${timestamp}</span>
            </div>
            <div class="alert-message">\${alert.Message}</div>
          </div>
        \`;
      });
      
      alertsList.innerHTML = alertsHtml;
    } else {
      alertsList.innerHTML = '<div class="alert-placeholder">No alerts to display</div>';
    }
    
    // Re-apply filtering if active
    if (alertLevelFilter.value !== 'all') {
      filterAlerts();
    }
  }
  
  function updateSystemSummary(data) {
    const memory = data.SystemMetrics.Memory;
    const cpu = data.SystemMetrics.CPU;
    const processes = data.ProcessMetrics;
    
    document.getElementById('summary-data').innerHTML = \`
      <div>Memory: \${memory.UsedPercent.toFixed(1)}%</div>
      <div>CPU: \${cpu.LoadPercent.toFixed(1)}%</div>
      <div>Processes: \${processes.TotalCount}</div>
      <div>Alerts: \${data.AlertHistory ? data.AlertHistory.length : 0}</div>
    \`;
  }
  
  // Initial load
  fetchMetrics();
});`;
} 