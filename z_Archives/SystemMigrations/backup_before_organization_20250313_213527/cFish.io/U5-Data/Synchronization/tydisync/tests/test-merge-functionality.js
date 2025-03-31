#!/usr/bin/env node

/**
 * Content Merging Test Script
 * 
 * This script specifically tests the merging functionality in the Beta Agent
 * to ensure it properly preserves content during bidirectional synchronization.
 * 
 * @version 1.0.0
 */

const fs = require('fs');
const path = require('path');
const BetaAgent = require('./beta-agent');
const GammaAgent = require('./gamma-agent');
const DeltaAgent = require('./delta-agent');

// Test configuration
const config = {
  watchDirs: [
    { md: './test-merge/md', json: './test-merge/json' }
  ],
  backupDir: './test-merge/backups',
  maxBackups: 3,
  enableBackups: true,
  validationThreshold: 0.9,
  criticalFiles: ['memory.md']
};

// Sample content similar to memory.md
const originalContent = `# Test Memory Document

## First Section
- Item one
- Item two
- Item three

## Second Section
This is content in the second section.
It spans multiple lines.

## Third Section
- Another item
- More content here

_Updated 03-14-2025 | Test: Original Content_
`;

// Modified JSON with changes to only one section
const modifiedJsonContent = {
  metadata: {
    title: "Test Memory Document"
  },
  sections: [
    {
      level: 1,
      title: "Test Memory Document",
      content: []
    },
    {
      level: 2,
      title: "First Section",
      content: [
        "- Item one",
        "- Item two",
        "- Item three"
      ]
    },
    {
      level: 2,
      title: "Second Section",
      content: [
        "This is UPDATED content in the second section.",
        "It spans multiple lines.",
        "With an additional line."
      ]
    },
    {
      level: 2,
      title: "Third Section",
      content: [
        "- Another item",
        "- More content here"
      ]
    },
    {
      level: 2,
      title: "New Section",
      content: [
        "This is a completely new section added in the JSON."
      ]
    }
  ],
  lastUpdated: new Date().toISOString(),
  signature: "_Updated 03-14-2025 | Test: Updated via JSON_"
};

/**
 * Setup test environment
 */
async function setupTestEnvironment() {
  console.log('🔧 Setting up merge test environment...');
  
  // Create test directories
  const dirs = [
    './test-merge',
    './test-merge/md',
    './test-merge/json',
    './test-merge/backups'
  ];
  
  for (const dir of dirs) {
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
  }
  
  // Create original Markdown file
  const mdPath = './test-merge/md/memory.md';
  fs.writeFileSync(mdPath, originalContent);
  console.log(`✅ Created test Markdown file at ${mdPath}`);
  
  // Create backup directory
  if (!fs.existsSync(config.backupDir)) {
    fs.mkdirSync(config.backupDir, { recursive: true });
  }
  
  console.log('✅ Test environment setup complete');
  return mdPath;
}

/**
 * Initialize agents
 */
async function initializeAgents() {
  console.log('🚀 Initializing agents for merge testing...');
  
  // Initialize relevant agents
  const betaAgent = new BetaAgent(config);
  await betaAgent.initialize();
  
  const gammaAgent = new GammaAgent(config);
  await gammaAgent.initialize();
  
  const deltaAgent = new DeltaAgent(config);
  await deltaAgent.initialize();
  
  console.log('✅ Agents initialized');
  
  return { betaAgent, gammaAgent, deltaAgent };
}

/**
 * Run the merge test
 */
