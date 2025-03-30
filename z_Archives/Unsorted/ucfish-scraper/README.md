# UcFish Web Scraper & Markdown Converter

A comprehensive web scraping and content conversion tool designed to extract content from the UcFish website and convert it to well-structured Markdown files.

## Features

- **Intelligent URL Discovery**: Crawls websites to discover and filter relevant URLs
- **Content Extraction**: Extracts meaningful content from HTML pages
- **Markdown Conversion**: Converts HTML content to clean, well-formatted Markdown
- **Metadata Extraction**: Extracts and preserves metadata from web pages
- **Content Verification**: Validates the quality and completeness of extracted content
- **Content Merging**: Combines related content to reduce fragmentation
- **Progress Monitoring**: Tracks and reports on scraping progress
- **Resumable Operations**: Supports resuming interrupted scraping sessions
- **Configurable Behavior**: Extensive configuration options for customization

## Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/ucfish-scraper.git
cd ucfish-scraper

# Install dependencies
npm install

# Link for global CLI usage (optional)
npm link
```

## Usage

### Command Line Interface

The scraper provides a comprehensive CLI for various operations:

#### Scraping a Website

```bash
ucfish-scraper scrape --url https://example.com --depth 3 --output ./output
```

Options:
- `--url`: Starting URL to scrape (required)
- `--depth`: Maximum depth to crawl (default: 3)
- `--output`: Output directory (default: ./output)
- `--concurrency`: Maximum concurrent requests (default: 2)
- `--delay`: Delay between requests in milliseconds (default: 2000)
- `--no-resume`: Disable resuming from checkpoint
- `--no-verify`: Disable verification of output
- `--no-merge`: Disable merging of related content

#### Verifying Content

```bash
ucfish-scraper verify --input ./output --report verification_report.json
```

Options:
- `--input`: Input directory containing markdown and HTML files (required)
- `--report`: Path to save verification report (default: verification_report.json)

#### Merging Related Content

```bash
ucfish-scraper merge --input ./output --threshold 0.6 --output ./merged
```

Options:
- `--input`: Input directory containing markdown files (required)
- `--threshold`: Similarity threshold (0-1) (default: 0.6)
- `--output`: Output directory for merged content (default: ./merged)

#### Generating a Summary

```bash
ucfish-scraper summarize --input ./output --output summary.md
```

Options:
- `--input`: Input directory containing markdown files (required)
- `--output`: Output file for summary (required)

#### Resuming a Scrape

```bash
ucfish-scraper resume --output ./output
```

Options:
- `--output`: Output directory containing checkpoint (default: ./output)

### Programmatic Usage

The scraper can also be used programmatically in your Node.js applications:

```javascript
const ucfishScraper = require('ucfish-scraper');

// Create a scraper instance
const scraper = ucfishScraper.createScraper({
  baseUrl: 'https://example.com',
  maxDepth: 3,
  outputDir: './output',
  concurrency: 2,
  requestDelay: 2000
});

// Run the scraper
async function run() {
  try {
    const result = await scraper.start({
      startUrl: 'https://example.com',
      resume: true
    });
    
    console.log('Scraping complete!');
    console.log(`Processed URLs: ${result.statistics.processed}`);
    console.log(`Success rate: ${result.statistics.successRate}%`);
  } catch (error) {
    console.error('Error running scraper:', error);
  }
}

run();
```

## Configuration

The scraper can be configured through environment variables or a `.env` file in the `config` directory:

```
# Base configuration
BASE_URL=https://example.com
MAX_DEPTH=3
OUTPUT_DIR=./output

# Request configuration
MAX_CONCURRENT_SCRAPES=2
REQUEST_DELAY=2000
REQUEST_TIMEOUT=30000
MAX_RETRIES=3

# Content processing
MIN_CONTENT_LENGTH=100
SIMILARITY_THRESHOLD=0.6

# Feature toggles
ENABLE_VERIFICATION=true
ENABLE_CONTENT_MERGING=true
ENABLE_RESUMABLE=true
```

## Project Structure

```
ucfish-scraper/
├── config/                 # Configuration files
│   └── .env                # Environment variables
├── output/                 # Default output directory
├── src/                    # Source code
│   ├── cli.js              # Command-line interface
│   ├── contentExtractor.js # HTML content extraction
│   ├── contentMerger.js    # Related content merging
│   ├── contentProcessor.js # Content processing pipeline
│   ├── contentVerifier.js  # Content quality verification
│   ├── index.js            # Main entry point
│   ├── markdownConverter.js # HTML to Markdown conversion
│   ├── metadataExtractor.js # Metadata extraction
│   ├── metadataStore.js    # Metadata storage and management
│   ├── progressMonitor.js  # Progress tracking and reporting
│   ├── requestManager.js   # HTTP request handling
│   ├── scraper.js          # Main scraper orchestration
│   └── urlDiscovery.js     # URL discovery and filtering
├── package.json            # Project metadata and dependencies
└── README.md               # Project documentation
```

## Development

### Prerequisites

- Node.js 14.x or higher
- npm 6.x or higher

### Setup for Development

```bash
# Clone the repository
git clone https://github.com/yourusername/ucfish-scraper.git
cd ucfish-scraper

# Install dependencies
npm install

# Run tests
npm test
```

### Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- [Cheerio](https://github.com/cheeriojs/cheerio) for HTML parsing
- [Turndown](https://github.com/domchristie/turndown) for HTML to Markdown conversion
- [Commander.js](https://github.com/tj/commander.js) for CLI functionality 