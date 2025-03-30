/**
 * Memory Optimization Test Script
 * 
 * This script tests the memory optimization implementation
 * to verify that it properly handles memory usage and prevents leaks.
 * 
 * @package cFish.io
 * @since 1.0.0
 * @author tY FischEYe
 */

const OptimizedMdJsonSync = require('../core/optimized-tydisync');
const fs = require('fs');
const path = require('path');
const os = require('os');

// Create test directory
const TEST_DIR = path.join(__dirname, 'memory-test');
const MD_DIR = path.join(TEST_DIR, 'md');
const JSON_DIR = path.join(TEST_DIR, 'json');
const LOG_DIR = path.join(TEST_DIR, 'logs');
const STATE_DIR = path.join(TEST_DIR, 'state');

// Create test directories
[TEST_DIR, MD_DIR, JSON_DIR, LOG_DIR, STATE_DIR].forEach(dir => {
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
});

// Configuration for memory test
const config = {
  watchDirectories: {
    markdown: [MD_DIR],
    json: [JSON_DIR]
  },
  exclusions: [],
  memoryWarningThreshold: 50, // Lower threshold for testing
  memoryCriticalThreshold: 70, // Lower threshold for testing
  memoryCheckInterval: 2000, // More frequent checking
  enableAutoGC: true,
  stateDirectory: STATE_DIR,
  logDirectory: LOG_DIR,
  performanceSettings: {
    batchProcessingEnabled: true,
    batchSize: 2, // Small batch size for testing
    batchTimeout: 1000,
    throttlingEnabled: true,
    maxConcurrentTasks: 1, // Just one task at a time for testing
    throttleDelay: 500
  }
};

// Progress indicator
let interval;
const startProgress = () => {
  let count = 0;
  const spinners = ['|', '/', '-', '\\'];
  interval = setInterval(() => {
    process.stdout.write(`\r${spinners[count % 4]} Running memory test...`);
    count++;
  }, 100);
};

const stopProgress = () => {
  clearInterval(interval);
  console.log('\nTest completed!');
};

// Create test files
const createTestFiles = (count = 10, size = 100) => {
  console.log(`Creating ${count} test Markdown files (approx. ${size}KB each)...`);
  
  for (let i = 0; i < count; i++) {
    const content = generateMdContent(i, size);
    const filePath = path.join(MD_DIR, `test-file-${i}.md`);
    fs.writeFileSync(filePath, content, 'utf8');
  }
  
  console.log('Test files created.');
};

// Generate markdown content of specified size
const generateMdContent = (index, sizeKB) => {
  // Create header
  let content = `---
title: Test File ${index}
created: ${new Date().toISOString()}
version: 1.0
test: true
---

# Test File ${index}

This is a test file generated for memory optimization testing.

`;

  // Add sections to reach the target size
  const targetBytes = sizeKB * 1024;
  const sectionSize = 500; // bytes per section
  const sectionsNeeded = Math.ceil((targetBytes - content.length) / sectionSize);
  
  for (let i = 0; i < sectionsNeeded; i++) {
    content += `
## Section ${i + 1}

This is test content for section ${i + 1}. This paragraph is designed to take up space
in the file to test memory handling capabilities of the MD-JSON sync system.

- Item 1: Testing memory allocation
- Item 2: Testing garbage collection
- Item 3: Testing file processing limits

The purpose of this test is to ensure the system can handle files of various sizes
without experiencing memory leaks or crashes that were occurring in the original implementation.

`;
  }
  
  return content;
};

// Run memory test
const runMemoryTest = async () => {
  console.log('Starting memory optimization test...');
  console.log('System memory:', formatMemory(os.totalmem()));
  console.log('Free memory:', formatMemory(os.freemem()));
  console.log('');
  
  // Create test files
  createTestFiles(20, 200); // 20 files of 200KB each
  
  // Initialize the sync system
  console.log('Initializing optimized MD-JSON sync system...');
  const syncSystem = new OptimizedMdJsonSync(config);
  
  // Start the sync system
  console.log('Starting sync system...');
  syncSystem.start();
  
  // Display initial memory usage
  console.log('Initial process memory usage:', formatMemory(process.memoryUsage().heapUsed));
  
  // Start progress indicator
  startProgress();
  
  // Wait for initial sync to complete
  await sleep(5000);
  
  // Make file changes to trigger processing
  for (let round = 0; round < 3; round++) {
    stopProgress();
    console.log(`\nRound ${round + 1}: Making changes to test files...`);
    console.log('Current memory usage:', formatMemory(process.memoryUsage().heapUsed));
    
    // Modify some files
    for (let i = 0; i < 10; i++) {
      const fileIndex = Math.floor(Math.random() * 20);
      const filePath = path.join(MD_DIR, `test-file-${fileIndex}.md`);
      
      if (fs.existsSync(filePath)) {
        let content = fs.readFileSync(filePath, 'utf8');
        content += `\n\n## Updated Section (${new Date().toISOString()})\n\nThis content was added during round ${round + 1} of testing.\n`;
        fs.writeFileSync(filePath, content, 'utf8');
        console.log(`  Modified test-file-${fileIndex}.md`);
      }
    }
    
    // Wait for processing to complete
    console.log('Waiting for sync system to process changes...');
    startProgress();
    await sleep(8000);
  }
  
  // Check JSON files were created
  stopProgress();
  console.log('\nChecking JSON files were created...');
  const jsonFiles = fs.readdirSync(JSON_DIR);
  console.log(`Found ${jsonFiles.length} JSON files.`);
  
  // Check memory usage after processing
  const finalMemory = process.memoryUsage();
  console.log('Final process memory usage:', formatMemory(finalMemory.heapUsed));
  console.log('Final RSS:', formatMemory(finalMemory.rss));
  
  // Check for memory leaks
  if (finalMemory.heapUsed > 200 * 1024 * 1024) {
    console.log('⚠️ WARNING: Memory usage is high, possible memory leak detected.');
  } else {
    console.log('✅ Memory usage is within acceptable limits.');
  }
  
  // Stop the sync system
  console.log('Stopping sync system...');
  syncSystem.stop();
  
  // Clean up test files
  if (process.argv.includes('--cleanup')) {
    console.log('Cleaning up test files...');
    fs.rmSync(TEST_DIR, { recursive: true, force: true });
  } else {
    console.log('Test files remain in:', TEST_DIR);
    console.log('Run with --cleanup to remove test files.');
  }
  
  console.log('\nMemory test completed!');
};

// Helper functions
const formatMemory = (bytes) => {
  return `${Math.round(bytes / (1024 * 1024))} MB`;
};

const sleep = (ms) => {
  return new Promise(resolve => setTimeout(resolve, ms));
};

// Run the test
runMemoryTest().catch(error => {
  console.error('Error running memory test:', error);
}); 