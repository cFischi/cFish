/**
 * Main Scraper Module
 * 
 * Orchestrates the entire web scraping process, coordinating URL discovery,
 * content extraction, and markdown conversion.
 * 
 * @package ucfish-scraper
 * @since 1.0.0
 */

const fs = require('fs-extra');
const path = require('path');
const UrlDiscovery = require('./urlDiscovery');
const ContentExtractor = require('./contentExtractor');
const MarkdownConverter = require('./markdownConverter');
const ContentProcessor = require('./contentProcessor');
const ContentVerifier = require('./contentVerifier');
const MetadataExtractor = require('./metadataExtractor');
const OutputManager = require('./outputManager');
const ContentMerger = require('./contentMerger');
const MetadataStore = require('./metadataStore');
const ProgressMonitor = require('./progressMonitor');
const dotenv = require('dotenv');

// Load environment variables
dotenv.config({ path: path.join(__dirname, '../config/.env') });

class Scraper {
  constructor(options = {}) {
    this.baseUrl = options.baseUrl || '';
    this.maxDepth = options.maxDepth || parseInt(process.env.MAX_DEPTH || '3', 10);
    this.outputDir = options.outputDir || path.join(__dirname, '../output');
    this.concurrency = options.concurrency || parseInt(process.env.MAX_CONCURRENT_SCRAPES || '2', 10);
    this.requestDelay = options.requestDelay || parseInt(process.env.REQUEST_DELAY || '2000', 10);
    this.checkpointInterval = options.checkpointInterval || 10 * 60 * 1000; // 10 minutes
    this.resumable = options.resumable !== false;
    this.verifyOutput = options.verifyOutput !== false;
    this.mergeContent = options.mergeContent !== false;
    
    // Create component instances
    this.urlDiscovery = new UrlDiscovery({
      baseUrl: this.baseUrl,
      maxDepth: this.maxDepth,
      outputDir: this.outputDir
    });
    
    this.contentExtractor = new ContentExtractor({
      outputDir: this.outputDir
    });
    
    this.markdownConverter = new MarkdownConverter({
      outputDir: this.outputDir
    });
    
    this.contentProcessor = new ContentProcessor({
      outputDir: this.outputDir,
      baseUrl: this.baseUrl
    });
    
    this.contentVerifier = new ContentVerifier({
      outputDir: this.outputDir
    });
    
    this.metadataExtractor = new MetadataExtractor({
      outputDir: this.outputDir
    });
    
    this.outputManager = new OutputManager({
      outputDir: this.outputDir
    });
    
    this.contentMerger = new ContentMerger({
      outputDir: this.outputDir
    });
    
    this.metadataStore = new MetadataStore({
      outputDir: this.outputDir,
      baseUrl: this.baseUrl
    });
    
    this.progressMonitor = new ProgressMonitor({
      outputDir: this.outputDir
    });
    
    // Initialize state
    this.state = {
      status: 'idle',
      discoveredUrls: new Map(),
      processedUrls: new Map(),
      failedUrls: new Map(),
      startTime: null,
      endTime: null,
      lastCheckpoint: null
    };
    
    // Setup checkpoint timer
    this.checkpointTimer = null;
  }

  /**
   * Starts the scraping process
   * 
   * @param {object} options Runtime options
   * @returns {Promise<object>} Results of the scraping process
   */
  async start(options = {}) {
    // Merge options
    const runOptions = {
      startUrl: options.startUrl || this.baseUrl,
      resume: options.resume !== false && this.resumable,
      ...options
    };
    
    try {
      // Update state
      this.state.status = 'running';
      this.state.startTime = new Date();
      this.state.lastCheckpoint = new Date();
      
      // Start progress monitoring
      this.progressMonitor.start();
      
      // Setup checkpoint timer
      if (this.resumable) {
        this.checkpointTimer = setInterval(() => this.createCheckpoint(), this.checkpointInterval);
      }
      
      // Initialize components
      await this.initializeComponents();
      
      // Try to resume if requested
      if (runOptions.resume) {
        await this.tryResume();
      }
      
      console.log(`Starting scraper with base URL: ${runOptions.startUrl}`);
      console.log(`Max depth: ${this.maxDepth}, Concurrency: ${this.concurrency}`);
      
      // Discover URLs
      await this.discoverUrls(runOptions.startUrl);
      
      // Process discovered URLs
      await this.processUrls();
      
      // Post-processing steps
      await this.runPostProcessing();
      
      // Create final checkpoint
      await this.createCheckpoint();
      
      // Clean up
      if (this.checkpointTimer) {
        clearInterval(this.checkpointTimer);
      }
      
      // Update state
      this.state.status = 'completed';
      this.state.endTime = new Date();
      
      // Generate final report
      return this.generateReport();
    } catch (error) {
      console.error('Error running scraper:', error);
      
      // Update state
      this.state.status = 'error';
      this.state.endTime = new Date();
      
      // Create checkpoint on error
      await this.createCheckpoint();
      
      // Clean up
      if (this.checkpointTimer) {
        clearInterval(this.checkpointTimer);
      }
      
      throw error;
    } finally {
      // Stop progress monitoring
      this.progressMonitor.stop();
      
      // Close browser instances
      await this.closeComponents();
    }
  }

