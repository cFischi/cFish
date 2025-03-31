/**
 * Content Verification Module
 * 
 * Validates the quality of extracted content and markdown conversion
 * to ensure proper formatting and completeness.
 * 
 * @package ucfish-scraper
 * @since 1.0.0
 */

const fs = require('fs-extra');
const path = require('path');
const cheerio = require('cheerio');
const natural = require('natural');
const { JSDOM } = require('jsdom');
const { TfIdf } = natural;

class ContentVerifier {
  constructor(options = {}) {
    this.outputDir = options.outputDir || path.join(__dirname, '../output');
    this.logDir = options.logDir || path.join(__dirname, '../logs');
    this.verificationReportPath = path.join(this.logDir, 'verification_report.json');
    
    this.minContentLength = options.minContentLength || 200; // Minimum characters for valid content
    this.maxErrorRatio = options.maxErrorRatio || 0.1; // Maximum ratio of error patterns to content length
    this.minImageTextRatio = options.minImageTextRatio || 0.01; // Minimum ratio of images to text
    this.minHeadingCount = options.minHeadingCount || 1; // Minimum number of headings
    this.minParagraphCount = options.minParagraphCount || 3; // Minimum number of paragraphs
    this.minReadabilityScore = options.minReadabilityScore || 30; // Minimum Flesch reading ease score
    this.errorPatterns = options.errorPatterns || [
      '404', 'not found', 'error', 'sorry', 'unavailable',
      'page cannot be found', 'no longer available'
    ];
    this.boilerplateThreshold = options.boilerplateThreshold || 0.6; // Threshold for duplicate content detection
    this.meaningfulContentThreshold = options.meaningfulContentThreshold || 0.4; // Threshold for meaningful content
    this.topicCoherenceThreshold = options.topicCoherenceThreshold || 0.3; // Threshold for topic coherence
    
    // New metrics
    this.codeQualityMetrics = options.codeQualityMetrics !== false;
    this.sentimentAnalysis = options.sentimentAnalysis !== false;
    this.brokenLinksCheck = options.brokenLinksCheck !== false;
    this.spellingCheck = options.spellingCheck !== false;
    this.languageDetection = options.languageDetection !== false;
    this.linkDensityThreshold = options.linkDensityThreshold || 0.5; // Maximum ratio of links to content
    this.maxConsecutiveEmptyLines = options.maxConsecutiveEmptyLines || 3;
    this.adPatterns = options.adPatterns || [
      'sponsored', 'advertisement', 'promoted', 'buy now',
      'discount', 'offer', 'limited time', 'click here'
    ];
    
    // Initialize natural language processing tools
    this.tfidf = new TfIdf();
    this.tokenizer = new natural.WordTokenizer();
    this.stemmer = natural.PorterStemmer;
    
    // Initialize spelling dictionary if enabled
    if (this.spellingCheck) {
      this.spellcheck = new natural.Spellcheck();
    }
    
    // Ensure directories exist
    fs.ensureDirSync(this.logDir);
  }

