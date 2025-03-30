/**
 * Dummy MdJsonSync class for testing purposes
 * Enhanced to actually watch test files
 * Added debug logging for troubleshooting
 */

const fs = require('fs');
const path = require('path');
const EventEmitter = require('events');
const chokidar = require('chokidar');

// Debug logging helper
function debugLog(message, object = null) {
  const timestamp = new Date().toISOString();
  const logMsg = `[DEBUG][${timestamp}] ${message}`;
  console.log(logMsg);
  
  if (object) {
    console.log(JSON.stringify(object, null, 2));
  }
  
  // Also write to a log file for persistent debugging
  try {
    fs.appendFileSync('tydisync-debug.log', logMsg + (object ? '\n' + JSON.stringify(object, null, 2) : '') + '\n');
  } catch (err) {
    console.error('Error writing to debug log file:', err);
  }
}

// Performance tracking
function trackPerformance(operation, startTime) {
  const endTime = process.hrtime.bigint();
  const duration = Number(endTime - startTime) / 1000000; // Convert to milliseconds
  debugLog(`Performance: ${operation} completed in ${duration.toFixed(2)}ms`);
  return duration;
}

class MdJsonSync extends EventEmitter {
  constructor(config) {
    super();
    this.config = config;
    this.running = false;
    this.watchDirectories = config.watchDirectories || {
      markdown: ['.'],
      json: ['json']
    };
    this.debounceTime = config.debounceTime || 1000;
    this.exclusions = config.exclusions || [];
    this.backupSettings = config.backupSettings || {
      enabled: true,
      backupDir: "backups",
      maxBackups: 5
    };
    
    // Performance optimization settings
    this.performanceSettings = config.performanceSettings || {
      batchProcessingEnabled: true,
      batchSize: 5,
      batchTimeout: 2000,
      throttlingEnabled: true,
      maxConcurrentTasks: 3,
      throttleDelay: 500
    };
    
    // Error recovery settings
    this.errorRecoverySettings = config.errorRecoverySettings || {
      enabled: true,
      retryEnabled: true,
      maxRetries: 3,
      initialRetryDelay: 1000, // ms
      retryBackoffMultiplier: 2,
      retryQueueProcessInterval: 10000, // 10 seconds
      autoRecoveryEnabled: true,
      recoveryStrategies: ['backupRestore', 'partialSync', 'recreate']
    };
    
    // New: User interface settings
    this.uiSettings = config.uiSettings || {
      enabled: true,
      statusFilePath: 'tydisync-status.json',
      statusUpdateInterval: 5000, // 5 seconds
      notificationsEnabled: true,
      notificationsFilePath: 'tydisync-notifications.json',
      maxNotifications: 100,
      consoleIndicatorsEnabled: true
    };
    
    // Batch processing queues
    this.mdQueue = [];
    this.jsonQueue = [];
    this.processingBatch = false;
    this.activeTasks = 0;
    
    // Retry queue for failed operations
    this.retryQueue = [];
    this.retryQueueProcessorId = null;
    this.failedOperations = new Map();
    
    // New: UI tracking
    this.statusUpdaterId = null;
    this.notifications = [];
    this.stats = {
      totalTransformations: 0,
      successfulTransformations: 0,
      failedTransformations: 0,
      totalRetries: 0,
      successfulRetries: 0,
      recoveryAttempts: 0,
      successfulRecoveries: 0,
      startTime: new Date().toISOString()
    };
    
    debugLog('MdJsonSync constructor called with config:', config);
    debugLog('Configured watch directories:', this.watchDirectories);
    debugLog('Performance settings:', this.performanceSettings);
    debugLog('Error recovery settings:', this.errorRecoverySettings);
    debugLog('User interface settings:', this.uiSettings);
  }

  start() {
    this.running = true;
    debugLog('🔍 Starting MdJsonSync watcher');
    console.log('🔍 Watching for file changes (two-way sync)...');
    
    // Verify that watch directories exist
    this.verifyWatchDirectories();
    
    // Set up actual file watchers for test directories
    this.setupWatchers();
    
    // Start the retry queue processor if enabled
    if (this.errorRecoverySettings.enabled && this.errorRecoverySettings.retryEnabled) {
      this.startRetryQueueProcessor();
    }
    
    // New: Start the status updater if UI is enabled
    if (this.uiSettings.enabled) {
      this.startStatusUpdater();
      this.addNotification({
        type: 'info',
        title: 'System Started',
        message: 'MD-JSON Sync system has started successfully.',
        timestamp: new Date().toISOString()
      });
      
      // Show initial console indicators
      if (this.uiSettings.consoleIndicatorsEnabled) {
        this.showConsoleStatus();
      }
    }
    
    // Log initial state
    setTimeout(() => {
      console.log('✅ Initial synchronization complete');
      console.log('✓ Validation: memory.md size looks reasonable');
      debugLog('Initial startup sequence completed');
      
      // Log error recovery status
      if (this.errorRecoverySettings.enabled) {
        debugLog('🛡️ Error recovery system enabled');
        console.log('🛡️ Error recovery system enabled');
        debugLog(`Retry settings: max ${this.errorRecoverySettings.maxRetries} retries with ${this.errorRecoverySettings.initialRetryDelay}ms initial delay`);
      }
      
      // New: Log UI status
      if (this.uiSettings.enabled) {
        debugLog('🖥️ User interface system enabled');
        console.log('🖥️ User interface system enabled');
        debugLog(`Status updates every ${this.uiSettings.statusUpdateInterval}ms to ${this.uiSettings.statusFilePath}`);
        this.updateStatusFile();
      }
    }, 2000);
    
    return this;
  }

  // New: Status file updater
  startStatusUpdater() {
    debugLog('Starting status updater');
    
    if (this.statusUpdaterId) {
      clearInterval(this.statusUpdaterId);
    }
    
    // Update status immediately
    this.updateStatusFile();
    
    // Then schedule regular updates
    this.statusUpdaterId = setInterval(() => {
      this.updateStatusFile();
    }, this.uiSettings.statusUpdateInterval);
    
    debugLog(`Status updater scheduled to run every ${this.uiSettings.statusUpdateInterval}ms`);
  }
  
