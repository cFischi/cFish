const fs = require('fs');
const path = require('path');
const { promisify } = require('util');
const readFileAsync = promisify(fs.readFile);
const writeFileAsync = promisify(fs.writeFile);
const readdirAsync = promisify(fs.readdir);
const statAsync = promisify(fs.stat);

// Define documentation replacements
const docReplacements = [
  { from: 'node md-json-sync.js', to: 'node tydisync.js' },
  { from: 'md-json-sync.js', to: 'tydisync.js' },
  { from: 'start-md-json-sync.bat', to: 'start-tydisync.bat' },
  { from: 'start-md-json-sync-background.bat', to: 'start-tydisync-background.bat' },
  { from: 'cursor-md-json-sync.js', to: 'cursor-tydisync.js' },
  { from: 'optimized-md-json-sync.js', to: 'optimized-tydisync.js' },
  { from: 'dummy-md-json-sync.js', to: 'dummy-tydisync.js' },
  { from: 'md-json-sync-engine.js', to: 'tydisync-engine.js' },
  { from: 'md-json-sync-enhanced.js', to: 'tydisync-enhanced.js' },
  { from: 'md-json-sync-enhanced-README.md', to: 'tydisync-enhanced-README.md' },
  { from: '.md-json-sync.lock', to: '.tydisync.lock' },
  { from: 'md-json-sync-status.json', to: 'tydisync-status.json' },
  { from: 'md-json-sync-notifications.json', to: 'tydisync-notifications.json' },
  { from: 'md-json-sync-state.json', to: 'tydisync-state.json' }
];

// Function to recursively walk through directory
async function walkDirectory(dirPath) {
  const files = await readdirAsync(dirPath);
  const result = [];

  for (const file of files) {
    const filePath = path.join(dirPath, file);
    const stat = await statAsync(filePath);

    if (stat.isDirectory()) {
      const subDirFiles = await walkDirectory(filePath);
      result.push(...subDirFiles);
    } else {
      result.push(filePath);
    }
  }

  return result;
}

// Function to update file content
async function updateFileContent(filePath) {
  try {
    // Check if file exists
    if (!fs.existsSync(filePath)) {
      console.log(`⚠️ File not found: ${filePath}`);
      return { filePath, changes: 0, success: false };
    }
    
    // Skip JSON files that are meant to be paired with Markdown files
    if (filePath.includes('json/') && path.extname(filePath) === '.json') {
      // These will be updated automatically by the sync system later
      console.log(`ℹ️ Skipping JSON file: ${filePath} (will be updated by sync system)`);
      return { filePath, changes: 0, success: true, skipped: true };
    }
    
    // Read the file
    const content = await readFileAsync(filePath, 'utf8');
    let updatedContent = content;
    let changesCount = 0;
    
    // Apply standard replacements
    for (const replacement of docReplacements) {
      const regex = new RegExp(replacement.from.replace(/\./g, '\\.').replace(/\//g, '\\/'), 'g');
      const beforeContent = updatedContent;
      updatedContent = updatedContent.replace(regex, replacement.to);
      
      // Count changes
      if (beforeContent !== updatedContent) {
        const matches = beforeContent.match(regex) || [];
        changesCount += matches.length;
      }
    }
    
    // Write updated content if changes were made
    if (changesCount > 0) {
      await writeFileAsync(filePath, updatedContent, 'utf8');
      console.log(`✅ Updated ${filePath} with ${changesCount} changes`);
      return { filePath, changes: changesCount, success: true };
    } else {
      console.log(`ℹ️ No changes needed in ${filePath}`);
      return { filePath, changes: 0, success: true };
    }
  } catch (error) {
    console.error(`❌ Error updating ${filePath}: ${error.message}`);
    return { filePath, changes: 0, success: false, error: error.message };
  }
}

// Main function
async function main() {
  console.log('🔄 Starting documentation updates for tYDiSync~ in docs directory...');
  
  // Get all files in docs directory recursively
  console.log('\n📂 Scanning docs directory...');
  const docsFiles = await walkDirectory('docs');
  console.log(`Found ${docsFiles.length} files in docs directory`);
  
  // Update implementation-plan.md in root directory
  if (fs.existsSync('implementation-plan.md')) {
    await updateFileContent('implementation-plan.md');
  }
  
  // Update all files in docs directory
  console.log('\n📝 Updating documentation files...');
  let totalChanges = 0;
  let updatedFiles = 0;
  let skippedFiles = 0;
  let failedFiles = 0;
  
  for (const filePath of docsFiles) {
    const result = await updateFileContent(filePath);
    
    if (result.success) {
      if (result.skipped) {
        skippedFiles++;
      } else if (result.changes > 0) {
        totalChanges += result.changes;
        updatedFiles++;
      }
    } else {
      failedFiles++;
    }
  }
  
  // Summary
  console.log('\n📊 Documentation Update Summary:');
  console.log(`- Files processed: ${docsFiles.length}`);
  console.log(`- Files updated: ${updatedFiles}`);
  console.log(`- Files skipped: ${skippedFiles}`);
  console.log(`- Files failed: ${failedFiles}`);
  console.log(`- Total changes made: ${totalChanges}`);
  
  console.log('\n✅ Docs directory update process completed!');
}

// Run the script
main().catch(error => {
  console.error('❌ Script failed:', error);
}); 