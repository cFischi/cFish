const { EnhancedResourceMonitor } = require('./enhanced-resource-monitor');

async function testMonitor() {
  const monitor = new EnhancedResourceMonitor({
    warningThreshold: 70,
    criticalThreshold: 80,
    updateInterval: 2000,
    processCheckInterval: 3000
  });

  // Event handlers
  monitor.on('update', (metrics) => {
    console.log('\nResource Metrics Update:');
    console.log('Memory Usage:', metrics.memory.toFixed(2) + '%');
    console.log('CPU Usage:', metrics.cpu.toFixed(2) + '%');
    console.log('Total Memory:', metrics.total.total);
    console.log('Used Memory:', metrics.total.used);
    console.log('Process Stats:', metrics.processes);
  });

  monitor.on('warning', (warning) => {
    console.log('\nWarning:', warning);
  });

  monitor.on('processStarted', (process) => {
    console.log('\nNew Process Started:', process);
  });

  monitor.on('processClosed', ({ pid, process }) => {
    console.log('\nProcess Terminated:', { pid, process });
  });

  // Start monitoring
  await monitor.start();

  // Test process monitoring
  console.log('\nGetting initial process list...');
  const processes = await monitor.getProcessList();
  console.log('Total processes:', processes.length);

  // Run for 30 seconds
  console.log('\nMonitoring for 30 seconds...');
  await new Promise(resolve => setTimeout(resolve, 30000));

  // Test process killing (example with notepad)
  if (process.platform === 'win32') {
    const { spawn } = require('child_process');
    console.log('\nLaunching notepad for kill test...');
    spawn('notepad.exe');
    
    // Wait 5 seconds
    await new Promise(resolve => setTimeout(resolve, 5000));
    
    console.log('Attempting to kill notepad processes...');
    const killed = await monitor.killProcessesByName('notepad.exe');
    console.log('Killed processes:', killed);
  }

  // Stop monitoring
  console.log('\nStopping monitor...');
  await monitor.stop();
}

// Run the test
testMonitor().catch(console.error); 