/**
 * Content Merger Module
 * 
 * Identifies and merges related content to reduce fragmentation
 * and create more comprehensive documents.
 * 
 * @package ucfish-scraper
 * @since 1.0.0
 */

const fs = require('fs-extra');
const path = require('path');
const sanitize = require('sanitize-filename');

class ContentMerger {
  constructor(options = {}) {
    this.outputDir = options.outputDir || path.join(__dirname, '../output');
    this.contentDir = options.contentDir || path.join(this.outputDir, 'content');
    this.mergedDir = options.mergedDir || path.join(this.outputDir, 'merged');
    this.similarityThreshold = options.similarityThreshold || 0.6;
    this.minHeadingLevel = options.minHeadingLevel || 1;
    
    // Ensure directories exist
    fs.ensureDirSync(this.outputDir);
    fs.ensureDirSync(this.contentDir);
    fs.ensureDirSync(this.mergedDir);
  }

  /**
   * Loads markdown files from a directory
   * 
   * @param {string} directory The directory to load from
   * @returns {Promise<Array<object>>} Array of {path, content, metadata} objects
   */
  async loadMarkdownFiles(directory) {
    const files = [];
    
    try {
      // Get all files in the directory
      const dirContents = await fs.readdir(directory, { withFileTypes: true });
      
      // Process each entry
      for (const entry of dirContents) {
        const fullPath = path.join(directory, entry.name);
        
        if (entry.isDirectory()) {
          // Recursively load files from subdirectories
          const subFiles = await this.loadMarkdownFiles(fullPath);
          files.push(...subFiles);
        } else if (entry.isFile() && entry.name.endsWith('.md')) {
          // Read the file
          const content = await fs.readFile(fullPath, 'utf8');
          
          // Extract frontmatter
          const metadata = this.extractFrontmatter(content);
          
          // Add to files array
          files.push({
            path: fullPath,
            relativePath: path.relative(this.contentDir, fullPath),
            content,
            metadata
          });
        }
      }
    } catch (error) {
      console.error(`Error loading markdown files from ${directory}:`, error.message);
    }
    
    return files;
  }

  /**
   * Extracts frontmatter from markdown content
   * 
   * @param {string} content The markdown content
   * @returns {object} Extracted metadata
   */
  extractFrontmatter(content) {
    const metadata = {};
    
    // Check if content has frontmatter
    if (!content.startsWith('---\n')) {
      return metadata;
    }
    
    try {
      // Find the end of frontmatter
      const endIndex = content.indexOf('\n---', 3);
      if (endIndex === -1) {
        return metadata;
      }
      
      // Extract frontmatter content
      const frontmatter = content.substring(4, endIndex).trim();
      
      // Parse each line
      for (const line of frontmatter.split('\n')) {
        const colonIndex = line.indexOf(':');
        if (colonIndex === -1) continue;
        
        const key = line.substring(0, colonIndex).trim();
        let value = line.substring(colonIndex + 1).trim();
        
        // Try to parse JSON values
        try {
          if (value.startsWith('"') && value.endsWith('"')) {
            value = value.substring(1, value.length - 1);
          } else if (value.startsWith('[') || value.startsWith('{')) {
            value = JSON.parse(value);
          } else if (value === 'true') {
            value = true;
          } else if (value === 'false') {
            value = false;
          } else if (!isNaN(value)) {
            value = Number(value);
          }
        } catch (e) {
          // If it fails, keep as string
        }
        
        metadata[key] = value;
      }
    } catch (error) {
      console.error('Error extracting frontmatter:', error.message);
    }
    
    return metadata;
  }

  /**
   * Removes frontmatter from markdown content
   * 
   * @param {string} content The markdown content
   * @returns {string} Content without frontmatter
   */
  removeFrontmatter(content) {
    // Check if content has frontmatter
    if (!content.startsWith('---\n')) {
      return content;
    }
    
    // Find the end of frontmatter
    const endIndex = content.indexOf('\n---', 3);
    if (endIndex === -1) {
      return content;
    }
    
    // Return content after frontmatter
    return content.substring(endIndex + 4).trim();
  }

