/**
 * token-logger.js - Cursor AI Token Usage Logging Utility
 * 
 * This utility provides functions to log and track token usage across multiple sessions,
 * allowing teams to monitor usage patterns and optimize AI interactions.
 * 
 * @package cFish.io
 * @since 1.0.0
 * @author cFish.io Development Team
 */

const fs = require('fs');
const path = require('path');
const tokenCounter = require('./token-counter');

// Configuration
const DEFAULT_CONFIG = {
  logDirectory: path.join(__dirname, 'logs'),
  sessionLogFile: 'cursor-session-log.json',
  summaryLogFile: 'cursor-usage-summary.json',
  projectName: 'cFish.io',
  maxSessionsInMemory: 50,
  enableDetailedLogging: true,
  loggedMessageFields: ['role', 'tokens', 'timestamp', 'sessionId'],
  customTags: []
};

let config = {...DEFAULT_CONFIG};
let activeSessions = {};
let cachedSummary = null;

/**
 * Initializes the token logger with custom configuration
 * 
 * @param {Object} customConfig - Custom configuration options
 * @return {Object} Current configuration
 */
function initialize(customConfig = {}) {
  config = {...DEFAULT_CONFIG, ...customConfig};
  
  // Ensure log directory exists
  if (!fs.existsSync(config.logDirectory)) {
    try {
      fs.mkdirSync(config.logDirectory, {recursive: true});
    } catch (err) {
      console.error(`Failed to create log directory: ${err.message}`);
      // Fall back to temp directory if creation fails
      config.logDirectory = path.join(require('os').tmpdir(), 'cursor-token-logs');
      fs.mkdirSync(config.logDirectory, {recursive: true});
    }
  }
  
  // Initialize session log file if it doesn't exist
  const sessionLogPath = path.join(config.logDirectory, config.sessionLogFile);
  if (!fs.existsSync(sessionLogPath)) {
    fs.writeFileSync(sessionLogPath, JSON.stringify({
      project: config.projectName,
      sessions: []
    }, null, 2));
  }
  
  // Initialize summary log file if it doesn't exist
  const summaryLogPath = path.join(config.logDirectory, config.summaryLogFile);
  if (!fs.existsSync(summaryLogPath)) {
    fs.writeFileSync(summaryLogPath, JSON.stringify({
      project: config.projectName,
      lastUpdated: new Date().toISOString(),
      totalSessions: 0,
      totalTokens: 0,
      tokensByRole: {
        user: 0,
        assistant: 0,
        system: 0
      },
      dailyUsage: {},
      sessionAverages: {
        tokensPerSession: 0,
        messagesPerSession: 0,
        tokensPerMessage: 0
      }
    }, null, 2));
  }
  
  return config;
}

/**
 * Creates a new session for token logging
 * 
 * @param {string} sessionName - Descriptive name for the session
 * @param {Object} metadata - Additional metadata for the session
 * @return {string} Session ID
 */
