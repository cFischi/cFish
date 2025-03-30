/**
 * WordPress Token Tracking System
 * 
 * A utility for tracking token usage in WordPress projects when working with AI models.
 * This allows for better budget management and optimization of prompts.
 * 
 * @package TokenTracker
 * @version 1.0.0
 */

/**
 * Token counter class for estimating and tracking token usage.
 */
class TokenTracker {
  /**
   * Initialize the token tracker with default values.
   */
  constructor() {
    this.sessions = [];
    this.currentSession = null;
    this.tokensPerWord = 0.75; // Average English words per token
    this.codeTokenMultiplier = 1.5; // Code tends to use more tokens per character
    this.currentReport = null;
  }

  /**
   * Start a new tracking session.
   * 
   * @param {string} sessionName Name of the session for reference
   * @param {string} projectName Name of the WordPress project
   * @param {string} taskType Type of task (e.g., "Architecture Planning", "Code Implementation")
   * @param {string} complexity Complexity level ("Low", "Medium", "High")
   * @returns {object} Session object
   */
  startSession(sessionName, projectName, taskType, complexity) {
    // End any current session first
    if (this.currentSession) {
      this.endSession();
    }

    this.currentSession = {
      id: Date.now(),
      name: sessionName,
      project: projectName,
      taskType: taskType,
      complexity: complexity,
      startTime: new Date(),
      endTime: null,
      inputs: [],
      outputs: [],
      totalInputTokens: 0,
      totalOutputTokens: 0,
      totalTokens: 0,
      budget: this.getTokenBudget(taskType, complexity),
      status: 'active'
    };

    console.log(`Session started: ${sessionName}`);
    return this.currentSession;
  }

  /**
   * End the current tracking session and generate summary.
   * 
   * @returns {object} Completed session object
   */
  endSession() {
    if (!this.currentSession) {
      console.warn('No active session to end');
      return null;
    }

    this.currentSession.endTime = new Date();
    this.currentSession.status = 'completed';
    
    // Calculate duration in minutes
    const durationMs = this.currentSession.endTime - this.currentSession.startTime;
    this.currentSession.durationMinutes = Math.round(durationMs / 60000);
    
    // Add session to history
    this.sessions.push(this.currentSession);
    
    console.log(`Session ended: ${this.currentSession.name}`);
    console.log(`Total tokens used: ${this.currentSession.totalTokens} / ${this.currentSession.budget} (${Math.round(this.currentSession.totalTokens / this.currentSession.budget * 100)}%)`);
    
    const completedSession = this.currentSession;
    this.currentSession = null;
    
    return completedSession;
  }

  /**
   * Track an input prompt or message.
   * 
   * @param {string} content Content of the prompt or message
   * @param {string} type Type of content: 'text', 'code', or 'mixed'
   * @returns {object} Input tracking details
   */
  trackInput(content, type = 'text') {
    if (!this.currentSession) {
      console.warn('Cannot track input: No active session');
      return null;
    }

    const tokenEstimate = this.estimateTokens(content, type);
    
    const input = {
      id: Date.now(),
      timestamp: new Date(),
      content: content.substring(0, 100) + (content.length > 100 ? '...' : ''), // Truncate for storage
      type: type,
      tokens: tokenEstimate,
      contentLength: content.length
    };
    
    this.currentSession.inputs.push(input);
    this.currentSession.totalInputTokens += tokenEstimate;
    this.currentSession.totalTokens += tokenEstimate;
    
    console.log(`Input tracked: ${tokenEstimate} tokens (${type})`);
    this.checkBudget();
    
    return input;
  }

  /**
   * Track an output response.
   * 
   * @param {string} content Content of the response
   * @param {string} type Type of content: 'text', 'code', or 'mixed'
   * @returns {object} Output tracking details
   */
  trackOutput(content, type = 'text') {
    if (!this.currentSession) {
      console.warn('Cannot track output: No active session');
      return null;
    }

    const tokenEstimate = this.estimateTokens(content, type);
    
    const output = {
      id: Date.now(),
      timestamp: new Date(),
      content: content.substring(0, 100) + (content.length > 100 ? '...' : ''), // Truncate for storage
      type: type,
      tokens: tokenEstimate,
      contentLength: content.length
    };
    
    this.currentSession.outputs.push(output);
    this.currentSession.totalOutputTokens += tokenEstimate;
    this.currentSession.totalTokens += tokenEstimate;
    
    console.log(`Output tracked: ${tokenEstimate} tokens (${type})`);
    this.checkBudget();
    
    return output;
  }

