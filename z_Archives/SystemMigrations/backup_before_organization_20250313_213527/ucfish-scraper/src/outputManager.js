/**
 * Output Manager Module
 * 
 * Manages the output of scraped content, organizing files in a
 * hierarchical structure and generating index files.
 * 
 * @package ucfish-scraper
 * @since 1.0.0
 */

const fs = require('fs-extra');
const path = require('path');
const sanitize = require('sanitize-filename');
const url = require('url');

class OutputManager {
  constructor(options = {}) {
    this.outputDir = options.outputDir || path.join(__dirname, '../output');
    this.imagesDir = options.imagesDir || path.join(this.outputDir, 'images');
    this.metadataDir = options.metadataDir || path.join(this.outputDir, 'metadata');
    this.contentDir = options.contentDir || path.join(this.outputDir, 'content');
    this.sitemapPath = options.sitemapPath || path.join(this.outputDir, 'sitemap.json');
    this.indexPath = options.indexPath || path.join(this.outputDir, 'index.md');
    
    // Ensure directories exist
    fs.ensureDirSync(this.outputDir);
    fs.ensureDirSync(this.imagesDir);
    fs.ensureDirSync(this.metadataDir);
    fs.ensureDirSync(this.contentDir);
    
    // Track files
    this.fileMap = new Map();
  }

  /**
   * Creates a sanitized and organized file path from a URL
   * 
   * @param {string} url The URL to create a path for
   * @param {object} options Path creation options
   * @returns {object} Path information
   */
  createPathFromUrl(url, options = {}) {
    try {
      const parsedUrl = new URL(url);
      const urlPath = parsedUrl.pathname;
      
      // Default to 'index' for root path
      if (urlPath === '/' || !urlPath) {
        return {
          directory: this.contentDir,
          filename: 'index',
          extension: options.extension || '.md',
          fullPath: path.join(this.contentDir, `index${options.extension || '.md'}`),
          relativePath: `content/index${options.extension || '.md'}`
        };
      }
      
      // Split the path into segments
      const segments = urlPath.split('/').filter(s => s);
      
      // Last segment will be the filename
      const lastSegment = segments.pop() || 'index';
      
      // Create a sanitized filename
      let filename = sanitize(lastSegment.replace(/\.\w+$/, ''));
      
      // If filename is empty or just dots/dashes, use 'index'
      if (!filename || /^[.\-_]+$/.test(filename)) {
        filename = 'index';
      }
      
      // Create directory structure
      let dirPath = this.contentDir;
      
      if (segments.length > 0 && options.createSubdirectories !== false) {
        const sanitizedSegments = segments.map(segment => sanitize(segment));
        dirPath = path.join(this.contentDir, ...sanitizedSegments);
        fs.ensureDirSync(dirPath);
      }
      
      // Add the extension
      const extension = options.extension || '.md';
      const fullPath = path.join(dirPath, `${filename}${extension}`);
      
      // Create a relative path from output directory
      const relativePath = path.relative(this.outputDir, fullPath).replace(/\\/g, '/');
      
      return {
        directory: dirPath,
        filename,
        extension,
        fullPath,
        relativePath
      };
    } catch (error) {
      console.error(`Error creating path from URL: ${url}`, error.message);
      
      // Fallback to a simple hash of the URL
      const fallbackName = `page_${Buffer.from(url).toString('hex').substring(0, 8)}`;
      return {
        directory: this.contentDir,
        filename: fallbackName,
        extension: options.extension || '.md',
        fullPath: path.join(this.contentDir, `${fallbackName}${options.extension || '.md'}`),
        relativePath: `content/${fallbackName}${options.extension || '.md'}`
      };
    }
  }

