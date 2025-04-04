const fs = require('fs').promises;
const path = require('path');
const tf = require('@tensorflow/tfjs-node');

class TestOptimizer {
  constructor(config = {}) {
    this.config = {
      modelPath: config.modelPath || path.join(__dirname, '../models/test-optimizer'),
      metricsDir: config.metricsDir || path.join(__dirname, '../metrics'),
      historyLength: config.historyLength || 1000,
      predictionWindow: config.predictionWindow || 10,
      trainingEpochs: config.trainingEpochs || 100,
      ...config
    };

    this.model = null;
    this.history = [];
    this.resourceStats = [];
  }

  async initialize() {
    console.log('Initializing test optimizer...');

    // Create directories if they don't exist
    await fs.mkdir(path.dirname(this.config.modelPath), { recursive: true });
    await fs.mkdir(this.config.metricsDir, { recursive: true });

    // Load or create model
    try {
      this.model = await tf.loadLayersModel(`file://${this.config.modelPath}/model.json`);
      console.log('Loaded existing model');
    } catch (error) {
      console.log('Creating new model...');
      this.model = this.createModel();
      await this.saveModel();
    }

    // Load historical data
    await this.loadHistory();
  }

  createModel() {
    const model = tf.sequential();

    // Input features: test duration, resource usage, time of day, day of week
    model.add(tf.layers.dense({
      units: 64,
      activation: 'relu',
      inputShape: [7]
    }));

    model.add(tf.layers.dropout({ rate: 0.2 }));

    model.add(tf.layers.dense({
      units: 32,
      activation: 'relu'
    }));

    model.add(tf.layers.dropout({ rate: 0.2 }));

    // Output: predicted resource usage and optimal concurrency
    model.add(tf.layers.dense({
      units: 4,
      activation: 'sigmoid'
    }));

    model.compile({
      optimizer: tf.train.adam(0.001),
      loss: 'meanSquaredError',
      metrics: ['accuracy']
    });

    return model;
  }

  async saveModel() {
    await this.model.save(`file://${this.config.modelPath}`);
  }

  async loadHistory() {
    try {
      const files = await fs.readdir(this.config.metricsDir);
      const metricsFiles = files.filter(f => f.startsWith('metrics-')).sort();

      for (const file of metricsFiles.slice(-this.config.historyLength)) {
        const metrics = JSON.parse(
          await fs.readFile(path.join(this.config.metricsDir, file), 'utf8')
        );

        this.history.push(this.processMetrics(metrics));
      }

      console.log(`Loaded ${this.history.length} historical records`);
    } catch (error) {
      console.error('Error loading history:', error);
    }
  }

  processMetrics(metrics) {
    const timestamp = new Date(metrics.timestamp);
    
    return {
      timestamp,
      timeOfDay: timestamp.getHours() + timestamp.getMinutes() / 60,
      dayOfWeek: timestamp.getDay(),
      resourceMetrics: metrics.resourceStats.resourceMetrics,
      testMetrics: metrics.testStats
    };
  }

  async train() {
    if (this.history.length < this.config.predictionWindow) {
      console.log('Insufficient historical data for training');
      return;
    }

    console.log('Training model...');

    const trainingData = this.prepareTrainingData();
    const { inputs, outputs } = this.tensorifyData(trainingData);

    try {
      const result = await this.model.fit(inputs, outputs, {
        epochs: this.config.trainingEpochs,
        validationSplit: 0.2,
        callbacks: {
          onEpochEnd: (epoch, logs) => {
            console.log(`Epoch ${epoch + 1}: loss = ${logs.loss.toFixed(4)}`);
          }
        }
      });

      await this.saveModel();
      console.log('Model training completed');

      return result;
    } catch (error) {
      console.error('Error training model:', error);
      throw error;
    } finally {
      inputs.dispose();
      outputs.dispose();
    }
  }

  prepareTrainingData() {
    const trainingData = [];

    for (let i = this.config.predictionWindow; i < this.history.length; i++) {
      const window = this.history.slice(i - this.config.predictionWindow, i);
      const target = this.history[i];

      trainingData.push({
        input: this.extractFeatures(window),
        output: this.extractTargets(target)
      });
    }

    return trainingData;
  }