  updateStatusFile() {
    if (!this.uiSettings.enabled) {
      return;
    }
    
    try {
      const status = {
        system: {
          running: this.running,
          uptime: this.calculateUptime(),
          version: '1.1.6',
          lastUpdated: new Date().toISOString()
        },
        queues: {
          markdown: this.mdQueue.length,
          json: this.jsonQueue.length,
          retry: this.retryQueue.length,
          activeTasks: this.activeTasks
        },
        errors: {
          failedOperations: this.failedOperations.size,
          retryQueueLength: this.retryQueue.length
        },
        stats: this.stats,
        directories: {
          markdown: this.watchDirectories.markdown,
          json: this.watchDirectories.json
        }
      };
      
      fs.writeFileSync(this.uiSettings.statusFilePath, JSON.stringify(status, null, 2), 'utf8');
      debugLog(`Updated status file: ${this.uiSettings.statusFilePath}`);
    } catch (error) {
      debugLog(`Error updating status file:`, error);
    }
  }
  
  calculateUptime() {
    const startTime = new Date(this.stats.startTime);
    const now = new Date();
    const uptimeMs = now - startTime;
    
    const seconds = Math.floor(uptimeMs / 1000);
    const minutes = Math.floor(seconds / 60);
    const hours = Math.floor(minutes / 60);
    const days = Math.floor(hours / 24);
    
    return {
      total: uptimeMs,
      formatted: `${days}d ${hours % 24}h ${minutes % 60}m ${seconds % 60}s`,
      days,
      hours: hours % 24,
      minutes: minutes % 60,
      seconds: seconds % 60
    };
  }
  
  // New: Notification system
  addNotification(notification) {
    if (!this.uiSettings.enabled || !this.uiSettings.notificationsEnabled) {
      return;
    }
    
    // Add timestamp if not provided
    if (!notification.timestamp) {
      notification.timestamp = new Date().toISOString();
    }
    
    // Add new notification to the beginning of the array
    this.notifications.unshift(notification);
    
    // Trim notifications list if it exceeds max size
    if (this.notifications.length > this.uiSettings.maxNotifications) {
      this.notifications = this.notifications.slice(0, this.uiSettings.maxNotifications);
    }
    
    debugLog(`Added notification: ${notification.title}`);
    
    // Show in console if console indicators are enabled
    if (this.uiSettings.consoleIndicatorsEnabled) {
      let prefix = '';
      switch (notification.type) {
        case 'info':
          prefix = '📢 INFO: ';
          break;
        case 'success':
          prefix = '✅ SUCCESS: ';
          break;
        case 'warning':
          prefix = '⚠️ WARNING: ';
          break;
        case 'error':
          prefix = '❌ ERROR: ';
          break;
        default:
          prefix = '🔔 NOTIFICATION: ';
      }
      
      console.log(`${prefix}${notification.title} - ${notification.message}`);
    }
    
    // Update notifications file
    this.updateNotificationsFile();
  }
  
  updateNotificationsFile() {
    if (!this.uiSettings.enabled || !this.uiSettings.notificationsEnabled) {
      return;
    }
    
    try {
      fs.writeFileSync(
        this.uiSettings.notificationsFilePath,
        JSON.stringify(this.notifications, null, 2),
        'utf8'
      );
      debugLog(`Updated notifications file: ${this.uiSettings.notificationsFilePath}`);
    } catch (error) {
      debugLog(`Error updating notifications file:`, error);
    }
  }
  
  // New: Console status display
  showConsoleStatus() {
    if (!this.uiSettings.enabled || !this.uiSettings.consoleIndicatorsEnabled) {
      return;
    }
    
    console.log('\n=== MD-JSON Sync Status ===');
    console.log(`🔄 System: ${this.running ? 'RUNNING' : 'STOPPED'}`);
    console.log(`⏱️ Uptime: ${this.calculateUptime().formatted}`);
    console.log(`📊 Stats: ${this.stats.successfulTransformations} successful / ${this.stats.failedTransformations} failed`);
    console.log(`📝 Queue: ${this.mdQueue.length} MD, ${this.jsonQueue.length} JSON, ${this.retryQueue.length} retry`);
    console.log(`🛠️ Recovery: ${this.stats.successfulRecoveries} successful / ${this.stats.recoveryAttempts} attempts`);
    console.log('===========================\n');
  }

  verifyWatchDirectories() {
    // Check markdown directories
    debugLog('Verifying watch directories exist:');
    
    for (const mdDir of this.watchDirectories.markdown) {
      if (fs.existsSync(mdDir)) {
        debugLog(`✅ Markdown directory exists: ${mdDir}`);
      } else {
        debugLog(`⚠️ Markdown directory does not exist: ${mdDir}`);
      }
    }
    
    // Check JSON directories
    for (const jsonDir of this.watchDirectories.json) {
      if (fs.existsSync(jsonDir)) {
        debugLog(`✅ JSON directory exists: ${jsonDir}`);
      } else {
        debugLog(`⚠️ JSON directory does not exist: ${jsonDir}`);
        // Try to create it
        try {
          fs.mkdirSync(jsonDir, { recursive: true });
          debugLog(`✅ Created JSON directory: ${jsonDir}`);
        } catch (error) {
          debugLog(`❌ Failed to create JSON directory: ${jsonDir}`, error);
        }
      }
    }
  }

