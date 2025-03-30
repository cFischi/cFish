const fs = require('fs');
const path = require('path');
const { promisify } = require('util');
const readFileAsync = promisify(fs.readFile);
const writeFileAsync = promisify(fs.writeFile);
const readdirAsync = promisify(fs.readdir);
const statAsync = promisify(fs.stat);

// Files to update
const fileUpdates = [
  // Core files
  'tydisync-enhanced.js',
  'sync-system/core/cursor-md-json-enhanced.js',
  'sync-system/core/optimized-tydisync.js',
  'memory-optimization-integration.js',
  'sync-system/start-optimized-sync.js',
  'cursor-sync-controller.js',
  'cursor-md-json-sync.js',
  // Other files found in the search
  'sync-system/core/dummy-tydisync.js',
  'start-tydisync-silent.vbs'
];

// Import/require mappings to update
const importMappings = [
  { from: './dummy-md-json-sync', to: './dummy-tydisync' },
  { from: './dummy-md-json-sync.js', to: './dummy-tydisync.js' },
  { from: './md-json-sync', to: './tydisync' },
  { from: './md-json-sync.js', to: './tydisync.js' },
  { from: './core/optimized-md-json-sync', to: './core/optimized-tydisync' },
  { from: './core/md-json-sync', to: './core/tydisync' },
  { from: './md-json-sync-engine', to: './tydisync-engine' },
];

// Config file paths that need to be updated
const configMappings = [
  { file: 'sync-system/core/dummy-tydisync.js', replacements: [
    { from: 'md-json-sync-status.json', to: 'tydisync-status.json' },
    { from: 'md-json-sync-notifications.json', to: 'tydisync-notifications.json' }
  ]},
  { file: 'sync-system/core/optimized-tydisync.js', replacements: [
    { from: 'optimized-md-json-sync.log', to: 'optimized-tydisync.log' },
    { from: 'md-json-sync-state.json', to: 'tydisync-state.json' }
  ]},
  { file: 'sync-system/config/sync-config.json', replacements: [
    { from: 'md-json-sync-status.json', to: 'tydisync-status.json' },
    { from: 'md-json-sync-notifications.json', to: 'tydisync-notifications.json' }
  ]},
  { file: 'tydisync-engine.js', replacements: [
    { from: 'md-json-sync-engine.js', to: 'tydisync-engine.js' }
  ]},
  { file: 'start-tydisync-silent.vbs', replacements: [
    { from: 'md-json-sync.js', to: 'tydisync.js' }
  ]},
  { file: 'safe-sync.js', replacements: [
    { from: 'node md-json-sync.js', to: 'node tydisync.js' }
  ]}
];

// Function to update import statements in a JavaScript file
async function updateImports(filePath) {
  try {
    // Read the file
    const fullPath = path.resolve(process.cwd(), filePath);
    const fileContent = await readFileAsync(fullPath, 'utf8');
    
    // Apply replacements
    let updatedContent = fileContent;
    let changesCount = 0;
    
    // Update imports based on mappings
    importMappings.forEach(mapping => {
      const requireRegex = new RegExp(`require\\(['"](${mapping.from})['"]\\)`, 'g');
      const replacedContent = updatedContent.replace(requireRegex, `require('${mapping.to}')`);
      
      if (replacedContent !== updatedContent) {
        changesCount += (updatedContent.match(requireRegex) || []).length;
        updatedContent = replacedContent;
      }
    });
    
    // Update file if changes were made
    if (changesCount > 0) {
      await writeFileAsync(fullPath, updatedContent, 'utf8');
      console.log(`✅ Updated ${changesCount} imports in ${filePath}`);
      return true;
    } else {
      console.log(`ℹ️ No import updates needed in ${filePath}`);
      return false;
    }
  } catch (error) {
    console.error(`❌ Error updating ${filePath}:`, error.message);
    return false;
  }
}

// Function to update config paths and other references
async function updateConfigReferences(fileConfig) {
  try {
    const fullPath = path.resolve(process.cwd(), fileConfig.file);
    const fileContent = await readFileAsync(fullPath, 'utf8');
    
    let updatedContent = fileContent;
    let changesCount = 0;
    
    fileConfig.replacements.forEach(replacement => {
      const regex = new RegExp(replacement.from.replace(/\./g, '\\.'), 'g');
      const replacedContent = updatedContent.replace(regex, replacement.to);
      
      if (replacedContent !== updatedContent) {
        changesCount += (updatedContent.match(regex) || []).length;
        updatedContent = replacedContent;
      }
    });
    
    if (changesCount > 0) {
      await writeFileAsync(fullPath, updatedContent, 'utf8');
      console.log(`✅ Updated ${changesCount} references in ${fileConfig.file}`);
      return true;
    } else {
      console.log(`ℹ️ No reference updates needed in ${fileConfig.file}`);
      return false;
    }
  } catch (error) {
    console.error(`❌ Error updating ${fileConfig.file}:`, error.message);
    return false;
  }
}

// Main function
async function main() {
  console.log('🔄 Starting tYDiSync~ reference updates...');
  
  // Update import statements
  console.log('\n📦 Updating import statements...');
  for (const file of fileUpdates) {
    await updateImports(file);
  }
  
  // Update config references
  console.log('\n⚙️ Updating configuration references...');
  for (const configMapping of configMappings) {
    await updateConfigReferences(configMapping);
  }
  
  console.log('\n✅ Reference update process completed!');
}

// Run the script
main().catch(error => {
  console.error('❌ Script failed:', error);
}); 