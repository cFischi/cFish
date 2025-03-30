/**
 * Metadata Extractor Module
 * 
 * Extracts and enhances content with metadata from various sources
 * including Open Graph, Twitter Cards, and structured data.
 * 
 * @package ucfish-scraper
 * @since 1.0.0
 */

const { chromium } = require('playwright');
const fs = require('fs-extra');
const path = require('path');
const dotenv = require('dotenv');

// Load environment variables
dotenv.config({ path: path.join(__dirname, '../config/.env') });

class MetadataExtractor {
  constructor(options = {}) {
    this.outputDir = options.outputDir || path.join(__dirname, '../output');
    this.logDir = options.logDir || path.join(__dirname, '../logs');
    this.userAgent = process.env.USER_AGENT || 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36';
    this.headless = process.env.HEADLESS === 'true';
    
    // Ensure directories exist
    fs.ensureDirSync(this.outputDir);
    fs.ensureDirSync(this.logDir);
  }

  /**
   * Initializes browser instance
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
   * Extracts metadata from a web page
   * 
   * @param {string} url The URL to extract metadata from
   * @returns {Promise<object>} The extracted metadata
   */
  async extractMetadata(url) {
    if (!this.browser) {
      await this.initBrowser();
    }
    
    console.log(`Extracting metadata from: ${url}`);
    
    const page = await this.context.newPage();
    let metadata = {
      url,
      extractedAt: new Date().toISOString(),
      openGraph: {},
      twitterCard: {},
      schemaOrg: [],
      jsonLd: [],
      meta: {},
      links: {}
    };
    
    try {
      // Navigate to the page
      await page.goto(url, { waitUntil: 'networkidle' });
      
      // Wait for content to load
      await page.waitForSelector('body', { timeout: 10000 });
      
      // Extract Open Graph metadata
      metadata.openGraph = await this.extractOpenGraph(page);
      
      // Extract Twitter Card metadata
      metadata.twitterCard = await this.extractTwitterCard(page);
      
      // Extract JSON-LD structured data
      metadata.jsonLd = await this.extractJsonLd(page);
      
      // Extract schema.org microdata
      metadata.schemaOrg = await this.extractSchemaOrg(page);
      
      // Extract basic meta tags
      metadata.meta = await this.extractMetaTags(page);
      
      // Extract link tags
      metadata.links = await this.extractLinkTags(page);
      
      // Extract page-specific metadata
      metadata = {
        ...metadata,
        ...(await this.extractPageMetadata(page, url))
      };
      
      console.log(`Metadata extraction complete for: ${url}`);
    } catch (error) {
      console.error(`Error extracting metadata from ${url}:`, error.message);
    } finally {
      await page.close();
    }
    
    return metadata;
  }

  /**
   * Extracts Open Graph metadata
   * 
   * @param {Page} page Playwright page object
   * @returns {Promise<object>} Open Graph metadata
   */
  async extractOpenGraph(page) {
    const openGraph = {};
    
    try {
      const ogTags = await page.$$eval('meta[property^="og:"]', tags => {
        return tags.map(tag => ({
          property: tag.getAttribute('property'),
          content: tag.getAttribute('content')
        }));
      });
      
      for (const tag of ogTags) {
        if (tag.property && tag.content) {
          const propertyName = tag.property.replace('og:', '');
          openGraph[propertyName] = tag.content;
        }
      }
    } catch (error) {
      console.error('Error extracting Open Graph metadata:', error.message);
    }
    
    return openGraph;
  }

  /**
   * Extracts Twitter Card metadata
   * 
   * @param {Page} page Playwright page object
   * @returns {Promise<object>} Twitter Card metadata
   */
  async extractTwitterCard(page) {
    const twitterCard = {};
    
    try {
      const twitterTags = await page.$$eval('meta[name^="twitter:"]', tags => {
        return tags.map(tag => ({
          name: tag.getAttribute('name'),
          content: tag.getAttribute('content')
        }));
      });
      
      for (const tag of twitterTags) {
        if (tag.name && tag.content) {
          const propertyName = tag.name.replace('twitter:', '');
          twitterCard[propertyName] = tag.content;
        }
      }
    } catch (error) {
      console.error('Error extracting Twitter Card metadata:', error.message);
    }
    
    return twitterCard;
  }

