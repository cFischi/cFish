/**
 * Test Script for Memory Optimization
 * 
 * This script tests the memory optimization features by:
 * 1. Creating large test files to process
 * 2. Monitoring memory usage during processing
 * 3. Validating the results of optimized processing
 */

const fs = require('fs');
const path = require('path');
const { EnhancedMdJsonSync } = require('./memory-optimization-integration');
const { MemoryMonitor } = require('./memory-optimization');

// Configuration
const TEST_DIR = './test-data';
const LARGE_FILE_SIZE_MB = 50; // Size of test file in MB
const MEMORY_LOG_INTERVAL_MS = 2000; // How often to log memory usage

// Ensure test directory exists
if (!fs.existsSync(TEST_DIR)) {
  fs.mkdirSync(TEST_DIR, { recursive: true });
}
if (!fs.existsSync(path.join(TEST_DIR, 'json'))) {
  fs.mkdirSync(path.join(TEST_DIR, 'json'), { recursive: true });
}

/**
 * Create a large Markdown test file
 * @param {string} filePath Path where to create the file
 * @param {number} sizeMB Approximate size in MB
 */
function createLargeMarkdownFile(filePath, sizeMB) {
  console.log(`Creating large Markdown test file (${sizeMB}MB) at ${filePath}...`);
  
  const fd = fs.openSync(filePath, 'w');
  
  // Write the file header
  fs.writeSync(fd, '---\n');
  fs.writeSync(fd, 'title: Large Test File\n');
  fs.writeSync(fd, 'author: Memory Test Script\n');
  fs.writeSync(fd, 'date: ' + new Date().toISOString() + '\n');
  fs.writeSync(fd, 'size: ' + sizeMB + 'MB\n');
  fs.writeSync(fd, '---\n\n');
  
  // Write title
  fs.writeSync(fd, '# Large Test File\n\n');
  
  // Calculate how many sections we need to reach the target size
  // Each section will be about 10KB
  const sectionSizeKB = 10;
  const sectionCount = Math.ceil((sizeMB * 1024) / sectionSizeKB);
  
  console.log(`Generating ${sectionCount} sections...`);
  
  for (let i = 0; i < sectionCount; i++) {
    // Section header
    fs.writeSync(fd, `## Section ${i + 1}\n\n`);
    
    // Generate paragraphs for this section
    for (let j = 0; j < 5; j++) {
      let paragraph = `This is paragraph ${j + 1} in section ${i + 1}. `;
      
      // Add some random text to the paragraph
      for (let k = 0; k < 20; k++) {
        paragraph += `Sentence ${k + 1} with some random words like `;
        paragraph += `memory optimization stream chunk buffer process `;
        paragraph += `Node.js JavaScript JSON Markdown synchronization. `;
      }
      
      fs.writeSync(fd, paragraph + '\n\n');
    }
    
    // Add a subsection
    fs.writeSync(fd, `### Subsection ${i + 1}.1\n\n`);
    
    // Generate list items
    fs.writeSync(fd, 'Here are some key points:\n\n');
    for (let j = 0; j < 10; j++) {
      fs.writeSync(fd, `- Item ${j + 1}: Some important information about memory usage and optimization techniques.\n`);
    }
    fs.writeSync(fd, '\n');
    
    // Progress indicator for large files
    if (i % Math.max(1, Math.floor(sectionCount / 20)) === 0) {
      console.log(`Progress: ${Math.round((i / sectionCount) * 100)}%`);
    }
  }
  
  fs.closeSync(fd);
  console.log(`Created ${sizeMB}MB test file at ${filePath}`);
  
  // Return file stats
  return fs.statSync(filePath);
}

/**
 * Independent memory monitoring for test purposes
 */
function startMemoryMonitoring() {
  const memoryMonitor = new MemoryMonitor({
    checkIntervalMs: MEMORY_LOG_INTERVAL_MS,
    logFunction: (message) => console.log(`[Test Monitor] ${message}`)
  });
  
  memoryMonitor.start();
  return memoryMonitor;
}

/**
 * Run the memory optimization test
 */
