/**
 * Content Extractor Module
 * 
 * Extracts meaningful content from web pages using Readability
 * and processes it for conversion to markdown.
 * 
 * @package ucfish-scraper
 * @since 1.0.0
 */

const { chromium } = require('playwright');
const { Readability } = require('@mozilla/readability');
const { JSDOM } = require('jsdom');
const fs = require('fs-extra');
const path = require('path');
const dotenv = require('dotenv');
const sanitize = require('sanitize-filename');
const cheerio = require('cheerio');
const url = require('url');
const jsdom = require('jsdom');

// Load environment variables
dotenv.config({ path: path.join(__dirname, '../config/.env') });

class ContentExtractor {
  constructor(options = {}) {
    this.outputDir = options.outputDir || path.join(__dirname, '../output');
    this.imagesDir = options.imagesDir || path.join(this.outputDir, 'images');
    this.logDir = options.logDir || path.join(__dirname, '../logs');
    this.userAgent = process.env.USER_AGENT || 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36';
    this.headless = process.env.HEADLESS === 'true';
    this.extractTitle = options.extractTitle !== false;
    this.extractDate = options.extractDate !== false;
    this.extractAuthor = options.extractAuthor !== false;
    this.extractImages = options.extractImages !== false;
    this.extractTags = options.extractTags !== false;
    this.removeUnwanted = options.removeUnwanted !== false;
    
    // Default selectors
    this.defaultSelectors = {
      content: "article, .content, .post-content, .entry-content, main",
      title: "h1, .entry-title, .post-title, .headline",
      date: ".date, .published, time, .post-date, meta[property='article:published_time']",
      author: ".author, .byline, .post-author, meta[name='author']",
      image: ".featured-image img, .post-thumbnail img, article img:first-of-type",
      tags: ".tags a, .categories a, .post-tags a",
      unwanted: ".sidebar, .comments, .navigation, .related-posts, .social-share, .advertisement, script, style",
      nextPage: ".pagination a, .nav-next a, a.next-page"
    };
    
    // Load custom selectors if available
    this.selectorsFile = options.selectorsFile || path.join(__dirname, '../config/selectors.json');
    this.loadSelectors();
    
    // Ensure directories exist
    fs.ensureDirSync(this.outputDir);
    fs.ensureDirSync(this.imagesDir);
    fs.ensureDirSync(this.logDir);
  }

  /**
   * Loads custom selectors from configuration file
   */
  loadSelectors() {
    try {
      if (fs.existsSync(this.selectorsFile)) {
        const selectorsConfig = fs.readJsonSync(this.selectorsFile);
        this.selectors = selectorsConfig;
        this.defaultSelectors = { ...this.defaultSelectors, ...selectorsConfig.default };
      } else {
        this.selectors = { default: this.defaultSelectors };
      }
    } catch (error) {
      console.error('Error loading selectors configuration:', error.message);
      this.selectors = { default: this.defaultSelectors };
    }
  }

  /**
   * Gets the appropriate selectors for a URL
   * 
   * @param {string} urlString The URL to get selectors for
   * @returns {Object} The selectors to use
   */
  getSelectorsForUrl(urlString) {
    let selectors = { ...this.defaultSelectors };
    
    try {
      if (!this.selectors) {
        return selectors;
      }
      
      const parsedUrl = new URL(urlString);
      const hostname = parsedUrl.hostname;
      const pathname = parsedUrl.pathname;
      
      // Check for site-specific selectors
      if (this.selectors.site_specific && this.selectors.site_specific[hostname]) {
        selectors = { ...selectors, ...this.selectors.site_specific[hostname] };
      }
      
      // Check for URL pattern matches
      if (this.selectors.url_patterns) {
        for (const pattern of this.selectors.url_patterns) {
          if (pathname.includes(pattern.pattern)) {
            selectors = { ...selectors, ...pattern.selectors };
            break;
          }
        }
      }
      
      return selectors;
    } catch (error) {
      console.error('Error determining selectors:', error.message);
      return selectors;
    }
  }

