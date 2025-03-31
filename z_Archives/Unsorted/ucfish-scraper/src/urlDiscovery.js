/**
 * URL Discovery Module
 * 
 * Responsible for discovering all relevant URLs within the target website
 * using a breadth-first search approach.
 * 
 * @package ucfish-scraper
 * @since 1.0.0
 */

const { chromium } = require('playwright');
const fs = require('fs-extra');
const path = require('path');
const url = require('url');
const dotenv = require('dotenv');

// Load environment variables
dotenv.config({ path: path.join(__dirname, '../config/.env') });

class UrlDiscovery {
  constructor(options = {}) {
    this.baseUrl = options.baseUrl || '';
    this.maxDepth = options.maxDepth || 3;
    this.outputDir = options.outputDir || path.join(__dirname, '../output');
    this.urlsFile = options.urlsFile || path.join(this.outputDir, 'discovered_urls.json');
    this.logDir = options.logDir || path.join(__dirname, '../logs');
    this.userAgent = process.env.USER_AGENT || 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36';
    this.headless = process.env.HEADLESS === 'true';
    this.requestDelay = parseInt(process.env.REQUEST_DELAY || '2000', 10);
    
    // Initialize sets and maps to track URLs
    this.discoveredUrls = new Map();
    this.queuedUrls = new Set();
    this.processedUrls = new Set();
    
    // Ensure directories exist
    fs.ensureDirSync(this.outputDir);
    fs.ensureDirSync(this.logDir);
  }

  /**
   * Initializes the browser instance for URL discovery
   */
  async initBrowser() {
    this.browser = await chromium.launch({
      headless: this.headless
    });
    this.context = await this.browser.newContext({
      userAgent: this.userAgent,
      viewport: { width: 1920, height: 1080 }
    });
  }

  /**
   * Cleanup resources
   */
  async close() {
    if (this.browser) {
      await this.browser.close();
    }
  }

  /**
   * Determines if a URL is within the same domain as the base URL
   * 
   * @param {string} urlString The URL to check
   * @returns {boolean} True if the URL is within the same domain
   */
  isInternalUrl(urlString) {
    try {
      const parsedUrl = new URL(urlString);
      const parsedBaseUrl = new URL(this.baseUrl);
      
      return parsedUrl.hostname === parsedBaseUrl.hostname;
    } catch (error) {
      return false;
    }
  }

  /**
   * Normalizes a URL to prevent duplicates
   * 
   * @param {string} urlString The URL to normalize
   * @returns {string} The normalized URL
   */
  normalizeUrl(urlString) {
    try {
      const parsedUrl = new URL(urlString);
      
      // Remove trailing slashes
      let normalizedPath = parsedUrl.pathname;
      if (normalizedPath.endsWith('/') && normalizedPath.length > 1) {
        normalizedPath = normalizedPath.slice(0, -1);
      }
      
      // Remove common query parameters that don't affect content
      const searchParams = new URLSearchParams(parsedUrl.search);
      const importantParams = new URLSearchParams();
      
      // Preserve specific parameters like 'v' for version
      for (const [key, value] of searchParams.entries()) {
        if (['v', 'id', 'page'].includes(key)) {
          importantParams.append(key, value);
        }
      }
      
      // Reconstruct the URL
      parsedUrl.pathname = normalizedPath;
      parsedUrl.search = importantParams.toString();
      return parsedUrl.toString();
    } catch (error) {
      return urlString;
    }
  }

