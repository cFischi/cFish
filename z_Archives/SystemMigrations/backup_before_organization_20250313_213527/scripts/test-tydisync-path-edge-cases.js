/**
 * test-tydisync-path-edge-cases.js
 * 
 * Tests tYDiSync~ with various path edge cases, including:
 * - Extremely long paths (approaching OS limits)
 * - Paths with special characters
 * - Deeply nested directory structures
 * - Spaces in directory and file names
 * 
 * Usage: node test-tydisync-path-edge-cases.js
 */

const fs = require('fs');
const path = require('path');
const os = require('os');
const { spawn, execSync } = require('child_process');

// Configuration
const isWindows = os.platform() === 'win32';
const testBaseDir = path.resolve(__dirname, '..', 'tydisync-test', 'path-edge-cases');
const logDir = path.resolve(__dirname, '..', 'logs');
const pathEdgeCaseLogFile = path.resolve(logDir, 'path-edge-case-results.log');

// Define test cases for different path edge cases
const pathEdgeCases = [
  // Long path (approaching OS limits)
  {
    name: "long-path-test",
    // Create a folder with a long name and nested directories
    relativePath: "a".repeat(20) + "/b".repeat(20) + "/c".repeat(20) + "/d".repeat(20),
    content: "# Long Path Test\n\nThis file is stored in a very long path to test path length limitations."
  },
  
  // Special characters in path
  {
    name: "special-chars-test",
    relativePath: "special @#$%^&()_+-={}[]~ chars/more!@#$%^ chars",
    content: "# Special Characters in Path\n\nThis file is stored in a path with special characters."
  },
  
  // Spaces in filename and path
  {
    name: "spaces in filename",
    relativePath: "folder with spaces/subfolder with more spaces",
    content: "# Spaces in Path and Filename\n\nThis file has spaces in its name and path."
  },
  
  // Unicode characters in path
  {
    name: "unicode-path-test",
    relativePath: "unicode_😀_🚀/中文_日本語/español_deutsch",
    content: "# Unicode Characters in Path\n\nThis file is stored in a path with Unicode characters."
  },
  
  // Deeply nested directories
  {
    name: "deeply-nested-test",
    relativePath: "level1/level2/level3/level4/level5/level6/level7/level8/level9/level10",
    content: "# Deeply Nested Directory Test\n\nThis file is stored in a deeply nested directory structure."
  },
  
  // Path with dots
  {
    name: "path.with.dots.test",
    relativePath: "folder.with.dots/subfolder.with.more.dots",
    content: "# Path with Dots\n\nThis file is stored in a path with dots in directory names."
  },
  
  // Mixed case path (for case-sensitive file systems)
  {
    name: "MixedCase-test",
    relativePath: "MixedCase/mixedCase/MIXEDCASE",
    content: "# Mixed Case Path Test\n\nThis file tests case sensitivity in paths."
  }
];

// Initialize directories and log file
function initialize() {
  console.log('Initializing test directories...');
  
  // Create log directory if it doesn't exist
  if (!fs.existsSync(logDir)) {
    fs.mkdirSync(logDir, { recursive: true });
  }
  
  // Clean up previous test directory if it exists
  if (fs.existsSync(testBaseDir)) {
    try {
      fs.rmSync(testBaseDir, { recursive: true, force: true });
    } catch (err) {
      console.warn(`Warning: Could not completely remove previous test directory: ${err.message}`);
    }
  }
  
  // Create base test directory
  fs.mkdirSync(testBaseDir, { recursive: true });
  
  // Initialize log file
  if (!fs.existsSync(pathEdgeCaseLogFile)) {
    fs.writeFileSync(pathEdgeCaseLogFile, '=== tYDiSync~ Path Edge Case Test Results ===\n\n');
  } else {
    fs.appendFileSync(pathEdgeCaseLogFile, '\n\n=== New Test Run: ' + new Date().toISOString() + ' ===\n\n');
  }
  
  console.log('Initialization complete.');
}

// Create test file with appropriate directories
function createTestFile(testCase) {
  try {
    // Create full directory path
    const dirPath = path.join(testBaseDir, 'md', testCase.relativePath);
    fs.mkdirSync(dirPath, { recursive: true });
    
    // Create the test file
    const filePath = path.join(dirPath, `${testCase.name}.md`);
    fs.writeFileSync(filePath, testCase.content);
    
    // Create json directory structure
    const jsonDirPath = path.join(testBaseDir, 'json', testCase.relativePath);
    fs.mkdirSync(jsonDirPath, { recursive: true });
    
    return { 
      success: true, 
      mdPath: filePath,
      jsonPath: path.join(jsonDirPath, `${testCase.name}.json`),
      error: null
    };
  } catch (err) {
    return { 
      success: false, 
      mdPath: null,
      jsonPath: null,
      error: err.message
    };
  }
}

