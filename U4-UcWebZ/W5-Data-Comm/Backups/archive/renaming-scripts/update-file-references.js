#!/usr/bin/env node

/**
 * tYDiSync~ File Reference Updater
 * This script updates references to the old md-json-sync filenames
 * to the new tydisync naming convention throughout the codebase.
 */

const fs = require('fs');
const path = require('path');
const { promisify } = require('util');

const readdir = promisify(fs.readdir);
const stat = promisify(fs.stat);
const readFile = promisify(fs.readFile);
const writeFile = promisify(fs.writeFile);

// Mapping of old to new filenames
const filenameMapping = {
  'tydisync-status-report.md': 'tydisync-status-report.md',
  'tydisync-debug.log': 'tydisync-debug.log',
  'tydisync-low-cpu-reference.md': 'tydisync-low-cpu-reference.md',
  'tydisync-implementation-verification.md': 'tydisync-implementation-verification.md',
  'tydisync-system-summary.md': 'tydisync-system-summary.md',
  'tydisync-testing-findings.md': 'tydisync-testing-findings.md',
  'tydisync-next-steps.md': 'tydisync-next-steps.md',
  'README-tydisync.md': 'README-tydisync.md',
  'tydisync-quick-reference.md': 'tydisync-quick-reference.md',
  'start-tydisync-silent.vbs': 'start-tydisync-silent.vbs'
};

// File types to process
const fileTypesToProcess = [
  '.js', '.json', '.md', '.bat', '.vbs', '.ps1'
];

// Directories to exclude
const excludedDirs = [
  'node_modules', '.git'
];

// Process a single file
async function processFile(filePath) {
  try {
    // Read file content
    let content = await readFile(filePath, 'utf8');
    let originalContent = content;
    
    // Replace all filename references
    for (const [oldName, newName] of Object.entries(filenameMapping)) {
      // Replace direct references to filenames
      const oldNameRegex = new RegExp(oldName.replace(/\./g, '\\.'), 'g');
      content = content.replace(oldNameRegex, newName);
      
      // Also replace references that might be in paths
      const oldPathRegex = new RegExp(`([/\\\\])${oldName.replace(/\./g, '\\.')}`, 'g');
      content = content.replace(oldPathRegex, `$1${newName}`);
    }
    
    // If content changed, write it back
    if (content !== originalContent) {
      await writeFile(filePath, content, 'utf8');
      console.log(`Updated references in: ${filePath}`);
      return 1; // Return 1 for files changed
    }
    
    return 0; // Return 0 for no changes
  } catch (error) {
    console.error(`Error processing file ${filePath}:`, error);
    return 0;
  }
}

// Recursively process directory
async function processDirectory(dirPath) {
  let filesChanged = 0;
  
  try {
    const entries = await readdir(dirPath);
    
    for (const entry of entries) {
      const entryPath = path.join(dirPath, entry);
      
      try {
        const entryStat = await stat(entryPath);
        
        if (entryStat.isDirectory()) {
          // Skip excluded directories
          if (excludedDirs.includes(entry)) {
            continue;
          }
          
          // Process subdirectory
          filesChanged += await processDirectory(entryPath);
        } else if (entryStat.isFile()) {
          // Process only specific file types
          const ext = path.extname(entryPath);
          if (fileTypesToProcess.includes(ext)) {
            filesChanged += await processFile(entryPath);
          }
        }
      } catch (error) {
        console.error(`Error processing ${entryPath}:`, error);
      }
    }
  } catch (error) {
    console.error(`Error reading directory ${dirPath}:`, error);
  }
  
  return filesChanged;
}

// Main function
async function main() {
  console.log('tYDiSync~ File Reference Updater');
  console.log('===============================');
  console.log('Updating all references to renamed files in the codebase...');
  
  const startTime = Date.now();
  
  // Start processing from root directory
  const rootDir = '.';
  const filesChanged = await processDirectory(rootDir);
  
  const endTime = Date.now();
  const duration = (endTime - startTime) / 1000; // Convert to seconds
  
  console.log('===============================');
  console.log(`Process completed in ${duration.toFixed(2)} seconds.`);
  console.log(`Updated references in ${filesChanged} files.`);
  console.log('Please review the changes before committing.');
}

// Run the main function
main().catch(error => {
  console.error('An error occurred:', error);
  process.exit(1);
}); 