  /**
   * Saves content to a file
   * 
   * @param {string} content The content to save
   * @param {string} url The source URL
   * @param {object} metadata Additional metadata
   * @param {object} options Output options
   * @returns {Promise<object>} Information about the saved file
   */
  async saveContent(content, url, metadata = {}, options = {}) {
    try {
      // Generate path information
      const pathInfo = this.createPathFromUrl(url, {
        extension: options.extension || '.md',
        createSubdirectories: options.createSubdirectories
      });
      
      // Check if content needs frontmatter
      let contentToSave = content;
      
      if (options.addFrontmatter !== false && !content.startsWith('---\n')) {
        const frontmatter = this.createFrontmatter({
          title: metadata.title || pathInfo.filename,
          url,
          ...metadata
        });
        contentToSave = frontmatter + contentToSave;
      }
      
      // Write the file
      await fs.writeFile(pathInfo.fullPath, contentToSave);
      
      // Track this file
      this.fileMap.set(url, {
        url,
        path: pathInfo.relativePath,
        fullPath: pathInfo.fullPath,
        title: metadata.title || pathInfo.filename,
        date: metadata.date || new Date().toISOString(),
        ...metadata
      });
      
      console.log(`Saved content to ${pathInfo.fullPath}`);
      
      return {
        path: pathInfo.fullPath,
        relativePath: pathInfo.relativePath,
        url
      };
    } catch (error) {
      console.error(`Error saving content for ${url}:`, error.message);
      throw error;
    }
  }

  /**
   * Creates YAML frontmatter for markdown files
   * 
   * @param {object} metadata The metadata to include
   * @returns {string} Formatted frontmatter
   */
  createFrontmatter(metadata = {}) {
    const frontmatter = ['---'];
    
    // Add title
    frontmatter.push(`title: ${JSON.stringify(metadata.title || 'Untitled')}`);
    
    // Add date
    frontmatter.push(`date: "${metadata.date || new Date().toISOString()}"`);
    
    // Add source URL
    if (metadata.url) {
      frontmatter.push(`source_url: "${metadata.url}"`);
    }
    
    // Add author if available
    if (metadata.author) {
      frontmatter.push(`author: ${JSON.stringify(metadata.author)}`);
    }
    
    // Add description if available
    if (metadata.description) {
      frontmatter.push(`description: ${JSON.stringify(metadata.description)}`);
    }
    
    // Add any other simple metadata
    for (const [key, value] of Object.entries(metadata)) {
      if (
        !['title', 'date', 'url', 'author', 'description', 'content'].includes(key) && 
        typeof value !== 'object' && 
        value !== undefined
      ) {
        frontmatter.push(`${key}: ${JSON.stringify(value)}`);
      }
    }
    
    frontmatter.push('---\n\n');
    
    return frontmatter.join('\n');
  }

  /**
   * Saves a companion metadata JSON file
   * 
   * @param {string} url The source URL
   * @param {object} metadata The metadata to save
   * @returns {Promise<string>} Path to the saved file
   */
  async saveMetadataFile(url, metadata = {}) {
    try {
      // Generate a filename from the URL
      const pathInfo = this.createPathFromUrl(url, {
        extension: '.json',
        createSubdirectories: true
      });
      
      // Create a new path in the metadata directory
      const metadataPath = path.join(
        this.metadataDir,
        path.relative(this.contentDir, pathInfo.directory),
        `${pathInfo.filename}.json`
      );
      
      // Ensure parent directory exists
      fs.ensureDirSync(path.dirname(metadataPath));
      
      // Write the file
      await fs.writeJson(metadataPath, {
        url,
        path: pathInfo.relativePath.replace('.json', '.md'),
        ...metadata,
        saved_at: new Date().toISOString()
      }, { spaces: 2 });
      
      console.log(`Saved metadata to ${metadataPath}`);
      
      return metadataPath;
    } catch (error) {
      console.error(`Error saving metadata for ${url}:`, error.message);
      throw error;
    }
  }