  /**
   * Initializes all components
   * 
   * @returns {Promise<void>}
   */
  async initializeComponents() {
    try {
      // Initialize browser-based components
      await this.urlDiscovery.initBrowser();
      await this.contentExtractor.initBrowser();
      await this.metadataExtractor.initBrowser();
      
      // Load any existing metadata
      await this.metadataStore.loadMetadata();
      
      console.log('All components initialized');
    } catch (error) {
      console.error('Error initializing components:', error.message);
      throw error;
    }
  }

  /**
   * Closes all components
   * 
   * @returns {Promise<void>}
   */
  async closeComponents() {
    try {
      // Close browser-based components
      await this.urlDiscovery.close();
      await this.contentExtractor.close();
      await this.metadataExtractor.close();
      
      console.log('All components closed');
    } catch (error) {
      console.error('Error closing components:', error.message);
    }
  }

  /**
   * Tries to resume a previous scraping session
   * 
   * @returns {Promise<boolean>} Whether resumption was successful
   */
  async tryResume() {
    try {
      // Check for checkpoint file
      const checkpointPath = path.join(this.outputDir, 'checkpoint.json');
      
      if (await fs.pathExists(checkpointPath)) {
        console.log('Found checkpoint file, attempting to resume');
        
        // Load checkpoint
        const checkpoint = await fs.readJson(checkpointPath);
        
        // Restore state
        this.state = {
          ...this.state,
          ...checkpoint.state
        };
        
        // Convert Maps from array format
        if (checkpoint.state.discoveredUrls) {
          this.state.discoveredUrls = new Map(checkpoint.state.discoveredUrls);
        }
        
        if (checkpoint.state.processedUrls) {
          this.state.processedUrls = new Map(checkpoint.state.processedUrls);
        }
        
        if (checkpoint.state.failedUrls) {
          this.state.failedUrls = new Map(checkpoint.state.failedUrls);
        }
        
        // Restore timestamps
        this.state.startTime = new Date(this.state.startTime);
        this.state.lastCheckpoint = new Date();
        
        // Load discovered URLs into URL discovery
        this.urlDiscovery.discoveredUrls = this.state.discoveredUrls;
        
        console.log(`Resumed session with ${this.state.discoveredUrls.size} discovered URLs and ${this.state.processedUrls.size} processed URLs`);
        
        return true;
      }
      
      console.log('No checkpoint found, starting fresh');
      return false;
    } catch (error) {
      console.error('Error resuming from checkpoint:', error.message);
      console.log('Starting fresh instead');
      return false;
    }
  }

  /**
   * Creates a checkpoint of the current state
   * 
   * @returns {Promise<void>}
   */
  async createCheckpoint() {
    try {
      // Update checkpoint time
      this.state.lastCheckpoint = new Date();
      
      // Prepare checkpoint data
      const checkpoint = {
        timestamp: new Date().toISOString(),
        state: {
          ...this.state,
          // Convert Maps to arrays for JSON serialization
          discoveredUrls: Array.from(this.state.discoveredUrls.entries()),
          processedUrls: Array.from(this.state.processedUrls.entries()),
          failedUrls: Array.from(this.state.failedUrls.entries())
        }
      };
      
      // Save checkpoint
      const checkpointPath = path.join(this.outputDir, 'checkpoint.json');
      await fs.writeJson(checkpointPath, checkpoint, { spaces: 2 });
      
      console.log(`Checkpoint created at ${new Date().toISOString()}`);
    } catch (error) {
      console.error('Error creating checkpoint:', error.message);
    }
  }

  /**
   * Discovers URLs starting from a base URL
   * 
   * @param {string} startUrl The URL to start from
   * @returns {Promise<Map<string, object>>} Discovered URLs
   */
  async discoverUrls(startUrl) {
    try {
      console.log(`Starting URL discovery from: ${startUrl}`);
      
      // Update URL discovery options
      this.urlDiscovery.baseUrl = startUrl;
      
      // Load any previously discovered URLs
      await this.urlDiscovery.loadDiscoveredUrls();
      
      // Run discovery
      const discoveredUrls = await this.urlDiscovery.discoverUrls();
      
      // Update state
      this.state.discoveredUrls = discoveredUrls;
      
      console.log(`URL discovery complete. Found ${discoveredUrls.size} URLs`);
      
      // Update progress monitor
      this.progressMonitor.setTotalUrls(discoveredUrls.size);
      
      return discoveredUrls;
    } catch (error) {
      console.error('Error discovering URLs:', error.message);
      throw error;
    }
  }

