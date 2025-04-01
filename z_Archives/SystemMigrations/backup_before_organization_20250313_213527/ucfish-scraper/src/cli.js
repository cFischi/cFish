#!/usr/bin/env node

/**
 * CLI Module
 * 
 * Provides a command-line interface for the scraper with 
 * options for configuration, monitoring, and verification.
 * 
 * @package ucfish-scraper
 * @since 1.0.0
 */

const { program } = require('commander');
const fs = require('fs-extra');
const path = require('path');
const Scraper = require('./scraper');
const ContentVerifier = require('./contentVerifier');
const ContentMerger = require('./contentMerger');
const dotenv = require('dotenv');

// Load environment variables
dotenv.config({ path: path.join(__dirname, '../config/.env') });

// Version from package.json
const packageJson = require('../package.json');

// Configure CLI
program
  .name('ucfish-scraper')
  .description('UcFish Web Content Scraper & Markdown Converter')
  .version(packageJson.version);

// Main scrape command
program
  .command('scrape')
  .description('Scrape a website and convert content to markdown')
  .requiredOption('--url <url>', 'Starting URL to scrape')
  .option('--depth <depth>', 'Maximum depth to crawl', parseInt, parseInt(process.env.MAX_DEPTH || '3'))
  .option('--output <dir>', 'Output directory', path.join(__dirname, '../output'))
  .option('--concurrency <n>', 'Maximum concurrent requests', parseInt, parseInt(process.env.MAX_CONCURRENT_SCRAPES || '2'))
  .option('--delay <ms>', 'Delay between requests in milliseconds', parseInt, parseInt(process.env.REQUEST_DELAY || '2000'))
  .option('--no-resume', 'Disable resuming from checkpoint')
  .option('--no-verify', 'Disable verification of output')
  .option('--no-merge', 'Disable merging of related content')
  .action(async (options) => {
    try {
      console.log('UcFish Web Content Scraper & Markdown Converter');
      console.log('=============================================');
      console.log(`Starting URL: ${options.url}`);
      console.log(`Max depth: ${options.depth}`);
      console.log(`Output directory: ${options.output}`);
      console.log(`Concurrency: ${options.concurrency}`);
      console.log(`Request delay: ${options.delay}ms`);
      console.log(`Resume enabled: ${options.resume}`);
      console.log(`Verification enabled: ${options.verify}`);
      console.log(`Content merging enabled: ${options.merge}`);
      console.log('=============================================');
      
      // Create scraper instance
      const scraper = new Scraper({
        baseUrl: options.url,
        maxDepth: options.depth,
        outputDir: options.output,
        concurrency: options.concurrency,
        requestDelay: options.delay,
        resumable: options.resume,
        verifyOutput: options.verify,
        mergeContent: options.merge
      });
      
      // Run scraper
      const result = await scraper.start({
        startUrl: options.url,
        resume: options.resume
      });
      
      console.log('=============================================');
      console.log('Scraping complete!');
      console.log(`Status: ${result.status}`);
      console.log(`Discovered URLs: ${result.statistics.discovered}`);
      console.log(`Processed URLs: ${result.statistics.processed}`);
      console.log(`Failed URLs: ${result.statistics.failed}`);
      console.log(`Success rate: ${result.statistics.successRate}%`);
      console.log(`Total duration: ${result.duration}`);
      console.log(`Output directory: ${result.outputDir}`);
      console.log('=============================================');
      
    } catch (error) {
      console.error('Error running scraper:', error);
      process.exit(1);
    }
  });

