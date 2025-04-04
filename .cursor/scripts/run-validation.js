const ResourceMonitor = require('../modules/resource-monitor');
const MetricsCollector = require('../modules/metrics-collector');
const PlatformValidator = require('../modules/platform-validator');
const StageRunner = require('../modules/stage-runner');

class ValidationRunner {
  constructor() {
    this.monitor = new ResourceMonitor({
      memory: { warning: 70, critical: 85 },
      cpu: { warning: 60, critical: 75 }
    });
    
    this.metrics = new MetricsCollector({
      metricsDir: '.cursor/metrics',
      retentionDays: 7
    });
    
    this.validator = new PlatformValidator();
    this.runner = new StageRunner();

    // Set up event handlers
    this.monitor.on('memory-warning', this.handleMemoryWarning.bind(this));
    this.monitor.on('cpu-warning', this.handleCPUWarning.bind(this));
    this.monitor.on('memory-critical', this.handleMemoryCritical.bind(this));
    this.monitor.on('cpu-critical', this.handleCPUCritical.bind(this));
  }

  handleMemoryWarning(data) {
    console.log(`[Warning] Memory usage at ${data.usedPercent.toFixed(2)}%`);
    this.metrics.recordMetric('memory-warning', data);
  }

  handleCPUWarning(data) {
    console.log(`[Warning] CPU usage at ${data.usage.toFixed(2)}%`);
    this.metrics.recordMetric('cpu-warning', data);
  }

  handleMemoryCritical(data) {
    console.log(`[Critical] Memory usage at ${data.usedPercent.toFixed(2)}%`);
    this.metrics.recordMetric('memory-critical', data);
    this.runner.pauseCurrentStage();
  }

  handleCPUCritical(data) {
    console.log(`[Critical] CPU usage at ${data.usage.toFixed(2)}%`);
    this.metrics.recordMetric('cpu-critical', data);
    this.runner.pauseCurrentStage();
  }

  async run() {
    try {
      // Start monitoring
      console.log('Starting validation run...');
      await this.monitor.start();
      await this.metrics.startCollection();

      // Validate platform
      console.log('Validating platform...');
      const platformValidation = await this.validator.validateAll();
      await this.metrics.recordMetric('platform-validation', platformValidation);

      // Run installation stages
      console.log('Running installation stages...');
      const stageResults = await this.runner.runStages([
        'initialization',
        'dependency-check',
        'resource-validation',
        'installation',
        'configuration',
        'verification'
      ]);

      // Generate final report
      const monitorReport = await this.monitor.generateReport();
      const metricsReport = await this.metrics.generateSummaryReport();
      
      const finalReport = {
        timestamp: new Date().toISOString(),
        platformValidation,
        stageResults,
        monitoring: monitorReport,
        metrics: metricsReport
      };

      // Save final report
      await this.metrics.recordMetric('validation-report', finalReport);
      
      console.log('Validation completed successfully');
      console.log('Final Report:', JSON.stringify(finalReport, null, 2));

      return finalReport;
    } catch (error) {
      console.error('Validation failed:', error);
      throw error;
    } finally {
      // Ensure cleanup
      await this.monitor.stop();
      await this.metrics.stopCollection();
    }
  }
}

// Run validation if called directly
if (require.main === module) {
  const validator = new ValidationRunner();
  validator.run().catch(error => {
    console.error('Validation failed:', error);
    process.exit(1);
  });
} 