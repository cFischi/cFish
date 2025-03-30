/**
 * WordPress Token Logger System
 * 
 * A utility for logging and analyzing token usage across WordPress projects.
 * This tracker works alongside the TokenTracker to provide historical analysis and reporting.
 * 
 * @package TokenLogger
 * @version 1.0.0
 */

const fs = require('fs');
const path = require('path');
const TokenTracker = require('./token-tracker');

/**
 * Token logger class for tracking token usage across sessions and projects.
 */
class TokenLogger {
  /**
   * Initialize the token logger with default values.
   * 
   * @param {string} logDir Directory to store log files
   */
  constructor(logDir = './.cursor/token-management/logs') {
    this.logDir = logDir;
    this.sessionLogs = [];
    this.projects = new Map();
    this.currentTracker = null;
    this.initialized = false;
    this.initializeLogger();
  }

  /**
   * Initialize the logger by creating log directory and loading existing logs.
   */
  initializeLogger() {
    try {
      // Create log directory if it doesn't exist
      if (!fs.existsSync(this.logDir)) {
        fs.mkdirSync(this.logDir, { recursive: true });
      }
      
      // Load existing logs
      this.loadLogs();
      this.initialized = true;
      console.log('Token logger initialized successfully');
    } catch (error) {
      console.error('Failed to initialize token logger:', error);
    }
  }

  /**
   * Load existing log files into memory.
   */
  loadLogs() {
    try {
      // Check if logs directory exists
      if (!fs.existsSync(this.logDir)) return;
      
      // Read log files
      const files = fs.readdirSync(this.logDir).filter(file => file.endsWith('.json'));
      
      files.forEach(file => {
        try {
          const filePath = path.join(this.logDir, file);
          const logData = JSON.parse(fs.readFileSync(filePath, 'utf8'));
          
          if (Array.isArray(logData)) {
            // Multiple sessions in a file
            this.sessionLogs.push(...logData);
          } else if (logData && logData.id) {
            // Single session
            this.sessionLogs.push(logData);
          }
        } catch (fileError) {
          console.warn(`Error loading log file ${file}:`, fileError);
        }
      });
      
      // Organize sessions by project
      this.organizeByProject();
      
      console.log(`Loaded ${this.sessionLogs.length} session logs`);
    } catch (error) {
      console.error('Error loading logs:', error);
    }
  }

  /**
   * Organize loaded session logs by project.
   */
  organizeByProject() {
    this.projects.clear();
    
    this.sessionLogs.forEach(session => {
      if (!session.project) return;
      
      if (!this.projects.has(session.project)) {
        this.projects.set(session.project, []);
      }
      
      this.projects.get(session.project).push(session);
    });
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
    // Create a new tracker if needed
    if (!this.currentTracker) {
      this.currentTracker = new TokenTracker();
    } else if (this.currentTracker.currentSession) {
      // End the current session if one exists
      this.endSession();
    }
    
    // Start a new session
    const session = this.currentTracker.startSession(sessionName, projectName, taskType, complexity);
    console.log(`Token logger started session: ${sessionName} (${projectName})`);
    
    return session;
  }

  /**
   * End the current tracking session and save to log.
   * 
   * @returns {object} Session data
   */
  endSession() {
    if (!this.currentTracker || !this.currentTracker.currentSession) {
      console.warn('No active session to end');
      return null;
    }
    
    // End the session in the tracker
    const session = this.currentTracker.endSession();
    
    // Add to session logs
    this.sessionLogs.push(session);
    
    // Update project organization
    if (!this.projects.has(session.project)) {
      this.projects.set(session.project, []);
    }
    this.projects.get(session.project).push(session);
    
    // Save to log file
    this.saveSessionLog(session);
    
    console.log(`Token logger ended session: ${session.name}`);
    return session;
  }

  /**
   * Track input message or prompt.
   * 
   * @param {string} content Content to track
   * @param {string} type Content type: 'text', 'code', or 'mixed'
   * @returns {object} Tracking data
   */
  trackInput(content, type = 'text') {
    if (!this.currentTracker || !this.currentTracker.currentSession) {
      console.warn('Cannot track input: No active session');
      return null;
    }
    
    return this.currentTracker.trackInput(content, type);
  }

  /**
   * Track output message or response.
   * 
   * @param {string} content Content to track
   * @param {string} type Content type: 'text', 'code', or 'mixed'
   * @returns {object} Tracking data
   */
  trackOutput(content, type = 'text') {
    if (!this.currentTracker || !this.currentTracker.currentSession) {
      console.warn('Cannot track output: No active session');
      return null;
    }
    
    return this.currentTracker.trackOutput(content, type);
  }

