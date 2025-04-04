const fs = require('fs').promises;
const path = require('path');
const { execSync } = require('child_process');
const { createLogger } = require('./logger');

const logger = createLogger('dependency-verification');

async function verifyDependencies() {
  try {
    logger.info('Starting dependency verification...');
    
    // Read package.json
    const packageJson = JSON.parse(
      await fs.readFile(path.join(__dirname, '../package.json'), 'utf8')
    );

    // Verify core dependencies
    const coreDeps = {
      ...packageJson.dependencies,
      ...packageJson.optionalDependencies
    };

    const results = {
      verified: [],
      missing: [],
      outdated: [],
      errors: []
    };

    // Check each dependency
    for (const [name, version] of Object.entries(coreDeps)) {
      try {
        logger.info(`Verifying ${name}...`);
        
        // Try to require the package
        try {
          require(name);
          results.verified.push(name);
        } catch (err) {
          results.missing.push(name);
          logger.error(`Missing dependency: ${name}`);
          continue;
        }

        // Check for updates
        const latestVersion = execSync(`npm view ${name} version`, { 
          encoding: 'utf8' 
        }).trim();
        
        const currentVersion = version.replace('^', '');
        if (currentVersion !== latestVersion) {
          results.outdated.push({
            name,
            current: currentVersion,
            latest: latestVersion
          });
          logger.warn(`Outdated dependency: ${name} (${currentVersion} -> ${latestVersion})`);
        }
      } catch (err) {
        results.errors.push({
          name,
          error: err.message
        });
        logger.error(`Error verifying ${name}: ${err.message}`);
      }
    }

    // Generate report
    const report = {
      timestamp: new Date().toISOString(),
      nodeVersion: process.version,
      results
    };

    // Save report
    const reportPath = path.join(__dirname, '../metrics/dependency-report.json');
    await fs.mkdir(path.dirname(reportPath), { recursive: true });
    await fs.writeFile(reportPath, JSON.stringify(report, null, 2));

    // Log summary
    logger.info('\nDependency Verification Summary:');
    logger.info(`Verified: ${results.verified.length}`);
    logger.info(`Missing: ${results.missing.length}`);
    logger.info(`Outdated: ${results.outdated.length}`);
    logger.info(`Errors: ${results.errors.length}`);

    if (results.missing.length > 0 || results.errors.length > 0) {
      throw new Error('Dependency verification failed - see logs for details');
    }

    return report;
  } catch (error) {
    logger.error('Dependency verification failed:', error);
    throw error;
  }
}

// Run verification if called directly
if (require.main === module) {
  verifyDependencies().catch(err => {
    logger.error('Verification failed:', err);
    process.exit(1);
  });
}

module.exports = verifyDependencies; 