function startSession(sessionName, metadata = {}) {
  const sessionId = `session_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  
  activeSessions[sessionId] = {
    id: sessionId,
    name: sessionName || 'Unnamed Session',
    startTime: new Date().toISOString(),
    endTime: null,
    metadata: {
      ...metadata,
      tags: [...(metadata.tags || []), ...config.customTags]
    },
    messages: [],
    summary: {
      totalTokens: 0,
      tokensByRole: {
        user: 0,
        assistant: 0,
        system: 0
      },
      messageCount: 0
    }
  };
  
  return sessionId;
}

/**
 * Logs a message exchange to the active session
 * 
 * @param {string} sessionId - ID of the active session
 * @param {Object} message - Message object with role and content
 * @return {Object|null} Updated session summary or null if session not found
 */
function logMessage(sessionId, message) {
  if (!activeSessions[sessionId]) {
    console.error(`Session ${sessionId} not found`);
    return null;
  }
  
  if (!message.role || !message.content) {
    console.error('Invalid message format. Must include role and content properties.');
    return null;
  }
  
  const session = activeSessions[sessionId];
  const tokensUsed = tokenCounter.estimateTokens(message.content);
  
  // Update session summary
  session.summary.totalTokens += tokensUsed;
  session.summary.messageCount++;
  
  // Update role-specific counters
  if (message.role.toLowerCase() in session.summary.tokensByRole) {
    session.summary.tokensByRole[message.role.toLowerCase()] += tokensUsed;
  }
  
  // Log the message details if detailed logging is enabled
  if (config.enableDetailedLogging) {
    const loggedMessage = {
      timestamp: new Date().toISOString(),
      sessionId: sessionId,
      role: message.role,
      tokens: tokensUsed
    };
    
    // Add other fields as configured
    if (config.loggedMessageFields.includes('content')) {
      // Optionally store content (can consume significant storage)
      loggedMessage.content = message.content;
    }
    
    if (config.loggedMessageFields.includes('contentPreview')) {
      // Store just a preview of content to save space
      loggedMessage.contentPreview = message.content.substring(0, 100) + 
        (message.content.length > 100 ? '...' : '');
    }
    
    // Store the logged message
    session.messages.push(loggedMessage);
  }
  
  return session.summary;
}

/**
 * Logs multiple messages at once (e.g., for an entire conversation)
 * 
 * @param {string} sessionId - ID of the active session
 * @param {Array} messages - Array of message objects
 * @return {Object|null} Updated session summary or null if session not found
 */
function logConversation(sessionId, messages) {
  if (!Array.isArray(messages)) {
    console.error('Messages must be an array');
    return null;
  }
  
  if (!activeSessions[sessionId]) {
    console.error(`Session ${sessionId} not found`);
    return null;
  }
  
  // Log each message
  messages.forEach(message => logMessage(sessionId, message));
  
  // Run token analysis on the entire conversation
  const analysis = tokenCounter.analyzeConversation(messages);
  
  // Update session with the analysis results
  const session = activeSessions[sessionId];
  session.analysis = analysis;
  
  return session.summary;
}

/**
 * Ends an active session and persists it to the log file
 * 
 * @param {string} sessionId - ID of the active session to end
 * @return {Object|null} Final session data or null if session not found
 */
function endSession(sessionId) {
  if (!activeSessions[sessionId]) {
    console.error(`Session ${sessionId} not found`);
    return null;
  }
  
  const session = activeSessions[sessionId];
  session.endTime = new Date().toISOString();
  
  // Calculate duration
  const startTime = new Date(session.startTime);
  const endTime = new Date(session.endTime);
  session.durationMs = endTime - startTime;
  session.durationFormatted = formatDuration(session.durationMs);
  
  // Persist to log file
  const sessionLogPath = path.join(config.logDirectory, config.sessionLogFile);
  let sessionLog;
  
  try {
    sessionLog = JSON.parse(fs.readFileSync(sessionLogPath, 'utf8'));
  } catch (err) {
    console.error(`Failed to read session log: ${err.message}`);
    sessionLog = { project: config.projectName, sessions: [] };
  }
  
  // Add to the beginning of the array (most recent first)
  sessionLog.sessions.unshift(session);
  
  // Limit the number of sessions in the file
  if (sessionLog.sessions.length > config.maxSessionsInMemory) {
    sessionLog.sessions = sessionLog.sessions.slice(0, config.maxSessionsInMemory);
  }
  
  // Write back to file
  try {
    fs.writeFileSync(sessionLogPath, JSON.stringify(sessionLog, null, 2));
  } catch (err) {
    console.error(`Failed to write session log: ${err.message}`);
  }
  
  // Update summary
  updateSummaryLog(session);
  
  // Remove from active sessions
  delete activeSessions[sessionId];
  
  return session;
}

/**
 * Updates the summary log with data from a completed session
 * 
 * @param {Object} session - Completed session data
 */
function updateSummaryLog(session) {
  const summaryLogPath = path.join(config.logDirectory, config.summaryLogFile);
  let summary;
  
  try {
    summary = JSON.parse(fs.readFileSync(summaryLogPath, 'utf8'));
  } catch (err) {
    console.error(`Failed to read summary log: ${err.message}`);
    return;
  }
  
  // Update summary statistics
  summary.lastUpdated = new Date().toISOString();
  summary.totalSessions++;
  summary.totalTokens += session.summary.totalTokens;
  
  // Update tokens by role
  Object.keys(session.summary.tokensByRole).forEach(role => {
    if (role in summary.tokensByRole) {
      summary.tokensByRole[role] += session.summary.tokensByRole[role];
    } else {
      summary.tokensByRole[role] = session.summary.tokensByRole[role];
    }
  });
  
  // Update daily usage
  const sessionDate = session.startTime.split('T')[0]; // YYYY-MM-DD
  if (!summary.dailyUsage[sessionDate]) {
    summary.dailyUsage[sessionDate] = {
      totalTokens: 0,
      sessionCount: 0
    };
  }
  
  summary.dailyUsage[sessionDate].totalTokens += session.summary.totalTokens;
  summary.dailyUsage[sessionDate].sessionCount++;
  
  // Update session averages
  summary.sessionAverages.tokensPerSession = Math.round(summary.totalTokens / summary.totalSessions);
  summary.sessionAverages.messagesPerSession = Math.round(
    (summary.sessionAverages.messagesPerSession * (summary.totalSessions - 1) + session.summary.messageCount) / 
    summary.totalSessions
  );
  summary.sessionAverages.tokensPerMessage = Math.round(
    summary.totalTokens / 
    (summary.sessionAverages.messagesPerSession * summary.totalSessions)
  );
  
  // Write back to file
  try {
    fs.writeFileSync(summaryLogPath, JSON.stringify(summary, null, 2));
    cachedSummary = summary; // Cache the updated summary
  } catch (err) {
    console.error(`Failed to write summary log: ${err.message}`);
  }
}

/**
 * Retrieves usage summary statistics
 * 
 * @param {boolean} refresh - Whether to refresh from disk
 * @return {Object} Usage summary statistics
 */
function getUsageSummary(refresh = false) {
  if (cachedSummary && !refresh) {
    return cachedSummary;
  }
  
  const summaryLogPath = path.join(config.logDirectory, config.summaryLogFile);
  try {
    const summary = JSON.parse(fs.readFileSync(summaryLogPath, 'utf8'));
    cachedSummary = summary;
    return summary;
  } catch (err) {
    console.error(`Failed to read summary log: ${err.message}`);
    return null;
  }
}

/**
 * Generates a token usage report for a given time period
 * 
 * @param {Object} options - Report options (timeframe, format, etc.)
 * @return {Object} Report data
 */
function generateReport(options = {}) {
  const defaults = {
    timeframe: 'all', // 'day', 'week', 'month', 'all'
    format: 'json', // 'json', 'markdown', 'html'
    includeSessions: false, // Include detailed session data
    includeMessages: false, // Include message details (can be large)
    tags: [] // Filter by specific tags
  };
  
  const reportOptions = {...defaults, ...options};
  const sessionLogPath = path.join(config.logDirectory, config.sessionLogFile);
  const summary = getUsageSummary(true); // Get fresh summary
  
  let sessionLog;
  try {
    sessionLog = JSON.parse(fs.readFileSync(sessionLogPath, 'utf8'));
  } catch (err) {
    console.error(`Failed to read session log: ${err.message}`);
    return null;
  }
  
  // Apply timeframe filter
  let filteredSessions = sessionLog.sessions;
  const now = new Date();
  
  if (reportOptions.timeframe !== 'all') {
    let cutoff = new Date();
    
    switch (reportOptions.timeframe) {
      case 'day':
        cutoff.setDate(cutoff.getDate() - 1);
        break;
      case 'week':
        cutoff.setDate(cutoff.getDate() - 7);
        break;
      case 'month':
        cutoff.setMonth(cutoff.getMonth() - 1);
        break;
    }
    
    filteredSessions = filteredSessions.filter(session => {
      const sessionDate = new Date(session.startTime);
      return sessionDate >= cutoff;
    });
  }
  
  // Apply tag filters if any
  if (reportOptions.tags && reportOptions.tags.length > 0) {
    filteredSessions = filteredSessions.filter(session => {
      if (!session.metadata || !session.metadata.tags) return false;
      return reportOptions.tags.some(tag => session.metadata.tags.includes(tag));
    });
  }
  
  // Prepare report data
  const reportData = {
    generatedAt: now.toISOString(),
    timeframe: reportOptions.timeframe,
    projectName: config.projectName,
    summary: {
      sessionsAnalyzed: filteredSessions.length,
      totalTokens: filteredSessions.reduce((sum, session) => sum + session.summary.totalTokens, 0),
      tokensByRole: {
        user: filteredSessions.reduce((sum, session) => sum + (session.summary.tokensByRole.user || 0), 0),
        assistant: filteredSessions.reduce((sum, session) => sum + (session.summary.tokensByRole.assistant || 0), 0),
        system: filteredSessions.reduce((sum, session) => sum + (session.summary.tokensByRole.system || 0), 0)
      },
      totalMessages: filteredSessions.reduce((sum, session) => sum + session.summary.messageCount, 0),
      averageTokensPerSession: Math.round(
        filteredSessions.reduce((sum, session) => sum + session.summary.totalTokens, 0) / 
        Math.max(1, filteredSessions.length)
      ),
      averageMessagesPerSession: Math.round(
        filteredSessions.reduce((sum, session) => sum + session.summary.messageCount, 0) / 
        Math.max(1, filteredSessions.length)
      )
    }
  };
  
  // Include session details if requested
  if (reportOptions.includeSessions) {
    reportData.sessions = filteredSessions.map(session => {
      const sessionCopy = {...session};
      
      // Remove message details unless specifically requested
      if (!reportOptions.includeMessages) {
        delete sessionCopy.messages;
      }
      
      return sessionCopy;
    });
  }
  
  // Format according to requested format
  switch (reportOptions.format) {
    case 'markdown':
      return formatReportMarkdown(reportData);
    case 'html':
      return formatReportHTML(reportData);
    case 'json':
    default:
      return reportData;
  }
}

/**
 * Formats report as Markdown
 * 
 * @param {Object} reportData - Report data to format
 * @return {string} Markdown formatted report
 */
function formatReportMarkdown(reportData) {
  const tokenPercent = (role) => {
    return ((reportData.summary.tokensByRole[role] / reportData.summary.totalTokens) * 100).toFixed(1);
  };

  let markdown = `# Cursor Token Usage Report
  
## Summary
- **Project**: ${reportData.projectName}
- **Report Generated**: ${new Date(reportData.generatedAt).toLocaleString()}
- **Timeframe**: ${reportData.timeframe}
- **Sessions Analyzed**: ${reportData.summary.sessionsAnalyzed}

## Token Statistics
- **Total Tokens**: ${reportData.summary.totalTokens.toLocaleString()}
- **User Tokens**: ${reportData.summary.tokensByRole.user.toLocaleString()} (${tokenPercent('user')}%)
- **Assistant Tokens**: ${reportData.summary.tokensByRole.assistant.toLocaleString()} (${tokenPercent('assistant')}%)
- **System Tokens**: ${reportData.summary.tokensByRole.system.toLocaleString()} (${tokenPercent('system')}%)

## Usage Metrics
- **Total Messages**: ${reportData.summary.totalMessages.toLocaleString()}
- **Average Tokens Per Session**: ${reportData.summary.averageTokensPerSession.toLocaleString()}
- **Average Messages Per Session**: ${reportData.summary.averageMessagesPerSession.toLocaleString()}
- **Average Tokens Per Message**: ${Math.round(reportData.summary.totalTokens / Math.max(1, reportData.summary.totalMessages)).toLocaleString()}
`;

  if (reportData.sessions) {
    markdown += '\n## Session Details\n\n';
    
    reportData.sessions.forEach(session => {
      markdown += `### ${session.name} (${session.id})\n`;
      markdown += `- **Started**: ${new Date(session.startTime).toLocaleString()}\n`;
      markdown += `- **Duration**: ${session.durationFormatted || 'N/A'}\n`;
      markdown += `- **Tokens**: ${session.summary.totalTokens.toLocaleString()}\n`;
      markdown += `- **Messages**: ${session.summary.messageCount}\n`;
      
      if (session.metadata && session.metadata.tags && session.metadata.tags.length) {
        markdown += `- **Tags**: ${session.metadata.tags.join(', ')}\n`;
      }
      
      markdown += '\n';
    });
  }

  return markdown;
}

