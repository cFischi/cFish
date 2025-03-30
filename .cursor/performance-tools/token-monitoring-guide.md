# Cursor Token Monitoring System for cFish.io

This guide provides detailed information on using the token monitoring tools for WordPress development at cFish.io. These tools help optimize token usage in Cursor AI interactions, leading to more efficient development workflows.

## Table of Contents

1. [Introduction](#introduction)
2. [Getting Started](#getting-started)
3. [Token Counter](#token-counter)
4. [Token Logger](#token-logger)
5. [Best Practices](#best-practices)
6. [Workflow Integration](#workflow-integration)
7. [Troubleshooting](#troubleshooting)

## Introduction

The Token Monitoring System consists of two primary components:

1. **Token Counter**: Estimates token usage in text, code snippets, and conversations
2. **Token Logger**: Tracks token usage across sessions for analysis and optimization

These tools help:
- Prevent hitting token limits (20,000 tokens) in Cursor
- Optimize prompts for better efficiency
- Track token usage patterns across projects
- Identify opportunities for optimization

## Getting Started

### Installation

The Token Monitoring System is pre-installed in the `.cursor/performance-tools/` directory.

### Quick Start

To quickly estimate tokens in a message:

```javascript
const tokenCounter = require('./.cursor/performance-tools/token-counter');

// Estimate tokens in text
const tokensUsed = tokenCounter.estimateTokens("Your message here");
console.log(`Estimated tokens: ${tokensUsed}`);

// Estimate tokens in code
const codeTokens = tokenCounter.estimateCodeTokens("function example() { return true; }", "javascript");
console.log(`Estimated code tokens: ${codeTokens}`);
```

To track tokens across a session:

```javascript
const tokenLogger = require('./.cursor/performance-tools/token-logger');

// Initialize with default settings
tokenLogger.initialize();

// Start a new session
const sessionId = tokenLogger.startSession("Feature Development");

// Log messages
tokenLogger.logMessage(sessionId, {
  role: "user",
  content: "Implement a WordPress custom post type for projects"
});

// End session and save logs
tokenLogger.endSession(sessionId);
```

## Token Counter

The token counter utility provides functions to estimate token usage in different types of content.

### Key Functions

#### `estimateTokens(text)`

Estimates tokens for a text string using a simple approximation method.

```javascript
const tokenCount = tokenCounter.estimateTokens("How do I create a WordPress plugin?");
console.log(`Estimated tokens: ${tokenCount}`);
```

#### `estimateCodeTokens(code, language)`

Calculates token usage for code blocks with higher accuracy by accounting for programming language syntax.

```javascript
const phpCode = `function my_function() {
  global $wpdb;
  return $wpdb->get_results("SELECT * FROM {$wpdb->posts}");
}`;

const tokenCount = tokenCounter.estimateCodeTokens(phpCode, "php");
console.log(`Estimated PHP code tokens: ${tokenCount}`);
```

Supported languages: `php`, `javascript`, `typescript`, `html`, `css`, `python`, and `generic` (default).

#### `estimateWPFileTokens(fileContent, fileType)`

Estimates tokens for a WordPress theme or plugin file, handling mixed content types.

```javascript
const fileContent = fs.readFileSync('wp-content/themes/mytheme/functions.php', 'utf8');
const tokenCount = tokenCounter.estimateWPFileTokens(fileContent, "theme");
console.log(`Estimated file tokens: ${tokenCount}`);
```

#### `analyzeConversation(messages)`

Analyzes a conversation to provide comprehensive token usage statistics.

```javascript
const messages = [
  { role: "user", content: "Create a WordPress custom post type for projects" },
  { role: "assistant", content: "Here's how to create a custom post type for projects..." }
];

const analysis = tokenCounter.analyzeConversation(messages);
console.log(`Total tokens: ${analysis.totalTokens}`);
console.log(`User tokens: ${analysis.userTokens}`);
console.log(`Assistant tokens: ${analysis.assistantTokens}`);
```

#### `getOptimizationSuggestions(analysis)`

Provides optimization suggestions based on token analysis.

```javascript
const suggestions = tokenCounter.getOptimizationSuggestions(analysis);
suggestions.forEach(suggestion => console.log(`- ${suggestion}`));
```

#### `formatTokenReport(analysis)`

Formats token usage analysis into a readable report.

```javascript
const report = tokenCounter.formatTokenReport(analysis);
console.log(report);
```

## Token Logger

The token logger utility tracks token usage across multiple sessions and provides reporting capabilities.

### Key Functions

#### `initialize(customConfig)`

Initializes the token logger with custom configuration.

```javascript
const config = tokenLogger.initialize({
  projectName: "Client Website Redesign",
  customTags: ["wordpress", "theme-development"]
});
```

Configuration options:
- `logDirectory`: Path to store log files
- `sessionLogFile`: Filename for session logs
- `summaryLogFile`: Filename for summary logs
- `projectName`: Name of the project
- `maxSessionsInMemory`: Maximum number of sessions to keep in memory
- `enableDetailedLogging`: Whether to log detailed message information
- `loggedMessageFields`: Fields to log for each message
- `customTags`: Tags to apply to all sessions

#### `startSession(sessionName, metadata)`

Starts a new token tracking session.

```javascript
const sessionId = tokenLogger.startSession("Homepage Development", {
  tags: ["homepage", "frontend"],
  developer: "John Doe",
  priority: "high"
});
```

#### `logMessage(sessionId, message)`

Logs a message exchange to the active session.

```javascript
tokenLogger.logMessage(sessionId, {
  role: "user",
  content: "Create a responsive hero section for the homepage"
});
```

#### `logConversation(sessionId, messages)`

Logs multiple messages at once.

```javascript
const messages = [
  { role: "user", content: "How do I create a WordPress shortcode?" },
  { role: "assistant", content: "Here's how to create a WordPress shortcode..." }
];

tokenLogger.logConversation(sessionId, messages);
```

#### `endSession(sessionId)`

Ends an active session and persists it to the log file.

```javascript
const finalSession = tokenLogger.endSession(sessionId);
console.log(`Session used ${finalSession.summary.totalTokens} tokens`);
```

#### `getUsageSummary(refresh)`

Retrieves usage summary statistics.

```javascript
const summary = tokenLogger.getUsageSummary();
console.log(`Total sessions: ${summary.totalSessions}`);
console.log(`Total tokens: ${summary.totalTokens}`);
```

#### `generateReport(options)`

Generates a token usage report for a given time period.

```javascript
const report = tokenLogger.generateReport({
  timeframe: 'week',
  format: 'markdown',
  includeSessions: true,
  tags: ['homepage']
});

console.log(report);
```

Report options:
- `timeframe`: 'day', 'week', 'month', or 'all'
- `format`: 'json', 'markdown', or 'html'
- `includeSessions`: Whether to include detailed session data
- `includeMessages`: Whether to include message details
- `tags`: Filter by specific tags

## Best Practices

### Optimizing Token Usage

1. **Be Specific and Concise**
   - Use precise language in prompts
   - Include only necessary context
   - Break complex tasks into smaller, focused requests

2. **Efficient Code References**
   - Reference file paths explicitly instead of pasting entire files
   - Use line number references when discussing specific code sections
   - Only include relevant code snippets in prompts

3. **Context Management**
   - Use the Reference Open Editors feature rather than pasting code
   - Create focused context.md files for project background
   - Open multiple related files at once for context

4. **WordPress-Specific Optimization**
   - Focus requests on specific components (themes, plugins, functions)
   - Reference WordPress Codex using links rather than copying documentation
   - Specify WordPress version and environment when relevant

### Monitoring Workflow

1. **Regular Token Audits**
   - Review token usage reports weekly
   - Identify patterns in high-token conversations
   - Look for optimization opportunities

2. **Team Guidelines**
   - Share optimization tips with the team
   - Establish token budgets for different task types
   - Create a repository of efficient prompt templates

3. **Session Management**
   - Start new sessions for new tasks
   - End sessions properly to ensure data is logged
   - Use descriptive session names and metadata

## Workflow Integration

### Integration with WordPress Development

1. **Theme Development**
   ```javascript
   const sessionId = tokenLogger.startSession("Theme Development", {
     tags: ["wordpress", "theme"]
   });
   
   // Log messages throughout development
   
   // Generate report at the end of the day
   tokenLogger.generateReport({
     timeframe: 'day',
     tags: ['theme']
   });
   ```

2. **Plugin Development**
   ```javascript
   const sessionId = tokenLogger.startSession("Plugin Development", {
     tags: ["wordpress", "plugin", "ecommerce"]
   });
   
   // Log messages throughout development
   
   // Generate report at the end
   const report = tokenLogger.generateReport({
     timeframe: 'day',
     tags: ['plugin']
   });
   ```

### Integration with Agent Workflow

For multi-agent workflows, track token usage across different agent roles:

```javascript
// Start session with Project Architect
const sessionId = tokenLogger.startSession("Feature Planning", {
  tags: ["project-architect"]
});

// Log Project Architect interactions
tokenLogger.logMessage(sessionId, {
  role: "user",
  content: "Plan the implementation of a client dashboard"
});

// When switching to Code Implementation Specialist
tokenLogger.logMessage(sessionId, {
  role: "system",
  content: "Switching to Code Implementation Specialist role"
});

// Continue logging with new agent role
tokenLogger.logMessage(sessionId, {
  role: "user",
  content: "Implement the client dashboard based on the plan"
});
```

## Troubleshooting

### Common Issues

#### Token Estimation Discrepancies

**Issue**: Token estimations differ from actual Cursor usage.

**Solution**: Token estimates are approximations. Adjust your token usage assumptions by applying a safety factor of 10-15%.

```javascript
// Apply a safety factor to estimates
const estimatedTokens = tokenCounter.estimateTokens(text);
const safetyFactor = 1.15; // 15% buffer
const adjustedEstimate = Math.ceil(estimatedTokens * safetyFactor);
```

#### Log Directory Access Issues

**Issue**: Permission errors when writing logs.

**Solution**: The logger will automatically fall back to the system temp directory. Check the console for error messages.

#### High Memory Usage

**Issue**: Processing very large files or conversations causes high memory usage.

**Solution**: Process files or conversations in chunks.

```javascript
// Process a large file in chunks
const fileContent = fs.readFileSync('large-file.php', 'utf8');
const chunkSize = 5000; // characters
const chunks = [];

for (let i = 0; i < fileContent.length; i += chunkSize) {
  const chunk = fileContent.substring(i, i + chunkSize);
  const tokens = tokenCounter.estimateTokens(chunk);
  chunks.push(tokens);
}

const totalTokens = chunks.reduce((sum, tokens) => sum + tokens, 0);
```

### Getting Help

For further assistance with the Token Monitoring System:

1. Check the source code in `.cursor/performance-tools/` for detailed documentation
2. Review the usage examples in this guide
3. Contact the cFish.io development team through the support channel 