  setupWatchers() {
    // Watch markdown directories
    for (const mdDir of this.watchDirectories.markdown) {
      if (fs.existsSync(mdDir)) {
        debugLog(`Setting up watcher for markdown directory: ${mdDir}`);
        try {
          const mdPattern = path.join(mdDir, '**/*.md');
          debugLog(`Watch pattern for Markdown: ${mdPattern}`);
          
          const mdWatcher = chokidar.watch(mdPattern, {
            ignored: this.exclusions,
            persistent: true,
            ignoreInitial: false, // Changed to false to log initial files
            awaitWriteFinish: {
              stabilityThreshold: 2000,
              pollInterval: 1000
            }
          });

          // Log what files are being watched initially
          mdWatcher.on('ready', () => {
            const watchedPaths = mdWatcher.getWatched();
            debugLog(`Markdown watcher ready, watching paths:`, watchedPaths);
          });

          // Log any add events to see initial files
          mdWatcher.on('add', (filePath) => {
            debugLog(`Markdown file detected: ${filePath}`);
          });

          mdWatcher.on('change', (filePath) => {
            debugLog(`📝 Detected change in Markdown file: ${filePath}`);
            
            // Modified: Use batch processing if enabled
            if (this.performanceSettings.batchProcessingEnabled) {
              this.queueMdFile(filePath);
            } else {
              this.handleMdChange(filePath);
            }
          });
          
          mdWatcher.on('error', (error) => {
            debugLog(`❌ Error in Markdown watcher:`, error);
          });
          
        } catch (error) {
          debugLog(`❌ Error setting up Markdown watcher for ${mdDir}:`, error);
        }
      }
    }

    // Watch JSON directories
    for (const jsonDir of this.watchDirectories.json) {
      if (fs.existsSync(jsonDir)) {
        debugLog(`Setting up watcher for JSON directory: ${jsonDir}`);
        try {
          const jsonPattern = path.join(jsonDir, '**/*.json');
          debugLog(`Watch pattern for JSON: ${jsonPattern}`);
          
          const jsonWatcher = chokidar.watch(jsonPattern, {
            ignored: this.exclusions,
            persistent: true,
            ignoreInitial: false, // Changed to false to log initial files
            awaitWriteFinish: {
              stabilityThreshold: 2000,
              pollInterval: 1000
            }
          });

          // Log what files are being watched initially
          jsonWatcher.on('ready', () => {
            const watchedPaths = jsonWatcher.getWatched();
            debugLog(`JSON watcher ready, watching paths:`, watchedPaths);
          });
          
          // Log any add events to see initial files
          jsonWatcher.on('add', (filePath) => {
            debugLog(`JSON file detected: ${filePath}`);
          });

          jsonWatcher.on('change', (filePath) => {
            debugLog(`📝 Detected change in JSON file: ${filePath}`);
            
            // Modified: Use batch processing if enabled
            if (this.performanceSettings.batchProcessingEnabled) {
              this.queueJsonFile(filePath);
            } else {
              this.handleJsonChange(filePath);
            }
          });
          
          jsonWatcher.on('error', (error) => {
            debugLog(`❌ Error in JSON watcher:`, error);
          });
          
        } catch (error) {
          debugLog(`❌ Error setting up JSON watcher for ${jsonDir}:`, error);
        }
      }
    }
  }

  // New: Batch processing methods
  queueMdFile(filePath) {
    debugLog(`Queueing Markdown file for batch processing: ${filePath}`);
    
    // Add to queue if not already there
    if (!this.mdQueue.includes(filePath)) {
      this.mdQueue.push(filePath);
      debugLog(`Markdown queue now contains ${this.mdQueue.length} files`);
      
      // Schedule batch processing if not already scheduled
      this.scheduleBatchProcessing();
    }
  }
  
  queueJsonFile(filePath) {
    debugLog(`Queueing JSON file for batch processing: ${filePath}`);
    
    // Add to queue if not already there
    if (!this.jsonQueue.includes(filePath)) {
      this.jsonQueue.push(filePath);
      debugLog(`JSON queue now contains ${this.jsonQueue.length} files`);
      
      // Schedule batch processing if not already scheduled
      this.scheduleBatchProcessing();
    }
  }
  
  scheduleBatchProcessing() {
    if (!this.batchTimeoutId) {
      debugLog(`Scheduling batch processing in ${this.performanceSettings.batchTimeout}ms`);
      this.batchTimeoutId = setTimeout(() => {
        this.processBatch();
        this.batchTimeoutId = null;
      }, this.performanceSettings.batchTimeout);
    }
  }
  
  async processBatch() {
    if (this.processingBatch) {
      debugLog(`Already processing a batch, will schedule another one`);
      this.scheduleBatchProcessing();
      return;
    }
    
    this.processingBatch = true;
    
    // Process markdown files first
    if (this.mdQueue.length > 0) {
      const batchStartTime = process.hrtime.bigint();
      debugLog(`Processing batch of ${this.mdQueue.length} Markdown files`);
      
      const mdFilesToProcess = this.mdQueue.splice(0, this.performanceSettings.batchSize);
      
      for (const filePath of mdFilesToProcess) {
        await this.throttleTask(() => this.handleMdChange(filePath));
      }
      
      trackPerformance(`Batch of ${mdFilesToProcess.length} Markdown files`, batchStartTime);
    }
    
    // Then process JSON files
    if (this.jsonQueue.length > 0) {
      const batchStartTime = process.hrtime.bigint();
      debugLog(`Processing batch of ${this.jsonQueue.length} JSON files`);
      
      const jsonFilesToProcess = this.jsonQueue.splice(0, this.performanceSettings.batchSize);
      
      for (const filePath of jsonFilesToProcess) {
        await this.throttleTask(() => this.handleJsonChange(filePath));
      }
      
      trackPerformance(`Batch of ${jsonFilesToProcess.length} JSON files`, batchStartTime);
    }
    
    this.processingBatch = false;
    
    // If there are still files in the queue, schedule another batch
    if (this.mdQueue.length > 0 || this.jsonQueue.length > 0) {
      debugLog(`Files still in queue: ${this.mdQueue.length} MD, ${this.jsonQueue.length} JSON`);
      this.scheduleBatchProcessing();
    }
  }
  
  // New: Throttling method
  async throttleTask(task) {
    // Wait until we're under the concurrent task limit
    while (this.performanceSettings.throttlingEnabled && 
           this.activeTasks >= this.performanceSettings.maxConcurrentTasks) {
      debugLog(`Throttling: waiting for available task slot (${this.activeTasks}/${this.performanceSettings.maxConcurrentTasks})`);
      await new Promise(resolve => setTimeout(resolve, this.performanceSettings.throttleDelay));
    }
    
    this.activeTasks++;
    
    try {
      return await Promise.resolve(task());
    } finally {
      this.activeTasks--;
    }
  }

