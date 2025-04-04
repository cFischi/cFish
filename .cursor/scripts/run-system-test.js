const { runValidation } = require('./test-validation');
const fs = require('fs').promises;
const path = require('path');
const moment = require('moment');

async function updateMemoryFile(results) {
  const memoryPath = path.join(__dirname, '../md/memory.md');
  const timestamp = moment().format('MM-DD-YYYY');
  
  const entry = `## System Test Results (${timestamp})

### Test Execution Summary
${results.map(r => `- **${r.component}**: ${r.status}\n  ${r.details.join('\n  ')}`).join('\n\n')}

### Next Steps
1. Address any failed tests and validation errors
2. Implement remaining monitoring dashboard components
3. Complete alert system implementation
4. Enhance error recovery mechanisms
5. Deploy process tree visualization

_Updated ${timestamp} | AI: Cursor (Claude 3.7 Sonnet)_\n\n`;

  try {
    const content = await fs.readFile(memoryPath, 'utf8');
    const updatedContent = entry + content;
    await fs.writeFile(memoryPath, updatedContent);
  } catch (error) {
    console.error('Error updating memory.md:', error);
    throw error;
  }
}

async function runSystemTest() {
  console.log('Starting comprehensive system test...\n');
  
  const results = [];
  let testsPassed = true;

  try {
    // Run validation tests
    const validationSuccess = await runValidation();
    results.push({
      component: 'Core Validation',
      status: validationSuccess ? 'PASSED' : 'FAILED',
      details: [
        'Resource monitoring system validated',
        'Progress monitoring system checked',
        'Staged installer functionality verified',
        'Component integration tested'
      ]
    });

    testsPassed = testsPassed && validationSuccess;

    // Document results
    await updateMemoryFile(results);

    if (testsPassed) {
      console.log('\nSystem test completed successfully!');
      console.log('Results have been documented in memory.md');
    } else {
      console.error('\nSystem test completed with failures.');
      console.error('Check memory.md for details and next steps.');
    }

    return testsPassed;
  } catch (error) {
    console.error('\nSystem test failed with error:', error);
    results.push({
      component: 'System Test',
      status: 'ERROR',
      details: [
        `Test execution error: ${error.message}`,
        'Check logs for detailed error information',
        'Manual intervention may be required'
      ]
    });

    await updateMemoryFile(results);
    return false;
  }
}

// Run test if called directly
if (require.main === module) {
  runSystemTest().then(success => {
    process.exit(success ? 0 : 1);
  });
}

module.exports = { runSystemTest }; 