  /**
   * Save session data to a log file.
   * 
   * @param {object} session Session data to save
   */
  saveSessionLog(session) {
    if (!this.initialized) {
      console.warn('Logger not initialized, cannot save session log');
      return;
    }
    
    try {
      // Create a filename based on project and date
      const date = new Date(session.startTime).toISOString().split('T')[0];
      const projectSlug = session.project.toLowerCase().replace(/[^a-z0-9]/g, '-');
      const filename = `${projectSlug}-${date}.json`;
      const filePath = path.join(this.logDir, filename);
      
      // Read existing file or create new array
      let sessionArray = [];
      if (fs.existsSync(filePath)) {
        try {
          sessionArray = JSON.parse(fs.readFileSync(filePath, 'utf8'));
          if (!Array.isArray(sessionArray)) {
            sessionArray = [sessionArray];
          }
        } catch (readError) {
          console.warn(`Error reading existing log file ${filename}, creating new file:`, readError);
        }
      }
      
      // Add current session and save
      sessionArray.push(session);
      fs.writeFileSync(filePath, JSON.stringify(sessionArray, null, 2));
      
      console.log(`Session log saved to ${filename}`);
    } catch (error) {
      console.error('Error saving session log:', error);
    }
  }

  /**
   * Generate a report for the current session.
   * 
   * @returns {object} Session report
   */
  generateSessionReport() {
    if (!this.currentTracker) {
      console.warn('No active tracker for session report');
      return null;
    }
    
    return this.currentTracker.generateReport();
  }

  /**
   * Generate a project report for a specific project.
   * 
   * @param {string} projectName Project name to report on
   * @returns {object} Project report data
   */
  generateProjectReport(projectName) {
    if (!this.projects.has(projectName)) {
      console.warn(`No logs found for project: ${projectName}`);
      return null;
    }
    
    const projectSessions = this.projects.get(projectName);
    const taskTypes = {};
    let totalTokens = 0;
    let totalInputTokens = 0;
    let totalOutputTokens = 0;
    let sessionCount = projectSessions.length;
    
    // Analyze sessions by task type
    projectSessions.forEach(session => {
      totalTokens += session.totalTokens || 0;
      totalInputTokens += session.totalInputTokens || 0;
      totalOutputTokens += session.totalOutputTokens || 0;
      
      // Group by task type
      if (!taskTypes[session.taskType]) {
        taskTypes[session.taskType] = {
          count: 0,
          totalTokens: 0,
          avgTokens: 0,
          byComplexity: {
            'Low': { count: 0, totalTokens: 0 },
            'Medium': { count: 0, totalTokens: 0 },
            'High': { count: 0, totalTokens: 0 }
          }
        };
      }
      
      // Add to task type stats
      taskTypes[session.taskType].count++;
      taskTypes[session.taskType].totalTokens += session.totalTokens || 0;
      
      // Add to complexity stats
      if (session.complexity && taskTypes[session.taskType].byComplexity[session.complexity]) {
        taskTypes[session.taskType].byComplexity[session.complexity].count++;
        taskTypes[session.taskType].byComplexity[session.complexity].totalTokens += session.totalTokens || 0;
      }
    });
    
    // Calculate averages
    Object.keys(taskTypes).forEach(type => {
      taskTypes[type].avgTokens = Math.round(taskTypes[type].totalTokens / taskTypes[type].count);
      
      // Calculate complexity averages
      Object.keys(taskTypes[type].byComplexity).forEach(complexity => {
        const complexityData = taskTypes[type].byComplexity[complexity];
        if (complexityData.count > 0) {
          complexityData.avgTokens = Math.round(complexityData.totalTokens / complexityData.count);
        }
      });
    });
    
    // Find the most recent session
    const mostRecentSession = projectSessions.reduce((latest, session) => {
      if (!latest || new Date(session.startTime) > new Date(latest.startTime)) {
        return session;
      }
      return latest;
    }, null);
    
    // Generate the report
    const report = {
      projectName: projectName,
      sessionCount: sessionCount,
      totalTokens: totalTokens,
      avgTokensPerSession: Math.round(totalTokens / sessionCount),
      inputTokens: totalInputTokens,
      outputTokens: totalOutputTokens,
      inputOutputRatio: Math.round((totalInputTokens / totalOutputTokens) * 100) / 100,
      mostRecentSession: mostRecentSession ? {
        name: mostRecentSession.name,
        date: mostRecentSession.startTime,
        tokens: mostRecentSession.totalTokens
      } : null,
      taskTypeSummary: taskTypes,
      recommendations: this.generateProjectRecommendations(projectSessions, taskTypes)
    };
    
    return report;
  }

