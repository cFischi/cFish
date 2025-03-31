/**
 * Metadata Store Module
 * 
 * Manages and stores structured metadata for all scraped content.
 * Generates companion JSON files, sitemap, and content relationship graphs.
 * 
 * @package ucfish-scraper
 * @since 1.0.0
 */

const fs = require('fs-extra');
const path = require('path');
const { URL } = require('url');

class MetadataStore {
  constructor(options = {}) {
    this.outputDir = options.outputDir || path.join(__dirname, '../output');
    this.metadataDir = options.metadataDir || path.join(this.outputDir, 'metadata');
    this.sitemapPath = options.sitemapPath || path.join(this.outputDir, 'sitemap.json');
    this.contentGraphPath = options.contentGraphPath || path.join(this.outputDir, 'content_graph.json');
    this.contentMappingPath = options.contentMappingPath || path.join(this.outputDir, 'content_mapping.json');
    this.baseUrl = options.baseUrl || '';
    
    // Initialize storage
    this.metadata = new Map();
    this.urlMapping = new Map();
    this.contentGraph = {
      nodes: [],
      edges: []
    };
    
    // Ensure directories exist
    fs.ensureDirSync(this.outputDir);
    fs.ensureDirSync(this.metadataDir);
  }

  /**
   * Adds metadata for a URL
   * 
   * @param {string} url The URL
   * @param {object} metadata The metadata to store
   * @param {string} contentPath Path to the content file
   * @returns {Promise<void>}
   */
  async addMetadata(url, metadata, contentPath) {
    try {
      // Normalize the URL
      const normalizedUrl = this.normalizeUrl(url);
      
      // Store metadata
      this.metadata.set(normalizedUrl, {
        url: normalizedUrl,
        originalUrl: url,
        contentPath,
        ...metadata,
        addedAt: new Date().toISOString()
      });
      
      // Map the URL to the content path
      this.urlMapping.set(normalizedUrl, contentPath);
      
      // Add to content graph
      this.addToContentGraph(normalizedUrl, metadata);
      
      console.log(`Added metadata for: ${normalizedUrl}`);
    } catch (error) {
      console.error(`Error adding metadata for ${url}:`, error.message);
    }
  }

  /**
   * Adds a URL to the content graph
   * 
   * @param {string} url The URL
   * @param {object} metadata The metadata
   */
  addToContentGraph(url, metadata = {}) {
    // Check if node already exists
    const existingNode = this.contentGraph.nodes.find(node => node.id === url);
    
    if (!existingNode) {
      // Add node to graph
      this.contentGraph.nodes.push({
        id: url,
        label: metadata.title || url,
        type: 'page',
        metadata: {
          title: metadata.title,
          description: metadata.description,
          date: metadata.date
        }
      });
    }
    
    // Add outgoing links as edges
    if (metadata.outgoingLinks && Array.isArray(metadata.outgoingLinks)) {
      for (const link of metadata.outgoingLinks) {
        const normalizedTarget = this.normalizeUrl(link);
        
        // Check if target exists
        const targetExists = this.metadata.has(normalizedTarget) || 
                           this.contentGraph.nodes.some(node => node.id === normalizedTarget);
        
        // Add target node if it doesn't exist
        if (!targetExists) {
          this.contentGraph.nodes.push({
            id: normalizedTarget,
            label: normalizedTarget,
            type: 'external',
            metadata: {}
          });
        }
        
        // Check if edge already exists
        const edgeExists = this.contentGraph.edges.some(edge => 
          edge.source === url && edge.target === normalizedTarget
        );
        
        if (!edgeExists) {
          this.contentGraph.edges.push({
            source: url,
            target: normalizedTarget,
            type: 'link'
          });
        }
      }
    }
  }

