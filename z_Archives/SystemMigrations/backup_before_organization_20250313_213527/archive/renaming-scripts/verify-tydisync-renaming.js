#!/usr/bin/env node

/**
 * tYDiSync~ Renaming Verification
 * This script verifies that the system still functions correctly after renaming
 */

const fs = require('fs');
const path = require('path');
const { promisify } = require('util');
const { exec } = require('child_process');

const readdir = promisify(fs.readdir);
const stat = promisify(fs.stat);
const readFile = promisify(fs.readFile);
const execAsync = promisify(exec);

// Files that have been renamed
const renamedFiles = [
  { old: 'md-json-sync-status-report.md', new: 'tydisync-status-report.md' },
  { old: 'md-json-sync-debug.log', new: 'tydisync-debug.log' },
  { old: 'md-json-sync-low-cpu-reference.md', new: 'tydisync-low-cpu-reference.md' },
  { old: 'md-json-sync-implementation-verification.md', new: 'tydisync-implementation-verification.md' },
  { old: 'md-json-sync-system-summary.md', new: 'tydisync-system-summary.md' },
  { old: 'md-json-sync-testing-findings.md', new: 'tydisync-testing-findings.md' },
  { old: 'md-json-sync-next-steps.md', new: 'tydisync-next-steps.md' },
  { old: 'README-md-json-sync.md', new: 'README-tydisync.md' },
  { old: 'md-json-sync-quick-reference.md', new: 'tydisync-quick-reference.md' },
  { old: 'start-md-json-sync-silent.vbs', new: 'start-tydisync-silent.vbs' }
];

// Script files to test for errors
const scriptFiles = [
  'sync-system/core/md-json-sync.js',
  'sync-system/agents/alpha-agent.js',
  'sync-system/agents/beta-agent.js',
  'sync-system/agents/delta-agent.js',
  'start-tydisync-silent.vbs'
];

// Check that old files are gone and new files exist
async function verifyFileRenaming() {
  console.log('Verifying file renaming...');
  let errors = 0;
  
  for (const file of renamedFiles) {
    try {
      // Check if old file exists (it shouldn't)
      try {
        await stat(file.old);
        console.error(`❌ ERROR: Old file ${file.old} still exists`);
        errors++;
      } catch (err) {
        if (err.code === 'ENOENT') {
          console.log(`✅ Old file ${file.old} correctly removed`);
        } else {
          throw err;
        }
      }
      
      // Check if new file exists
      try {
        await stat(file.new);
        console.log(`✅ New file ${file.new} exists`);
      } catch (err) {
        console.error(`❌ ERROR: New file ${file.new} does not exist`);
        errors++;
      }
    } catch (error) {
      console.error(`Error verifying ${file.old} → ${file.new}:`, error);
      errors++;
    }
  }
  
  return errors === 0;
}

// Check for references to old filenames
async function verifyNoRemainingReferences() {
  console.log('\nChecking for remaining references to old filenames...');
  let errors = 0;
  
  for (const file of renamedFiles) {
    try {
      // Use grep to find references to old filenames
      const { stdout } = await execAsync(`grep -r "${file.old}" --include="*.js" --include="*.md" --include="*.json" --include="*.bat" --include="*.vbs" .`);
      
      if (stdout.trim()) {
        console.error(`❌ Found references to ${file.old} in:`);
        console.error(stdout);
        errors++;
      } else {
        console.log(`✅ No references to ${file.old} found`);
      }
    } catch (error) {
      // grep returns non-zero exit code when no matches found, which is what we want
      if (error.code === 1 && !error.stdout.trim()) {
        console.log(`✅ No references to ${file.old} found`);
      } else {
        console.error(`Error checking references to ${file.old}:`, error);
        errors++;
      }
    }
  }
  
  return errors === 0;
}

// Verify that scripts can be parsed without syntax errors
async function verifyScriptParsing() {
  console.log('\nVerifying script syntax...');
  let errors = 0;
  
  for (const script of scriptFiles) {
    try {
      if (script.endsWith('.js')) {
        // Use Node.js to check syntax
        await execAsync(`node --check "${script}"`);
        console.log(`✅ Script ${script} parses correctly`);
      } else if (script.endsWith('.vbs')) {
        // VBS syntax can't be easily checked without executing, so we'll just check file exists
        await stat(script);
        console.log(`✅ Script ${script} exists`);
      }
    } catch (error) {
      console.error(`❌ ERROR: Script ${script} has syntax errors:`, error.message);
      errors++;
    }
  }
  
  return errors === 0;
}

// Main verification function
async function verifyRenaming() {
  console.log('tYDiSync~ Renaming Verification');
  console.log('==============================\n');
  
  let allTestsPassed = true;
  
  // Check file renaming
  const fileRenamingPassed = await verifyFileRenaming();
  allTestsPassed = allTestsPassed && fileRenamingPassed;
  
  // Check for remaining references
  const noRemainingRefsPassed = await verifyNoRemainingReferences();
  allTestsPassed = allTestsPassed && noRemainingRefsPassed;
  
  // Check script syntax
  const scriptParsingPassed = await verifyScriptParsing();
  allTestsPassed = allTestsPassed && scriptParsingPassed;
  
  // Print summary
  console.log('\n==============================');
  if (allTestsPassed) {
    console.log('✅ All verification tests passed!');
    console.log('The renaming process was successful.');
  } else {
    console.error('❌ Some verification tests failed.');
    console.error('Please review the errors above and fix any issues.');
  }
  
  return allTestsPassed;
}

// Run the verification
verifyRenaming().then(passed => {
  process.exit(passed ? 0 : 1);
}).catch(error => {
  console.error('An error occurred during verification:', error);
  process.exit(1);
}); 