/**
 * Formats report as HTML
 * 
 * @param {Object} reportData - Report data to format
 * @return {string} HTML formatted report
 */
function formatReportHTML(reportData) {
  const tokenPercent = (role) => {
    return ((reportData.summary.tokensByRole[role] / reportData.summary.totalTokens) * 100).toFixed(1);
  };

  let html = `<!DOCTYPE html>
<html>
<head>
  <title>Cursor Token Usage Report - ${reportData.projectName}</title>
  <style>
    body { font-family: Arial, sans-serif; line-height: 1.6; max-width: 1000px; margin: 0 auto; padding: 20px; }
    h1 { color: #2c3e50; border-bottom: 1px solid #eee; padding-bottom: 10px; }
    h2 { color: #3498db; margin-top: 30px; }
    h3 { color: #2980b9; }
    .card { background: #f9f9f9; border-radius: 5px; padding: 15px; margin-bottom: 20px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); }
    .stats { display: flex; flex-wrap: wrap; gap: 20px; margin: 20px 0; }
    .stat-box { flex: 1; min-width: 200px; background: #fff; padding: 15px; border-radius: 5px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); }
    .stat-title { font-size: 14px; color: #7f8c8d; margin-bottom: 5px; }
    .stat-value { font-size: 24px; font-weight: bold; color: #2c3e50; }
    .session-list { margin-top: 30px; }
    .session-item { background: #fff; margin-bottom: 15px; padding: 15px; border-radius: 5px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); }
    .tag { display: inline-block; background: #e0f7fa; color: #00838f; padding: 2px 8px; border-radius: 3px; font-size: 12px; margin-right: 5px; }
  </style>
</head>
<body>
  <h1>Cursor Token Usage Report</h1>
  
  <div class="card">
    <p><strong>Project:</strong> ${reportData.projectName}</p>
    <p><strong>Report Generated:</strong> ${new Date(reportData.generatedAt).toLocaleString()}</p>
    <p><strong>Timeframe:</strong> ${reportData.timeframe}</p>
    <p><strong>Sessions Analyzed:</strong> ${reportData.summary.sessionsAnalyzed}</p>
  </div>
  
  <h2>Token Statistics</h2>
  
  <div class="stats">
    <div class="stat-box">
      <div class="stat-title">Total Tokens</div>
      <div class="stat-value">${reportData.summary.totalTokens.toLocaleString()}</div>
    </div>
    <div class="stat-box">
      <div class="stat-title">User Tokens</div>
      <div class="stat-value">${reportData.summary.tokensByRole.user.toLocaleString()} <small>(${tokenPercent('user')}%)</small></div>
    </div>
    <div class="stat-box">
      <div class="stat-title">Assistant Tokens</div>
      <div class="stat-value">${reportData.summary.tokensByRole.assistant.toLocaleString()} <small>(${tokenPercent('assistant')}%)</small></div>
    </div>
  </div>
  
  <h2>Usage Metrics</h2>
  
  <div class="stats">
    <div class="stat-box">
      <div class="stat-title">Total Messages</div>
      <div class="stat-value">${reportData.summary.totalMessages.toLocaleString()}</div>
    </div>
    <div class="stat-box">
      <div class="stat-title">Avg. Tokens/Session</div>
      <div class="stat-value">${reportData.summary.averageTokensPerSession.toLocaleString()}</div>
    </div>
    <div class="stat-box">
      <div class="stat-title">Avg. Messages/Session</div>
      <div class="stat-value">${reportData.summary.averageMessagesPerSession.toLocaleString()}</div>
    </div>
  </div>`;

  if (reportData.sessions) {
    html += `
  <h2>Session Details</h2>
  
  <div class="session-list">`;
    
    reportData.sessions.forEach(session => {
      html += `
    <div class="session-item">
      <h3>${session.name}</h3>
      <p><strong>ID:</strong> ${session.id}</p>
      <p><strong>Started:</strong> ${new Date(session.startTime).toLocaleString()}</p>
      <p><strong>Duration:</strong> ${session.durationFormatted || 'N/A'}</p>
      <p><strong>Tokens:</strong> ${session.summary.totalTokens.toLocaleString()}</p>
      <p><strong>Messages:</strong> ${session.summary.messageCount}</p>`;
      
      if (session.metadata && session.metadata.tags && session.metadata.tags.length) {
        html += `
      <p><strong>Tags:</strong> `;
        session.metadata.tags.forEach(tag => {
          html += `<span class="tag">${tag}</span>`;
        });
        html += `</p>`;
      }
      
      html += `
    </div>`;
    });
    
    html += `
  </div>`;
  }

  html += `
</body>
</html>`;

  return html;
}

/**
 * Helper function to format duration in ms to a human-readable string
 * 
 * @param {number} ms - Duration in milliseconds
 * @return {string} Formatted duration
 */
function formatDuration(ms) {
  if (ms < 0) return 'Invalid duration';
  
  const seconds = Math.floor(ms / 1000);
  const minutes = Math.floor(seconds / 60);
  const hours = Math.floor(minutes / 60);
  
  if (hours > 0) {
    return `${hours}h ${minutes % 60}m ${seconds % 60}s`;
  } else if (minutes > 0) {
    return `${minutes}m ${seconds % 60}s`;
  } else {
    return `${seconds}s`;
  }
}

// Export functions for external usage
module.exports = {
  initialize,
  startSession,
  logMessage,
  logConversation,
  endSession,
  getUsageSummary,
  generateReport
}; 