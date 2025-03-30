#!/usr/bin/env node

/**
 * Critical File Protection Test Script
 * 
 * This script tests the critical file protection mechanisms to ensure
 * that files like memory.md are protected from data loss during synchronization.
 * 
 * @version 1.0.0
 */

const fs = require('fs');
const path = require('path');
const GammaAgent = require('./gamma-agent');
const DeltaAgent = require('./delta-agent');
const AlphaAgent = require('./alpha-agent');

// Test configuration
const config = {
  watchDirs: [
    { md: './test-critical/md', json: './test-critical/json' }
  ],
  backupDir: './test-critical/backups',
  maxBackups: 3,
  enableBackups: true,
  criticalFiles: ['memory.md', 'critical-test.md'],
  validationThreshold: 0.9
};

// Create a critical file with substantial content
const criticalContent = `# Critical Test Document

## Section 1
This is very important content that should not be lost.
It contains critical information that needs to be preserved.

## Section 2
More critical content that should be protected.
- Important item 1
- Important item 2
- Important item 3

## Section 3
Final section with important information.
This must be preserved at all costs.

_Updated 03-14-2025 | Test: Critical Content_
`;

// Create minimal JSON content that would cause data loss
const minimalJsonContent = {
  metadata: {
    title: "Minimal Content"
  },
  sections: [
    {
      level: 1,
      title: "Critical Test Document",
      content: []
    },
    {
      level: 2,
      title: "Minimal Section",
      content: [
        "This is minimal content that would cause data loss if synchronized."
      ]
    }
  ],
  lastUpdated: new Date().toISOString()
};

/**
 * Setup test environment
 */
async function setupTestEnvironment() {
  console.log('🔧 Setting up critical file protection test environment...');
  
  // Create test directories
  const dirs = [
    './test-critical',
    './test-critical/md',
    './test-critical/json',
    './test-critical/backups'
  ];
  
  for (const dir of dirs) {
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
  }
  
  // Create critical test file
  const mdPath = './test-critical/md/critical-test.md';
  fs.writeFileSync(mdPath, criticalContent);
  console.log(`✅ Created critical test file at ${mdPath}`);
  
  // Create corresponding minimal JSON
  const jsonPath = './test-critical/json/critical-test.json';
  fs.writeFileSync(jsonPath, JSON.stringify(minimalJsonContent, null, 2));
  console.log(`✅ Created minimal JSON file at ${jsonPath}`);
  
  // Create backup directory
  if (!fs.existsSync(config.backupDir)) {
    fs.mkdirSync(config.backupDir, { recursive: true });
  }
  
  // Create a .nosync marker file for testing exclusion
  const nosyncPath = './test-critical/md/excluded.md.nosync';
  fs.writeFileSync(nosyncPath, 'This file excludes excluded.md from synchronization');
  fs.writeFileSync('./test-critical/md/excluded.md', '# Excluded File\nThis file should be excluded by the .nosync marker.\n');
  console.log(`✅ Created .nosync marker at ${nosyncPath}`);
  
  console.log('✅ Test environment setup complete');
  return { mdPath, jsonPath };
}

/**
 * Initialize agents
 */
async function initializeAgents() {
  console.log('🚀 Initializing agents for protection testing...');
  
  // Initialize relevant agents
  const alphaAgent = new AlphaAgent(config);
  await alphaAgent.initialize();
  
  const gammaAgent = new GammaAgent(config);
  await gammaAgent.initialize();
  
  const deltaAgent = new DeltaAgent(config);
  await deltaAgent.initialize();
  
  console.log('✅ Agents initialized');
  
  return { alphaAgent, gammaAgent, deltaAgent };
}

/**
 * Run critical file protection tests
 */
