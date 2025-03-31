const fs = require('fs');
const path = require('path');
const { promisify } = require('util');
const readFileAsync = promisify(fs.readFile);
const writeFileAsync = promisify(fs.writeFile);
const readdirAsync = promisify(fs.readdir);
const statAsync = promisify(fs.stat);

// List of batch files to update
const batchFiles = [
  'scripts/md-json-sync.bat',
  'scripts/run-enhanced.bat',
  'scripts/run-low-cpu.bat',
  'scripts/run-memory-optimized.bat',
  'scripts/run-with-more-memory.bat',
  'scripts/run-optimized.bat',
  'scripts/start-md-json-sync-background.bat',
  'scripts/update-low-cpu-mode.bat',
  'scripts/start-safe-sync.bat',
  'scripts/start-md-json-sync.bat',
  'scripts/start-md-json-sync-watcher.bat'
];

// Define replacements
const replacements = [
  { from: 'md-json-sync.js', to: 'tydisync.js' },
  { from: 'md-json-sync-enhanced.js', to: 'tydisync-enhanced.js' },
  { from: 'md-json-sync.bat', to: 'tydisync.bat' },
  { from: 'start-md-json-sync', to: 'start-tydisync' },
  { from: '.md-json-sync.lock', to: '.tydisync.lock' },
  { from: 'md-json-sync.log', to: 'tydisync.log' },
  { from: 'cursor-md-json-sync.js', to: 'cursor-tydisync.js' }
];

// Function to rename batch files
async function renameBatchFiles() {
  const renameOperations = [];
  
  for (const batchFile of batchFiles) {
    // Determine new filename (if it contains md-json-sync)
    const dirname = path.dirname(batchFile);
    const basename = path.basename(batchFile);
    let newBasename = basename;
    
    if (basename.includes('md-json-sync')) {
      newBasename = basename.replace('md-json-sync', 'tydisync');
      const newFilePath = path.join(dirname, newBasename);
      renameOperations.push({ oldPath: batchFile, newPath: newFilePath });
    }
  }
  
  return renameOperations;
}

// Function to update content within batch files
async function updateBatchFileContent(filePath) {
  try {
    // Read file content
    const fullPath = path.resolve(process.cwd(), filePath);
    let fileContent = await readFileAsync(fullPath, 'utf8');
    
    // Apply all replacements
    let changesCount = 0;
    for (const replacement of replacements) {
      const regex = new RegExp(replacement.from.replace(/\./g, '\\.'), 'g');
      const beforeContent = fileContent;
      fileContent = fileContent.replace(regex, replacement.to);
      
      // Count changes
      if (beforeContent !== fileContent) {
        const matches = beforeContent.match(regex) || [];
        changesCount += matches.length;
      }
    }
    
    // Save updated content
    if (changesCount > 0) {
      await writeFileAsync(fullPath, fileContent, 'utf8');
      console.log(`✅ Made ${changesCount} replacements in ${filePath}`);
      return true;
    } else {
      console.log(`ℹ️ No replacements needed in ${filePath}`);
      return false;
    }
  } catch (error) {
    console.error(`❌ Error updating ${filePath}: ${error.message}`);
    return false;
  }
}

// Main function
async function main() {
  console.log('🔄 Starting batch file updates for tYDiSync~...');
  
  // Step 1: Update content in all batch files
  console.log('\n📝 Updating batch file content...');
  for (const batchFile of batchFiles) {
    await updateBatchFileContent(batchFile);
  }
  
  // Step 2: Rename batch files
  console.log('\n🏷️ Preparing batch file renaming operations...');
  const renameOperations = await renameBatchFiles();
  
  console.log(`Found ${renameOperations.length} batch files to rename:`);
  renameOperations.forEach(op => {
    console.log(`- ${op.oldPath} → ${op.newPath}`);
  });
  
  // Step 3: Perform renaming
  if (renameOperations.length > 0) {
    console.log('\n🔄 Renaming batch files...');
    for (const op of renameOperations) {
      try {
        // Make sure the target directory exists
        const targetDir = path.dirname(op.newPath);
        if (!fs.existsSync(targetDir)) {
          fs.mkdirSync(targetDir, { recursive: true });
        }
        
        // Rename file
        fs.renameSync(op.oldPath, op.newPath);
        console.log(`✅ Renamed ${op.oldPath} to ${op.newPath}`);
      } catch (error) {
        console.error(`❌ Error renaming ${op.oldPath}: ${error.message}`);
      }
    }
  }
  
  console.log('\n✅ Batch file update process completed!');
}

// Run the script
main().catch(error => {
  console.error('❌ Script failed:', error);
}); 