/**
 * tYDiSync~ - Delta Agent
 * 
 * The Delta Agent is responsible for system safety, including file locking,
 * backup management, and preventing concurrent modifications. It ensures
 * data integrity during synchronization operations.
 * 
 * Part of the tY FischEYe ecosystem connecting with the "Dreamflo ~" philosophy
 * 
 * @version 1.2.0
 */

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const EventEmitter = require('events');

class DeltaAgent extends EventEmitter {
  constructor(config) {
    super();
    this.config = config;
    this.backupDir = config.backupDir || './backups';
    this.maxBackups = config.maxBackups || 5;
    this.enableBackups = config.enableBackups !== false;
    this.activeLocks = new Map();
    this.transactionLog = [];
    this.lockFileExtension = '.lock';
  }

  /**
   * Initialize the safety manager
   */
  async initialize() {
    console.log('🔐 Delta Agent: Initializing safety manager');
    
    // Ensure backup directory exists
    if (this.enableBackups) {
      await this.ensureBackupDirectory();
      console.log(`✅ Delta Agent: Backup directory ready at ${this.backupDir}`);
    } else {
      console.log(`⚠️ Delta Agent: Backups are disabled in configuration`);
    }
    
    // Clean up any stale locks at startup
    await this.cleanupStaleLocks();
    
    console.log('✅ Delta Agent: Safety manager initialized');
    return this;
  }

  /**
   * Create a backup of a file before modification
   * @param {string} filePath The file to back up
   * @returns {Promise<Object>} Information about the backup
   */
  async createBackup(filePath) {
    if (!this.enableBackups) {
      return { success: false, reason: 'backups-disabled' };
    }
    
    try {
      // Check if file exists
      if (!await this.fileExists(filePath)) {
        return { success: false, reason: 'file-not-found' };
      }
      
      // Generate backup filename with timestamp
      const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
      const fileName = path.basename(filePath);
      const backupFileName = `${fileName}.${timestamp}.backup`;
      const backupPath = path.join(this.backupDir, backupFileName);
      
      // Copy the file
      await fs.promises.copyFile(filePath, backupPath);
      
      console.log(`✓ Delta Agent: Created backup of ${filePath} to ${backupPath}`);
      
      // Rotate old backups if needed
      await this.rotateBackups(fileName);
      
      // Log the backup
      this.transactionLog.push({
        action: 'backup',
        source: filePath,
        target: backupPath,
        timestamp: new Date().toISOString()
      });
      
      return {
        success: true,
        backupPath: backupPath,
        timestamp: timestamp
      };
      
    } catch (error) {
      console.error(`❌ Delta Agent: Backup creation failed for ${filePath}: ${error.message}`);
      return {
        success: false,
        reason: error.message
      };
    }
  }

  /**
   * Rotate old backups to maintain the maximum number
   * @param {string} fileName The base file name
   * @returns {Promise<void>}
   */
  async rotateBackups(fileName) {
    try {
      // Get all backups for this file
      const files = await fs.promises.readdir(this.backupDir);
      const backups = files.filter(f => f.startsWith(fileName) && f.endsWith('.backup'))
                          .map(f => path.join(this.backupDir, f));
      
      // Sort by creation time, most recent first
      const sortedBackups = await Promise.all(backups.map(async (backupPath) => {
        const stats = await fs.promises.stat(backupPath);
        return {
          path: backupPath,
          time: stats.mtime.getTime()
        };
      }));
      
      sortedBackups.sort((a, b) => b.time - a.time);
      
      // Remove oldest backups if we have too many
      if (sortedBackups.length > this.maxBackups) {
        const toRemove = sortedBackups.slice(this.maxBackups);
        
        for (const backup of toRemove) {
          await fs.promises.unlink(backup.path);
          console.log(`ℹ️ Delta Agent: Removed old backup ${backup.path}`);
        }
      }
      
    } catch (error) {
      console.error(`⚠️ Delta Agent: Error rotating backups: ${error.message}`);
      // Non-fatal error, continue execution
    }
  }