async function runCriticalProtectionTests() {
  try {
    console.log('🧪 Starting Critical File Protection Tests');
    
    // Setup test environment
    const { mdPath, jsonPath } = await setupTestEnvironment();
    
    // Initialize agents
    const { alphaAgent, gammaAgent, deltaAgent } = await initializeAgents();
    
    // Test scenario: Minimal JSON file is newer than critical MD file
    const now = new Date();
    fs.utimesSync(jsonPath, now, now);
    const pastDate = new Date(now.getTime() - 10000);
    fs.utimesSync(mdPath, pastDate, pastDate);
    
    // Test 1: Data loss detection
    console.log('\n🧪 Test 1: Data Loss Risk Detection');
    const contentAnalysis = await gammaAgent.analyzeContentChanges(
      jsonPath,
      mdPath,
      'json-to-md'
    );
    
    console.log('Analysis results:', contentAnalysis);
    if (contentAnalysis.dataLossRisk) {
      console.log('✅ PASS: Gamma Agent correctly detected data loss risk');
      
      // Print details
      console.log(`   - Size difference: ${contentAnalysis.sizeDifference.toFixed(2)}x`);
      if (contentAnalysis.missingSections) {
        console.log(`   - Missing sections: ${contentAnalysis.missingSections}`);
      }
    } else {
      console.log('❌ FAIL: Gamma Agent failed to detect data loss risk');
    }
    
    // Test 2: Synchronization decision
    console.log('\n🧪 Test 2: Synchronization Decision');
    const shouldSync = await gammaAgent.shouldSynchronize({
      sourcePath: jsonPath,
      targetPath: mdPath,
      direction: 'json-to-md',
      force: false
    });
    
    if (!shouldSync.proceed) {
      console.log('✅ PASS: Gamma Agent correctly blocked synchronization for critical file');
      console.log(`   - Reason: ${shouldSync.reason}`);
    } else {
      console.log('❌ FAIL: Gamma Agent incorrectly allowed synchronization for critical file');
      console.log(`   - Reason: ${shouldSync.reason}`);
    }
    
    // Test 3: Manual protection creation
    console.log('\n🧪 Test 3: Manual Protection Creation');
    const protectionResult = await deltaAgent.createProtection(
      mdPath,
      'Test protection'
    );
    
    const nosyncPath = `${mdPath}.nosync`;
    if (protectionResult.success && fs.existsSync(nosyncPath)) {
      console.log('✅ PASS: Delta Agent successfully created protection marker');
      console.log(`   - Marker path: ${nosyncPath}`);
    } else {
      console.log('❌ FAIL: Delta Agent failed to create protection marker');
    }
    
    // Test 4: Protection marker detection
    console.log('\n🧪 Test 4: Protection Marker Detection');
    const isExcluded = alphaAgent.isExcluded('./test-critical/md/excluded.md');
    if (isExcluded) {
      console.log('✅ PASS: Alpha Agent correctly detected .nosync marker');
    } else {
      console.log('❌ FAIL: Alpha Agent failed to detect .nosync marker');
    }
    
    // Test 5: Backup creation
    console.log('\n🧪 Test 5: Critical File Backup');
    const backupResult = await deltaAgent.createBackup(mdPath);
    if (backupResult.success) {
      console.log('✅ PASS: Delta Agent successfully created backup of critical file');
      console.log(`   - Backup path: ${backupResult.backupPath}`);
    } else {
      console.log('❌ FAIL: Delta Agent failed to create backup of critical file');
      console.log(`   - Reason: ${backupResult.reason}`);
    }
    
    // Test 6: Forced sync with protection
    console.log('\n🧪 Test 6: Force Override Protection');
    const forcedSync = await gammaAgent.shouldSynchronize({
      sourcePath: jsonPath,
      targetPath: mdPath,
      direction: 'json-to-md',
      force: true
    });
    
    if (forcedSync.proceed) {
      console.log('✅ PASS: Force flag correctly overrides protection');
    } else {
      console.log('❌ FAIL: Force flag did not override protection');
    }
    
    // Test 7: Safe operation
    console.log('\n🧪 Test 7: Safe Operation');
    const safeOpResult = await deltaAgent.safeOperation(
      {
        sourcePath: mdPath,
        targetPath: `${mdPath}.safe-test`,
        operationType: 'test-operation'
      },
      async () => {
        // Simple test operation - copy file
        await fs.promises.copyFile(mdPath, `${mdPath}.safe-test`);
        return { success: true };
      }
    );
    
    if (safeOpResult.success && fs.existsSync(`${mdPath}.safe-test`)) {
      console.log('✅ PASS: Delta Agent successfully performed safe operation');
    } else {
      console.log('❌ FAIL: Delta Agent failed to perform safe operation');
    }
    
    // Print summary
    console.log('\n📊 Protection Test Summary:');
    console.log('1. Data Loss Risk Detection: ' + (contentAnalysis.dataLossRisk ? '✅ PASS' : '❌ FAIL'));
    console.log('2. Synchronization Decision: ' + (!shouldSync.proceed ? '✅ PASS' : '❌ FAIL'));
    console.log('3. Manual Protection Creation: ' + (protectionResult.success ? '✅ PASS' : '❌ FAIL'));
    console.log('4. Protection Marker Detection: ' + (isExcluded ? '✅ PASS' : '❌ FAIL'));
    console.log('5. Critical File Backup: ' + (backupResult.success ? '✅ PASS' : '❌ FAIL'));
    console.log('6. Force Override Protection: ' + (forcedSync.proceed ? '✅ PASS' : '❌ FAIL'));
    console.log('7. Safe Operation: ' + (safeOpResult.success ? '✅ PASS' : '❌ FAIL'));
    
    // Overall result
    const allPassed = contentAnalysis.dataLossRisk && !shouldSync.proceed && 
                     protectionResult.success && isExcluded && 
                     backupResult.success && forcedSync.proceed && 
                     safeOpResult.success;
                     
    if (allPassed) {
      console.log('\n🎉 All critical file protection tests PASSED!');
      console.log('   Critical files are properly protected from data loss.');
    } else {
      console.log('\n⚠️ Some critical file protection tests FAILED!');
      console.log('   Review the results above to identify issues.');
    }
    
  } catch (error) {
    console.error(`❌ Error during critical file protection testing: ${error.message}`);
    console.error(error.stack);
  }
}

// Run the tests
runCriticalProtectionTests(); 