  /**
   * Discovers all links on a page
   * 
   * @param {string} urlString The URL to scan for links
   * @param {number} depth The current depth level
   * @returns {Promise<string[]>} Array of discovered URLs
   */
  async discoverLinksOnPage(urlString, depth) {
    console.log(`Discovering links on ${urlString} at depth ${depth}`);
    
    const page = await this.context.newPage();
    const discoveredLinks = new Set();
    
    try {
      // Navigate to the page
      await page.goto(urlString, { waitUntil: 'networkidle' });
      
      // Wait for content to load (adjust selectors based on site structure)
      await page.waitForSelector('body', { timeout: 10000 });
      
      // Extract all links
      const links = await page.evaluate(() => {
        const linkElements = document.querySelectorAll('a[href]');
        return Array.from(linkElements).map(link => link.href);
      });
      
      // Process each link
      for (const link of links) {
        if (this.isInternalUrl(link)) {
          const normalizedUrl = this.normalizeUrl(link);
          discoveredLinks.add(normalizedUrl);
        }
      }
      
      return Array.from(discoveredLinks);
    } catch (error) {
      console.error(`Error discovering links on ${urlString}:`, error.message);
      return [];
    } finally {
      await page.close();
    }
  }

  /**
   * Performs breadth-first traversal of the website
   * 
   * @returns {Promise<Map<string, Object>>} Map of discovered URLs with metadata
   */
  async discoverUrls() {
    if (!this.browser) {
      await this.initBrowser();
    }
    
    // Start with the base URL
    const normalizedBaseUrl = this.normalizeUrl(this.baseUrl);
    this.queuedUrls.add(normalizedBaseUrl);
    this.discoveredUrls.set(normalizedBaseUrl, {
      url: normalizedBaseUrl,
      depth: 0,
      parent: null,
      discovered: new Date().toISOString()
    });
    
    // Process the queue
    for (let currentDepth = 0; currentDepth <= this.maxDepth; currentDepth++) {
      const currentLevelUrls = [...this.queuedUrls].filter(url => 
        this.discoveredUrls.get(url).depth === currentDepth
      );
      
      console.log(`Processing ${currentLevelUrls.length} URLs at depth ${currentDepth}`);
      
      for (const currentUrl of currentLevelUrls) {
        // Skip if already processed
        if (this.processedUrls.has(currentUrl)) {
          continue;
        }
        
        // Process the URL
        const links = await this.discoverLinksOnPage(currentUrl, currentDepth);
        this.processedUrls.add(currentUrl);
        this.queuedUrls.delete(currentUrl);
        
        // Add delay between requests
        await new Promise(resolve => setTimeout(resolve, this.requestDelay));
        
        // Queue newly discovered URLs for the next depth level
        if (currentDepth < this.maxDepth) {
          for (const link of links) {
            if (!this.discoveredUrls.has(link)) {
              this.queuedUrls.add(link);
              this.discoveredUrls.set(link, {
                url: link,
                depth: currentDepth + 1,
                parent: currentUrl,
                discovered: new Date().toISOString()
              });
            }
          }
        }
        
        // Save progress periodically
        await this.saveDiscoveredUrls();
      }
    }
    
    return this.discoveredUrls;
  }

  /**
   * Saves the discovered URLs to a JSON file
   */
  async saveDiscoveredUrls() {
    const urlsArray = Array.from(this.discoveredUrls.values());
    await fs.writeJson(this.urlsFile, {
      baseUrl: this.baseUrl,
      maxDepth: this.maxDepth,
      totalDiscovered: urlsArray.length,
      discoveredAt: new Date().toISOString(),
      urls: urlsArray
    }, { spaces: 2 });
  }

  /**
   * Loads previously discovered URLs from a JSON file
   */
  async loadDiscoveredUrls() {
    try {
      if (await fs.pathExists(this.urlsFile)) {
        const data = await fs.readJson(this.urlsFile);
        
        // Restore the discovered URLs
        this.discoveredUrls.clear();
        for (const url of data.urls) {
          this.discoveredUrls.set(url.url, url);
        }
        
        console.log(`Loaded ${this.discoveredUrls.size} previously discovered URLs`);
      }
    } catch (error) {
      console.error('Error loading discovered URLs:', error.message);
    }
  }
}

module.exports = UrlDiscovery; 