#!/usr/bin/env node

/**
 * Agent Architecture Test Script
 * 
 * This script tests the interactions between the five agents in the MD-JSON
 * synchronization system to verify proper communication and functionality.
 * 
 * @version 1.0.0
 */

// Import required modules
const fs = require('fs');
const path = require('path');
const assert = require('assert');
const EventEmitter = require('events');

// Import agents
const AlphaAgent = require('./alpha-agent');
const BetaAgent = require('./beta-agent');
const GammaAgent = require('./gamma-agent');
const DeltaAgent = require('./delta-agent');
const EpsilonAgent = require('./epsilon-agent');

// Test configuration
const config = {
  watchDirs: [
    { md: './test-data/md', json: './test-data/json' }
  ],
  backupDir: './test-data/backups',
  maxBackups: 3,
  enableBackups: true,
  debounceTime: 100, // Lower for testing
  exclusions: ['node_modules', '.git'],
  conflictResolutionMethod: 'timestamp',
  criticalFiles: ['memory.md'],
  exitWithCursor: false, // Disable for testing
  recursiveWatching: true,
  validationThreshold: 0.9,
  parentProcessCheckInterval: 1000 // Lower for testing
};

// Test event bus for monitoring interactions
const testEventBus = new EventEmitter();
let testResults = {
  totalTests: 0,
  passedTests: 0,
  failedTests: 0,
  skippedTests: 0
};

// Agent instances
let alphaAgent, betaAgent, gammaAgent, deltaAgent, epsilonAgent;

/**
 * Assert with logging
 */
function assertTest(name, condition, message) {
  testResults.totalTests++;
  try {
    assert(condition, message);
    console.log(`✅ PASS: ${name}`);
    testResults.passedTests++;
    testEventBus.emit('test-passed', { name, message });
  } catch (error) {
    console.error(`❌ FAIL: ${name} - ${error.message}`);
    testResults.failedTests++;
    testEventBus.emit('test-failed', { name, message, error });
  }
}

/**
 * Setup test directory structure
 */
async function setupTestEnvironment() {
  console.log('🔧 Setting up test environment...');
  
  // Create test directories
  const dirs = [
    './test-data',
    './test-data/md',
    './test-data/json',
    './test-data/backups'
  ];
  
  for (const dir of dirs) {
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
  }
  
  // Create test markdown file
  const testMdContent = `# Test Document
  
## Section One
This is test content for section one.

## Section Two
This is test content for section two.

_Updated 03-14-2025 | Test: Agent Architecture_
`;
  
  fs.writeFileSync('./test-data/md/test-doc.md', testMdContent);
  
  // Create test JSON file
  const testJsonContent = {
    metadata: {
      title: "Test JSON Document"
    },
    sections: [
      {
        level: 1,
        title: "JSON Test",
        content: ["This is a test JSON document."]
      },
      {
        level: 2,
        title: "JSON Section",
        content: ["This is content from a JSON file."]
      }
    ],
    lastUpdated: new Date().toISOString()
  };
  
  fs.writeFileSync(
    './test-data/json/json-test.json',
    JSON.stringify(testJsonContent, null, 2)
  );
  
  // Create test critical file
  fs.writeFileSync('./test-data/md/memory.md', '# Memory File\n\nThis is a critical test file.\n');
  
  console.log('✅ Test environment setup complete');
}

/**
 * Initialize agents for testing
 */
async function initializeAgents() {
  console.log('🚀 Initializing agents for testing...');
  
  // Initialize agents in proper order
  epsilonAgent = new EpsilonAgent(config);
  await epsilonAgent.initialize();
  
  deltaAgent = new DeltaAgent(config);
  await deltaAgent.initialize();
  
  gammaAgent = new GammaAgent(config);
  await gammaAgent.initialize();
  
  betaAgent = new BetaAgent(config);
  await betaAgent.initialize();
  
  alphaAgent = new AlphaAgent(config);
  await alphaAgent.initialize();
  
  // Setup inter-agent event handling
  setupEventHandlers();
  
  console.log('✅ All agents initialized');
}

/**
 * Setup event handlers for testing
 */