  /**
   * Verify markdown content against original HTML content
   * 
   * @param {string} markdown The markdown content
   * @param {string} html The original HTML content
   * @param {object} metadata Additional metadata
   * @returns {object} Verification results
   */
  verifyContent(markdown, html, metadata = {}) {
    const results = {
      url: metadata.url || '',
      contentLengthRatio: 0,
      headingCount: 0,
      linkCount: 0,
      imageCount: 0,
      tableCount: 0,
      codeBlockCount: 0,
      listCount: 0,
      errors: [],
      warnings: [],
      status: 'unknown'
    };
    
    try {
      // Create DOM from HTML
      const dom = new JSDOM(html);
      const document = dom.window.document;
      
      // Compare content length
      const htmlTextLength = document.body.textContent.trim().length;
      const markdownTextLength = markdown.replace(/[#*`\-_|]/g, '').trim().length;
      
      results.contentLengthRatio = markdownTextLength / (htmlTextLength || 1);
      
      // Check if content length is reasonable
      if (results.contentLengthRatio < 0.7) {
        results.warnings.push(`Content length ratio is low: ${results.contentLengthRatio.toFixed(2)}`);
      } else if (results.contentLengthRatio > 1.5) {
        results.warnings.push(`Content length ratio is high: ${results.contentLengthRatio.toFixed(2)}`);
      }
      
      // Count elements in HTML
      const htmlHeadings = document.querySelectorAll('h1, h2, h3, h4, h5, h6').length;
      const htmlLinks = document.querySelectorAll('a[href]').length;
      const htmlImages = document.querySelectorAll('img').length;
      const htmlTables = document.querySelectorAll('table').length;
      const htmlCodeBlocks = document.querySelectorAll('pre, code').length;
      const htmlLists = document.querySelectorAll('ul, ol').length;
      
      // Count elements in markdown
      results.headingCount = (markdown.match(/^#{1,6} .+$/gm) || []).length;
      results.linkCount = (markdown.match(/\[.+?\]\(.+?\)/g) || []).length;
      results.imageCount = (markdown.match(/!\[.+?\]\(.+?\)/g) || []).length;
      results.tableCount = (markdown.match(/\|.*\|/g) || []).length > 0 ? 
                           Math.floor((markdown.match(/\|.*\|/g) || []).length / 3) : 0;
      results.codeBlockCount = (markdown.match(/```[\s\S]*?```/g) || []).length;
      results.listCount = (markdown.match(/^(\s*[*\-+]|\s*\d+\.) .+$/gm) || []).length;
      
      // Compare element counts
      if (htmlHeadings > 0 && results.headingCount === 0) {
        results.errors.push('Missing headings in markdown');
      }
      
      if (htmlLinks > 0 && results.linkCount === 0) {
        results.warnings.push('Missing links in markdown');
      }
      
      if (htmlImages > 0 && results.imageCount === 0) {
        results.warnings.push('Missing images in markdown');
      }
      
      if (htmlTables > 0 && results.tableCount === 0) {
        results.warnings.push('Missing tables in markdown');
      }
      
      // Check for broken markdown syntax
      const brokenSyntaxPatterns = [
        { regex: /\[([^\]]*?\n[^\]]*?)\]/g, message: 'Line break within link text' },
        { regex: /\]\([^)]*?\n[^)]*?\)/g, message: 'Line break within link URL' },
        { regex: /!\[[^\]]*\]\([^)]+$/gm, message: 'Unclosed image syntax' },
        { regex: /\*\*[^*]*$/gm, message: 'Unclosed bold syntax' },
        { regex: /\*[^*]*$/gm, message: 'Unclosed italic syntax' },
        { regex: /```[^`]*$/gm, message: 'Unclosed code block' },
      ];
      
      for (const pattern of brokenSyntaxPatterns) {
        if (pattern.regex.test(markdown)) {
          results.errors.push(`Broken markdown syntax: ${pattern.message}`);
        }
      }
      
      // Check for broken internal links
      const internalLinks = markdown.match(/\[.+?\]\((?!https?:\/\/).+?\)/g) || [];
      for (const link of internalLinks) {
        const urlMatch = link.match(/\]\((.+?)\)/);
        if (urlMatch && urlMatch[1]) {
          const linkTarget = urlMatch[1];
          
          // Check if it's an anchor link
          if (linkTarget.startsWith('#')) {
            const anchor = linkTarget.substring(1);
            const headingExists = markdown.includes(`<a name="${anchor}"></a>`) || 
                                 new RegExp(`^#{1,6}\\s+.*${anchor}.*$`, 'gm').test(markdown);
            
            if (!headingExists) {
              results.warnings.push(`Broken anchor link: ${linkTarget}`);
            }
          }
        }
      }
      
      // Set status based on errors and warnings
      if (results.errors.length > 0) {
        results.status = 'error';
      } else if (results.warnings.length > 0) {
        results.status = 'warning';
      } else {
        results.status = 'success';
      }
      
    } catch (error) {
      results.errors.push(`Verification error: ${error.message}`);
      results.status = 'error';
    }
    
    return results;
  }

  /**
   * Verify a markdown file against its source HTML
   * 
   * @param {string} markdownFile Path to markdown file
   * @param {string} htmlFile Path to source HTML file
   * @param {object} metadata Additional metadata
   * @returns {Promise<object>} Verification results
   */
  async verifyFile(markdownFile, htmlFile, metadata = {}) {
    try {
      // Read both files
      const markdown = await fs.readFile(markdownFile, 'utf8');
      const html = await fs.readFile(htmlFile, 'utf8');
      
      // Verify content
      const results = this.verifyContent(markdown, html, metadata);
      
      // Add file paths to results
      results.markdownFile = markdownFile;
      results.htmlFile = htmlFile;
      
      return results;
    } catch (error) {
      console.error(`Error verifying file: ${markdownFile}`, error.message);
      return {
        markdownFile,
        htmlFile,
        errors: [`File verification error: ${error.message}`],
        status: 'error'
      };
    }
  }

  /**
   * Verify a batch of files and generate a report
   * 
   * @param {Array<object>} files Array of {markdownFile, htmlFile, metadata} objects
   * @returns {Promise<object>} Verification report
   */
  async verifyBatch(files) {
    const results = [];
    let successCount = 0;
    let warningCount = 0;
    let errorCount = 0;
    
    for (const file of files) {
      const result = await this.verifyFile(file.markdownFile, file.htmlFile, file.metadata);
      results.push(result);
      
      if (result.status === 'success') successCount++;
      else if (result.status === 'warning') warningCount++;
      else if (result.status === 'error') errorCount++;
    }
    
    // Generate report
    const report = {
      timestamp: new Date().toISOString(),
      totalFiles: files.length,
      successCount,
      warningCount,
      errorCount,
      successRate: files.length > 0 ? (successCount / files.length) : 0,
      results
    };
    
    // Save report
    await fs.writeJson(this.verificationReportPath, report, { spaces: 2 });
    console.log(`Verification report saved to ${this.verificationReportPath}`);
    
    return report;
  }

  /**
   * Verifies all files in the output directory
   * 
   * @returns {Promise<object>} Verification report
   */
  async verifyAllFiles() {
    try {
      // Find all markdown files
      const markdownFiles = await fs.readdir(this.outputDir);
      const filesToVerify = [];
      
      for (const file of markdownFiles) {
        if (file.endsWith('.md')) {
          const baseName = file.substring(0, file.length - 3);
          const htmlFile = path.join(this.outputDir, `${baseName}_raw.html`);
          const jsonFile = path.join(this.outputDir, `${baseName}_content.json`);
          
          // Only add if both html and markdown exist
          if (await fs.pathExists(htmlFile)) {
            let metadata = {};
            
            // Try to load metadata from json file
            if (await fs.pathExists(jsonFile)) {
              try {
                metadata = await fs.readJson(jsonFile);
              } catch (e) {
                console.warn(`Error reading metadata file: ${jsonFile}`, e.message);
              }
            }
            
            filesToVerify.push({
              markdownFile: path.join(this.outputDir, file),
              htmlFile,
              metadata
            });
          }
        }
      }
      
      console.log(`Found ${filesToVerify.length} files to verify`);
      return this.verifyBatch(filesToVerify);
    } catch (error) {
      console.error('Error verifying all files:', error.message);
      throw error;
    }
  }

  /**
   * Verifies the content quality and returns a verification report
   * 
   * @param {Object} content The content object with HTML and metadata
   * @returns {Object} Verification results with quality metrics
   */
  async verify(content) {
    if (!content || !content.content) {
      return {
        valid: false,
        score: 0,
        reason: 'Empty content',
        metrics: {}
      };
    }

    const metrics = {};
    let totalScore = 0;
    let maxPossibleScore = 0;
    const issues = [];

    // Basic length check
    metrics.contentLength = content.content.length;
    const lengthScore = this.checkContentLength(content.content);
    metrics.lengthScore = lengthScore.score;
    totalScore += lengthScore.score;
    maxPossibleScore += lengthScore.maxScore;
    if (lengthScore.issue) issues.push(lengthScore.issue);

    // Error pattern check
    const errorCheck = this.checkErrorPatterns(content.content);
    metrics.errorPatternScore = errorCheck.score;
    metrics.errorPatternsFound = errorCheck.patterns;
    totalScore += errorCheck.score;
    maxPossibleScore += errorCheck.maxScore;
    if (errorCheck.issue) issues.push(errorCheck.issue);

    // Structure check
    const structureCheck = this.checkStructure(content.content);
    metrics.structureScore = structureCheck.score;
    metrics.headingCount = structureCheck.headings;
    metrics.paragraphCount = structureCheck.paragraphs;
    metrics.listCount = structureCheck.lists;
    metrics.imageCount = structureCheck.images;
    totalScore += structureCheck.score;
    maxPossibleScore += structureCheck.maxScore;
    if (structureCheck.issue) issues.push(structureCheck.issue);

    // Readability check
    const readabilityCheck = this.checkReadability(content.content);
    metrics.readabilityScore = readabilityCheck.score;
    metrics.fleschScore = readabilityCheck.fleschScore;
    metrics.fogIndex = readabilityCheck.fogIndex;
    metrics.averageSentenceLength = readabilityCheck.avgSentenceLength;
    metrics.averageWordLength = readabilityCheck.avgWordLength;
    totalScore += readabilityCheck.score;
    maxPossibleScore += readabilityCheck.maxScore;
    if (readabilityCheck.issue) issues.push(readabilityCheck.issue);

    // Content duplicity check (boilerplate detection)
    const duplicityCheck = this.checkDuplicateContent(content.content);
    metrics.uniqueContentScore = duplicityCheck.score;
    metrics.duplicateRatio = duplicityCheck.duplicateRatio;
    totalScore += duplicityCheck.score;
    maxPossibleScore += duplicityCheck.maxScore;
    if (duplicityCheck.issue) issues.push(duplicityCheck.issue);

    // Meaningful content check
    const meaningfulCheck = this.checkMeaningfulContent(content.content);
    metrics.meaningfulContentScore = meaningfulCheck.score;
    metrics.contentDensity = meaningfulCheck.contentDensity;
    metrics.wordCount = meaningfulCheck.wordCount;
    totalScore += meaningfulCheck.score;
    maxPossibleScore += meaningfulCheck.maxScore;
    if (meaningfulCheck.issue) issues.push(meaningfulCheck.issue);

    // Topic coherence check
    const coherenceCheck = this.checkTopicCoherence(content.content);
    metrics.topicCoherenceScore = coherenceCheck.score;
    metrics.keywordDensity = coherenceCheck.keywordDensity;
    metrics.topKeywords = coherenceCheck.topKeywords;
    totalScore += coherenceCheck.score;
    maxPossibleScore += coherenceCheck.maxScore;
    if (coherenceCheck.issue) issues.push(coherenceCheck.issue);
    
    // Link density check (new)
    const linkCheck = this.checkLinkDensity(content.content);
    metrics.linkDensityScore = linkCheck.score;
    metrics.linkDensity = linkCheck.linkDensity;
    metrics.linkCount = linkCheck.linkCount;
    totalScore += linkCheck.score;
    maxPossibleScore += linkCheck.maxScore;
    if (linkCheck.issue) issues.push(linkCheck.issue);
    
    // Advertising content check (new)
    const adCheck = this.checkAdvertisingContent(content.content);
    metrics.adFreeScore = adCheck.score;
    metrics.adPatternMatches = adCheck.matches;
    totalScore += adCheck.score;
    maxPossibleScore += adCheck.maxScore;
    if (adCheck.issue) issues.push(adCheck.issue);
    
    // Code quality check (new)
    if (this.codeQualityMetrics) {
      const codeCheck = this.checkCodeQuality(content.content);
      metrics.codeQualityScore = codeCheck.score;
      metrics.codeBlocks = codeCheck.codeBlocks;
      totalScore += codeCheck.score;
      maxPossibleScore += codeCheck.maxScore;
      if (codeCheck.issue) issues.push(codeCheck.issue);
    }
    
    // Formatting consistency check (new)
    const formattingCheck = this.checkFormattingConsistency(content.content);
    metrics.formattingScore = formattingCheck.score;
    metrics.emptyLineRatio = formattingCheck.emptyLineRatio;
    metrics.consistencyIssues = formattingCheck.issues;
    totalScore += formattingCheck.score;
    maxPossibleScore += formattingCheck.maxScore;
    if (formattingCheck.issue) issues.push(formattingCheck.issue);
    
    // Spelling check (new)
    if (this.spellingCheck) {
      const spellingCheck = await this.checkSpelling(content.content);
      metrics.spellingScore = spellingCheck.score;
      metrics.spellingErrorRatio = spellingCheck.errorRatio;
      totalScore += spellingCheck.score;
      maxPossibleScore += spellingCheck.maxScore;
      if (spellingCheck.issue) issues.push(spellingCheck.issue);
    }
    
    // Calculate final normalized score (0-100)
    const normalizedScore = maxPossibleScore > 0 ? 
      Math.round((totalScore / maxPossibleScore) * 100) : 0;
    
    // Determine overall validity
    const valid = normalizedScore >= 60 && issues.length <= 3;
    
    return {
      valid,
      score: normalizedScore,
      reason: valid ? 'Content meets quality standards' : 
        `Quality issues found: ${issues.slice(0, 3).join(', ')}${issues.length > 3 ? '...' : ''}`,
      metrics,
      issues
    };
  }

  /**
   * Checks content length
   */
  checkContentLength(content) {
    const lengthScore = {
      maxScore: 10,
      score: 0,
      issue: null
    };
    
    if (content.length < this.minContentLength) {
      lengthScore.score = 0;
      lengthScore.issue = `Content too short (${content.length} chars)`;
    } else if (content.length < this.minContentLength * 2) {
      lengthScore.score = 5;
    } else if (content.length < this.minContentLength * 5) {
      lengthScore.score = 7;
    } else {
      lengthScore.score = 10;
    }
    
    return lengthScore;
  }

  /**
   * Checks for error patterns that indicate non-valid content
   */
  checkErrorPatterns(content) {
    const errorCheck = {
      maxScore: 10,
      score: 10,
      patterns: [],
      issue: null
    };
    
    const lowerContent = content.toLowerCase();
    
    for (const pattern of this.errorPatterns) {
      if (lowerContent.includes(pattern.toLowerCase())) {
        errorCheck.patterns.push(pattern);
      }
    }
    
    const errorRatio = errorCheck.patterns.length / content.length;
    
    if (errorRatio > this.maxErrorRatio) {
      errorCheck.score = 0;
      errorCheck.issue = 'Error patterns detected';
    } else if (errorCheck.patterns.length > 0) {
      errorCheck.score = 5;
    }
    
    return errorCheck;
  }

  /**
   * Checks HTML structure for headings, paragraphs, lists, and images
   */
  checkStructure(htmlContent) {
    const structureCheck = {
      maxScore: 20,
      score: 0,
      headings: 0,
      paragraphs: 0,
      lists: 0,
      images: 0,
      issue: null
    };
    
    try {
      const $ = cheerio.load(htmlContent);
      
      // Count headings
      structureCheck.headings = $('h1, h2, h3, h4, h5, h6').length;
      
      // Count paragraphs
      structureCheck.paragraphs = $('p').length;
      
      // Count lists
      structureCheck.lists = $('ul, ol').length;
      
      // Count images
      structureCheck.images = $('img').length;
      
      // Calculate score based on structure
      let score = 0;
      
      // Heading score
      if (structureCheck.headings >= this.minHeadingCount) {
        score += 5;
      } else {
        structureCheck.issue = 'Insufficient headings';
      }
      
      // Paragraph score
      if (structureCheck.paragraphs >= this.minParagraphCount) {
        score += 5;
      } else if (structureCheck.issue === null) {
        structureCheck.issue = 'Insufficient paragraphs';
      }
      
      // List score
      score += Math.min(5, structureCheck.lists * 2);
      
      // Image score
      const imageTextRatio = structureCheck.images / htmlContent.length;
      if (imageTextRatio >= this.minImageTextRatio) {
        score += 5;
      } else if (structureCheck.issue === null && structureCheck.images === 0) {
        structureCheck.issue = 'No images found';
      }
      
      structureCheck.score = score;
    } catch (error) {
      structureCheck.score = 0;
      structureCheck.issue = 'Error analyzing structure';
    }
    
    return structureCheck;
  }

  /**
   * Checks readability metrics (Flesch Reading Ease, Fog Index)
   */
  checkReadability(htmlContent) {
    const readabilityCheck = {
      maxScore: 15,
      score: 0,
      fleschScore: 0,
      fogIndex: 0,
      avgSentenceLength: 0,
      avgWordLength: 0,
      issue: null
    };
    
    try {
      // Extract text from HTML
      const { window } = new JSDOM(htmlContent);
      const textContent = window.document.body.textContent || '';
      
      // Split into sentences
      const sentences = textContent.split(/[.!?]+/).filter(s => s.trim().length > 0);
      
      if (sentences.length === 0) {
        readabilityCheck.issue = 'No sentences found';
        return readabilityCheck;
      }
      
      // Calculate average sentence length (in words)
      const words = textContent.split(/\s+/).filter(w => w.trim().length > 0);
      readabilityCheck.avgSentenceLength = words.length / sentences.length;
      
      // Calculate average word length (in characters)
      const totalChars = words.reduce((sum, word) => sum + word.length, 0);
      readabilityCheck.avgWordLength = totalChars / words.length;
      
      // Calculate Flesch Reading Ease
      const ASL = readabilityCheck.avgSentenceLength;
      const AWL = readabilityCheck.avgWordLength;
      readabilityCheck.fleschScore = 206.835 - (1.015 * ASL) - (84.6 * AWL);
      
      // Calculate Gunning Fog Index
      const complexWords = words.filter(word => word.length > 6).length;
      const percentComplexWords = complexWords / words.length * 100;
      readabilityCheck.fogIndex = 0.4 * (ASL + percentComplexWords);
      
      // Score based on readability
      if (readabilityCheck.fleschScore >= this.minReadabilityScore) {
        readabilityCheck.score = 15;
      } else if (readabilityCheck.fleschScore >= this.minReadabilityScore * 0.7) {
        readabilityCheck.score = 10;
        readabilityCheck.issue = 'Moderate readability issues';
      } else if (readabilityCheck.fleschScore >= this.minReadabilityScore * 0.4) {
        readabilityCheck.score = 5;
        readabilityCheck.issue = 'Significant readability issues';
      } else {
        readabilityCheck.score = 0;
        readabilityCheck.issue = 'Poor readability';
      }
    } catch (error) {
      readabilityCheck.score = 0;
      readabilityCheck.issue = 'Error analyzing readability';
    }
    
    return readabilityCheck;
  }

  /**
   * Checks for duplicate content (boilerplate detection)
   */
  checkDuplicateContent(htmlContent) {
    const duplicityCheck = {
      maxScore: 10,
      score: 10,
      duplicateRatio: 0,
      issue: null
    };
    
    try {
      // Extract text from HTML
      const { window } = new JSDOM(htmlContent);
      const textContent = window.document.body.textContent || '';
      
      // Split into sentences
      const sentences = textContent.split(/[.!?]+/).filter(s => s.trim().length > 0);
      
      if (sentences.length === 0) {
        duplicityCheck.score = 0;
        duplicityCheck.issue = 'No sentences found';
        return duplicityCheck;
      }
      
      // Check for duplicate sentences
      const uniqueSentences = new Set(sentences);
      const duplicateCount = sentences.length - uniqueSentences.size;
      duplicityCheck.duplicateRatio = duplicateCount / sentences.length;
      
      // Score based on duplicity
      if (duplicityCheck.duplicateRatio > this.boilerplateThreshold) {
        duplicityCheck.score = 0;
        duplicityCheck.issue = 'High duplicate content ratio';
      } else if (duplicityCheck.duplicateRatio > this.boilerplateThreshold * 0.7) {
        duplicityCheck.score = 5;
        duplicityCheck.issue = 'Moderate duplicate content';
      } else if (duplicityCheck.duplicateRatio > this.boilerplateThreshold * 0.3) {
        duplicityCheck.score = 7;
      }
    } catch (error) {
      duplicityCheck.score = 0;
      duplicityCheck.issue = 'Error analyzing duplicate content';
    }
    
    return duplicityCheck;
  }

  /**
   * Checks for meaningful content (noise vs. signal ratio)
   */
  checkMeaningfulContent(htmlContent) {
    const meaningfulCheck = {
      maxScore: 15,
      score: 0,
      contentDensity: 0,
      wordCount: 0,
      issue: null
    };
    
    try {
      // Extract text from HTML
      const { window } = new JSDOM(htmlContent);
      const textContent = window.document.body.textContent || '';
      
      // Count words (excluding stop words)
      const words = textContent.split(/\s+/).filter(w => {
        // Simple stopwords filter (can be expanded)
        const stopwords = ['the', 'and', 'in', 'of', 'to', 'a', 'is', 'that', 'for', 'on', 'with'];
        return w.trim().length > 2 && !stopwords.includes(w.toLowerCase());
      });
      
      meaningfulCheck.wordCount = words.length;
      
      // Calculate content density (ratio of meaningful words to total content length)
      meaningfulCheck.contentDensity = words.length / textContent.length;
      
      // Score based on content density
      if (meaningfulCheck.contentDensity >= this.meaningfulContentThreshold) {
        meaningfulCheck.score = 15;
      } else if (meaningfulCheck.contentDensity >= this.meaningfulContentThreshold * 0.7) {
        meaningfulCheck.score = 10;
      } else if (meaningfulCheck.contentDensity >= this.meaningfulContentThreshold * 0.4) {
        meaningfulCheck.score = 5;
        meaningfulCheck.issue = 'Low content density';
      } else {
        meaningfulCheck.score = 0;
        meaningfulCheck.issue = 'Very low meaningful content';
      }
    } catch (error) {
      meaningfulCheck.score = 0;
      meaningfulCheck.issue = 'Error analyzing meaningful content';
    }
    
    return meaningfulCheck;
  }

  /**
   * Checks topic coherence through keyword analysis
   */
  checkTopicCoherence(htmlContent) {
    const coherenceCheck = {
      maxScore: 10,
      score: 0,
      keywordDensity: 0,
      topKeywords: [],
      issue: null
    };
    
    try {
      // Extract text from HTML
      const { window } = new JSDOM(htmlContent);
      const textContent = window.document.body.textContent || '';
      
      // Tokenize and analyze
      const tokens = this.tokenizer.tokenize(textContent.toLowerCase());
      
      if (tokens.length === 0) {
        coherenceCheck.issue = 'No content to analyze';
        return coherenceCheck;
      }
      
      // Filter tokens (remove short words and stopwords)
      const filteredTokens = tokens.filter(token => {
        // Simple stopwords filter (can be expanded)
        const stopwords = ['the', 'and', 'in', 'of', 'to', 'a', 'is', 'that', 'for', 'on', 'with'];
        return token.length > 2 && !stopwords.includes(token);
      });
      
      // Count occurrences of each word
      const wordCounts = {};
      filteredTokens.forEach(token => {
        const stem = this.stemmer.stem(token);
        wordCounts[stem] = (wordCounts[stem] || 0) + 1;
      });
      
      // Get top keywords
      const sortedWords = Object.entries(wordCounts)
        .sort((a, b) => b[1] - a[1])
        .slice(0, 10);
      
      coherenceCheck.topKeywords = sortedWords.map(([word, count]) => ({ 
        word, 
        count,
        frequency: count / filteredTokens.length
      }));
      
      // Calculate keyword density for top 5 keywords
      const top5Density = sortedWords.slice(0, 5).reduce((sum, [_, count]) => sum + count, 0) / 
        filteredTokens.length;
      
      coherenceCheck.keywordDensity = top5Density;
      
      // Score based on keyword density
      if (top5Density >= this.topicCoherenceThreshold) {
        coherenceCheck.score = 10;
      } else if (top5Density >= this.topicCoherenceThreshold * 0.7) {
        coherenceCheck.score = 7;
      } else if (top5Density >= this.topicCoherenceThreshold * 0.4) {
        coherenceCheck.score = 4;
        coherenceCheck.issue = 'Low topic coherence';
      } else {
        coherenceCheck.score = 0;
        coherenceCheck.issue = 'Very low topic coherence';
      }
    } catch (error) {
      coherenceCheck.score = 0;
      coherenceCheck.issue = 'Error analyzing topic coherence';
    }
    
    return coherenceCheck;
  }
  
  /**
   * Checks link density (new metric)
   */
  checkLinkDensity(htmlContent) {
    const linkCheck = {
      maxScore: 10,
      score: 10,
      linkDensity: 0,
      linkCount: 0,
      issue: null
    };
    
    try {
      const $ = cheerio.load(htmlContent);
      
      // Count links
      linkCheck.linkCount = $('a').length;
      
      // Extract text length
      const textLength = $('body').text().length;
      
      // Calculate link density
      linkCheck.linkDensity = textLength > 0 ? 
        linkCheck.linkCount / textLength : 0;
      
      // Score based on link density
      if (linkCheck.linkDensity > this.linkDensityThreshold) {
        linkCheck.score = 0;
        linkCheck.issue = 'Excessive links detected';
      } else if (linkCheck.linkDensity > this.linkDensityThreshold * 0.8) {
        linkCheck.score = 5;
        linkCheck.issue = 'High link density';
      } else if (linkCheck.linkDensity > this.linkDensityThreshold * 0.6) {
        linkCheck.score = 7;
      }
    } catch (error) {
      linkCheck.score = 5; // Default to middle score on error
      linkCheck.issue = 'Error analyzing link density';
    }
    
    return linkCheck;
  }
  
  /**
   * Checks for advertising content (new metric)
   */
  checkAdvertisingContent(htmlContent) {
    const adCheck = {
      maxScore: 10,
      score: 10,
      matches: [],
      issue: null
    };
    
    try {
      // Extract text from HTML
      const { window } = new JSDOM(htmlContent);
      const textContent = window.document.body.textContent || '';
      const lowerContent = textContent.toLowerCase();
      
      // Check for ad patterns
      for (const pattern of this.adPatterns) {
        if (lowerContent.includes(pattern.toLowerCase())) {
          adCheck.matches.push(pattern);
        }
      }
      
      // Score based on ad patterns found
      if (adCheck.matches.length > 5) {
        adCheck.score = 0;
        adCheck.issue = 'Heavy advertising content detected';
      } else if (adCheck.matches.length > 3) {
        adCheck.score = 4;
        adCheck.issue = 'Moderate advertising content';
      } else if (adCheck.matches.length > 1) {
        adCheck.score = 7;
      }
    } catch (error) {
      adCheck.score = 5; // Default to middle score on error
      adCheck.issue = 'Error analyzing advertising content';
    }
    
    return adCheck;
  }
  
  /**
   * Checks code quality for technical content (new metric)
   */
  checkCodeQuality(htmlContent) {
    const codeCheck = {
      maxScore: 10,
      score: 0,
      codeBlocks: 0,
      issue: null
    };
    
    try {
      const $ = cheerio.load(htmlContent);
      
      // Find code blocks
      const codeElements = $('pre, code, .code, [class*="language-"]');
      codeCheck.codeBlocks = codeElements.length;
      
      if (codeCheck.codeBlocks === 0) {
        // No code blocks found, this metric is not applicable
        codeCheck.score = 5; // Neutral score
        return codeCheck;
      }
      
      // Simple quality checks for code blocks
      let validCodeBlocks = 0;
      codeElements.each((i, element) => {
        const codeText = $(element).text();
        
        // Check for minimum length
        if (codeText.length < 10) {
          return;
        }
        
        // Check for formatting consistency
        const indentationConsistent = this.checkCodeIndentation(codeText);
        
        // Check for syntax elements
        const hasSyntaxElements = /[{}();=]/.test(codeText);
        
        if (indentationConsistent && hasSyntaxElements) {
          validCodeBlocks++;
        }
      });
      
      // Calculate score based on valid code blocks ratio
      const validRatio = validCodeBlocks / codeCheck.codeBlocks;
      
      if (validRatio >= 0.8) {
        codeCheck.score = 10;
      } else if (validRatio >= 0.6) {
        codeCheck.score = 7;
      } else if (validRatio >= 0.3) {
        codeCheck.score = 4;
        codeCheck.issue = 'Poor code formatting detected';
      } else {
        codeCheck.score = 0;
        codeCheck.issue = 'Bad code quality';
      }
    } catch (error) {
      codeCheck.score = 5; // Default to middle score on error
      codeCheck.issue = 'Error analyzing code quality';
    }
    
    return codeCheck;
  }
  
  /**
   * Helper method to check code indentation consistency
   */
  checkCodeIndentation(codeText) {
    const lines = codeText.split('\n').filter(line => line.trim().length > 0);
    
    if (lines.length < 3) {
      return true; // Too short to check
    }
    
    // Detect indentation character and size
    const indentChar = lines[1].startsWith('\t') ? '\t' : ' ';
    
    // Count indentation levels
    const indentLevels = lines.map(line => {
      let i = 0;
      while (line[i] === indentChar) {
        i++;
      }
      return i;
    });
    
    // Check for consistency (should have some variation in levels)
    const uniqueLevels = new Set(indentLevels);
    const hasVariation = uniqueLevels.size > 1;
    
    // Check for progressive indentation (not all lines at same level)
    const maxIndent = Math.max(...indentLevels);
    const minIndent = Math.min(...indentLevels);
    
    return hasVariation && maxIndent - minIndent < 10; // Avoid extremes
  }
  
  /**
   * Checks formatting consistency (new metric)
   */
  checkFormattingConsistency(htmlContent) {
    const formattingCheck = {
      maxScore: 10,
      score: 10,
      emptyLineRatio: 0,
      issues: [],
      issue: null
    };
    
    try {
      const $ = cheerio.load(htmlContent);
      
      // Extract text with line breaks preserved
      const text = $.text().replace(/\n+/g, '\n');
      const lines = text.split('\n');
      
      // Count empty lines
      const emptyLines = lines.filter(line => line.trim().length === 0).length;
      formattingCheck.emptyLineRatio = emptyLines / lines.length;
      
      // Check for consecutive empty lines
      let maxConsecutiveEmpty = 0;
      let currentConsecutive = 0;
      
      for (const line of lines) {
        if (line.trim().length === 0) {
          currentConsecutive++;
        } else {
          maxConsecutiveEmpty = Math.max(maxConsecutiveEmpty, currentConsecutive);
          currentConsecutive = 0;
        }
      }
      
      // Update max consecutive if at end of content
      maxConsecutiveEmpty = Math.max(maxConsecutiveEmpty, currentConsecutive);
      
      // Check heading-paragraph consistency
      const headings = $('h1, h2, h3, h4, h5, h6');
      let headingsWithoutContent = 0;
      
      headings.each((i, heading) => {
        const $heading = $(heading);
        const nextP = $heading.next('p');
        
        if (nextP.length === 0 && i < headings.length - 1) {
          headingsWithoutContent++;
        }
      });
      
      // Collect issues
      if (maxConsecutiveEmpty > this.maxConsecutiveEmptyLines) {
        formattingCheck.issues.push('Too many consecutive empty lines');
      }
      
      if (formattingCheck.emptyLineRatio > 0.3) {
        formattingCheck.issues.push('High ratio of empty lines');
      }
      
      if (headingsWithoutContent > headings.length * 0.3) {
        formattingCheck.issues.push('Many headings without content');
      }
      
      // Calculate score
      if (formattingCheck.issues.length >= 3) {
        formattingCheck.score = 0;
        formattingCheck.issue = 'Multiple formatting issues';
      } else if (formattingCheck.issues.length === 2) {
        formattingCheck.score = 4;
        formattingCheck.issue = formattingCheck.issues.join(', ');
      } else if (formattingCheck.issues.length === 1) {
        formattingCheck.score = 7;
        formattingCheck.issue = formattingCheck.issues[0];
      }
    } catch (error) {
      formattingCheck.score = 5; // Default to middle score on error
      formattingCheck.issue = 'Error analyzing formatting consistency';
    }
    
    return formattingCheck;
  }
  
  /**
   * Checks spelling quality (new metric)
   */
  async checkSpelling(htmlContent) {
    const spellingCheck = {
      maxScore: 10,
      score: 10,
      errorRatio: 0,
      issue: null
    };
    
    if (!this.spellingCheck) {
      spellingCheck.issue = 'Spelling check disabled';
      return spellingCheck;
    }
    
    try {
      // Extract text from HTML
      const { window } = new JSDOM(htmlContent);
      const textContent = window.document.body.textContent || '';
      
      // Tokenize into words
      const words = textContent.split(/\s+/)
        .filter(w => w.length > 2)
        .filter(w => !/\d/.test(w)) // Filter out words with numbers
        .filter(w => !/[^\w\s]/.test(w)) // Filter out words with special chars
        .map(w => w.toLowerCase())
        .slice(0, 1000); // Limit to 1000 words for performance
      
      if (words.length === 0) {
        spellingCheck.issue = 'No words to check';
        return spellingCheck;
      }
      
      // Check spelling
      let spellingErrors = 0;
      
      for (const word of words) {
        if (!this.spellcheck.isCorrect(word)) {
          spellingErrors++;
        }
      }
      
      // Calculate error ratio
      spellingCheck.errorRatio = spellingErrors / words.length;
      
      // Score based on error ratio
      if (spellingCheck.errorRatio > 0.2) {
        spellingCheck.score = 0;
        spellingCheck.issue = 'High rate of spelling errors';
      } else if (spellingCheck.errorRatio > 0.1) {
        spellingCheck.score = 5;
        spellingCheck.issue = 'Moderate spelling issues';
      } else if (spellingCheck.errorRatio > 0.05) {
        spellingCheck.score = 7;
      }
    } catch (error) {
      spellingCheck.score = 5; // Default to middle score on error
      spellingCheck.issue = 'Error analyzing spelling';
    }
    
    return spellingCheck;
  }
}

module.exports = ContentVerifier; 