  /**
   * Generate optimization recommendations for a project.
   * 
   * @param {Array} sessions Project sessions
   * @param {object} taskTypes Task type analysis
   * @returns {Array} Recommendations
   */
  generateProjectRecommendations(sessions, taskTypes) {
    const recommendations = [];
    
    // Analyze input/output ratio
    const totalInputTokens = sessions.reduce((sum, session) => sum + (session.totalInputTokens || 0), 0);
    const totalOutputTokens = sessions.reduce((sum, session) => sum + (session.totalOutputTokens || 0), 0);
    const inputOutputRatio = totalInputTokens / totalOutputTokens;
    
    if (inputOutputRatio > 1.5) {
      recommendations.push('Input prompts are consistently larger than outputs. Consider using more concise prompts and leveraging template libraries.');
    }
    
    // Analyze budget utilization patterns
    const budgetUtilization = sessions.map(session => ({
      percentUsed: session.totalTokens / session.budget,
      taskType: session.taskType,
      complexity: session.complexity
    }));
    
    const highUtilizationCount = budgetUtilization.filter(item => item.percentUsed > 0.9).length;
    if (highUtilizationCount > sessions.length * 0.3) {
      recommendations.push('Multiple sessions are approaching or exceeding token budgets. Consider breaking complex tasks into smaller components.');
    }
    
    // Analyze task type patterns
    Object.keys(taskTypes).forEach(type => {
      const taskData = taskTypes[type];
      
      // Check for inefficient complexity allocation
      const lowComplexityAvg = taskData.byComplexity['Low'].avgTokens || 0;
      const lowComplexityBudget = this.getTypicalBudget(type, 'Low');
      
      if (lowComplexityAvg > lowComplexityBudget * 0.8 && taskData.byComplexity['Low'].count > 2) {
        recommendations.push(`Consider reclassifying some "${type}" tasks from Low to Medium complexity based on token usage patterns.`);
      }
    });
    
    // Add general recommendations
    recommendations.push('Implement structured prompt templates to reduce token usage variability.');
    recommendations.push('Use token optimization strategies found in wordpress-optimization-strategies.md for each task type.');
    
    return recommendations;
  }

  /**
   * Get typical token budget for a task type and complexity.
   * 
   * @param {string} taskType Task type
   * @param {string} complexity Complexity level
   * @returns {number} Budget estimate
   */
  getTypicalBudget(taskType, complexity) {
    // This mirrors the budget logic in TokenTracker
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
    
    if (!budgets[taskType]) {
      return 10000; // Default
    }
    
    if (!budgets[taskType][complexity]) {
      return budgets[taskType]['Medium']; // Default to medium
    }
    
    return budgets[taskType][complexity];
  }