function setupEventHandlers() {
  // Alpha to Beta events
  alphaAgent.on('markdown-changed', (fileInfo) => {
    testEventBus.emit('alpha-detected-md-change', fileInfo);
  });
  
  alphaAgent.on('json-changed', (fileInfo) => {
    testEventBus.emit('alpha-detected-json-change', fileInfo);
  });
  
  // Beta events
  betaAgent.on('transformation-complete', (info) => {
    testEventBus.emit('beta-transformation-complete', info);
  });
  
  betaAgent.on('transformation-failed', (info) => {
    testEventBus.emit('beta-transformation-failed', info);
  });
  
  // Gamma events
  gammaAgent.on('merge-report', (report) => {
    testEventBus.emit('gamma-merge-report', report);
  });
  
  // Delta events (custom for testing)
  deltaAgent.on('backup-created', (info) => {
    testEventBus.emit('delta-backup-created', info);
  });
  
  // Epsilon events
  epsilonAgent.on('shutdown-requested', (info) => {
    testEventBus.emit('epsilon-shutdown-requested', info);
  });
}

/**
 * Test Alpha Agent functionality
 */
async function testAlphaAgent() {
  console.log('\n🧪 Testing Alpha Agent (File System Monitor)...');
  
  // Test file monitoring setup
  assertTest(
    'Alpha Agent Initialization',
    alphaAgent !== null && alphaAgent.watchers.length > 0,
    'Alpha Agent should initialize with active watchers'
  );
  
  // Test exclusion mechanism
  const exclusionMarker = './test-data/md/excluded-file.md.nosync';
  fs.writeFileSync(exclusionMarker, 'This file excludes excluded-file.md from synchronization');
  fs.writeFileSync('./test-data/md/excluded-file.md', '# Excluded File\n\nThis file should be excluded.\n');
  
  const isExcluded = alphaAgent.isExcluded('./test-data/md/excluded-file.md');
  assertTest(
    'Alpha Agent Exclusion Mechanism',
    isExcluded === true,
    'Files with .nosync markers should be excluded'
  );
  
  // Test file change detection
  return new Promise((resolve) => {
    let changeDetected = false;
    
    testEventBus.once('alpha-detected-md-change', (fileInfo) => {
      changeDetected = true;
      assertTest(
        'Alpha Agent Change Detection',
        fileInfo.path.includes('modified-file.md'),
        'Alpha Agent should detect file changes'
      );
      resolve();
    });
    
    // Trigger a file change
    setTimeout(() => {
      fs.writeFileSync('./test-data/md/modified-file.md', '# Modified File\n\nThis file was modified during testing.\n');
      
      // Timeout for change detection
      setTimeout(() => {
        if (!changeDetected) {
          assertTest(
            'Alpha Agent Change Detection',
            false,
            'Alpha Agent should detect file changes'
          );
          resolve();
        }
      }, 1000);
    }, 100);
  });
}

/**
 * Test Beta Agent functionality
 */
async function testBetaAgent() {
  console.log('\n🧪 Testing Beta Agent (Content Transformer)...');
  
  // Test Markdown to JSON conversion
  const mdToJsonResult = await betaAgent.markdownToJson({
    path: './test-data/md/test-doc.md',
    type: 'change'
  });
  
  assertTest(
    'Beta Agent MD to JSON Conversion',
    mdToJsonResult.success === true,
    'Beta Agent should successfully convert Markdown to JSON'
  );
  
  // Verify the generated JSON file exists
  const jsonPath = mdToJsonResult.targetPath;
  const jsonExists = fs.existsSync(jsonPath);
  
  assertTest(
    'Beta Agent JSON File Creation',
    jsonExists === true,
    'Beta Agent should create a JSON file'
  );
  
  // Test JSON to Markdown conversion
  const jsonToMdResult = await betaAgent.jsonToMarkdown({
    path: './test-data/json/json-test.json',
    type: 'change'
  });
  
  assertTest(
    'Beta Agent JSON to MD Conversion',
    jsonToMdResult.success === true,
    'Beta Agent should successfully convert JSON to Markdown'
  );
  
  // Verify the generated Markdown file exists
  const mdPath = jsonToMdResult.targetPath;
  const mdExists = fs.existsSync(mdPath);
  
  assertTest(
    'Beta Agent Markdown File Creation',
    mdExists === true,
    'Beta Agent should create a Markdown file'
  );
  
  // Test content validation
  const mdContent = fs.readFileSync('./test-data/md/test-doc.md', 'utf8');
  const jsonData = JSON.parse(fs.readFileSync(jsonPath, 'utf8'));
  
  const validationResult = betaAgent.validateTransformation(mdContent, jsonData, 'md-to-json');
  
  assertTest(
    'Beta Agent Content Validation',
    validationResult === true,
    'Beta Agent should validate content integrity'
  );
}

