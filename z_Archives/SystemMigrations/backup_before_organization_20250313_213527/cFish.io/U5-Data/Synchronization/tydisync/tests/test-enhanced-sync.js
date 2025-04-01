/**
 * Test Enhanced MD-JSON Sync System
 * 
 * This script tests the enhanced MD-JSON sync system with complex documents
 * and long-term stability monitoring.
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// Path to test data
const TEST_DIR = 'test-data';
const MD_DIR = path.join(TEST_DIR, 'md');
const JSON_DIR = path.join(TEST_DIR, 'json');
const COMPLEX_DOC_SIZE = 500; // Number of sections in complex document
const TEST_DURATION = 3600000; // 1 hour
const OPERATIONS_PER_MINUTE = 10;

// Create test directories if they don't exist
if (!fs.existsSync(TEST_DIR)) {
  fs.mkdirSync(TEST_DIR);
  console.log(`Created test directory: ${TEST_DIR}`);
}

if (!fs.existsSync(MD_DIR)) {
  fs.mkdirSync(MD_DIR);
  console.log(`Created test directory: ${MD_DIR}`);
}

if (!fs.existsSync(JSON_DIR)) {
  fs.mkdirSync(JSON_DIR);
  console.log(`Created test directory: ${JSON_DIR}`);
}

/**
 * Generate a complex Markdown document with many sections
 * @param {string} filePath - Path to the output file
 * @param {number} size - Number of sections
 */
function generateComplexMarkdown(filePath, size = COMPLEX_DOC_SIZE) {
  console.log(`Generating complex Markdown document: ${filePath}`);
  
  let content = '# Complex Test Document\n\n';
  content += 'This document is designed to test the MD-JSON sync system with a complex structure.\n\n';
  
  // Generate sections
  for (let i = 1; i <= size; i++) {
    content += `## Section ${i}\n\n`;
    content += `This is section ${i} of the test document.\n\n`;
    
    // Add subsections
    for (let j = 1; j <= 3; j++) {
      content += `### Subsection ${i}.${j}\n\n`;
      content += `This is subsection ${j} of section ${i}.\n\n`;
      
      // Add code block
      content += '```javascript\n';
      content += `// Code block for section ${i}.${j}\n`;
      content += `function test${i}_${j}() {\n`;
      content += `  console.log("Testing section ${i}.${j}");\n`;
      content += `  return ${i * j};\n`;
      content += '}\n';
      content += '```\n\n';
      
      // Add table
      content += '| Column 1 | Column 2 | Column 3 |\n';
      content += '|----------|----------|----------|\n';
      content += `| Value ${i} | Value ${j} | Value ${i*j} |\n`;
      content += `| Test ${i} | Test ${j} | Test ${i+j} |\n\n`;
    }
  }
  
  fs.writeFileSync(filePath, content);
  console.log(`Created complex document with ${size} sections: ${filePath}`);
}

/**
 * Generate a complex JSON document from a Markdown document
 * @param {string} mdPath - Path to the Markdown file
 * @param {string} jsonPath - Path to the output JSON file
 */
function generateComplexJSON(mdPath, jsonPath) {
  console.log(`Generating complex JSON document: ${jsonPath}`);
  
  // Read Markdown content
  const mdContent = fs.readFileSync(mdPath, 'utf8');
  
  // Parse Markdown into a structured JSON object
  const lines = mdContent.split('\n');
  const jsonObj = {
    title: lines[0].replace('# ', ''),
    description: lines[2],
    sections: []
  };
  
  let currentSection = null;
  let currentSubsection = null;
  
  for (let i = 3; i < lines.length; i++) {
    const line = lines[i];
    
    if (line.startsWith('## ')) {
      currentSection = {
        title: line.replace('## ', ''),
        content: '',
        subsections: []
      };
      jsonObj.sections.push(currentSection);
      currentSubsection = null;
    } else if (line.startsWith('### ') && currentSection) {
      currentSubsection = {
        title: line.replace('### ', ''),
        content: '',
        codeBlock: '',
        table: []
      };
      currentSection.subsections.push(currentSubsection);
    } else if (currentSubsection && line.startsWith('```javascript')) {
      // Capture code block
      let codeBlock = '';
      i++;
      while (i < lines.length && !lines[i].startsWith('```')) {
        codeBlock += lines[i] + '\n';
        i++;
      }
      currentSubsection.codeBlock = codeBlock;
    } else if (currentSubsection && line.startsWith('| Column')) {
      // Capture table
      const headers = line.split('|').map(h => h.trim()).filter(h => h);
      i += 2; // Skip header separator
      
      currentSubsection.table = {
        headers,
        rows: []
      };
      
      while (i < lines.length && lines[i].startsWith('|')) {
        const cells = lines[i].split('|').map(c => c.trim()).filter(c => c);
        currentSubsection.table.rows.push(cells);
        i++;
      }
      
      i--; // Adjust index
    } else if (line.trim() !== '' && !line.startsWith('```')) {
      // Add content to current section or subsection
      if (currentSubsection) {
        currentSubsection.content += line + '\n';
      } else if (currentSection) {
        currentSection.content += line + '\n';
      }
    }
  }
  
  // Write JSON to file
  fs.writeFileSync(jsonPath, JSON.stringify(jsonObj, null, 2));
  console.log(`Created complex JSON document: ${jsonPath}`);
}

