# WordPress Token Management Tools

A comprehensive toolkit for tracking, logging, and optimizing token usage in WordPress development projects when working with AI models. This system helps maintain efficient token usage, optimize prompts, and manage token budgets across projects.

## Key Components

- `token-tracker.js`: Core token estimation and tracking class
- `token-logger.js`: Advanced token usage logging and analysis
- `index.js`: Main entry point for token management utilities
- `package.json`: Dependencies and scripts for token management

## Features

### Token Tracking

- Accurate token estimation for text, code, and mixed content
- Session-based token tracking for inputs and outputs
- Real-time budget monitoring with configurable thresholds
- Task-specific token budgets based on type and complexity

### Token Logging

- Historical token usage logging across projects and sessions
- Detailed metrics on input/output token ratios
- Project-level token usage analysis and trends
- Monthly usage tracking and visualization

### Reporting and Analysis

- Comprehensive session reports with detailed metrics
- Token usage optimization recommendations
- Project-level analytics with performance trends
- Cross-project comparisons and benchmarks

### Optimization Strategies

- Task-specific token optimization recommendations
- WordPress-specific token efficiency guidelines
- Content type-based optimization approaches
- Prompt template optimization suggestions

## Installation

```bash
cd .cursor/token-management
npm install
```

## Usage

### Basic Token Tracking

```javascript
const { createTracker } = require('./index');

// Create a tracker instance
const tracker = createTracker();

// Start a session
tracker.startSession('Feature Implementation', 'WooCommerce Extension', 'Code Implementation', 'Medium');

// Track inputs and outputs
tracker.trackInput('I need to implement a custom product field in WooCommerce.', 'text');
tracker.trackOutput('I can help with that. Here\'s a code implementation...', 'text');

// Generate a report
const report = tracker.generateReport();
console.log(report);

// End the session
tracker.endSession();
```

### Advanced Token Logging

```javascript
const { createLogger } = require('./index');

// Create a logger instance
const logger = createLogger();

// Start a session and track tokens
logger.startSession('Performance Optimization', 'WordPress Theme', 'Theme Development', 'High');

// Track inputs and outputs throughout development
logger.trackInput('...large code block...', 'code');
logger.trackOutput('...optimized code...', 'code');

// End session and generate analytics
logger.endSession();
const projectReport = logger.generateProjectReport('WordPress Theme');
logger.generateHtmlReport('theme-optimization-report.html');
```

## Token Budget Guidelines

| Task Type             | Low Complexity | Medium Complexity | High Complexity |
|-----------------------|----------------|-------------------|-----------------|
| Architecture Planning | 4,000 tokens   | 8,000 tokens      | 14,000 tokens   |
| Code Implementation   | 5,000 tokens   | 10,000 tokens     | 18,000 tokens   |
| Theme Development     | 5,000 tokens   | 10,000 tokens     | 18,000 tokens   |
| Security Review       | 4,000 tokens   | 7,000 tokens      | 13,000 tokens   |
| Documentation         | 3,000 tokens   | 6,000 tokens      | 12,000 tokens   |
| Plugin Integration    | 4,000 tokens   | 7,000 tokens      | 11,000 tokens   |

## Token Optimization Tips

1. Use structured prompt templates for common tasks
2. Break complex prompts into smaller, focused components
3. Leverage existing code patterns instead of generating from scratch
4. Focus on specific functionality rather than entire components
5. Use references to documentation instead of explaining basics
6. Provide context efficiently with minimal repetition
7. Use code examples sparingly and with purpose

## Reporting

The token management tools can generate several types of reports:

- **Session Reports**: Detailed metrics for individual development sessions
- **Project Reports**: Aggregated data across all sessions for a project
- **Monthly Trends**: Token usage patterns over time
- **HTML Reports**: Visual reports with charts and graphs

## Maintenance

These tools should be updated when:

- New AI models with different token calculation methods are used
- Project requirements change significantly
- New WordPress development patterns emerge
- Additional optimization strategies are identified

## Related Resources

- `../agent-configs/`: Agent configuration files and prompt templates
- `../../memory.md`: Project memory with implementation history
- `../../changelog.md`: Version history with recent changes 