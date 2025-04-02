const fs = require('fs');
const path = require('path');

class DocumentationGenerator {
  constructor() {
    this.memoryPath = path.join(__dirname, '../md/memory.md');
    this.changelogPath = path.join(__dirname, '../md/changelog.md');
    this.operationalPath = path.join(__dirname, '../md/operational');
  }

  async generateDailyReport(metrics) {
    const date = new Date();
    const formattedDate = this.formatDate(date);
    
    const memoryEntry = this.createMemoryEntry(formattedDate, metrics);
    await this.updateMemoryFile(memoryEntry);
    
    if (this.isWeeklyReportDue(date)) {
      const changelogEntry = this.createChangelogEntry(formattedDate, metrics);
      await this.updateChangelogFile(changelogEntry);
    }
  }

  async generateOperationalReport(reportData) {
    const { cycle, metrics, baseline, recommendations } = reportData;
    const date = new Date();
    const formattedDate = this.formatDate(date);
    
    const reportEntry = this.createOperationalEntry(cycle, formattedDate, metrics, baseline, recommendations);
    await this.updateOperationalFile(cycle, reportEntry);
  }

  createMemoryEntry(date, metrics) {
    return `## Performance Summary (${date})
- Token Usage: Peak ${metrics.tokens.usage.peak}, Average ${metrics.tokens.usage.average}
- Efficiency: ${this.formatEfficiencyMetrics(metrics.tokens.efficiency)}
- Response Times: P95 ${metrics.performance.responseTimes.p95}ms, P99 ${metrics.performance.responseTimes.p99}ms
- System Health: ${this.formatSystemHealth(metrics.health)}

### Optimization Metrics
- Token Savings: ${this.calculateTokenSavings(metrics)}
- Performance Improvements: ${this.calculatePerformanceGains(metrics)}
- Resource Utilization: ${this.formatResourceUtilization(metrics)}

### Action Items
${this.generateActionItems(metrics)}

_Updated ${date} | AI: Cursor (Claude 3.7 Sonnet)_

`;
  }

  createChangelogEntry(date, metrics) {
    return `## [1.0.${this.getVersionIncrement()}] - ${date}

### System Health
- Token Usage Trends: ${this.analyzeTokenTrends(metrics)}
- Performance Metrics: ${this.analyzePerformanceMetrics(metrics)}
- Resource Utilization: ${this.analyzeResourceUtilization(metrics)}

### Optimization Impact
- Token Efficiency: ${this.calculateEfficiencyImpact(metrics)}
- Response Time Improvements: ${this.calculateResponseTimeImpact(metrics)}
- Resource Optimization: ${this.calculateResourceOptimization(metrics)}

### Recommendations
${this.generateRecommendations(metrics)}

`;
  }

  createOperationalEntry(cycle, date, metrics, baseline, recommendations) {
    return `## Operational ${cycle.charAt(0).toUpperCase() + cycle.slice(1)} Report (${date})

### Performance Metrics
${this.formatOperationalMetrics(metrics)}

### Baseline Comparison
${this.formatBaselineComparison(baseline)}

### Usage Patterns
${this.formatUsagePatterns(metrics)}

### Optimization Impact
${this.formatOptimizationImpact(metrics)}

### Recommendations
${this.formatRecommendations(recommendations)}

_Updated ${date} | AI: Cursor (Claude 3.7 Sonnet)_

`;
  }

  formatEfficiencyMetrics(efficiency) {
    let result = [];
    for (const [pillar, value] of efficiency.byPillar) {
      result.push(`${pillar}: ${(value * 100).toFixed(1)}%`);
    }
    return result.join(', ');
  }

  formatSystemHealth(health) {
    return `Memory ${(health.memory_usage * 100).toFixed(1)}%, CPU ${(health.cpu_utilization * 100).toFixed(1)}%, Error Rate ${(health.error_rates * 100).toFixed(2)}%`;
  }

  calculateTokenSavings(metrics) {
    const maxAllocation = 48000;
    const actualUsage = metrics.tokens.usage.average;
    const savings = maxAllocation - actualUsage;
    return `${savings} tokens (${((savings/maxAllocation) * 100).toFixed(1)}% below maximum)`;
  }

  calculatePerformanceGains(metrics) {
    const targetResponseTime = 150;
    const actualResponseTime = metrics.performance.responseTimes.p95;
    const improvement = targetResponseTime - actualResponseTime;
    return `${improvement}ms faster than target (${((improvement/targetResponseTime) * 100).toFixed(1)}% improvement)`;
  }

  formatResourceUtilization(metrics) {
    return `Memory: ${(metrics.health.memory_usage * 100).toFixed(1)}%, CPU: ${(metrics.health.cpu_utilization * 100).toFixed(1)}%`;
  }