  /**
   * Restore a file from its latest backup
   * @param {string} filePath The file to restore
   * @returns {Promise<Object>} Information about the restoration
   */
  async restoreFromBackup(filePath) {
    try {
      const fileName = path.basename(filePath);
      
      // Find all backups for this file
      const files = await fs.promises.readdir(this.backupDir);
      const backups = files.filter(f => f.startsWith(fileName) && f.endsWith('.backup'))
                           .map(f => path.join(this.backupDir, f));
      
      if (backups.length === 0) {
        console.error(`❌ Delta Agent: No backups found for ${filePath}`);
        return {
          success: false,
          reason: 'no-backups-found'
        };
      }
      
      // Sort by creation time, most recent first
      const sortedBackups = await Promise.all(backups.map(async (backupPath) => {
        const stats = await fs.promises.stat(backupPath);
        return {
          path: backupPath,
          time: stats.mtime.getTime()
        };
      }));
      
      sortedBackups.sort((a, b) => b.time - a.time);
      
      // Use the most recent backup
      const latestBackup = sortedBackups[0].path;
      
      // Create a backup of the current file if it exists
      if (await this.fileExists(filePath)) {
        await this.createBackup(filePath);
      }
      
      // Copy the backup to the original location
      await fs.promises.copyFile(latestBackup, filePath);
      
      console.log(`✅ Delta Agent: Restored ${filePath} from backup ${latestBackup}`);
      
      // Log the restoration
      this.transactionLog.push({
        action: 'restore',
        source: latestBackup,
        target: filePath,
        timestamp: new Date().toISOString()
      });
      
      return {
        success: true,
        backupUsed: latestBackup
      };
      
    } catch (error) {
      console.error(`❌ Delta Agent: Restoration failed for ${filePath}: ${error.message}`);
      return {
        success: false,
        reason: error.message
      };
    }
  }

  /**
   * Acquire a lock on a file for exclusive access
   * @param {string} filePath The file to lock
   * @param {string} operation The operation being performed
   * @returns {Promise<Object>} Lock information
   */
  async acquireLock(filePath, operation) {
    const lockId = crypto.randomBytes(8).toString('hex');
    const lockPath = `${filePath}${this.lockFileExtension}`;
    
    console.log(`🔒 Delta Agent: Attempting to acquire lock for ${filePath}`);
    
    try {
      // Check if there's already a lock
      if (this.activeLocks.has(filePath)) {
        console.log(`⚠️ Delta Agent: File ${filePath} already locked by this process`);
        return {
          success: false,
          reason: 'already-locked-by-us',
          lockId: this.activeLocks.get(filePath).id
        };
      }
      
      // Check for external lock file
      if (await this.fileExists(lockPath)) {
        // Read the lock file to check if it's stale
        const lockContent = await fs.promises.readFile(lockPath, 'utf8');
        let lockInfo;
        
        try {
          lockInfo = JSON.parse(lockContent);
          
          // Check if the lock is stale (older than 5 minutes)
          const lockTime = new Date(lockInfo.timestamp).getTime();
          const now = Date.now();
          const lockAge = now - lockTime;
          
          if (lockAge > 5 * 60 * 1000) { // 5 minutes
            console.log(`ℹ️ Delta Agent: Found stale lock for ${filePath}, removing`);
            await fs.promises.unlink(lockPath);
          } else {
            console.log(`⚠️ Delta Agent: File ${filePath} is locked by another process`);
            return {
              success: false,
              reason: 'locked-by-other-process',
              lockInfo: lockInfo
            };
          }
        } catch (parseError) {
          // Invalid lock file, assume it's stale
          console.log(`ℹ️ Delta Agent: Found invalid lock file for ${filePath}, removing`);
          await fs.promises.unlink(lockPath);
        }
      }
      
      // Create lock file
      const lockInfo = {
        id: lockId,
        operation: operation,
        timestamp: new Date().toISOString(),
        pid: process.pid
      };
      
      await fs.promises.writeFile(lockPath, JSON.stringify(lockInfo, null, 2), 'utf8');
      
      // Store in active locks
      this.activeLocks.set(filePath, lockInfo);
      
      console.log(`✅ Delta Agent: Lock acquired for ${filePath} with ID ${lockId}`);
      
      return {
        success: true,
        lockId: lockId,
        lockPath: lockPath
      };
      
    } catch (error) {
      console.error(`❌ Delta Agent: Failed to acquire lock for ${filePath}: ${error.message}`);
      return {
        success: false,
        reason: error.message
      };
    }
  }

