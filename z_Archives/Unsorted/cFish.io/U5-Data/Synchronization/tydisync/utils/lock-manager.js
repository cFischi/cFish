/**
 * Lock Manager for MD-JSON Sync System
 * 
 * This utility provides enhanced lock management capabilities to prevent
 * stale locks and race conditions in the MD-JSON synchronization system.
 * 
 * Features:
 * - Timeout-based lock expiration
 * - Automatic stale lock detection and cleanup
 * - Process-aware lock verification
 * - Detailed lock status reporting
 */

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

class LockManager {
  constructor(options = {}) {
    // Configuration
    this.options = {
      lockTimeout: options.lockTimeout || 60000, // 60 seconds default timeout
      lockCleanupInterval: options.lockCleanupInterval || 30000, // Check for stale locks every 30 seconds
      lockDirectory: options.lockDirectory || '.locks', // Directory to store lock files
      enabled: options.enabled !== false, // Enabled by default
      debug: options.debug || false // Debug mode for verbose logging
    };

    // State
    this.locks = new Map(); // In-memory locks
    this.cleanupTimer = null;
    this.isRunning = false;

    // Ensure lock directory exists
    this.ensureLockDirectory();

    // Bind methods
    this.acquireLock = this.acquireLock.bind(this);
    this.releaseLock = this.releaseLock.bind(this);
    this.cleanupStaleLocks = this.cleanupStaleLocks.bind(this);
    this.start = this.start.bind(this);
    this.stop = this.stop.bind(this);
  }

  /**
   * Ensure lock directory exists
   */
  ensureLockDirectory() {
    if (!fs.existsSync(this.options.lockDirectory)) {
      try {
        fs.mkdirSync(this.options.lockDirectory, { recursive: true });
      } catch (err) {
        console.error(`Error creating lock directory: ${err.message}`);
      }
    }
  }

  /**
   * Generate a lock file path for a given file
   * @param {string} filePath - Path to the file being locked
   * @returns {string} Path to the lock file
   */
  getLockFilePath(filePath) {
    // Create a hash of the file path to avoid path length issues
    const filePathHash = crypto.createHash('md5').update(filePath).digest('hex');
    return path.join(this.options.lockDirectory, `${filePathHash}.lock`);
  }

  /**
   * Check if a process is still running
   * @param {number} pid - Process ID to check
   * @returns {boolean} Whether the process is running
   */
  isProcessRunning(pid) {
    try {
      // Send signal 0 to check if process exists
      // This doesn't actually send a signal
      process.kill(pid, 0);
      return true;
    } catch (err) {
      // If error is ESRCH, process doesn't exist
      return err.code !== 'ESRCH';
    }
  }

  /**
   * Acquire a lock for a file
   * @param {string} filePath - Path to the file to lock
   * @param {string} operation - Operation being performed (for logging)
   * @returns {Promise<string|boolean>} Lock ID if successful, false otherwise
   */
  async acquireLock(filePath, operation = 'unknown') {
    if (!this.options.enabled) {
      return true; // Locks disabled, always succeed
    }

    // Generate a unique lock ID
    const lockId = crypto.randomBytes(8).toString('hex');
    const lockFilePath = this.getLockFilePath(filePath);

    // Check if the file is already locked in memory
    if (this.locks.has(filePath)) {
      const existingLock = this.locks.get(filePath);
      const lockAge = Date.now() - existingLock.timestamp;

      // Check if the lock is stale
      if (lockAge > this.options.lockTimeout) {
        if (this.options.debug) {
          console.log(`ℹ️ Lock Manager: Found stale in-memory lock for ${filePath}, removing`);
        }
        this.releaseLock(filePath);
      } else {
        if (this.options.debug) {
          console.log(`⚠️ Lock Manager: File ${filePath} is already locked in memory`);
        }
        return false;
      }
    }

    try {
      // Check if lock file exists
      if (fs.existsSync(lockFilePath)) {
        try {
          // Read the lock file
          const lockData = JSON.parse(fs.readFileSync(lockFilePath, 'utf8'));
          const lockAge = Date.now() - lockData.timestamp;

          // Check if the lock is stale
          if (lockAge > this.options.lockTimeout) {
            if (this.options.debug) {
              console.log(`ℹ️ Lock Manager: Found stale lock file for ${filePath}, removing`);
            }
            fs.unlinkSync(lockFilePath);
          } else if (!this.isProcessRunning(lockData.processId)) {
            // Process that created the lock is no longer running
            if (this.options.debug) {
              console.log(`ℹ️ Lock Manager: Process ${lockData.processId} that locked ${filePath} is no longer running, removing lock`);
            }
            fs.unlinkSync(lockFilePath);
          } else {
            if (this.options.debug) {
              console.log(`⚠️ Lock Manager: File ${filePath} is locked by process ${lockData.processId}`);
            }
            return false;
          }
        } catch (err) {
          // Lock file exists but is invalid, remove it
          if (this.options.debug) {
            console.log(`⚠️ Lock Manager: Invalid lock file for ${filePath}, removing`);
          }
          fs.unlinkSync(lockFilePath);
        }
      }

      // Create lock file
      const lockData = {
        id: lockId,
        processId: process.pid,
        timestamp: Date.now(),
        operation,
        filePath
      };

      fs.writeFileSync(lockFilePath, JSON.stringify(lockData));

      // Store lock in memory
      this.locks.set(filePath, {
        id: lockId,
        timestamp: Date.now(),
        operation,
        lockFilePath
      });

      if (this.options.debug) {
        console.log(`✅ Lock Manager: Lock acquired for ${filePath} with ID ${lockId}`);
      }
      return lockId;
    } catch (err) {
      console.error(`⚠️ Lock Manager: Error acquiring lock for ${filePath}: ${err.message}`);
      return false;
    }
  }

