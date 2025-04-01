/**
 * tYDiSync~ - Optimized Synchronization System
 * 
 * Main entry point for the tYDiSync system.
 * 
 * @package tydisync
 * @since 1.0.0
 * @author cFish.io
 */

'use strict';

// Core dependencies
const fs = require('fs-extra');
const path = require('path');
const events = require('events');

// Agent modules
const AlphaAgent = require('../agents/alpha-agent');
const BetaAgent = require('../agents/beta-agent');
const GammaAgent = require('../agents/gamma-agent');
const DeltaAgent = require('../agents/delta-agent');
const EpsilonAgent = require('../agents/epsilon-agent');

// Utility modules
const logger = require('../utils/logger');
const config = require('../config/config');
const memoryOptimization = require('./memory-optimization');

// Create event emitter for inter-agent communication
const eventBus = new events.EventEmitter();
eventBus.setMaxListeners(20); // Increase max listeners to prevent warnings

/**
 * Main tYDiSync class
 */
class TYDiSync {
  constructor() {
    this.config = config;
    this.logger = logger;
    this.eventBus = eventBus;
    
    // Initialize agents
    this.alphaAgent = new AlphaAgent(this.eventBus, this.config);
    this.betaAgent = new BetaAgent(this.eventBus, this.config);
    this.gammaAgent = new GammaAgent(this.eventBus, this.config);
    this.deltaAgent = new DeltaAgent(this.eventBus, this.config);
    this.epsilonAgent = new EpsilonAgent(this.eventBus, this.config);
    
    // Setup process handlers
    this.setupProcessHandlers();
  }
  
  /**
   * Setup process handlers for graceful shutdown
   */
  setupProcessHandlers() {
    process.on('SIGINT', this.shutdown.bind(this));
    process.on('SIGTERM', this.shutdown.bind(this));
    process.on('uncaughtException', (error) => {
      this.logger.error('Uncaught exception:', error);
      this.shutdown();
    });
  }
  
  /**
   * Start the synchronization system
   */
  start() {
    this.logger.info('Starting tYDiSync~ Optimized Synchronization System...');
    
    // Apply memory optimization
    memoryOptimization.optimize();
    
    // Start agents in sequence
    this.epsilonAgent.start()
      .then(() => this.alphaAgent.start())
      .then(() => this.betaAgent.start())
      .then(() => this.gammaAgent.start())
      .then(() => this.deltaAgent.start())
      .then(() => {
        this.logger.info('All agents started successfully');
        this.logger.info('tYDiSync~ is now running');
      })
      .catch((error) => {
        this.logger.error('Failed to start tYDiSync~:', error);
        this.shutdown();
      });
  }
  
  /**
   * Shutdown the synchronization system
   */
  shutdown() {
    this.logger.info('Shutting down tYDiSync~...');
    
    // Stop agents in reverse sequence
    Promise.all([
      this.deltaAgent.stop(),
      this.gammaAgent.stop(),
      this.betaAgent.stop(),
      this.alphaAgent.stop(),
      this.epsilonAgent.stop()
    ])
    .then(() => {
      this.logger.info('All agents stopped successfully');
      this.logger.info('tYDiSync~ has been shut down');
      process.exit(0);
    })
    .catch((error) => {
      this.logger.error('Error during shutdown:', error);
      process.exit(1);
    });
  }
}

// Parse command line arguments
const args = process.argv.slice(2);
const options = {
  watch: args.includes('--watch'),
  verbose: args.includes('--verbose')
};

// Configure logger based on options
if (options.verbose) {
  logger.setLevel('debug');
} else {
  logger.setLevel('info');
}

// Create and start tYDiSync
const tydisync = new TYDiSync();
tydisync.start();

module.exports = TYDiSync; 