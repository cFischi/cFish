/**
 * Backup Manager
 * 
 * Handles backup creation, rotation, and cleanup to prevent excessive backups.
 */

const fs = require('fs');
const path = require('path');
const zlib = require('zlib');

class BackupManager {
  constructor(options = {}) {
    this.backupDir = options.backupDir || 'backups';
    this.maxBackups = options.maxBackups || 5;
    this.rotationEnabled = options.rotationEnabled !== false;
    this.rotationInterval = options.rotationInterval || 86400000; // 24 hours
    this.compressionEnabled = options.compressionEnabled || false;
    this.timestampPattern = /\.(\d{4}-\d{2}-\d{2}T\d{2}-\d{2}-\d{2}-\d{3}Z)\.backup$/;
    this.debug = options.debug || false;
    
    // Create backup directory if it doesn't exist
    if (!fs.existsSync(this.backupDir)) {
      fs.mkdirSync(this.backupDir, { recursive: true });
      this.log(`Created backup directory: ${this.backupDir}`);
    }
  }

  /**
   * Create a backup of a file
   * @param {string} filePath - Path to the file to back up
   * @returns {string|null} - Path to the backup file, or null if backup failed
   */
  createBackup(filePath) {
    try {
      if (!fs.existsSync(filePath)) {
        this.log(`File does not exist: ${filePath}`, 'warn');
        return null;
      }

      const fileName = path.basename(filePath);
      const timestamp = new Date().toISOString().replace(/:/g, '-');
      const backupFilePath = path.join(
        this.backupDir, 
        `${fileName}.${timestamp}.backup`
      );

      // Create the backup
      if (this.compressionEnabled) {
        // Compressed backup
        const fileContent = fs.readFileSync(filePath);
        const compressed = zlib.gzipSync(fileContent);
        fs.writeFileSync(backupFilePath + '.gz', compressed);
        this.log(`Created compressed backup: ${backupFilePath}.gz`);
        
        // Rotate backups for this file
        if (this.rotationEnabled) {
          this.rotateBackups(fileName, true);
        }
        
        return backupFilePath + '.gz';
      } else {
        // Regular backup
        fs.copyFileSync(filePath, backupFilePath);
        this.log(`Created backup: ${backupFilePath}`);
        
        // Rotate backups for this file
        if (this.rotationEnabled) {
          this.rotateBackups(fileName);
        }
        
        return backupFilePath;
      }
    } catch (error) {
      this.log(`Error creating backup for ${filePath}: ${error.message}`, 'error');
      return null;
    }
  }

  /**
   * Rotate backups for a specific file to keep only a maximum number
   * @param {string} fileName - Base name of the file
   * @param {boolean} compressed - Whether the backups are compressed
   */
  rotateBackups(fileName, compressed = false) {
    try {
      const extension = compressed ? '.backup.gz' : '.backup';
      const filePattern = new RegExp(`^${fileName.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}\\..*${extension}$`);
      
      // Get all backups for this file
      const backups = fs.readdirSync(this.backupDir)
        .filter(file => filePattern.test(file))
        .map(file => {
          const match = file.match(this.timestampPattern);
          return {
            file,
            path: path.join(this.backupDir, file),
            timestamp: match ? match[1] : null,
            date: match ? new Date(match[1].replace(/-/g, ':')) : new Date(0)
          };
        })
        .sort((a, b) => b.date - a.date); // Sort by date, newest first
      
      // Keep only the maximum number of backups
      if (backups.length > this.maxBackups) {
        const toRemove = backups.slice(this.maxBackups);
        toRemove.forEach(backup => {
          try {
            fs.unlinkSync(backup.path);
            this.log(`Removed old backup: ${backup.file}`);
          } catch (err) {
            this.log(`Error removing backup ${backup.file}: ${err.message}`, 'warn');
          }
        });
      }
    } catch (error) {
      this.log(`Error rotating backups for ${fileName}: ${error.message}`, 'error');
    }
  }