  /**
   * Extracts JSON-LD structured data
   * 
   * @param {Page} page Playwright page object
   * @returns {Promise<Array>} JSON-LD data
   */
  async extractJsonLd(page) {
    const jsonLdData = [];
    
    try {
      const jsonLdScripts = await page.$$eval('script[type="application/ld+json"]', scripts => {
        return scripts.map(script => {
          try {
            return JSON.parse(script.textContent);
          } catch (e) {
            return null;
          }
        }).filter(data => data !== null);
      });
      
      jsonLdData.push(...jsonLdScripts);
    } catch (error) {
      console.error('Error extracting JSON-LD data:', error.message);
    }
    
    return jsonLdData;
  }

  /**
   * Extracts schema.org microdata
   * 
   * @param {Page} page Playwright page object
   * @returns {Promise<Array>} Schema.org data
   */
  async extractSchemaOrg(page) {
    const schemaData = [];
    
    try {
      // Extract schema.org microdata
      const itemScopes = await page.$$eval('[itemscope]', elements => {
        function extractItemProps(element) {
          const result = {
            type: element.getAttribute('itemtype') || '',
            properties: {}
          };
          
          // Extract item properties
          const itemProps = element.querySelectorAll('[itemprop]');
          for (const prop of itemProps) {
            const name = prop.getAttribute('itemprop');
            let value;
            
            // Extract value based on tag name
            if (prop.tagName === 'META') {
              value = prop.getAttribute('content');
            } else if (prop.tagName === 'IMG') {
              value = prop.getAttribute('src');
            } else if (prop.tagName === 'A') {
              value = prop.getAttribute('href');
            } else if (prop.tagName === 'TIME') {
              value = prop.getAttribute('datetime') || prop.textContent;
            } else {
              value = prop.textContent;
            }
            
            // Handle nested itemscope
            if (prop.hasAttribute('itemscope')) {
              value = extractItemProps(prop);
            }
            
            result.properties[name] = value;
          }
          
          return result;
        }
        
        return elements.map(el => extractItemProps(el));
      });
      
      schemaData.push(...itemScopes);
    } catch (error) {
      console.error('Error extracting schema.org data:', error.message);
    }
    
    return schemaData;
  }

  /**
   * Extracts meta tags
   * 
   * @param {Page} page Playwright page object
   * @returns {Promise<object>} Meta tag data
   */
  async extractMetaTags(page) {
    const meta = {};
    
    try {
      const metaTags = await page.$$eval('meta', tags => {
        return tags.map(tag => {
          const attributes = {};
          for (const attr of tag.getAttributeNames()) {
            attributes[attr] = tag.getAttribute(attr);
          }
          return attributes;
        });
      });
      
      for (const tag of metaTags) {
        // Handle different meta tag formats
        if (tag.name && tag.content) {
          meta[tag.name] = tag.content;
        } else if (tag.property && tag.content && !tag.property.startsWith('og:')) {
          meta[tag.property] = tag.content;
        }
      }
    } catch (error) {
      console.error('Error extracting meta tags:', error.message);
    }
    
    return meta;
  }

  /**
   * Extracts link tags
   * 
   * @param {Page} page Playwright page object
   * @returns {Promise<object>} Link tag data
   */
  async extractLinkTags(page) {
    const links = {};
    
    try {
      const linkTags = await page.$$eval('link[rel]', tags => {
        return tags.map(tag => ({
          rel: tag.getAttribute('rel'),
          href: tag.getAttribute('href'),
          type: tag.getAttribute('type')
        }));
      });
      
      for (const tag of linkTags) {
        if (tag.rel && tag.href) {
          // Group links by rel attribute
          if (!links[tag.rel]) {
            links[tag.rel] = [];
          }
          
          links[tag.rel].push({
            href: tag.href,
            type: tag.type
          });
        }
      }
    } catch (error) {
      console.error('Error extracting link tags:', error.message);
    }
    
    return links;
  }