/**
 * Make a random change to a Markdown file
 * @param {string} filePath - Path to the Markdown file
 */
function makeRandomMarkdownChange(filePath) {
  console.log(`Making random change to Markdown file: ${filePath}`);
  
  // Read file
  let content = fs.readFileSync(filePath, 'utf8');
  
  // Split into lines
  const lines = content.split('\n');
  
  // Choose a random section line
  let sectionLines = lines.map((line, index) => ({ line, index }))
                      .filter(item => item.line.startsWith('## ') || item.line.startsWith('### '));
  
  if (sectionLines.length === 0) {
    console.log('No sections found in file');
    return;
  }
  
  const randomSectionIndex = Math.floor(Math.random() * sectionLines.length);
  const targetLine = sectionLines[randomSectionIndex];
  
  // Make a change
  const changeType = Math.floor(Math.random() * 3);
  
  if (changeType === 0) {
    // Change section title
    const oldTitle = targetLine.line;
    const newTitle = oldTitle + ' (Updated)';
    lines[targetLine.index] = newTitle;
    console.log(`Changed section title: ${oldTitle} -> ${newTitle}`);
  } else if (changeType === 1) {
    // Add content after the section
    const newContent = '\nThis is newly added content for testing purposes.\n';
    lines.splice(targetLine.index + 1, 0, newContent);
    console.log(`Added new content after section: ${targetLine.line}`);
  } else {
    // Modify a code block if one exists
    let codeBlockStart = -1;
    let codeBlockEnd = -1;
    
    for (let i = targetLine.index + 1; i < lines.length; i++) {
      if (lines[i].startsWith('```javascript')) {
        codeBlockStart = i;
      } else if (codeBlockStart !== -1 && lines[i] === '```') {
        codeBlockEnd = i;
        break;
      }
    }
    
    if (codeBlockStart !== -1 && codeBlockEnd !== -1) {
      // Add a new line to the code block
      const newCodeLine = `// Modified at ${new Date().toISOString()}`;
      lines.splice(codeBlockEnd, 0, newCodeLine);
      console.log(`Modified code block in section: ${targetLine.line}`);
    } else {
      // Fallback: add a comment
      lines.splice(targetLine.index + 1, 0, `<!-- Modified at ${new Date().toISOString()} -->`);
      console.log(`Added comment after section: ${targetLine.line}`);
    }
  }
  
  // Write back to file
  fs.writeFileSync(filePath, lines.join('\n'));
}

/**
 * Make a random change to a JSON file
 * @param {string} filePath - Path to the JSON file
 */
function makeRandomJSONChange(filePath) {
  console.log(`Making random change to JSON file: ${filePath}`);
  
  // Read and parse file
  let content = fs.readFileSync(filePath, 'utf8');
  let jsonObj = JSON.parse(content);
  
  if (!jsonObj.sections || jsonObj.sections.length === 0) {
    console.log('No sections found in JSON file');
    return;
  }
  
  // Choose a random section
  const randomSectionIndex = Math.floor(Math.random() * jsonObj.sections.length);
  const section = jsonObj.sections[randomSectionIndex];
  
  // Make a change
  const changeType = Math.floor(Math.random() * 3);
  
  if (changeType === 0) {
    // Change section title
    section.title = section.title + ' (Updated JSON)';
    console.log(`Changed JSON section title: ${section.title}`);
  } else if (changeType === 1) {
    // Add metadata
    section.metadata = {
      lastModified: new Date().toISOString(),
      modifiedBy: 'test-script',
      changeId: Math.floor(Math.random() * 10000)
    };
    console.log(`Added metadata to JSON section: ${section.title}`);
  } else if (section.subsections && section.subsections.length > 0) {
    // Modify a subsection
    const randomSubsectionIndex = Math.floor(Math.random() * section.subsections.length);
    const subsection = section.subsections[randomSubsectionIndex];
    
    subsection.content = subsection.content + '\nModified subsection content.\n';
    console.log(`Modified JSON subsection content: ${subsection.title}`);
  } else {
    // Fallback: add a note
    section.note = `Modified at ${new Date().toISOString()}`;
    console.log(`Added note to JSON section: ${section.title}`);
  }
  
  // Write back to file
  fs.writeFileSync(filePath, JSON.stringify(jsonObj, null, 2));
}