  /**
   * Perform a complete backup cleanup, removing old backups
   * to maintain the specified maximum count for each file
   */
  cleanupBackups() {
    try {
      // Get all backup files
      const files = fs.readdirSync(this.backupDir)
        .filter(file => file.endsWith('.backup') || file.endsWith('.backup.gz'));
      
      // Group by original file name
      const backupsByFile = {};
      
      files.forEach(file => {
        const compressed = file.endsWith('.gz');
        const baseFile = file.replace(this.timestampPattern, '').replace(/\.gz$/, '');
        
        if (!backupsByFile[baseFile]) {
          backupsByFile[baseFile] = [];
        }
        
        const match = file.match(this.timestampPattern);
        backupsByFile[baseFile].push({
          file,
          path: path.join(this.backupDir, file),
          timestamp: match ? match[1] : null,
          date: match ? new Date(match[1].replace(/-/g, ':')) : new Date(0),
          compressed
        });
      });
      
      // For each file, sort backups by date and keep only the maximum number
      let removedCount = 0;
      Object.keys(backupsByFile).forEach(file => {
        const backups = backupsByFile[file].sort((a, b) => b.date - a.date);
        
        if (backups.length > this.maxBackups) {
          const toRemove = backups.slice(this.maxBackups);
          toRemove.forEach(backup => {
            try {
              fs.unlinkSync(backup.path);
              this.log(`Removed old backup: ${backup.file}`);
              removedCount++;
            } catch (err) {
              this.log(`Error removing backup ${backup.file}: ${err.message}`, 'warn');
            }
          });
        }
      });
      
      this.log(`Cleanup complete: removed ${removedCount} old backups`);
    } catch (error) {
      this.log(`Error cleaning up backups: ${error.message}`, 'error');
    }
  }

  /**
   * Clean up backups older than a certain age
   * @param {number} maxAge - Maximum age in milliseconds
   */
  cleanupOldBackups(maxAge = this.rotationInterval) {
    try {
      const now = new Date();
      const cutoff = new Date(now.getTime() - maxAge);
      
      // Get all backup files
      const files = fs.readdirSync(this.backupDir)
        .filter(file => file.endsWith('.backup') || file.endsWith('.backup.gz'))
        .map(file => {
          const match = file.match(this.timestampPattern);
          return {
            file,
            path: path.join(this.backupDir, file),
            timestamp: match ? match[1] : null,
            date: match ? new Date(match[1].replace(/-/g, ':')) : new Date(0)
          };
        })
        .filter(backup => backup.date < cutoff);
      
      // Remove old backups
      let removedCount = 0;
      files.forEach(backup => {
        try {
          fs.unlinkSync(backup.path);
          this.log(`Removed old backup: ${backup.file}`);
          removedCount++;
        } catch (err) {
          this.log(`Error removing backup ${backup.file}: ${err.message}`, 'warn');
        }
      });
      
      this.log(`Cleaned up ${removedCount} backups older than ${new Date(cutoff).toISOString()}`);
    } catch (error) {
      this.log(`Error cleaning up old backups: ${error.message}`, 'error');
    }
  }

  /**
   * Start the automated backup rotation
   */
  startRotation() {
    if (!this.rotationEnabled) return;
    
    this.log(`Starting automatic backup rotation (interval: ${this.rotationInterval}ms)`);
    
    // Run an initial cleanup
    this.cleanupBackups();
    
    // Set up recurring cleanup
    this.rotationTimer = setInterval(() => {
      this.log('Running scheduled backup rotation');
      this.cleanupBackups();
    }, this.rotationInterval);
    
    // Don't keep the process running for this timer alone
    this.rotationTimer.unref();
  }

  /**
   * Stop the automated backup rotation
   */
  stopRotation() {
    if (this.rotationTimer) {
      clearInterval(this.rotationTimer);
      this.rotationTimer = null;
      this.log('Stopped automatic backup rotation');
    }
  }

  /**
   * Log a message if debug is enabled
   * @param {string} message - The message to log
   * @param {string} level - Log level (log, warn, error)
   */
  log(message, level = 'log') {
    if (this.debug) {
      if (level === 'error') {
        console.error(`⚠️ BackupManager: ${message}`);
      } else if (level === 'warn') {
        console.warn(`⚠️ BackupManager: ${message}`);
      } else {
        console.log(`✓ BackupManager: ${message}`);
      }
    }
  }
}

module.exports = BackupManager; 