  /**
   * Release a previously acquired lock
   * @param {string} filePath The file to unlock
   * @param {string} lockId The lock ID
   * @returns {Promise<Object>} Result of the unlock operation
   */
  async releaseLock(filePath, lockId) {
    const lockPath = `${filePath}${this.lockFileExtension}`;
    
    console.log(`🔓 Delta Agent: Releasing lock for ${filePath}`);
    
    try {
      // Check if we have this lock
      if (!this.activeLocks.has(filePath)) {
        console.log(`⚠️ Delta Agent: We don't have a lock for ${filePath}`);
        return {
          success: false,
          reason: 'not-our-lock'
        };
      }
      
      // Verify lock ID
      const ourLock = this.activeLocks.get(filePath);
      if (ourLock.id !== lockId) {
        console.log(`⚠️ Delta Agent: Lock ID mismatch for ${filePath}`);
        return {
          success: false,
          reason: 'lock-id-mismatch'
        };
      }
      
      // Remove lock file
      if (await this.fileExists(lockPath)) {
        await fs.promises.unlink(lockPath);
      }
      
      // Remove from active locks
      this.activeLocks.delete(filePath);
      
      console.log(`✅ Delta Agent: Lock released for ${filePath}`);
      
      return {
        success: true
      };
      
    } catch (error) {
      console.error(`❌ Delta Agent: Failed to release lock for ${filePath}: ${error.message}`);
      return {
        success: false,
        reason: error.message
      };
    }
  }

  /**
   * Clean up any stale locks that might have been left from a previous run
   * @returns {Promise<void>}
   */
  async cleanupStaleLocks() {
    console.log('🧹 Delta Agent: Cleaning up stale locks');
    
    try {
      // Search for lock files in all watched directories
      for (const watchDir of this.config.watchDirs || []) {
        const mdDir = path.resolve(process.cwd(), watchDir.md);
        const jsonDir = path.resolve(process.cwd(), watchDir.json);
        
        // Search in MD directories
        await this.cleanupLocksInDirectory(mdDir);
        
        // Search in JSON directories
        await this.cleanupLocksInDirectory(jsonDir);
      }
      
      // Check root directory
      await this.cleanupLocksInDirectory(process.cwd());
      
      console.log('✅ Delta Agent: Stale locks cleanup complete');
      
    } catch (error) {
      console.error(`⚠️ Delta Agent: Error cleaning up stale locks: ${error.message}`);
      // Non-fatal error, continue execution
    }
  }

  /**
   * Clean up lock files in a specific directory
   * @param {string} dirPath The directory to clean
   * @returns {Promise<void>}
   */
  async cleanupLocksInDirectory(dirPath) {
    try {
      const files = await fs.promises.readdir(dirPath);
      
      // Find lock files
      const lockFiles = files.filter(f => f.endsWith(this.lockFileExtension))
                            .map(f => path.join(dirPath, f));
      
      for (const lockPath of lockFiles) {
        try {
          // Read lock file
          const lockContent = await fs.promises.readFile(lockPath, 'utf8');
          let lockInfo;
          
          try {
            lockInfo = JSON.parse(lockContent);
            
            // Check if the lock is stale (older than 5 minutes)
            const lockTime = new Date(lockInfo.timestamp).getTime();
            const now = Date.now();
            const lockAge = now - lockTime;
            
            if (lockAge > 5 * 60 * 1000) { // 5 minutes
              console.log(`ℹ️ Delta Agent: Removing stale lock file ${lockPath}`);
              await fs.promises.unlink(lockPath);
            }
          } catch (parseError) {
            // Invalid lock file, remove it
            console.log(`ℹ️ Delta Agent: Removing invalid lock file ${lockPath}`);
            await fs.promises.unlink(lockPath);
          }
        } catch (readError) {
          console.error(`⚠️ Delta Agent: Error processing lock file ${lockPath}: ${readError.message}`);
        }
      }
    } catch (error) {
      if (error.code !== 'ENOENT') {
        console.error(`⚠️ Delta Agent: Error reading directory ${dirPath}: ${error.message}`);
      }
    }
  }