// Verify command
program
  .command('verify')
  .description('Verify the quality of scraped content')
  .requiredOption('--input <dir>', 'Input directory containing markdown and HTML files')
  .option('--report <file>', 'Path to save verification report', 'verification_report.json')
  .action(async (options) => {
    try {
      console.log('UcFish Content Verification');
      console.log('==========================');
      console.log(`Input directory: ${options.input}`);
      console.log(`Report file: ${options.report}`);
      console.log('==========================');
      
      // Create verifier instance
      const verifier = new ContentVerifier({
        outputDir: options.input,
        verificationReportPath: options.report
      });
      
      // Run verification
      const report = await verifier.verifyAllFiles();
      
      console.log('==========================');
      console.log('Verification complete!');
      console.log(`Total files: ${report.totalFiles}`);
      console.log(`Success: ${report.successCount}`);
      console.log(`Warnings: ${report.warningCount}`);
      console.log(`Errors: ${report.errorCount}`);
      console.log(`Success rate: ${Math.round(report.successRate * 100)}%`);
      console.log(`Report saved to: ${verifier.verificationReportPath}`);
      console.log('==========================');
      
    } catch (error) {
      console.error('Error verifying content:', error);
      process.exit(1);
    }
  });

// Summarize command
program
  .command('summarize')
  .description('Generate a summary of scraped content')
  .requiredOption('--input <dir>', 'Input directory containing markdown files')
  .requiredOption('--output <file>', 'Output file for summary')
  .action(async (options) => {
    try {
      console.log('UcFish Content Summarization');
      console.log('===========================');
      console.log(`Input directory: ${options.input}`);
      console.log(`Output file: ${options.output}`);
      console.log('===========================');
      
      // Read all markdown files
      const files = await getAllMarkdownFiles(options.input);
      console.log(`Found ${files.length} markdown files`);
      
      // Generate summary
      const summary = await generateSummary(files, options.input);
      
      // Write summary to file
      await fs.writeFile(options.output, summary);
      
      console.log('===========================');
      console.log('Summary generation complete!');
      console.log(`Summary saved to: ${options.output}`);
      console.log('===========================');
      
    } catch (error) {
      console.error('Error generating summary:', error);
      process.exit(1);
    }
  });

// Merge command
program
  .command('merge')
  .description('Merge related content')
  .requiredOption('--input <dir>', 'Input directory containing markdown files')
  .option('--threshold <n>', 'Similarity threshold (0-1)', parseFloat, 0.6)
  .option('--output <dir>', 'Output directory for merged content', 'merged')
  .action(async (options) => {
    try {
      console.log('UcFish Content Merger');
      console.log('====================');
      console.log(`Input directory: ${options.input}`);
      console.log(`Output directory: ${options.output}`);
      console.log(`Similarity threshold: ${options.threshold}`);
      console.log('====================');
      
      // Create merger instance
      const merger = new ContentMerger({
        contentDir: options.input,
        mergedDir: options.output,
        similarityThreshold: options.threshold
      });
      
      // Run merger
      const mergedFiles = await merger.mergeRelatedContent();
      
      console.log('====================');
      console.log('Content merging complete!');
      console.log(`Merged ${mergedFiles.length} clusters into ${mergedFiles.length} files`);
      console.log(`Output directory: ${options.output}`);
      console.log('====================');
      
    } catch (error) {
      console.error('Error merging content:', error);
      process.exit(1);
    }
  });

// Resume command
program
  .command('resume')
  .description('Resume a previously interrupted scrape')
  .option('--output <dir>', 'Output directory containing checkpoint', path.join(__dirname, '../output'))
  .action(async (options) => {
    try {
      console.log('UcFish Scrape Resume');
      console.log('===================');
      console.log(`Output directory: ${options.output}`);
      
      // Check for checkpoint file
      const checkpointPath = path.join(options.output, 'checkpoint.json');
      if (!await fs.pathExists(checkpointPath)) {
        console.error('No checkpoint found. Cannot resume.');
        process.exit(1);
      }
      
      // Load checkpoint
      const checkpoint = await fs.readJson(checkpointPath);
      console.log(`Found checkpoint from: ${checkpoint.timestamp}`);
      console.log(`Status: ${checkpoint.state.status}`);
      console.log(`Discovered URLs: ${checkpoint.state.discoveredUrls.length}`);
      console.log(`Processed URLs: ${checkpoint.state.processedUrls.length}`);
      console.log(`Failed URLs: ${checkpoint.state.failedUrls.length}`);
      console.log('===================');
      
      // Create scraper instance
      const scraper = new Scraper({
        outputDir: options.output,
        resumable: true
      });
      
      // Run scraper with resume option
      const result = await scraper.start({
        resume: true
      });
      
      console.log('===================');
      console.log('Resumption complete!');
      console.log(`Status: ${result.status}`);
      console.log(`Discovered URLs: ${result.statistics.discovered}`);
      console.log(`Processed URLs: ${result.statistics.processed}`);
      console.log(`Failed URLs: ${result.statistics.failed}`);
      console.log(`Success rate: ${result.statistics.successRate}%`);
      console.log(`Total duration: ${result.duration}`);
      console.log(`Output directory: ${result.outputDir}`);
      console.log('===================');
      
    } catch (error) {
      console.error('Error resuming scrape:', error);
      process.exit(1);
    }
  });