  handleMdChange(filePath, isRetry = false) {
    const startTime = process.hrtime.bigint();
    debugLog(`Processing change in Markdown file: ${filePath}${isRetry ? ' (RETRY)' : ''}`);
    if (!isRetry) {
      console.log(`📝 Detected change in Markdown file: ${filePath}`);
      
      // New: Update stats
      this.stats.totalTransformations++;
    } else {
      // New: Update retry stats
      this.stats.totalRetries++;
    }
    
    // Create a backup
    this.createBackup(filePath);
    
    // Determine the corresponding JSON file
    const relativePath = path.relative(
      this.findContainingDirectory(filePath, this.watchDirectories.markdown),
      filePath
    );
    
    // Convert spaces to dashes in the output filename
    const normalizedPath = relativePath.replace(/\s+/g, '-');
    
    const jsonDir = this.watchDirectories.json[0]; // Use first JSON directory
    const jsonPath = path.join(jsonDir, normalizedPath.replace('.md', '.json'));
    
    debugLog(`Mapping MD to JSON: ${filePath} -> ${jsonPath}`);
    debugLog(`Relative path: ${relativePath}`);
    debugLog(`Normalized path: ${normalizedPath}`);
    
    const fileInfo = {
      source: filePath,
      target: jsonPath,
      operation: 'md-to-json'
    };
    
    // Call beforeTransform hooks
    this.emit('beforeTransform', fileInfo);
    
    // Actually perform the transformation
    try {
      // Make sure target directory exists
      const targetDir = path.dirname(jsonPath);
      if (!fs.existsSync(targetDir)) {
        fs.mkdirSync(targetDir, { recursive: true });
      }
      
      // Read the markdown file
      debugLog(`Reading markdown file: ${filePath}`);
      const mdContent = fs.readFileSync(filePath, 'utf8');
      
      // Transform markdown to JSON
      debugLog(`Transforming markdown to JSON`);
      const jsonData = this.convertMarkdownToJson(mdContent);
      
      // Write the JSON file
      debugLog(`Writing JSON file: ${jsonPath}`);
      fs.writeFileSync(jsonPath, JSON.stringify(jsonData, null, 2), 'utf8');
      
      const duration = trackPerformance(`Transform ${filePath} to ${jsonPath}`, startTime);
      
      debugLog(`✅ Successfully transformed ${filePath} to ${jsonPath} in ${duration.toFixed(2)}ms`);
      console.log(`✅ Successfully transformed ${filePath} to ${jsonPath}`);
      
      // New: Update success stats
      this.stats.successfulTransformations++;
      if (isRetry) {
        this.stats.successfulRetries++;
      }
      
      // New: Add success notification
      this.addNotification({
        type: 'success',
        title: 'Transformation Successful',
        message: `Successfully transformed ${path.basename(filePath)} to JSON format.`,
        details: {
          source: filePath,
          target: jsonPath,
          duration: duration
        }
      });
      
      // Remove from failed operations if it was there
      if (this.failedOperations.has(filePath)) {
        this.failedOperations.delete(filePath);
        debugLog(`Removed ${filePath} from failed operations map after successful transformation`);
      }
      
      // Call afterTransform hooks
      this.emit('afterTransform', { 
        ...fileInfo, 
        success: true,
        performance: {
          duration,
          timestamp: new Date().toISOString()
        }
      });
      
      // Update status file
      this.updateStatusFile();
    } catch (error) {
      const duration = trackPerformance(`Failed transform ${filePath} to ${jsonPath}`, startTime);
      
      debugLog(`❌ Error transforming ${filePath} to ${jsonPath}:`, error);
      console.error(`❌ Error transforming ${filePath} to ${jsonPath}:`, error);
      
      // New: Update error stats
      this.stats.failedTransformations++;
      
      // New: Add error notification
      this.addNotification({
        type: 'error',
        title: 'Transformation Failed',
        message: `Failed to transform ${path.basename(filePath)} to JSON format.`,
        details: {
          source: filePath,
          target: jsonPath,
          error: error.message,
          duration: duration
        }
      });
      
      // Add to retry queue if not already retrying
      if (!isRetry && this.errorRecoverySettings.enabled && this.errorRecoverySettings.retryEnabled) {
        this.addToRetryQueue(fileInfo, error);
      }
      
      this.emit('afterTransform', { 
        ...fileInfo, 
        success: false, 
        error,
        performance: {
          duration,
          timestamp: new Date().toISOString()
        }
      });
      
      // Update status file
      this.updateStatusFile();
    }
  }