async function runMergeTest() {
  try {
    console.log('🧪 Starting Content Merge Test');
    
    // Setup test environment
    const mdPath = await setupTestEnvironment();
    
    // Initialize agents
    const { betaAgent, gammaAgent, deltaAgent } = await initializeAgents();
    
    // Save the JSON file
    const jsonPath = betaAgent.getCorrespondingJsonPath(mdPath);
    const jsonDir = path.dirname(jsonPath);
    
    if (!fs.existsSync(jsonDir)) {
      fs.mkdirSync(jsonDir, { recursive: true });
    }
    
    // First, convert MD to JSON
    console.log('🔄 Converting original Markdown to JSON...');
    const mdToJsonResult = await betaAgent.markdownToJson({
      path: mdPath,
      type: 'change'
    });
    
    if (!mdToJsonResult.success) {
      throw new Error(`Failed to convert Markdown to JSON: ${mdToJsonResult.reason}`);
    }
    
    console.log(`✅ Successfully converted Markdown to JSON at ${mdToJsonResult.targetPath}`);
    
    // Now, modify the JSON with our changes
    console.log('✏️ Modifying JSON content...');
    fs.writeFileSync(jsonPath, JSON.stringify(modifiedJsonContent, null, 2));
    
    // Set the modification time to be newer
    const now = new Date();
    fs.utimesSync(jsonPath, now, now);
    const pastDate = new Date(now.getTime() - 10000);
    fs.utimesSync(mdPath, pastDate, pastDate);
    
    // Should we sync from JSON to MD?
    const shouldSync = await gammaAgent.shouldSynchronize({
      sourcePath: jsonPath,
      targetPath: mdPath,
      direction: 'json-to-md',
      force: false
    });
    
    console.log(`🔍 Gamma Agent decision: ${shouldSync.proceed ? 'Proceed' : 'Skip'} - ${shouldSync.reason}`);
    
    if (!shouldSync.proceed) {
      throw new Error(`Gamma Agent unexpectedly blocked synchronization: ${shouldSync.reason}`);
    }
    
    // Create backup
    console.log('💾 Creating backup of original Markdown...');
    const backupResult = await deltaAgent.createBackup(mdPath);
    
    if (!backupResult.success) {
      throw new Error(`Failed to create backup: ${backupResult.reason}`);
    }
    
    console.log(`✅ Created backup at ${backupResult.backupPath}`);
    
    // Perform the merge
    console.log('🔄 Performing JSON to Markdown merge...');
    const jsonToMdResult = await betaAgent.jsonToMarkdown({
      path: jsonPath,
      type: 'change'
    });
    
    if (!jsonToMdResult.success) {
      throw new Error(`Failed to convert JSON to Markdown: ${jsonToMdResult.reason}`);
    }
    
    console.log(`✅ Successfully converted JSON to Markdown with merge at ${jsonToMdResult.targetPath}`);
    
    // Read the merged content
    const mergedContent = fs.readFileSync(mdPath, 'utf8');
    
    // Analyze the merge results
    console.log('\n📊 Merge Analysis:');
    
    // Check if updated content is present
    const hasUpdatedContent = mergedContent.includes('UPDATED content');
    console.log(`- Updated content preserved: ${hasUpdatedContent ? '✅' : '❌'}`);
    
    // Check if new section is present
    const hasNewSection = mergedContent.includes('New Section');
    console.log(`- New section added: ${hasNewSection ? '✅' : '❌'}`);
    
    // Check if original untouched sections are preserved
    const hasFirstSection = mergedContent.includes('First Section');
    const hasThirdSection = mergedContent.includes('Third Section');
    console.log(`- Original first section preserved: ${hasFirstSection ? '✅' : '❌'}`);
    console.log(`- Original third section preserved: ${hasThirdSection ? '✅' : '❌'}`);
    
    // Check if signature line updated
    const hasUpdatedSignature = mergedContent.includes('Test: Updated via JSON');
    console.log(`- Signature line updated: ${hasUpdatedSignature ? '✅' : '❌'}`);
    
    // Overall merge quality
    const mergeSuccess = hasUpdatedContent && hasNewSection && hasFirstSection && hasThirdSection;
    
    console.log(`\n${mergeSuccess ? '🎉 Merge TEST PASSED' : '❌ Merge TEST FAILED'}`);
    
    // Print the merged content
    console.log('\n📄 Merged Content:');
    console.log('------------------------------------------');
    console.log(mergedContent);
    console.log('------------------------------------------');
    
    // Compare with original
    console.log('\n📄 Original Content:');
    console.log('------------------------------------------');
    console.log(originalContent);
    console.log('------------------------------------------');
    
    // Summary
    if (mergeSuccess) {
      console.log('\n✅ The merge functionality is working properly!');
      console.log('   Critical content is preserved while new content is integrated.');
    } else {
      console.log('\n❌ The merge functionality has issues:');
      if (!hasUpdatedContent) console.log('   - Failed to include updated content');
      if (!hasNewSection) console.log('   - Failed to add new section');
      if (!hasFirstSection) console.log('   - Lost original first section');
      if (!hasThirdSection) console.log('   - Lost original third section');
    }
    
  } catch (error) {
    console.error(`❌ Error during merge testing: ${error.message}`);
    console.error(error.stack);
  }
}

// Run the merge test
runMergeTest(); 