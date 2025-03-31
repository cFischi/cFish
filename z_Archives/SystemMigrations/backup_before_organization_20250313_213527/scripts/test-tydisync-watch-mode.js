/**
 * Automated Test for tYDiSync~ Watch Mode Functionality
 * 
 * This script tests the watch mode functionality by:
 * 1. Starting tydisync in watch mode
 * 2. Creating, modifying, and deleting test files
 * 3. Verifying the correct conversion happens automatically
 * 
 * @version 1.0.0
 */

const fs = require('fs');
const path = require('path');
const { spawn } = require('child_process');
const { setTimeout } = require('timers/promises');
const os = require('os');

// Configuration
const config = {
  testDir: path.resolve(__dirname, '..', 'tydisync-test'),
  mdDir: path.resolve(__dirname, '..', 'tydisync-test', 'md'),
  jsonDir: path.resolve(__dirname, '..', 'tydisync-test', 'json'),
  watchDelay: 2000, // Time to wait for watch to detect changes (ms)
  processTimeout: 30000, // Maximum time to run the test (ms)
  testFiles: {
    md: 'watch_test.md',
    json: 'watch_test.json'
  },
  logFile: path.resolve(__dirname, '..', 'tydisync-test', 'watch_output.txt')
};

// Determine which script to use based on platform
const isWindows = os.platform() === 'win32';
const scriptCmd = isWindows ? 'cmd.exe' : 'bash';
const scriptArgs = isWindows ? 
  ['/c', 'tydisync.bat', '--watch', '--verbose'] : 
  ['./tydisync.sh', '--watch', '--verbose'];

// Ensure test directories exist
function ensureDirectories() {
  if (!fs.existsSync(config.testDir)) fs.mkdirSync(config.testDir, { recursive: true });
  if (!fs.existsSync(config.mdDir)) fs.mkdirSync(config.mdDir, { recursive: true });
  if (!fs.existsSync(config.jsonDir)) fs.mkdirSync(config.jsonDir, { recursive: true });
}

// Clean up test files
function cleanupTestFiles() {
  const mdPath = path.join(config.mdDir, config.testFiles.md);
  const jsonPath = path.join(config.jsonDir, config.testFiles.json);
  
  if (fs.existsSync(mdPath)) fs.unlinkSync(mdPath);
  if (fs.existsSync(jsonPath)) fs.unlinkSync(jsonPath);
}

// Write log message
function log(message) {
  const timestamp = new Date().toISOString();
  const logMessage = `[${timestamp}] ${message}\n`;
  
  fs.appendFileSync(config.logFile, logMessage);
  console.log(message);
}

// Start tydisync in watch mode
function startTydisync() {
  log('Starting tydisync in watch mode...');
  
  // Clear previous log
  if (fs.existsSync(config.logFile)) fs.unlinkSync(config.logFile);
  
  // Start process from the scripts directory
  const tydisync = spawn(scriptCmd, scriptArgs, {
    cwd: __dirname,
    stdio: ['ignore', 'pipe', 'pipe']
  });
  
  tydisync.stdout.on('data', (data) => {
    fs.appendFileSync(config.logFile, data.toString());
  });
  
  tydisync.stderr.on('data', (data) => {
    fs.appendFileSync(config.logFile, `ERROR: ${data.toString()}`);
  });
  
  tydisync.on('close', (code) => {
    log(`tydisync process exited with code ${code}`);
  });
  
  return tydisync;
}

// Test MD to JSON conversion
async function testMdToJsonConversion() {
  log('TEST 1: Markdown to JSON conversion');
  
  // Create test Markdown file
  const mdContent = '# Watch Test Heading\n\nThis is a test for watch mode.\n\n- Item 1\n- Item 2\n';
  const mdPath = path.join(config.mdDir, config.testFiles.md);
  fs.writeFileSync(mdPath, mdContent);
  
  log(`Created Markdown file: ${mdPath}`);
  
  // Wait for watch mode to detect and process
  await setTimeout(config.watchDelay);
  
  // Check if JSON file was created
  const jsonPath = path.join(config.jsonDir, config.testFiles.json);
  const success = fs.existsSync(jsonPath);
  
  if (success) {
    log(`PASSED: JSON file was created at ${jsonPath}`);
    return true;
  } else {
    log(`FAILED: JSON file was not created at ${jsonPath}`);
    return false;
  }
}

// Test JSON to MD conversion
async function testJsonToMdConversion() {
  log('TEST 2: JSON to Markdown conversion');
  
  // Create test JSON file
  const jsonContent = JSON.stringify({
    title: 'JSON Watch Test',
    content: 'This is a test JSON file for watch mode.',
    items: ['Test Item A', 'Test Item B']
  }, null, 2);
  
  const jsonPath = path.join(config.jsonDir, config.testFiles.json);
  fs.writeFileSync(jsonPath, jsonContent);
  
  log(`Created JSON file: ${jsonPath}`);
  
  // Wait for watch mode to detect and process
  await setTimeout(config.watchDelay);
  
  // Check if Markdown file was updated
  const mdPath = path.join(config.mdDir, config.testFiles.md);
  
  if (fs.existsSync(mdPath)) {
    const mdContent = fs.readFileSync(mdPath, 'utf8');
    // Check if content was updated - simple check for JSON content 
    const success = mdContent.includes('JSON Watch Test') || mdContent.includes('Test Item');
    
    if (success) {
      log(`PASSED: Markdown file was updated with JSON content at ${mdPath}`);
      return true;
    } else {
      log(`FAILED: Markdown file exists but content was not updated at ${mdPath}`);
      return false;
    }
  } else {
    log(`FAILED: Markdown file was not created at ${mdPath}`);
    return false;
  }
}

// Run the tests
async function runTests() {
  try {
    log('======== tYDiSync~ Watch Mode Automated Test ========');
    log(`Platform: ${os.platform()}, Using script: ${scriptArgs[0]}`);
    
    // Setup
    ensureDirectories();
    cleanupTestFiles();
    
    // Start tydisync in watch mode
    const tydisyncProcess = startTydisync();
    
    // Wait for process to fully start
    await setTimeout(2000);
    
    // Run test 1: MD to JSON
    const test1Result = await testMdToJsonConversion();
    
    // Run test 2: JSON to MD
    const test2Result = await testJsonToMdConversion();
    
    // Kill the tydisync process
    tydisyncProcess.kill();
    
    // Summary
    log('\n======== Test Results ========');
    log(`Test 1 (MD to JSON): ${test1Result ? 'PASSED' : 'FAILED'}`);
    log(`Test 2 (JSON to MD): ${test2Result ? 'PASSED' : 'FAILED'}`);
    
    if (test1Result && test2Result) {
      log('ALL TESTS PASSED! Watch mode is working correctly.');
      return true;
    } else {
      log('SOME TESTS FAILED. Watch mode needs investigation.');
      return false;
    }
  } catch (error) {
    log(`ERROR: ${error.message}`);
    return false;
  } finally {
    // Cleanup
    log('Cleaning up test files...');
    cleanupTestFiles();
  }
}

// Set a timeout to ensure the test doesn't run forever
const timeout = setTimeout(() => {
  log('ERROR: Test timed out after ' + (config.processTimeout / 1000) + ' seconds');
  process.exit(1);
}, config.processTimeout);

// Run the tests and exit
runTests().then(success => {
  clearTimeout(timeout);
  process.exit(success ? 0 : 1);
}); 