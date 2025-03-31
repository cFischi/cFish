/**
 * Backup Restoration Utility
 * 
 * This utility allows for the restoration of files from the backup directory.
 * It can restore a specific file or all files from a specific date.
 */

const fs = require('fs');
const path = require('path');
const readline = require('readline');

// Configuration
const BACKUP_DIR = 'backups';
const DEFAULT_TIMESTAMP_PATTERN = /\.(\d{4}-\d{2}-\d{2}T\d{2}-\d{2}-\d{2}-\d{3}Z)\.backup$/;

class BackupRestorer {
  constructor(options = {}) {
    this.backupDir = options.backupDir || BACKUP_DIR;
    this.timestampPattern = options.timestampPattern || DEFAULT_TIMESTAMP_PATTERN;
    this.rl = readline.createInterface({
      input: process.stdin,
      output: process.stdout
    });
  }

  /**
   * List all available backups, grouped by date
   */
  listBackups() {
    try {
      if (!fs.existsSync(this.backupDir)) {
        console.error(`Backup directory '${this.backupDir}' does not exist.`);
        return;
      }

      const files = fs.readdirSync(this.backupDir);
      if (files.length === 0) {
        console.log('No backups found.');
        return;
      }

      // Group backups by date
      const backupsByDate = {};
      const backupsByFile = {};

      files.forEach(file => {
        if (!file.endsWith('.backup')) return;

        const match = file.match(this.timestampPattern);
        if (!match) return;

        const timestamp = match[1];
        const date = timestamp.split('T')[0];
        const originalFile = file.replace(this.timestampPattern, '');

        if (!backupsByDate[date]) {
          backupsByDate[date] = [];
        }
        backupsByDate[date].push({ file, timestamp, originalFile });

        if (!backupsByFile[originalFile]) {
          backupsByFile[originalFile] = [];
        }
        backupsByFile[originalFile].push({ file, timestamp });
      });

      console.log('Available backups by date:');
      Object.keys(backupsByDate).sort().reverse().forEach(date => {
        console.log(`\n${date}:`);
        backupsByDate[date].forEach(({ file, timestamp, originalFile }) => {
          const time = timestamp.split('T')[1].replace(/-/g, ':');
          console.log(`  - ${originalFile} (${time})`);
        });
      });

      console.log('\nAvailable backups by file:');
      Object.keys(backupsByFile).sort().forEach(file => {
        console.log(`\n${file}:`);
        backupsByFile[file].sort((a, b) => b.timestamp.localeCompare(a.timestamp)).forEach(({ timestamp }) => {
          const date = timestamp.split('T')[0];
          const time = timestamp.split('T')[1].replace(/-/g, ':');
          console.log(`  - ${date} ${time}`);
        });
      });
    } catch (error) {
      console.error(`Error listing backups: ${error.message}`);
    }
  }

  /**
   * Restore a specific file from a backup
   * @param {string} backupFile - The backup file to restore from
   * @param {string} targetFile - The target file to restore to
   * @param {boolean} force - Whether to overwrite without confirmation
   */
  async restoreFile(backupFile, targetFile, force = false) {
    try {
      const backupPath = path.join(this.backupDir, backupFile);
      
      if (!fs.existsSync(backupPath)) {
        console.error(`Backup file '${backupFile}' does not exist.`);
        return false;
      }

      if (fs.existsSync(targetFile) && !force) {
        const answer = await this.promptYesNo(`Target file '${targetFile}' already exists. Overwrite?`);
        if (!answer) {
          console.log('Restoration cancelled.');
          return false;
        }
      }

      // Create a backup of the current file if it exists
      if (fs.existsSync(targetFile)) {
        const timestamp = new Date().toISOString().replace(/:/g, '-');
        const preRestoreBackup = path.join(this.backupDir, `${path.basename(targetFile)}.pre-restore.${timestamp}.backup`);
        fs.copyFileSync(targetFile, preRestoreBackup);
        console.log(`Created pre-restoration backup: ${preRestoreBackup}`);
      }

      // Ensure the target directory exists
      const targetDir = path.dirname(targetFile);
      if (!fs.existsSync(targetDir)) {
        fs.mkdirSync(targetDir, { recursive: true });
      }

      // Restore the file
      fs.copyFileSync(backupPath, targetFile);
      console.log(`Successfully restored '${targetFile}' from backup.`);
      return true;
    } catch (error) {
      console.error(`Error restoring file: ${error.message}`);
      return false;
    }
  }