  /**
   * Release a lock for a file
   * @param {string} filePath - Path to the file to unlock
   * @param {string} [lockId] - Lock ID to verify (optional)
   * @returns {boolean} Whether the lock was released
   */
  releaseLock(filePath, lockId) {
    if (!this.options.enabled) {
      return true; // Locks disabled, always succeed
    }

    // Check if lock exists in memory
    if (!this.locks.has(filePath)) {
      if (this.options.debug) {
        console.log(`⚠️ Lock Manager: No in-memory lock found for ${filePath}`);
      }
      
      // Still try to clean up any lock file
      const lockFilePath = this.getLockFilePath(filePath);
      if (fs.existsSync(lockFilePath)) {
        try {
          fs.unlinkSync(lockFilePath);
          if (this.options.debug) {
            console.log(`✅ Lock Manager: Removed orphaned lock file for ${filePath}`);
          }
        } catch (err) {
          console.error(`⚠️ Lock Manager: Error removing orphaned lock file for ${filePath}: ${err.message}`);
        }
      }
      
      return false;
    }

    // Check if lockId matches (if provided)
    const lock = this.locks.get(filePath);
    if (lockId && lock.id !== lockId) {
      if (this.options.debug) {
        console.log(`⚠️ Lock Manager: Lock ID mismatch for ${filePath}`);
      }
      return false;
    }

    // Remove from memory
    this.locks.delete(filePath);

    // Remove lock file
    try {
      if (fs.existsSync(lock.lockFilePath)) {
        fs.unlinkSync(lock.lockFilePath);
      }
      
      if (this.options.debug) {
        console.log(`✅ Lock Manager: Lock released for ${filePath}`);
      }
      
      return true;
    } catch (err) {
      console.error(`⚠️ Lock Manager: Error removing lock file for ${filePath}: ${err.message}`);
      return false;
    }
  }

  /**
   * Check if a file is locked
   * @param {string} filePath - Path to the file to check
   * @returns {boolean} Whether the file is locked
   */
  isLocked(filePath) {
    if (!this.options.enabled) {
      return false; // Locks disabled, always report unlocked
    }

    // Check in-memory locks
    if (this.locks.has(filePath)) {
      return true;
    }

    // Check lock file
    const lockFilePath = this.getLockFilePath(filePath);
    if (fs.existsSync(lockFilePath)) {
      try {
        // Read the lock file
        const lockData = JSON.parse(fs.readFileSync(lockFilePath, 'utf8'));
        const lockAge = Date.now() - lockData.timestamp;

        // Check if the lock is stale
        if (lockAge > this.options.lockTimeout) {
          // Stale lock, remove it
          fs.unlinkSync(lockFilePath);
          return false;
        }

        // Check if the process is still running
        if (!this.isProcessRunning(lockData.processId)) {
          // Process that created the lock is no longer running
          fs.unlinkSync(lockFilePath);
          return false;
        }

        // Lock is valid
        return true;
      } catch (err) {
        // Invalid lock file, remove it
        try {
          fs.unlinkSync(lockFilePath);
        } catch (e) {
          // Ignore errors when removing invalid lock file
        }
        return false;
      }
    }

    return false;
  }

