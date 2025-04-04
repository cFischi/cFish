const assert = require('assert');
const AlertCorrelation = require('./alert-correlation');

describe('AlertCorrelation', () => {
  let correlation;

  beforeEach(() => {
    correlation = new AlertCorrelation({
      correlationWindow: 300000, // 5 minutes
      patternThreshold: 3
    });
  });

  describe('Alert Processing', () => {
    it('should process a single alert', async () => {
      const alert = {
        id: 'test-1',
        resource: 'cpu',
        type: 'warning',
        value: 75,
        timestamp: new Date()
      };

      const result = await correlation.processAlert(alert);
      assert.strictEqual(result, null, 'Single alert should not create correlation');
    });

    it('should correlate related alerts', async () => {
      const alerts = [
        {
          id: 'test-1',
          resource: 'cpu',
          type: 'warning',
          value: 75,
          timestamp: new Date()
        },
        {
          id: 'test-2',
          resource: 'memory',
          type: 'warning',
          value: 80,
          timestamp: new Date(Date.now() + 1000)
        },
        {
          id: 'test-3',
          resource: 'processes',
          type: 'critical',
          value: 90,
          timestamp: new Date(Date.now() + 2000)
        }
      ];

      // Process alerts in sequence
      for (let i = 0; i < alerts.length - 1; i++) {
        await correlation.processAlert(alerts[i]);
      }

      // Process final alert and check correlation
      const result = await correlation.processAlert(alerts[alerts.length - 1]);
      
      assert(result, 'Should create correlation for related alerts');
      assert(result.pattern, 'Should identify pattern');
      assert.strictEqual(result.relatedAlerts.length, 2, 'Should find 2 related alerts');
    });
  });

  describe('Pattern Detection', () => {
    it('should identify patterns in alert sequence', async () => {
      const alerts = [
        {
          id: 'test-1',
          resource: 'cpu',
          type: 'warning',
          value: 75,
          timestamp: new Date()
        },
        {
          id: 'test-2',
          resource: 'memory',
          type: 'warning',
          value: 80,
          timestamp: new Date(Date.now() + 60000)
        },
        {
          id: 'test-3',
          resource: 'cpu',
          type: 'critical',
          value: 90,
          timestamp: new Date(Date.now() + 120000)
        }
      ];

      // Process all alerts
      for (const alert of alerts) {
        await correlation.processAlert(alert);
      }

      const stats = correlation.getStats();
      assert(stats.identifiedPatterns > 0, 'Should identify patterns');
      assert(stats.patternsByResource.cpu >= 1, 'Should track patterns by resource');
    });
  });

  describe('Recommendation Generation', () => {
    it('should generate recommendations for correlated alerts', async () => {
      const alerts = [
        {
          id: 'test-1',
          resource: 'cpu',
          type: 'warning',
          value: 75,
          timestamp: new Date()
        },
        {
          id: 'test-2',
          resource: 'memory',
          type: 'warning',
          value: 80,
          timestamp: new Date(Date.now() + 1000)
        }
      ];

      let recommendations;
      correlation.on('recommendations_available', (data) => {
        recommendations = data.recommendations;
      });

      // Process alerts
      for (const alert of alerts) {
        await correlation.processAlert(alert);
      }

      assert(recommendations, 'Should generate recommendations');
      assert(recommendations.length > 0, 'Should have at least one recommendation');
      assert.strictEqual(recommendations[0].type, 'resource_optimization', 'Should recommend resource optimization');
    });
  });

  describe('Alert Cleanup', () => {
    it('should clean up old alerts', async () => {
      const oldAlert = {
        id: 'old-1',
        resource: 'cpu',
        type: 'warning',
        value: 75,
        timestamp: new Date(Date.now() - 600000) // 10 minutes ago
      };

      const newAlert = {
        id: 'new-1',
        resource: 'cpu',
        type: 'warning',
        value: 80,
        timestamp: new Date()
      };

      await correlation.processAlert(oldAlert);
      await correlation.processAlert(newAlert);

      correlation.cleanupOldAlerts();

      const stats = correlation.getStats();
      assert.strictEqual(stats.alertsByResource.cpu, 1, 'Should only keep recent alert');
    });
  });

  describe('Statistics', () => {
    it('should track correlation statistics', async () => {
      const alerts = [
        {
          id: 'test-1',
          resource: 'cpu',
          type: 'warning',
          value: 75,
          timestamp: new Date()
        },
        {
          id: 'test-2',
          resource: 'memory',
          type: 'warning',
          value: 80,
          timestamp: new Date(Date.now() + 1000)
        }
      ];

      // Process alerts
      for (const alert of alerts) {
        await correlation.processAlert(alert);
      }

      const stats = correlation.getStats();
      assert(typeof stats.activeCorrelations === 'number', 'Should track active correlations');
      assert(typeof stats.identifiedPatterns === 'number', 'Should track identified patterns');
      assert(stats.alertsByResource.cpu === 1, 'Should track alerts by resource');
      assert(stats.alertsByResource.memory === 1, 'Should track alerts by resource');
    });
  });
}); 