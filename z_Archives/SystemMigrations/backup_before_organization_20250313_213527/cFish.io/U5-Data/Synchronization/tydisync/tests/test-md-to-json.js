#!/usr/bin/env node

/**
 * Test script for Markdown to JSON conversion
 * 
 * This script tests the Markdown to JSON conversion functionality
 * of the MD-JSON synchronization system independently.
 * 
 * @version 1.0.0
 */

const fs = require('fs');
const path = require('path');
const BetaAgent = require('./beta-agent');

// Configuration for the test
const config = {
  watchDirs: [
    { md: './docs', json: './docs/json' },
    { md: './shortlinks', json: './shortlinks/json' }
  ],
  validationThreshold: 0.9
};

/**
 * Create a test Markdown file if it doesn't exist
 */
async function createTestMarkdown() {
  const testMdPath = './docs/sync-test-for-json.md';
  
  // Check if file already exists
  try {
    await fs.promises.access(testMdPath);
    console.log(`Test file ${testMdPath} already exists, using it for testing`);
    return testMdPath;
  } catch (error) {
    // File doesn't exist, create it
    console.log(`Creating test Markdown file at ${testMdPath}`);
    
    const testContent = `# Sync Test Document

## Introduction
This is a test document created to verify the Markdown to JSON conversion functionality.

## Purpose
The purpose of this test is to ensure that:
1. Markdown files are correctly parsed
2. JSON structure is properly generated
3. Content integrity is maintained

## Code Example
\`\`\`javascript
function testFunction() {
  console.log("This is a test function");
  return true;
}
\`\`\`

## Conclusion
If this test is successful, the system should generate a corresponding JSON file
in the ./docs/json directory with all the content properly structured.

---
Last updated: ${new Date().toISOString()}
Test generated for MD-JSON sync system verification.
`;
    
    // Ensure the directory exists
    const dir = path.dirname(testMdPath);
    await fs.promises.mkdir(dir, { recursive: true });
    
    // Write the test file
    await fs.promises.writeFile(testMdPath, testContent, 'utf8');
    console.log(`Test Markdown file created at ${testMdPath}`);
    
    return testMdPath;
  }
}

/**
 * Run the test
 */
async function runTest() {
  try {
    console.log('🚀 Starting Markdown to JSON conversion test');
    
    // Create test Markdown file
    const testMdPath = await createTestMarkdown();
    
    // Initialize Beta Agent (Content Transformer)
    const betaAgent = new BetaAgent(config);
    await betaAgent.initialize();
    
    // Convert Markdown to JSON
    console.log(`Converting ${testMdPath} to JSON...`);
    const result = await betaAgent.markdownToJson({
      path: testMdPath,
      type: 'md'
    });
    
    if (result.success) {
      console.log(`✅ Test successful! JSON file created at ${result.targetPath}`);
      console.log('Please check the JSON file to verify the conversion quality.');
    } else {
      console.error(`❌ Test failed: ${result.reason}`);
    }
    
  } catch (error) {
    console.error(`❌ Test error: ${error.message}`);
    console.error(error.stack);
  }
}

// Run the test
runTest(); 