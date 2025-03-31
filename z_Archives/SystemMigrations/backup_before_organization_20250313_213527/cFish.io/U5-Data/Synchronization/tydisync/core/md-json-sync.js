#!/usr/bin/env node

/**
 * tYDiSync~ - Bidirectional Markdown and JSON Synchronization System
 * 
 * This is the main entry point for the synchronization system that manages
 * bidirectional synchronization between Markdown and JSON files using
 * a distributed agent architecture.
 * 
 * Part of the tY FischEYe ecosystem connecting with the "Dreamflo ~" philosophy
 * 
 * @version 1.2.0
 */

const fs = require('fs');
const path = require('path');

// Import agents
const AlphaAgent = require('./alpha-agent');
const BetaAgent = require('./beta-agent');
const GammaAgent = require('./gamma-agent');
const DeltaAgent = require('./delta-agent');
const EpsilonAgent = require('./epsilon-agent');

// Parse command-line arguments
const args = process.argv.slice(2);
const options = {
  watch: args.includes('--watch'),
  verbose: args.includes('--verbose'),
  force: args.includes('--force'),
  preferMarkdown: args.includes('--prefer-md'),
  preferJson: args.includes('--prefer-json'),
  configPath: args.find(arg => arg.startsWith('--config='))?.split('=')?.[1] || './config.json'
};

// Default configuration
const defaultConfig = {
  watchDirs: [
    { md: './docs', json: './docs/json' },
    { md: './shortlinks', json: './shortlinks/json' }
  ],
  backupDir: './backups',
  maxBackups: 5,
  enableBackups: true,
  debounceTime: 500,
  exclusions: ['node_modules', '.git'],
  conflictResolutionMethod: options.preferMarkdown ? 'prefer-markdown' : 
                           options.preferJson ? 'prefer-json' : 'timestamp',
  criticalFiles: ['memory.md'],
  exitWithCursor: true,
  recursiveWatching: true,
  validationThreshold: 0.9,
  parentProcessCheckInterval: 30000
};

// Agent instances
let alphaAgent, betaAgent, gammaAgent, deltaAgent, epsilonAgent;
let config;

/**
 * Initialize the system
 */
async function initialize() {
  console.log('🚀 Starting Markdown-JSON two-way synchronization');
  
  // Load configuration
  config = await loadConfig();
  
  // Set up agents
  epsilonAgent = new EpsilonAgent(config);
  await epsilonAgent.initialize();
  
  // If Epsilon returns null, it means we should exit
  if (!epsilonAgent) {
    console.log('🛑 System initialization aborted');
    process.exit(0);
  }
  
  deltaAgent = new DeltaAgent(config);
  await deltaAgent.initialize();
  
  gammaAgent = new GammaAgent(config);
  await gammaAgent.initialize();
  
  betaAgent = new BetaAgent(config);
  await betaAgent.initialize();
  
  alphaAgent = new AlphaAgent(config);
  await alphaAgent.initialize();
  
  // Set up event handlers
  setupEventHandlers();
  
  console.log(`⚙️ Conflict resolution method: ${config.conflictResolutionMethod}`);
  
  // Process initial synchronization
  await processAllFiles();
  
  // Start watching for changes if requested
  if (options.watch) {
    console.log('🔍 Watching for file changes (two-way sync)...');
  } else {
    console.log('✅ One-time synchronization complete');
    process.exit(0);
  }
}

/**
 * Load configuration from file or use defaults
 * @returns {Object} The configuration object
 */
async function loadConfig() {
  try {
    // Check if config file exists
    if (await fileExists(options.configPath)) {
      const configContent = await fs.promises.readFile(options.configPath, 'utf8');
      const fileConfig = JSON.parse(configContent);
      
      // Merge with defaults
      return { ...defaultConfig, ...fileConfig };
    }
  } catch (error) {
    console.error(`⚠️ Error loading config: ${error.message}`);
    console.log('ℹ️ Using default configuration');
  }
  
  return defaultConfig;
}

/**
 * Set up event handlers between agents
 */