  /**
   * Generate comprehensive analytics across all projects.
   * 
   * @returns {object} Analytics data
   */
  generateAnalytics() {
    const projectCount = this.projects.size;
    const sessionCount = this.sessionLogs.length;
    let totalTokens = 0;
    let totalInputTokens = 0;
    let totalOutputTokens = 0;
    
    // Task type distribution
    const taskTypeDistribution = {};
    // Complexity distribution
    const complexityDistribution = {
      'Low': 0,
      'Medium': 0,
      'High': 0
    };
    
    // Project statistics
    const projectStats = [];
    
    // Calculate token usage by project
    this.projects.forEach((sessions, projectName) => {
      let projectTokens = 0;
      sessions.forEach(session => {
        // Add to totals
        const sessionTokens = session.totalTokens || 0;
        projectTokens += sessionTokens;
        totalTokens += sessionTokens;
        totalInputTokens += session.totalInputTokens || 0;
        totalOutputTokens += session.totalOutputTokens || 0;
        
        // Add to task type distribution
        if (session.taskType) {
          if (!taskTypeDistribution[session.taskType]) {
            taskTypeDistribution[session.taskType] = {
              count: 0,
              tokens: 0
            };
          }
          taskTypeDistribution[session.taskType].count++;
          taskTypeDistribution[session.taskType].tokens += sessionTokens;
        }
        
        // Add to complexity distribution
        if (session.complexity && complexityDistribution[session.complexity] !== undefined) {
          complexityDistribution[session.complexity]++;
        }
      });
      
      // Add project stats
      projectStats.push({
        name: projectName,
        sessions: sessions.length,
        tokens: projectTokens,
        avgTokensPerSession: Math.round(projectTokens / sessions.length)
      });
    });
    
    // Sort projects by token usage
    projectStats.sort((a, b) => b.tokens - a.tokens);
    
    // Calculate percentages for task types
    Object.keys(taskTypeDistribution).forEach(type => {
      taskTypeDistribution[type].percentage = Math.round(taskTypeDistribution[type].count / sessionCount * 100);
      taskTypeDistribution[type].avgTokens = Math.round(taskTypeDistribution[type].tokens / taskTypeDistribution[type].count);
    });
    
    // Calculate time trends (by month)
    const monthlyTrends = this.calculateMonthlyTrends();
    
    // Generate the analytics report
    const analytics = {
      overview: {
        projectCount,
        sessionCount,
        totalTokens,
        avgTokensPerSession: Math.round(totalTokens / sessionCount),
        inputTokens: totalInputTokens,
        outputTokens: totalOutputTokens,
        inputOutputRatio: Math.round((totalInputTokens / totalOutputTokens) * 100) / 100
      },
      projects: projectStats,
      taskTypes: taskTypeDistribution,
      complexity: complexityDistribution,
      monthlyTrends,
      recommendations: this.generateOverallRecommendations()
    };
    
    return analytics;
  }

  /**
   * Calculate monthly token usage trends.
   * 
   * @returns {object} Monthly trends data
   */
  calculateMonthlyTrends() {
    const trends = {};
    
    this.sessionLogs.forEach(session => {
      if (!session.startTime) return;
      
      const date = new Date(session.startTime);
      const monthKey = `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}`;
      
      if (!trends[monthKey]) {
        trends[monthKey] = {
          sessions: 0,
          tokens: 0,
          inputTokens: 0,
          outputTokens: 0
        };
      }
      
      trends[monthKey].sessions++;
      trends[monthKey].tokens += session.totalTokens || 0;
      trends[monthKey].inputTokens += session.totalInputTokens || 0;
      trends[monthKey].outputTokens += session.totalOutputTokens || 0;
    });
    
    // Convert to array and sort by date
    const trendsArray = Object.keys(trends).map(month => ({
      month,
      ...trends[month],
      avgTokensPerSession: Math.round(trends[month].tokens / trends[month].sessions)
    }));
    
    trendsArray.sort((a, b) => a.month.localeCompare(b.month));
    
    return trendsArray;
  }

  /**
   * Generate overall recommendations based on analytics.
   * 
   * @returns {Array} Recommendations
   */
  generateOverallRecommendations() {
    const recommendations = [];
    
    // Analyze input/output ratio across all sessions
    const totalInputTokens = this.sessionLogs.reduce((sum, session) => sum + (session.totalInputTokens || 0), 0);
    const totalOutputTokens = this.sessionLogs.reduce((sum, session) => sum + (session.totalOutputTokens || 0), 0);
    const inputOutputRatio = totalInputTokens / totalOutputTokens;
    
    // Input/output recommendations
    if (inputOutputRatio > 1.5) {
      recommendations.push('Across all projects, input tokens significantly exceed output tokens. Implement more concise prompt templates.');
    }
    
    // Task type optimization
    const taskTypes = {};
    this.sessionLogs.forEach(session => {
      if (!session.taskType) return;
      
      if (!taskTypes[session.taskType]) {
        taskTypes[session.taskType] = {
          count: 0,
          tokens: 0,
          overBudget: 0
        };
      }
      
      taskTypes[session.taskType].count++;
      taskTypes[session.taskType].tokens += session.totalTokens || 0;
      
      // Check if over budget
      if (session.budget && session.totalTokens > session.budget) {
        taskTypes[session.taskType].overBudget++;
      }
    });
    
    // Identify task types with budget issues
    Object.keys(taskTypes).forEach(type => {
      const overBudgetPercentage = (taskTypes[type].overBudget / taskTypes[type].count) * 100;
      
      if (overBudgetPercentage > 20 && taskTypes[type].count >= 5) {
        recommendations.push(`${type} tasks frequently exceed token budgets (${Math.round(overBudgetPercentage)}% of sessions). Review complexity classifications and implement task-specific optimization strategies.`);
      }
    });
    
    // Monthly trend analysis
    const monthlyTrends = this.calculateMonthlyTrends();
    if (monthlyTrends.length >= 3) {
      // Check for increasing token usage trend
      const increasingTrend = monthlyTrends.slice(-3).every((month, i, arr) => {
        return i === 0 || month.avgTokensPerSession > arr[i-1].avgTokensPerSession;
      });
      
      if (increasingTrend) {
        recommendations.push('Token usage per session is steadily increasing over the past three months. Review recent projects for optimization opportunities.');
      }
    }
    
    // General recommendations
    recommendations.push('Implement token budgeting at the project planning stage based on historical data.');
    recommendations.push('Use the token optimization strategies document for targeted improvements.');
    recommendations.push('Conduct regular reviews of high-token-usage projects to identify patterns and optimization opportunities.');
    
    return recommendations;
  }