  /**
   * Clean up stale locks
   */
  cleanupStaleLocks() {
    if (!this.options.enabled) {
      return;
    }

    const now = Date.now();
    let staleLocksFound = 0;

    // Check in-memory locks
    for (const [filePath, lockInfo] of this.locks.entries()) {
      // Check if lock has expired
      if (now - lockInfo.timestamp > this.options.lockTimeout) {
        if (this.options.debug) {
          console.log(`ℹ️ Lock Manager: Found stale in-memory lock for ${filePath}, removing`);
        }
        this.releaseLock(filePath);
        staleLocksFound++;
      }
    }

    // Check lock files on disk
    try {
      const lockFiles = fs.readdirSync(this.options.lockDirectory);
      
      for (const lockFile of lockFiles) {
        if (!lockFile.endsWith('.lock')) {
          continue;
        }
        
        const lockFilePath = path.join(this.options.lockDirectory, lockFile);
        
        try {
          // Read the lock file
          const lockData = JSON.parse(fs.readFileSync(lockFilePath, 'utf8'));
          const lockAge = Date.now() - lockData.timestamp;
          
          // Check if the lock is stale
          if (lockAge > this.options.lockTimeout || !this.isProcessRunning(lockData.processId)) {
            if (this.options.debug) {
              console.log(`ℹ️ Lock Manager: Found stale lock file ${lockFile}, removing`);
            }
            fs.unlinkSync(lockFilePath);
            staleLocksFound++;
          }
        } catch (err) {
          // Invalid lock file, remove it
          if (this.options.debug) {
            console.log(`⚠️ Lock Manager: Invalid lock file ${lockFile}, removing`);
          }
          try {
            fs.unlinkSync(lockFilePath);
            staleLocksFound++;
          } catch (e) {
            // Ignore errors when removing invalid lock file
          }
        }
      }
    } catch (err) {
      console.error(`⚠️ Lock Manager: Error cleaning up lock files: ${err.message}`);
    }

    if (staleLocksFound > 0 && this.options.debug) {
      console.log(`ℹ️ Lock Manager: Removed ${staleLocksFound} stale locks during cleanup`);
    }
  }

  /**
   * Start lock management
   */
  start() {
    if (this.isRunning || !this.options.enabled) {
      return;
    }

    if (this.options.debug) {
      console.log('🔒 Lock Manager: Starting lock management');
    }

    // Set up periodic cleanup
    this.cleanupTimer = setInterval(() => {
      this.cleanupStaleLocks();
    }, this.options.lockCleanupInterval);

    // Make sure timer doesn't prevent process exit
    this.cleanupTimer.unref();

    this.isRunning = true;
    return true;
  }

  /**
   * Stop lock management
   */
  stop() {
    if (!this.isRunning) {
      return;
    }

    if (this.options.debug) {
      console.log('🔒 Lock Manager: Stopping lock management');
    }

    if (this.cleanupTimer) {
      clearInterval(this.cleanupTimer);
      this.cleanupTimer = null;
    }

    this.isRunning = false;

    // Release all locks
    this.releaseAllLocks();

    return true;
  }

  /**
   * Release all locks
   */
  releaseAllLocks() {
    if (this.options.debug) {
      console.log(`🔓 Lock Manager: Releasing all locks (${this.locks.size} total)`);
    }

    for (const filePath of this.locks.keys()) {
      this.releaseLock(filePath);
    }
  }

  /**
   * Get lock statistics
   * @returns {Object} Lock statistics
   */
  getStats() {
    return {
      activeLocks: this.locks.size,
      locks: Array.from(this.locks.entries()).map(([filePath, lockInfo]) => ({
        filePath,
        id: lockInfo.id,
        operation: lockInfo.operation,
        age: Date.now() - lockInfo.timestamp
      }))
    };
  }
}

// Export the LockManager class
module.exports = LockManager; 