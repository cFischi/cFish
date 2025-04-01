/**
 * test-tydisync-unicode.js
 * 
 * A specialized test script for testing Unicode character handling in tYDiSync~
 * This script tests synchronization with files containing various Unicode characters,
 * emojis, and unusual symbols to ensure proper handling across platforms.
 * 
 * Usage: node test-tydisync-unicode.js
 */

const fs = require('fs');
const path = require('path');
const os = require('os');
const { spawn, execSync } = require('child_process');

// Configuration
const isWindows = os.platform() === 'win32';
const testDir = path.resolve(__dirname, '..', 'tydisync-test', 'unicode');
const logDir = path.resolve(__dirname, '..', 'logs');
const tempDir = path.resolve(testDir, 'temp');
const unicodeLogFile = path.resolve(logDir, 'unicode-test-results.log');

// Unicode test cases
const unicodeTestCases = [
  { 
    name: "emojis", 
    content: `# Emoji Test 😀 🚀 🌍 🔥 💻\n\n## Section with Emojis\n- Item 1 ✅\n- Item 2 📝\n- Item 3 ⚠️\n\n## Another Section\nThis is a paragraph with emojis 🎉 🎊 🎁.`
  },
  { 
    name: "international-characters", 
    content: `# International Characters\n\n## European\n- French: çéâêîôûàèìòùëïü\n- German: äöüß\n- Spanish: áéíóúñ¿¡\n\n## Asian\n- Chinese: 你好世界\n- Japanese: こんにちは世界\n- Korean: 안녕하세요 세계`
  },
  { 
    name: "special-symbols", 
    content: `# Special Symbols & Characters\n\n## Math Symbols\n- π ∑ ∫ ∆ ∇ √ ∞ ≈ ≠ ≤ ≥ ±\n\n## Currency\n- $€£¥₹₽¢₩\n\n## Various Symbols\n- ☀☁☂☃★☆♠♣♥♦♪♫`
  },
  { 
    name: "mixed-content", 
    content: `# Mixed Unicode Content\n\n## Code with Comments\n\`\`\`javascript\n// 你好世界 - Hello World in Chinese\nconst greeting = "こんにちは"; // Japanese\nconsole.log(\`${greeting} 🌍\`);\n\`\`\`\n\n## List with Various Characters\n- Item ① with ✅\n- Item ② with ❌\n- Item ③ with unicode: ñáéíóú`
  },
  { 
    name: "extremely-unusual", 
    content: `# Extremely Unusual Unicode\n\n## Rare Characters\n- Ogham: ᚑᚌᚐᚋ\n- Old Italic: 𐌀𐌁𐌂𐌃\n- Egyptian Hieroglyphs: 𓀀𓀁𓀂𓀃\n- Runic: ᚠᚢᚦᚨᚱᚲ\n\n## Unusual Combinations\nHere's a mix: ⚕☤⚚⚛⚜⚝⚡⚢⚣⚤⚥`
  }
];

// Initialize directories
function initializeDirectories() {
  console.log('Initializing test directories...');
  
  if (!fs.existsSync(logDir)) {
    fs.mkdirSync(logDir, { recursive: true });
  }
  
  if (fs.existsSync(testDir)) {
    // Clean up existing test directory
    fs.rmSync(testDir, { recursive: true, force: true });
  }
  
  fs.mkdirSync(testDir, { recursive: true });
  fs.mkdirSync(path.join(testDir, 'md'), { recursive: true });
  fs.mkdirSync(path.join(testDir, 'json'), { recursive: true });
  fs.mkdirSync(tempDir, { recursive: true });
  
  console.log('Test directories initialized.');
}

// Create test files with Unicode content
function createTestFiles() {
  console.log('Creating Unicode test files...');
  
  unicodeTestCases.forEach(testCase => {
    const mdFilePath = path.join(testDir, 'md', `${testCase.name}.md`);
    fs.writeFileSync(mdFilePath, testCase.content);
    console.log(`Created ${mdFilePath}`);
  });
  
  console.log('Unicode test files created.');
}