  /**
   * Export analytics data to a JSON file.
   * 
   * @param {string} filename Filename to save as
   * @returns {boolean} Success status
   */
  exportAnalyticsToFile(filename = 'token-analytics.json') {
    try {
      const analytics = this.generateAnalytics();
      const filePath = path.join(this.logDir, filename);
      
      fs.writeFileSync(filePath, JSON.stringify(analytics, null, 2));
      console.log(`Analytics exported to ${filePath}`);
      
      return true;
    } catch (error) {
      console.error('Error exporting analytics:', error);
      return false;
    }
  }

  /**
   * Generate an HTML report for visualization.
   * 
   * @param {string} filename Filename to save as
   * @returns {boolean} Success status
   */
  generateHtmlReport(filename = 'token-report.html') {
    try {
      const analytics = this.generateAnalytics();
      const filePath = path.join(this.logDir, filename);
      
      // Generate HTML content
      const html = `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>WordPress Token Usage Analytics</title>
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; margin: 0; padding: 20px; line-height: 1.6; color: #333; }
    .container { max-width: 1200px; margin: 0 auto; }
    h1, h2, h3 { color: #0073aa; }
    .card { background-color: #fff; border-radius: 5px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); padding: 20px; margin-bottom: 20px; }
    .stat { font-size: 24px; font-weight: bold; margin: 5px 0; }
    .stat-label { font-size: 14px; color: #666; }
    .stats-container { display: flex; flex-wrap: wrap; justify-content: space-between; }
    .stat-card { flex: 1; min-width: 200px; margin: 10px; background-color: #f9f9f9; padding: 15px; border-radius: 5px; }
    table { width: 100%; border-collapse: collapse; margin: 20px 0; }
    th, td { padding: 12px 15px; text-align: left; border-bottom: 1px solid #ddd; }
    th { background-color: #f5f5f5; font-weight: bold; }
    tr:hover { background-color: #f5f5f5; }
    .recommendations li { margin-bottom: 10px; line-height: 1.6; }
    .chart { height: 300px; margin: 20px 0; }
    .footer { margin-top: 30px; text-align: center; font-size: 14px; color: #666; }
  </style>
  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>
  <div class="container">
    <h1>WordPress Token Usage Analytics</h1>
    <p>Generated on ${new Date().toLocaleDateString()} at ${new Date().toLocaleTimeString()}</p>
    
    <div class="card">
      <h2>Overview</h2>
      <div class="stats-container">
        <div class="stat-card">
          <div class="stat">${analytics.overview.projectCount}</div>
          <div class="stat-label">Projects</div>
        </div>
        <div class="stat-card">
          <div class="stat">${analytics.overview.sessionCount}</div>
          <div class="stat-label">Sessions</div>
        </div>
        <div class="stat-card">
          <div class="stat">${analytics.overview.totalTokens.toLocaleString()}</div>
          <div class="stat-label">Total Tokens</div>
        </div>
        <div class="stat-card">
          <div class="stat">${analytics.overview.avgTokensPerSession.toLocaleString()}</div>
          <div class="stat-label">Avg Tokens/Session</div>
        </div>
        <div class="stat-card">
          <div class="stat">${analytics.overview.inputOutputRatio}</div>
          <div class="stat-label">Input/Output Ratio</div>
        </div>
      </div>
    </div>
    
    <div class="card">
      <h2>Projects</h2>
      <table>
        <thead>
          <tr>
            <th>Project</th>
            <th>Sessions</th>
            <th>Total Tokens</th>
            <th>Avg Tokens/Session</th>
          </tr>
        </thead>
        <tbody>
          ${analytics.projects.map(project => `
            <tr>
              <td>${project.name}</td>
              <td>${project.sessions}</td>
              <td>${project.tokens.toLocaleString()}</td>
              <td>${project.avgTokensPerSession.toLocaleString()}</td>
            </tr>
          `).join('')}
        </tbody>
      </table>
    </div>
    
    <div class="card">
      <h2>Task Type Distribution</h2>
      <div class="chart">
        <canvas id="taskTypeChart"></canvas>
      </div>
      <table>
        <thead>
          <tr>
            <th>Task Type</th>
            <th>Count</th>
            <th>Percentage</th>
            <th>Avg Tokens</th>
          </tr>
        </thead>
        <tbody>
          ${Object.keys(analytics.taskTypes).map(type => `
            <tr>
              <td>${type}</td>
              <td>${analytics.taskTypes[type].count}</td>
              <td>${analytics.taskTypes[type].percentage}%</td>
              <td>${analytics.taskTypes[type].avgTokens.toLocaleString()}</td>
            </tr>
          `).join('')}
        </tbody>
      </table>
    </div>
    
    <div class="card">
      <h2>Monthly Trends</h2>
      <div class="chart">
        <canvas id="trendsChart"></canvas>
      </div>
      <table>
        <thead>
          <tr>
            <th>Month</th>
            <th>Sessions</th>
            <th>Total Tokens</th>
            <th>Avg Tokens/Session</th>
          </tr>
        </thead>
        <tbody>
          ${analytics.monthlyTrends.map(month => `
            <tr>
              <td>${month.month}</td>
              <td>${month.sessions}</td>
              <td>${month.tokens.toLocaleString()}</td>
              <td>${month.avgTokensPerSession.toLocaleString()}</td>
            </tr>
          `).join('')}
        </tbody>
      </table>
    </div>
    
    <div class="card">
      <h2>Recommendations</h2>
      <ul class="recommendations">
        ${analytics.recommendations.map(rec => `<li>${rec}</li>`).join('')}
      </ul>
    </div>
    
    <div class="footer">
      <p>Generated by TokenLogger v1.0.0</p>
    </div>
  </div>

  <script>
    // Task Type Chart
    const taskTypeCtx = document.getElementById('taskTypeChart').getContext('2d');
    new Chart(taskTypeCtx, {
      type: 'pie',
      data: {
        labels: ${JSON.stringify(Object.keys(analytics.taskTypes))},
        datasets: [{
          data: ${JSON.stringify(Object.keys(analytics.taskTypes).map(type => analytics.taskTypes[type].count))},
          backgroundColor: ['#0073aa', '#00a0d2', '#00c1d2', '#00d1b2', '#00d18c', '#7fd100', '#d1c100', '#d17e00']
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            position: 'right'
          }
        }
      }
    });

    // Monthly Trends Chart
    const trendsCtx = document.getElementById('trendsChart').getContext('2d');
    new Chart(trendsCtx, {
      type: 'line',
      data: {
        labels: ${JSON.stringify(analytics.monthlyTrends.map(m => m.month))},
        datasets: [{
          label: 'Avg Tokens per Session',
          data: ${JSON.stringify(analytics.monthlyTrends.map(m => m.avgTokensPerSession))},
          borderColor: '#0073aa',
          backgroundColor: 'rgba(0, 115, 170, 0.1)',
          fill: true,
          tension: 0.1
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        scales: {
          y: {
            beginAtZero: true
          }
        }
      }
    });
  </script>
</body>
</html>
      `;
      
      fs.writeFileSync(filePath, html);
      console.log(`HTML report generated to ${filePath}`);
      
      return true;
    } catch (error) {
      console.error('Error generating HTML report:', error);
      return false;
    }
  }
}

// Example usage
/*
const logger = new TokenLogger();

// Start a session and track tokens
logger.startSession('Feature Implementation', 'WooCommerce Custom Extension', 'Code Implementation', 'Medium');

logger.trackInput('I need to implement a custom checkout field in WooCommerce that validates a customer\'s tax ID number.', 'text');
logger.trackOutput('I\'ll help you implement a custom checkout field for tax ID validation in WooCommerce. Here\'s how we can approach this:', 'text');

// End session
logger.endSession();

// Generate reports
const projectReport = logger.generateProjectReport('WooCommerce Custom Extension');
console.log(JSON.stringify(projectReport, null, 2));

// Generate analytics and export to HTML
logger.generateHtmlReport();
*/

// Export the TokenLogger class
module.exports = TokenLogger; 