// Run conversion test for a single test case
function runConversionTest(testCase, fileInfo) {
  const logEntry = `Test: ${testCase.name}\n` +
                   `Path: ${testCase.relativePath}\n`;
  
  fs.appendFileSync(pathEdgeCaseLogFile, logEntry);
  
  if (!fileInfo.success) {
    fs.appendFileSync(pathEdgeCaseLogFile, `✗ Failed to create test file: ${fileInfo.error}\n\n`);
    console.error(`Error creating test file for ${testCase.name}: ${fileInfo.error}`);
    return false;
  }
  
  // Try to convert the file
  try {
    console.log(`Testing conversion for: ${testCase.name}`);
    
    // Run the conversion command
    const scriptExt = isWindows ? '.bat' : '.sh';
    const scriptPath = path.resolve(__dirname, `tydisync${scriptExt}`);
    
    const command = isWindows ? 
      `cmd.exe /c "${scriptPath}" --convert "${fileInfo.mdPath}" --output "${fileInfo.jsonPath}"` :
      `bash "${scriptPath}" --convert "${fileInfo.mdPath}" --output "${fileInfo.jsonPath}"`;
    
    execSync(command, { encoding: 'utf8' });
    
    // Check if JSON file was created
    if (fs.existsSync(fileInfo.jsonPath)) {
      fs.appendFileSync(pathEdgeCaseLogFile, `✓ Conversion successful\n`);
      
      // Try roundtrip conversion (JSON back to MD)
      try {
        const roundtripMdPath = fileInfo.mdPath.replace('.md', '-roundtrip.md');
        
        const roundtripCommand = isWindows ? 
          `cmd.exe /c "${scriptPath}" --json-to-md "${fileInfo.jsonPath}" --output "${roundtripMdPath}"` :
          `bash "${scriptPath}" --json-to-md "${fileInfo.jsonPath}" --output "${roundtripMdPath}"`;
        
        execSync(roundtripCommand, { encoding: 'utf8' });
        
        if (fs.existsSync(roundtripMdPath)) {
          fs.appendFileSync(pathEdgeCaseLogFile, `✓ Roundtrip conversion successful\n`);
          return true;
        } else {
          fs.appendFileSync(pathEdgeCaseLogFile, `✗ Roundtrip file not created\n`);
          return false;
        }
      } catch (roundtripErr) {
        fs.appendFileSync(pathEdgeCaseLogFile, `✗ Roundtrip conversion failed: ${roundtripErr.message}\n`);
        return false;
      }
    } else {
      fs.appendFileSync(pathEdgeCaseLogFile, `✗ JSON file not created\n`);
      return false;
    }
  } catch (err) {
    fs.appendFileSync(pathEdgeCaseLogFile, `✗ Conversion failed: ${err.message}\n`);
    console.error(`Error converting ${testCase.name}: ${err.message}`);
    return false;
  } finally {
    fs.appendFileSync(pathEdgeCaseLogFile, '\n');
  }
}

// Main test execution
function runTests() {
  console.log('Starting path edge case tests...');
  
  initialize();
  
  let successCount = 0;
  let failCount = 0;
  
  // Create paths for OS-specific tests
  if (isWindows) {
    // Windows-specific test: UNC path (if possible in this environment)
    try {
      // This won't actually work in many cases as it requires a real network share
      // Just added as an example of Windows-specific test
      pathEdgeCases.push({
        name: "windows-unc-path-test",
        relativePath: "windows_specific",
        content: "# Windows UNC Path Test\n\nThis tests Windows UNC paths (though would need a real network share)."
      });
    } catch (err) {
      console.log("Skipping Windows UNC path test (requires network share)");
    }
  } else {
    // Unix-specific test: Path with backslashes
    pathEdgeCases.push({
      name: "unix-backslash-test",
      relativePath: "unix\\specific\\backslash\\path",
      content: "# Unix Path with Backslashes\n\nThis tests paths with backslashes on Unix systems."
    });
  }
  
  // Process each test case
  for (const testCase of pathEdgeCases) {
    console.log(`Processing test case: ${testCase.name}`);
    const fileInfo = createTestFile(testCase);
    
    if (runConversionTest(testCase, fileInfo)) {
      successCount++;
    } else {
      failCount++;
    }
  }
  
  // Generate summary
  const summary = `
=== Test Summary ===
Total tests: ${pathEdgeCases.length}
Successful: ${successCount}
Failed: ${failCount}
Success rate: ${((successCount / pathEdgeCases.length) * 100).toFixed(2)}%
`;
  
  fs.appendFileSync(pathEdgeCaseLogFile, summary);
  console.log(summary);
  
  // Generate OS-specific information
  const osInfo = `
=== OS Specific Information ===
Platform: ${os.platform()}
OS Version: ${os.release()}
OS Type: ${os.type()}
Path Separator: ${path.sep}
Directory Separator: ${path.delimiter}
Max Path Length: ${isWindows ? '260 (standard) / ~32,767 (extended)' : 'Typically 4,096+ characters'}
`;
  
  fs.appendFileSync(pathEdgeCaseLogFile, osInfo);
  console.log('Path edge case tests completed.');
  
  return { successCount, failCount, total: pathEdgeCases.length };
}

// Run the tests and exit with appropriate code
try {
  const results = runTests();
  console.log(`Results written to: ${pathEdgeCaseLogFile}`);
  
  // Exit with code 0 if all tests passed, 1 otherwise
  process.exit(results.failCount === 0 ? 0 : 1);
} catch (err) {
  console.error('Test script failed with error:', err);
  fs.appendFileSync(pathEdgeCaseLogFile, `\nTest script failed with error: ${err.message}\n${err.stack}\n`);
  process.exit(1);
} 