/**
 * Test script for Cursor MD-JSON Sync Integration
 * This script checks if the cursor integration is properly configured.
 * 
 * Usage:
 * node test-cursor-integration.js
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// Test paths and configuration
const cursorFlagFile = path.join(__dirname, '.cursor-running');
const integrationFiles = [
  'cursor-tydisync-enhanced.js',
  'setup-cursor-integration.ps1',
  'start-enhanced-sync.bat'
];

// Check if files exist
console.log('📋 Checking required files...');
const missingFiles = [];
integrationFiles.forEach(file => {
  if (!fs.existsSync(path.join(__dirname, file))) {
    missingFiles.push(file);
  }
});

if (missingFiles.length > 0) {
  console.error('❌ Missing required files:', missingFiles.join(', '));
} else {
  console.log('✅ All required files present.');
}

// Check if cursor flag exists
console.log('🔍 Checking if Cursor integration flag exists...');
if (fs.existsSync(cursorFlagFile)) {
  console.log('✅ Cursor flag file (.cursor-running) found. Integration active.');
} else {
  console.log('⚠️ Cursor flag file not found. This is normal if Cursor is not running.');
  console.log('   The flag should appear when the integration script is running with Cursor.');
}

// Check scheduled task
console.log('🔍 Checking scheduled task...');
try {
  const taskOutput = execSync('schtasks /query /tn "MD-JSON-Sync-Cursor-Integration" /fo list').toString();
  console.log('✅ Task found. Details:');
  console.log(taskOutput.split('\n').slice(0, 5).join('\n') + '\n...');
} catch (error) {
  console.log('⚠️ Task not found or cannot be accessed. You may need to run the setup script.');
  console.log('   Run: powershell -ExecutionPolicy Bypass -File setup-cursor-integration.ps1');
}

// Provide next steps
console.log('\n📝 Recommended next steps:');
console.log('1. Fix any issues reported above');
console.log('2. Run the setup script if not already done:');
console.log('   cd C:\\Users\\Chris\\cFish.io');
console.log('   powershell -ExecutionPolicy Bypass -File setup-cursor-integration.ps1');
console.log('3. Test the enhanced script manually:');
console.log('   node cursor-tydisync-enhanced.js');
console.log('4. Open Cursor IDE to see if the integration activates automatically');
console.log('\nCheck memory.md and README-cursor-integration.md for more detailed instructions.'); 