/**
 * Root Directory Monitoring Test - Limited
 * 
 * This script focuses only on testing root directory monitoring
 * with minimal processing to avoid memory issues.
 */

const fs = require('fs');
const path = require('path');
const child_process = require('child_process');

// Test configuration
const testConfig = {
  testFile: 'root-monitor-test.md',
  jsonFile: 'json/root-monitor-test.json',
  syncProcess: null,
  testContent: `# Root Directory Monitoring Test

This is a limited test file created by test-root-dir-only.js to verify
that Markdown files in the root directory are properly synchronized
to JSON files.

Test timestamp: ${new Date().toISOString()}

## Test Section

This section should be properly converted to JSON format.

* Test bullet point 1
* Test bullet point 2
* Test bullet point 3

## Verification

If this works correctly:
1. A JSON file should be created at ${path.resolve('json/root-monitor-test.json')}
2. The JSON file should reflect the content of this Markdown file
`
};

/**
 * Run the test
 */
async function runTest() {
  console.log('🧪 Starting Limited Root Directory Monitoring Test');
  
  try {
    // Create test directory if it doesn't exist
    if (!fs.existsSync('json')) {
      fs.mkdirSync('json', { recursive: true });
      console.log('✅ Created json directory');
    }
    
    // Clean up previous test files if they exist
    if (fs.existsSync(testConfig.testFile)) {
      fs.unlinkSync(testConfig.testFile);
      console.log(`✅ Removed previous test file: ${testConfig.testFile}`);
    }
    
    if (fs.existsSync(testConfig.jsonFile)) {
      fs.unlinkSync(testConfig.jsonFile);
      console.log(`✅ Removed previous test file: ${testConfig.jsonFile}`);
    }
    
    // Create test file
    console.log(`📝 Creating test file: ${testConfig.testFile}`);
    fs.writeFileSync(testConfig.testFile, testConfig.testContent);
    console.log('✅ Test file created successfully');
    
    // Start MD-JSON sync process with limited scope
    console.log('🚀 Starting MD-JSON sync process with limited scope...');
    
    // Create a temporary config file that only watches root directory
    const tempConfigFile = 'test-config-root-only.json';
    const configContent = {
      watchDirs: [
        { md: "./", json: "./json" }
      ],
      backupDir: "./backups",
      maxBackups: 2,
      enableBackups: true,
      debounceTime: 300,
      exclusions: [
        "node_modules", ".git", ".cursor", "backups",
        "wp-content", "wp-admin", "wp-includes", "vendor"
      ],
      conflictResolutionMethod: "timestamp",
      criticalFiles: ["memory.md"],
      recursiveWatching: false,
      validationThreshold: 0.9
    };
    
    fs.writeFileSync(tempConfigFile, JSON.stringify(configContent, null, 2));
    console.log(`✅ Created temporary config file: ${tempConfigFile}`);
    
    // Run the sync process with increased memory and the limited config
    const syncProcess = child_process.spawn('node', [
      '--max-old-space-size=4096',
      'tydisync.js',
      '--config=' + tempConfigFile,
      '--verbose'
    ], {
      detached: false,
      stdio: ['ignore', 'pipe', 'pipe']
    });
    
    testConfig.syncProcess = syncProcess;
    
    let outputData = '';
    
    syncProcess.stdout.on('data', (data) => {
      const output = data.toString();
      outputData += output;
      console.log(`🔄 Sync: ${output.trim()}`);
    });
    
    syncProcess.stderr.on('data', (data) => {
      console.error(`❌ Sync Error: ${data}`);
    });
    
    // Wait for synchronization to create the JSON file (up to 10 seconds)
    console.log('⏳ Waiting for JSON file to be created (max 10 seconds)...');
    let attempts = 0;
    const maxAttempts = 20; // 20 attempts * 500ms = 10 seconds
    
    while (attempts < maxAttempts) {
      if (fs.existsSync(testConfig.jsonFile)) {
        console.log(`✅ JSON file created: ${testConfig.jsonFile}`);
        break;
      }
      
      await new Promise(resolve => setTimeout(resolve, 500));
      attempts++;
      
      if (attempts % 4 === 0) {
        console.log(`⏳ Still waiting... (${attempts/2} seconds)`);
      }
    }
    
    // Check if JSON file was created
    if (fs.existsSync(testConfig.jsonFile)) {
      // Read the JSON file
      const jsonContent = fs.readFileSync(testConfig.jsonFile, 'utf8');
      console.log('📄 JSON content summary:');
      console.log('-----------------------');
      const jsonObj = JSON.parse(jsonContent);
      console.log(`Title: ${jsonObj.metadata?.title || 'Not found'}`);
      console.log(`Sections: ${jsonObj.sections?.length || 0}`);
      if (jsonObj.sections?.length > 0) {
        console.log('Section titles:');
        jsonObj.sections.forEach((section, index) => {
          console.log(`  ${index + 1}. ${section.title}`);
        });
      }
      console.log('-----------------------');
      
      console.log('✅ SUCCESS: Root directory monitoring is working!');
      console.log('🎉 The MD-JSON sync system successfully detected and processed the root directory file.');
    } else {
      console.log(`❌ FAIL: JSON file was not created at ${testConfig.jsonFile}`);
      console.log('🔍 Root directory monitoring is not working correctly');
      console.log('📋 Sync process output:');
      console.log(outputData);
    }
  } catch (error) {
    console.error('❌ Test error:', error);
  } finally {
    // Clean up
    if (testConfig.syncProcess) {
      try {
        process.kill(-testConfig.syncProcess.pid);
      } catch (e) {
        console.log('Note: Could not terminate sync process, it may have already exited');
      }
    }
    
    console.log('🧪 Root Directory Monitoring Test complete');
  }
}

// Run the test
runTest(); 