const chokidar = require('chokidar');
const path = require('path');
const fs = require('fs-extra');

// Create backups directory if it doesn't exist
if (!fs.existsSync('backups')) {
  fs.mkdirSync('backups');
}

// Set memory limits
const v8 = require('v8');
v8.setFlagsFromString('--max-old-space-size=2048'); // Limit to 2GB

// Improved WordPress exclusion patterns
const ignoredPatterns = [
  '**/wp-content/**',
  '**/wp-includes/**',
  '**/wp-admin/**',
  '**/plugins/**',
  '**/themes/**',
  '**/wordpress/**',
  '**/WordPress/**',
  '**/node_modules/**',
  '**/.git/**',
  '**/vendor/**',
  '**/backup*/**',
  '**/temp/**'
];

// More conservative throttling configuration
const config = {
  maxConcurrent: 1, // Process one file at a time
  delayBetweenFiles: 2000, // 2 second delay between files
  maxQueueSize: 50,
  batchSize: 10, // Process files in smaller batches
  batchDelay: 5000 // 5 second delay between batches
};

let processingQueue = [];
let currentlyProcessing = 0;
let processedCount = 0;
let batchCount = 0;

async function processFile(filePath) {
  console.log(`[${new Date().toISOString()}] Processing file: ${filePath}`);
  // Simulate file processing
  await new Promise(resolve => setTimeout(resolve, 500));
  processedCount++;
  console.log(`[${new Date().toISOString()}] Completed processing: ${filePath} (${processedCount} files processed)`);
}

async function processQueue() {
  if (processingQueue.length === 0 || currentlyProcessing >= config.maxConcurrent) {
    return;
  }

  // Process files in batches
  if (processedCount >= config.batchSize) {
    batchCount++;
    console.log(`\nBatch ${batchCount} completed. Pausing for ${config.batchDelay}ms...\n`);
    processedCount = 0;
    await new Promise(resolve => setTimeout(resolve, config.batchDelay));
  }

  const filePath = processingQueue.shift();
  currentlyProcessing++;

  try {
    await processFile(filePath);
  } catch (error) {
    console.error(`Error processing ${filePath}:`, error);
  }

  currentlyProcessing--;
  setTimeout(processQueue, config.delayBetweenFiles);
}

function addToQueue(filePath) {
  if (processingQueue.length >= config.maxQueueSize) {
    console.log(`Queue full (${config.maxQueueSize} items), skipping file:`, filePath);
    return;
  }
  processingQueue.push(filePath);
  processQueue();
}

// Initialize watcher with improved options
const watcher = chokidar.watch('**/*.{md,json}', {
  ignored: ignoredPatterns,
  persistent: true,
  ignoreInitial: false,
  awaitWriteFinish: {
    stabilityThreshold: 2000,
    pollInterval: 100
  },
  depth: 2, // Limit directory depth
  usePolling: false, // Disable polling to reduce CPU usage
  interval: 2000, // Check for changes every 2 seconds
  binaryInterval: 3000
});

// Event handlers with timestamps
watcher
  .on('add', path => {
    console.log(`[${new Date().toISOString()}] File ${path} has been added`);
    addToQueue(path);
  })
  .on('change', path => {
    console.log(`[${new Date().toISOString()}] File ${path} has been changed`);
    addToQueue(path);
  })
  .on('unlink', path => {
    console.log(`[${new Date().toISOString()}] File ${path} has been removed`);
  })
  .on('error', error => {
    console.error(`[${new Date().toISOString()}] Error happened`, error);
  });

// Monitor memory usage
setInterval(() => {
  const used = process.memoryUsage();
  console.log('\nMemory usage:');
  for (let key in used) {
    console.log(`${key}: ${Math.round(used[key] / 1024 / 1024 * 100) / 100} MB`);
  }
  console.log(`Queue length: ${processingQueue.length}`);
  console.log(`Currently processing: ${currentlyProcessing}`);
  console.log(`Batch progress: ${processedCount}/${config.batchSize}\n`);
}, 10000);

console.log('Starting file monitoring with improved throttling...');
console.log('Ignored patterns:', ignoredPatterns);
console.log('Configuration:', config); 