  /**
   * Processes all discovered URLs
   * 
   * @returns {Promise<void>}
   */
  async processUrls() {
    try {
      const urls = Array.from(this.state.discoveredUrls.keys());
      console.log(`Processing ${urls.length} URLs`);
      
      // Process in batches to control concurrency
      const batchSize = this.concurrency;
      
      for (let i = 0; i < urls.length; i += batchSize) {
        const batch = urls.slice(i, i + batchSize);
        
        // Process batch in parallel
        await Promise.all(batch.map(url => this.processUrl(url)));
        
        console.log(`Processed batch ${Math.floor(i / batchSize) + 1}/${Math.ceil(urls.length / batchSize)}`);
        
        // Update progress
        this.progressMonitor.updateProgress(i + batch.length, urls.length);
        
        // Create checkpoint after each batch
        await this.createCheckpoint();
      }
      
      console.log(`Finished processing ${urls.length} URLs`);
    } catch (error) {
      console.error('Error processing URLs:', error.message);
      throw error;
    }
  }

  /**
   * Processes a single URL
   * 
   * @param {string} url The URL to process
   * @returns {Promise<object>} Result of processing
   */
  async processUrl(url) {
    try {
      // Skip if already processed
      if (this.state.processedUrls.has(url)) {
        return this.state.processedUrls.get(url);
      }
      
      console.log(`Processing URL: ${url}`);
      
      // Extract content
      const extractedContent = await this.contentExtractor.extractContent(url);
      
      if (!extractedContent) {
        throw new Error('Content extraction failed');
      }
      
      // Extract additional metadata
      const metadata = await this.metadataExtractor.extractMetadata(url);
      
      // Combine content and metadata
      const combinedContent = {
        ...extractedContent,
        metadata: {
          ...extractedContent.metadata,
          ...metadata
        }
      };
      
      // Convert to markdown
      const markdownResult = await this.markdownConverter.convertToMarkdown(combinedContent);
      
      // Process the markdown content
      await this.contentProcessor.processFile(markdownResult.path, {
        url,
        title: markdownResult.title
      });
      
      // Save to output manager
      const outputPath = await this.outputManager.saveContent(
        await fs.readFile(markdownResult.path, 'utf8'),
        url,
        {
          title: markdownResult.title,
          ...metadata
        }
      );
      
      // Save metadata
      await this.metadataStore.addMetadata(url, metadata, outputPath.relativePath);
      
      // Add to processed URLs
      const result = {
        url,
        outputPath: outputPath.path,
        title: markdownResult.title,
        timestamp: new Date().toISOString()
      };
      
      this.state.processedUrls.set(url, result);
      
      // Update progress
      this.progressMonitor.incrementProcessed();
      
      console.log(`Successfully processed: ${url}`);
      
      return result;
    } catch (error) {
      console.error(`Error processing URL ${url}:`, error.message);
      
      // Add to failed URLs
      this.state.failedUrls.set(url, {
        url,
        error: error.message,
        timestamp: new Date().toISOString()
      });
      
      // Update progress
      this.progressMonitor.incrementFailed();
      
      return {
        url,
        error: error.message,
        success: false
      };
    }
  }

  /**
   * Runs post-processing steps
   * 
   * @returns {Promise<void>}
   */
  async runPostProcessing() {
    try {
      console.log('Starting post-processing steps');
      
      // Save all metadata
      await this.metadataStore.saveAllMetadata();
      
      // Create output index
      await this.outputManager.createIndexFile();
      
      // Create sitemap
      await this.outputManager.createSitemap();
      
      // Merge related content if enabled
      if (this.mergeContent) {
        await this.contentMerger.mergeRelatedContent();
      }
      
      // Verify output if enabled
      if (this.verifyOutput) {
        await this.contentVerifier.verifyAllFiles();
      }
      
      console.log('Post-processing complete');
    } catch (error) {
      console.error('Error during post-processing:', error.message);
      throw error;
    }
  }

  /**
   * Generates a final report
   * 
   * @returns {object} The report
   */
  generateReport() {
    // Calculate duration
    const duration = this.state.endTime - this.state.startTime;
    const durationMinutes = Math.round(duration / (60 * 1000));
    
    // Prepare report
    const report = {
      status: this.state.status,
      baseUrl: this.baseUrl,
      maxDepth: this.maxDepth,
      startTime: this.state.startTime.toISOString(),
      endTime: this.state.endTime.toISOString(),
      duration: `${durationMinutes} minutes`,
      statistics: {
        discovered: this.state.discoveredUrls.size,
        processed: this.state.processedUrls.size,
        failed: this.state.failedUrls.size,
        successRate: Math.round((this.state.processedUrls.size / (this.state.discoveredUrls.size || 1)) * 100)
      },
      outputDir: this.outputDir
    };
    
    // Save report
    const reportPath = path.join(this.outputDir, 'scrape_report.json');
    fs.writeJsonSync(reportPath, report, { spaces: 2 });
    
    console.log(`Report saved to ${reportPath}`);
    console.log(`Scraping complete: ${report.statistics.processed} pages processed (${report.statistics.successRate}% success rate)`);
    
    return report;
  }
}

module.exports = Scraper; 