  /**
   * Creates an index file listing all content
   * 
   * @returns {Promise<string>} Path to the index file
   */
  async createIndexFile() {
    try {
      if (this.fileMap.size === 0) {
        console.warn('No files to index');
        return null;
      }
      
      // Create a sorted array of files
      const files = Array.from(this.fileMap.values())
        .sort((a, b) => {
          // Sort by date if available
          if (a.date && b.date) {
            return new Date(b.date) - new Date(a.date);
          }
          // Otherwise, sort by title
          return a.title.localeCompare(b.title);
        });
      
      // Generate markdown
      let markdown = `# Content Index\n\n`;
      markdown += `*Generated on ${new Date().toISOString()}*\n\n`;
      markdown += `This index contains ${files.length} pages.\n\n`;
      
      // Add table of contents
      markdown += `## Table of Contents\n\n`;
      
      // Group by first letter of title
      const groupedByLetter = {};
      
      for (const file of files) {
        const firstLetter = (file.title.charAt(0) || '0').toUpperCase();
        if (!groupedByLetter[firstLetter]) {
          groupedByLetter[firstLetter] = [];
        }
        groupedByLetter[firstLetter].push(file);
      }
      
      // Create TOC links
      for (const letter of Object.keys(groupedByLetter).sort()) {
        markdown += `- [${letter}](#${letter.toLowerCase()})\n`;
      }
      
      markdown += '\n';
      
      // List all files by letter
      for (const letter of Object.keys(groupedByLetter).sort()) {
        markdown += `## ${letter}\n\n`;
        
        for (const file of groupedByLetter[letter]) {
          const relativePath = file.path;
          const date = file.date ? ` (${new Date(file.date).toLocaleDateString()})` : '';
          markdown += `- [${file.title}](${relativePath})${date}\n`;
        }
        
        markdown += '\n';
      }
      
      // Save the index file
      await fs.writeFile(this.indexPath, markdown);
      console.log(`Created index file at ${this.indexPath}`);
      
      return this.indexPath;
    } catch (error) {
      console.error('Error creating index file:', error.message);
      throw error;
    }
  }

  /**
   * Creates a sitemap JSON file
   * 
   * @returns {Promise<string>} Path to the sitemap file
   */
  async createSitemap() {
    try {
      if (this.fileMap.size === 0) {
        console.warn('No files to include in sitemap');
        return null;
      }
      
      // Create a sitemap object
      const sitemap = {
        generated_at: new Date().toISOString(),
        total_pages: this.fileMap.size,
        pages: Array.from(this.fileMap.values()).map(file => ({
          url: file.url,
          path: file.path,
          title: file.title,
          date: file.date
        }))
      };
      
      // Save the sitemap
      await fs.writeJson(this.sitemapPath, sitemap, { spaces: 2 });
      console.log(`Created sitemap at ${this.sitemapPath}`);
      
      return this.sitemapPath;
    } catch (error) {
      console.error('Error creating sitemap:', error.message);
      throw error;
    }
  }

  /**
   * Creates a relationship graph between content
   * 
   * @returns {Promise<string>} Path to the relationship graph file
   */
  async createRelationshipGraph() {
    try {
      if (this.fileMap.size === 0) {
        console.warn('No files to include in relationship graph');
        return null;
      }
      
      const graphPath = path.join(this.outputDir, 'relationships.json');
      
      // Create a graph of relationships
      const graph = {
        nodes: [],
        edges: []
      };
      
      // Add all nodes
      for (const [url, file] of this.fileMap.entries()) {
        graph.nodes.push({
          id: url,
          label: file.title,
          path: file.path
        });
      }
      
      // Find relationships based on content
      // This would require analyzing the content for links or other relationships
      // For now, we'll just create a simple placeholder
      
      // Save the graph
      await fs.writeJson(graphPath, graph, { spaces: 2 });
      console.log(`Created relationship graph at ${graphPath}`);
      
      return graphPath;
    } catch (error) {
      console.error('Error creating relationship graph:', error.message);
      throw error;
    }
  }
}

module.exports = OutputManager; 