  /**
   * Normalizes a URL
   * 
   * @param {string} urlString The URL to normalize
   * @returns {string} Normalized URL
   */
  normalizeUrl(urlString) {
    try {
      // If URL is relative, combine with base URL
      if (urlString.startsWith('/') && this.baseUrl) {
        urlString = new URL(urlString, this.baseUrl).href;
      }
      
      // Parse the URL
      const parsedUrl = new URL(urlString);
      
      // Remove trailing slash
      let pathname = parsedUrl.pathname;
      if (pathname.endsWith('/') && pathname.length > 1) {
        pathname = pathname.slice(0, -1);
      }
      
      // Keep only certain query parameters (like 'id' or 'v')
      const searchParams = new URLSearchParams(parsedUrl.search);
      const filteredParams = new URLSearchParams();
      
      for (const [key, value] of searchParams.entries()) {
        if (['id', 'v', 'page'].includes(key)) {
          filteredParams.append(key, value);
        }
      }
      
      // Build normalized URL
      parsedUrl.pathname = pathname;
      parsedUrl.search = filteredParams.toString();
      parsedUrl.hash = '';
      
      return parsedUrl.toString();
    } catch (error) {
      console.error(`Error normalizing URL: ${urlString}`, error.message);
      return urlString;
    }
  }

  /**
   * Saves all metadata to disk
   * 
   * @returns {Promise<void>}
   */
  async saveAllMetadata() {
    try {
      // Save individual metadata files
      for (const [url, metadata] of this.metadata.entries()) {
        await this.saveMetadataFile(url, metadata);
      }
      
      // Save sitemap
      await this.saveSitemap();
      
      // Save content graph
      await this.saveContentGraph();
      
      // Save URL mapping
      await this.saveContentMapping();
      
      console.log(`Saved all metadata (${this.metadata.size} entries)`);
    } catch (error) {
      console.error('Error saving all metadata:', error.message);
    }
  }

  /**
   * Saves metadata for a single URL
   * 
   * @param {string} url The URL
   * @param {object} metadata The metadata
   * @returns {Promise<string>} Path to saved file
   */
  async saveMetadataFile(url, metadata) {
    try {
      // Create a filename from the URL
      const filename = encodeURIComponent(url).replace(/%/g, '_') + '.json';
      const outputPath = path.join(this.metadataDir, filename);
      
      // Write to file
      await fs.writeJson(outputPath, {
        ...metadata,
        savedAt: new Date().toISOString()
      }, { spaces: 2 });
      
      return outputPath;
    } catch (error) {
      console.error(`Error saving metadata file for ${url}:`, error.message);
      throw error;
    }
  }

  /**
   * Saves the sitemap
   * 
   * @returns {Promise<string>} Path to saved sitemap
   */
  async saveSitemap() {
    try {
      const sitemap = {
        generated: new Date().toISOString(),
        baseUrl: this.baseUrl,
        totalPages: this.metadata.size,
        urls: Array.from(this.metadata.entries()).map(([url, metadata]) => ({
          url,
          lastModified: metadata.date || metadata.addedAt,
          title: metadata.title,
          path: this.urlMapping.get(url)
        }))
      };
      
      await fs.writeJson(this.sitemapPath, sitemap, { spaces: 2 });
      console.log(`Saved sitemap to ${this.sitemapPath}`);
      
      return this.sitemapPath;
    } catch (error) {
      console.error('Error saving sitemap:', error.message);
      throw error;
    }
  }

  /**
   * Saves the content graph
   * 
   * @returns {Promise<string>} Path to saved graph
   */
  async saveContentGraph() {
    try {
      const graph = {
        generated: new Date().toISOString(),
        baseUrl: this.baseUrl,
        nodeCount: this.contentGraph.nodes.length,
        edgeCount: this.contentGraph.edges.length,
        ...this.contentGraph
      };
      
      await fs.writeJson(this.contentGraphPath, graph, { spaces: 2 });
      console.log(`Saved content graph to ${this.contentGraphPath}`);
      
      return this.contentGraphPath;
    } catch (error) {
      console.error('Error saving content graph:', error.message);
      throw error;
    }
  }