  handleJsonChange(filePath, isRetry = false) {
    const startTime = process.hrtime.bigint();
    debugLog(`Processing change in JSON file: ${filePath}${isRetry ? ' (RETRY)' : ''}`);
    if (!isRetry) {
      console.log(`📝 Detected change in JSON file: ${filePath}`);
      
      // New: Update stats
      this.stats.totalTransformations++;
    } else {
      // New: Update retry stats
      this.stats.totalRetries++;
    }
    
    // Create a backup
    this.createBackup(filePath);
    
    // Determine the corresponding MD file
    const relativePath = path.relative(
      this.findContainingDirectory(filePath, this.watchDirectories.json),
      filePath
    );
    
    // Convert dashes to spaces in the output filename if they exist
    const normalizedPath = relativePath.replace(/-/g, ' ');
    
    const mdDir = this.watchDirectories.markdown[0]; // Use first MD directory
    const mdPath = path.join(mdDir, normalizedPath.replace('.json', '.md'));
    
    debugLog(`Mapping JSON to MD: ${filePath} -> ${mdPath}`);
    debugLog(`Relative path: ${relativePath}`);
    debugLog(`Normalized path: ${normalizedPath}`);
    
    const fileInfo = {
      source: filePath,
      target: mdPath,
      operation: 'json-to-md'
    };
    
    // Call beforeTransform hooks
    this.emit('beforeTransform', fileInfo);
    
    // Actually perform the transformation
    try {
      // Make sure target directory exists
      const targetDir = path.dirname(mdPath);
      if (!fs.existsSync(targetDir)) {
        fs.mkdirSync(targetDir, { recursive: true });
      }
      
      // Read the JSON file
      debugLog(`Reading JSON file: ${filePath}`);
      const jsonContent = fs.readFileSync(filePath, 'utf8');
      
      // Parse the JSON
      debugLog(`Parsing JSON`);
      const jsonData = JSON.parse(jsonContent);
      
      // Transform JSON to markdown
      debugLog(`Transforming JSON to markdown`);
      const mdContent = this.convertJsonToMarkdown(jsonData);
      
      // Write the markdown file
      debugLog(`Writing markdown file: ${mdPath}`);
      fs.writeFileSync(mdPath, mdContent, 'utf8');
      
      const duration = trackPerformance(`Transform ${filePath} to ${mdPath}`, startTime);
      
      debugLog(`✅ Successfully transformed ${filePath} to ${mdPath} in ${duration.toFixed(2)}ms`);
      console.log(`✅ Successfully transformed ${filePath} to ${mdPath}`);
      
      // New: Update success stats
      this.stats.successfulTransformations++;
      if (isRetry) {
        this.stats.successfulRetries++;
      }
      
      // New: Add success notification
      this.addNotification({
        type: 'success',
        title: 'Transformation Successful',
        message: `Successfully transformed ${path.basename(filePath)} to Markdown format.`,
        details: {
          source: filePath,
          target: mdPath,
          duration: duration
        }
      });
      
      // Remove from failed operations if it was there
      if (this.failedOperations.has(filePath)) {
        this.failedOperations.delete(filePath);
        debugLog(`Removed ${filePath} from failed operations map after successful transformation`);
      }
      
      // Call afterTransform hooks
      this.emit('afterTransform', { 
        ...fileInfo, 
        success: true,
        performance: {
          duration,
          timestamp: new Date().toISOString()
        }
      });
      
      // Update status file
      this.updateStatusFile();
    } catch (error) {
      const duration = trackPerformance(`Failed transform ${filePath} to ${mdPath}`, startTime);
      
      debugLog(`❌ Error transforming ${filePath} to ${mdPath}:`, error);
      console.error(`❌ Error transforming ${filePath} to ${mdPath}:`, error);
      
      // New: Update error stats
      this.stats.failedTransformations++;
      
      // New: Add error notification
      this.addNotification({
        type: 'error',
        title: 'Transformation Failed',
        message: `Failed to transform ${path.basename(filePath)} to Markdown format.`,
        details: {
          source: filePath,
          target: mdPath,
          error: error.message,
          duration: duration
        }
      });
      
      // Add to retry queue if not already retrying
      if (!isRetry && this.errorRecoverySettings.enabled && this.errorRecoverySettings.retryEnabled) {
        this.addToRetryQueue(fileInfo, error);
      }
      
      this.emit('afterTransform', { 
        ...fileInfo, 
        success: false, 
        error,
        performance: {
          duration,
          timestamp: new Date().toISOString()
        }
      });
      
      // Update status file
      this.updateStatusFile();
    }
  }

  convertMarkdownToJson(markdown) {
    debugLog(`Converting markdown to JSON`);
    // Basic implementation - can be enhanced based on your specific needs
    const lines = markdown.split('\n');
    const result = {
      title: '',
      sections: [],
      metadata: {
        lastUpdated: new Date().toISOString(),
        version: '1.0'
      }
    };
    
    let currentSection = null;
    
    // Extract YAML frontmatter if present
    let i = 0;
    if (lines[0] && lines[0].trim() === '---') {
      debugLog(`Found YAML frontmatter`);
      i = 1; // Skip the opening ---
      while (i < lines.length && lines[i].trim() !== '---') {
        const line = lines[i].trim();
        if (line && line.includes(':')) {
          const [key, value] = line.split(':', 2).map(part => part.trim());
          result.metadata[key] = value;
          debugLog(`Added metadata: ${key} = ${value}`);
        }
        i++;
      }
      i++; // Skip the closing ---
    }
    
    for (; i < lines.length; i++) {
      const line = lines[i].trim();
      
      // Extract title from first h1
      if (line.startsWith('# ') && !result.title) {
        result.title = line.substring(2);
        debugLog(`Found title: ${result.title}`);
        continue;
      }
      
      // Handle section headers
      if (line.startsWith('## ')) {
        currentSection = {
          title: line.substring(3),
          content: [],
          subsections: []
        };
        debugLog(`Found section: ${currentSection.title}`);
        result.sections.push(currentSection);
        continue;
      }
      
      // Handle subsection headers
      if (line.startsWith('### ') && currentSection) {
        const subsection = {
          title: line.substring(4),
          content: []
        };
        debugLog(`Found subsection: ${subsection.title}`);
        currentSection.subsections.push(subsection);
        currentSection = subsection; // Switch context to the subsection
        continue;
      }
      
      // Add content to current section/subsection
      if (currentSection && line !== '') {
        currentSection.content.push(line);
      }
    }
    
    debugLog(`Conversion complete. Found ${result.sections.length} sections`);
    return result;
  }

  convertJsonToMarkdown(json) {
    debugLog(`Converting JSON to markdown`);
    // Basic implementation - can be enhanced based on your specific needs
    let markdown = '';
    
    // Add YAML frontmatter if metadata exists
    if (json.metadata && Object.keys(json.metadata).length > 0) {
      markdown += '---\n';
      Object.entries(json.metadata).forEach(([key, value]) => {
        markdown += `${key}: ${value}\n`;
      });
      markdown += '---\n\n';
      debugLog(`Added YAML frontmatter with ${Object.keys(json.metadata).length} properties`);
    }
    
    // Add title
    if (json.title) {
      markdown += `# ${json.title}\n\n`;
      debugLog(`Added title: ${json.title}`);
    }
    
    // Process sections
    if (json.sections && Array.isArray(json.sections)) {
      debugLog(`Processing ${json.sections.length} sections`);
      json.sections.forEach(section => {
        markdown += `## ${section.title}\n\n`;
        debugLog(`Processing section: ${section.title}`);
        
        // Add section content
        if (section.content && Array.isArray(section.content)) {
          section.content.forEach(line => {
            markdown += `${line}\n`;
          });
          markdown += '\n';
        }
        
        // Process subsections
        if (section.subsections && Array.isArray(section.subsections)) {
          debugLog(`Processing ${section.subsections.length} subsections for section ${section.title}`);
          section.subsections.forEach(subsection => {
            markdown += `### ${subsection.title}\n\n`;
            debugLog(`Processing subsection: ${subsection.title}`);
            
            // Add subsection content
            if (subsection.content && Array.isArray(subsection.content)) {
              subsection.content.forEach(line => {
                markdown += `${line}\n`;
              });
              markdown += '\n';
            }
          });
        }
      });
    }
    
    debugLog(`Markdown conversion complete`);
    return markdown;
  }

