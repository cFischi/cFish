const ResourceMonitor = require('./resource-monitor');
const TestOptimizer = require('./test-optimizer');
const AlertManager = require('./alert-manager');
const WebSocket = require('ws');
const assert = require('assert');

class IntegrationTest {
  constructor() {
    this.monitor = new ResourceMonitor();
    this.optimizer = new TestOptimizer();
    this.alertManager = new AlertManager();
    this.testResults = {
      monitorTests: [],
      optimizerTests: [],
      alertTests: [],
      integrationTests: []
    };
  }

  async runTests() {
    console.log('Starting integration tests...');
    
    try {
      // Test individual components
      await this.testResourceMonitor();
      await this.testTestOptimizer();
      await this.testAlertManager();
      
      // Test component integration
      await this.testSystemIntegration();
      
      // Generate test report
      await this.generateTestReport();
      
    } catch (error) {
      console.error('Integration test failed:', error);
      throw error;
    }
  }

  async testResourceMonitor() {
    console.log('Testing Resource Monitor...');
    
    // Test resource metrics collection
    const metrics = await this.monitor.gatherMetrics();
    assert(metrics.cpu !== undefined, 'CPU metrics missing');
    assert(metrics.memory !== undefined, 'Memory metrics missing');
    assert(metrics.disk !== undefined, 'Disk metrics missing');
    
    this.testResults.monitorTests.push({
      name: 'Resource metrics collection',
      status: 'passed'
    });

    // Test WebSocket updates
    const wsClient = new WebSocket('ws://localhost:3000');
    await new Promise((resolve, reject) => {
      wsClient.on('message', (data) => {
        const message = JSON.parse(data);
        assert(message.type === 'update', 'Invalid message type');
        wsClient.close();
        resolve();
      });
      
      wsClient.on('error', reject);
    });

    this.testResults.monitorTests.push({
      name: 'WebSocket communication',
      status: 'passed'
    });
  }

  async testTestOptimizer() {
    console.log('Testing Test Optimizer...');
    
    // Test model creation
    const model = this.optimizer.createModel();
    assert(model !== null, 'Failed to create ML model');
    
    this.testResults.optimizerTests.push({
      name: 'Model creation',
      status: 'passed'
    });

    // Test prediction
    const prediction = await this.optimizer.predict({
      resourceStats: {
        resourceMetrics: {
          cpu: 50,
          memory: 60,
          disk: 70
        }
      }
    });
    
    assert(prediction.recommendedConcurrency > 0, 'Invalid concurrency prediction');
    
    this.testResults.optimizerTests.push({
      name: 'Resource prediction',
      status: 'passed'
    });
  }

  async testAlertManager() {
    console.log('Testing Alert Manager...');
    
    // Test alert creation
    const alert = {
      type: 'warning',
      resource: 'cpu',
      value: 75,
      threshold: 70,
      message: 'CPU usage high'
    };
    
    await this.alertManager.processAlert(alert, new Date());
    const activeAlerts = this.alertManager.getActiveAlerts();
    assert(activeAlerts.length > 0, 'Alert not created');
    
    this.testResults.alertTests.push({
      name: 'Alert creation and processing',
      status: 'passed'
    });

    // Test alert escalation
    const criticalAlert = {
      type: 'critical',
      resource: 'memory',
      value: 90,
      threshold: 80,
      message: 'Memory usage critical'
    };
    
    await this.alertManager.processAlert(criticalAlert, new Date());
    const escalatedAlerts = this.alertManager.getActiveAlerts()
      .filter(a => a.escalationLevel > 1);
    
    assert(escalatedAlerts.length > 0, 'Alert escalation failed');
    
    this.testResults.alertTests.push({
      name: 'Alert escalation',
      status: 'passed'
    });
  }

  async testSystemIntegration() {
    console.log('Testing System Integration...');
    
    // Test monitor-to-optimizer integration
    const metrics = await this.monitor.gatherMetrics();
    const optimization = await this.optimizer.optimizeTestExecution(metrics);
    
    assert(optimization.maxConcurrency !== undefined, 'Optimization failed');
    
    this.testResults.integrationTests.push({
      name: 'Monitor-Optimizer integration',
      status: 'passed'
    });

    // Test monitor-to-alert integration
    const highCPUMetrics = {
      ...metrics,
      resourceStats: {
        resourceMetrics: {
          cpu: 85,
          memory: metrics.memory,
          disk: metrics.disk
        }
      }
    };
    
    await this.monitor.checkResources(highCPUMetrics);
    const alerts = this.alertManager.getActiveAlerts();
    
    assert(alerts.some(a => a.resource === 'cpu'), 'Alert integration failed');
    
    this.testResults.integrationTests.push({
      name: 'Monitor-Alert integration',
      status: 'passed'
    });
  }

  async generateTestReport() {
    const report = {
      timestamp: new Date().toISOString(),
      summary: {
        total: 0,
        passed: 0,
        failed: 0
      },
      results: this.testResults
    };

    // Calculate summary
    for (const category of Object.values(this.testResults)) {
      for (const test of category) {
        report.summary.total++;
        if (test.status === 'passed') report.summary.passed++;
        else report.summary.failed++;
      }
    }

    // Save report
    const fs = require('fs').promises;
    const path = require('path');
    await fs.writeFile(
      path.join(__dirname, '../logs/integration-test-report.json'),
      JSON.stringify(report, null, 2)
    );

    console.log('Test report generated:', report);
    return report;
  }
}

module.exports = IntegrationTest;

// Run tests if executed directly
if (require.main === module) {
  const test = new IntegrationTest();
  test.runTests().catch(console.error);
} 