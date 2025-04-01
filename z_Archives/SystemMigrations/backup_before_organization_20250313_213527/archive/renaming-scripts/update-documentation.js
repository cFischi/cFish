const fs = require('fs');
const path = require('path');
const { promisify } = require('util');
const readFileAsync = promisify(fs.readFile);
const writeFileAsync = promisify(fs.writeFile);

// Documentation files to update
const docsToUpdate = [
  'tydisync-quick-reference.md',
  'tydisync-system-summary.md',
  'safe-sync-system.md',
  'tydisync-next-steps.md',
  'sync-system/README.md'
];

// Define documentation replacements
const docReplacements = [
  { from: 'node md-json-sync.js', to: 'node tydisync.js' },
  { from: 'md-json-sync.js', to: 'tydisync.js' },
  { from: 'start-md-json-sync.bat', to: 'start-tydisync.bat' },
  { from: 'start-md-json-sync-background.bat', to: 'start-tydisync-background.bat' },
  { from: './logs/md-json-sync.log', to: './logs/tydisync.log' },
  { from: 'logs/md-json-sync.log', to: 'logs/tydisync.log' },
  { from: 'dummy-md-json-sync.js', to: 'dummy-tydisync.js' },
  { from: 'optimized-md-json-sync.js', to: 'optimized-tydisync.js' },
  { from: 'cursor-md-json-sync.js', to: 'cursor-tydisync.js' },
  { from: 'md-json-sync-engine.js', to: 'tydisync-engine.js' }
];

// File specific replacements
const fileSpecificReplacements = {
  'tydisync-engine.js': [
    { from: '* md-json-sync-engine.js', to: '* tydisync-engine.js' }
  ],
  'sync-system/core/optimized-tydisync.js': [
    { from: 'optimized-md-json-sync.log', to: 'optimized-tydisync.log' },
    { from: 'md-json-sync-state.json', to: 'tydisync-state.json' }
  ],
  'sync-system/core/dummy-tydisync.js': [
    { from: 'md-json-sync-status.json', to: 'tydisync-status.json' },
    { from: 'md-json-sync-notifications.json', to: 'tydisync-notifications.json' }
  ],
  'sync-system/config/sync-config.json': [
    { from: 'md-json-sync-status.json', to: 'tydisync-status.json' },
    { from: 'md-json-sync-notifications.json', to: 'tydisync-notifications.json' }
  ]
};

// Function to update markdown documentation
async function updateDocumentation(filePath) {
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
    
    // Apply file-specific replacements if they exist
    const filename = path.basename(filePath);
    if (fileSpecificReplacements[filePath]) {
      for (const replacement of fileSpecificReplacements[filePath]) {
        const regex = new RegExp(replacement.from.replace(/\./g, '\\.').replace(/\//g, '\\/'), 'g');
        const beforeContent = updatedContent;
        updatedContent = updatedContent.replace(regex, replacement.to);
        
        // Count changes
        if (beforeContent !== updatedContent) {
          const matches = beforeContent.match(regex) || [];
          changesCount += matches.length;
        }
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
  console.log('🔄 Starting documentation updates for tYDiSync~...');
  
  // Update all documentation files
  const results = [];
  for (const docFile of docsToUpdate) {
    const result = await updateDocumentation(docFile);
    results.push(result);
  }
  
  // Update file-specific files
  for (const filePath in fileSpecificReplacements) {
    if (!docsToUpdate.includes(filePath)) {
      const result = await updateDocumentation(filePath);
      results.push(result);
    }
  }
  
  // Summary
  const successCount = results.filter(r => r.success).length;
  const totalChanges = results.reduce((sum, r) => sum + r.changes, 0);
  const failedFiles = results.filter(r => !r.success).map(r => r.filePath);
  
  console.log('\n📊 Documentation Update Summary:');
  console.log(`- Successfully updated: ${successCount}/${results.length} files`);
  console.log(`- Total changes made: ${totalChanges}`);
  
  if (failedFiles.length > 0) {
    console.log(`- Failed to update: ${failedFiles.length} files`);
    console.log('  - ' + failedFiles.join('\n  - '));
  }
  
  console.log('\n✅ Documentation update process completed!');
}

// Run the script
main().catch(error => {
  console.error('❌ Script failed:', error);
}); 