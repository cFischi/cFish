const fs = require('fs');
const path = require('path');
const { promisify } = require('util');
const readFileAsync = promisify(fs.readFile);
const writeFileAsync = promisify(fs.writeFile);

// Update package.json
async function updatePackageJson() {
  try {
    const packagePath = 'package.json';
    if (!fs.existsSync(packagePath)) {
      console.log('⚠️ package.json not found');
      return;
    }
    
    console.log('📦 Updating package.json...');
    const content = await readFileAsync(packagePath, 'utf8');
    let packageJson = JSON.parse(content);
    
    // Update main field
    if (packageJson.main && packageJson.main.includes('md-json-sync')) {
      packageJson.main = packageJson.main.replace('md-json-sync', 'tydisync');
      console.log('  ✅ Updated main field');
    }
    
    // Update scripts
    if (packageJson.scripts) {
      for (const [key, value] of Object.entries(packageJson.scripts)) {
        if (value.includes('md-json-sync')) {
          packageJson.scripts[key] = value.replace(/md-json-sync/g, 'tydisync');
          console.log(`  ✅ Updated script: ${key}`);
        }
      }
    }
    
    // Update bin if it exists
    if (packageJson.bin) {
      const updatedBin = {};
      for (const [key, value] of Object.entries(packageJson.bin)) {
        if (key.includes('md-json-sync') || value.includes('md-json-sync')) {
          const newKey = key.replace('md-json-sync', 'tydisync');
          const newValue = value.replace('md-json-sync', 'tydisync');
          updatedBin[newKey] = newValue;
          console.log(`  ✅ Updated bin: ${key} -> ${newKey}`);
        } else {
          updatedBin[key] = value;
        }
      }
      packageJson.bin = updatedBin;
    }
    
    // Save the updated package.json
    await writeFileAsync(packagePath, JSON.stringify(packageJson, null, 2), 'utf8');
    console.log('✅ Updated package.json successfully');
  } catch (error) {
    console.error(`❌ Error updating package.json: ${error.message}`);
  }
}

// Update specific files
async function updateSpecificFiles() {
  const specificFiles = [
    'json-sync-system.md',
    'memory-full.md',
    'memory-manual.md',
    'memory-md-data-loss-resolution.md',
    'memory-md-protection.md',
    'memory-restore.js',
    'invisible.vbs',
    'patch-low-cpu.js',
    'README-tydisync.md',
    'recursive-directory-monitoring.md',
    'root-directory-monitoring-workarounds.md'
  ];
  
  console.log('\n📄 Updating specific files...');
  
  for (const filePath of specificFiles) {
    try {
      if (!fs.existsSync(filePath)) {
        console.log(`  ℹ️ File not found: ${filePath}`);
        continue;
      }
      
      const content = await readFileAsync(filePath, 'utf8');
      
      // Apply replacements
      let updatedContent = content
        .replace(/md-json-sync\.js/g, 'tydisync.js')
        .replace(/md-json-sync-enhanced\.js/g, 'tydisync-enhanced.js')
        .replace(/start-md-json-sync/g, 'start-tydisync')
        .replace(/cursor-md-json-sync\.js/g, 'cursor-tydisync.js')
        .replace(/optimized-md-json-sync\.js/g, 'optimized-tydisync.js')
        .replace(/dummy-md-json-sync\.js/g, 'dummy-tydisync.js')
        .replace(/\.md-json-sync\.lock/g, '.tydisync.lock')
        .replace(/md-json-sync-engine\.js/g, 'tydisync-engine.js');
      
      if (content !== updatedContent) {
        await writeFileAsync(filePath, updatedContent, 'utf8');
        console.log(`  ✅ Updated ${filePath}`);
      } else {
        console.log(`  ℹ️ No changes needed in ${filePath}`);
      }
    } catch (error) {
      console.error(`  ❌ Error updating ${filePath}: ${error.message}`);
    }
  }
}

// Main function
async function main() {
  console.log('🔄 Starting simple reference updates for tYDiSync~...');
  
  // Update package.json
  await updatePackageJson();
  
  // Update specific files
  await updateSpecificFiles();
  
  console.log('\n✅ Simple reference update process completed!');
}

// Run the script
main().catch(error => {
  console.error('❌ Script failed:', error);
}); 