  /**
   * Calculates similarity between two texts
   * 
   * @param {string} text1 First text
   * @param {string} text2 Second text
   * @returns {number} Similarity score between 0 and 1
   */
  calculateSimilarity(text1, text2) {
    // Simple approach: use jaccard similarity of words
    const words1 = new Set(text1.toLowerCase().split(/\W+/).filter(w => w.length > 3));
    const words2 = new Set(text2.toLowerCase().split(/\W+/).filter(w => w.length > 3));
    
    // Calculate intersection
    const intersection = new Set([...words1].filter(x => words2.has(x)));
    
    // Calculate union
    const union = new Set([...words1, ...words2]);
    
    // Return similarity score
    return intersection.size / (union.size || 1);
  }

  /**
   * Identifies related content based on similarity
   * 
   * @param {Array<object>} files Array of file objects
   * @returns {Array<Array<object>>} Clusters of related files
   */
  identifyRelatedContent(files) {
    // Initialize clusters with each file in its own cluster
    const clusters = files.map(file => [file]);
    
    // Iterate until no more merges can be performed
    let mergesMade = true;
    while (mergesMade) {
      mergesMade = false;
      
      // Check each pair of clusters
      for (let i = 0; i < clusters.length; i++) {
        if (mergesMade) break;
        
        for (let j = i + 1; j < clusters.length; j++) {
          // Calculate similarity between every file in cluster i and j
          let totalSimilarity = 0;
          let comparisonCount = 0;
          
          for (const fileI of clusters[i]) {
            for (const fileJ of clusters[j]) {
              const contentI = this.removeFrontmatter(fileI.content);
              const contentJ = this.removeFrontmatter(fileJ.content);
              const similarity = this.calculateSimilarity(contentI, contentJ);
              totalSimilarity += similarity;
              comparisonCount++;
            }
          }
          
          // Calculate average similarity
          const avgSimilarity = totalSimilarity / comparisonCount;
          
          // If average similarity is above threshold, merge clusters
          if (avgSimilarity >= this.similarityThreshold) {
            clusters[i] = [...clusters[i], ...clusters[j]];
            clusters.splice(j, 1);
            mergesMade = true;
            break;
          }
        }
      }
    }
    
    // Filter out single-file clusters
    return clusters.filter(cluster => cluster.length > 1);
  }

  /**
   * Merges content from multiple files
   * 
   * @param {Array<object>} files Array of file objects to merge
   * @returns {object} Merged content information
   */
  mergeContent(files) {
    // Sort files by date if available
    files.sort((a, b) => {
      const dateA = a.metadata.date ? new Date(a.metadata.date) : new Date(0);
      const dateB = b.metadata.date ? new Date(b.metadata.date) : new Date(0);
      return dateB - dateA; // Most recent first
    });
    
    // Use title from the most recent file
    const title = files[0].metadata.title || 'Merged Content';
    
    // Combine metadata
    const metadata = {
      title,
      date: new Date().toISOString(),
      merged_from: files.map(file => ({
        title: file.metadata.title,
        path: file.relativePath,
        date: file.metadata.date
      })),
      source_urls: files.map(file => file.metadata.source_url).filter(Boolean)
    };
    
    // Create table of contents
    let tableOfContents = '## Table of Contents\n\n';
    
    // Initialize merged content
    let mergedContent = `# ${title}\n\n`;
    
    // Add a brief description of the merged content
    mergedContent += `*This document was created by merging ${files.length} related pages.*\n\n`;
    
    // Process each file
    const sections = [];
    let section = 1;
    
    for (const file of files) {
      // Extract content without frontmatter
      const content = this.removeFrontmatter(file.content);
      
      // Create a section for this file
      const sectionTitle = file.metadata.title || `Section ${section}`;
      const sectionAnchor = sectionTitle.toLowerCase().replace(/[^\w\s-]/g, '').replace(/\s+/g, '-');
      
      // Add to table of contents
      tableOfContents += `- [${sectionTitle}](#${sectionAnchor})\n`;
      
      // Add section to merged content (adjust heading levels)
      const adjustedContent = this.adjustHeadingLevels(content, this.minHeadingLevel);
      sections.push(`## ${sectionTitle}\n\n${adjustedContent}`);
      
      section++;
    }
    
    // Insert table of contents after introduction
    mergedContent += tableOfContents + '\n\n';
    
    // Add all sections
    mergedContent += sections.join('\n\n---\n\n');
    
    return {
      title,
      metadata,
      content: mergedContent
    };
  }

