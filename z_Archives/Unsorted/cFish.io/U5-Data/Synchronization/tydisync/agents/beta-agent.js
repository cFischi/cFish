/**
 * tYDiSync~ - Beta Agent
 * 
 * The Beta Agent handles content transformation between Markdown and JSON formats.
 * It is responsible for the actual conversion process in both directions,
 * ensuring data integrity and format correctness.
 * 
 * Part of the tY FischEYe ecosystem connecting with the "Dreamflo ~" philosophy
 * 
 * @version 1.2.0
 */

const fs = require('fs');
const path = require('path');
const EventEmitter = require('events');
const jsonValidator = require('./json-validator');

class BetaAgent extends EventEmitter {
  constructor(config) {
    super();
    this.config = config;
    this.validationThreshold = config.validationThreshold || 0.9; // 90% content retention required
  }

  /**
   * Initialize the content transformer
   */
  initialize() {
    console.log('🔄 Beta Agent: Initializing content transformer');
    console.log('✅ Beta Agent: Content transformer initialized');
    return this;
  }

  /**
   * Transform Markdown content to JSON format
   * @param {Object} fileInfo Information about the file to transform
   * @returns {Promise<Object>} The transformation result
   */
  async markdownToJson(fileInfo) {
    console.log(`🔄 Beta Agent: Converting ${fileInfo.path} from Markdown to JSON`);
    
    try {
      // Read the Markdown content
      const mdContent = await fs.promises.readFile(fileInfo.path, 'utf8');
      
      // Transform to JSON structure
      const jsonData = this.parseMarkdownToJsonStructure(mdContent, fileInfo.path);
      
      // Validate the transformation
      const isValid = this.validateTransformation(mdContent, jsonData, 'md-to-json');
      if (!isValid) {
        console.error(`❌ Beta Agent: Invalid transformation for ${fileInfo.path}, aborting`);
        this.emit('transformation-failed', {
          source: fileInfo.path,
          reason: 'validation-failed',
          direction: 'md-to-json'
        });
        return { success: false, reason: 'validation-failed' };
      }
      
      // Determine target JSON path
      const jsonPath = this.getCorrespondingJsonPath(fileInfo.path);
      
      // Ensure directory exists
      await this.ensureDirectoryExists(path.dirname(jsonPath));
      
      // Write JSON content
      await fs.promises.writeFile(
        jsonPath,
        JSON.stringify(jsonData, null, 2),
        'utf8'
      );
      
      console.log(`✅ Beta Agent: Successfully converted ${fileInfo.path} to JSON`);
      
      this.emit('transformation-complete', {
        source: fileInfo.path,
        target: jsonPath,
        direction: 'md-to-json'
      });
      
      return {
        success: true,
        sourcePath: fileInfo.path,
        targetPath: jsonPath
      };
      
    } catch (error) {
      console.error(`❌ Beta Agent: Error transforming ${fileInfo.path}: ${error.message}`);
      this.emit('transformation-failed', {
        source: fileInfo.path,
        reason: error.message,
        direction: 'md-to-json'
      });
      return { success: false, reason: error.message };
    }
  }