// Run the conversion using tydisync
function runConversion() {
  console.log('Running conversion tests...');
  
  const logStream = fs.createWriteStream(unicodeLogFile, { flags: 'a' });
  logStream.write(`\n=== Unicode Test Run: ${new Date().toISOString()} ===\n\n`);
  
  // MD to JSON conversion
  unicodeTestCases.forEach(testCase => {
    const mdFilePath = path.join(testDir, 'md', `${testCase.name}.md`);
    const expectedJsonPath = path.join(testDir, 'json', `${testCase.name}.json`);
    
    try {
      // Run the conversion command
      const scriptExt = isWindows ? '.bat' : '.sh';
      const scriptPath = path.resolve(__dirname, `tydisync${scriptExt}`);
      const scriptCmd = isWindows ? 'cmd.exe' : 'bash';
      const scriptArgs = isWindows ? 
        ['/c', scriptPath, '--convert', mdFilePath, '--output', expectedJsonPath] : 
        [scriptPath, '--convert', mdFilePath, '--output', expectedJsonPath];
      
      console.log(`Converting ${testCase.name}.md to JSON...`);
      
      // Execute the conversion
      const output = execSync(
        isWindows ? 
          `cmd.exe /c "${scriptPath}" --convert "${mdFilePath}" --output "${expectedJsonPath}"` :
          `bash "${scriptPath}" --convert "${mdFilePath}" --output "${expectedJsonPath}"`,
        { encoding: 'utf8' }
      );
      
      logStream.write(`✓ MD to JSON conversion succeeded for ${testCase.name}\n`);
      logStream.write(`  Output: ${output.split('\n')[0]}\n`);
      
      // Verify the JSON file exists
      if (fs.existsSync(expectedJsonPath)) {
        logStream.write(`  JSON file created successfully.\n`);
        
        // Read and parse the JSON to verify it's valid
        try {
          const jsonContent = fs.readFileSync(expectedJsonPath, 'utf8');
          JSON.parse(jsonContent);
          logStream.write(`  JSON is valid and can be parsed.\n`);
        } catch (err) {
          logStream.write(`  ⚠ JSON validation error: ${err.message}\n`);
          console.error(`Error validating JSON for ${testCase.name}: ${err.message}`);
        }
      } else {
        logStream.write(`  ✗ JSON file was not created.\n`);
        console.error(`JSON file was not created for ${testCase.name}`);
      }
    } catch (err) {
      logStream.write(`✗ MD to JSON conversion failed for ${testCase.name}: ${err.message}\n`);
      console.error(`Error converting ${testCase.name}: ${err.message}`);
    }
    
    logStream.write('\n');
  });
  
  // Now test JSON to MD conversion (roundtrip)
  logStream.write('\n=== Testing JSON to MD Roundtrip ===\n\n');
  
  unicodeTestCases.forEach(testCase => {
    const jsonFilePath = path.join(testDir, 'json', `${testCase.name}.json`);
    const roundtripMdPath = path.join(tempDir, `${testCase.name}-roundtrip.md`);
    
    try {
      if (!fs.existsSync(jsonFilePath)) {
        logStream.write(`✗ Skipping roundtrip test for ${testCase.name}: JSON file doesn't exist\n`);
        return;
      }
      
      // Run the conversion command
      const scriptExt = isWindows ? '.bat' : '.sh';
      const scriptPath = path.resolve(__dirname, `tydisync${scriptExt}`);
      
      console.log(`Converting ${testCase.name}.json back to MD...`);
      
      // Execute the conversion
      const output = execSync(
        isWindows ? 
          `cmd.exe /c "${scriptPath}" --json-to-md "${jsonFilePath}" --output "${roundtripMdPath}"` :
          `bash "${scriptPath}" --json-to-md "${jsonFilePath}" --output "${roundtripMdPath}"`,
        { encoding: 'utf8' }
      );
      
      logStream.write(`✓ JSON to MD conversion succeeded for ${testCase.name}\n`);
      
      // Compare original and roundtrip content
      if (fs.existsSync(roundtripMdPath)) {
        const originalContent = fs.readFileSync(path.join(testDir, 'md', `${testCase.name}.md`), 'utf8');
        const roundtripContent = fs.readFileSync(roundtripMdPath, 'utf8');
        
        // Check content preservation (might not be identical due to formatting)
        const originalLines = originalContent.split('\n').map(line => line.trim()).filter(line => line.length > 0);
        const roundtripLines = roundtripContent.split('\n').map(line => line.trim()).filter(line => line.length > 0);
        
        let preservedCount = 0;
        let totalChecked = 0;
        
        originalLines.forEach(line => {
          if (line.length > 3) { // Skip very short lines
            totalChecked++;
            if (roundtripContent.includes(line)) {
              preservedCount++;
            }
          }
        });
        
        const preservationRate = totalChecked > 0 ? (preservedCount / totalChecked) * 100 : 0;
        
        logStream.write(`  Content preservation: ${preservationRate.toFixed(2)}% of original content found in roundtrip\n`);
        
        if (preservationRate < 70) {
          logStream.write(`  ⚠ Warning: Low content preservation rate. Unicode character loss may be occurring.\n`);
          console.warn(`Warning: Low content preservation for ${testCase.name} (${preservationRate.toFixed(2)}%)`);
        }
      } else {
        logStream.write(`  ✗ Roundtrip MD file was not created.\n`);
        console.error(`Roundtrip MD file was not created for ${testCase.name}`);
      }
    } catch (err) {
      logStream.write(`✗ JSON to MD conversion failed for ${testCase.name}: ${err.message}\n`);
      console.error(`Error in roundtrip conversion for ${testCase.name}: ${err.message}`);
    }
    
    logStream.write('\n');
  });
  
  logStream.write('\n=== Unicode Test Complete ===\n');
  logStream.end();
  console.log('Conversion tests completed.');
}

// Main test execution
function runTest() {
  console.log('Starting Unicode character test...');
  
  // Add timestamp to log file
  if (fs.existsSync(unicodeLogFile)) {
    fs.appendFileSync(unicodeLogFile, `\n\n=== New Test Run: ${new Date().toISOString()} ===\n`);
  } else {
    fs.writeFileSync(unicodeLogFile, `=== Unicode Character Test: ${new Date().toISOString()} ===\n`);
  }
  
  try {
    initializeDirectories();
    createTestFiles();
    runConversion();
    
    console.log(`\nUnicode test completed. Results logged to ${unicodeLogFile}`);
    console.log('Check the log file for detailed results.');
  } catch (err) {
    console.error('Test failed with error:', err);
    fs.appendFileSync(unicodeLogFile, `\nTest failed with error: ${err.message}\n${err.stack}\n`);
  }
}

// Run the test
runTest(); 