  extractFeatures(window) {
    const lastPoint = window[window.length - 1];
    
    return [
      lastPoint.timeOfDay / 24, // Normalize time to 0-1
      lastPoint.dayOfWeek / 6, // Normalize day to 0-1
      lastPoint.resourceMetrics.cpu / 100,
      lastPoint.resourceMetrics.memory / 100,
      lastPoint.resourceMetrics.disk / 100,
      lastPoint.testMetrics.active / 10, // Normalize test counts
      lastPoint.testMetrics.queued / 20
    ];
  }

  extractTargets(point) {
    return [
      point.resourceMetrics.cpu / 100,
      point.resourceMetrics.memory / 100,
      point.resourceMetrics.disk / 100,
      Math.min(point.testMetrics.active, 10) / 10 // Normalized optimal concurrency
    ];
  }

  tensorifyData(data) {
    const inputs = tf.tensor2d(
      data.map(d => d.input),
      [data.length, 7]
    );

    const outputs = tf.tensor2d(
      data.map(d => d.output),
      [data.length, 4]
    );

    return { inputs, outputs };
  }

  async predict(currentMetrics) {
    const input = tf.tensor2d(
      [this.extractFeatures([this.processMetrics(currentMetrics)])],
      [1, 7]
    );

    try {
      const prediction = await this.model.predict(input).array();
      return {
        predictedResources: {
          cpu: prediction[0][0] * 100,
          memory: prediction[0][1] * 100,
          disk: prediction[0][2] * 100
        },
        recommendedConcurrency: Math.max(1, Math.round(prediction[0][3] * 10))
      };
    } finally {
      input.dispose();
    }
  }

  async optimizeTestExecution(currentMetrics) {
    try {
      const prediction = await this.predict(currentMetrics);
      
      // Add current metrics to history
      this.history.push(this.processMetrics(currentMetrics));
      if (this.history.length > this.config.historyLength) {
        this.history.shift();
      }

      // Calculate optimal test configuration
      const config = this.calculateOptimalConfig(currentMetrics, prediction);

      // Retrain model periodically
      if (this.history.length % 100 === 0) {
        await this.train();
      }

      return config;
    } catch (error) {
      console.error('Error optimizing test execution:', error);
      
      // Return conservative defaults if optimization fails
      return {
        maxConcurrency: 2,
        testTimeout: 60000,
        retryAttempts: 2,
        prioritization: 'default'
      };
    }
  }

  calculateOptimalConfig(current, prediction) {
    // Base configuration
    const config = {
      maxConcurrency: prediction.recommendedConcurrency,
      testTimeout: 60000,
      retryAttempts: 2,
      prioritization: 'default'
    };

    // Adjust based on resource predictions
    if (prediction.predictedResources.cpu > 80 || 
        prediction.predictedResources.memory > 80) {
      config.maxConcurrency = Math.max(1, config.maxConcurrency - 1);
      config.testTimeout *= 1.5;
      config.prioritization = 'resource-conservative';
    }

    // Adjust based on current queue size
    if (current.testStats.queued > current.testStats.active * 2) {
      config.maxConcurrency = Math.min(
        config.maxConcurrency + 1,
        Math.floor(100 / prediction.predictedResources.cpu)
      );
      config.prioritization = 'queue-clearing';
    }

    // Adjust based on failure rates
    const failureRate = current.testStats.failed / 
      (current.testStats.completed + current.testStats.failed);
    
    if (failureRate > 0.1) {
      config.retryAttempts = 3;
      config.testTimeout *= 1.2;
      config.prioritization = 'reliability-focused';
    }

    return config;
  }

  getOptimizationStats() {
    return {
      historyLength: this.history.length,
      lastTraining: this.model.history?.history || null,
      currentConfig: this.calculateOptimalConfig(
        this.history[this.history.length - 1],
        this.predict(this.history[this.history.length - 1])
      )
    };
  }
}

module.exports = TestOptimizer; 