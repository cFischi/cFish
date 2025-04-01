/**
 * tYDiSync~ Web Dashboard Server
 * 
 * This server provides API endpoints and WebSocket services for the tYDiSync~ web dashboard.
 * It integrates with PowerShell scripts for cross-platform synchronization operations.
 */

const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const path = require('path');
const { exec } = require('child_process');
const jwt = require('jsonwebtoken');
const fs = require('fs');

// Configuration
const PORT = process.env.PORT || 3000;
const JWT_SECRET = process.env.JWT_SECRET || 'tydisync-dashboard-secret';

// Platform detection
const isPowerShellCore = process.platform === 'win32' ? 'pwsh.exe' : 'pwsh';
const isPowerShell5 = process.platform === 'win32' ? 'powershell.exe' : null;
const powershellCommand = isPowerShellCore || isPowerShell5;

// Create Express app, HTTP server, and Socket.io instance
const app = express();
const server = http.createServer(app);
const io = socketIo(server, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST']
  }
});

// Middleware
app.use(express.json());
app.use(express.static(path.join(__dirname, '../build')));

// Authentication middleware
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  
  if (!token) return res.sendStatus(401);
  
  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) return res.sendStatus(403);
    req.user = user;
    next();
  });
};

// API routes
app.get('/api/status', authenticateToken, (req, res) => {
  // Execute PowerShell command to get tYDiSync~ status
  const command = `${powershellCommand} -ExecutionPolicy Bypass -Command "& {Import-Module '../../scripts/PlatformDetection.psm1'; Get-TYDiSyncStatus | ConvertTo-Json}"`;
  
  exec(command, (error, stdout, stderr) => {
    if (error) {
      console.error(`Error: ${error.message}`);
      return res.status(500).json({ error: 'Failed to get status' });
    }
    
    try {
      const status = JSON.parse(stdout);
      res.json(status);
    } catch (e) {
      console.error(`Parse error: ${e.message}`);
      res.status(500).json({ error: 'Failed to parse status data' });
    }
  });
});

app.get('/api/configuration', authenticateToken, (req, res) => {
  // Get configuration from tYDiSync~
  const command = `${powershellCommand} -ExecutionPolicy Bypass -Command "& {Import-Module '../../scripts/PlatformDetection.psm1'; Get-TYDiSyncConfiguration | ConvertTo-Json}"`;
  
  exec(command, (error, stdout, stderr) => {
    if (error) {
      console.error(`Error: ${error.message}`);
      return res.status(500).json({ error: 'Failed to get configuration' });
    }
    
    try {
      const config = JSON.parse(stdout);
      res.json(config);
    } catch (e) {
      console.error(`Parse error: ${e.message}`);
      res.status(500).json({ error: 'Failed to parse configuration data' });
    }
  });
});

app.post('/api/configuration', authenticateToken, (req, res) => {
  // Update configuration
  const config = req.body;
  const configJson = JSON.stringify(config);
  
  const command = `${powershellCommand} -ExecutionPolicy Bypass -Command "& {Import-Module '../../scripts/PlatformDetection.psm1'; Set-TYDiSyncConfiguration -ConfigJson '${configJson}'}"`;
  
  exec(command, (error, stdout, stderr) => {
    if (error) {
      console.error(`Error: ${error.message}`);
      return res.status(500).json({ error: 'Failed to update configuration' });
    }
    
    res.json({ success: true, message: 'Configuration updated successfully' });
  });
});

app.post('/api/sync/start', authenticateToken, (req, res) => {
  // Start synchronization
  const command = `${powershellCommand} -ExecutionPolicy Bypass -Command "& {Import-Module '../../scripts/PlatformDetection.psm1'; Start-TYDiSync}"`;
  
  exec(command, (error, stdout, stderr) => {
    if (error) {
      console.error(`Error: ${error.message}`);
      return res.status(500).json({ error: 'Failed to start synchronization' });
    }
    
    res.json({ success: true, message: 'Synchronization started' });
  });
});

app.post('/api/sync/stop', authenticateToken, (req, res) => {
  // Stop synchronization
  const command = `${powershellCommand} -ExecutionPolicy Bypass -Command "& {Import-Module '../../scripts/PlatformDetection.psm1'; Stop-TYDiSync}"`;
  
  exec(command, (error, stdout, stderr) => {
    if (error) {
      console.error(`Error: ${error.message}`);
      return res.status(500).json({ error: 'Failed to stop synchronization' });
    }
    
    res.json({ success: true, message: 'Synchronization stopped' });
  });
});

app.get('/api/logs', authenticateToken, (req, res) => {
  // Get logs
  const command = `${powershellCommand} -ExecutionPolicy Bypass -Command "& {Import-Module '../../scripts/PlatformDetection.psm1'; Get-TYDiSyncLogs | ConvertTo-Json -Depth 3}"`;
  
  exec(command, (error, stdout, stderr) => {
    if (error) {
      console.error(`Error: ${error.message}`);
      return res.status(500).json({ error: 'Failed to retrieve logs' });
    }
    
    try {
      const logs = JSON.parse(stdout);
      res.json(logs);
    } catch (e) {
      console.error(`Parse error: ${e.message}`);
      res.status(500).json({ error: 'Failed to parse logs data' });
    }
  });
});

// Authentication endpoint
app.post('/api/auth/login', (req, res) => {
  const { username, password } = req.body;
  
  // For demonstration - in production, use proper authentication
  if (username === 'admin' && password === 'admin') {
    const user = { username: 'admin', role: 'administrator' };
    const token = jwt.sign(user, JWT_SECRET, { expiresIn: '1h' });
    res.json({ token });
  } else {
    res.status(401).json({ error: 'Invalid credentials' });
  }
});

// Serve React app
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, '../build', 'index.html'));
});

// WebSocket for real-time updates
io.on('connection', (socket) => {
  console.log('Client connected');
  
  // Set up interval to push status updates
  const statusInterval = setInterval(() => {
    const command = `${powershellCommand} -ExecutionPolicy Bypass -Command "& {Import-Module '../../scripts/PlatformDetection.psm1'; Get-TYDiSyncStatus | ConvertTo-Json}"`;
    
    exec(command, (error, stdout, stderr) => {
      if (!error) {
        try {
          const status = JSON.parse(stdout);
          socket.emit('status_update', status);
        } catch (e) {
          console.error(`Parse error: ${e.message}`);
        }
      }
    });
  }, 5000);
  
  socket.on('disconnect', () => {
    console.log('Client disconnected');
    clearInterval(statusInterval);
  });
});

// Start server
server.listen(PORT, () => {
  console.log(`tYDiSync~ Web Dashboard server running on port ${PORT}`);
  console.log(`Using PowerShell command: ${powershellCommand}`);
  console.log(`Platform: ${process.platform}`);
});

// Handle graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM signal received: closing HTTP server');
  server.close(() => {
    console.log('HTTP server closed');
  });
});

process.on('SIGINT', () => {
  console.log('SIGINT signal received: closing HTTP server');
  server.close(() => {
    console.log('HTTP server closed');
  });
}); 