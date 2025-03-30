/**
 * Content Processor Module
 * 
 * Implements post-processing for markdown content to improve quality,
 * fix common issues, and normalize structure.
 * 
 * @package ucfish-scraper
 * @since 1.0.0
 */

const fs = require('fs-extra');
const path = require('path');
const url = require('url');

class ContentProcessor {
  constructor(options = {}) {
    this.outputDir = options.outputDir || path.join(__dirname, '../output');
    this.baseUrl = options.baseUrl || '';
    this.urlMap = options.urlMap || new Map();
  }

  /**
   * Processes markdown content
   * 
   * @param {string} markdown The raw markdown content
   * @param {object} metadata Metadata about the content
   * @returns {string} The processed markdown
   */
  processContent(markdown, metadata = {}) {
    let processedContent = markdown;
    
    // Apply processing steps in sequence
    processedContent = this.fixMarkdownSyntax(processedContent);
    processedContent = this.normalizeHeadings(processedContent);
    processedContent = this.processInternalLinks(processedContent, metadata);
    processedContent = this.removeRedundantContent(processedContent);
    processedContent = this.addTableOfContents(processedContent);
    
    return processedContent;
  }

  /**
   * Fixes common markdown syntax issues
   * 
   * @param {string} markdown The markdown content
   * @returns {string} Fixed markdown
   */
  fixMarkdownSyntax(markdown) {
    let fixedMarkdown = markdown;
    
    // Fix extra whitespace
    fixedMarkdown = fixedMarkdown.replace(/[ \t]+$/gm, '');
    
    // Fix consecutive blank lines (more than 2)
    fixedMarkdown = fixedMarkdown.replace(/\n{3,}/g, '\n\n');
    
    // Fix heading spacing (ensure blank line before headings)
    fixedMarkdown = fixedMarkdown.replace(/([^\n])\n(#{1,6} )/g, '$1\n\n$2');
    
    // Fix code block syntax (ensure blank lines around code blocks)
    fixedMarkdown = fixedMarkdown.replace(/([^\n])\n```/g, '$1\n\n```');
    fixedMarkdown = fixedMarkdown.replace(/```\n([^\n])/g, '```\n\n$1');
    
    // Fix list item spacing
    fixedMarkdown = fixedMarkdown.replace(/([^\n])\n(- |\d+\. )/g, '$1\n\n$2');
    
    // Fix inline code with spaces
    fixedMarkdown = fixedMarkdown.replace(/`([^`]+)`/g, (match, code) => {
      // Trim whitespace within inline code
      return '`' + code.trim() + '`';
    });
    
    return fixedMarkdown;
  }

  /**
   * Normalizes headings to maintain proper hierarchy
   * 
   * @param {string} markdown The markdown content
   * @returns {string} Markdown with normalized headings
   */
  normalizeHeadings(markdown) {
    // Extract all headings with their levels
    const headingRegex = /^(#{1,6}) (.+)$/gm;
    const headings = [];
    let match;
    
    while ((match = headingRegex.exec(markdown)) !== null) {
      headings.push({
        level: match[1].length,
        text: match[2],
        originalMatch: match[0],
        index: match.index
      });
    }
    
    // If no headings or just one, no need to normalize
    if (headings.length <= 1) {
      return markdown;
    }
    
    // Find the minimum heading level
    const minLevel = Math.min(...headings.map(h => h.level));
    
    // If minimum level is already 1, no need to adjust
    if (minLevel === 1) {
      return markdown;
    }
    
    // Adjust all headings by the difference
    let adjustedMarkdown = markdown;
    const levelDiff = minLevel - 1;
    
    // Sort headings in reverse order by index to avoid position shifting
    headings.sort((a, b) => b.index - a.index);
    
    for (const heading of headings) {
      const newLevel = heading.level - levelDiff;
      const newHeading = '#'.repeat(newLevel) + ' ' + heading.text;
      adjustedMarkdown = adjustedMarkdown.substring(0, heading.index) + 
                         newHeading +
                         adjustedMarkdown.substring(heading.index + heading.originalMatch.length);
    }
    
    return adjustedMarkdown;
  }

  /**
   * Processes internal links to maintain proper references
   * 
   * @param {string} markdown The markdown content
   * @param {object} metadata Metadata about the content
   * @returns {string} Markdown with processed links
   */
  processInternalLinks(markdown, metadata = {}) {
    // Skip if no URL map or base URL
    if (!this.urlMap.size || !this.baseUrl) {
      return markdown;
    }
    
    const currentUrl = metadata.url || '';
    
    // Process links
    return markdown.replace(/\[([^\]]+)\]\(([^)]+)\)/g, (match, text, link) => {
      try {
        // Skip if it's an anchor link
        if (link.startsWith('#')) {
          return match;
        }
        
        // Skip if it's an external link
        if (link.startsWith('http') && !link.includes(this.baseUrl)) {
          return match;
        }
        
        // Resolve relative URLs
        const absoluteUrl = new URL(link, currentUrl).href;
        
        // Check if we have this URL in our map
        if (this.urlMap.has(absoluteUrl)) {
          const mdFilePath = this.urlMap.get(absoluteUrl);
          // Create relative path from current file to target file
          const relativePath = path.relative(
            path.dirname(path.join(this.outputDir, metadata.outputPath || '')),
            path.join(this.outputDir, mdFilePath)
          ).replace(/\\/g, '/');
          
          return `[${text}](${relativePath})`;
        }
      } catch (error) {
        console.warn(`Error processing link: ${link}`, error.message);
      }
      
      // Return original if we couldn't process it
      return match;
    });
  }

  /**
   * Removes duplicate or redundant content
   * 
   * @param {string} markdown The markdown content
   * @returns {string} Cleaned markdown
   */
  removeRedundantContent(markdown) {
    let cleanedMarkdown = markdown;
    
    // Remove duplicate headings (same text in sequence)
    const headingRegex = /^(#{1,6}) (.+)$/gm;
    let lastHeading = null;
    
    cleanedMarkdown = cleanedMarkdown.replace(headingRegex, (match, level, text) => {
      if (text.trim() === lastHeading) {
        return ''; // Remove the duplicate
      }
      lastHeading = text.trim();
      return match;
    });
    
    // Remove empty sections (heading followed immediately by another heading)
    cleanedMarkdown = cleanedMarkdown.replace(/^(#{1,6} .+)\n+(?=#{1,6} .+)/gm, '$1\n\n');
    
    // Remove common redundant phrases
    const redundantPhrases = [
      'Click here to',
      'Click here for',
      'Click to',
      'Learn more about',
      'Read more about',
      'Follow this link'
    ];
    
    for (const phrase of redundantPhrases) {
      const regex = new RegExp(`\\[${phrase} (.+?)\\]`, 'gi');
      cleanedMarkdown = cleanedMarkdown.replace(regex, '[$1]');
    }
    
    return cleanedMarkdown;
  }

  /**
   * Adds a table of contents to the markdown
   * 
   * @param {string} markdown The markdown content
   * @returns {string} Markdown with table of contents
   */
  addTableOfContents(markdown) {
    // Extract all headings
    const headingRegex = /^(#{1,4}) (.+)$/gm;
    const headings = [];
    let match;
    
    while ((match = headingRegex.exec(markdown)) !== null) {
      const level = match[1].length;
      const text = match[2].trim();
      
      // Skip if it's a h1 title (likely the page title)
      if (level === 1 && headings.length === 0) {
        continue;
      }
      
      // Create an anchor link from the heading text
      const anchor = text.toLowerCase()
        .replace(/[^\w\s-]/g, '')
        .replace(/\s+/g, '-');
      
      headings.push({
        level,
        text,
        anchor
      });
    }
    
    // If fewer than 3 headings, don't add a TOC
    if (headings.length < 3) {
      return markdown;
    }
    
    // Generate TOC
    let toc = '## Table of Contents\n\n';
    
    for (const heading of headings) {
      // Create indentation based on heading level (h2 = no indent, h3 = 2 spaces, etc.)
      const indent = '  '.repeat(heading.level - 2);
      toc += `${indent}- [${heading.text}](#${heading.anchor})\n`;
    }
    
    // Find the position to insert the TOC (after the first h1/h2 heading)
    const firstHeadingMatch = /^#{1,2} .+$/m.exec(markdown);
    
    if (firstHeadingMatch) {
      const insertPosition = firstHeadingMatch.index + firstHeadingMatch[0].length;
      
      // Insert TOC after the first heading
      return markdown.slice(0, insertPosition) + '\n\n' + toc + '\n' + markdown.slice(insertPosition);
    }
    
    // If no heading found, add TOC to the beginning
    return toc + '\n\n' + markdown;
  }

  /**
   * Processes a markdown file
   * 
   * @param {string} filePath Path to the markdown file
   * @param {object} metadata Metadata about the content
   * @returns {Promise<string>} The path to the processed file
   */
  async processFile(filePath, metadata = {}) {
    try {
      // Read the markdown file
      const markdown = await fs.readFile(filePath, 'utf8');
      
      // Process the content
      const processedContent = this.processContent(markdown, {
        ...metadata,
        outputPath: path.relative(this.outputDir, filePath)
      });
      
      // Write the processed content back to the file
      await fs.writeFile(filePath, processedContent);
      
      console.log(`Processed markdown file: ${filePath}`);
      
      return filePath;
    } catch (error) {
      console.error(`Error processing markdown file: ${filePath}`, error.message);
      throw error;
    }
  }
}

module.exports = ContentProcessor; 