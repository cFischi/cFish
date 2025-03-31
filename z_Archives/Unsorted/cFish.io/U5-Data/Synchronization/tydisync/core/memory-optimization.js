/**
 * MD-JSON Sync Memory Optimization Module
 * 
 * This module provides memory management and optimization features
 * for the MD-JSON synchronization system to prevent memory-related crashes
 * and improve overall stability.
 */

const fs = require('fs');
const stream = require('stream');
const { promisify } = require('util');
const v8 = require('v8');
const pipeline = promisify(stream.pipeline);
const path = require('path');

/**
 * Memory monitoring utility that tracks usage and triggers actions
 * based on configurable thresholds.
 */
class MemoryMonitor {
  constructor(config = {}) {
    this.config = {
      warningThresholdPercent: config.warningThresholdPercent || 70,
      criticalThresholdPercent: config.criticalThresholdPercent || 85,
      checkIntervalMs: config.checkIntervalMs || 5000,
      enableGarbageCollection: config.enableGarbageCollection !== false,
      gcThresholdPercent: config.gcThresholdPercent || 75,
      logFunction: config.logFunction || console.log,
      ...config
    };
    
    this.running = false;
    this.intervalId = null;
    this.stats = {
      checks: 0,
      warnings: 0,
      criticals: 0,
      gcTriggers: 0,
      maxUsageMb: 0,
      lastUsageMb: 0
    };
    
    // Event handlers
    this.onWarning = config.onWarning || (() => {});
    this.onCritical = config.onCritical || (() => {});
    this.onNormal = config.onNormal || (() => {});
  }
  
  /**
   * Start memory monitoring
   */
  start() {
    if (this.running) return;
    
    this.running = true;
    this.intervalId = setInterval(() => this.checkMemory(), this.config.checkIntervalMs);
    this.config.logFunction('🧠 Memory monitor started');
    
    return this;
  }
  
  /**
   * Stop memory monitoring
   */
  stop() {
    if (!this.running) return;
    
    this.running = false;
    if (this.intervalId) {
      clearInterval(this.intervalId);
      this.intervalId = null;
    }
    this.config.logFunction('🛑 Memory monitor stopped');
    
    return this;
  }
  
  /**
   * Check current memory usage and trigger appropriate actions
   */
  checkMemory() {
    this.stats.checks++;
    
    const memoryUsage = process.memoryUsage();
    const heapStats = v8.getHeapStatistics();
    
    const heapUsed = memoryUsage.heapUsed;
    const heapTotal = memoryUsage.heapTotal;
    const heapLimit = heapStats.heap_size_limit;
    
    const usedPercent = (heapUsed / heapLimit) * 100;
    const totalPercent = (heapTotal / heapLimit) * 100;
    
    // Convert to MB for readability
    const heapUsedMb = Math.round(heapUsed / 1024 / 1024);
    const heapTotalMb = Math.round(heapTotal / 1024 / 1024);
    const heapLimitMb = Math.round(heapLimit / 1024 / 1024);
    
    // Update stats
    this.stats.lastUsageMb = heapUsedMb;
    this.stats.maxUsageMb = Math.max(this.stats.maxUsageMb, heapUsedMb);
    
    // Log basic memory info every 10 checks
    if (this.stats.checks % 10 === 0) {
      this.config.logFunction(`📊 Memory usage: ${heapUsedMb}MB used / ${heapTotalMb}MB allocated / ${heapLimitMb}MB limit (${usedPercent.toFixed(1)}%)`);
    }
    
    // Handle memory conditions
    if (usedPercent >= this.config.criticalThresholdPercent) {
      this.stats.criticals++;
      this.config.logFunction(`❌ CRITICAL MEMORY USAGE: ${heapUsedMb}MB / ${heapLimitMb}MB (${usedPercent.toFixed(1)}%)`);
      
      if (this.config.enableGarbageCollection) {
        this.forceGarbageCollection();
      }
      
      this.onCritical({
        usedMb: heapUsedMb,
        totalMb: heapTotalMb,
        limitMb: heapLimitMb,
        usedPercent,
        totalPercent
      });
    } else if (usedPercent >= this.config.warningThresholdPercent) {
      this.stats.warnings++;
      this.config.logFunction(`⚠️ High memory usage: ${heapUsedMb}MB / ${heapLimitMb}MB (${usedPercent.toFixed(1)}%)`);
      
      if (this.config.enableGarbageCollection && usedPercent >= this.config.gcThresholdPercent) {
        this.forceGarbageCollection();
      }
      
      this.onWarning({
        usedMb: heapUsedMb,
        totalMb: heapTotalMb,
        limitMb: heapLimitMb,
        usedPercent,
        totalPercent
      });
    } else {
      this.onNormal({
        usedMb: heapUsedMb,
        totalMb: heapTotalMb,
        limitMb: heapLimitMb,
        usedPercent,
        totalPercent
      });
    }
    
    return {
      usedMb: heapUsedMb,
      totalMb: heapTotalMb,
      limitMb: heapLimitMb,
      usedPercent,
      totalPercent
    };
  }
  