  /**
   * Estimate the number of tokens in a text.
   * 
   * @param {string} text Text to analyze
   * @param {string} type Type of content: 'text', 'code', or 'mixed'
   * @returns {number} Estimated token count
   */
  estimateTokens(text, type = 'text') {
    if (!text) return 0;
    
    let tokenEstimate = 0;

    switch (type) {
      case 'code':
        // Code tends to use more tokens due to spacing and special characters
        tokenEstimate = Math.ceil(text.length / 3 * this.codeTokenMultiplier);
        break;
      case 'mixed':
        // For mixed content, split by code blocks and estimate separately
        const codeBlockRegex = /```[\s\S]*?```/g;
        const codeBlocks = text.match(codeBlockRegex) || [];
        let remainingText = text;
        
        // Calculate tokens for code blocks
        let codeTokens = 0;
        codeBlocks.forEach(block => {
          codeTokens += Math.ceil(block.length / 3 * this.codeTokenMultiplier);
          remainingText = remainingText.replace(block, ''); // Remove code block
        });
        
        // Calculate tokens for remaining text
        const textTokens = Math.ceil(this.countWords(remainingText) * this.tokensPerWord);
        
        tokenEstimate = codeTokens + textTokens;
        break;
      case 'text':
      default:
        // Standard text estimation based on word count
        tokenEstimate = Math.ceil(this.countWords(text) * this.tokensPerWord);
        break;
    }
    
    return tokenEstimate;
  }

  /**
   * Count the number of words in a text.
   * 
   * @param {string} text Text to analyze
   * @returns {number} Word count
   */
  countWords(text) {
    if (!text) return 0;
    const words = text.trim().split(/\s+/);
    return words.length;
  }

  /**
   * Get the token budget for a specific task type and complexity.
   * 
   * @param {string} taskType Type of task
   * @param {string} complexity Complexity level
   * @returns {number} Token budget
   */
  getTokenBudget(taskType, complexity) {
    const budgets = {
      'Architecture Planning': {
        'Low': 4000,
        'Medium': 8000,
        'High': 14000
      },
      'Code Implementation': {
        'Low': 5000,
        'Medium': 10000,
        'High': 18000
      },
      'Theme Development': {
        'Low': 5000,
        'Medium': 10000,
        'High': 18000
      },
      'Security Review': {
        'Low': 4000,
        'Medium': 7000,
        'High': 13000
      },
      'Documentation': {
        'Low': 3000,
        'Medium': 6000,
        'High': 12000
      },
      'Plugin Integration': {
        'Low': 4000,
        'Medium': 7000,
        'High': 11000
      }
    };
    
    // Default to medium Code Implementation if type not found
    if (!budgets[taskType]) {
      console.warn(`Task type "${taskType}" not found in budget table, using default`);
      return 10000;
    }
    
    // Default to medium complexity if complexity not found
    if (!budgets[taskType][complexity]) {
      console.warn(`Complexity "${complexity}" not found for task type "${taskType}", using Medium`);
      return budgets[taskType]['Medium'];
    }
    
    return budgets[taskType][complexity];
  }

  /**
   * Check the current budget status and warn if approaching/exceeding limits.
   */
  checkBudget() {
    if (!this.currentSession) return;
    
    const used = this.currentSession.totalTokens;
    const budget = this.currentSession.budget;
    const percentUsed = (used / budget) * 100;
    
    if (percentUsed >= 90) {
      console.warn(`BUDGET ALERT: ${Math.round(percentUsed)}% of token budget used (${used}/${budget})`);
      if (percentUsed > 100) {
        console.warn('Token budget exceeded! Consider implementing optimization strategies.');
      }
    } else if (percentUsed >= 70) {
      console.warn(`BUDGET WARNING: ${Math.round(percentUsed)}% of token budget used (${used}/${budget})`);
    }
  }

  /**
   * Generate a report for the current or specified session.
   * 
   * @param {number} sessionId Optional session ID to report on
   * @returns {object} Report object
   */
  generateReport(sessionId = null) {
    let session;
    
    if (sessionId) {
      session = this.sessions.find(s => s.id === sessionId);
      if (!session) {
        console.warn(`Session with ID ${sessionId} not found`);
        return null;
      }
    } else if (this.currentSession) {
      session = this.currentSession;
    } else if (this.sessions.length > 0) {
      session = this.sessions[this.sessions.length - 1];
    } else {
      console.warn('No sessions available to generate report');
      return null;
    }
    
    const inputTokens = session.totalInputTokens;
    const outputTokens = session.totalOutputTokens;
    const totalTokens = session.totalTokens;
    const budget = session.budget;
    
    // Calculate percentages and rates
    const percentUsed = (totalTokens / budget) * 100;
    const inputPercentage = (inputTokens / totalTokens) * 100;
    const outputPercentage = (outputTokens / totalTokens) * 100;
    
    let tokenRate = 0;
    if (session.endTime && session.status === 'completed') {
      const durationMinutes = session.durationMinutes;
      tokenRate = durationMinutes > 0 ? Math.round(totalTokens / durationMinutes) : 0;
    }
    
    // Create report object
    this.currentReport = {
      sessionName: session.name,
      project: session.project,
      taskType: session.taskType,
      complexity: session.complexity,
      startTime: session.startTime,
      endTime: session.endTime || new Date(),
      status: session.status,
      inputTokens: inputTokens,
      outputTokens: outputTokens,
      totalTokens: totalTokens,
      budget: budget,
      percentUsed: Math.round(percentUsed * 10) / 10,
      inputPercentage: Math.round(inputPercentage * 10) / 10,
      outputPercentage: Math.round(outputPercentage * 10) / 10,
      tokenRate: tokenRate,
      messageCount: session.inputs.length,
      inputsByType: this.countByType(session.inputs),
      outputsByType: this.countByType(session.outputs),
      recommendations: this.generateRecommendations(session)
    };
    
    return this.currentReport;
  }

