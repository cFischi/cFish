const TestOptimizer = require('./test-optimizer');
const fs = require('fs').promises;
const path = require('path');
const tf = require('@tensorflow/tfjs-node');

class PerformanceTuner {
  constructor(config = {}) {
    this.config = {
      metricsDir: path.join(__dirname, '../metrics'),
      modelDir: path.join(__dirname, '../models'),
      hyperparameters: {
        learningRates: [0.001, 0.0005, 0.0001],
        batchSizes: [32, 64, 128],
        epochs: [50, 100, 200],
        layers: [
          [64, 32],
          [128, 64, 32],
          [256, 128, 64, 32]
        ]
      },
      validationSplit: 0.2,
      ...config
    };

    this.optimizer = new TestOptimizer();
    this.results = [];
  }

  async tune() {
    console.log('Starting performance tuning...');

    try {
      // Load historical data
      const data = await this.loadHistoricalData();
      
      // Perform hyperparameter tuning
      await this.tuneHyperparameters(data);
      
      // Optimize WebSocket settings
      await this.optimizeWebSocket();
      
      // Enhance data persistence
      await this.enhanceDataPersistence();
      
      // Generate tuning report
      await this.generateReport();
      
    } catch (error) {
      console.error('Performance tuning failed:', error);
      throw error;
    }
  }

  async loadHistoricalData() {
    const files = await fs.readdir(this.config.metricsDir);
    const metricsFiles = files.filter(f => f.startsWith('metrics-'));
    
    const data = [];
    for (const file of metricsFiles) {
      const metrics = JSON.parse(
        await fs.readFile(path.join(this.config.metricsDir, file), 'utf8')
      );
      data.push(metrics);
    }
    
    return data;
  }

  async tuneHyperparameters(data) {
    console.log('Tuning hyperparameters...');
    
    const bestParams = {
      learningRate: null,
      batchSize: null,
      epochs: null,
      layers: null,
      performance: -Infinity
    };

    for (const learningRate of this.config.hyperparameters.learningRates) {
      for (const batchSize of this.config.hyperparameters.batchSizes) {
        for (const epochs of this.config.hyperparameters.epochs) {
          for (const layers of this.config.hyperparameters.layers) {
            const performance = await this.evaluateModel({
              learningRate,
              batchSize,
              epochs,
              layers
            }, data);

            if (performance > bestParams.performance) {
              bestParams.learningRate = learningRate;
              bestParams.batchSize = batchSize;
              bestParams.epochs = epochs;
              bestParams.layers = layers;
              bestParams.performance = performance;
            }

            this.results.push({
              params: { learningRate, batchSize, epochs, layers },
              performance
            });
          }
        }
      }
    }

    console.log('Best hyperparameters found:', bestParams);
    return bestParams;
  }

  async evaluateModel(params, data) {
    const model = tf.sequential();
    
    // Input layer
    model.add(tf.layers.dense({
      units: params.layers[0],
      activation: 'relu',
      inputShape: [7]
    }));

    // Hidden layers
    for (let i = 1; i < params.layers.length; i++) {
      model.add(tf.layers.dense({
        units: params.layers[i],
        activation: 'relu'
      }));
    }

    // Output layer
    model.add(tf.layers.dense({
      units: 4,
      activation: 'sigmoid'
    }));

    model.compile({
      optimizer: tf.train.adam(params.learningRate),
      loss: 'meanSquaredError',
      metrics: ['accuracy']
    });

    // Prepare data
    const { inputs, outputs } = this.optimizer.tensorifyData(
      this.optimizer.prepareTrainingData(data)
    );

    // Train model
    const result = await model.fit(inputs, outputs, {
      batchSize: params.batchSize,
      epochs: params.epochs,
      validationSplit: this.config.validationSplit,
      verbose: 0
    });

    // Calculate performance score
    const performance = 1 - result.history.val_loss[result.history.val_loss.length - 1];

    inputs.dispose();
    outputs.dispose();
    model.dispose();

    return performance;
  }

  async optimizeWebSocket() {
    console.log('Optimizing WebSocket communication...');
    
    // Implement WebSocket optimization logic
    const wsConfig = {
      compression: true,
      maxPayloadSize: 1024 * 16, // 16KB
      batchInterval: 100, // ms
      heartbeatInterval: 30000 // 30s
    };

    await fs.writeFile(
      path.join(__dirname, '../config/websocket.json'),
      JSON.stringify(wsConfig, null, 2)
    );
  }

  async enhanceDataPersistence() {
    console.log('Enhancing data persistence...');
    
    // Implement data persistence optimization
    const persistenceConfig = {
      compression: {
        enabled: true,
        algorithm: 'gzip',
        level: 6
      },
      batching: {
        enabled: true,
        maxSize: 1000,
        flushInterval: 5000
      },
      storage: {
        type: 'file',
        path: '../data',
        retention: '30d'
      }
    };

    await fs.writeFile(
      path.join(__dirname, '../config/persistence.json'),
      JSON.stringify(persistenceConfig, null, 2)
    );
  }

  async generateReport() {
    const report = {
      timestamp: new Date().toISOString(),
      hyperparameterTuning: {
        results: this.results,
        bestParams: this.results.reduce((best, current) => 
          current.performance > best.performance ? current : best
        )
      },
      websocketOptimization: {
        config: JSON.parse(
          await fs.readFile(path.join(__dirname, '../config/websocket.json'), 'utf8')
        )
      },
      persistenceOptimization: {
        config: JSON.parse(
          await fs.readFile(path.join(__dirname, '../config/persistence.json'), 'utf8')
        )
      }
    };

    await fs.writeFile(
      path.join(__dirname, '../logs/performance-tuning-report.json'),
      JSON.stringify(report, null, 2)
    );

    console.log('Performance tuning report generated:', report);
    return report;
  }
}

module.exports = PerformanceTuner;

// Run tuning if executed directly
if (require.main === module) {
  const tuner = new PerformanceTuner();
  tuner.tune().catch(console.error);
} 