  /**
   * Adjusts heading levels in markdown content
   * 
   * @param {string} content The markdown content
   * @param {number} minLevel The minimum heading level (1-6)
   * @returns {string} Content with adjusted headings
   */
  adjustHeadingLevels(content, minLevel) {
    // Ensure minLevel is between 1 and 6
    minLevel = Math.max(1, Math.min(6, minLevel));
    
    // Find all headings
    const headingRegex = /^(#{1,6}) (.+)$/gm;
    const headings = [];
    let match;
    
    while ((match = headingRegex.exec(content)) !== null) {
      headings.push({
        level: match[1].length,
        text: match[2],
        originalMatch: match[0],
        index: match.index
      });
    }
    
    // If no headings, return the original content
    if (headings.length === 0) {
      return content;
    }
    
    // Find the minimum heading level in the content
    const contentMinLevel = Math.min(...headings.map(h => h.level));
    
    // Calculate the level adjustment
    const adjustment = minLevel - contentMinLevel;
    
    // If no adjustment needed, return the original content
    if (adjustment <= 0) {
      return content;
    }
    
    // Adjust heading levels
    let adjustedContent = content;
    
    // Process headings in reverse order to avoid messing up indices
    headings.sort((a, b) => b.index - a.index);
    
    for (const heading of headings) {
      const newLevel = Math.min(6, heading.level + adjustment);
      const newHeading = '#'.repeat(newLevel) + ' ' + heading.text;
      
      adjustedContent = adjustedContent.substring(0, heading.index) +
                        newHeading +
                        adjustedContent.substring(heading.index + heading.originalMatch.length);
    }
    
    return adjustedContent;
  }

  /**
   * Merges related content across all files
   * 
   * @returns {Promise<Array<object>>} Information about merged files
   */
  async mergeRelatedContent() {
    try {
      // Load all markdown files
      console.log(`Loading markdown files from ${this.contentDir}`);
      const files = await this.loadMarkdownFiles(this.contentDir);
      console.log(`Loaded ${files.length} markdown files`);
      
      if (files.length === 0) {
        console.warn('No files to merge');
        return [];
      }
      
      // Identify related content
      console.log('Identifying related content...');
      const relatedClusters = this.identifyRelatedContent(files);
      console.log(`Found ${relatedClusters.length} clusters of related content`);
      
      // Merge each cluster
      const mergedFiles = [];
      
      for (let i = 0; i < relatedClusters.length; i++) {
        const cluster = relatedClusters[i];
        console.log(`Merging cluster ${i + 1} with ${cluster.length} files`);
        
        // Merge the content
        const merged = this.mergeContent(cluster);
        
        // Generate a filename
        const filename = sanitize(`merged_${merged.title.toLowerCase().replace(/\s+/g, '_')}`);
        const outputPath = path.join(this.mergedDir, `${filename}.md`);
        
        // Create frontmatter
        const frontmatter = ['---'];
        for (const [key, value] of Object.entries(merged.metadata)) {
          if (typeof value !== 'object') {
            frontmatter.push(`${key}: ${JSON.stringify(value)}`);
          } else {
            frontmatter.push(`${key}: ${JSON.stringify(value)}`);
          }
        }
        frontmatter.push('---\n\n');
        
        // Write the merged file
        await fs.writeFile(outputPath, frontmatter.join('\n') + merged.content);
        console.log(`Saved merged content to ${outputPath}`);
        
        // Add to mergedFiles array
        mergedFiles.push({
          path: outputPath,
          relativePath: path.relative(this.outputDir, outputPath),
          title: merged.title,
          files: cluster.map(file => file.relativePath)
        });
      }
      
      return mergedFiles;
    } catch (error) {
      console.error('Error merging related content:', error.message);
      throw error;
    }
  }
}

module.exports = ContentMerger; 