  /**
   * Count tracked items by content type.
   * 
   * @param {Array} items Items to count
   * @returns {object} Count by type
   */
  countByType(items) {
    const types = {};
    
    items.forEach(item => {
      if (!types[item.type]) {
        types[item.type] = {
          count: 0,
          tokens: 0
        };
      }
      
      types[item.type].count++;
      types[item.type].tokens += item.tokens;
    });
    
    return types;
  }

  /**
   * Generate optimization recommendations based on session data.
   * 
   * @param {object} session Session to analyze
   * @returns {Array} Recommendations
   */
  generateRecommendations(session) {
    const recommendations = [];
    const percentUsed = (session.totalTokens / session.budget) * 100;
    
    // Budget-based recommendations
    if (percentUsed > 90) {
      recommendations.push('Consider breaking this task into smaller, more focused components');
      recommendations.push('Review the token optimization strategies document for this task type');
    }
    
    // Input-heavy recommendations
    if (session.totalInputTokens > session.totalOutputTokens * 2) {
      recommendations.push('Input prompts are significantly larger than outputs; consider streamlining prompts');
      recommendations.push('Use more concise descriptions and focused requests in prompts');
    }
    
    // Code-heavy recommendations
    const codeInputs = session.inputs.filter(i => i.type === 'code' || i.type === 'mixed');
    if (codeInputs.length > 0 && this.sumTokens(codeInputs) > session.totalInputTokens * 0.7) {
      recommendations.push('Large portions of code in prompts; consider referencing specific functions instead of entire files');
      recommendations.push('Focus on the specific code sections needing attention rather than entire components');
    }
    
    // General recommendations
    recommendations.push('Use structured templates from the prompt template library for better token efficiency');
    recommendations.push('Consider batching similar questions together instead of separate requests');
    
    return recommendations;
  }

  /**
   * Sum tokens from a list of tracked items.
   * 
   * @param {Array} items Items to sum
   * @returns {number} Total tokens
   */
  sumTokens(items) {
    return items.reduce((sum, item) => sum + item.tokens, 0);
  }

  /**
   * Export the session data to JSON.
   * 
   * @param {number} sessionId Optional session ID to export
   * @returns {string} JSON string
   */
  exportToJson(sessionId = null) {
    let dataToExport;
    
    if (sessionId) {
      const session = this.sessions.find(s => s.id === sessionId);
      dataToExport = session || null;
    } else if (this.currentSession) {
      dataToExport = this.currentSession;
    } else if (this.sessions.length > 0) {
      dataToExport = this.sessions;
    } else {
      console.warn('No session data to export');
      return null;
    }
    
    return JSON.stringify(dataToExport, null, 2);
  }

  /**
   * Export the current report to JSON.
   * 
   * @returns {string} JSON string
   */
  exportReportToJson() {
    if (!this.currentReport) {
      console.warn('No report to export, generate a report first');
      return null;
    }
    
    return JSON.stringify(this.currentReport, null, 2);
  }

  /**
   * Import session data from JSON.
   * 
   * @param {string} jsonString JSON data to import
   * @returns {boolean} Success status
   */
  importFromJson(jsonString) {
    try {
      const data = JSON.parse(jsonString);
      
      if (Array.isArray(data)) {
        // Importing multiple sessions
        this.sessions = [...this.sessions, ...data];
        console.log(`Imported ${data.length} sessions`);
      } else if (data && data.id) {
        // Importing a single session
        this.sessions.push(data);
        console.log(`Imported session: ${data.name}`);
      } else {
        console.warn('Invalid session data format');
        return false;
      }
      
      return true;
    } catch (error) {
      console.error('Error importing session data:', error);
      return false;
    }
  }
}

// Example usage
/*
const tracker = new TokenTracker();

// Start a session
tracker.startSession('Feature Implementation', 'WooCommerce Custom Extension', 'Code Implementation', 'Medium');

// Track inputs and outputs
tracker.trackInput('I need to implement a custom checkout field in WooCommerce that validates a customer\'s tax ID number.', 'text');
tracker.trackOutput('I\'ll help you implement a custom checkout field for tax ID validation in WooCommerce. Here\'s how we can approach this:', 'text');

tracker.trackInput(`
Here's the current checkout form code:

\`\`\`php
function custom_checkout_fields($fields) {
    // Current implementation
    return $fields;
}
add_filter('woocommerce_checkout_fields', 'custom_checkout_fields');
\`\`\`

How do I modify this to add a tax ID field with validation?
`, 'mixed');

// Generate and display a report
const report = tracker.generateReport();
console.log(JSON.stringify(report, null, 2));

// End the session
tracker.endSession();
*/

// Export the TokenTracker class
module.exports = TokenTracker; 