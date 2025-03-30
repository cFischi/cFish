/**
 * ucf-u5.3-sync-system-path-fix-20250313.js
 * 
 * This script updates path references in tYDiSync configuration files
 * after the system has been moved to its new location in the
 * cFish.io directory structure.
 */

const fs = require('fs');
const path = require('path');

// Define the old and new base paths
const OLD_BASE_PATH = 'sync-system';
const NEW_BASE_PATH = 'cFish.io/U5-Data/Synchronization/tydisync';

// Configuration files that need path updates
const CONFIG_FILES = [
  'cFish.io/U5-Data/Synchronization/tydisync/config/paths.json',
  'cFish.io/U5-Data/Synchronization/tydisync/config/sync-config.json',
  'cFish.io/U5-Data/Synchronization/tydisync/start-optimized-sync.js'
];

// Function to update paths in a file
function updatePaths(filePath) {
  console.log(`Updating paths in ${filePath}...`);
  
  try {
    // Check if file exists
    if (!fs.existsSync(filePath)) {
      console.log(`  File not found: ${filePath}`);
      return false;
    }
    
    // Read file content
    let content = fs.readFileSync(filePath, 'utf8');
    
    // Count original references
    const originalReferences = (content.match(new RegExp(OLD_BASE_PATH.replace(/\//g, '[/\\\\]'), 'g')) || []).length;
    
    // Replace path references
    const updatedContent = content.replace(
      new RegExp(OLD_BASE_PATH.replace(/\//g, '[/\\\\]'), 'g'),
      NEW_BASE_PATH
    );
    
    // Count updated references
    const updatedReferences = (updatedContent.match(new RegExp(NEW_BASE_PATH.replace(/\//g, '[/\\\\]'), 'g')) || []).length;
    
    // Write updated content back to file
    fs.writeFileSync(filePath, updatedContent, 'utf8');
    
    console.log(`  Updated ${originalReferences} path references`);
    return true;
  } catch (error) {
    console.error(`  Error updating ${filePath}: ${error.message}`);
    return false;
  }
}

// Function to search for additional config files
function findAdditionalConfigFiles() {
  const baseDir = 'cFish.io/U5-Data/Synchronization/tydisync';
  const results = [];
  
  // Helper function for recursive search
  function searchDir(dir) {
    const files = fs.readdirSync(dir);
    
    for (const file of files) {
      const filePath = path.join(dir, file);
      const stat = fs.statSync(filePath);
      
      if (stat.isDirectory()) {
        searchDir(filePath);
      } else if (
        (file.endsWith('.json') || file.endsWith('.js') || file.endsWith('.md')) &&
        !CONFIG_FILES.includes(filePath)
      ) {
        // Read file to check if it contains the old path
        const content = fs.readFileSync(filePath, 'utf8');
        if (content.includes(OLD_BASE_PATH) || content.includes(OLD_BASE_PATH.replace(/\//g, '\\'))) {
          results.push(filePath);
        }
      }
    }
  }
  
  try {
    searchDir(baseDir);
  } catch (error) {
    console.error(`Error searching for config files: ${error.message}`);
  }
  
  return results;
}

// Main execution
console.log('tYDiSync Path Fix Script');
console.log('==============================================');
console.log(`Updating path references from '${OLD_BASE_PATH}' to '${NEW_BASE_PATH}'`);

// Update paths in known config files
let updatedFiles = 0;
for (const file of CONFIG_FILES) {
  if (updatePaths(file)) {
    updatedFiles++;
  }
}

// Find and update additional files
console.log('\nSearching for additional files with path references...');
const additionalFiles = findAdditionalConfigFiles();

if (additionalFiles.length > 0) {
  console.log(`Found ${additionalFiles.length} additional files with path references`);
  
  for (const file of additionalFiles) {
    if (updatePaths(file)) {
      updatedFiles++;
    }
  }
} else {
  console.log('No additional files found with path references');
}

console.log('\nPath update summary:');
console.log(`Total files updated: ${updatedFiles}`);
console.log('==============================================');
console.log('Next steps: Restart tYDiSync with the new paths'); 