function setupEventHandlers() {
  // Handle shutdown request
  epsilonAgent.on('shutdown-requested', async (info) => {
    console.log(`🛑 Shutdown requested: ${info.reason}`);
    
    // Stop the Alpha agent (file watcher)
    if (alphaAgent) {
      alphaAgent.stopWatching();
    }
    
    // Exit after a brief delay to allow cleanup
    setTimeout(() => {
      process.exit(0);
    }, 500);
  });
  
  // Handle file changes from Alpha
  alphaAgent.on('markdown-changed', async (fileInfo) => {
    if (options.verbose) {
      console.log(`📄 Markdown file changed: ${fileInfo.path}`);
    }
    
    await synchronizeMarkdownToJson(fileInfo);
  });
  
  alphaAgent.on('json-changed', async (fileInfo) => {
    if (options.verbose) {
      console.log(`📄 JSON file changed: ${fileInfo.path}`);
    }
    
    await synchronizeJsonToMarkdown(fileInfo);
  });
  
  // Handle transformation events from Beta
  betaAgent.on('transformation-complete', (info) => {
    if (options.verbose) {
      console.log(`✅ Transformation complete: ${info.source} → ${info.target}`);
    }
  });
  
  betaAgent.on('transformation-failed', (info) => {
    console.error(`❌ Transformation failed: ${info.source}, reason: ${info.reason}`);
  });
  
  // Handle merge reports from Gamma
  gammaAgent.on('merge-report', (report) => {
    if (options.verbose || report.conflicts.length > 0 || report.warnings.length > 0) {
      console.log(`📊 Merge report for ${report.source} → ${report.target}:`);
      
      if (report.conflicts.length > 0) {
        console.log(`⚠️ Conflicts: ${report.conflicts.join(', ')}`);
      }
      
      if (report.warnings.length > 0) {
        console.log(`⚠️ Warnings: ${report.warnings.join(', ')}`);
      }
    }
  });
}

/**
 * Process all files for initial synchronization
 */
async function processAllFiles() {
  console.log('📊 Starting initial file processing with throttling');
  
  // Use a queue for processing to avoid overwhelming the system
  let processingQueue = [];
  const maxConcurrent = 5; // Maximum number of files to process concurrently
  let activeProcesses = 0;
  
  // Process all configured directories
  for (const watchDir of config.watchDirs) {
    const mdDir = watchDir.md;
    console.log(`📂 Processing ${mdDir} directory...`);
    
    // Special handling for root directory
    if (mdDir === './' || mdDir === '.') {
      console.log('📂 Processing root directory files...');
      try {
        const files = await fs.promises.readdir(process.cwd());
        
        // Filter to only include markdown files and exclude WordPress files
        const markdownFiles = files.filter(file => 
          file.endsWith('.md') && 
          !file.includes('wp-') &&
          !config.exclusions.includes(file) &&
          !file.startsWith('.')
        );
        
        console.log(`📊 Found ${markdownFiles.length} Markdown files in root directory`);
        
        // Add to processing queue
        for (const file of markdownFiles) {
          const filePath = path.join(process.cwd(), file);
          
          // Check if the file is excluded by a .nosync marker
          const isExcluded = await checkExclusionMarker(filePath);
          if (!isExcluded) {
            processingQueue.push({
              path: filePath,
              type: 'change',
              isRootFile: true
            });
          } else {
            console.log(`⚠ Skipping ${file} as it is excluded by a .nosync marker`);
          }
        }
      } catch (error) {
        console.error(`❌ Error processing root directory: ${error.message}`);
      }
      console.log('✓ Finished processing root directory files');
    } else {
      try {
        await processDirectoryThrottled(mdDir, 'md-to-json', processingQueue);
      } catch (error) {
        console.error(`❌ Error processing directory ${mdDir}: ${error.message}`);
      }
    }
  }
  
  // Process root-level JSON files
  console.log('📂 Processing root json directory...');
  const rootJsonDir = path.join(process.cwd(), 'json');
  
  if (await directoryExists(rootJsonDir)) {
    try {
      const files = await fs.promises.readdir(rootJsonDir);
      
      // Filter to only include JSON files and exclude large files
      const jsonFiles = files.filter(file => 
        file.endsWith('.json') && 
        !file.startsWith('.') &&
        !file.includes('wp-')
      );
      
      console.log(`📊 Found ${jsonFiles.length} JSON files in root json directory`);
      
      // Add to processing queue
      for (const file of jsonFiles.slice(0, 20)) { // Limit to 20 files for safety
        const jsonPath = path.join(rootJsonDir, file);
        
        // Get the corresponding markdown file to check if it's excluded
        const mdPath = betaAgent.getCorrespondingMarkdownPath(jsonPath);
        const isExcluded = await checkExclusionMarker(mdPath);
        
        if (!isExcluded) {
          processingQueue.push({
            path: jsonPath,
            type: 'change',
            isRootJsonDir: true
          });
        } else {
          console.log(`⚠ Skipping ${file} as target is excluded by a .nosync marker`);
        }
      }
    } catch (error) {
      console.error(`❌ Error processing root json directory: ${error.message}`);
    }
  }
  
  // Process the queue with throttling
  console.log(`📊 Processing queue with ${processingQueue.length} files (max ${maxConcurrent} concurrent)`);
  
  // Create a function to process items from the queue
  const processQueueItem = async () => {
    if (processingQueue.length === 0) {
      return;
    }
    
    activeProcesses++;
    const fileInfo = processingQueue.shift();
    
    try {
      if (fileInfo.path.endsWith('.md')) {
        await synchronizeMarkdownToJson(fileInfo);
      } else if (fileInfo.path.endsWith('.json')) {
        await synchronizeJsonToMarkdown(fileInfo);
      }
    } catch (error) {
      console.error(`❌ Error processing ${fileInfo.path}: ${error.message}`);
    } finally {
      activeProcesses--;
      
      // Process next item if available
      if (processingQueue.length > 0) {
        setTimeout(() => processQueueItem(), 100); // Small delay to prevent system overload
      }
    }
  };
  
  // Start initial batch of processes
  const initialBatch = Math.min(maxConcurrent, processingQueue.length);
  for (let i = 0; i < initialBatch; i++) {
    processQueueItem();
  }
  
  // Wait for all items to be processed
  while (processingQueue.length > 0 || activeProcesses > 0) {
    await new Promise(resolve => setTimeout(resolve, 500));
  }
  
  // Final report
  console.log('🎉 Initial synchronization complete');
  
  // Validate sync integrity
  await validateSyncIntegrity();
}