  /**
   * Extracts page-specific metadata (authors, dates, etc.)
   * 
   * @param {Page} page Playwright page object
   * @param {string} url The URL of the page
   * @returns {Promise<object>} Page-specific metadata
   */
  async extractPageMetadata(page, url) {
    const pageMetadata = {
      title: '',
      description: '',
      author: '',
      publishDate: '',
      modifiedDate: '',
      keywords: [],
      language: ''
    };
    
    try {
      // Get page title
      pageMetadata.title = await page.title();
      
      // Get standard meta description
      pageMetadata.description = await page.$eval('meta[name="description"]', el => el.getAttribute('content'))
        .catch(() => '');
      
      // Try to find author information
      pageMetadata.author = await page.$eval('meta[name="author"]', el => el.getAttribute('content'))
        .catch(() => '');
        
      if (!pageMetadata.author) {
        // Try common author selectors
        const authorSelectors = [
          '.author',
          '.byline',
          '[rel="author"]',
          'meta[property="article:author"]'
        ];
        
        for (const selector of authorSelectors) {
          try {
            const authorElement = await page.$(selector);
            if (authorElement) {
              if (selector.startsWith('meta')) {
                pageMetadata.author = await authorElement.getAttribute('content');
              } else {
                pageMetadata.author = await authorElement.textContent();
              }
              pageMetadata.author = pageMetadata.author.trim();
              if (pageMetadata.author) break;
            }
          } catch (e) {
            // Continue to next selector
          }
        }
      }
      
      // Try to find publication date
      const dateSelectors = [
        'meta[property="article:published_time"]',
        'meta[name="date"]',
        'time[datetime]',
        '.published-date',
        '.post-date',
        '[itemprop="datePublished"]'
      ];
      
      for (const selector of dateSelectors) {
        try {
          const dateElement = await page.$(selector);
          if (dateElement) {
            if (selector.includes('time[datetime]')) {
              pageMetadata.publishDate = await dateElement.getAttribute('datetime');
            } else if (selector.startsWith('meta')) {
              pageMetadata.publishDate = await dateElement.getAttribute('content');
            } else {
              pageMetadata.publishDate = await dateElement.textContent();
            }
            pageMetadata.publishDate = pageMetadata.publishDate.trim();
            if (pageMetadata.publishDate) break;
          }
        } catch (e) {
          // Continue to next selector
        }
      }
      
      // Try to find modification date
      const modifiedSelectors = [
        'meta[property="article:modified_time"]',
        'meta[name="last-modified"]',
        '[itemprop="dateModified"]',
        '.updated-date'
      ];
      
      for (const selector of modifiedSelectors) {
        try {
          const dateElement = await page.$(selector);
          if (dateElement) {
            if (selector.startsWith('meta')) {
              pageMetadata.modifiedDate = await dateElement.getAttribute('content');
            } else {
              pageMetadata.modifiedDate = await dateElement.textContent();
            }
            pageMetadata.modifiedDate = pageMetadata.modifiedDate.trim();
            if (pageMetadata.modifiedDate) break;
          }
        } catch (e) {
          // Continue to next selector
        }
      }
      
      // Get keywords
      try {
        const keywords = await page.$eval('meta[name="keywords"]', el => el.getAttribute('content'));
        if (keywords) {
          pageMetadata.keywords = keywords.split(',').map(k => k.trim());
        }
      } catch (e) {
        // No keywords meta tag
      }
      
      // Get language
      pageMetadata.language = await page.$eval('html', el => el.getAttribute('lang'))
        .catch(() => '');
    } catch (error) {
      console.error('Error extracting page metadata:', error.message);
    }
    
    return pageMetadata;
  }

  /**
   * Saves metadata to a JSON file
   * 
   * @param {string} url The URL of the page
   * @param {object} metadata The metadata to save
   * @returns {Promise<string>} The path to the saved file
   */
  async saveMetadata(url, metadata) {
    try {
      // Generate filename from URL
      const filename = url.replace(/[^a-z0-9]/gi, '_').toLowerCase();
      const outputPath = path.join(this.outputDir, `${filename}_metadata.json`);
      
      // Save to file
      await fs.writeJson(outputPath, metadata, { spaces: 2 });
      console.log(`Metadata saved to ${outputPath}`);
      
      return outputPath;
    } catch (error) {
      console.error(`Error saving metadata for ${url}:`, error.message);
      throw error;
    }
  }
}

module.exports = MetadataExtractor; 