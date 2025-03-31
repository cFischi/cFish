/**
 * Root Directory Monitoring Test
 * 
 * This script tests if the MD-JSON synchronization system properly
 * handles root directory Markdown files.
 */

const fs = require('fs');
const path = require('path');

// Test configuration
const testConfig = {
  testFile: 'root-monitor-test.md',
  jsonFile: 'json/root-monitor-test.json',
  backupFile: 'backups/root-monitor-test.md.backup',
  testContent: `# Root Directory Monitoring Test

This is a test file created by test-root-monitoring.js to verify
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
3. When the JSON is modified, changes should be reflected back in this file
`
};

/**
 * Run the test
 */
async function runTest() {
  console.log('🧪 Starting Root Directory Monitoring Test');
  
  try {
    // Create test file
    console.log(`📝 Creating test file: ${testConfig.testFile}`);
    fs.writeFileSync(testConfig.testFile, testConfig.testContent);
    console.log('✅ Test file created successfully');
    
    // Wait for synchronization to happen
    console.log('⏳ Waiting 5 seconds for synchronization to occur...');
    await new Promise(resolve => setTimeout(resolve, 5000));
    
    // Check if JSON file was created
    if (fs.existsSync(testConfig.jsonFile)) {
      console.log(`✅ JSON file created: ${testConfig.jsonFile}`);
      
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
      
      // Modify the JSON file
      console.log('✏️ Modifying JSON file to test bidirectional sync...');
      const testSection = {
        level: 2,
        title: "JSON Modification Test",
        content: [
          "This section was added by the test script directly to the JSON file.",
          "It should appear in the Markdown file if bidirectional sync is working.",
          `Modification timestamp: ${new Date().toISOString()}`
        ]
      };
      
      // Add the new section
      jsonObj.sections.push(testSection);
      jsonObj.lastUpdated = new Date().toISOString();
      
      // Write back the modified JSON
      fs.writeFileSync(testConfig.jsonFile, JSON.stringify(jsonObj, null, 2));
      console.log('✅ JSON file modified successfully');
      
      // Wait for sync back to MD
      console.log('⏳ Waiting 5 seconds for changes to sync back to Markdown...');
      await new Promise(resolve => setTimeout(resolve, 5000));
      
      // Check if the Markdown file was updated
      const updatedMdContent = fs.readFileSync(testConfig.testFile, 'utf8');
      console.log('📝 Checking if Markdown file was updated...');
      if (updatedMdContent.includes('JSON Modification Test')) {
        console.log('✅ SUCCESS: Markdown file was updated with changes from JSON!');
        console.log('🎉 Bidirectional synchronization is working correctly for root directory files');
      } else {
        console.log('❌ FAIL: Markdown file was not updated with changes from JSON');
        console.log('🔍 Root to JSON works, but JSON to root does not work yet');
      }
    } else {
      console.log(`❌ FAIL: JSON file was not created at ${testConfig.jsonFile}`);
      console.log('🔍 Root directory monitoring is not working correctly');
    }
  } catch (error) {
    console.error('❌ Test error:', error);
  } finally {
    console.log('🧪 Root Directory Monitoring Test complete');
  }
}

// Run the test
runTest(); 