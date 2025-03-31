const axios = require('axios');
const cheerio = require('cheerio');
const TurndownService = require('turndown');
const fs = require('fs');
const path = require('path');
const url = require('url');

// Initialize turndown service to convert HTML to Markdown
const turndownService = new TurndownService({
  headingStyle: 'atx',
  codeBlockStyle: 'fenced',
  emDelimiter: '_'
});

// Custom rules for Turndown
turndownService.addRule('emphasize', {
  filter: ['em', 'i'],
  replacement: function(content) {
    return '_' + content + '_';
  }
});

turndownService.addRule('codeBlock', {
  filter: function(node) {
    return node.nodeName === 'PRE' && 
           node.firstChild && 
           node.firstChild.nodeName === 'CODE';
  },
  replacement: function(content, node) {
    return '```\n' + node.firstChild.textContent + '\n```\n\n';
  }
});

// Configuration
const config = {
  baseUrl: 'https://u.cfish.io/u-ucf',
  startUrl: 'https://u.cfish.io/u-ucf?v=17c33104429080cc8c82000c89b1f0d4&pvs=4',
  outputFile: path.join(__dirname, '../../cfish-ucf-content.md'),
  visitedUrls: new Set(),
  maxDepth: 2, // Maximum depth to crawl
  userAgent: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
};

// Helper to normalize URLs
function normalizeUrl(link, baseUrl) {
  try {
    const parsedUrl = url.parse(url.resolve(baseUrl, link));
    // Only include URLs from the same domain
    if (!parsedUrl.hostname || !parsedUrl.hostname.includes('cfish.io')) {
      return null;
    }
    return parsedUrl.href;
  } catch (error) {
    console.error(`Error normalizing URL ${link}:`, error.message);
    return null;
  }
}

// Function to scrape a page
async function scrapePage(pageUrl, depth = 0) {
  if (config.visitedUrls.has(pageUrl) || depth > config.maxDepth) {
    return { content: '', links: [] };
  }

  console.log(`Scraping ${pageUrl} (depth: ${depth})`);
  config.visitedUrls.add(pageUrl);

  try {
    const response = await axios.get(pageUrl, {
      headers: {
        'User-Agent': config.userAgent,
      },
      timeout: 30000
    });

    const $ = cheerio.load(response.data);
    
    // Extract page title
    const pageTitle = $('title').text() || $('h1').first().text() || 'Unknown Page';
    
    // Prepare content container
    let htmlContent = `<h1>${pageTitle}</h1>\n`;
    
    // Get the main content area - this selector might need adjustment based on the site structure
    const mainContent = $('main, .main-content, article, .content, body').first();
    
    if (mainContent.length) {
      htmlContent += mainContent.html();
    } else {
      htmlContent += $('body').html();
    }
    
    // Convert HTML to markdown
    let markdownContent = turndownService.turndown(htmlContent);
    markdownContent = `# ${pageTitle}\n\nURL: ${pageUrl}\n\n${markdownContent}\n\n---\n\n`;
    
    // Find all links on the page
    const links = [];
    $('a').each((i, element) => {
      const href = $(element).attr('href');
      if (href) {
        const normalizedLink = normalizeUrl(href, pageUrl);
        if (normalizedLink && normalizedLink.includes('cfish.io')) {
          links.push(normalizedLink);
        }
      }
    });
    
    return { content: markdownContent, links };
  } catch (error) {
    console.error(`Error scraping ${pageUrl}:`, error.message);
    return { content: `# Error Scraping ${pageUrl}\n\nFailed to scrape this page due to: ${error.message}\n\n`, links: [] };
  }
}

// Main function to start scraping
async function startScraping() {
  console.log('Starting web scraping process...');
  let allContent = '# cFish.io Website Content\n\n';

  try {
    // Create a queue for BFS traversal
    const queue = [{ url: config.startUrl, depth: 0 }];
    
    while (queue.length > 0) {
      const { url: currentUrl, depth } = queue.shift();
      
      const result = await scrapePage(currentUrl, depth);
      allContent += result.content;
      
      // Add unvisited links to the queue
      if (depth < config.maxDepth) {
        for (const link of result.links) {
          if (!config.visitedUrls.has(link)) {
            queue.push({ url: link, depth: depth + 1 });
          }
        }
      }
    }
    
    // Write the content to the output file
    fs.writeFileSync(config.outputFile, allContent);
    console.log(`Scraping completed. Content saved to ${config.outputFile}`);
  } catch (error) {
    console.error('Error during scraping process:', error);
  }
}

// Run the scraper
startScraping(); 