# CursorFocus Integration Guide for cFish.io

## Overview
This document provides step-by-step instructions for setting up and configuring CursorFocus for the cFish.io project. CursorFocus is a tool that automatically tracks project files, functions, and environment variables, providing a lightweight focused view of your project structure.

## Prerequisites
- Node.js (v14 or higher)
- Git
- Administrator privileges (for some installation steps)
- Cursor IDE installed

## Installation Process

### Step 1: Clone the CursorFocus Repository
```bash
git clone https://github.com/RenjiYuusei/CursorFocus.git
cd CursorFocus
```

### Step 2: Install Dependencies
```bash
npm install
```

### Step 3: Configure for cFish.io Project
1. Create a configuration file named `cursorfocus-config.json` in the project root:
```json
{
  "projectName": "cFish.io",
  "trackingInterval": 60000,
  "fileTypes": [".php", ".js", ".css", ".md", ".json", ".html"],
  "ignoreFolders": ["node_modules", ".git", "backups"],
  "trackFunctions": true,
  "trackEnvVars": true,
  "autoUpdateRules": true,
  "rulesPath": ".cursorrules",
  "outputPath": "./focus-output"
}
```

2. Modify the CursorFocus installation to use this configuration:
```bash
cp cursorfocus-config.json /path/to/CursorFocus/config/
```

### Step 4: Set Up Auto-Start (Optional)
1. For Windows:
   - Create a shortcut to the CursorFocus startup script
   - Place the shortcut in the Windows Startup folder

2. For macOS:
   - Add CursorFocus to Login Items in System Preferences

3. For Linux:
   - Add CursorFocus to startup applications

### Step 5: Integration with Documentation System
1. Create a script to synchronize CursorFocus output with documentation:
```javascript
// sync-focus-docs.js
const fs = require('fs');
const path = require('path');

const focusOutputPath = './focus-output';
const docsPath = './Documentation';

// Read the latest focus output
const focusData = JSON.parse(fs.readFileSync(
  path.join(focusOutputPath, 'latest.json'), 
  'utf8'
));

// Update documentation
// ... (implementation details)

console.log('Documentation synchronized with CursorFocus data');
```

2. Set up a scheduled task to run this script periodically

### Step 6: Setup Automatic .cursorrules Updates
1. Create a script to update .cursorrules based on focus data:
```javascript
// update-cursorrules.js
const fs = require('fs');
const path = require('path');

const focusOutputPath = './focus-output';
const rulesPath = './.cursorrules';

// Read the latest focus output
const focusData = JSON.parse(fs.readFileSync(
  path.join(focusOutputPath, 'latest.json'), 
  'utf8'
));

// Read current rules
let rules = JSON.parse(fs.readFileSync(rulesPath, 'utf8'));

// Update rules based on focus data
// ... (implementation details)

// Write updated rules
fs.writeFileSync(rulesPath, JSON.stringify(rules, null, 2));

console.log('.cursorrules file updated based on CursorFocus data');
```

2. Set up a scheduled task to run this script weekly

## Testing the Integration

### Basic Functionality Test
1. Start CursorFocus:
```bash
cd /path/to/CursorFocus
npm start
```

2. Verify output is being generated in the focus-output directory
3. Check that relevant files and functions are being tracked
4. Ensure tracking updates occur at the specified interval (default: 60 seconds)

### Documentation Sync Test
1. Run the sync script manually:
```bash
node sync-focus-docs.js
```

2. Verify documentation reflects the current project structure
3. Check for any errors in the synchronization process

### .cursorrules Update Test
1. Run the update script manually:
```bash
node update-cursorrules.js
```

2. Verify .cursorrules file contains updated information
3. Test the updated rules with the Cursor AI to ensure functionality

## Troubleshooting

### Common Issues and Solutions

1. **Permission Denied Errors**
   - Solution: Run the installation with administrator privileges
   - Alternative: Modify file permissions on relevant directories

2. **Node.js Version Conflicts**
   - Solution: Use nvm to switch to a compatible Node.js version
   - Alternative: Update the CursorFocus code to support your Node.js version

3. **Integration Script Errors**
   - Solution: Check file paths and JSON formatting
   - Alternative: Implement better error handling in the scripts

4. **CursorFocus Not Tracking Files**
   - Solution: Verify configuration file settings for file types and ignored folders
   - Alternative: Run with verbose logging to diagnose tracking issues

## Alternative Integration Approaches

If administrator privileges are not available or the standard installation is problematic:

1. **Browser-Based Integration**
   - Use the CursorFocus web dashboard without local integration
   - Configure manual uploads of project structure data

2. **Simplified Tracking**
   - Implement a basic version that only tracks file changes
   - Remove dependency on administrator privileges

3. **Manual Update Mode**
   - Disable automatic updates
   - Set up a manual process for updating documentation and rules

## Maintenance

### Regular Tasks
1. Update CursorFocus to the latest version monthly
2. Review and optimize tracking configuration quarterly
3. Validate integration with documentation system after major project changes
4. Monitor performance impact and adjust tracking frequency if needed

### Performance Optimization
1. Increase tracking interval for large projects
2. Be selective about file types to track
3. Use more specific ignore patterns for better performance
4. Consider disabling function tracking for very large codebase

## Next Steps
1. Implement full integration with documentation system
2. Set up automated tests for the integration
3. Develop custom dashboards for focus data
4. Train team members on using the CursorFocus data effectively

_Created 05-06-2025 | AI: Cursor (Claude 3.7 Sonnet)_ 