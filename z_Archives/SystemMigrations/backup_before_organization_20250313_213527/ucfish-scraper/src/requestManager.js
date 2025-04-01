/**
 * Request Manager Module
 * 
 * Handles HTTP requests with rate limiting, retries, and robust error handling.
 * 
 * @package ucfish-scraper
 * @since 1.0.0
 */

const axios = require('axios');
const PQueue = require('p-queue').default;
const fs = require('fs-extra');
const path = require('path');
const dotenv = require('dotenv');

// Load environment variables
dotenv.config({ path: path.join(__dirname, '../config/.env') });

class RequestManager {
  constructor(options = {}) {
    this.userAgents = [
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.1 Safari/605.1.15',
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:122.0) Gecko/20100101 Firefox/122.0',
      'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Edge/124.0.0.0 Safari/537.36'
    ];
    
    // If a user agent is provided in the environment, add it to the list
    if (process.env.USER_AGENT) {
      this.userAgents.unshift(process.env.USER_AGENT);
    }
    
    // Request configuration
    this.initialDelay = options.initialDelay || parseInt(process.env.REQUEST_DELAY || '2000', 10);
    this.backoffFactor = options.backoffFactor || 1.5;
    this.maxDelay = options.maxDelay || 30000;
    this.useJitter = options.useJitter !== undefined ? options.useJitter : true;
    this.maxRetries = options.maxRetries || 3;
    
    // Set up request queue
    this.concurrency = options.concurrency || parseInt(process.env.MAX_CONCURRENT_SCRAPES || '2', 10);
    this.queue = new PQueue({ concurrency: this.concurrency });
    
    // Set up axios instance
    this.axiosInstance = axios.create({
      timeout: 30000,
      headers: {
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8',
        'Accept-Language': 'en-US,en;q=0.5',
        'Cache-Control': 'no-cache',
        'Pragma': 'no-cache',
        'User-Agent': this.getRandomUserAgent()
      }
    });
    
    // Track failed URLs
    this.failedUrls = new Map();
    this.successUrls = new Set();
    
    // Log directory
    this.logDir = options.logDir || path.join(__dirname, '../logs');
    fs.ensureDirSync(this.logDir);
  }

  /**
   * Gets a random user agent from the list
   * 
   * @returns {string} A random user agent
   */
  getRandomUserAgent() {
    const index = Math.floor(Math.random() * this.userAgents.length);
    return this.userAgents[index];
  }

  /**
   * Calculates delay with exponential backoff and optional jitter
   * 
   * @param {number} retryCount The current retry count
   * @returns {number} The delay in milliseconds
   */
  calculateDelay(retryCount) {
    // Calculate exponential backoff
    let delay = this.initialDelay * Math.pow(this.backoffFactor, retryCount);
    
    // Apply maximum delay
    delay = Math.min(delay, this.maxDelay);
    
    // Apply jitter if enabled
    if (this.useJitter) {
      // Add random jitter of ±30%
      const jitterFactor = 0.7 + (Math.random() * 0.6); // 0.7 to 1.3
      delay = Math.floor(delay * jitterFactor);
    }
    
    return delay;
  }

  /**
   * Executes a request with retry logic
   * 
   * @param {Object} options The request options
   * @returns {Promise<Object>} The response
   */
  async executeRequest(options) {
    let retryCount = 0;
    let lastError = null;
    
    while (retryCount <= this.maxRetries) {
      try {
        // Rotate user agent on retries
        if (retryCount > 0) {
          options.headers = options.headers || {};
          options.headers['User-Agent'] = this.getRandomUserAgent();
        }
        
        // Execute the request
        const response = await this.axiosInstance(options);
        
        // Mark as successful
        this.successUrls.add(options.url);
        
        return response;
      } catch (error) {
        lastError = error;
        retryCount++;
        
        // Track failed URL
        this.failedUrls.set(options.url, {
          url: options.url,
          attempts: retryCount,
          lastError: error.message,
          timestamp: new Date().toISOString()
        });
        
        // Log the error
        console.error(`Request failed (attempt ${retryCount}/${this.maxRetries + 1}): ${options.url}`, error.message);
        
        // Stop retrying if we've reached max retries
        if (retryCount > this.maxRetries) {
          break;
        }
        
        // Calculate delay for next retry
        const delay = this.calculateDelay(retryCount);
        console.log(`Retrying in ${delay}ms...`);
        
        // Wait before retrying
        await new Promise(resolve => setTimeout(resolve, delay));
      }
    }
    
    // Save failed requests to log
    await this.saveFailedRequests();
    
    // If we get here, all retries failed
    throw lastError;
  }

  /**
   * Adds a request to the queue
   * 
   * @param {Object} options The request options
   * @returns {Promise<Object>} The response
   */
  async queueRequest(options) {
    // Set default headers if not provided
    options.headers = options.headers || {};
    if (!options.headers['User-Agent']) {
      options.headers['User-Agent'] = this.getRandomUserAgent();
    }
    
    // Add to queue
    return this.queue.add(() => this.executeRequest(options));
  }

  /**
   * Performs a GET request
   * 
   * @param {string} url The URL to request
   * @param {Object} options Additional options for axios
   * @returns {Promise<Object>} The response
   */
  async get(url, options = {}) {
    return this.queueRequest({
      url,
      method: 'GET',
      ...options
    });
  }

  /**
   * Returns the current queue size and status
   * 
   * @returns {Object} Queue status
   */
  getQueueStatus() {
    return {
      size: this.queue.size,
      pending: this.queue.pending,
      isPaused: this.queue.isPaused
    };
  }

  /**
   * Saves failed requests to a log file
   */
  async saveFailedRequests() {
    try {
      const failedRequestsLog = path.join(this.logDir, 'failed_requests.json');
      
      // Create an array from the Map entries
      const failedRequests = Array.from(this.failedUrls.values());
      
      await fs.writeJson(failedRequestsLog, {
        timestamp: new Date().toISOString(),
        count: failedRequests.length,
        requests: failedRequests
      }, { spaces: 2 });
    } catch (error) {
      console.error('Error saving failed requests log:', error.message);
    }
  }

  /**
   * Pauses the request queue
   */
  pauseQueue() {
    this.queue.pause();
  }

  /**
   * Resumes the request queue
   */
  resumeQueue() {
    this.queue.start();
  }

  /**
   * Clears the request queue
   */
  clearQueue() {
    this.queue.clear();
  }

  /**
   * Waits for all queued requests to complete
   */
  async waitForAll() {
    await this.queue.onIdle();
  }
}

module.exports = RequestManager; 