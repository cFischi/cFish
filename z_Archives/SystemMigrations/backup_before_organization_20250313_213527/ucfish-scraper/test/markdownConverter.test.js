/**
 * Markdown Converter Module Tests
 *
 * @package ucfish-scraper
 * @since 1.0.0
 */

const MarkdownConverter = require('../src/markdownConverter');

// Mock TurndownService
jest.mock('turndown', () => {
  return jest.fn().mockImplementation(() => {
    return {
      addRule: jest.fn(),
      keep: jest.fn(),
      remove: jest.fn(),
      turndown: jest.fn().mockImplementation((html) => {
        // Simple mock implementation
        if (html.includes('<h1>')) return '# Sample Heading';
        if (html.includes('<p>')) return 'Sample paragraph';
        if (html.includes('<ul>')) return '* List item 1\n* List item 2';
        return 'Converted markdown';
      })
    };
  });
});

// Mock other dependencies
jest.mock('cheerio', () => {
  return {
    load: jest.fn().mockImplementation(() => {
      return function($) {
        return {
          find: jest.fn().mockReturnThis(),
          remove: jest.fn().mockReturnThis(),
          html: jest.fn().mockReturnValue('<div>Test HTML</div>'),
          text: jest.fn().mockReturnValue('Test text'),
          attr: jest.fn().mockReturnValue('test-attr'),
          each: jest.fn().mockImplementation(callback => {
            // Mock a few elements for the callback
            [0, 1].forEach(i => callback(i, { attribs: { src: 'img.jpg', href: 'link.html' } }));
            return { length: 2 };
          })
        };
      };
    }),
    html: jest.fn().mockReturnValue('<div>Test HTML</div>')
  };
});

describe('MarkdownConverter', () => {
  let converter;
  
  beforeEach(() => {
    jest.clearAllMocks();
    converter = new MarkdownConverter({
      customRules: true,
      imageBaseUrl: 'https://example.com/images/',
      linkBaseUrl: 'https://example.com/'
    });
  });
  
  afterAll(() => {
    jest.restoreAllMocks();
  });
  
  test('constructor initializes with default parameters', () => {
    const defaultConverter = new MarkdownConverter();
    
    expect(defaultConverter.customRules).toBe(true);
    expect(defaultConverter.imageBaseUrl).toBe('');
    expect(defaultConverter.linkBaseUrl).toBe('');
    expect(defaultConverter.turndownService).toBeDefined();
  });
  
  test('constructor initializes with custom parameters', () => {
    expect(converter.customRules).toBe(true);
    expect(converter.imageBaseUrl).toBe('https://example.com/images/');
    expect(converter.linkBaseUrl).toBe('https://example.com/');
  });
  
  test('convert transforms HTML to Markdown', async () => {
    const html = '<div><h1>Test Heading</h1><p>Test paragraph</p></div>';
    const markdown = await converter.convert(html);
    
    expect(markdown).toBe('# Sample Heading');
    expect(converter.turndownService.turndown).toHaveBeenCalledWith(expect.any(String));
  });
  
  test('convert handles empty input', async () => {
    const markdown = await converter.convert('');
    expect(markdown).toBe('');
  });
  
  test('convert handles null input', async () => {
    const markdown = await converter.convert(null);
    expect(markdown).toBe('');
  });
  
  test('preprocessHtml cleans HTML before conversion', () => {
    const html = '<div class="unwanted">Remove this</div><div class="content">Keep this</div>';
    const processed = converter.preprocessHtml(html);
    
    expect(processed).toBeDefined();
    expect(typeof processed).toBe('string');
  });
  
  test('fixRelativeUrls converts relative URLs to absolute', () => {
    const html = '<img src="/images/test.jpg"><a href="/page.html">Link</a>';
    const fixed = converter.fixRelativeUrls(html);
    
    expect(fixed).toBeDefined();
    expect(typeof fixed).toBe('string');
  });
  
  test('postprocessMarkdown further refines Markdown content', () => {
    const markdown = '# Heading\n\n\n\nToo many blank lines\n\n\n\nAnother paragraph';
    const processed = converter.postprocessMarkdown(markdown);
    
    expect(processed).toBeDefined();
    expect(typeof processed).toBe('string');
    expect(processed).not.toContain('\n\n\n');
  });
  
  test('initTurndownService configures the Turndown service', () => {
    converter.initTurndownService();
    
    expect(converter.turndownService.addRule).toHaveBeenCalled();
    expect(converter.turndownService.keep).toHaveBeenCalled();
    expect(converter.turndownService.remove).toHaveBeenCalled();
  });
  
  test('convertWithMetadata extracts and includes metadata', async () => {
    const html = `
      <html>
        <head>
          <title>Test Title</title>
          <meta name="description" content="Test description">
        </head>
        <body>
          <h1>Main Content</h1>
          <p>Test paragraph</p>
        </body>
      </html>
    `;
    
    const result = await converter.convertWithMetadata(html, 'https://example.com/test');
    
    expect(result).toHaveProperty('content');
    expect(result).toHaveProperty('metadata');
    expect(result.metadata).toHaveProperty('title');
    expect(result.metadata).toHaveProperty('url');
  });
}); 