async function runTest() {
  console.log('=== MEMORY OPTIMIZATION TEST ===');
  console.log('Starting test at', new Date().toISOString());
  
  // Test files
  const mdFilePath = path.join(TEST_DIR, 'large-test.md');
  const jsonFilePath = path.join(TEST_DIR, 'json', 'large-test.json');
  const convertedMdFilePath = path.join(TEST_DIR, 'converted-large-test.md');
  
  try {
    // Start independent memory monitoring
    const memoryMonitor = startMemoryMonitoring();
    
    // Create a large test file
    const fileStats = createLargeMarkdownFile(mdFilePath, LARGE_FILE_SIZE_MB);
    console.log(`Test file created: ${fileStats.size} bytes (${(fileStats.size / 1024 / 1024).toFixed(2)}MB)`);
    
    // Create sync instance with memory optimization
    console.log('Creating enhanced MD-JSON sync instance...');
    const syncInstance = new EnhancedMdJsonSync({
      baseDir: TEST_DIR,
      statusFilePath: path.join(TEST_DIR, 'status.json'),
      notificationFilePath: path.join(TEST_DIR, 'notifications.json'),
      autoStartMemoryMonitor: true,
      memoryWarningThreshold: 70,
      memoryCriticalThreshold: 85,
      streamChunkSize: 128 * 1024, // 128KB chunks
      enableAutoGC: true,
      autoRestartOnCrash: true,
      logFunction: (message) => console.log(`[Sync] ${message}`)
    });
    
    // Initialize the system
    console.log('Initializing sync system...');
    await syncInstance.initialize();
    
    // Memory stats before processing
    const beforeStats = memoryMonitor.checkMemory();
    console.log(`Memory before processing: ${beforeStats.usedMb}MB / ${beforeStats.limitMb}MB (${beforeStats.usedPercent.toFixed(1)}%)`);
    
    // Test MD to JSON conversion with optimized streaming
    console.log(`\n=== TESTING MD TO JSON CONVERSION (${(fileStats.size / 1024 / 1024).toFixed(2)}MB file) ===`);
    console.log(`Converting ${mdFilePath} to ${jsonFilePath}...`);
    const startMdToJson = Date.now();
    await syncInstance.optimizedConvertMarkdownToJson(mdFilePath, jsonFilePath);
    const mdToJsonDuration = Date.now() - startMdToJson;
    console.log(`MD to JSON conversion completed in ${(mdToJsonDuration / 1000).toFixed(2)}s`);
    
    // Memory stats after MD to JSON
    const afterMdToJsonStats = memoryMonitor.checkMemory();
    console.log(`Memory after MD to JSON: ${afterMdToJsonStats.usedMb}MB / ${afterMdToJsonStats.limitMb}MB (${afterMdToJsonStats.usedPercent.toFixed(1)}%)`);
    console.log(`Memory increase: ${afterMdToJsonStats.usedMb - beforeStats.usedMb}MB`);
    
    // Validate JSON file
    const jsonStats = fs.statSync(jsonFilePath);
    console.log(`JSON file created: ${jsonStats.size} bytes (${(jsonStats.size / 1024 / 1024).toFixed(2)}MB)`);
    
    // Test JSON to MD conversion with optimized streaming
    console.log(`\n=== TESTING JSON TO MD CONVERSION (${(jsonStats.size / 1024 / 1024).toFixed(2)}MB file) ===`);
    console.log(`Converting ${jsonFilePath} to ${convertedMdFilePath}...`);
    const startJsonToMd = Date.now();
    await syncInstance.optimizedConvertJsonToMarkdown(jsonFilePath, convertedMdFilePath);
    const jsonToMdDuration = Date.now() - startJsonToMd;
    console.log(`JSON to MD conversion completed in ${(jsonToMdDuration / 1000).toFixed(2)}s`);
    
    // Memory stats after JSON to MD
    const afterJsonToMdStats = memoryMonitor.checkMemory();
    console.log(`Memory after JSON to MD: ${afterJsonToMdStats.usedMb}MB / ${afterJsonToMdStats.limitMb}MB (${afterJsonToMdStats.usedPercent.toFixed(1)}%)`);
    
    // Validate converted MD file
    const convertedMdStats = fs.statSync(convertedMdFilePath);
    console.log(`Converted MD file created: ${convertedMdStats.size} bytes (${(convertedMdStats.size / 1024 / 1024).toFixed(2)}MB)`);
    
    // Compare original and converted MD files
    console.log(`\n=== COMPARING ORIGINAL AND CONVERTED MD FILES ===`);
    const originalSize = fileStats.size;
    const convertedSize = convertedMdStats.size;
    const sizeDiff = Math.abs(originalSize - convertedSize);
    const percentDiff = (sizeDiff / originalSize) * 100;
    
    console.log(`Original size: ${originalSize} bytes`);
    console.log(`Converted size: ${convertedSize} bytes`);
    console.log(`Difference: ${sizeDiff} bytes (${percentDiff.toFixed(2)}%)`);
    
    if (percentDiff < 5) {
      console.log('✅ Files are within 5% size difference - PASSED');
    } else {
      console.log('⚠️ Files have significant size difference - WARNING');
    }
    
    // Retrieve and display memory status
    console.log(`\n=== MEMORY OPTIMIZATION STATISTICS ===`);
    const memoryStatus = syncInstance.getMemoryStatus();
    console.log(JSON.stringify(memoryStatus, null, 2));
    
    // Stop memory monitoring
    memoryMonitor.stop();
    
    // Graceful shutdown
    console.log('\nShutting down sync system...');
    await syncInstance.shutdown();
    
    console.log('\n=== TEST COMPLETED SUCCESSFULLY ===');
    console.log('Test completed at', new Date().toISOString());
    
  } catch (error) {
    console.error('❌ TEST FAILED:', error);
  }
}

// Run the test
if (require.main === module) {
  runTest().catch(console.error);
} 