  /**
   * Force garbage collection if V8 flags permit
   */
  forceGarbageCollection() {
    if (global.gc) {
      this.config.logFunction('♻️ Forcing garbage collection');
      try {
        global.gc();
        this.stats.gcTriggers++;
      } catch (error) {
        this.config.logFunction('❌ Error during forced garbage collection:', error);
      }
    } else {
      this.config.logFunction('⚠️ Cannot force garbage collection. Start Node with --expose-gc flag.');
    }
  }
  
  /**
   * Get memory monitor stats
   */
  getStats() {
    return {
      ...this.stats,
      running: this.running,
      currentUsageMb: this.stats.lastUsageMb,
      timestamp: new Date().toISOString()
    };
  }
}

/**
 * Enhanced file reader that uses streams to minimize memory usage
 */
class StreamingFileProcessor {
  constructor(config = {}) {
    this.config = {
      chunkSize: config.chunkSize || 64 * 1024, // 64KB chunks by default
      logFunction: config.logFunction || console.log,
      ...config
    };
  }
  
  /**
   * Read a file using streams and process its content with minimal memory footprint
   * @param {string} filePath Path to the file to read
   * @param {Function} processor Function that processes each chunk of data
   * @param {Object} options Additional options for file processing
   * @returns {Promise<any>} Promise that resolves with the processor's result
   */
  async processFile(filePath, processor, options = {}) {
    const startTime = process.hrtime.bigint();
    
    // Create readable stream
    const readStream = fs.createReadStream(filePath, {
      encoding: 'utf8',
      highWaterMark: this.config.chunkSize
    });
    
    let result;
    
    try {
      // Create processor
      const transformProcessor = new stream.Transform({
        objectMode: true,
        transform(chunk, encoding, callback) {
          try {
            // Process the chunk and push the result
            const processedChunk = processor(chunk, this);
            callback(null, processedChunk);
          } catch (error) {
            callback(error);
          }
        },
        flush(callback) {
          // Optional final processing
          if (options.finalizer) {
            try {
              result = options.finalizer(this);
              callback();
            } catch (error) {
              callback(error);
            }
          } else {
            callback();
          }
        }
      });
      
      // Create writable stream if needed
      let writeStream;
      if (options.outputPath) {
        writeStream = fs.createWriteStream(options.outputPath);
      } else {
        // Use a null writable stream if no output file is needed
        writeStream = new stream.Writable({
          write(chunk, encoding, callback) {
            callback();
          }
        });
      }
      
      // Process the file using pipeline
      await pipeline(
        readStream,
        transformProcessor,
        writeStream
      );
      
      const duration = Number(process.hrtime.bigint() - startTime) / 1000000;
      this.config.logFunction(`✅ Processed ${filePath} in ${duration.toFixed(2)}ms using streaming`);
      
      return result;
    } catch (error) {
      this.config.logFunction(`❌ Error processing ${filePath}:`, error);
      throw error;
    }
  }
  
  /**
   * Convert a Markdown file to JSON using streaming processing
   * @param {string} mdFilePath Path to the Markdown file
   * @param {string} jsonFilePath Path where the JSON should be written
   * @returns {Promise<Object>} Promise that resolves with the generated JSON data
   */
  async markdownToJson(mdFilePath, jsonFilePath) {
    const mdContent = {
      title: '',
      sections: [],
      metadata: {
        lastUpdated: new Date().toISOString(),
        version: '1.0'
      }
    };
    
    let currentSection = null;
    let inYamlFrontmatter = false;
    let lineBuffer = [];
    
    const lineProcessor = (chunk) => {
      // Split chunk into lines, combining with any leftover from previous chunk
      const lines = (lineBuffer.join('') + chunk).split('\n');
      
      // Save the last line in case it's incomplete
      lineBuffer = [lines.pop()];
      
      // Process each complete line
      lines.forEach(line => {
        line = line.trim();
        
        // Handle YAML frontmatter
        if (line === '---') {
          if (!inYamlFrontmatter) {
            inYamlFrontmatter = true;
          } else {
            inYamlFrontmatter = false;
          }
          return;
        }
        
        if (inYamlFrontmatter) {
          if (line && line.includes(':')) {
            const [key, value] = line.split(':', 2).map(part => part.trim());
            mdContent.metadata[key] = value;
          }
          return;
        }
        
        // Extract title from first h1
        if (line.startsWith('# ') && !mdContent.title) {
          mdContent.title = line.substring(2);
          return;
        }
        
        // Handle section headers
        if (line.startsWith('## ')) {
          currentSection = {
            title: line.substring(3),
            content: [],
            subsections: []
          };
          mdContent.sections.push(currentSection);
          return;
        }
        
        // Handle subsection headers
        if (line.startsWith('### ') && currentSection) {
          const subsection = {
            title: line.substring(4),
            content: []
          };
          currentSection.subsections.push(subsection);
          currentSection = subsection; // Switch context to the subsection
          return;
        }
        
        // Add content to current section/subsection
        if (currentSection && line !== '') {
          currentSection.content.push(line);
        }
      });
      
      // Return empty string since we're collecting results into mdContent
      return '';
    };
    
    const finalize = () => {
      // Process any remaining line in the buffer
      if (lineBuffer.length > 0 && lineBuffer[0]) {
        lineProcessor(lineBuffer[0] + '\n');
      }
      
      // Write the JSON file
      fs.writeFileSync(jsonFilePath, JSON.stringify(mdContent, null, 2), 'utf8');
      
      return mdContent;
    };
    
    return this.processFile(mdFilePath, lineProcessor, {
      finalizer: finalize,
      // We're manually writing the JSON file in the finalizer,
      // so we don't need an output path for the stream
      outputPath: null
    });
  }
  