/**
 * Test Gamma Agent functionality
 */
async function testGammaAgent() {
  console.log('\n🧪 Testing Gamma Agent (Conflict Resolver)...');
  
  // Test conflict resolution for MD to JSON
  const mdPath = './test-data/md/test-doc.md';
  const jsonPath = betaAgent.getCorrespondingJsonPath(mdPath);
  
  // Ensure file exists
  if (!fs.existsSync(jsonPath)) {
    const jsonDir = path.dirname(jsonPath);
    if (!fs.existsSync(jsonDir)) {
      fs.mkdirSync(jsonDir, { recursive: true });
    }
    fs.writeFileSync(jsonPath, '{}');
  }
  
  // Set MD file to be newer
  const now = new Date();
  fs.utimesSync(mdPath, now, now);
  
  // Set JSON file to be older
  const pastDate = new Date(now.getTime() - 10000);
  fs.utimesSync(jsonPath, pastDate, pastDate);
  
  const shouldSyncMdToJson = await gammaAgent.shouldSynchronize({
    sourcePath: mdPath,
    targetPath: jsonPath,
    direction: 'md-to-json',
    force: false
  });
  
  assertTest(
    'Gamma Agent Timestamp Resolution (MD to JSON)',
    shouldSyncMdToJson.proceed === true && shouldSyncMdToJson.reason === 'source-newer',
    'Gamma Agent should allow synchronization when source is newer'
  );
  
  // Test conflict resolution for JSON to MD
  // Set JSON file to be newer
  fs.utimesSync(jsonPath, now, now);
  
  // Set MD file to be older
  fs.utimesSync(mdPath, pastDate, pastDate);
  
  const shouldSyncJsonToMd = await gammaAgent.shouldSynchronize({
    sourcePath: jsonPath,
    targetPath: mdPath,
    direction: 'json-to-md',
    force: false
  });
  
  assertTest(
    'Gamma Agent Timestamp Resolution (JSON to MD)',
    shouldSyncJsonToMd.proceed === true && shouldSyncJsonToMd.reason === 'source-newer',
    'Gamma Agent should allow synchronization when source is newer'
  );
  
  // Test critical file protection
  const memoryMdPath = './test-data/md/memory.md';
  const memoryJsonPath = './test-data/json/memory.json';
  
  // Create memory.json for testing
  const memoryJson = {
    sections: [{ title: "Test Section", level: 1, content: ["This is a test section."] }],
    lastUpdated: new Date().toISOString()
  };
  
  fs.writeFileSync(memoryJsonPath, JSON.stringify(memoryJson, null, 2));
  
  // Update memory.md content to be substantial
  fs.writeFileSync(memoryMdPath, '# Memory File\n\nThis is a critical test file.\n\n## Section One\nContent for section one.\n\n## Section Two\nContent for section two.\n\n_Updated 03-14-2025 | Test: Critical File_\n');
  
  // Make JSON file newer
  fs.utimesSync(memoryJsonPath, now, now);
  fs.utimesSync(memoryMdPath, pastDate, pastDate);
  
  const contentAnalysis = await gammaAgent.analyzeContentChanges(
    memoryJsonPath,
    memoryMdPath,
    'json-to-md'
  );
  
  assertTest(
    'Gamma Agent Content Analysis',
    typeof contentAnalysis === 'object' && 'dataLossRisk' in contentAnalysis,
    'Gamma Agent should perform content analysis for critical files'
  );
}