  /**
   * Transform JSON content to Markdown format
   * @param {Object} fileInfo Information about the file to transform
   * @returns {Promise<Object>} The transformation result
   */
  async jsonToMarkdown(fileInfo) {
    console.log(`🔄 Beta Agent: Converting ${fileInfo.path} from JSON to Markdown`);
    
    try {
      // Read the JSON content
      const jsonContent = await fs.promises.readFile(fileInfo.path, 'utf8');
      const jsonData = JSON.parse(jsonContent);
      
      // Determine target Markdown path
      const mdPath = this.getCorrespondingMarkdownPath(fileInfo.path);
      
      // Check if Markdown file exists - if so, we'll need to merge
      let existingMdContent = '';
      let shouldMerge = false;
      
      try {
        if (fs.existsSync(mdPath)) {
          existingMdContent = await fs.promises.readFile(mdPath, 'utf8');
          shouldMerge = true;
          console.log(`ℹ️ Beta Agent: Existing Markdown file found at ${mdPath}, will perform intelligent merge`);
        }
      } catch (readError) {
        console.warn(`⚠️ Beta Agent: Error reading existing Markdown file: ${readError.message}`);
        // Continue with transformation without merging
      }
      
      // Transform to Markdown
      let mdContent;
      
      if (shouldMerge) {
        mdContent = this.intelligentMerge(existingMdContent, jsonData, mdPath);
      } else {
        mdContent = this.convertJsonToMarkdown(jsonData);
      }
      
      // Validate the transformation
      const isValid = this.validateTransformation(jsonData, mdContent, 'json-to-md');
      if (!isValid) {
        console.error(`❌ Beta Agent: Invalid transformation for ${fileInfo.path}, aborting`);
        this.emit('transformation-failed', {
          source: fileInfo.path,
          reason: 'validation-failed',
          direction: 'json-to-md'
        });
        return { success: false, reason: 'validation-failed' };
      }
      
      // Ensure directory exists
      await this.ensureDirectoryExists(path.dirname(mdPath));
      
      // Write Markdown content
      await fs.promises.writeFile(mdPath, mdContent, 'utf8');
      
      console.log(`✅ Beta Agent: Successfully converted ${fileInfo.path} to Markdown`);
      
      this.emit('transformation-complete', {
        source: fileInfo.path,
        target: mdPath,
        direction: 'json-to-md'
      });
      
      return {
        success: true,
        sourcePath: fileInfo.path,
        targetPath: mdPath,
        wasMerged: shouldMerge
      };
      
    } catch (error) {
      console.error(`❌ Beta Agent: Error transforming ${fileInfo.path}: ${error.message}`);
      this.emit('transformation-failed', {
        source: fileInfo.path,
        reason: error.message,
        direction: 'json-to-md'
      });
      return { success: false, reason: error.message };
    }
  }

