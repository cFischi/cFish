const fs = require('fs');
const path = require('path');
const { promisify } = require('util');
const readFileAsync = promisify(fs.readFile);
const writeFileAsync = promisify(fs.writeFile);

// Current date in MM-DD-YYYY format
const currentDate = new Date().toLocaleDateString('en-US', {
  month: '2-digit',
  day: '2-digit',
  year: 'numeric'
}).replace(/(\d+)\/(\d+)\/(\d+)/, '$1-$2-$3');

// Memory entry content
const memoryEntry = `## tYDiSync~ Reference Updates Completed (${currentDate})

The tYDiSync~ rebranding has been fully completed with all code references successfully updated from the old "md-json-sync" naming convention to the new "tydisync" branding. This includes:

- All import/require statements in JavaScript files
- All file paths and references in configuration files
- All commands and references in batch files
- All documentation references in markdown files
- All VBS script references
- All log and state file naming conventions

The update was verified using the \`verify-tydisync-references.js\` script, which confirmed that all relevant references have been updated. This completes the tYDiSync~ rebranding project, with all files now consistently using the new naming convention both in filenames and internal references.

_Updated ${currentDate} | AI: Cursor (Claude 3.7 Sonnet)_

`;

// Function to add entry to memory.md
async function addMemoryEntry() {
  try {
    const memoryPath = path.resolve(process.cwd(), 'memory.md');
    
    // Check if memory.md exists
    if (!fs.existsSync(memoryPath)) {
      console.error('❌ memory.md not found in the current directory');
      return false;
    }
    
    // Read the memory.md file
    const memoryContent = await readFileAsync(memoryPath, 'utf8');
    
    // Find the position of "Next Steps" section to insert before it
    const nextStepsIndex = memoryContent.indexOf('## Next Steps');
    
    if (nextStepsIndex === -1) {
      // If "Next Steps" section not found, append to the end
      const updatedContent = memoryContent + '\n\n' + memoryEntry;
      await writeFileAsync(memoryPath, updatedContent, 'utf8');
    } else {
      // Insert before the "Next Steps" section
      const contentBeforeNextSteps = memoryContent.substring(0, nextStepsIndex);
      const contentFromNextSteps = memoryContent.substring(nextStepsIndex);
      const updatedContent = contentBeforeNextSteps + memoryEntry + '\n' + contentFromNextSteps;
      await writeFileAsync(memoryPath, updatedContent, 'utf8');
    }
    
    console.log('✅ Successfully updated memory.md with final tYDiSync~ entry');
    return true;
  } catch (error) {
    console.error('❌ Error updating memory.md:', error.message);
    return false;
  }
}

// Function to update changelog.md
async function updateChangelog() {
  try {
    const changelogPath = path.resolve(process.cwd(), 'changelog.md');
    
    // Check if changelog.md exists
    if (!fs.existsSync(changelogPath)) {
      console.error('❌ changelog.md not found in the current directory');
      return false;
    }
    
    // Format date in ISO format (YYYY-MM-DD)
    const isoDate = new Date().toISOString().split('T')[0];
    
    // Changelog entry
    const changelogEntry = `## 1.2.0 - ${isoDate}

### Changed
- Completed all reference updates from "md-json-sync" to "tydisync" throughout the codebase
- Updated all import/require statements in JavaScript files
- Updated all commands and references in batch files
- Updated all documentation references
- Updated all configuration file paths

### Fixed
- Fixed inconsistencies between actual filenames and internal references
- Fixed batch files to point to correct tydisync files
- Fixed log and state file references to use the new naming convention
`;
    
    // Read the changelog.md file
    const changelogContent = await readFileAsync(changelogPath, 'utf8');
    
    // Add to the top of the changelog
    const updatedContent = changelogEntry + '\n' + changelogContent;
    await writeFileAsync(changelogPath, updatedContent, 'utf8');
    
    console.log('✅ Successfully updated changelog.md with tYDiSync~ reference updates');
    return true;
  } catch (error) {
    console.error('❌ Error updating changelog.md:', error.message);
    return false;
  }
}

// Main function
async function main() {
  console.log('🔄 Updating documentation with final tYDiSync~ entries...');
  
  // Update memory.md
  await addMemoryEntry();
  
  // Update changelog.md
  await updateChangelog();
  
  console.log('\n✅ Documentation update completed!');
}

// Run the script
main().catch(error => {
  console.error('❌ Script failed:', error);
}); 