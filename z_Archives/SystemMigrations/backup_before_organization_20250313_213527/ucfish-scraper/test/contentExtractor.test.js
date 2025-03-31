/**
 * Content Extractor Module Tests
 *
 * @package ucfish-scraper
 * @since 1.0.0
 */

const path = require('path');
const fs = require('fs-extra');
const ContentExtractor = require('../src/contentExtractor');

// Mock dependencies
jest.mock('fs-extra', () => ({
  ensureDirSync: jest.fn(),
  existsSync: jest.fn().mockReturnValue(true),
  readJsonSync: jest.fn().mockReturnValue({
    default: {
      content: '.custom-content',
      title: '.custom-title',
      unwanted: '.custom-unwanted'
    },
    site_specific: {
      'example.com': {
        content: '.example-content',
        title: '.example-title'
      }
    },
    url_patterns: [
      {
        pattern: '/blog/',
        selectors: {
          content: '.blog-content',
          title: '.blog-title'
        }
      }
    ],
    special_cases: {
      paywall: {
        detection: '.paywall',
        action: 'skip'
      }
    }
  })
}));

// Mock HTML content
const sampleHtml = `
<!DOCTYPE html>
<html>
<head>
  <title>Page Title</title>
  <meta name="author" content="John Doe">
</head>
<body>
  <article class="custom-content">
    <h1 class="custom-title">Article Title</h1>
    <div class="date">2025-05-15</div>
    <div class="author">John Doe</div>
    <div class="content">
      <p>This is the main content.</p>
      <p>More paragraphs here.</p>
    </div>
    <div class="tags">
      <a href="/tags/sample">sample</a>
      <a href="/tags/test">test</a>
    </div>
  </article>
  <div class="custom-unwanted">
    <p>This should be removed.</p>
  </div>
</body>
</html>
`;

const exampleSiteHtml = `
<!DOCTYPE html>
<html>
<head>
  <title>Example.com Page</title>
</head>
<body>
  <div class="example-content">
    <h1 class="example-title">Example Title</h1>
    <p>Example content.</p>
  </div>
</body>
</html>
`;

const blogPageHtml = `
<!DOCTYPE html>
<html>
<head>
  <title>Blog Post</title>
</head>
<body>
  <div class="blog-content">
    <h1 class="blog-title">Blog Post Title</h1>
    <p>Blog content.</p>
  </div>
</body>
</html>
`;

const paywallHtml = `
<!DOCTYPE html>
<html>
<head>
  <title>Premium Content</title>
</head>
<body>
  <div class="content">
    <h1>Premium Article</h1>
    <p>This is a preview.</p>
    <div class="paywall">
      <p>Subscribe to read the full article.</p>
    </div>
  </div>
</body>
</html>
`;

describe('ContentExtractor', () => {
  let extractor;
  
  beforeEach(() => {
    jest.clearAllMocks();
    
    extractor = new ContentExtractor({
      outputDir: '/tmp/output',
      logDir: '/tmp/logs'
    });
  });
  
  afterAll(() => {
    jest.restoreAllMocks();
  });
  
  test('constructor loads custom selectors', () => {
    expect(fs.existsSync).toHaveBeenCalledWith(expect.stringContaining('selectors.json'));
    expect(fs.readJsonSync).toHaveBeenCalled();
    expect(extractor.selectors).toBeDefined();
    expect(extractor.defaultSelectors).toHaveProperty('content', '.custom-content');
  });
  
  test('getSelectorsForUrl returns default selectors for normal URLs', () => {
    const selectors = extractor.getSelectorsForUrl('https://unknown-site.com/page');
    
    expect(selectors).toHaveProperty('content', '.custom-content');
    expect(selectors).toHaveProperty('title', '.custom-title');
  });
  
  test('getSelectorsForUrl returns site-specific selectors', () => {
    const selectors = extractor.getSelectorsForUrl('https://example.com/page');
    
    expect(selectors).toHaveProperty('content', '.example-content');
    expect(selectors).toHaveProperty('title', '.example-title');
  });
  
  test('getSelectorsForUrl returns URL pattern selectors', () => {
    const selectors = extractor.getSelectorsForUrl('https://any-site.com/blog/post');
    
    expect(selectors).toHaveProperty('content', '.blog-content');
    expect(selectors).toHaveProperty('title', '.blog-title');
  });
  
  test('extract extracts content using custom selectors', async () => {
    const result = await extractor.extract(sampleHtml, 'https://test.com/page');
    
    expect(result).toHaveProperty('content');
    expect(result).toHaveProperty('metadata');
    expect(result.metadata).toHaveProperty('title', 'Article Title');
    expect(result.content).not.toContain('This should be removed');
  });
  
  test('extract uses site-specific selectors', async () => {
    const result = await extractor.extract(exampleSiteHtml, 'https://example.com/page');
    
    expect(result).toHaveProperty('content');
    expect(result.metadata).toHaveProperty('title', 'Example Title');
  });
  
  test('extract uses URL pattern selectors', async () => {
    const result = await extractor.extract(blogPageHtml, 'https://any-site.com/blog/post');
    
    expect(result).toHaveProperty('content');
    expect(result.metadata).toHaveProperty('title', 'Blog Post Title');
  });
  
  test('extract handles special cases', async () => {
    const result = await extractor.extract(paywallHtml, 'https://premium-site.com/article');
    
    expect(result).toHaveProperty('metadata');
    expect(result.metadata).toHaveProperty('skipped', true);
    expect(result.metadata).toHaveProperty('reason', expect.stringContaining('paywall'));
  });
  
  test('extractMultiplePages combines content from multiple pages', async () => {
    const pages = [
      { html: sampleHtml, url: 'https://test.com/page/1' },
      { html: sampleHtml, url: 'https://test.com/page/2' }
    ];
    
    const result = await extractor.extractMultiplePages(pages);
    
    expect(result).toHaveProperty('content');
    expect(result).toHaveProperty('metadata');
    expect(result.metadata).toHaveProperty('multipage', true);
    expect(result.metadata).toHaveProperty('pageCount', 2);
    expect(result.metadata).toHaveProperty('urls');
    expect(result.metadata.urls).toHaveLength(2);
  });
}); 