/**
 * Edge Case Tests for tYDiSync~ Functionality
 * 
 * This script tests various edge conditions:
 * 1. Empty files
 * 2. Very large files (simulated)
 * 3. Files with special characters
 * 4. Malformed Markdown syntax
 * 5. Invalid JSON structures
 * 
 * @version 1.0.0
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');
const { setTimeout } = require('timers/promises');
const os = require('os');

// Configuration
const config = {
  testDir: path.resolve(__dirname, '..', 'tydisync-test'),
  mdDir: path.resolve(__dirname, '..', 'tydisync-test', 'md'),
  jsonDir: path.resolve(__dirname, '..', 'tydisync-test', 'json'),
  logFile: path.resolve(__dirname, '..', 'logs', 'tydisync-edge-test.log'),
  processTimeout: 10000, // Maximum time for each test (ms)
  specialChars: '!@#$%^&*()_+{}[]:;"\'<>,.?/~`±§',
  largeFileSize: 5 * 1024 * 1024 // 5MB for large file test
};

// Determine which script to use based on platform
const isWindows = os.platform() === 'win32';
const scriptCmd = isWindows ? 
  'tydisync.bat' : 
  './tydisync.sh';

// Ensure test directories exist
function ensureDirectories() {
  if (!fs.existsSync(config.testDir)) fs.mkdirSync(config.testDir, { recursive: true });
  if (!fs.existsSync(config.mdDir)) fs.mkdirSync(config.mdDir, { recursive: true });
  if (!fs.existsSync(config.jsonDir)) fs.mkdirSync(config.jsonDir, { recursive: true });
  
  // Ensure logs directory exists
  const logDir = path.dirname(config.logFile);
  if (!fs.existsSync(logDir)) fs.mkdirSync(logDir, { recursive: true });
}

// Clean up test files
function cleanupTestFiles() {
  const testFiles = [
    path.join(config.mdDir, 'empty_test.md'),
    path.join(config.jsonDir, 'empty_test.json'),
    path.join(config.mdDir, 'large_test.md'),
    path.join(config.jsonDir, 'large_test.json'),
    path.join(config.mdDir, 'special_chars_test.md'),
    path.join(config.jsonDir, 'special_chars_test.json'),
    path.join(config.mdDir, 'malformed_md_test.md'),
    path.join(config.jsonDir, 'malformed_md_test.json'),
    path.join(config.mdDir, 'malformed_json_test.md'),
    path.join(config.jsonDir, 'malformed_json_test.json')
  ];
  
  testFiles.forEach(file => {
    if (fs.existsSync(file)) {
      try {
        fs.unlinkSync(file);
      } catch (err) {
        console.error(`Error deleting ${file}: ${err.message}`);
      }
    }
  });
}

// Write log message
function log(message) {
  const timestamp = new Date().toISOString();
  const logMessage = `[${timestamp}] ${message}\n`;
  
  fs.appendFileSync(config.logFile, logMessage);
  console.log(message);
}

// Run tydisync conversion
function runConversion(filePath) {
  try {
    // Create a platform-appropriate command
    const cdCmd = isWindows ? 'cd' : 'cd';
    const cmdSeparator = isWindows ? '&&' : '&&';
    const quoteChar = isWindows ? '"' : '\'';
    
    const cmd = `${cdCmd} "${__dirname}" ${cmdSeparator} ${scriptCmd} --convert ${quoteChar}${filePath}${quoteChar} --verbose`;
    log(`Running command: ${cmd}`);
    
    const output = execSync(cmd, { timeout: config.processTimeout }).toString();
    log(`Command output: ${output.substring(0, 200)}...`);
    return { success: true, output };
  } catch (error) {
    log(`Error running conversion: ${error.message}`);
    return { success: false, error: error.message };
  }
}

// Test 1: Empty files
async function testEmptyFiles() {
  log('\n=== Test 1: Empty Files ===');
  
  // Create empty MD file
  const emptyMdPath = path.join(config.mdDir, 'empty_test.md');
  fs.writeFileSync(emptyMdPath, '');
  log(`Created empty Markdown file: ${emptyMdPath}`);
  
  // Run conversion
  const result = runConversion(emptyMdPath);
  
  // Check if JSON file was created
  const jsonPath = path.join(config.jsonDir, 'empty_test.json');
  const fileExists = fs.existsSync(jsonPath);
  
  if (result.success && fileExists) {
    log(`PASSED: Empty file conversion handled correctly`);
    return true;
  } else {
    log(`FAILED: Empty file conversion failed`);
    if (!fileExists) log(`       - JSON file was not created`);
    return false;
  }
}

// Test 2: Large files
async function testLargeFiles() {
  log('\n=== Test 2: Large Files ===');
  
  // Create large MD file (5MB)
  const largeMdPath = path.join(config.mdDir, 'large_test.md');
  
  // Generate content: large file with repeating markdown
  let content = '# Large File Test\n\n';
  const paragraph = 'This is a test paragraph for large file handling. It will be repeated many times to create a large file. ';
  const repetitions = Math.floor(config.largeFileSize / paragraph.length);
  
  log(`Generating large file with ${repetitions} repetitions...`);
  
  // Add heading every 100 paragraphs
  for (let i = 0; i < repetitions; i++) {
    if (i % 100 === 0) {
      content += `\n## Section ${Math.floor(i/100) + 1}\n\n`;
    }
    content += paragraph;
  }
  
  fs.writeFileSync(largeMdPath, content);
  log(`Created large Markdown file (${Math.round(content.length/1024/1024 * 100) / 100}MB): ${largeMdPath}`);
  
  // Run conversion
  const result = runConversion(largeMdPath);
  
  // Check if JSON file was created
  const jsonPath = path.join(config.jsonDir, 'large_test.json');
  const fileExists = fs.existsSync(jsonPath);
  
  if (result.success && fileExists) {
    const stats = fs.statSync(jsonPath);
    log(`PASSED: Large file conversion handled correctly, JSON size: ${Math.round(stats.size/1024/1024 * 100) / 100}MB`);
    return true;
  } else {
    log(`FAILED: Large file conversion failed`);
    if (!fileExists) log(`       - JSON file was not created`);
    return false;
  }
}

// Test 3: Special characters
async function testSpecialCharacters() {
  log('\n=== Test 3: Special Characters ===');
  
  // Create MD file with special characters
  const specialMdPath = path.join(config.mdDir, 'special_chars_test.md');
  
  // Generate content with special characters
  const content = `# Special ${config.specialChars} Characters Test\n\n` +
                 `This is a test with special characters: ${config.specialChars}\n\n` +
                 `- List item with ${config.specialChars}\n` +
                 `- Another ${config.specialChars} item\n\n` +
                 `\`\`\`\n${config.specialChars}\n\`\`\`\n`;
  
  fs.writeFileSync(specialMdPath, content);
  log(`Created Markdown file with special characters: ${specialMdPath}`);
  
  // Run conversion
  const result = runConversion(specialMdPath);
  
  // Check if JSON file was created and contains special characters
  const jsonPath = path.join(config.jsonDir, 'special_chars_test.json');
  const fileExists = fs.existsSync(jsonPath);
  
  if (result.success && fileExists) {
    const jsonContent = fs.readFileSync(jsonPath, 'utf8');
    const containsSpecialChars = config.specialChars.split('').every(char => 
      jsonContent.includes(char) || jsonContent.includes(`\\${char}`)
    );
    
    if (containsSpecialChars) {
      log(`PASSED: Special characters handled correctly`);
      return true;
    } else {
      log(`FAILED: Special characters not preserved in JSON`);
      return false;
    }
  } else {
    log(`FAILED: Special characters conversion failed`);
    if (!fileExists) log(`       - JSON file was not created`);
    return false;
  }
}

// Test 4: Malformed Markdown
async function testMalformedMarkdown() {
  log('\n=== Test 4: Malformed Markdown ===');
  
  // Create malformed MD file
  const malformedMdPath = path.join(config.mdDir, 'malformed_md_test.md');
  
  // Generate malformed Markdown content
  const content = `# Malformed Markdown Test\n\n` +
                 `This is a test with malformed Markdown syntax.\n\n` +
                 `- Unclosed list item\n` +
                 `* Mixed list syntax\n\n` +
                 `\`\`\` Unclosed code block\n` +
                 `[Unclosed link (http://example.com\n` +
                 `> Unclosed blockquote\n` +
                 `## Heading with ** unclosed emphasis\n`;
  
  fs.writeFileSync(malformedMdPath, content);
  log(`Created malformed Markdown file: ${malformedMdPath}`);
  
  // Run conversion
  const result = runConversion(malformedMdPath);
  
  // Check if JSON file was created despite malformed input
  const jsonPath = path.join(config.jsonDir, 'malformed_md_test.json');
  const fileExists = fs.existsSync(jsonPath);
  
  if (result.success && fileExists) {
    log(`PASSED: Malformed Markdown handled correctly`);
    return true;
  } else {
    log(`FAILED: Malformed Markdown conversion failed`);
    if (!fileExists) log(`       - JSON file was not created`);
    return false;
  }
}

// Test 5: Invalid JSON
async function testInvalidJson() {
  log('\n=== Test 5: Invalid JSON ===');
  
  // Create invalid JSON file
  const invalidJsonPath = path.join(config.jsonDir, 'malformed_json_test.json');
  
  // Generate invalid JSON content
  const content = `{
    "title": "Malformed JSON Test",
    "content": "This is a test with invalid JSON syntax.
    "items": [
      "Item 1",
      "Item 2",
      "Item 3"
    ]
    "unclosed": {
      "nested": "object"
  `;
  
  fs.writeFileSync(invalidJsonPath, content);
  log(`Created invalid JSON file: ${invalidJsonPath}`);
  
  // Run conversion
  const result = runConversion(invalidJsonPath);
  
  // For invalid JSON, we expect the conversion to fail gracefully or generate an error file
  if (!result.success) {
    log(`PASSED: Invalid JSON correctly identified as problematic`);
    return true;
  } else {
    // Check if MD file was created despite invalid input
    const mdPath = path.join(config.mdDir, 'malformed_json_test.md');
    const fileExists = fs.existsSync(mdPath);
    
    if (fileExists) {
      const mdContent = fs.readFileSync(mdPath, 'utf8');
      if (mdContent.includes('error') || mdContent.includes('invalid')) {
        log(`PASSED: Invalid JSON handled by creating error notification in MD`);
        return true;
      } else {
        log(`FAILED: Invalid JSON was converted without error notification`);
        return false;
      }
    } else {
      log(`FAILED: Invalid JSON handling didn't create any output file`);
      return false;
    }
  }
}

// Run all tests
async function runTests() {
  try {
    log('======== tYDiSync~ Edge Case Tests ========');
    log(`Platform: ${os.platform()}, Using script: ${scriptCmd}`);
    
    // Setup
    ensureDirectories();
    cleanupTestFiles();
    
    // Run all tests
    const results = [
      await testEmptyFiles(),
      await testLargeFiles(),
      await testSpecialCharacters(),
      await testMalformedMarkdown(),
      await testInvalidJson()
    ];
    
    // Summary
    log('\n======== Test Results Summary ========');
    log(`Test 1 (Empty Files): ${results[0] ? 'PASSED' : 'FAILED'}`);
    log(`Test 2 (Large Files): ${results[1] ? 'PASSED' : 'FAILED'}`);
    log(`Test 3 (Special Characters): ${results[2] ? 'PASSED' : 'FAILED'}`);
    log(`Test 4 (Malformed Markdown): ${results[3] ? 'PASSED' : 'FAILED'}`);
    log(`Test 5 (Invalid JSON): ${results[4] ? 'PASSED' : 'FAILED'}`);
    
    const passCount = results.filter(r => r).length;
    
    log(`\nPassed ${passCount} out of 5 tests`);
    
    if (passCount === 5) {
      log('ALL TESTS PASSED! Edge cases are handled correctly.');
      return true;
    } else {
      log('SOME TESTS FAILED. Edge case handling needs improvement.');
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

// Run the tests and exit
runTests().then(success => {
  process.exit(success ? 0 : 1);
}); 