  /**
   * Convert a JSON file to Markdown using streaming processing
   * @param {string} jsonFilePath Path to the JSON file
   * @param {string} mdFilePath Path where the Markdown should be written
   * @returns {Promise<string>} Promise that resolves with the generated Markdown content
   */
  async jsonToMarkdown(jsonFilePath, mdFilePath) {
    console.log(`Using streaming processor to convert JSON to Markdown: ${jsonFilePath} -> ${mdFilePath}`);
    
    // Ensure the output directory exists
    const targetDir = path.dirname(mdFilePath);
    if (!fs.existsSync(targetDir)) {
      fs.mkdirSync(targetDir, { recursive: true });
    }
    
    // Create a state object to maintain context between chunks
    const state = {
      inMetadata: false,
      metadataComplete: false,
      currentSection: null,
      sectionLevel: 0,
      buffer: '',
      frontmatter: {},
      sections: [],
      title: '',
      currentSectionContent: [],
      phase: 'init' // Phases: init, metadata, content, finalize
    };
    
    // First pass: Read the entire JSON file to parse its structure
    // This is necessary because JSON can't be parsed incrementally like Markdown
    try {
      const jsonContent = await fs.promises.readFile(jsonFilePath, 'utf8');
      const jsonData = JSON.parse(jsonContent);
      
      // Now use the streaming write approach to generate markdown
      const writeStream = fs.createWriteStream(mdFilePath);
      
      // Write frontmatter if exists
      if (jsonData.metadata && Object.keys(jsonData.metadata).length > 0) {
        writeStream.write('---\n');
        for (const [key, value] of Object.entries(jsonData.metadata)) {
          writeStream.write(`${key}: ${value}\n`);
        }
        writeStream.write('---\n\n');
      }
      
      // Write title
      if (jsonData.title) {
        writeStream.write(`# ${jsonData.title}\n\n`);
      }
      
      // Process sections in chunks
      if (jsonData.sections && Array.isArray(jsonData.sections)) {
        for (const section of jsonData.sections) {
          // Write section title
          writeStream.write(`## ${section.title}\n\n`);
          
          // Write section content
          if (section.content && Array.isArray(section.content)) {
            for (const line of section.content) {
              writeStream.write(`${line}\n`);
            }
            writeStream.write('\n');
          }
          
          // Process subsections
          if (section.subsections && Array.isArray(section.subsections)) {
            for (const subsection of section.subsections) {
              writeStream.write(`### ${subsection.title}\n\n`);
              
              // Write subsection content
              if (subsection.content && Array.isArray(subsection.content)) {
                for (const line of subsection.content) {
                  writeStream.write(`${line}\n`);
                }
                writeStream.write('\n');
              }
            }
          }
        }
      }
      
      // Close the stream
      writeStream.end();
      
      // Return a promise that resolves when the stream is closed
      return new Promise((resolve, reject) => {
        writeStream.on('finish', () => {
          console.log(`Successfully converted ${jsonFilePath} to ${mdFilePath} using streaming approach`);
          resolve();
        });
        
        writeStream.on('error', (err) => {
          console.error(`Error in JSON to Markdown streaming conversion:`, err);
          reject(err);
        });
      });
    } catch (error) {
      console.error(`Error in JSON to Markdown conversion:`, error);
      throw error;
    }
  }
}

/**
 * System-wide memory and process management utility
 */