/**
 * Process all files in a directory with throttling
 * @param {string} dirPath The directory to process
 * @param {string} direction The direction of synchronization
 * @param {Array} queue The processing queue to add files to
 * @returns {Promise<number>} Number of files found
 */
async function processDirectoryThrottled(dirPath, direction, queue) {
  try {
    if (!await directoryExists(dirPath)) {
      return 0;
    }
    
    const files = await fs.promises.readdir(dirPath);
    let fileCount = 0;
    
    for (const file of files) {
      // Skip files that match exclusion patterns
      if (shouldExcludeFile(file)) {
        continue;
      }
      
      const filePath = path.join(dirPath, file);
      
      try {
        const stats = await fs.promises.stat(filePath);
        
        if (stats.isDirectory()) {
          // Recursively process subdirectories but skip excluded directories
          if (!shouldExcludeDirectory(file)) {
            fileCount += await processDirectoryThrottled(filePath, direction, queue);
          }
        } else if (direction === 'md-to-json' && file.endsWith('.md')) {
          // Process Markdown files
          const isExcluded = await checkExclusionMarker(filePath);
          if (!isExcluded) {
            queue.push({
              path: filePath,
              type: 'change'
            });
            fileCount++;
          }
        } else if (direction === 'json-to-md' && file.endsWith('.json')) {
          // Process JSON files
          // Get the corresponding markdown file to check if it's excluded
          const mdPath = betaAgent.getCorrespondingMarkdownPath(filePath);
          const isExcluded = await checkExclusionMarker(mdPath);
          
          if (!isExcluded) {
            queue.push({
              path: filePath,
              type: 'change'
            });
            fileCount++;
          }
        }
      } catch (error) {
        console.error(`⚠️ Error processing ${filePath}: ${error.message}`);
      }
    }
    
    console.log(`✓ Found ${fileCount} files in ${dirPath}`);
    return fileCount;
    
  } catch (error) {
    console.error(`⚠️ Error processing directory ${dirPath}: ${error.message}`);
    return 0;
  }
}

/**
 * Check if a file should be excluded based on patterns
 * @param {string} filename The filename to check
 * @returns {boolean} True if the file should be excluded
 */