/**
 * Test Delta Agent functionality
 */
async function testDeltaAgent() {
  console.log('\n🧪 Testing Delta Agent (Safety Manager)...');
  
  // Test backup creation
  const testFilePath = './test-data/md/backup-test.md';
  fs.writeFileSync(testFilePath, '# Backup Test\n\nThis file is used to test backups.\n');
  
  const backupResult = await deltaAgent.createBackup(testFilePath);
  
  assertTest(
    'Delta Agent Backup Creation',
    backupResult.success === true && fs.existsSync(backupResult.backupPath),
    'Delta Agent should create backups successfully'
  );
  
  // Test file locking
  const lockResult = await deltaAgent.acquireLock(testFilePath, 'test-operation');
  
  assertTest(
    'Delta Agent Lock Acquisition',
    lockResult.success === true && lockResult.lockId !== undefined,
    'Delta Agent should acquire locks successfully'
  );
  
  // Test lock verification
  const lockPath = `${testFilePath}${deltaAgent.lockFileExtension}`;
  const lockExists = fs.existsSync(lockPath);
  
  assertTest(
    'Delta Agent Lock File Creation',
    lockExists === true,
    'Delta Agent should create lock files'
  );
  
  // Test lock release
  const unlockResult = await deltaAgent.releaseLock(testFilePath, lockResult.lockId);
  
  assertTest(
    'Delta Agent Lock Release',
    unlockResult.success === true && !fs.existsSync(lockPath),
    'Delta Agent should release locks successfully'
  );
  
  // Test safe operation
  const safeOpResult = await deltaAgent.safeOperation(
    {
      sourcePath: testFilePath,
      targetPath: `${testFilePath}.safe-test`,
      operationType: 'test-operation'
    },
    async () => {
      // Simple test operation - copy file
      await fs.promises.copyFile(testFilePath, `${testFilePath}.safe-test`);
      return { success: true };
    }
  );
  
  assertTest(
    'Delta Agent Safe Operation',
    safeOpResult.success === true && fs.existsSync(`${testFilePath}.safe-test`),
    'Delta Agent should perform safe operations successfully'
  );
  
  // Test protection marker creation
  const protectionResult = await deltaAgent.createProtection(
    testFilePath,
    'Test protection marker'
  );
  
  assertTest(
    'Delta Agent Protection Marker',
    protectionResult.success === true && fs.existsSync(`${testFilePath}.nosync`),
    'Delta Agent should create protection markers successfully'
  );
}

/**
 * Test Epsilon Agent functionality
 */
async function testEpsilonAgent() {
  console.log('\n🧪 Testing Epsilon Agent (Process Controller)...');
  
  // Test process ID file
  const pidFilePath = epsilonAgent.pidFilePath;
  const pidFileExists = fs.existsSync(pidFilePath);
  
  assertTest(
    'Epsilon Agent PID File',
    pidFileExists === true,
    'Epsilon Agent should create a PID file'
  );
  
  // Read PID file content
  const pidContent = fs.readFileSync(pidFilePath, 'utf8');
  const pidMatch = parseInt(pidContent.trim(), 10) === process.pid;
  
  assertTest(
    'Epsilon Agent PID Content',
    pidMatch === true,
    'Epsilon Agent should write the correct PID to the PID file'
  );
  
  // Test running instance detection
  const isRunningResult = await epsilonAgent.isProcessRunning(process.pid);
  
  assertTest(
    'Epsilon Agent Process Detection',
    isRunningResult === true,
    'Epsilon Agent should detect running processes'
  );
  
  // Test clean shutdown (don't actually shut down during test)
  let shutdownRequestCaptured = false;
  
  testEventBus.once('epsilon-shutdown-requested', () => {
    shutdownRequestCaptured = true;
  });
  
  // Simulate shutdown (but don't actually exit)
  const originalExit = process.exit;
  process.exit = () => {
    // Do nothing - just prevent actual exit
  };
  
  epsilonAgent.shutdown('test-shutdown');
  
  // Restore original exit function
  process.exit = originalExit;
  
  assertTest(
    'Epsilon Agent Shutdown Request',
    shutdownRequestCaptured === true,
    'Epsilon Agent should emit shutdown events'
  );
}