  generateActionItems(metrics) {
    const items = [];
    
    if (metrics.tokens.usage.peak > 45000) {
      items.push('- Monitor token usage closely, approaching warning threshold');
    }
    
    if (metrics.performance.responseTimes.p95 > 140) {
      items.push('- Investigate response time optimization opportunities');
    }
    
    if (metrics.health.memory_usage > 0.75) {
      items.push('- Review memory utilization and optimization options');
    }
    
    return items.length > 0 ? items.join('\n') : '- No immediate action items required';
  }

  analyzeTokenTrends(metrics) {
    const usage = metrics.tokens.usage;
    const trend = usage.peak > usage.average ? 'increasing' : 'stable';
    return `${trend}, peak usage at ${((usage.peak/48000) * 100).toFixed(1)}% of limit`;
  }

  analyzePerformanceMetrics(metrics) {
    const p95 = metrics.performance.responseTimes.p95;
    return `P95 response time ${p95}ms, ${p95 <= 150 ? 'within' : 'exceeding'} target`;
  }

  analyzeResourceUtilization(metrics) {
    return `Memory utilization ${(metrics.health.memory_usage * 100).toFixed(1)}%, CPU utilization ${(metrics.health.cpu_utilization * 100).toFixed(1)}%`;
  }

  generateRecommendations(metrics) {
    const recommendations = [];
    
    if (metrics.tokens.usage.peak > 45000) {
      recommendations.push('- Consider implementing additional token optimization strategies');
    }
    
    if (metrics.performance.responseTimes.p95 > 140) {
      recommendations.push('- Evaluate caching opportunities for performance improvement');
    }
    
    if (metrics.health.memory_usage > 0.75) {
      recommendations.push('- Plan for resource scaling based on current utilization trends');
    }
    
    return recommendations.length > 0 ? recommendations.join('\n') : '- Continue monitoring current optimization strategies';
  }

  formatOperationalMetrics(metrics) {
    return `- Token Usage: ${this.formatTokenMetrics(metrics.token_usage)}
- Performance: ${this.formatPerformanceMetrics(metrics.performance)}
- Resource Utilization: ${this.formatResourceMetrics(metrics.resource_usage)}`;
  }

  formatBaselineComparison(baseline) {
    return Object.entries(baseline)
      .map(([metric, { current, baseline, trend }]) => 
        `- ${metric}: ${current} (${trend > 0 ? '+' : ''}${trend}% vs baseline of ${baseline})`)
      .join('\n');
  }

  formatUsagePatterns(metrics) {
    return `- Active Pillars: ${metrics.patterns.active_pillars.join(', ')}
- Resource Distribution: ${this.formatResourceDistribution(metrics.patterns.resource_distribution)}
- Peak Usage Times: ${this.formatPeakUsage(metrics.patterns.peak_usage)}`;
  }

  formatOptimizationImpact(metrics) {
    const { token_savings, performance_improvement } = metrics.patterns.optimization_impact;
    return `- Token Savings: ${this.formatTokenSavings(token_savings)}
- Performance Gains: ${this.formatPerformanceGains(performance_improvement)}`;
  }

  formatRecommendations(recommendations) {
    return recommendations
      .map(rec => `- ${rec}`)
      .join('\n');
  }

  async updateMemoryFile(entry) {
    let content = await fs.promises.readFile(this.memoryPath, 'utf8');
    const nextStepsMatch = content.match(/## Next Steps/);
    
    if (nextStepsMatch) {
      const position = nextStepsMatch.index;
      content = content.slice(0, position) + entry + content.slice(position);
    } else {
      content += entry;
    }
    
    await fs.promises.writeFile(this.memoryPath, content);
  }

  async updateChangelogFile(entry) {
    let content = await fs.promises.readFile(this.changelogPath, 'utf8');
    content = entry + content;
    await fs.promises.writeFile(this.changelogPath, content);
  }

  async updateOperationalFile(cycle, entry) {
    const cyclePath = path.join(this.operationalPath, `${cycle}_reports.md`);
    
    // Ensure directory exists
    await fs.promises.mkdir(this.operationalPath, { recursive: true });
    
    // Create file if it doesn't exist
    if (!fs.existsSync(cyclePath)) {
      await fs.promises.writeFile(cyclePath, `# ${cycle.charAt(0).toUpperCase() + cycle.slice(1)} Operational Reports\n\n`);
    }
    
    // Append new entry
    let content = await fs.promises.readFile(cyclePath, 'utf8');
    content = entry + content.replace(/^# .*\n\n/, '');
    await fs.promises.writeFile(cyclePath, `# ${cycle.charAt(0).toUpperCase() + cycle.slice(1)} Operational Reports\n\n${content}`);
  }

  formatDate(date) {
    const mm = String(date.getMonth() + 1).padStart(2, '0');
    const dd = String(date.getDate()).padStart(2, '0');
    const yyyy = date.getFullYear();
    return `${mm}-${dd}-${yyyy}`;
  }

  isWeeklyReportDue(date) {
    return date.getDay() === 0; // Sunday
  }

  getVersionIncrement() {
    return Math.floor(Date.now() / 1000) % 1000;
  }
}

module.exports = DocumentationGenerator; 