/**
 * Gets all markdown files in a directory recursively
 * 
 * @param {string} directory The directory to search
 * @returns {Promise<Array<string>>} Array of file paths
 */
async function getAllMarkdownFiles(directory) {
  const files = [];
  
  async function walk(dir) {
    const entries = await fs.readdir(dir, { withFileTypes: true });
    
    for (const entry of entries) {
      const fullPath = path.join(dir, entry.name);
      
      if (entry.isDirectory()) {
        await walk(fullPath);
      } else if (entry.isFile() && entry.name.endsWith('.md')) {
        files.push(fullPath);
      }
    }
  }
  
  await walk(directory);
  return files;
}

/**
 * Generates a summary of markdown files
 * 
 * @param {Array<string>} files Array of file paths
 * @param {string} baseDir Base directory
 * @returns {Promise<string>} Generated summary markdown
 */
async function generateSummary(files, baseDir) {
  let summary = '# Content Summary\n\n';
  summary += `*Generated on ${new Date().toISOString()}*\n\n`;
  summary += `This summary contains information about ${files.length} markdown files.\n\n`;
  
  // Sort files by path
  files.sort();
  
  // Group by directory
  const filesByDirectory = {};
  
  for (const file of files) {
    const relativePath = path.relative(baseDir, file);
    const directory = path.dirname(relativePath);
    
    if (!filesByDirectory[directory]) {
      filesByDirectory[directory] = [];
    }
    
    filesByDirectory[directory].push({
      path: relativePath,
      name: path.basename(relativePath)
    });
  }
  
  // Add table of contents
  summary += '## Table of Contents\n\n';
  
  for (const directory of Object.keys(filesByDirectory).sort()) {
    const dirName = directory === '.' ? 'Root Directory' : directory;
    const anchor = dirName.toLowerCase().replace(/[^\w]+/g, '-');
    summary += `- [${dirName}](#${anchor})\n`;
  }
  
  summary += '\n';
  
  // Add content for each directory
  for (const directory of Object.keys(filesByDirectory).sort()) {
    const dirName = directory === '.' ? 'Root Directory' : directory;
    summary += `## ${dirName}\n\n`;
    
    const dirFiles = filesByDirectory[directory];
    
    // Add table of files
    summary += '| File | Title |\n';
    summary += '|------|-------|\n';
    
    for (const file of dirFiles) {
      try {
        // Read file to extract title
        const content = await fs.readFile(path.join(baseDir, file.path), 'utf8');
        const titleMatch = content.match(/^# (.+)$/m) || content.match(/^title: ["'](.+)["']/m);
        const title = titleMatch ? titleMatch[1] : file.name;
        
        summary += `| [${file.name}](${file.path.replace(/\\/g, '/')}) | ${title} |\n`;
      } catch (error) {
        summary += `| [${file.name}](${file.path.replace(/\\/g, '/')}) | Error reading file |\n`;
      }
    }
    
    summary += '\n';
  }
  
  return summary;
}

// Parse command line arguments
program.parse(process.argv);

// Display help if no command provided
if (!process.argv.slice(2).length) {
  program.outputHelp();
} 