/**
 * Monitor a file for changes and verify its integrity
 * @param {string} sourceFile - The source file path
 * @param {string} targetFile - The target file path (transformed version)
 * @param {boolean} jsonToMd - Whether the transformation is from JSON to MD
 */
function monitorFileSync(sourceFile, targetFile, jsonToMd = false) {
  let lastSourceTime = fs.existsSync(sourceFile) ? fs.statSync(sourceFile).mtime.getTime() : 0;
  let lastTargetTime = fs.existsSync(targetFile) ? fs.statSync(targetFile).mtime.getTime() : 0;
  
  console.log(`Monitoring synchronization: ${sourceFile} -> ${targetFile}`);
  
  // Check every 2 seconds
  const intervalId = setInterval(() => {
    try {
      // Check if source file has changed
      if (fs.existsSync(sourceFile)) {
        const currentSourceTime = fs.statSync(sourceFile).mtime.getTime();
        
        if (currentSourceTime > lastSourceTime) {
          console.log(`Source file changed: ${sourceFile}`);
          lastSourceTime = currentSourceTime;
          
          // Wait a bit for sync to occur
          setTimeout(() => {
            if (fs.existsSync(targetFile)) {
              const currentTargetTime = fs.statSync(targetFile).mtime.getTime();
              
              if (currentTargetTime > lastTargetTime) {
                console.log(`✅ Target file updated: ${targetFile}`);
                lastTargetTime = currentTargetTime;
              } else {
                console.log(`⚠️ Target file not updated yet: ${targetFile}`);
              }
            } else {
              console.log(`⚠️ Target file does not exist: ${targetFile}`);
            }
          }, 5000);
        }
      }
    } catch (error) {
      console.error(`Error monitoring files: ${error.message}`);
    }
  }, 2000);
  
  return intervalId;
}

/**
 * Run a stress test by making frequent changes to monitored files
 * @param {number} duration - Test duration in milliseconds
 * @param {number} operationsPerMinute - Number of operations per minute
 */