  findContainingDirectory(filePath, directories) {
    for (const dir of directories) {
      if (filePath.startsWith(dir)) {
        return dir;
      }
    }
    debugLog(`Could not find containing directory for ${filePath}, using default: ${directories[0]}`);
    return directories[0]; // Default to first directory
  }

  createBackup(filePath) {
    if (!this.backupSettings.enabled) return;
    
    debugLog(`Creating backup for ${filePath}`);
    try {
      const backupDir = this.backupSettings.backupDir;
      
      // Create backup directory if it doesn't exist
      if (!fs.existsSync(backupDir)) {
        fs.mkdirSync(backupDir, { recursive: true });
        debugLog(`Created backup directory: ${backupDir}`);
      }
      
      // Generate backup filename with timestamp
      const timestamp = new Date().toISOString().replace(/:/g, '-');
      const fileName = path.basename(filePath);
      const backupPath = path.join(backupDir, `${fileName}.${timestamp}.backup`);
      
      // Copy the file to the backup location
      fs.copyFileSync(filePath, backupPath);
      debugLog(`📦 Created backup: ${backupPath}`);
      console.log(`📦 Created backup: ${backupPath}`);
      
      // Manage backup rotation if needed
      this.rotateBackups(fileName);
    } catch (error) {
      debugLog(`❌ Error creating backup for ${filePath}:`, error);
      console.error(`❌ Error creating backup for ${filePath}:`, error);
    }
  }

  rotateBackups(fileName) {
    if (!this.backupSettings.rotationEnabled || !this.backupSettings.maxBackups) return;
    
    debugLog(`Rotating backups for ${fileName}`);
    try {
      const backupDir = this.backupSettings.backupDir;
      const maxBackups = this.backupSettings.maxBackups;
      
      // Get all backups for this file
      const backups = fs.readdirSync(backupDir)
        .filter(file => file.startsWith(fileName + '.'))
        .map(file => path.join(backupDir, file));
      
      debugLog(`Found ${backups.length} backups for ${fileName}`);
      
      // If we have more backups than the maximum allowed, delete the oldest ones
      if (backups.length > maxBackups) {
        // Sort backups by creation time (oldest first)
        backups.sort((a, b) => {
          return fs.statSync(a).birthtime.getTime() - fs.statSync(b).birthtime.getTime();
        });
        
        // Delete oldest backups
        const backupsToDelete = backups.slice(0, backups.length - maxBackups);
        for (const backup of backupsToDelete) {
          fs.unlinkSync(backup);
          debugLog(`🗑️ Removed old backup: ${backup}`);
          console.log(`🗑️ Removed old backup: ${backup}`);
        }
      }
    } catch (error) {
      debugLog(`❌ Error rotating backups for ${fileName}:`, error);
      console.error(`❌ Error rotating backups for ${fileName}:`, error);
    }
  }

  stop() {
    this.running = false;
    
    // Clear any pending batch processing
    if (this.batchTimeoutId) {
      clearTimeout(this.batchTimeoutId);
      this.batchTimeoutId = null;
    }
    
    // Clear retry queue processor
    if (this.retryQueueProcessorId) {
      clearInterval(this.retryQueueProcessorId);
      this.retryQueueProcessorId = null;
    }
    
    // New: Clear status updater
    if (this.statusUpdaterId) {
      clearInterval(this.statusUpdaterId);
      this.statusUpdaterId = null;
    }
    
    // Process any remaining items in the queue
    if (this.mdQueue.length > 0 || this.jsonQueue.length > 0) {
      debugLog(`Processing ${this.mdQueue.length + this.jsonQueue.length} remaining queued files before stopping`);
      this.processBatch();
    }
    
    // New: Add shutdown notification
    this.addNotification({
      type: 'info',
      title: 'System Shutdown',
      message: 'MD-JSON Sync system is shutting down.',
      details: {
        uptime: this.calculateUptime().formatted,
        stats: this.stats
      }
    });
    
    // New: Final status update
    this.updateStatusFile();
    
    debugLog('🛑 Stopping file watch system');
    console.log('🛑 Stopped watching for file changes');
    
    // New: Show final console status
    if (this.uiSettings.enabled && this.uiSettings.consoleIndicatorsEnabled) {
      this.showConsoleStatus();
    }
    
    return this;
  }
  
  // Get status info about the system
  getStatus() {
    return {
      running: this.running,
      queueLengths: {
        markdown: this.mdQueue.length,
        json: this.jsonQueue.length,
        retry: this.retryQueue.length
      },
      activeTasks: this.activeTasks,
      processingBatch: this.processingBatch,
      errorRecovery: {
        enabled: this.errorRecoverySettings.enabled,
        failedOperationsCount: this.failedOperations.size,
        retryQueueLength: this.retryQueue.length
      },
      stats: this.stats,
      uptime: this.calculateUptime(),
      timestamp: new Date().toISOString()
    };
  }

  // New: Retry queue processor
  startRetryQueueProcessor() {
    debugLog('Starting retry queue processor');
    
    if (this.retryQueueProcessorId) {
      clearInterval(this.retryQueueProcessorId);
    }
    
    this.retryQueueProcessorId = setInterval(() => {
      this.processRetryQueue();
    }, this.errorRecoverySettings.retryQueueProcessInterval);
    
    debugLog(`Retry queue processor scheduled to run every ${this.errorRecoverySettings.retryQueueProcessInterval}ms`);
  }
  
