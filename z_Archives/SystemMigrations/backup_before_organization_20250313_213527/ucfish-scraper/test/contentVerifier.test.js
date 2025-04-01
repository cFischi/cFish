/**
 * Content Verifier Module Tests
 *
 * @package ucfish-scraper
 * @since 1.0.0
 */

const ContentVerifier = require('../src/contentVerifier');

// Mock natural module
jest.mock('natural', () => {
  return {
    WordTokenizer: jest.fn().mockImplementation(() => ({
      tokenize: jest.fn().mockReturnValue(['sample', 'test', 'content', 'words', 'keywords'])
    })),
    PorterStemmer: {
      stem: jest.fn().mockImplementation(word => word.slice(0, word.length - 1))
    },
    TfIdf: jest.fn().mockImplementation(() => ({
      addDocument: jest.fn(),
      listTerms: jest.fn().mockReturnValue([
        { term: 'test', tfidf: 0.5 },
        { term: 'content', tfidf: 0.3 }
      ])
    })),
    Spellcheck: jest.fn().mockImplementation(() => ({
      isCorrect: jest.fn().mockImplementation(word => word !== 'wrrongword')
    }))
  };
});

// Mock JSDOM
jest.mock('jsdom', () => {
  return {
    JSDOM: jest.fn().mockImplementation(() => ({
      window: {
        document: {
          body: {
            textContent: 'Sample test content with multiple words and sentences. This is a second sentence for testing purposes.'
          }
        }
      }
    }))
  };
});

// Mock HTML content for testing
const goodHtmlContent = `
<!DOCTYPE html>
<html>
<head>
  <title>Test Article</title>
</head>
<body>
  <article>
    <h1>Sample Article Title</h1>
    <p>This is a paragraph with some content.</p>
    <p>This is another paragraph with different content.</p>
    <p>Third paragraph for good measure.</p>
    <ul>
      <li>List item 1</li>
      <li>List item 2</li>
    </ul>
    <img src="test.jpg" alt="Test Image">
    <pre><code>function testCode() { return true; }</code></pre>
  </article>
</body>
</html>
`;

const badHtmlContent = `
<!DOCTYPE html>
<html>
<head>
  <title>Error Page</title>
</head>
<body>
  <div>
    <h1>404 Not Found</h1>
    <p>The page you requested cannot be found.</p>
    <p>Sorry for the inconvenience.</p>
    <p class="sponsored">ADVERTISEMENT: Buy now! Limited time offer!</p>
    <a href="ad1.html">Click here</a>
    <a href="ad2.html">Click here</a>
    <a href="ad3.html">Click here</a>
    <a href="ad4.html">Click here</a>
    <a href="ad5.html">Click here</a>
  </div>
</body>
</html>
`;

