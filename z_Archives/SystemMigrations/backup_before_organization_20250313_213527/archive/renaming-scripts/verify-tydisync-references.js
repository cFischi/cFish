const fs = require('fs');
const path = require('path');
const { promisify } = require('util');
const readFileAsync = promisify(fs.readFile);
const readdirAsync = promisify(fs.readdir);
const statAsync = promisify(fs.stat);
const { execSync } = require('child_process');

// Configuration
const searchTerms = [
  'md-json-sync.js',
  'md-json-sync-enhanced',
  'dummy-md-json-sync',
  'cursor-md-json-sync',
  'optimized-md-json-sync',
  'md-json-sync-engine',
  'start-md-json-sync',
  '.md-json-sync.lock'
];

// Files to exclude from verification
const excludedFiles = [
  'node_modules',
  '.git',
  'update-tydisync-references.js',
  'update-file-references.js',
  'update-imports.js',
  'update-batch-files.js',
  'update-documentation.js',
  'update-docs-directory.js',
  'update-remaining-references.js',
  'update-remaining-references-simple.js',  // Contains old references as part of its replacement logic
  'update-sync-system-references.js',
  'update-memory-for-renaming.js',
  'update-final-memory-entry.js',
  'verify-tydisync-references.js',
  'verify-tydisync-renaming.js',
  'rename-tydisync-files.ps1',             // PowerShell script contains old references as part of its mapping
  'memory.md',                             // Memory.md keeps historical references
  'changelog.md',                          // Changelog keeps historical references
  'docs/json',                             // Exclude JSON files in docs
  'docs/md-json-sync',                     // Exclude old directory
  'docs/u5-data-management/md-json-sync-fixes.md',  // Historical document
  'tydisync-file-mapping-reference.md',    // This file documents the mapping
  'tydisync-renaming-completion.md',       // This file documents the renaming process
];

// Function to walk directory recursively
async function walkDirectory(dir, fileList = []) {
  const files = await readdirAsync(dir);
  
  for (const file of files) {
    const filePath = path.join(dir, file);
    
    // Skip excluded directories
    if (excludedFiles.some(exclude => filePath.includes(exclude))) {
      continue;
    }
    
    const stat = await statAsync(filePath);
    
    if (stat.isDirectory()) {
      fileList = await walkDirectory(filePath, fileList);
    } else {
      // Only include text files
      const ext = path.extname(filePath).toLowerCase();
      if (['.js', '.json', '.md', '.bat', '.vbs', '.html', '.css', '.txt', '.ps1'].includes(ext)) {
        fileList.push(filePath);
      }
    }
  }
  
  return fileList;
}

// Function to check file for search terms
async function checkFile(filePath) {
  try {
    const content = await readFileAsync(filePath, 'utf8');
    const findings = [];
    
    for (const term of searchTerms) {
      if (content.includes(term)) {
        // Get line numbers for each occurrence
        const lines = content.split('\n');
        lines.forEach((line, index) => {
          if (line.includes(term)) {
            findings.push({
              term,
              lineNumber: index + 1,
              line: line.trim()
            });
          }
        });
      }
    }
    
    return { filePath, findings };
  } catch (error) {
    console.error(`Error reading ${filePath}: ${error.message}`);
    return { filePath, findings: [], error: error.message };
  }
}

// Function to check specific file
async function checkSpecificFile(filePath) {
  if (fs.existsSync(filePath)) {
    return await checkFile(filePath);
  } else {
    return { filePath, findings: [], error: 'File not found' };
  }
}

// Main verification function
async function verifyReferences() {
  console.log('🔍 Starting tYDiSync~ reference verification...');
  
  // Get all eligible files
  console.log('📂 Scanning directories for files to check...');
  const filesToCheck = await walkDirectory('.');
  console.log(`Found ${filesToCheck.length} files to verify`);
  
  // Check each file for references
  console.log('\n🔍 Checking files for old references...');
  const results = [];
  
  for (const filePath of filesToCheck) {
    const result = await checkFile(filePath);
    if (result.findings.length > 0) {
      results.push(result);
    }
  }
  
  // Check specific important files
  console.log('\n🔍 Checking specific critical files...');
  const criticalFiles = [
    'package.json',
    'tydisync.js',
    'sync-system/core/tydisync.js',
    'start-tydisync-silent.vbs',
    'scripts/tydisync.bat'
  ];
  
  for (const filePath of criticalFiles) {
    const result = await checkSpecificFile(filePath);
    if (result.findings.length > 0) {
      // Make sure it's not already in results
      if (!results.some(r => r.filePath === result.filePath)) {
        results.push(result);
      }
    }
  }
  
  // Generate report
  if (results.length > 0) {
    console.log('\n⚠️ Found references to old naming convention in the following files:');
    let totalReferences = 0;
    
    results.forEach(result => {
      console.log(`\n📄 ${result.filePath} (${result.findings.length} references):`);
      result.findings.forEach(finding => {
        console.log(`   Line ${finding.lineNumber}: ${finding.line.substring(0, 100)}${finding.line.length > 100 ? '...' : ''}`);
        console.log(`   Term found: "${finding.term}"`);
        totalReferences++;
      });
    });
    
    console.log(`\n📊 Total: ${totalReferences} references to old naming convention found in ${results.length} files`);
    
    // Provide guidance
    console.log('\n🔧 Next steps:');
    console.log('1. Update imports using update-imports.js');
    console.log('2. Update batch files using update-batch-files.js');
    console.log('3. Run this verification script again to confirm all references are updated');
    
    return { success: false, referenceCount: totalReferences, fileCount: results.length };
  } else {
    console.log('\n✅ No references to old naming convention found in the codebase!');
    return { success: true, referenceCount: 0, fileCount: 0 };
  }
}

// Run the verification
verifyReferences()
  .then(result => {
    if (result.success) {
      console.log('\n🎉 Verification complete! All references have been updated.');
      process.exit(0);
    } else {
      console.log(`\n⚠️ Verification failed: ${result.referenceCount} references still need to be updated in ${result.fileCount} files.`);
      process.exit(1);
    }
  })
  .catch(error => {
    console.error('❌ Verification script error:', error);
    process.exit(1);
  }); 