const fs = require('fs');
const path = require('path');
const { promisify } = require('util');
const readFileAsync = promisify(fs.readFile);
const writeFileAsync = promisify(fs.writeFile);
const readdirAsync = promisify(fs.readdir);
const statAsync = promisify(fs.stat);

// Define replacements
const replacements = [
  { from: /md-json-sync\.js/g, to: 'tydisync.js' },
  { from: /dummy-md-json-sync\.js/g, to: 'dummy-tydisync.js' },
  { from: /dummy-md-json-sync/g, to: 'dummy-tydisync' },
  { from: /optimized-md-json-sync\.js/g, to: 'optimized-tydisync.js' },
  { from: /optimized-md-json-sync/g, to: 'optimized-tydisync' },
  { from: /optimized-md-json-sync\.log/g, to: 'optimized-tydisync.log' },
  { from: /cursor-md-json-sync\.js/g, to: 'cursor-tydisync.js' },
  { from: /cursor-md-json-enhanced\.js/g, to: 'cursor-tydisync-enhanced.js' },
  { from: /md-json-sync-enhanced\.js/g, to: 'tydisync-enhanced.js' },
  { from: /md-json-sync-state\.json/g, to: 'tydisync-state.json' },
  { from: /md-json-sync-status\.json/g, to: 'tydisync-status.json' },
  { from: /md-json-sync-notifications\.json/g, to: 'tydisync-notifications.json' }
];

// Function to recursively walk through directory
async function walkDirectory(dirPath) {
  const files = await readdirAsync(dirPath);
  const result = [];

  for (const file of files) {
    const filePath = path.join(dirPath, file);
    const stat = await statAsync(filePath);

    if (stat.isDirectory()) {
      // Skip node_modules and .git directories
      if (file === 'node_modules' || file === '.git') {
        continue;
      }
      const subDirFiles = await walkDirectory(filePath);
      result.push(...subDirFiles);
    } else {
      // Only include text files
      const ext = path.extname(filePath).toLowerCase();
      if (['.js', '.json', '.md', '.bat', '.vbs', '.html', '.css', '.txt', '.ps1'].includes(ext)) {
        result.push(filePath);
      }
    }
  }

  return result;
}

// Function to update file
async function updateFile(filePath) {
  try {
    // Check if file exists
    if (!fs.existsSync(filePath)) {
      console.log(`⚠️ File not found: ${filePath}`);
      return { filePath, changes: 0, success: false };
    }
    
    // Read the file
    const content = await readFileAsync(filePath, 'utf8');
    let updatedContent = content;
    let changesCount = 0;
    
    // Apply replacements
    for (const replacement of replacements) {
      const beforeContent = updatedContent;
      updatedContent = updatedContent.replace(replacement.from, replacement.to);
      
      // Count changes
      if (beforeContent !== updatedContent) {
        const matches = (beforeContent.match(replacement.from) || []).length;
        changesCount += matches;
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
  console.log('🔄 Starting sync-system reference updates for tYDiSync~...');
  
  if (!fs.existsSync('sync-system')) {
    console.error('❌ sync-system directory not found');
    return;
  }
  
  // Get all files in sync-system directory recursively
  console.log('\n📂 Scanning sync-system directory...');
  const files = await walkDirectory('sync-system');
  console.log(`Found ${files.length} files in sync-system directory`);
  
  // Update all files
  console.log('\n📝 Updating files...');
  let totalChanges = 0;
  let updatedFiles = 0;
  let failedFiles = 0;
  
  for (const filePath of files) {
    const result = await updateFile(filePath);
    
    if (result.success) {
      if (result.changes > 0) {
        totalChanges += result.changes;
        updatedFiles++;
      }
    } else {
      failedFiles++;
    }
  }
  
  // Summary
  console.log('\n📊 Sync-System Update Summary:');
  console.log(`- Files processed: ${files.length}`);
  console.log(`- Files updated: ${updatedFiles}`);
  console.log(`- Files failed: ${failedFiles}`);
  console.log(`- Total changes made: ${totalChanges}`);
  
  console.log('\n✅ Sync-system update process completed!');
}

// Run the script
main().catch(error => {
  console.error('❌ Script failed:', error);
}); 