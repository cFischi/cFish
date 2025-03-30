/**
 * Test script for JSON to Markdown conversion
 * 
 * This script tests the JSON to Markdown conversion functionality
 * independently of the full synchronization system.
 */

const fs = require('fs');
const path = require('path');
const BetaAgent = require('./beta-agent');

// Configuration
const config = {
  watchDirs: [
    { md: './docs', json: './docs/json' },
    { md: './shortlinks', json: './shortlinks/json' }
  ],
  validationThreshold: 0.9
};

// Test JSON file path
const testJsonPath = path.join(__dirname, 'docs', 'json', 'sync-test.json');
const outputMdPath = path.join(__dirname, 'docs', 'sync-test-from-json.md');

// Create test JSON if it doesn't exist
async function createTestJson() {
  const testJson = {
    metadata: {
      title: "Test Document",
      author: "MD-JSON Sync System",
      date: new Date().toISOString()
    },
    sections: [
      {
        level: 1,
        title: "Introduction",
        content: [
          "This is a test document created by the JSON to Markdown conversion test script.",
          "",
          "It contains multiple sections with different levels."
        ]
      },
      {
        level: 2,
        title: "Purpose",
        content: [
          "The purpose of this document is to test the JSON to Markdown conversion functionality.",
          "",
          "- Test bullet point 1",
          "- Test bullet point 2",
          "- Test bullet point 3"
        ]
      },
      {
        level: 2,
        title: "Code Example",
        content: [
          "Here is a code example:",
          "",
          "```javascript",
          "function testFunction() {",
          "  console.log('This is a test');",
          "  return true;",
          "}",
          "```"
        ]
      },
      {
        level: 1,
        title: "Conclusion",
        content: [
          "This concludes the test document.",
          "",
          "Thank you for using the MD-JSON Sync System!"
        ]
      }
    ],
    filePath: testJsonPath,
    lastUpdated: new Date().toISOString(),
    signature: "_Updated 03-13-2025 | Test: JSON to Markdown Conversion_"
  };

  // Ensure the directory exists
  const jsonDir = path.dirname(testJsonPath);
  await fs.promises.mkdir(jsonDir, { recursive: true });

  // Write the test JSON
  await fs.promises.writeFile(
    testJsonPath,
    JSON.stringify(testJson, null, 2),
    'utf8'
  );

  console.log(`✅ Created test JSON file at ${testJsonPath}`);
  return testJson;
}

// Run the test
async function runTest() {
  try {
    console.log('🧪 Starting JSON to Markdown conversion test');

    // Create or ensure the test JSON exists
    await createTestJson();

    // Initialize the Beta Agent
    const betaAgent = new BetaAgent(config);
    await betaAgent.initialize();

    // Convert JSON to Markdown
    console.log(`🔄 Converting ${testJsonPath} to Markdown`);
    const result = await betaAgent.jsonToMarkdown({
      path: testJsonPath,
      type: 'change'
    });

    if (result.success) {
      console.log(`✅ Successfully converted JSON to Markdown at ${result.targetPath}`);
      
      // Also save a copy to our specific output path for verification
      const mdContent = await fs.promises.readFile(result.targetPath, 'utf8');
      await fs.promises.writeFile(outputMdPath, mdContent, 'utf8');
      console.log(`✅ Saved a copy to ${outputMdPath} for verification`);
      
      // Display the generated Markdown
      console.log('\n📄 Generated Markdown content:');
      console.log('------------------------------------------');
      console.log(mdContent);
      console.log('------------------------------------------');
    } else {
      console.error(`❌ Conversion failed: ${result.reason}`);
    }

  } catch (error) {
    console.error(`🔥 Test failed with error: ${error.message}`);
    console.error(error.stack);
  }
}

// Run the test
runTest().then(() => {
  console.log('🏁 Test completed');
}); 