  /**
   * Perform a file operation safely with locking and backup
   * @param {Object} operationInfo Information about the operation
   * @param {Function} operation The operation function to perform
   * @returns {Promise<Object>} Result of the operation
   */
  async safeOperation(operationInfo, operation) {
    const { sourcePath, targetPath, operationType } = operationInfo;
    
    console.log(`🔐 Delta Agent: Starting safe operation ${operationType} from ${sourcePath} to ${targetPath}`);
    
    // First, acquire locks for both source and target
    const sourceLock = await this.acquireLock(sourcePath, `${operationType}-source`);
    if (!sourceLock.success) {
      return {
        success: false,
        stage: 'source-lock',
        reason: sourceLock.reason
      };
    }
    
    let targetLock = { success: false };
    if (targetPath && targetPath !== sourcePath) {
      targetLock = await this.acquireLock(targetPath, `${operationType}-target`);
      if (!targetLock.success) {
        // Release source lock
        await this.releaseLock(sourcePath, sourceLock.lockId);
        
        return {
          success: false,
          stage: 'target-lock',
          reason: targetLock.reason
        };
      }
    }
    
    try {
      // Create backup of target if it exists
      if (targetPath && await this.fileExists(targetPath)) {
        await this.createBackup(targetPath);
      }
      
      // Perform the operation
      const result = await operation();
      
      // Log the operation
      this.transactionLog.push({
        action: operationType,
        source: sourcePath,
        target: targetPath,
        timestamp: new Date().toISOString(),
        result: result.success
      });
      
      return result;
      
    } catch (error) {
      console.error(`❌ Delta Agent: Operation failed: ${error.message}`);
      return {
        success: false,
        stage: 'operation',
        reason: error.message
      };
    } finally {
      // Release locks
      await this.releaseLock(sourcePath, sourceLock.lockId);
      
      if (targetPath && targetPath !== sourcePath && targetLock.success) {
        await this.releaseLock(targetPath, targetLock.lockId);
      }
    }
  }

  /**
   * Ensure the backup directory exists
   * @returns {Promise<void>}
   */
  async ensureBackupDirectory() {
    try {
      await fs.promises.mkdir(this.backupDir, { recursive: true });
    } catch (error) {
      if (error.code !== 'EEXIST') {
        console.error(`❌ Delta Agent: Failed to create backup directory: ${error.message}`);
        throw error;
      }
    }
  }

  /**
   * Check if a file exists
   * @param {string} filePath The file path to check
   * @returns {Promise<boolean>} True if the file exists
   */
  async fileExists(filePath) {
    try {
      await fs.promises.access(filePath, fs.constants.F_OK);
      return true;
    } catch (error) {
      return false;
    }
  }

  /**
   * Get the transaction log
   * @returns {Array} The transaction log
   */
  getTransactionLog() {
    return [...this.transactionLog];
  }

  /**
   * Create a protective marker file to exclude a file from synchronization
   * @param {string} filePath The file to protect
   * @param {string} reason The reason for protection
   * @returns {Promise<Object>} Result of the protection operation
   */
  async createProtection(filePath, reason) {
    const markerPath = `${filePath}.nosync`;
    
    try {
      // Create marker file with explanation
      const content = `This file tells the sync system to ignore ${path.basename(filePath)}\nReason: ${reason}\nCreated: ${new Date().toISOString()}`;
      await fs.promises.writeFile(markerPath, content, 'utf8');
      
      console.log(`🛡️ Delta Agent: Created protection marker for ${filePath}`);
      
      return {
        success: true,
        markerPath: markerPath
      };
    } catch (error) {
      console.error(`❌ Delta Agent: Failed to create protection marker: ${error.message}`);
      return {
        success: false,
        reason: error.message
      };
    }
  }
}

module.exports = DeltaAgent; 