/**
 * Test agent interactions
 */
async function testAgentInteractions() {
  console.log('\n🧪 Testing Agent Interactions...');
  
  // Create a test file for triggering interactions
  const interactionTestFile = './test-data/md/interaction-test.md';
  fs.writeFileSync(interactionTestFile, '# Interaction Test\n\nThis file tests agent interactions.\n');
  
  // Set up event listeners for interactions
  let detectedByAlpha = false;
  let transformedByBeta = false;
  
  return new Promise((resolve) => {
    // Set up a timeout to fail the test if events aren't received
    const timeout = setTimeout(() => {
      assertTest(
        'Full Agent Interaction Chain',
        false,
        'All agents should process the file change in sequence'
      );
      resolve();
    }, 2000);
    
    // Listen for Alpha detection
    testEventBus.once('alpha-detected-md-change', (fileInfo) => {
      if (fileInfo.path.includes('interaction-test.md')) {
        detectedByAlpha = true;
        console.log('✓ Alpha Agent detected the file change');
      }
    });
    
    // Listen for Beta transformation
    testEventBus.once('beta-transformation-complete', (info) => {
      if (info.source.includes('interaction-test.md')) {
        transformedByBeta = true;
        console.log('✓ Beta Agent transformed the file');
        
        // Check the full interaction chain
        clearTimeout(timeout);
        assertTest(
          'Full Agent Interaction Chain',
          detectedByAlpha && transformedByBeta,
          'All agents should process the file change in sequence'
        );
        resolve();
      }
    });
    
    // Modify the file to trigger the chain
    setTimeout(() => {
      fs.appendFileSync(interactionTestFile, '\nThis line was added to trigger agent interactions.\n');
    }, 500);
  });
}

/**
 * Print test summary
 */
function printTestSummary() {
  console.log('\n📊 Test Summary:');
  console.log(`✓ Total Tests: ${testResults.totalTests}`);
  console.log(`✓ Passed: ${testResults.passedTests}`);
  console.log(`✗ Failed: ${testResults.failedTests}`);
  console.log(`⚠ Skipped: ${testResults.skippedTests}`);
  
  const successRate = Math.round((testResults.passedTests / testResults.totalTests) * 100);
  console.log(`📈 Success Rate: ${successRate}%`);
  
  if (testResults.failedTests === 0) {
    console.log('\n🎉 All tests passed! The agent architecture is functioning correctly.');
  } else {
    console.log('\n⚠️ Some tests failed. Please review the test output for details.');
  }
}

/**
 * Clean up test environment
 */
async function cleanupTestEnvironment() {
  console.log('\n🧹 Cleaning up test environment...');
  
  // Stop Alpha agent monitoring
  if (alphaAgent) {
    alphaAgent.stopWatching();
  }
  
  // Remove PID file
  if (epsilonAgent && epsilonAgent.pidFilePath && fs.existsSync(epsilonAgent.pidFilePath)) {
    fs.unlinkSync(epsilonAgent.pidFilePath);
  }
  
  // Optionally remove test files
  // Uncomment to delete test files after testing
  /*
  if (fs.existsSync('./test-data')) {
    fs.rmSync('./test-data', { recursive: true, force: true });
  }
  */
  
  console.log('✅ Cleanup complete');
}

/**
 * Run all tests
 */
async function runTests() {
  try {
    console.log('🚀 Starting MD-JSON Synchronization System Agent Architecture Tests\n');
    
    // Setup test environment
    await setupTestEnvironment();
    
    // Initialize agents
    await initializeAgents();
    
    // Run individual agent tests
    await testAlphaAgent();
    await testBetaAgent();
    await testGammaAgent();
    await testDeltaAgent();
    await testEpsilonAgent();
    
    // Test agent interactions
    await testAgentInteractions();
    
    // Print test summary
    printTestSummary();
    
    // Clean up
    await cleanupTestEnvironment();
    
  } catch (error) {
    console.error('❌ Error during testing:', error);
    console.error(error.stack);
  }
}

// Run the tests
runTests(); 