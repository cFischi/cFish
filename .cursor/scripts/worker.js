const { parentPort } = require('worker_threads');

// Simulate CPU-intensive work
function simulateWork() {
  const iterations = 1000000;
  let result = 0;
  
  for (let i = 0; i < iterations; i++) {
    result += Math.sqrt(i) * Math.sin(i);
  }
  
  return result;
}

// Listen for messages from the main thread
parentPort.on('message', (message) => {
  if (message === 'start') {
    const result = simulateWork();
    parentPort.postMessage({ type: 'result', value: result });
  } else if (message === 'exit') {
    process.exit(0);
  }
});

// Report ready state
parentPort.postMessage({ type: 'ready' }); 