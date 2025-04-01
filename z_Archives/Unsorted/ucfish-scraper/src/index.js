/**
 * UcFish Scraper - Main Entry Point
 * 
 * This file exports all modules for programmatic usage.
 * 
 * @package ucfish-scraper
 * @since 1.0.0
 */

const Scraper = require('./scraper');
const UrlDiscovery = require('./urlDiscovery');
const ContentExtractor = require('./contentExtractor');
const MarkdownConverter = require('./markdownConverter');
const RequestManager = require('./requestManager');
const ContentProcessor = require('./contentProcessor');
const ContentVerifier = require('./contentVerifier');
const MetadataExtractor = require('./metadataExtractor');
const MetadataStore = require('./metadataStore');
const ContentMerger = require('./contentMerger');
const ProgressMonitor = require('./progressMonitor');

/**
 * Main export object
 */
module.exports = {
  // Main scraper class
  Scraper,
  
  // Core components
  UrlDiscovery,
  ContentExtractor,
  MarkdownConverter,
  RequestManager,
  
  // Processing components
  ContentProcessor,
  ContentVerifier,
  MetadataExtractor,
  
  // Storage components
  MetadataStore,
  
  // Utility components
  ContentMerger,
  ProgressMonitor,
  
  /**
   * Create a new scraper instance with the provided options
   * 
   * @param {Object} options Configuration options
   * @returns {Scraper} A new scraper instance
   */
  createScraper: (options) => new Scraper(options),
  
  /**
   * Run the scraper with the provided options
   * 
   * @param {Object} options Configuration options
   * @returns {Promise<Object>} The result of the scraping operation
   */
  run: async (options) => {
    const scraper = new Scraper(options);
    return await scraper.start(options);
  },
  
  /**
   * Verify content with the provided options
   * 
   * @param {Object} options Configuration options
   * @returns {Promise<Object>} The verification report
   */
  verify: async (options) => {
    const verifier = new ContentVerifier(options);
    return await verifier.verifyAllFiles();
  },
  
  /**
   * Merge related content with the provided options
   * 
   * @param {Object} options Configuration options
   * @returns {Promise<Array>} The merged content files
   */
  merge: async (options) => {
    const merger = new ContentMerger(options);
    return await merger.mergeRelatedContent();
  }
}; 