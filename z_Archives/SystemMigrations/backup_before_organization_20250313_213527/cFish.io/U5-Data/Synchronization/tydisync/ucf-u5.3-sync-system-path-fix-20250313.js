/**
 * ucf-u5.3-sync-system-path-fix-20250313.js
 * This script fixes path issues in the tYDiSync~ system
 * Department: U5 - Data Management
 * Function: 3 - Data Migration
 */

const fs = require('fs');
const path = require('path');

// Configuration
const CONFIG = {
  configPath: path.join(__dirname, 'config', 'sync-config.json'),
  stateDir: path.join(__dirname, 'state'),
  backupDir: path.join(__dirname, '..', 'backups', 'sync-system-config'),
  logFile: path.join(__dirname, '..', 'logs', 'sync-system-path-fix.log')
};

// Initialize logging
function log(message, level = 'INFO') {
  const timestamp = new Date().toISOString();
  const logMessage = `[${timestamp}] [${level}] ${message}`;
  
  console.log(logMessage);
  
  // Ensure log directory exists
  const logDir = path.dirname(CONFIG.logFile);
  if (!fs.existsSync(logDir)) {
    fs.mkdirSync(logDir, { recursive: true });
  }
  
  // Append to log file
  fs.appendFileSync(CONFIG.logFile, logMessage + '\n');
}

// Ensure directories exist
function ensureDirectoriesExist() {
  const dirs = [
    CONFIG.stateDir,
    CONFIG.backupDir
  ];
  
  for (const dir of dirs) {
    if (!fs.existsSync(dir)) {
      log(`Creating directory: ${dir}`);
      fs.mkdirSync(dir, { recursive: true });
    }
  }
}

// Backup the config file
function backupConfig() {
  if (!fs.existsSync(CONFIG.configPath)) {
    log(`Config file not found at: ${CONFIG.configPath}`, 'ERROR');
    return false;
  }
  
  const backupPath = path.join(
    CONFIG.backupDir, 
    `tydisync-config-${new Date().toISOString().replace(/:/g, '-')}.json.backup`
  );
  
  try {
    fs.copyFileSync(CONFIG.configPath, backupPath);
    log(`Config backup created at: ${backupPath}`, 'SUCCESS');
    return true;
  } catch (err) {
    log(`Failed to create config backup: ${err.message}`, 'ERROR');
    return false;
  }
}

// Fix paths in config
function fixConfigPaths() {
  try {
    // Read the current config
    if (!fs.existsSync(CONFIG.configPath)) {
      log(`Config file not found at: ${CONFIG.configPath}`, 'ERROR');
      return false;
    }
    
    const configData = fs.readFileSync(CONFIG.configPath, 'utf8');
    let config = JSON.parse(configData);
    
    // Save original paths for reporting
    const originalStatusPath = config.uiSettings?.statusFilePath || 'sync-system/state/md-json-sync-status.json';
    const originalNotificationsPath = config.uiSettings?.notificationsFilePath || 'sync-system/state/md-json-sync-notifications.json';
    
    // Update path configurations
    if (config.uiSettings) {
      config.uiSettings.statusFilePath = 'state/md-json-sync-status.json';
      config.uiSettings.notificationsFilePath = 'state/md-json-sync-notifications.json';
      log(`Updated UI settings paths:`, 'INFO');
      log(`  Status file: ${originalStatusPath} -> ${config.uiSettings.statusFilePath}`, 'INFO');
      log(`  Notifications file: ${originalNotificationsPath} -> ${config.uiSettings.notificationsFilePath}`, 'INFO');
    }
    
    // Update state directory path
    if (config.stateDirectory && config.stateDirectory.includes('sync-system\\sync-system')) {
      const originalStateDir = config.stateDirectory;
      config.stateDirectory = path.join(__dirname, 'state');
      log(`Updated state directory path:`, 'INFO');
      log(`  ${originalStateDir} -> ${config.stateDirectory}`, 'INFO');
    }
    
    // Write the updated config
    fs.writeFileSync(CONFIG.configPath, JSON.stringify(config, null, 2), 'utf8');
    log(`Config file updated successfully`, 'SUCCESS');
    return true;
  } catch (err) {
    log(`Failed to update config: ${err.message}`, 'ERROR');
    return false;
  }
}

// Create state files if they don't exist
function ensureStateFiles() {
  const stateFiles = [
    { 
      path: path.join(CONFIG.stateDir, 'md-json-sync-status.json'),
      content: { 
        status: 'ready', 
        lastUpdated: new Date().toISOString(),
        version: '0.5.0'
      }
    },
    { 
      path: path.join(CONFIG.stateDir, 'md-json-sync-notifications.json'),
      content: { 
        notifications: [{
          id: '1',
          type: 'info',
          message: 'System path configuration updated',
          timestamp: new Date().toISOString()
        }]
      }
    }
  ];
  
  for (const file of stateFiles) {
    if (!fs.existsSync(file.path)) {
      try {
        fs.writeFileSync(file.path, JSON.stringify(file.content, null, 2), 'utf8');
        log(`Created state file: ${file.path}`, 'SUCCESS');
      } catch (err) {
        log(`Failed to create state file ${file.path}: ${err.message}`, 'ERROR');
      }
    }
  }
}

// Main function
async function main() {
  log('Starting sync system path fix script', 'INFO');
  
  // Step 1: Ensure directories exist
  ensureDirectoriesExist();
  
  // Step 2: Backup the config
  if (!backupConfig()) {
    log('Failed to backup config, aborting', 'ERROR');
    return;
  }
  
  // Step 3: Fix paths in config
  if (!fixConfigPaths()) {
    log('Failed to update config paths, aborting', 'ERROR');
    return;
  }
  
  // Step 4: Create state files if needed
  ensureStateFiles();
  
  log('Sync system path fix completed successfully', 'SUCCESS');
  log('You should restart the sync system to apply these changes', 'INFO');
}

// Run the script
main().catch(err => {
  log(`Unhandled error: ${err.message}`, 'ERROR');
  process.exit(1);
}); 