  /**
   * Restore all files from a specific date
   * @param {string} date - The date to restore from (YYYY-MM-DD)
   * @param {boolean} force - Whether to overwrite without confirmation
   */
  async restoreByDate(date, force = false) {
    try {
      if (!fs.existsSync(this.backupDir)) {
        console.error(`Backup directory '${this.backupDir}' does not exist.`);
        return;
      }

      const files = fs.readdirSync(this.backupDir);
      const backupsForDate = files.filter(file => {
        if (!file.endsWith('.backup')) return false;
        const match = file.match(this.timestampPattern);
        if (!match) return false;
        return match[1].startsWith(date);
      });

      if (backupsForDate.length === 0) {
        console.log(`No backups found for date ${date}.`);
        return;
      }

      // Group backups by file, keeping only the latest for each file on the specified date
      const latestBackupsByFile = {};
      backupsForDate.forEach(file => {
        const match = file.match(this.timestampPattern);
        const timestamp = match[1];
        const originalFile = file.replace(this.timestampPattern, '');

        if (!latestBackupsByFile[originalFile] || 
            latestBackupsByFile[originalFile].timestamp < timestamp) {
          latestBackupsByFile[originalFile] = { file, timestamp };
        }
      });

      console.log(`Found ${Object.keys(latestBackupsByFile).length} files to restore from ${date}.`);
      
      if (!force) {
        const answer = await this.promptYesNo('Proceed with restoration?');
        if (!answer) {
          console.log('Restoration cancelled.');
          return;
        }
      }

      // Restore each file
      let successCount = 0;
      for (const originalFile of Object.keys(latestBackupsByFile)) {
        const { file } = latestBackupsByFile[originalFile];
        const success = await this.restoreFile(file, originalFile, force);
        if (success) successCount++;
      }

      console.log(`Restoration complete: ${successCount} of ${Object.keys(latestBackupsByFile).length} files restored.`);
    } catch (error) {
      console.error(`Error restoring by date: ${error.message}`);
    }
  }

  /**
   * Prompt for yes/no input
   * @param {string} question - The question to ask
   * @returns {Promise<boolean>} - True for yes, false for no
   */
  promptYesNo(question) {
    return new Promise(resolve => {
      this.rl.question(`${question} (y/n) `, answer => {
        resolve(answer.toLowerCase() === 'y' || answer.toLowerCase() === 'yes');
      });
    });
  }

  /**
   * Close the readline interface
   */
  close() {
    this.rl.close();
  }
}

// If run directly from command line
if (require.main === module) {
  const args = process.argv.slice(2);
  const restorer = new BackupRestorer();

  const showHelp = () => {
    console.log(`
Backup Restoration Utility

Usage:
  node backup-restore.js list                          - List all available backups
  node backup-restore.js restore <backup-file> <target> - Restore a specific backup
  node backup-restore.js restore-date <date>           - Restore latest backups from date (YYYY-MM-DD)
  node backup-restore.js help                          - Show this help message
    `);
  };

  const handleCommand = async () => {
    if (args.length === 0 || args[0] === 'help') {
      showHelp();
    } else if (args[0] === 'list') {
      restorer.listBackups();
    } else if (args[0] === 'restore' && args.length >= 3) {
      await restorer.restoreFile(args[1], args[2], args[3] === '--force');
    } else if (args[0] === 'restore-date' && args.length >= 2) {
      await restorer.restoreByDate(args[1], args[2] === '--force');
    } else {
      console.error('Invalid command or missing arguments.');
      showHelp();
    }
    
    restorer.close();
  };

  handleCommand();
}

module.exports = BackupRestorer; 