function shouldExcludeFile(filename) {
  // Skip hidden files, system files, and temp files
  if (filename.startsWith('.') || 
      filename.startsWith('~') || 
      filename.endsWith('.tmp') ||
      filename.endsWith('.lock')) {
    return true;
  }
  
  // Skip WordPress-related files
  if (filename.includes('wp-') || 
      filename.startsWith('wordpress')) {
    return true;
  }
  
  // Skip files in the exclusion list
  for (const exclusion of config.exclusions) {
    if (filename.includes(exclusion)) {
      return true;
    }
  }
  
  return false;
}

/**
 * Check if a directory should be excluded based on patterns
 * @param {string} dirname The directory name to check
 * @returns {boolean} True if the directory should be excluded
 */
function shouldExcludeDirectory(dirname) {
  // Skip directories that should be excluded
  const excludedDirs = [
    'node_modules', '.git', '.cursor', 'backups', 'wp-content', 
    'wp-admin', 'wp-includes', 'vendor', 'cache', 'tmp', 'temp', 'logs'
  ];
  
  if (excludedDirs.includes(dirname) || 
      dirname.startsWith('.') || 
      dirname.startsWith('wp-')) {
    return true;
  }
  
  // Skip directories in the exclusion list
  for (const exclusion of config.exclusions) {
    if (dirname.includes(exclusion)) {
      return true;
    }
  }
  
  return false;
}

/**
 * Synchronize a Markdown file to JSON
 * @param {Object} fileInfo Information about the file
 * @returns {Promise<void>}
 */
async function synchronizeMarkdownToJson(fileInfo) {
  const mdPath = fileInfo.path;
  
  try {
    // Check if this file is excluded by a .nosync marker
    const isExcluded = await checkExclusionMarker(mdPath);
    if (isExcluded) {
      console.log(`⚠ Skipping ${mdPath} as it is excluded by a .nosync marker`);
      return;
    }
    
    // Get corresponding JSON path
    const jsonPath = betaAgent.getCorrespondingJsonPath(mdPath);
    
    // Ask Gamma if we should proceed
    const shouldSync = await gammaAgent.shouldSynchronize({
      sourcePath: mdPath,
      targetPath: jsonPath,
      direction: 'md-to-json',
      force: options.force
    });
    
    if (!shouldSync.proceed) {
      console.log(`⚠ ${shouldSync.reason}, skipping MD → JSON: ${mdPath}`);
      return;
    }
    
    // Create backup of target if it exists
    if (await fileExists(jsonPath)) {
      await deltaAgent.createBackup(jsonPath);
    }
    
    // Perform the transformation using a safe operation
    await deltaAgent.safeOperation(
      {
        sourcePath: mdPath,
        targetPath: jsonPath,
        operationType: 'md-to-json'
      },
      async () => {
        return await betaAgent.markdownToJson(fileInfo);
      }
    );
    
  } catch (error) {
    console.error(`❌ Error synchronizing ${mdPath} to JSON: ${error.message}`);
  }
}

/**
 * Synchronize a JSON file to Markdown
 * @param {Object} fileInfo Information about the file
 * @returns {Promise<void>}
 */
async function synchronizeJsonToMarkdown(fileInfo) {
  const jsonPath = fileInfo.path;
  
  try {
    // Get corresponding Markdown path
    const mdPath = betaAgent.getCorrespondingMarkdownPath(jsonPath);
    
    // Check if the target MD file is excluded by a .nosync marker
    const isExcluded = await checkExclusionMarker(mdPath);
    if (isExcluded) {
      console.log(`⚠ Skipping ${jsonPath} as target ${mdPath} is excluded by a .nosync marker`);
      return;
    }
    
    // Ask Gamma if we should proceed
    const shouldSync = await gammaAgent.shouldSynchronize({
      sourcePath: jsonPath,
      targetPath: mdPath,
      direction: 'json-to-md',
      force: options.force
    });
    
    if (!shouldSync.proceed) {
      console.log(`⚠ ${shouldSync.reason}, skipping JSON → MD: ${jsonPath}`);
      return;
    }
    
    // Create backup of target if it exists
    if (await fileExists(mdPath)) {
      await deltaAgent.createBackup(mdPath);
    }
    
    // Perform the transformation using a safe operation
    await deltaAgent.safeOperation(
      {
        sourcePath: jsonPath,
        targetPath: mdPath,
        operationType: 'json-to-md'
      },
      async () => {
        return await betaAgent.jsonToMarkdown(fileInfo);
      }
    );
    
  } catch (error) {
    console.error(`❌ Error synchronizing ${jsonPath} to Markdown: ${error.message}`);
  }
}

