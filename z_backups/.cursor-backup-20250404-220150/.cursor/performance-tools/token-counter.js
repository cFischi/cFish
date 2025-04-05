/**
 * token-counter.js - Cursor AI Token Usage Estimation Utility
 * 
 * This utility provides functions to estimate token usage in Cursor AI interactions,
 * helping developers optimize their prompts and responses for better efficiency.
 * 
 * @package cFish.io
 * @since 1.0.0
 * @author cFish.io Development Team
 */

/**
 * Estimates tokens for a given text string using a simple approximation method.
 * 
 * Note: This is an approximation. Actual token counts may vary as tokenization
 * depends on the specific model and tokenizer used by Cursor.
 * 
 * @param {string} text - The text to count tokens for
 * @return {number} Estimated token count
 */
function estimateTokens(text) {
  if (!text) return 0;
  
  // Simple approximation: average English words are ~1.3 tokens
  // For multi-language support, character counting is more reliable
  // Split by whitespace for word count
  const words = text.trim().split(/\s+/).length;
  
  // Estimate: ~1.3 tokens per word for English
  return Math.ceil(words * 1.3);
}

/**
 * Calculates token usage for code blocks with higher accuracy
 * Code typically tokenizes differently than natural language
 * 
 * @param {string} code - The code string to analyze
 * @param {string} language - Programming language (optional)
 * @return {number} Estimated token count for code
 */
function estimateCodeTokens(code, language = 'generic') {
  if (!code) return 0;
  
  const trimmedCode = code.trim();
  
  // Code tends to have more tokens per character than natural text
  // Special characters and syntax each often represent individual tokens
  const chars = trimmedCode.length;
  const words = trimmedCode.split(/\s+/).length;
  
  // Different estimation based on language type
  // These are approximations based on observed tokenization patterns
  const languageMultipliers = {
    'html': 0.35,   // HTML has many tokens for tags
    'css': 0.33,    // CSS properties and selectors are token-heavy
    'php': 0.30,    // PHP has many symbols and operators
    'javascript': 0.28, // JS has many symbols and keywords
    'typescript': 0.28, // Similar to JS
    'python': 0.25, // Python is relatively token-efficient
    'generic': 0.30 // Default multiplier
  };
  
  const multiplier = languageMultipliers[language.toLowerCase()] || languageMultipliers.generic;
  
  // Base calculation: characters * multiplier + word count as a baseline
  return Math.ceil((chars * multiplier) + (words * 0.5));
}

/**
 * Estimates tokens for a WordPress theme or plugin file
 * 
 * @param {string} fileContent - Content of the WordPress file
 * @param {string} fileType - Type of file (e.g., 'theme', 'plugin', 'functions')
 * @return {number} Estimated token count
 */
function estimateWPFileTokens(fileContent, fileType = 'theme') {
  if (!fileContent) return 0;
  
  // Extract code blocks by language
  const phpMatches = fileContent.match(/(?:```php\n)([^`]+)(?:```)/g) || [];
  const jsMatches = fileContent.match(/(?:```js\n)([^`]+)(?:```)/g) || [];
  const cssMatches = fileContent.match(/(?:```css\n)([^`]+)(?:```)/g) || [];
  const htmlMatches = fileContent.match(/(?:```html\n)([^`]+)(?:```)/g) || [];
  
  // Remove code blocks from text for separate processing
  let textContent = fileContent;
  [...phpMatches, ...jsMatches, ...cssMatches, ...htmlMatches].forEach(match => {
    textContent = textContent.replace(match, '');
  });
  
  // Calculate tokens for each content type
  let totalTokens = estimateTokens(textContent);
  
  // Process PHP blocks
  phpMatches.forEach(match => {
    const code = match.replace(/```php\n/, '').replace(/```$/, '');
    totalTokens += estimateCodeTokens(code, 'php');
  });
  
  // Process JS blocks
  jsMatches.forEach(match => {
    const code = match.replace(/```js\n/, '').replace(/```$/, '');
    totalTokens += estimateCodeTokens(code, 'javascript');
  });
  
  // Process CSS blocks
  cssMatches.forEach(match => {
    const code = match.replace(/```css\n/, '').replace(/```$/, '');
    totalTokens += estimateCodeTokens(code, 'css');
  });
  
  // Process HTML blocks
  htmlMatches.forEach(match => {
    const code = match.replace(/```html\n/, '').replace(/```$/, '');
    totalTokens += estimateCodeTokens(code, 'html');
  });
  
  return totalTokens;
}

/**
 * Analyzes a conversation to estimate total token usage
 * 
 * @param {Array} messages - Array of message objects with 'role' and 'content'
 * @return {Object} Token usage statistics
 */