  /**
   * Parse Markdown content into a structured JSON object
   * @param {string} mdContent The Markdown content
   * @param {string} filePath The path to the Markdown file
   * @returns {Object} The structured JSON object
   */
  parseMarkdownToJsonStructure(mdContent, filePath) {
    // Extract sections and metadata from Markdown content
    const lines = mdContent.split('\n');
    const result = {
      metadata: {},
      sections: [],
      filePath: filePath,
      lastUpdated: new Date().toISOString()
    };
    
    let currentSection = null;
    let inMetadataBlock = false;
    let inCodeBlock = false;
    
    for (let i = 0; i < lines.length; i++) {
      const line = lines[i];
      
      // Handle code blocks
      if (line.startsWith('```')) {
        inCodeBlock = !inCodeBlock;
        
        if (currentSection) {
          currentSection.content.push(line);
        } else {
          // Code block outside of a section, create a default section
          currentSection = {
            level: 0,
            title: 'Content',
            content: [line]
          };
          result.sections.push(currentSection);
        }
        continue;
      }
      
      // Skip processing inside code blocks
      if (inCodeBlock) {
        if (currentSection) {
          currentSection.content.push(line);
        }
        continue;
      }
      
      // Check for metadata block
      if (line === '---' && (i === 0 || result.sections.length === 0)) {
        inMetadataBlock = !inMetadataBlock;
        continue;
      }
      
      if (inMetadataBlock) {
        // Parse metadata line (key: value)
        const match = line.match(/^(.+?)\s*:\s*(.+)$/);
        if (match) {
          result.metadata[match[1].trim()] = match[2].trim();
        }
        continue;
      }
      
      // Check for headings (# Header)
      const headingMatch = line.match(/^(#{1,6})\s+(.+)$/);
      if (headingMatch) {
        const level = headingMatch[1].length;
        const title = headingMatch[2].trim();
        
        currentSection = {
          level: level,
          title: title,
          content: []
        };
        
        result.sections.push(currentSection);
        continue;
      }
      
      // Add content to current section
      if (currentSection) {
        currentSection.content.push(line);
      } else if (line.trim() !== '') {
        // Content outside of a section, create a default section
        currentSection = {
          level: 0,
          title: 'Content',
          content: [line]
        };
        result.sections.push(currentSection);
      }
    }
    
    // Process signature line if present
    const signatureLine = this.extractSignatureLine(mdContent);
    if (signatureLine) {
      result.signature = signatureLine;
    }
    
    return result;
  }

  /**
   * Convert JSON structure back to Markdown
   * @param {Object} jsonData The structured JSON object
   * @returns {string} The Markdown content
   */
  convertJsonToMarkdown(jsonData) {
    let mdContent = '';
    
    // Add metadata block if present
    if (Object.keys(jsonData.metadata || {}).length > 0) {
      mdContent += '---\n';
      for (const [key, value] of Object.entries(jsonData.metadata)) {
        mdContent += `${key}: ${value}\n`;
      }
      mdContent += '---\n\n';
    }
    
    // Process sections
    if (jsonData.sections && jsonData.sections.length > 0) {
      for (const section of jsonData.sections) {
        // Add section heading if level > 0
        if (section.level > 0) {
          const heading = '#'.repeat(section.level);
          mdContent += `${heading} ${section.title}\n\n`;
        }
        
        // Add section content
        if (section.content && section.content.length > 0) {
          mdContent += section.content.join('\n') + '\n\n';
        }
      }
    }
    
    // Add signature line if present
    if (jsonData.signature) {
      mdContent += jsonData.signature + '\n';
    }
    
    return mdContent.trim();
  }

  /**
   * Perform intelligent merge between existing Markdown and JSON data
   * @param {string} existingMd The existing Markdown content
   * @param {Object} jsonData The JSON data to merge
   * @param {string} mdPath The path to the Markdown file
   * @returns {string} The merged Markdown content
   */
  intelligentMerge(existingMd, jsonData, mdPath) {
    console.log(`🔄 Beta Agent: Performing intelligent merge for ${mdPath}`);
    
    // Parse the existing Markdown
    const existingStructure = this.parseMarkdownToJsonStructure(existingMd, mdPath);
    
    // Create a map of existing sections by title for easy lookup
    const existingSectionMap = new Map();
    for (const section of existingStructure.sections) {
      existingSectionMap.set(section.title, section);
    }
    
    // Extract signature line from existing content
    const existingSignature = this.extractSignatureLine(existingMd);
    
    // Create a new merged structure
    const mergedStructure = {
      metadata: { ...existingStructure.metadata, ...jsonData.metadata },
      sections: [],
      filePath: mdPath,
      lastUpdated: new Date().toISOString()
    };
    
    // If original had a signature, preserve it
    if (existingSignature) {
      mergedStructure.signature = existingSignature;
    } else if (jsonData.signature) {
      mergedStructure.signature = jsonData.signature;
    }
    
    // Get all section titles from both sources
    const allSectionTitles = new Set([
      ...Array.from(existingSectionMap.keys()),
      ...(jsonData.sections || []).map(s => s.title)
    ]);
    
    // Create a map of JSON sections by title
    const jsonSectionMap = new Map();
    for (const section of (jsonData.sections || [])) {
      jsonSectionMap.set(section.title, section);
    }
    
    // Special handling for memory.md - we want to be extra cautious
    const isMemoryFile = mdPath.toLowerCase().includes('memory.md');
    
    // Track sections we've processed to preserve order
    const processedSections = new Set();
    
    // First, add sections in the order they appear in the original markdown
    for (const section of existingStructure.sections) {
      processedSections.add(section.title);
      
      if (jsonSectionMap.has(section.title)) {
        // Section exists in both - need to merge
        const jsonSection = jsonSectionMap.get(section.title);
        
        // For memory.md, always preserve existing content
        if (isMemoryFile) {
          mergedStructure.sections.push(section);
        } else {
          // For other files, use the newer content based on modification time
          // We default to existing content if timestamps are missing or equal
          const useJsonContent = jsonData.lastUpdated && 
            (!existingStructure.lastUpdated || 
             new Date(jsonData.lastUpdated) > new Date(existingStructure.lastUpdated));
          
          mergedStructure.sections.push(useJsonContent ? jsonSection : section);
        }
      } else {
        // Section only in original - preserve it
        mergedStructure.sections.push(section);
      }
    }
    
    // Then add any new sections from JSON that weren't in the original
    for (const section of (jsonData.sections || [])) {
      if (!processedSections.has(section.title)) {
        mergedStructure.sections.push(section);
      }
    }
    
    // Convert the merged structure back to Markdown
    return this.convertJsonToMarkdown(mergedStructure);
  }

  /**
   * Extract signature line from Markdown content
   * @param {string} mdContent The Markdown content
   * @returns {string|null} The signature line or null if not found
   */
  extractSignatureLine(mdContent) {
    const lines = mdContent.split('\n');
    
    // Look for signature line (starts with _Updated)
    for (let i = lines.length - 1; i >= 0; i--) {
      const line = lines[i].trim();
      if (line.startsWith('_Updated') && line.endsWith('_')) {
        return line;
      }
    }
    
    return null;
  }

  /**
   * Validate that the transformation preserves content integrity
   * @param {string|Object} source The source content
   * @param {string|Object} target The target content
   * @param {string} direction The direction of transformation
   * @returns {boolean} True if the transformation is valid
   */
  validateTransformation(source, target, direction) {
    if (direction === 'md-to-json') {
      // For MD to JSON, check that all sections are preserved
      const sourceLines = source.split('\n');
      const headings = sourceLines.filter(line => /^#{1,6}\s+.+$/.test(line));
      
      // Check that all headings are preserved in the JSON
      const allHeadingsPreserved = headings.every(heading => {
        const match = heading.match(/^(#{1,6})\s+(.+)$/);
        if (match) {
          const title = match[2].trim();
          return target.sections.some(section => section.title === title);
        }
        return false;
      });
      
      // Check content size - JSON should not be significantly smaller
      const jsonString = JSON.stringify(target);
      const contentPreservation = jsonString.length / source.length;
      
      console.log(`ℹ️ Beta Agent: Content preservation ratio: ${contentPreservation.toFixed(2)}`);
      
      return allHeadingsPreserved && contentPreservation >= this.validationThreshold;
    } else if (direction === 'json-to-md') {
      // For JSON to MD, ensure all sections are preserved
      const sourceJSON = typeof source === 'string' ? JSON.parse(source) : source;
      const targetLines = typeof target === 'string' ? target.split('\n') : [];
      
      // Check that all sections from JSON appear in the Markdown
      const allSectionsPreserved = (sourceJSON.sections || []).every(section => {
        if (section.level > 0) {
          const headingPattern = new RegExp(`^#{${section.level}}\\s+${section.title.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}$`);
          return targetLines.some(line => headingPattern.test(line));
        }
        return true; // Non-heading sections are harder to verify
      });
      
      // Check content size - MD should not be significantly smaller than expected
      const expectedLength = this.estimateMarkdownSize(sourceJSON);
      const actualLength = typeof target === 'string' ? target.length : 0;
      const contentPreservation = actualLength / expectedLength;
      
      console.log(`ℹ️ Beta Agent: Content preservation ratio: ${contentPreservation.toFixed(2)}`);
      
      return allSectionsPreserved && contentPreservation >= this.validationThreshold;
    }
    
    return false;
  }

  /**
   * Estimate the expected size of Markdown content from JSON structure
   * @param {Object} jsonData The JSON data
   * @returns {number} Estimated Markdown size in characters
   */
  estimateMarkdownSize(jsonData) {
    let estimatedSize = 0;
    
    // Add metadata size
    if (jsonData.metadata) {
      estimatedSize += Object.keys(jsonData.metadata).length * 20; // Average line length estimate
    }
    
    // Add section sizes
    if (jsonData.sections) {
      for (const section of jsonData.sections) {
        // Add heading size
        if (section.level > 0) {
          estimatedSize += section.level + section.title.length + 2; // # Title format
        }
        
        // Add content size
        if (section.content) {
          if (Array.isArray(section.content)) {
            for (const line of section.content) {
              estimatedSize += line.length + 1; // +1 for newline
            }
          } else if (typeof section.content === 'string') {
            estimatedSize += section.content.length;
          }
        }
      }
    }
    
    // Add signature size if present
    if (jsonData.signature) {
      estimatedSize += jsonData.signature.length;
    }
    
    return estimatedSize;
  }

  /**
   * Get the corresponding JSON path for a Markdown file
   * @param {string} mdPath The path to the Markdown file
   * @returns {string} The path to the corresponding JSON file
   */
  getCorrespondingJsonPath(mdPath) {
    const parsedPath = path.parse(mdPath);
    const dirName = parsedPath.dir;
    const baseName = parsedPath.name;
    
    // Special handling for root directory files
    if (dirName === '' || dirName === '.') {
      console.log(`🔍 Beta Agent: Processing root directory file: ${mdPath}`);
      // For root directory files, use the root json directory
      return path.join(process.cwd(), 'json', `${baseName}.json`);
    }
    
    // Check if the path matches configured directories
    for (const watchDir of this.config.watchDirs || []) {
      const mdDir = path.resolve(process.cwd(), watchDir.md);
      
      // Check if directory is a root directory pattern
      if (watchDir.md === './' && (dirName === '' || dirName === '.')) {
        return path.join(process.cwd(), watchDir.json, `${baseName}.json`);
      }
      
      if (dirName.startsWith(mdDir)) {
        // This file is in a configured directory
        const relativePath = path.relative(mdDir, dirName);
        return path.join(
          process.cwd(),
          watchDir.json,
          relativePath,
          `${baseName}.json`
        );
      }
    }
    
    // Default: for files not in configured directories, use root json directory
    return path.join(process.cwd(), 'json', `${baseName}.json`);
  }

  /**
   * Get the corresponding Markdown path for a JSON file
   * @param {string} jsonPath The path to the JSON file
   * @returns {string} The path to the corresponding Markdown file
   */
  getCorrespondingMarkdownPath(jsonPath) {
    const parsedPath = path.parse(jsonPath);
    const dirName = parsedPath.dir;
    const baseName = parsedPath.name;
    
    // Improved handling for root JSON directory files
    const rootJsonDir = path.join(process.cwd(), 'json');
    const normalizedJsonPath = path.normalize(jsonPath);
    const normalizedRootJsonDir = path.normalize(rootJsonDir);
    
    if (dirName === normalizedRootJsonDir || 
        dirName === 'json' || 
        normalizedJsonPath.startsWith(normalizedRootJsonDir + path.sep)) {
      // This is a root-level JSON file
      console.log(`🔍 Beta Agent: Processing root json directory file: ${jsonPath}`);
      return path.join(process.cwd(), `${baseName}.md`);
    }
    
    // First check if this is a JSON file in a designated JSON directory
    for (const watchDir of this.config.watchDirs || []) {
      const jsonDir = path.resolve(process.cwd(), watchDir.json);
      if (dirName.startsWith(jsonDir)) {
        // This file is in a configured JSON directory
        const relativePath = path.relative(jsonDir, dirName);
        return path.join(
          process.cwd(),
          watchDir.md,
          relativePath,
          `${baseName}.md`
        );
      }
    }
    
    // Default: JSON files in any other location, use the same directory
    return path.join(dirName, `${baseName}.md`);
  }

  /**
   * Ensure a directory exists, creating it if necessary
   * @param {string} dirPath The directory path
   * @returns {Promise<void>}
   */
  async ensureDirectoryExists(dirPath) {
    try {
      await fs.promises.mkdir(dirPath, { recursive: true });
    } catch (error) {
      if (error.code !== 'EEXIST') {
        throw error;
      }
    }
  }

  // Enhance the transformJSONtoMarkdown function with robust error handling
  async transformJSONtoMarkdown(jsonFilePath, markdownFilePath) {
    this.log(`🔄 Beta Agent: Converting ${jsonFilePath} from JSON to Markdown`);
    
    try {
      // First, validate the JSON file
      const validationResult = jsonValidator.validateJSON(jsonFilePath);
      
      if (!validationResult.valid) {
        this.log(`⚠️ Beta Agent: Invalid JSON detected in ${jsonFilePath}: ${validationResult.error}`);
        
        // Attempt to fix the JSON file
        this.log(`🔄 Beta Agent: Attempting to fix JSON file: ${jsonFilePath}`);
        const fixResult = jsonValidator.attemptFix(validationResult);
        
        if (fixResult.fixed) {
          this.log(`✅ Beta Agent: Successfully fixed JSON file: ${jsonFilePath}`);
          // Save the fixed content back to the file
          fs.writeFileSync(jsonFilePath, fixResult.fixedContent);
          // Continue with transformation using the fixed content
          const jsonData = JSON.parse(fixResult.fixedContent);
          return this.processJSONData(jsonData, jsonFilePath, markdownFilePath);
        } else {
          this.log(`❌ Beta Agent: Error transforming ${jsonFilePath}: ${validationResult.error}`);
          this.emit('error', `Failed to transform JSON to Markdown: ${validationResult.error}`, {
            source: jsonFilePath,
            target: markdownFilePath,
            operation: 'json-to-md'
          });
          return false;
        }
      }

      // Read and parse the JSON file
      const jsonData = JSON.parse(fs.readFileSync(jsonFilePath, 'utf8'));
      return this.processJSONData(jsonData, jsonFilePath, markdownFilePath);
    } catch (error) {
      this.log(`❌ Beta Agent: Error transforming ${jsonFilePath}: ${error.message}`);
      this.emit('error', `Failed to transform JSON to Markdown: ${error.message}`, {
        source: jsonFilePath,
        target: markdownFilePath,
        operation: 'json-to-md'
      });
      return false;
    }
  }

  // Helper method to process JSON data (extracted from the original transformation method)
  async processJSONData(jsonData, jsonFilePath, markdownFilePath) {
    try {
      // ... existing transformation code ...
      
      // The rest of your JSON to Markdown transformation logic
      
      return true; // or false based on the result
    } catch (error) {
      this.log(`❌ Beta Agent: Error processing JSON data: ${error.message}`);
      this.emit('error', `Failed to process JSON data: ${error.message}`, {
        source: jsonFilePath,
        target: markdownFilePath,
        operation: 'json-to-md'
      });
      return false;
    }
  }

  // Enhance Markdown to JSON with validation
  async transformMarkdowntoJSON(markdownFilePath, jsonFilePath) {
    this.log(`🔄 Beta Agent: Converting ${markdownFilePath} from Markdown to JSON`);
    
    try {
      // ... existing transformation code ...
      
      // After generating the JSON, validate it
      const jsonOutput = JSON.stringify(jsonData, null, 2);
      
      // Validate before saving
      try {
        JSON.parse(jsonOutput); // Should parse without errors
      } catch (parseError) {
        this.log(`⚠️ Beta Agent: Generated invalid JSON: ${parseError.message}`);
        this.emit('error', `Generated invalid JSON: ${parseError.message}`, {
          source: markdownFilePath,
          target: jsonFilePath,
          operation: 'md-to-json'
        });
        return false;
      }
      
      // Save the valid JSON
      fs.writeFileSync(jsonFilePath, jsonOutput);
      // ... rest of the method ...
      
      return true;
    } catch (error) {
      // ... existing error handling ...
    }
  }
}

module.exports = BetaAgent; 