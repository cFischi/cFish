#!/usr/bin/env node

/**
 * tYDiSync~ Changelog Updater
 * This script adds a version entry to changelog.md for the file renaming process
 */

const fs = require('fs');
const { promisify } = require('util');
const readFile = promisify(fs.readFile);
const writeFile = promisify(fs.writeFile);

// Format date as YYYY-MM-DD
function formatDateISO() {
  const now = new Date();
  const year = now.getFullYear();
  const month = String(now.getMonth() + 1).padStart(2, '0');
  const day = String(now.getDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
}

async function updateChangelogMd() {
  const changelogPath = './changelog.md';
  const formattedDate = formatDateISO();
  
  try {
    // Read changelog.md
    const content = await readFile(changelogPath, 'utf8');
    
    // Define the new changelog entry
    const newEntry = `## [1.3.0] - ${formattedDate}

### Added
- New rebranded filenames using tYDiSync~ naming convention
- Complete file renaming process with git history preservation

### Changed
- Renamed all files from "md-json-sync-*" prefix to "tydisync-*" prefix
- Renamed documentation files for consistency with new branding
- Updated all internal references to use new filenames 
- Updated memory.md with comprehensive documentation about the renaming process

### Fixed
- Fixed inconsistency between file content (using new branding) and filenames (using old convention)
- Resolved potential confusion from mismatched naming in documentation and implementation

`;
    
    // Find where to insert the new entry (after the changelog header)
    const headerPos = content.indexOf('# Changelog');
    if (headerPos === -1) {
      console.error('Could not find "# Changelog" header in changelog.md');
      return;
    }
    
    // Find the end of the header section
    const headerEndPos = content.indexOf('\n', headerPos);
    if (headerEndPos === -1) {
      console.error('Could not find end of header in changelog.md');
      return;
    }
    
    // Insert the new entry after the header (and any descriptive text)
    // Look for the first version entry
    const firstVersionPos = content.indexOf('## [', headerEndPos);
    if (firstVersionPos === -1) {
      console.error('Could not find any version entries in changelog.md');
      return;
    }
    
    // Insert the new entry before the first existing version entry
    const updatedContent = 
      content.slice(0, firstVersionPos) + 
      newEntry + 
      content.slice(firstVersionPos);
    
    // Write the updated content back to changelog.md
    await writeFile(changelogPath, updatedContent, 'utf8');
    
    console.log(`Successfully updated changelog.md with entry for version 1.3.0`);
  } catch (error) {
    console.error('Error updating changelog.md:', error);
  }
}

// Run the update function
updateChangelogMd().catch(console.error); 