  processRetryQueue() {
    if (!this.running || !this.errorRecoverySettings.enabled || !this.errorRecoverySettings.retryEnabled) {
      return;
    }
    
    if (this.retryQueue.length === 0) {
      return; // Nothing to process
    }
    
    debugLog(`Processing retry queue with ${this.retryQueue.length} items`);
    
    // Process one item from the queue
    const item = this.retryQueue.shift();
    
    if (!item) {
      return;
    }
    
    const { fileInfo, retryCount, lastAttempt } = item;
    
    // Check if we've exceeded the max retries
    if (retryCount >= this.errorRecoverySettings.maxRetries) {
      debugLog(`❌ Max retries (${this.errorRecoverySettings.maxRetries}) exceeded for ${fileInfo.source} -> ${fileInfo.target}`);
      console.error(`❌ Max retries (${this.errorRecoverySettings.maxRetries}) exceeded for ${fileInfo.source} -> ${fileInfo.target}`);
      
      // Remove from failed operations map
      this.failedOperations.delete(fileInfo.source);
      
      // If auto recovery is enabled, try recovery strategies
      if (this.errorRecoverySettings.autoRecoveryEnabled) {
        debugLog(`🔄 Attempting auto-recovery for ${fileInfo.source} -> ${fileInfo.target}`);
        this.attemptRecovery(fileInfo);
      }
      
      return;
    }
    
    // Calculate the delay based on exponential backoff
    const now = Date.now();
    const delay = this.errorRecoverySettings.initialRetryDelay * 
                  Math.pow(this.errorRecoverySettings.retryBackoffMultiplier, retryCount);
    const nextAttemptTime = lastAttempt + delay;
    
    if (now < nextAttemptTime) {
      // Not time to retry yet, put it back in the queue
      this.retryQueue.push(item);
      return;
    }
    
    // Time to retry
    debugLog(`🔄 Retry #${retryCount + 1} for ${fileInfo.source} -> ${fileInfo.target}`);
    console.log(`🔄 Retry #${retryCount + 1} for ${fileInfo.source} -> ${fileInfo.target}`);
    
    // Update the retry count and last attempt time
    const updatedItem = {
      ...item,
      retryCount: retryCount + 1,
      lastAttempt: now
    };
    
    // Perform the retry based on operation type
    try {
      if (fileInfo.operation === 'md-to-json') {
        this.handleMdChange(fileInfo.source, true); // true indicates this is a retry
      } else if (fileInfo.operation === 'json-to-md') {
        this.handleJsonChange(fileInfo.source, true); // true indicates this is a retry
      }
    } catch (error) {
      debugLog(`❌ Retry #${updatedItem.retryCount} failed for ${fileInfo.source}:`, error);
      
      // Put back in the queue for another attempt later
      this.retryQueue.push(updatedItem);
    }
  }
  
  // New: Add failed operation to retry queue
  addToRetryQueue(fileInfo, error) {
    if (!this.errorRecoverySettings.enabled || !this.errorRecoverySettings.retryEnabled) {
      return;
    }
    
    // Check if this file is already in the failed operations map
    if (this.failedOperations.has(fileInfo.source)) {
      debugLog(`File ${fileInfo.source} is already in the retry queue`);
      return;
    }
    
    debugLog(`Adding ${fileInfo.source} -> ${fileInfo.target} to retry queue`);
    
    const retryItem = {
      fileInfo,
      retryCount: 0,
      lastAttempt: Date.now(),
      error
    };
    
    this.retryQueue.push(retryItem);
    this.failedOperations.set(fileInfo.source, retryItem);
    
    debugLog(`Retry queue now contains ${this.retryQueue.length} items`);
  }
  
  // New: Attempt recovery for a failed operation
  attemptRecovery(fileInfo) {
    debugLog(`Attempting recovery for ${fileInfo.source} -> ${fileInfo.target}`);
    console.log(`🛠️ Attempting recovery for ${fileInfo.source} -> ${fileInfo.target}`);
    
    // New: Update recovery stats
    this.stats.recoveryAttempts++;
    
    // New: Add recovery notification
    this.addNotification({
      type: 'warning',
      title: 'Recovery Attempt',
      message: `Attempting to recover failed transformation for ${path.basename(fileInfo.source)}.`,
      details: {
        source: fileInfo.source,
        target: fileInfo.target,
        operation: fileInfo.operation
      }
    });
    
    // Try each recovery strategy in order
    for (const strategy of this.errorRecoverySettings.recoveryStrategies) {
      try {
        let result = false;
        
        switch (strategy) {
          case 'backupRestore':
            result = this.attemptBackupRestore(fileInfo);
            break;
            
          case 'partialSync':
            result = this.attemptPartialSync(fileInfo);
            break;
            
          case 'recreate':
            result = this.attemptRecreate(fileInfo);
            break;
        }
        
        if (result) {
          // New: Update success stats
          this.stats.successfulRecoveries++;
          
          // New: Add success notification
          this.addNotification({
            type: 'success',
            title: 'Recovery Successful',
            message: `Successfully recovered ${path.basename(fileInfo.source)} using ${strategy} strategy.`,
            details: {
              source: fileInfo.source,
              target: fileInfo.target,
              strategy
            }
          });
          
          // Update status file
          this.updateStatusFile();
          
          return true;
        }
      } catch (error) {
        debugLog(`Recovery strategy ${strategy} failed:`, error);
      }
    }
    
    debugLog(`❌ All recovery strategies failed for ${fileInfo.source} -> ${fileInfo.target}`);
    console.error(`❌ All recovery strategies failed for ${fileInfo.source} -> ${fileInfo.target}`);
    
    // New: Add failure notification
    this.addNotification({
      type: 'error',
      title: 'Recovery Failed',
      message: `All recovery strategies failed for ${path.basename(fileInfo.source)}.`,
      details: {
        source: fileInfo.source,
        target: fileInfo.target,
        strategies: this.errorRecoverySettings.recoveryStrategies
      }
    });
    
    // Emit recovery failure event
    this.emit('recoveryFailed', {
      ...fileInfo,
      timestamp: new Date().toISOString()
    });
    
    // Update status file
    this.updateStatusFile();
    
    return false;
  }
  
