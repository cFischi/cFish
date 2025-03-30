/**
 * Progress Monitor Module
 * 
 * Tracks and reports progress of the scraping process,
 * providing real-time statistics and estimates.
 * 
 * @package ucfish-scraper
 * @since 1.0.0
 */

const fs = require('fs-extra');
const path = require('path');

class ProgressMonitor {
  constructor(options = {}) {
    this.outputDir = options.outputDir || path.join(__dirname, '../output');
    this.logDir = options.logDir || path.join(this.outputDir, 'logs');
    this.progressFile = options.progressFile || path.join(this.logDir, 'progress.json');
    this.updateInterval = options.updateInterval || 5000; // 5 seconds
    
    // Initialize progress data
    this.progress = {
      status: 'idle',
      startTime: null,
      lastUpdateTime: null,
      totalUrls: 0,
      processedUrls: 0,
      failedUrls: 0,
      currentUrl: null,
      estimatedTimeRemaining: null,
      averageProcessingTime: null,
      processingTimes: [],
      recentProcessingTimes: [],
      problematicUrls: []
    };
    
    // Setup timer
    this.updateTimer = null;
    
    // Ensure log directory exists
    fs.ensureDirSync(this.logDir);
  }

  /**
   * Starts progress monitoring
   */
  start() {
    // Update initial state
    this.progress.status = 'running';
    this.progress.startTime = new Date();
    this.progress.lastUpdateTime = new Date();
    
    // Save initial progress
    this.saveProgress();
    
    // Setup timer for updates
    this.updateTimer = setInterval(() => this.saveProgress(), this.updateInterval);
    
    console.log('Progress monitoring started');
  }

  /**
   * Stops progress monitoring
   */
  stop() {
    // Update final state
    this.progress.status = 'completed';
    this.progress.lastUpdateTime = new Date();
    
    // Save final progress
    this.saveProgress();
    
    // Clear timer
    if (this.updateTimer) {
      clearInterval(this.updateTimer);
      this.updateTimer = null;
    }
    
    console.log('Progress monitoring stopped');
  }

  /**
   * Updates the total number of URLs to process
   * 
   * @param {number} total Total number of URLs
   */
  setTotalUrls(total) {
    this.progress.totalUrls = total;
    this.saveProgress();
  }

  /**
   * Increments the number of processed URLs
   */
  incrementProcessed() {
    this.progress.processedUrls++;
    this.saveProgress();
  }

  /**
   * Increments the number of failed URLs
   */
  incrementFailed() {
    this.progress.failedUrls++;
    this.saveProgress();
  }

  /**
   * Updates progress with the current URL being processed
   * 
   * @param {string} url The URL being processed
   */
  setCurrentUrl(url) {
    this.progress.currentUrl = url;
    this.saveProgress();
  }

  /**
   * Adds a problematic URL to the list
   * 
   * @param {string} url The problematic URL
   * @param {string} reason The reason for the issue
   */
  addProblematicUrl(url, reason) {
    this.progress.problematicUrls.push({
      url,
      reason,
      timestamp: new Date().toISOString()
    });
    
    // Keep only the latest 100 problematic URLs
    if (this.progress.problematicUrls.length > 100) {
      this.progress.problematicUrls.shift();
    }
    
    this.saveProgress();
  }

  /**
   * Records the processing time for a URL
   * 
   * @param {string} url The URL
   * @param {number} timeInMs Processing time in milliseconds
   */
  recordProcessingTime(url, timeInMs) {
    this.progress.processingTimes.push(timeInMs);
    
    // Keep only the latest 100 processing times for the full history
    if (this.progress.processingTimes.length > 100) {
      this.progress.processingTimes.shift();
    }
    
    // Keep the latest 10 for recent calculations
    this.progress.recentProcessingTimes.push(timeInMs);
    if (this.progress.recentProcessingTimes.length > 10) {
      this.progress.recentProcessingTimes.shift();
    }
    
    // Update average processing time
    this.updateAverageProcessingTime();
    
    // Update estimated time remaining
    this.updateEstimatedTimeRemaining();
  }

  /**
   * Updates the average processing time
   */
  updateAverageProcessingTime() {
    if (this.progress.recentProcessingTimes.length === 0) {
      this.progress.averageProcessingTime = null;
      return;
    }
    
    const total = this.progress.recentProcessingTimes.reduce((sum, time) => sum + time, 0);
    this.progress.averageProcessingTime = Math.round(total / this.progress.recentProcessingTimes.length);
  }