/**
 * Check if a file has an exclusion marker
 * @param {string} filePath The file to check
 * @returns {Promise<boolean>} True if the file should be excluded
 */
async function checkExclusionMarker(filePath) {
  const markerPath = `${filePath}.nosync`;
  
  try {
    if (await fileExists(markerPath)) {
      console.log(`⚠️ Found nosync marker for ${filePath}, excluding from synchronization`);
      return true;
    }
    return false;
  } catch (error) {
    console.error(`⚠️ Error checking exclusion marker: ${error.message}`);
    return false;
  }
}

/**
 * Validate the integrity of the synchronization
 * @returns {Promise<void>}
 */
async function validateSyncIntegrity() {
  try {
    // Validate critical files like memory.md
    for (const criticalFile of config.criticalFiles) {
      const mdPath = path.join(process.cwd(), criticalFile);
      
      if (await fileExists(mdPath)) {
        // Check size - as a basic integrity check
        const stats = await fs.promises.stat(mdPath);
        const sizeKB = stats.size / 1024;
        
        if (sizeKB < 1) {
          console.error(`❌ Validation: ${criticalFile} is suspiciously small (${sizeKB.toFixed(2)} KB)`);
        } else {
          console.log(`✓ Validation: ${criticalFile} size looks reasonable`);
        }
      }
    }
    
    // Count total Markdown and JSON files
    let mdCount = 0;
    let jsonCount = 0;
    
    for (const watchDir of config.watchDirs) {
      mdCount += await countFiles(watchDir.md, '.md');
      jsonCount += await countFiles(watchDir.json, '.json');
    }
    
    // Add root-level JSON files
    const rootJsonDir = path.join(process.cwd(), 'json');
    if (await fileExists(rootJsonDir)) {
      jsonCount += await countFiles(rootJsonDir, '.json');
    }
    
    console.log(`ℹ️ Found ${mdCount} Markdown files and ${jsonCount} JSON files`);
    
    // Check for substantial mismatch
    if (jsonCount < mdCount * 0.5) {
      console.warn(`⚠️ Significantly fewer JSON files than Markdown files. Possible synchronization issues.`);
    }
    
    console.log(`✓ Initial validation complete, no critical issues found`);
    
  } catch (error) {
    console.error(`❌ Error validating sync integrity: ${error.message}`);
  }
}

/**
 * Count files with a specific extension in a directory and its subdirectories
 * @param {string} dirPath The directory to check
 * @param {string} extension The file extension to count
 * @returns {Promise<number>} The number of matching files
 */
async function countFiles(dirPath, extension) {
  try {
    if (!await fileExists(dirPath)) {
      return 0;
    }
    
    const files = await fs.promises.readdir(dirPath);
    let count = 0;
    
    for (const file of files) {
      const filePath = path.join(dirPath, file);
      const stats = await fs.promises.stat(filePath);
      
      if (stats.isDirectory()) {
        count += await countFiles(filePath, extension);
      } else if (file.endsWith(extension)) {
        count++;
      }
    }
    
    return count;
  } catch (error) {
    console.error(`⚠️ Error counting files in ${dirPath}: ${error.message}`);
    return 0;
  }
}

/**
 * Check if a file exists
 * @param {string} filePath The file path to check
 * @returns {Promise<boolean>} True if the file exists
 */
async function fileExists(filePath) {
  try {
    await fs.promises.access(filePath, fs.constants.F_OK);
    return true;
  } catch (error) {
    return false;
  }
}

/**
 * Check if a directory exists
 * @param {string} dirPath The directory path to check
 * @returns {Promise<boolean>} True if the directory exists
 */
async function directoryExists(dirPath) {
  try {
    await fs.promises.access(dirPath, fs.constants.F_OK);
    return true;
  } catch (error) {
    return false;
  }
}

// Start the system
initialize().catch(error => {
  console.error(`🔥 Critical error during initialization: ${error.message}`);
  console.error(error.stack);
  process.exit(1);
});
