/**
 * URL Discovery Module Tests
 *
 * @package ucfish-scraper
 * @since 1.0.0
 */

const path = require('path');
const fs = require('fs-extra');
const { jest: jestObject } = require('@jest/globals');
const UrlDiscovery = require('../src/urlDiscovery');

// Mock dependencies
jest.mock('playwright', () => ({
  chromium: {
    launch: jest.fn().mockResolvedValue({
      newContext: jest.fn().mockResolvedValue({
        newPage: jest.fn().mockResolvedValue({
          goto: jest.fn().mockResolvedValue(),
          waitForSelector: jest.fn().mockResolvedValue(),
          evaluate: jest.fn().mockResolvedValue([
            'https://example.com/',
            'https://example.com/page1',
            'https://example.com/page2',
            'https://external.com/page'
          ]),
          close: jest.fn().mockResolvedValue()
        })
      }),
      close: jest.fn().mockResolvedValue()
    })
  }
}));

jest.mock('fs-extra', () => ({
  ensureDirSync: jest.fn(),
  writeJson: jest.fn().mockResolvedValue(),
  readJson: jest.fn().mockResolvedValue({
    urls: [
      { url: 'https://example.com/', depth: 0, parent: null },
      { url: 'https://example.com/page1', depth: 1, parent: 'https://example.com/' }
    ]
  }),
  pathExists: jest.fn().mockResolvedValue(true)
}));

jest.mock('dotenv', () => ({
  config: jest.fn()
}));

describe('UrlDiscovery', () => {
  let urlDiscovery;
  const tempDir = path.join(__dirname, 'temp');
  
  beforeEach(() => {
    jest.clearAllMocks();
    jest.useFakeTimers();
    
    urlDiscovery = new UrlDiscovery({
      baseUrl: 'https://example.com/',
      maxDepth: 2,
      outputDir: tempDir,
      urlsFile: path.join(tempDir, 'urls.json')
    });
  });
  
  afterEach(() => {
    jest.useRealTimers();
  });
  
  afterAll(() => {
    jest.restoreAllMocks();
  });
  
  test('constructor initializes with default parameters', () => {
    const defaultUrlDiscovery = new UrlDiscovery();
    
    expect(defaultUrlDiscovery.baseUrl).toBe('');
    expect(defaultUrlDiscovery.maxDepth).toBe(3);
    expect(defaultUrlDiscovery.outputDir).toContain('output');
    expect(defaultUrlDiscovery.discoveredUrls).toBeInstanceOf(Map);
    expect(defaultUrlDiscovery.queuedUrls).toBeInstanceOf(Set);
    expect(defaultUrlDiscovery.processedUrls).toBeInstanceOf(Set);
  });
  
  test('constructor initializes with custom parameters', () => {
    expect(urlDiscovery.baseUrl).toBe('https://example.com/');
    expect(urlDiscovery.maxDepth).toBe(2);
    expect(urlDiscovery.outputDir).toBe(tempDir);
    expect(urlDiscovery.urlsFile).toBe(path.join(tempDir, 'urls.json'));
  });
  
  test('initBrowser initializes browser and context', async () => {
    await urlDiscovery.initBrowser();
    
    expect(require('playwright').chromium.launch).toHaveBeenCalledWith({
      headless: expect.any(Boolean)
    });
    
    expect(urlDiscovery.browser.newContext).toHaveBeenCalledWith({
      userAgent: expect.any(String),
      viewport: { width: 1920, height: 1080 }
    });
  });
  
  test('isInternalUrl identifies internal URLs correctly', () => {
    expect(urlDiscovery.isInternalUrl('https://example.com/page1')).toBe(true);
    expect(urlDiscovery.isInternalUrl('https://example.com/page2?id=123')).toBe(true);
    expect(urlDiscovery.isInternalUrl('https://other-domain.com/page')).toBe(false);
    expect(urlDiscovery.isInternalUrl('invalid-url')).toBe(false);
  });
  
  test('normalizeUrl removes trailing slashes and normalizes URL', () => {
    expect(urlDiscovery.normalizeUrl('https://example.com/')).toBe('https://example.com/');
    expect(urlDiscovery.normalizeUrl('https://example.com/page/')).toBe('https://example.com/page');
    expect(urlDiscovery.normalizeUrl('https://example.com/page?utm_source=test')).toBe('https://example.com/page');
    expect(urlDiscovery.normalizeUrl('https://example.com/page?id=123&utm_source=test')).toBe('https://example.com/page?id=123');
  });
  
  test('discoverLinksOnPage discovers and filters links', async () => {
    // Initialize browser first
    await urlDiscovery.initBrowser();
    
    const links = await urlDiscovery.discoverLinksOnPage('https://example.com/', 0);
    
    expect(links).toContain('https://example.com/');
    expect(links).toContain('https://example.com/page1');
    expect(links).toContain('https://example.com/page2');
    expect(links).not.toContain('https://external.com/page');
  });
  
  test('discoverUrls performs breadth-first traversal', async () => {
    // Setup mocks for discoverUrls
    await urlDiscovery.initBrowser();
    
    // Spy on discoverLinksOnPage and mock its implementation
    const mockDiscoverLinksOnPage = jest.spyOn(urlDiscovery, 'discoverLinksOnPage')
      .mockImplementation((url) => {
        if (url === 'https://example.com/') {
          return Promise.resolve([
            'https://example.com/page1',
            'https://example.com/page2'
          ]);
        }
        return Promise.resolve([]);
      });
    
    // Mock the delay function to make test run faster
    jest.spyOn(global, 'setTimeout').mockImplementation(cb => cb());
    
    const result = await urlDiscovery.discoverUrls();
    
    expect(mockDiscoverLinksOnPage).toHaveBeenCalledWith(
      'https://example.com/',  // Note the trailing slash
      0  // The depth should be 0 for the base URL
    );
    expect(result).toBeInstanceOf(Map);
    expect(result.has('https://example.com/')).toBe(true);
    expect(result.has('https://example.com/page1')).toBe(true);
    expect(result.has('https://example.com/page2')).toBe(true);
    expect(fs.writeJson).toHaveBeenCalled();
    
    mockDiscoverLinksOnPage.mockRestore();
  }, 10000); // Increase timeout for this test
  
  test('saveDiscoveredUrls writes URLs to file', async () => {
    urlDiscovery.discoveredUrls.set('https://example.com/', {
      url: 'https://example.com/',
      depth: 0,
      parent: null
    });
    
    await urlDiscovery.saveDiscoveredUrls();
    
    expect(fs.writeJson).toHaveBeenCalledWith(
      urlDiscovery.urlsFile,
      expect.objectContaining({
        baseUrl: 'https://example.com/',
        maxDepth: 2,
        urls: [{ url: 'https://example.com/', depth: 0, parent: null }]
      }),
      { spaces: 2 }
    );
  });
  
  test('loadDiscoveredUrls loads URLs from file', async () => {
    await urlDiscovery.loadDiscoveredUrls();
    
    expect(fs.pathExists).toHaveBeenCalledWith(urlDiscovery.urlsFile);
    expect(fs.readJson).toHaveBeenCalledWith(urlDiscovery.urlsFile);
    expect(urlDiscovery.discoveredUrls.size).toBe(2);
    expect(urlDiscovery.discoveredUrls.has('https://example.com/')).toBe(true);
    expect(urlDiscovery.discoveredUrls.has('https://example.com/page1')).toBe(true);
  });
}); 