function analyzeConversation(messages) {
  if (!Array.isArray(messages)) {
    return {
      error: 'Invalid input: messages should be an array',
      totalTokens: 0
    };
  }
  
  const result = {
    totalTokens: 0,
    userTokens: 0,
    assistantTokens: 0,
    systemTokens: 0,
    messageCount: messages.length,
    averageTokensPerMessage: 0,
    tokensByMessage: []
  };
  
  messages.forEach((message, index) => {
    if (!message.role || !message.content) {
      result.tokensByMessage.push({
        index,
        tokens: 0,
        error: 'Invalid message format'
      });
      return;
    }
    
    const content = message.content;
    let tokens;
    
    // Check if the content contains code blocks
    if (content.includes('```')) {
      tokens = estimateWPFileTokens(content);
    } else {
      tokens = estimateTokens(content);
    }
    
    // Add role prefix tokens (typically 3-4 tokens)
    tokens += 4;
    
    // Add to the appropriate counter
    switch (message.role.toLowerCase()) {
      case 'user':
        result.userTokens += tokens;
        break;
      case 'assistant':
        result.assistantTokens += tokens;
        break;
      case 'system':
        result.systemTokens += tokens;
        break;
    }
    
    result.totalTokens += tokens;
    
    // Add message-specific data
    result.tokensByMessage.push({
      index,
      role: message.role,
      tokens
    });
  });
  
  // Calculate average
  if (messages.length > 0) {
    result.averageTokensPerMessage = Math.round(result.totalTokens / messages.length);
  }
  
  return result;
}

/**
 * Provides optimization suggestions based on token analysis
 * 
 * @param {Object} analysis - Token analysis from analyzeConversation()
 * @return {Array} Array of optimization suggestions
 */
function getOptimizationSuggestions(analysis) {
  if (!analysis || typeof analysis !== 'object') {
    return ['Invalid analysis data'];
  }
  
  const suggestions = [];
  
  // Check for high token usage in specific messages
  const highTokenMessages = analysis.tokensByMessage.filter(msg => 
    msg.tokens > 1000 && msg.role === 'user'
  );
  
  if (highTokenMessages.length > 0) {
    suggestions.push(`Found ${highTokenMessages.length} user messages with high token counts (>1000). Consider breaking these into smaller, focused requests.`);
    
    highTokenMessages.slice(0, 3).forEach(msg => {
      suggestions.push(`Message at index ${msg.index} uses ${msg.tokens} tokens. Consider optimizing.`);
    });
  }
  
  // Check for overall conversation length
  if (analysis.totalTokens > 15000) {
    suggestions.push(`Total conversation is approaching Cursor's limit (${analysis.totalTokens}/20000 tokens). Consider starting a new session soon.`);
  }
  
  // Check for balance between user and assistant
  const userRatio = analysis.userTokens / analysis.totalTokens;
  if (userRatio > 0.7) {
    suggestions.push(`User messages make up ${Math.round(userRatio * 100)}% of tokens. Consider more focused prompts.`);
  }
  
  // WordPress-specific optimizations
  if (analysis.messageCount > 10 && analysis.averageTokensPerMessage > 800) {
    suggestions.push(`For WordPress development, consider breaking tasks into specific components (themes, plugins, functions) rather than large, general requests.`);
  }
  
  // Add general tips if no specific issues found
  if (suggestions.length === 0) {
    suggestions.push('Token usage appears efficient. Continue with current approach.');
    suggestions.push('For WordPress tasks, remember to reference file paths explicitly and use specific component-focused requests.');
  }
  
  return suggestions;
}

/**
 * Format and display token usage report for a conversation
 * 
 * @param {Object} analysis - Token analysis from analyzeConversation()
 * @return {string} Formatted report
 */
function formatTokenReport(analysis) {
  if (!analysis || typeof analysis !== 'object') {
    return 'Invalid analysis data';
  }
  
  const cursorLimit = 20000;
  const percentUsed = ((analysis.totalTokens / cursorLimit) * 100).toFixed(1);
  
  let report = `
# Cursor Token Usage Report

## Summary
- Total tokens: ${analysis.totalTokens} (${percentUsed}% of ${cursorLimit} limit)
- User tokens: ${analysis.userTokens} (${((analysis.userTokens / analysis.totalTokens) * 100).toFixed(1)}%)
- Assistant tokens: ${analysis.assistantTokens} (${((analysis.assistantTokens / analysis.totalTokens) * 100).toFixed(1)}%)
- System tokens: ${analysis.systemTokens}
- Messages: ${analysis.messageCount}
- Average tokens per message: ${analysis.averageTokensPerMessage}

## Token Distribution by Message
`;

  // Add message-specific data
  analysis.tokensByMessage.forEach(msg => {
    report += `- Message ${msg.index + 1} (${msg.role}): ${msg.tokens} tokens\n`;
  });
  
  report += '\n## Optimization Suggestions\n';
  
  // Add optimization suggestions
  const suggestions = getOptimizationSuggestions(analysis);
  suggestions.forEach(suggestion => {
    report += `- ${suggestion}\n`;
  });
  
  return report;
}

// Export functions for external usage
module.exports = {
  estimateTokens,
  estimateCodeTokens,
  estimateWPFileTokens,
  analyzeConversation,
  getOptimizationSuggestions,
  formatTokenReport
}; 