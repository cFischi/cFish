const fs = require('fs');
const path = require('path');
const { promisify } = require('util');
const readFileAsync = promisify(fs.readFile);
const writeFileAsync = promisify(fs.writeFile);
const readdirAsync = promisify(fs.readdir);
const statAsync = promisify(fs.stat);

// Define replacements
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

// Special handling for package.json
async function updatePackageJson() {
  try {
    const packagePath = 'package.json';
    if (!fs.existsSync(packagePath)) {
      console.log('⚠️ package.json not found');
      return { success: false };
    }
    
    // Read package.json
    const content = await readFileAsync(packagePath, 'utf8');
    let packageJson;
    
    try {
      packageJson = JSON.parse(content);
    } catch (error) {
      console.error(`❌ Error parsing package.json: ${error.message}`);
      return { success: false, error: error.message };
    }
    
    // Make updates
    let changes = 0;
    
    // Update main field
    if (packageJson.main && packageJson.main.includes('md-json-sync')) {
      packageJson.main = packageJson.main.replace('md-json-sync', 'tydisync');
      changes++;
    }
    
    // Update scripts
    if (packageJson.scripts) {
      for (const [key, value] of Object.entries(packageJson.scripts)) {
        if (value.includes('md-json-sync')) {
          packageJson.scripts[key] = value.replace(/md-json-sync/g, 'tydisync');
          changes++;
        }
      }
    }
    
    // Update bin if it exists
    if (packageJson.bin) {
      for (const [key, value] of Object.entries(packageJson.bin)) {
        if (key.includes('md-json-sync') || value.includes('md-json-sync')) {
          const newKey = key.replace('md-json-sync', 'tydisync');
          const newValue = value.replace('md-json-sync', 'tydisync');
          
          // Delete old key
          delete packageJson.bin[key];
          
          // Add new key
          packageJson.bin[newKey] = newValue;
          changes++;
        }
      }
    }
    
    // Save updates if changes were made
    if (changes > 0) {
      await writeFileAsync(packagePath, JSON.stringify(packageJson, null, 2), 'utf8');
      console.log(`✅ Updated package.json with ${changes} changes`);
      return { success: true, changes };
    } else {
      console.log('ℹ️ No changes needed in package.json');
      return { success: true, changes: 0 };
    }
  } catch (error) {
    console.error(`❌ Error updating package.json: ${error.message}`);
    return { success: false, error: error.message };
  }
}

// Function to walk recursively through directory
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
      result.push(filePath);
    }
  }

  return result;
}

// Function to update json file
async function updateJsonFile(filePath) {
  try {
    // Skip files that should be excluded
    if (filePath.includes('node_modules') || 
        filePath.includes('.git') || 
        filePath.includes('package-lock.json') ||
        filePath.includes('tydisync-file-mapping-reference') ||
        filePath.includes('memory.md') ||
        filePath.includes('changelog.md')) {
      return { filePath, changes: 0, success: true, skipped: true };
    }
    
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

// Function to update JSON files in the json directory
async function updateJsonDirectory() {
  try {
    // Check if json directory exists
    if (!fs.existsSync('json')) {
      console.log('⚠️ json directory not found');
      return { success: true, changes: 0, skipped: true };
    }
    
    console.log('\n📂 Scanning json directory...');
    const jsonFiles = await walkDirectory('json');
    console.log(`Found ${jsonFiles.length} files in json directory`);
    
    // Process each file
    let totalChanges = 0;
    let updatedFiles = 0;
    let skippedFiles = 0;
    let failedFiles = 0;
    
    for (const filePath of jsonFiles) {
      const result = await updateJsonFile(filePath);
      
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
    
    return {
      success: true,
      totalFiles: jsonFiles.length,
      updatedFiles,
      skippedFiles,
      failedFiles,
      totalChanges
    };
  } catch (error) {
    console.error(`❌ Error updating json directory: ${error.message}`);
    return { success: false, error: error.message };
  }
}

// Function to update remaining files in root directory
async function updateRootFiles() {
  try {
    console.log('\n📂 Scanning root directory for remaining files...');
    
    // Get specific files in root directory that need updating
    const filesToUpdate = [
      'json-sync-system.md',
      'memory-full.md',
      'memory-manual.md',
      'memory-md-data-loss-resolution.md',
      'memory-md-protection.md',
      'memory-restore.js',
      'invisible.vbs',
      'patch-low-cpu.js',
      'README-tydisync.md', // Already renamed but might have references
      'recursive-directory-monitoring.md',
      'root-directory-monitoring-workarounds.md',
      'md-json-sync-engine.js', // This should be renamed to tydisync-engine.js in previous steps
    ];
    
    let totalChanges = 0;
    let updatedFiles = 0;
    let skippedFiles = 0;
    let failedFiles = 0;
    
    for (const filePath of filesToUpdate) {
      if (fs.existsSync(filePath)) {
        const result = await updateJsonFile(filePath);
        
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
      } else {
        console.log(`ℹ️ File not found: ${filePath} (might have been renamed already)`);
        skippedFiles++;
      }
    }
    
    return {
      success: true,
      updatedFiles,
      skippedFiles,
      failedFiles,
      totalChanges
    };
  } catch (error) {
    console.error(`❌ Error updating root files: ${error.message}`);
    return { success: false, error: error.message };
  }
}

// Main function
async function main() {
  console.log('🔄 Starting final reference updates for tYDiSync~...');
  
  // Update package.json
  console.log('\n📦 Updating package.json...');
  const packageResult = await updatePackageJson();
  
  // Update json directory
  console.log('\n📁 Updating files in json directory...');
  const jsonResult = await updateJsonDirectory();
  
  // Update remaining files in root directory
  console.log('\n📄 Updating remaining files in root directory...');
  const rootResult = await updateRootFiles();
  
  // Summary
  console.log('\n📊 Final Reference Update Summary:');
  
  if (packageResult.success) {
    console.log(`- Package.json: ${packageResult.changes} changes`);
  } else {
    console.log('- Package.json: Failed to update');
  }
  
  if (jsonResult.success) {
    console.log(`- JSON directory: ${jsonResult.totalChanges} changes in ${jsonResult.updatedFiles} files`);
  } else {
    console.log('- JSON directory: Failed to update');
  }
  
  if (rootResult.success) {
    console.log(`- Root files: ${rootResult.totalChanges} changes in ${rootResult.updatedFiles} files`);
  } else {
    console.log('- Root files: Failed to update');
  }
  
  const totalChanges = 
    (packageResult.success ? packageResult.changes : 0) +
    (jsonResult.success ? jsonResult.totalChanges : 0) +
    (rootResult.success ? rootResult.totalChanges : 0);
  
  console.log(`\n✅ Total changes made: ${totalChanges}`);
  console.log('\n✅ Final reference update process completed!');
}

// Run the script
main().catch(error => {
  console.error('❌ Script failed:', error);
}); 