  /**
   * Saves the content URL mapping
   * 
   * @returns {Promise<string>} Path to saved mapping
   */
  async saveContentMapping() {
    try {
      const mapping = {
        generated: new Date().toISOString(),
        baseUrl: this.baseUrl,
        totalMappings: this.urlMapping.size,
        mappings: Array.from(this.urlMapping.entries()).map(([url, contentPath]) => ({
          url,
          contentPath
        }))
      };
      
      await fs.writeJson(this.contentMappingPath, mapping, { spaces: 2 });
      console.log(`Saved content mapping to ${this.contentMappingPath}`);
      
      return this.contentMappingPath;
    } catch (error) {
      console.error('Error saving content mapping:', error.message);
      throw error;
    }
  }

  /**
   * Loads previously saved metadata
   * 
   * @returns {Promise<void>}
   */
  async loadMetadata() {
    try {
      // Check if metadata directory exists
      if (!await fs.pathExists(this.metadataDir)) {
        console.log('No existing metadata directory found');
        return;
      }
      
      // Get all JSON files in the metadata directory
      const files = await fs.readdir(this.metadataDir);
      const jsonFiles = files.filter(file => file.endsWith('.json'));
      
      console.log(`Found ${jsonFiles.length} metadata files to load`);
      
      // Load each file
      for (const file of jsonFiles) {
        try {
          const filePath = path.join(this.metadataDir, file);
          const data = await fs.readJson(filePath);
          
          if (data.url) {
            this.metadata.set(data.url, data);
            
            if (data.contentPath) {
              this.urlMapping.set(data.url, data.contentPath);
            }
          }
        } catch (error) {
          console.error(`Error loading metadata file: ${file}`, error.message);
        }
      }
      
      console.log(`Loaded ${this.metadata.size} metadata entries`);
      
      // Load content graph if it exists
      if (await fs.pathExists(this.contentGraphPath)) {
        try {
          this.contentGraph = await fs.readJson(this.contentGraphPath);
          console.log(`Loaded content graph with ${this.contentGraph.nodes.length} nodes and ${this.contentGraph.edges.length} edges`);
        } catch (error) {
          console.error('Error loading content graph:', error.message);
        }
      }
    } catch (error) {
      console.error('Error loading metadata:', error.message);
    }
  }

  /**
   * Gets metadata for a URL
   * 
   * @param {string} url The URL
   * @returns {object|null} The metadata or null if not found
   */
  getMetadata(url) {
    const normalizedUrl = this.normalizeUrl(url);
    return this.metadata.get(normalizedUrl) || null;
  }

  /**
   * Gets all metadata
   * 
   * @returns {Array<object>} Array of all metadata objects
   */
  getAllMetadata() {
    return Array.from(this.metadata.values());
  }

  /**
   * Gets the content path for a URL
   * 
   * @param {string} url The URL
   * @returns {string|null} The content path or null if not found
   */
  getContentPath(url) {
    const normalizedUrl = this.normalizeUrl(url);
    return this.urlMapping.get(normalizedUrl) || null;
  }

  /**
   * Gets related content for a URL
   * 
   * @param {string} url The URL
   * @param {number} maxResults Maximum number of results
   * @returns {Array<object>} Array of related content
   */
  getRelatedContent(url, maxResults = 5) {
    const normalizedUrl = this.normalizeUrl(url);
    const related = [];
    
    // Check if URL exists in graph
    const nodeExists = this.contentGraph.nodes.some(node => node.id === normalizedUrl);
    
    if (!nodeExists) {
      return related;
    }
    
    // Find directly linked pages
    const directLinks = this.contentGraph.edges
      .filter(edge => edge.source === normalizedUrl || edge.target === normalizedUrl)
      .map(edge => edge.source === normalizedUrl ? edge.target : edge.source);
    
    // Add metadata for each related page
    for (const link of directLinks) {
      const metadata = this.getMetadata(link);
      if (metadata) {
        related.push({
          url: link,
          title: metadata.title || link,
          contentPath: metadata.contentPath,
          relationship: 'direct'
        });
      }
    }
    
    // If we need more results, add indirect relationships
    if (related.length < maxResults) {
      // TBD: Implement more sophisticated recommendation logic
    }
    
    // Limit results
    return related.slice(0, maxResults);
  }
}

module.exports = MetadataStore; 