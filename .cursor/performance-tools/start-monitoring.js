const MonitoringSystem = require('./monitor');
const path = require('path');
const fs = require('fs');

async function ensureDirectories() {
  const dirs = [
    path.join(__dirname, '../md'),
    path.join(__dirname, '../logs')
  ];
  
  for (const dir of dirs) {
    if (!fs.existsSync(dir)) {
      await fs.promises.mkdir(dir, { recursive: true });
    }
  }
}

async function initializeFiles() {
  const memoryPath = path.join(__dirname, '../md/memory.md');
  const changelogPath = path.join(__dirname, '../md/changelog.md');
  
  if (!fs.existsSync(memoryPath)) {
    await fs.promises.writeFile(memoryPath, '# System Performance Memory\n\n## Next Steps\n\n');
  }
  
  if (!fs.existsSync(changelogPath)) {
    await fs.promises.writeFile(changelogPath, '# System Performance Changelog\n\n');
  }
}

async function startMonitoring() {
  try {
    console.log('Initializing monitoring system...');
    
    // Ensure required directories exist
    await ensureDirectories();
    
    // Initialize memory.md and changelog.md if they don't exist
    await initializeFiles();
    
    console.log('Starting monitoring system...');
    const monitor = new MonitoringSystem();
    
    // Handle process termination
    process.on('SIGINT', async () => {
      console.log('\nGracefully shutting down...');
      await monitor.stop();
      process.exit(0);
    });
    
    process.on('uncaughtException', async (error) => {
      console.error('Uncaught Exception:', error);
      await monitor.stop();
      process.exit(1);
    });
    
    // Start monitoring
    await monitor.start();
    console.log('Monitoring system started successfully');
    
  } catch (error) {
    console.error('Failed to start monitoring system:', error);
    process.exit(1);
  }
}

// Start the monitoring system
startMonitoring().catch(console.error); 