describe('ContentVerifier', () => {
  let verifier;
  
  beforeEach(() => {
    jest.clearAllMocks();
    
    verifier = new ContentVerifier({
      minContentLength: 100,
      minHeadingCount: 1,
      minParagraphCount: 2,
      spellingCheck: true
    });
  });
  
  afterAll(() => {
    jest.restoreAllMocks();
  });
  
  test('constructor initializes with default parameters', () => {
    const defaultVerifier = new ContentVerifier();
    
    expect(defaultVerifier.minContentLength).toBe(200);
    expect(defaultVerifier.errorPatterns).toContain('404');
    expect(defaultVerifier.spellingCheck).toBeTruthy();
    expect(defaultVerifier.tfidf).toBeDefined();
    expect(defaultVerifier.tokenizer).toBeDefined();
    expect(defaultVerifier.stemmer).toBeDefined();
  });
  
  test('constructor initializes with custom parameters', () => {
    expect(verifier.minContentLength).toBe(100);
    expect(verifier.minHeadingCount).toBe(1);
    expect(verifier.minParagraphCount).toBe(2);
  });
  
  test('verify returns valid result for good content', async () => {
    const content = { content: goodHtmlContent, metadata: { url: 'https://example.com/article' } };
    const result = await verifier.verify(content);
    
    expect(result).toHaveProperty('valid');
    expect(result).toHaveProperty('score');
    expect(result).toHaveProperty('metrics');
    expect(result.valid).toBe(true);
    expect(result.score).toBeGreaterThan(50);
  });
  
  test('verify returns invalid result for bad content', async () => {
    const content = { content: badHtmlContent, metadata: { url: 'https://example.com/error' } };
    const result = await verifier.verify(content);
    
    expect(result).toHaveProperty('valid');
    expect(result).toHaveProperty('score');
    expect(result).toHaveProperty('metrics');
    expect(result.valid).toBe(false);
    expect(result.issues.length).toBeGreaterThan(0);
    expect(result.issues).toContain('Error patterns detected');
  });
  
  test('verify handles empty content', async () => {
    const content = { content: '', metadata: { url: 'https://example.com/empty' } };
    const result = await verifier.verify(content);
    
    expect(result.valid).toBe(false);
    expect(result.score).toBe(0);
    expect(result.reason).toContain('Empty content');
  });
  
  test('checkContentLength returns appropriate scores', () => {
    const shortContent = 'a'.repeat(50);
    const mediumContent = 'a'.repeat(150);
    const longContent = 'a'.repeat(500);
    
    const shortResult = verifier.checkContentLength(shortContent);
    const mediumResult = verifier.checkContentLength(mediumContent);
    const longResult = verifier.checkContentLength(longContent);
    
    expect(shortResult.score).toBe(0);
    expect(shortResult.issue).toBeDefined();
    expect(mediumResult.score).toBe(5);
    expect(longResult.score).toBe(10);
  });
  
  test('checkErrorPatterns detects error content', () => {
    const errorContent = 'This page cannot be found';
    const normalContent = 'This is normal content without errors';
    
    const errorResult = verifier.checkErrorPatterns(errorContent);
    const normalResult = verifier.checkErrorPatterns(normalContent);
    
    expect(errorResult.patterns.length).toBeGreaterThan(0);
    expect(errorResult.score).toBeLessThan(normalResult.score);
    expect(normalResult.patterns.length).toBe(0);
    expect(normalResult.score).toBe(10);
  });
  
  test('checkStructure analyzes HTML structure', () => {
    const structureResult = verifier.checkStructure(goodHtmlContent);
    
    expect(structureResult).toHaveProperty('headings');
    expect(structureResult).toHaveProperty('paragraphs');
    expect(structureResult).toHaveProperty('lists');
    expect(structureResult).toHaveProperty('images');
    expect(structureResult.headings).toBe(1);
    expect(structureResult.paragraphs).toBe(3);
    expect(structureResult.lists).toBe(1);
    expect(structureResult.images).toBe(1);
    expect(structureResult.score).toBeGreaterThan(0);
  });
  
  test('checkReadability calculates readability metrics', () => {
    const readabilityResult = verifier.checkReadability(goodHtmlContent);
    
    expect(readabilityResult).toHaveProperty('fleschScore');
    expect(readabilityResult).toHaveProperty('fogIndex');
    expect(readabilityResult).toHaveProperty('avgSentenceLength');
    expect(readabilityResult).toHaveProperty('avgWordLength');
    expect(typeof readabilityResult.fleschScore).toBe('number');
    expect(typeof readabilityResult.fogIndex).toBe('number');
  });
  
  test('checkLinkDensity detects excessive links', () => {
    const highLinkContent = `
      <div>
        <p>Short content with many links</p>
        <a href="#">Link 1</a>
        <a href="#">Link 2</a>
        <a href="#">Link 3</a>
        <a href="#">Link 4</a>
        <a href="#">Link 5</a>
      </div>
    `;
    
    const normalLinkContent = `
      <div>
        <p>This is a longer paragraph with normal content that has lots of words
        and only a few links to other resources.</p>
        <p>Another paragraph with more content to balance the link ratio.</p>
        <a href="#">Link 1</a>
        <a href="#">Link 2</a>
      </div>
    `;
    
    const highLinkResult = verifier.checkLinkDensity(highLinkContent);
    const normalLinkResult = verifier.checkLinkDensity(normalLinkContent);
    
    expect(highLinkResult.linkCount).toBe(5);
    expect(normalLinkResult.linkCount).toBe(2);
    expect(highLinkResult.linkDensity).toBeGreaterThan(normalLinkResult.linkDensity);
    expect(highLinkResult.score).toBeLessThan(normalLinkResult.score);
  });
  
  test('checkAdvertisingContent detects ad content', () => {
    const adContent = `
      <div>
        <p>Check out our limited time offer!</p>
        <p>Buy now and get a special discount!</p>
        <p>Sponsored content that you might like.</p>
        <p>Click here to see more advertisements.</p>
      </div>
    `;
    
    const normalContent = `
      <div>
        <p>This is a normal article about a topic.</p>
        <p>It contains information without promotional language.</p>
      </div>
    `;
    
    const adResult = verifier.checkAdvertisingContent(adContent);
    const normalResult = verifier.checkAdvertisingContent(normalContent);
    
    expect(adResult.matches.length).toBeGreaterThan(3);
    expect(normalResult.matches.length).toBe(0);
    expect(adResult.score).toBeLessThan(normalResult.score);
  });
  
  test('checkCodeQuality analyzes code blocks', () => {
    const goodCodeContent = `
      <pre><code>
      function calculateSum(a, b) {
        const result = a + b;
        return result;
      }
      
      const total = calculateSum(5, 10);
      console.log(total);
      </code></pre>
    `;
    
    const badCodeContent = `
      <pre><code>
      function bad(){
      no indentation
      missing brackets and semicolons
      }
      </code></pre>
    `;
    
    const goodCodeResult = verifier.checkCodeQuality(goodCodeContent);
    const badCodeResult = verifier.checkCodeQuality(badCodeContent);
    
    expect(goodCodeResult.codeBlocks).toBeGreaterThan(0);
    expect(badCodeResult.codeBlocks).toBeGreaterThan(0);
    expect(goodCodeResult.score).toBeGreaterThanOrEqual(badCodeResult.score);
  });
  
  test('checkFormattingConsistency detects formatting issues', () => {
    const goodFormattingContent = `
      <h1>Well Formatted Article</h1>
      <p>This paragraph follows a heading properly.</p>
      
      <h2>Subsection Title</h2>
      <p>Another well-formatted paragraph with good content.</p>
      
      <h2>Final Section</h2>
      <p>The article maintains consistent formatting throughout.</p>
    `;
    
    const badFormattingContent = `
      <h1>Poorly Formatted Article</h1>
      
      
      
      
      <h2>Empty Heading</h2>
      <h3>Another Heading</h3>
      <h4>Too Many Headings</h4>
      
      
      
      <p>This paragraph has too many empty lines before it.</p>
    `;
    
    const goodFormattingResult = verifier.checkFormattingConsistency(goodFormattingContent);
    const badFormattingResult = verifier.checkFormattingConsistency(badFormattingContent);
    
    expect(goodFormattingResult.issues.length).toBeLessThan(badFormattingResult.issues.length);
    expect(badFormattingResult.issues.length).toBeGreaterThan(0);
    expect(goodFormattingResult.score).toBeGreaterThan(badFormattingResult.score);
  });
  
  test('checkSpelling detects spelling errors', async () => {
    // Mock the HTML content with good spelling
    const goodSpellingContent = `
      <div>
        <p>This is a paragraph with correctly spelled words.</p>
      </div>
    `;
    
    // Mock the HTML content with spelling errors
    const badSpellingContent = `
      <div>
        <p>This parrragraph has wrrongword spelling errors.</p>
      </div>
    `;
    
    const goodSpellingResult = await verifier.checkSpelling(goodSpellingContent);
    const badSpellingResult = await verifier.checkSpelling(badSpellingContent);
    
    expect(goodSpellingResult.errorRatio).toBeLessThan(badSpellingResult.errorRatio);
    expect(goodSpellingResult.score).toBeGreaterThanOrEqual(badSpellingResult.score);
  });
  
  test('verifyBatch handles multiple content items', async () => {
    const contentItems = [
      { content: goodHtmlContent, metadata: { url: 'https://example.com/good' } },
      { content: badHtmlContent, metadata: { url: 'https://example.com/bad' } }
    ];
    
    const result = await verifier.verifyBatch(contentItems);
    
    expect(result).toHaveProperty('total', 2);
    expect(result).toHaveProperty('valid');
    expect(result).toHaveProperty('invalid');
    expect(result).toHaveProperty('averageScore');
    expect(result).toHaveProperty('items');
    expect(result.items).toHaveLength(2);
    expect(result.items[0]).toHaveProperty('url', 'https://example.com/good');
    expect(result.items[1]).toHaveProperty('url', 'https://example.com/bad');
  });
}); 