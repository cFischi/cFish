#!/usr/bin/env node

const TestRunner = require('./test-runner');
const TestSuite = require('./test-suite');
const yargs = require('yargs/yargs');
const { hideBin } = require('yargs/helpers');
const { spawn } = require('child_process');
const fs = require('fs').promises;
const path = require('path');
const moment = require('moment');

async function runTest(testFile) {
  return new Promise((resolve, reject) => {
    const test = spawn('node', [testFile], {
      stdio: ['pipe', 'pipe', 'pipe']
    });

    let output = '';
    let errors = '';

    test.stdout.on('data', (data) => {
      output += data.toString();
      console.log(data.toString()); // Show output in real-time
    });

    test.stderr.on('data', (data) => {
      errors += data.toString();
      console.error(data.toString()); // Show errors in real-time
    });

    test.on('close', (code) => {
      resolve({
        file: testFile,
        success: code === 0,
        output,
        errors,
        code
      });
    });

    test.on('error', (err) => {
      reject(err);
    });
  });
}

async function generateReport(results) {
  const reportDir = path.join(__dirname, '../logs/test-reports');
  await fs.mkdir(reportDir, { recursive: true });

  const timestamp = moment().format('YYYY-MM-DD-HH-mm-ss');
  const reportPath = path.join(reportDir, `test-report-${timestamp}.md`);

  const report = [
    '# Test Execution Report',
    `\nExecution Date: ${moment(results.startTime).format('YYYY-MM-DD HH:mm:ss')}`,
    '\n## Summary',
    `- Total Tests: ${results.summary.total}`,
    `- Passed: ${results.summary.passed}`,
    `- Failed: ${results.summary.failed}`,
    `- Duration: ${results.summary.duration}ms`,
    '\n## Test Results\n'
  ];

  for (const test of results.tests) {
    report.push(`### ${path.basename(test.file)}`);
    report.push(`Status: ${test.success ? '✓ Passed' : '✗ Failed'}`);
    if (!test.success) {
      report.push('\nErrors:');
      report.push('```');
      report.push(test.errors);
      report.push('```');
    }
    report.push('\nOutput:');
    report.push('```');
    report.push(test.output);
    report.push('```\n');
  }

  await fs.writeFile(reportPath, report.join('\n'));
  return reportPath;
}

async function main() {
  const argv = yargs(hideBin(process.argv))
    .usage('Usage: $0 [options]')
    .option('type', {
      alias: 't',
      describe: 'Type of tests to run',
      choices: ['unit', 'integration', 'e2e', 'chaos', 'all'],
      default: 'all'
    })
    .option('component', {
      alias: 'c',
      describe: 'Specific component to test',
      type: 'string'
    })
    .option('workflow', {
      alias: 'w',
      describe: 'Specific workflow to test',
      type: 'string'
    })
    .option('flow', {
      alias: 'f',
      describe: 'Specific user flow to test',
      type: 'string'
    })
    .option('system', {
      alias: 's',
      describe: 'Specific system for chaos testing',
      type: 'string'
    })
    .option('report', {
      alias: 'r',
      describe: 'Generate HTML report',
      type: 'boolean',
      default: true
    })
    .option('verbose', {
      alias: 'v',
      describe: 'Run with verbose logging',
      type: 'boolean',
      default: false
    })
    .help()
    .argv;

  // Configure verbose logging
  if (argv.verbose) {
    process.env.VERBOSE = 'true';
  }

  console.log('Test Configuration:');
  console.log('-------------------');
  console.log('Test Type:', argv.type);
  if (argv.component) console.log('Component:', argv.component);
  if (argv.workflow) console.log('Workflow:', argv.workflow);
  if (argv.flow) console.log('User Flow:', argv.flow);
  if (argv.system) console.log('System:', argv.system);
  console.log('Generate Report:', argv.report);
  console.log('Verbose Logging:', argv.verbose);
  console.log('-------------------\n');

  try {
    const testSuite = TestSuite;
    const runner = new TestRunner();
    let results;

    switch (argv.type) {
      case 'unit':
        if (argv.component) {
          results = await testSuite.runUnitTests(argv.component);
        } else {
          results = await runner.runUnitTests(testSuite.testConfig.unit);
        }
        break;

      case 'integration':
        if (argv.workflow) {
          results = await testSuite.runIntegrationTests(argv.workflow);
        } else {
          results = await runner.runIntegrationTests(testSuite.testConfig.integration);
        }
        break;

      case 'e2e':
        if (argv.flow) {
          results = await testSuite.runE2ETests(argv.flow);
        } else {
          results = await runner.runE2ETests(testSuite.testConfig.e2e);
        }
        break;

      case 'chaos':
        if (argv.system) {
          results = await testSuite.runChaosTests(argv.system);
        } else {
          results = await runner.runChaosTests(testSuite.testConfig.chaos);
        }
        break;

      case 'all':
      default:
        results = await runner.run();
        break;
    }

    if (argv.report) {
      const reportPath = await generateReport(results);
      console.log('\nTest Report:', reportPath);
    }

    if (results && !results.success) {
      console.error('\nTests failed:', results.error || 'Unknown error');
      process.exit(1);
    }

    console.log('\nAll tests completed successfully!');
  } catch (error) {
    console.error('Error during test execution:', error);
    process.exit(1);
  }
}

main().catch(error => {
  console.error('Unhandled error:', error);
  process.exit(1);
}); 