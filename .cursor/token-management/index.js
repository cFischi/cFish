/**
 * WordPress Token Management Tools
 * 
 * Main entry point for token management utilities for WordPress AI workflows.
 * 
 * @package wp-token-management
 * @version 1.0.0
 */

const TokenTracker = require('./token-tracker');
const TokenLogger = require('./token-logger');

/**
 * Create and initialize a new token tracker.
 * 
 * @returns {TokenTracker} A new token tracker instance
 */
function createTracker() {
  return new TokenTracker();
}

/**
 * Create and initialize a new token logger.
 * 
 * @param {string} logDir Optional custom log directory
 * @returns {TokenLogger} A new token logger instance
 */
function createLogger(logDir) {
  return new TokenLogger(logDir);
}

/**
 * Estimate tokens in a given text.
 * 
 * @param {string} text Text to analyze
 * @param {string} type Type of content: 'text', 'code', or 'mixed'
 * @returns {number} Estimated token count
 */
function estimateTokens(text, type = 'text') {
  const tracker = new TokenTracker();
  return tracker.estimateTokens(text, type);
}

/**
 * Get token budget for a task type and complexity.
 * 
 * @param {string} taskType Type of task
 * @param {string} complexity Complexity level: 'Low', 'Medium', or 'High'
 * @returns {number} Token budget
 */
function getTokenBudget(taskType, complexity) {
  const tracker = new TokenTracker();
  return tracker.getTokenBudget(taskType, complexity);
}

// Export the token management utilities
module.exports = {
  TokenTracker,
  TokenLogger,
  createTracker,
  createLogger,
  estimateTokens,
  getTokenBudget
}; 