  /**
   * Updates the estimated time remaining
   */
  updateEstimatedTimeRemaining() {
    if (!this.progress.averageProcessingTime || this.progress.totalUrls === 0) {
      this.progress.estimatedTimeRemaining = null;
      return;
    }
    
    const remainingUrls = this.progress.totalUrls - this.progress.processedUrls - this.progress.failedUrls;
    if (remainingUrls <= 0) {
      this.progress.estimatedTimeRemaining = 0;
      return;
    }
    
    // Estimate based on recent processing times
    const estimatedMs = remainingUrls * this.progress.averageProcessingTime;
    
    // Convert to minutes
    this.progress.estimatedTimeRemaining = Math.round(estimatedMs / (60 * 1000));
  }

  /**
   * Updates overall progress
   * 
   * @param {number} current Number of URLs processed so far
   * @param {number} total Total number of URLs to process
   */
  updateProgress(current, total) {
    if (total > 0) {
      this.progress.totalUrls = total;
    }
    
    if (current >= 0) {
      // Calculate the difference to avoid double-counting
      const diff = current - (this.progress.processedUrls + this.progress.failedUrls);
      if (diff > 0) {
        this.progress.processedUrls += diff;
      }
    }
    
    // Update timestamp
    this.progress.lastUpdateTime = new Date();
    
    // Update estimated time remaining
    this.updateEstimatedTimeRemaining();
    
    // Save progress
    this.saveProgress();
  }

  /**
   * Saves current progress to file
   */
  saveProgress() {
    try {
      // Update the last update time
      this.progress.lastUpdateTime = new Date();
      
      // Calculate completion percentage
      const total = this.progress.totalUrls;
      const processed = this.progress.processedUrls + this.progress.failedUrls;
      
      this.progress.completionPercentage = total > 0 ? 
        Math.round((processed / total) * 100) : 0;
      
      // Calculate elapsed time
      if (this.progress.startTime) {
        const elapsed = new Date() - new Date(this.progress.startTime);
        this.progress.elapsedTimeMinutes = Math.round(elapsed / (60 * 1000));
      }
      
      // Save to file
      fs.writeJsonSync(this.progressFile, {
        ...this.progress,
        startTime: this.progress.startTime ? this.progress.startTime.toISOString() : null,
        lastUpdateTime: this.progress.lastUpdateTime.toISOString()
      }, { spaces: 2 });
    } catch (error) {
      console.error('Error saving progress:', error.message);
    }
  }

  /**
   * Generates a progress report
   * 
   * @returns {object} Progress report
   */
  generateReport() {
    // Calculate statistics
    const total = this.progress.totalUrls;
    const processed = this.progress.processedUrls;
    const failed = this.progress.failedUrls;
    const remaining = total - processed - failed;
    const successRate = processed > 0 ? Math.round((processed / (processed + failed)) * 100) : 0;
    
    const report = {
      status: this.progress.status,
      timestamp: new Date().toISOString(),
      startTime: this.progress.startTime ? this.progress.startTime.toISOString() : null,
      elapsedTimeMinutes: this.progress.elapsedTimeMinutes || 0,
      statistics: {
        total,
        processed,
        failed,
        remaining,
        completionPercentage: this.progress.completionPercentage || 0,
        successRate
      },
      timing: {
        averageProcessingTimeMs: this.progress.averageProcessingTime,
        estimatedTimeRemainingMinutes: this.progress.estimatedTimeRemaining
      },
      problematic: {
        count: this.progress.problematicUrls.length,
        urls: this.progress.problematicUrls.slice(0, 10) // Show only the 10 most recent
      }
    };
    
    // Save report
    const reportPath = path.join(this.logDir, 'progress_report.json');
    fs.writeJsonSync(reportPath, report, { spaces: 2 });
    
    return report;
  }

  /**
   * Gets the current progress data
   * 
   * @returns {object} Progress data
   */
  getProgress() {
    return {
      ...this.progress,
      startTime: this.progress.startTime ? this.progress.startTime.toISOString() : null,
      lastUpdateTime: this.progress.lastUpdateTime ? this.progress.lastUpdateTime.toISOString() : null
    };
  }
}

module.exports = ProgressMonitor; 