  // Recovery strategy: Restore from backup
  attemptBackupRestore(fileInfo) {
    debugLog(`Attempting backup restore for ${fileInfo.source}`);
    
    if (!this.backupSettings.enabled) {
      debugLog('Backup restore failed: Backups not enabled');
      return false;
    }
    
    try {
      const backupDir = this.backupSettings.backupDir;
      const fileName = path.basename(fileInfo.source);
      
      // Find the most recent backup for this file
      const backups = fs.readdirSync(backupDir)
        .filter(file => file.startsWith(fileName + '.'))
        .map(file => path.join(backupDir, file));
      
      if (backups.length === 0) {
        debugLog('Backup restore failed: No backups found');
        return false;
      }
      
      // Sort by creation time (newest first)
      backups.sort((a, b) => {
        return fs.statSync(b).birthtime.getTime() - fs.statSync(a).birthtime.getTime();
      });
      
      const latestBackup = backups[0];
      debugLog(`Found latest backup: ${latestBackup}`);
      
      // Restore from backup
      fs.copyFileSync(latestBackup, fileInfo.source);
      debugLog(`✅ Successfully restored ${fileInfo.source} from backup ${latestBackup}`);
      console.log(`✅ Successfully restored ${fileInfo.source} from backup ${latestBackup}`);
      
      // Trigger a re-sync
      if (fileInfo.operation === 'md-to-json') {
        this.handleMdChange(fileInfo.source);
      } else if (fileInfo.operation === 'json-to-md') {
        this.handleJsonChange(fileInfo.source);
      }
      
      return true;
    } catch (error) {
      debugLog(`Backup restore failed:`, error);
      return false;
    }
  }
  
  // Recovery strategy: Partial sync (try to salvage partial content)
  attemptPartialSync(fileInfo) {
    debugLog(`Attempting partial sync for ${fileInfo.source} -> ${fileInfo.target}`);
    
    try {
      // Check if source and target both exist
      if (!fs.existsSync(fileInfo.source) || !fs.existsSync(fileInfo.target)) {
        debugLog('Partial sync failed: Source or target file missing');
        return false;
      }
      
      if (fileInfo.operation === 'md-to-json') {
        // Try to read the markdown and do a simplified conversion
        const mdContent = fs.readFileSync(fileInfo.source, 'utf8');
        const simplifiedJson = {
          title: this.extractTitle(mdContent) || 'Recovered Document',
          content: mdContent,
          metadata: {
            recovered: true,
            recoveryTimestamp: new Date().toISOString(),
            recoveryStrategy: 'partialSync'
          }
        };
        
        fs.writeFileSync(fileInfo.target, JSON.stringify(simplifiedJson, null, 2), 'utf8');
        debugLog(`✅ Successfully created simplified JSON from ${fileInfo.source}`);
        console.log(`✅ Successfully created simplified JSON from ${fileInfo.source}`);
        return true;
      } else if (fileInfo.operation === 'json-to-md') {
        // Try to read the JSON and create a basic markdown structure
        const jsonContent = fs.readFileSync(fileInfo.source, 'utf8');
        let jsonData;
        try {
          jsonData = JSON.parse(jsonContent);
        } catch (e) {
          debugLog('Partial sync failed: Could not parse JSON');
          return false;
        }
        
        let mdContent = '---\nrecovered: true\nrecoveryTimestamp: ' + new Date().toISOString() + '\n---\n\n';
        
        if (jsonData.title) {
          mdContent += `# ${jsonData.title}\n\n`;
        } else {
          mdContent += '# Recovered Document\n\n';
        }
        
        if (jsonData.content) {
          mdContent += jsonData.content;
        } else if (jsonData.sections && Array.isArray(jsonData.sections)) {
          jsonData.sections.forEach(section => {
            if (section.title) {
              mdContent += `## ${section.title}\n\n`;
            }
            if (section.content && Array.isArray(section.content)) {
              section.content.forEach(line => {
                mdContent += `${line}\n`;
              });
              mdContent += '\n';
            }
          });
        }
        
        mdContent += '\n\n> This document was auto-recovered using partial sync strategy.';
        
        fs.writeFileSync(fileInfo.target, mdContent, 'utf8');
        debugLog(`✅ Successfully created simplified Markdown from ${fileInfo.source}`);
        console.log(`✅ Successfully created simplified Markdown from ${fileInfo.source}`);
        return true;
      }
      
      return false;
    } catch (error) {
      debugLog(`Partial sync failed:`, error);
      return false;
    }
  }
  
  // Helper: Extract title from markdown content
  extractTitle(mdContent) {
    const lines = mdContent.split('\n');
    for (const line of lines) {
      if (line.startsWith('# ')) {
        return line.substring(2).trim();
      }
    }
    return null;
  }
  
  // Recovery strategy: Recreate empty/placeholder file
  attemptRecreate(fileInfo) {
    debugLog(`Attempting to recreate ${fileInfo.target}`);
    
    try {
      // Make sure the target directory exists
      const targetDir = path.dirname(fileInfo.target);
      if (!fs.existsSync(targetDir)) {
        fs.mkdirSync(targetDir, { recursive: true });
      }
      
      // Create a placeholder file based on the operation type
      if (fileInfo.operation === 'md-to-json') {
        const fileName = path.basename(fileInfo.source, '.md');
        const placeholderJson = {
          title: fileName,
          recovered: true,
          metadata: {
            recoveryTimestamp: new Date().toISOString(),
            recoveryStrategy: 'recreate',
            originalFile: fileInfo.source
          },
          sections: [{
            title: 'Recovery Notice',
            content: ['This file was automatically recreated after multiple synchronization failures.']
          }]
        };
        
        fs.writeFileSync(fileInfo.target, JSON.stringify(placeholderJson, null, 2), 'utf8');
        debugLog(`✅ Successfully recreated placeholder JSON file ${fileInfo.target}`);
        console.log(`✅ Successfully recreated placeholder JSON file ${fileInfo.target}`);
        return true;
      } else if (fileInfo.operation === 'json-to-md') {
        const fileName = path.basename(fileInfo.source, '.json');
        const placeholderMd = `---
recovered: true
recoveryTimestamp: ${new Date().toISOString()}
recoveryStrategy: recreate
originalFile: ${fileInfo.source}
---

# ${fileName}

## Recovery Notice

This file was automatically recreated after multiple synchronization failures.

`;
        
        fs.writeFileSync(fileInfo.target, placeholderMd, 'utf8');
        debugLog(`✅ Successfully recreated placeholder Markdown file ${fileInfo.target}`);
        console.log(`✅ Successfully recreated placeholder Markdown file ${fileInfo.target}`);
        return true;
      }
      
      return false;
    } catch (error) {
      debugLog(`Recreate strategy failed:`, error);
      return false;
    }
  }
}

module.exports = MdJsonSync; 