class ProcessManager {
  constructor(config = {}) {
    this.config = {
      autoRestartEnabled: config.autoRestartEnabled !== false,
      maxRestarts: config.maxRestarts || 5,
      restartDelayMs: config.restartDelayMs || 5000,
      gracefulShutdownTimeoutMs: config.gracefulShutdownTimeoutMs || 10000,
      logFunction: config.logFunction || console.log,
      ...config
    };
    
    this.restartCount = 0;
    this.running = true;
    this.shutdownCallbacks = [];
    
    // Set up process event handlers
    this.setupProcessHandlers();
  }
  
  /**
   * Set up process event handlers for graceful shutdown and restart
   */
  setupProcessHandlers() {
    // Handle SIGINT (Ctrl+C)
    process.on('SIGINT', () => {
      this.config.logFunction('🛑 Received SIGINT signal. Gracefully shutting down...');
      this.performGracefulShutdown();
    });
    
    // Handle SIGTERM
    process.on('SIGTERM', () => {
      this.config.logFunction('🛑 Received SIGTERM signal. Gracefully shutting down...');
      this.performGracefulShutdown();
    });
    
    // Handle uncaught exceptions
    process.on('uncaughtException', (error) => {
      this.config.logFunction('❌ Uncaught exception:', error);
      this.handleCriticalError('uncaughtException', error);
    });
    
    // Handle unhandled promise rejections
    process.on('unhandledRejection', (reason, promise) => {
      this.config.logFunction('❌ Unhandled promise rejection:', reason);
      this.handleCriticalError('unhandledRejection', reason);
    });
    
    // Handle warning event
    process.on('warning', (warning) => {
      this.config.logFunction('⚠️ Process warning:', warning);
    });
  }
  
  /**
   * Register a callback to be called during graceful shutdown
   * @param {Function} callback Function to be called during shutdown
   * @param {string} name Optional name for the callback for logging
   */
  registerShutdownCallback(callback, name = 'unnamed') {
    this.shutdownCallbacks.push({ callback, name });
    return this;
  }
  
  /**
   * Perform graceful shutdown
   */
  async performGracefulShutdown() {
    if (!this.running) return;
    
    this.running = false;
    this.config.logFunction('🔃 Performing graceful shutdown...');
    
    // Set a timeout for the shutdown process
    const shutdownTimeout = setTimeout(() => {
      this.config.logFunction('⚠️ Shutdown taking too long. Forcing exit...');
      process.exit(1);
    }, this.config.gracefulShutdownTimeoutMs);
    
    // Execute all shutdown callbacks
    for (const { callback, name } of this.shutdownCallbacks) {
      try {
        this.config.logFunction(`🔄 Running shutdown callback: ${name}`);
        await Promise.resolve(callback());
      } catch (error) {
        this.config.logFunction(`❌ Error in shutdown callback ${name}:`, error);
      }
    }
    
    // Clear the timeout and exit gracefully
    clearTimeout(shutdownTimeout);
    this.config.logFunction('👋 Shutdown complete. Exiting gracefully.');
    process.exit(0);
  }
  
  /**
   * Handle critical errors by attempting restart or shutdown
   * @param {string} errorType Type of error that occurred
   * @param {Error} error The error object
   */
  handleCriticalError(errorType, error) {
    if (!this.running) return;
    
    // Check if it's a memory-related error
    const isMemoryError = error && error.message && (
      error.message.includes('heap') || 
      error.message.includes('memory') || 
      error.message.includes('allocation')
    );
    
    if (isMemoryError) {
      this.config.logFunction('💥 Memory-related critical error detected');
    }
    
    // Decide whether to restart or shut down
    if (this.config.autoRestartEnabled && this.restartCount < this.config.maxRestarts) {
      this.restartCount++;
      const delay = this.config.restartDelayMs;
      
      this.config.logFunction(`🔄 Scheduling restart ${this.restartCount}/${this.config.maxRestarts} in ${delay}ms...`);
      
      // Perform graceful shutdown and restart
      this.running = false;
      
      // Execute shutdown callbacks before restarting
      Promise.all(this.shutdownCallbacks.map(({ callback }) => {
        try {
          return Promise.resolve(callback());
        } catch (error) {
          return Promise.resolve();
        }
      })).then(() => {
        // Schedule restart after delay
        setTimeout(() => {
          this.config.logFunction('🔄 Restarting process...');
          
          // Save current modules to restore on restart
          const args = process.argv.slice(1);
          
          // Spawn a new process
          const { spawn } = require('child_process');
          const childProcess = spawn(process.execPath, args, {
            detached: true,
            stdio: 'inherit'
          });
          
          childProcess.unref();
          
          // Exit the current process
          process.exit(0);
        }, delay);
      });
    } else {
      this.config.logFunction(`❌ Maximum restarts (${this.config.maxRestarts}) exceeded or restarts disabled. Shutting down...`);
      this.performGracefulShutdown();
    }
  }
}

module.exports = {
  MemoryMonitor,
  StreamingFileProcessor,
  ProcessManager
}; 