function runStressTest(duration = TEST_DURATION, operationsPerMinute = OPERATIONS_PER_MINUTE) {
  console.log(`Starting stress test (duration: ${duration/60000} minutes, operations: ${operationsPerMinute}/minute)`);
  
  // Create test files
  const complexMdFile = path.join(MD_DIR, 'complex-test.md');
  const complexJsonFile = path.join(JSON_DIR, 'complex-test.json');
  
  generateComplexMarkdown(complexMdFile);
  generateComplexJSON(complexMdFile, complexJsonFile);
  
  // Setup monitoring
  const monitor1 = monitorFileSync(complexMdFile, complexJsonFile, false);
  const monitor2 = monitorFileSync(complexJsonFile, complexMdFile, true);
  
  // Start making changes
  const changeInterval = Math.floor(60000 / operationsPerMinute);
  const operationInterval = setInterval(() => {
    // Randomly choose which file to modify
    const modifyJson = Math.random() > 0.5;
    
    try {
      if (modifyJson) {
        makeRandomJSONChange(complexJsonFile);
      } else {
        makeRandomMarkdownChange(complexMdFile);
      }
    } catch (error) {
      console.error(`Error making changes: ${error.message}`);
    }
  }, changeInterval);
  
  // Create a memory and stability monitor
  let memoryReadings = [];
  const stabilityInterval = setInterval(() => {
    try {
      // Get Node.js process memory usage
      const memoryUsage = process.memoryUsage();
      memoryReadings.push({
        time: new Date(),
        rss: memoryUsage.rss,
        heapTotal: memoryUsage.heapTotal,
        heapUsed: memoryUsage.heapUsed,
        external: memoryUsage.external
      });
      
      // Log memory usage
      console.log('📊 Memory usage:');
      console.log(`RSS: ${Math.round(memoryUsage.rss / 1024 / 1024 * 100) / 100} MB`);
      console.log(`Heap total: ${Math.round(memoryUsage.heapTotal / 1024 / 1024 * 100) / 100} MB`);
      console.log(`Heap used: ${Math.round(memoryUsage.heapUsed / 1024 / 1024 * 100) / 100} MB`);
    } catch (error) {
      console.error(`Error monitoring memory: ${error.message}`);
    }
  }, 60000); // Check every minute
  
  // Stop test after duration
  setTimeout(() => {
    clearInterval(operationInterval);
    clearInterval(monitor1);
    clearInterval(monitor2);
    clearInterval(stabilityInterval);
    
    console.log('Stress test completed');
    
    // Generate memory usage report
    console.log('Memory usage report:');
    if (memoryReadings.length > 0) {
      const initialMemory = memoryReadings[0];
      const finalMemory = memoryReadings[memoryReadings.length - 1];
      
      console.log(`Initial RSS: ${Math.round(initialMemory.rss / 1024 / 1024 * 100) / 100} MB`);
      console.log(`Final RSS: ${Math.round(finalMemory.rss / 1024 / 1024 * 100) / 100} MB`);
      console.log(`Change: ${Math.round((finalMemory.rss - initialMemory.rss) / 1024 / 1024 * 100) / 100} MB`);
      
      console.log(`Initial heap used: ${Math.round(initialMemory.heapUsed / 1024 / 1024 * 100) / 100} MB`);
      console.log(`Final heap used: ${Math.round(finalMemory.heapUsed / 1024 / 1024 * 100) / 100} MB`);
      console.log(`Change: ${Math.round((finalMemory.heapUsed - initialMemory.heapUsed) / 1024 / 1024 * 100) / 100} MB`);
    }
    
    // Write memory report to file
    const reportFile = 'test-stability-report.json';
    fs.writeFileSync(reportFile, JSON.stringify({
      duration: duration,
      operationsPerMinute: operationsPerMinute,
      memoryReadings
    }, null, 2));
    
    console.log(`Stability report written to: ${reportFile}`);
  }, duration);
}

// If run directly from command line
if (require.main === module) {
  const args = process.argv.slice(2);
  
  const showHelp = () => {
    console.log(`
Test Enhanced MD-JSON Sync System

Usage:
  node test-enhanced-sync.js generate              - Generate test files
  node test-enhanced-sync.js monitor <duration>    - Monitor files for <duration> minutes
  node test-enhanced-sync.js stress <duration> <ops> - Run stress test for <duration> minutes with <ops> operations per minute
  node test-enhanced-sync.js help                  - Show this help message
    `);
  };
  
  if (args.length === 0 || args[0] === 'help') {
    showHelp();
  } else if (args[0] === 'generate') {
    const complexMdFile = path.join(MD_DIR, 'complex-test.md');
    const complexJsonFile = path.join(JSON_DIR, 'complex-test.json');
    
    generateComplexMarkdown(complexMdFile);
    generateComplexJSON(complexMdFile, complexJsonFile);
    
    console.log('Test files generated successfully');
  } else if (args[0] === 'monitor') {
    const duration = args[1] ? parseInt(args[1]) * 60000 : 300000; // Default: 5 minutes
    const complexMdFile = path.join(MD_DIR, 'complex-test.md');
    const complexJsonFile = path.join(JSON_DIR, 'complex-test.json');
    
    // Check if files exist, create if not
    if (!fs.existsSync(complexMdFile) || !fs.existsSync(complexJsonFile)) {
      generateComplexMarkdown(complexMdFile);
      generateComplexJSON(complexMdFile, complexJsonFile);
    }
    
    const monitor1 = monitorFileSync(complexMdFile, complexJsonFile, false);
    const monitor2 = monitorFileSync(complexJsonFile, complexMdFile, true);
    
    console.log(`Monitoring for ${duration / 60000} minutes...`);
    
    setTimeout(() => {
      clearInterval(monitor1);
      clearInterval(monitor2);
      console.log('Monitoring complete');
    }, duration);
  } else if (args[0] === 'stress') {
    const duration = args[1] ? parseInt(args[1]) * 60000 : 600000; // Default: 10 minutes
    const ops = args[2] ? parseInt(args[2]) : 10; // Default: 10 operations per minute
    
    runStressTest(duration, ops);
  } else {
    console.error('Invalid command');
    showHelp();
  }
}

module.exports = {
  generateComplexMarkdown,
  generateComplexJSON,
  makeRandomMarkdownChange,
  makeRandomJSONChange,
  monitorFileSync,
  runStressTest
}; 