  /**
   * Checks for special cases that need handling
   * 
   * @param {CheerioStatic} $ The Cheerio instance
   * @param {string} urlString The URL being processed
   * @returns {Object|null} Special case action or null
   */
  checkSpecialCases($, urlString) {
    if (!this.selectors || !this.selectors.special_cases) {
      return null;
    }
    
    for (const [caseName, caseConfig] of Object.entries(this.selectors.special_cases)) {
      if ($(caseConfig.detection).length > 0) {
        return {
          case: caseName,
          ...caseConfig
        };
      }
    }
    
    return null;
  }

  /**
   * Initializes the browser instance
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
   * Downloads images from the page
   * 
   * @param {Page} page Playwright page object
   * @param {string} pageUrl The URL of the page
   * @returns {Promise<Map<string, string>>} Map of original URLs to local paths
   */
  async downloadImages(page, pageUrl) {
    const imageMap = new Map();
    
    // Get all image elements on the page
    const images = await page.$$('img');
    console.log(`Found ${images.length} images on the page`);
    
    // Create a directory for this page's images
    const pageDirName = sanitize(new URL(pageUrl).pathname.replace(/\//g, '_'));
    const pageImageDir = path.join(this.imagesDir, pageDirName);
    fs.ensureDirSync(pageImageDir);
    
    for (let i = 0; i < images.length; i++) {
      try {
        // Get image attributes
        const src = await images[i].getAttribute('src');
        if (!src) continue;
        
        // Skip data URLs and SVGs
        if (src.startsWith('data:') || src.endsWith('.svg')) continue;
        
        const alt = await images[i].getAttribute('alt') || '';
        
        // Resolve relative URLs
        const absoluteUrl = new URL(src, pageUrl).href;
        
        // Generate a filename
        const extension = path.extname(src) || '.jpg';
        const filename = `image_${i}${extension}`;
        const imagePath = path.join(pageImageDir, filename);
        
        // Download the image
        const imageResponse = await this.context.request.get(absoluteUrl);
        if (imageResponse.ok()) {
          const imageBuffer = await imageResponse.body();
          await fs.writeFile(imagePath, imageBuffer);
          
          // Store relative path for markdown use
          const relativePath = path.relative(this.outputDir, imagePath).replace(/\\/g, '/');
          imageMap.set(absoluteUrl, {
            path: relativePath,
            alt: alt
          });
          
          console.log(`Downloaded image: ${absoluteUrl} -> ${relativePath}`);
        }
      } catch (error) {
        console.error(`Error downloading image at index ${i}:`, error.message);
      }
    }
    
    return imageMap;
  }

  /**
   * Extracts metadata from the page
   * 
   * @param {Page} page Playwright page object
   * @returns {Promise<Object>} Extracted metadata
   */
  async extractMetadata(page) {
    const metadata = {};
    
    try {
      // Extract basic metadata
      metadata.title = await page.title();
      metadata.url = page.url();
      metadata.extractedAt = new Date().toISOString();
      
      // Extract meta tags
      const metaTags = await page.$$eval('meta', metas => {
        return metas.map(meta => {
          const attributes = {};
          for (const attr of meta.getAttributeNames()) {
            attributes[attr] = meta.getAttribute(attr);
          }
          return attributes;
        });
      });
      
      // Process meta tags
      for (const meta of metaTags) {
        if (meta.name === 'description') {
          metadata.description = meta.content;
        } else if (meta.property === 'og:description') {
          metadata.ogDescription = meta.content;
        } else if (meta.property === 'og:title') {
          metadata.ogTitle = meta.content;
        } else if (meta.property === 'og:image') {
          metadata.ogImage = meta.content;
        } else if (meta.name === 'author') {
          metadata.author = meta.content;
        } else if (meta.property === 'article:published_time') {
          metadata.publishedDate = meta.content;
        } else if (meta.property === 'article:modified_time') {
          metadata.modifiedDate = meta.content;
        }
      }
      
      // Extract JSON-LD structured data
      const jsonLdScripts = await page.$$eval('script[type="application/ld+json"]', scripts => {
        return scripts.map(script => {
          try {
            return JSON.parse(script.textContent);
          } catch (e) {
            return null;
          }
        }).filter(data => data !== null);
      });
      
      if (jsonLdScripts.length > 0) {
        metadata.structuredData = jsonLdScripts;
      }
      
    } catch (error) {
      console.error('Error extracting metadata:', error.message);
    }
    
    return metadata;
  }

  /**
   * Extracts content from a web page
   * 
   * @param {string} url The URL to extract content from
   * @returns {Promise<Object>} Extracted content with metadata
   */
  async extractContent(url) {
    if (!this.browser) {
      await this.initBrowser();
    }
    
    console.log(`Extracting content from: ${url}`);
    
    const page = await this.context.newPage();
    let extractedContent = null;
    
    try {
      // Navigate to the page
      await page.goto(url, { waitUntil: 'networkidle' });
      
      // Wait for content to load
      await page.waitForSelector('body', { timeout: 10000 });
      
      // Handle any modals or overlays
      await this.dismissPopups(page);
      
      // Download images
      const imageMap = await this.downloadImages(page, url);
      
      // Extract metadata
      const metadata = await this.extractMetadata(page);
      
      // Get the HTML content
      const content = await page.content();
      
      // Use Readability to extract the main content
      const dom = new JSDOM(content, { url });
      const reader = new Readability(dom.window.document);
      const article = reader.parse();
      
      if (article) {
        // Save the extracted HTML content
        extractedContent = {
          title: article.title,
          content: article.content,
          textContent: article.textContent,
          length: article.textContent.length,
          excerpt: article.excerpt,
          siteName: article.siteName,
          byline: article.byline,
          url: url,
          metadata: metadata,
          imageMap: Object.fromEntries(imageMap),
          extractedAt: new Date().toISOString()
        };
        
        // Save the raw HTML for debug purposes
        const outputFilename = sanitize(new URL(url).pathname.replace(/\//g, '_') || 'index');
        const htmlOutputPath = path.join(this.outputDir, `${outputFilename}_raw.html`);
        await fs.writeFile(htmlOutputPath, article.content);
        
        // Save the extracted content as JSON
        const jsonOutputPath = path.join(this.outputDir, `${outputFilename}_content.json`);
        await fs.writeJson(jsonOutputPath, extractedContent, { spaces: 2 });
        
        console.log(`Content extracted and saved to ${jsonOutputPath}`);
      } else {
        console.warn(`Readability couldn't extract content from ${url}`);
      }
    } catch (error) {
      console.error(`Error extracting content from ${url}:`, error.message);
    } finally {
      await page.close();
    }
    
    return extractedContent;
  }

  /**
   * Dismisses any popups, modals, or cookie banners
   * 
   * @param {Page} page Playwright page object
   */
  async dismissPopups(page) {
    try {
      // List of common selectors for cookie banners and modals
      const selectors = [
        '[aria-label="Accept cookies"]',
        '.cookie-banner button',
        '.modal .close',
        '#cookie-notice button',
        '.modal-close',
        '[data-dismiss="modal"]'
      ];
      
      for (const selector of selectors) {
        try {
          const element = await page.$(selector);
          if (element) {
            await element.click();
            console.log(`Dismissed popup/modal with selector: ${selector}`);
            // Wait a bit for the modal to disappear
            await page.waitForTimeout(500);
          }
        } catch (e) {
          // Ignore errors for individual selectors
        }
      }
    } catch (error) {
      console.error('Error dismissing popups:', error.message);
    }
  }

  /**
   * Extracts the main content from an HTML page
   * 
   * @param {string} html The HTML content
   * @param {string} urlString The URL of the page
   * @returns {Object} The extracted content and metadata
   */
  async extract(html, urlString) {
    if (!html) {
      return { content: '', metadata: {} };
    }
    
    const $ = cheerio.load(html);
    const selectors = this.getSelectorsForUrl(urlString);
    const specialCase = this.checkSpecialCases($, urlString);
    
    // Handle special cases
    if (specialCase && specialCase.action === 'skip') {
      return { 
        content: '', 
        metadata: { 
          url: urlString,
          skipped: true,
          reason: `Special case detected: ${specialCase.case}`
        }
      };
    }
    
    // Clean unwanted elements
    if (this.removeUnwanted && selectors.unwanted) {
      $(selectors.unwanted).remove();
    }
    
    // Extract main content
    let $content;
    if (selectors.content) {
      $content = $(selectors.content);
      if ($content.length === 0) {
        // Fallback to body if no content found with selectors
        $content = $('body');
      }
    } else {
      $content = $('body');
    }
    
    // Extract metadata
    const metadata = {};
    metadata.url = urlString;
    
    // Extract title
    if (this.extractTitle && selectors.title) {
      const $title = $(selectors.title).first();
      if ($title.length > 0) {
        metadata.title = $title.text().trim();
      } else {
        metadata.title = $('title').text().trim();
      }
    }
    
    // Extract date
    if (this.extractDate && selectors.date) {
      const $date = $(selectors.date).first();
      if ($date.length > 0) {
        // Check for datetime attribute first
        const dateAttr = $date.attr('datetime') || $date.attr('content');
        if (dateAttr) {
          metadata.date = dateAttr;
        } else {
          metadata.date = $date.text().trim();
        }
      }
    }
    
    // Extract author
    if (this.extractAuthor && selectors.author) {
      const $author = $(selectors.author).first();
      if ($author.length > 0) {
        const authorAttr = $author.attr('content');
        if (authorAttr) {
          metadata.author = authorAttr;
        } else {
          metadata.author = $author.text().trim();
        }
      }
    }
    
    // Extract tags
    if (this.extractTags && selectors.tags) {
      const tags = [];
      $(selectors.tags).each((i, el) => {
        const tagText = $(el).text().trim();
        if (tagText && !tags.includes(tagText)) {
          tags.push(tagText);
        }
      });
      if (tags.length > 0) {
        metadata.tags = tags;
      }
    }
    
    // Extract next page link if pagination is present
    if (selectors.nextPage) {
      const $nextPage = $(selectors.nextPage).first();
      if ($nextPage.length > 0) {
        const nextPageHref = $nextPage.attr('href');
        if (nextPageHref) {
          metadata.nextPage = new URL(nextPageHref, urlString).toString();
        }
      }
    }
    
    // Process content-specific features
    if (selectors.features) {
      const features = [];
      $(selectors.features).each((i, el) => {
        features.push($(el).text().trim());
      });
      if (features.length > 0) {
        metadata.features = features;
      }
    }
    
    // Process price if present (for product pages)
    if (selectors.price) {
      const $price = $(selectors.price).first();
      if ($price.length > 0) {
        metadata.price = $price.text().trim();
      }
    }
    
    return {
      content: $content.html(),
      metadata
    };
  }

  /**
   * Extracts the contents of multiple pages and combines them
   * 
   * @param {Array<Object>} pages Array of { html, url } objects
   * @returns {Object} Combined content and metadata
   */
  async extractMultiplePages(pages) {
    if (!pages || pages.length === 0) {
      return { content: '', metadata: {} };
    }
    
    // Extract content from the first page to get base metadata
    const firstPageResult = await this.extract(pages[0].html, pages[0].url);
    let combinedContent = firstPageResult.content;
    const metadata = { ...firstPageResult.metadata };
    
    // Process additional pages
    for (let i = 1; i < pages.length; i++) {
      const pageResult = await this.extract(pages[i].html, pages[i].url);
      combinedContent += `\n\n${pageResult.content}`;
      
      // Update metadata
      metadata.multipage = true;
      metadata.pageCount = pages.length;
      
      if (!metadata.urls) {
        metadata.urls = [pages[0].url];
      }
      metadata.urls.push(pages[i].url);
    }
    
    return {
      content: combinedContent,
      metadata
    };
  }
}

module.exports = ContentExtractor; 