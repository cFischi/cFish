# Test Execution SOP - cFish.io Testing Framework

## Overview
This Standard Operating Procedure (SOP) documents the process for executing the comprehensive test suite for cFish.io components, including visualization components, installation scripts, and cross-platform integrations.

## 1. Test Environment Preparation

### 1.1 System Requirements
- Windows 10 (19045 build or later)
- Minimum 8GB RAM (2GB available)
- Node.js 18.x or later
- PowerShell 7.x or later
- Administrative privileges for installation scripts testing

### 1.2 Environment Setup
1. Clone the repository to a local directory:
   ```powershell
   git clone https://github.com/cfish-io/cfish.io.git
   cd cfish.io
   ```

2. Install dependencies using the safe installation script:
   ```powershell
   .\scripts\safe-npm.ps1 install
   ```

3. Verify test environment:
   ```powershell
   .\scripts\pre-flight-checks.ps1 -TestEnvironment
   ```

### 1.3 Test Configuration
1. Configure test parameters in `.cursor/config/test-config.json`:
   ```json
   {
     "memoryLimits": {
       "perProcess": "256MB",
       "totalAllowed": "2GB",
       "swapThreshold": "1GB"
     },
     "timeouts": {
       "componentTests": 15000,
       "integrationTests": 30000,
       "e2eTests": 120000
     }
   }
   ```

2. Set up platform-specific configuration for cross-platform testing in `.cursor/config/platform-config.json`

## 2. Test Execution Process

### 2.1 Comprehensive Test Execution
1. Run all tests with the consolidated test runner:
   ```powershell
   .\.cursor\scripts\run-all-tests.ps1
   ```

2. View consolidated HTML report at `.cursor/test-results/reports/consolidated-report.html`

### 2.2 Component-Specific Testing
1. Run D3.js visualization component tests:
   ```powershell
   npm run test:d3
   ```

2. Run standard component tests:
   ```powershell
   npm test
   ```

3. View component test results in `coverage/lcov-report/index.html`

### 2.3 Installation Script Testing
1. Run installation script tests:
   ```powershell
   .\.cursor\scripts\test-installation-scripts.ps1
   ```

2. View script test results in `.cursor/test-output/reports/test-report.html`

### 2.4 Performance Testing
1. Run performance tests:
   ```powershell
   .\.cursor\scripts\run-all-tests.ps1 -IncludePerformance
   ```

2. View performance test results in `.cursor/performance-tools/reports/`

## 3. Test Validation Process

### 3.1 Critical Success Criteria
- All critical tests must pass (100%)
- Test coverage must exceed 95% for core components
- Performance metrics must meet specified thresholds:
  - Process Tree render time: <16ms
  - Memory usage: <100MB
  - Update latency: <50ms

### 3.2 Test Result Interpretation
1. Check test status in the consolidated report
2. Review any failed tests and their error messages
3. Analyze performance metrics against established baselines
4. Verify cross-platform compatibility metrics

### 3.3 Test Report Verification
1. Verify all test components executed successfully
2. Check that HTML reports were generated correctly
3. Validate test coverage metrics against targets
4. Ensure performance benchmarks meet requirements

## 4. Issue Resolution Process

### 4.1 Test Failure Resolution
1. Identify failed test(s) from the HTML report
2. Examine detailed error logs in `.cursor/test-results/logs/`
3. Reproduce the issue in isolation using the specific test case
4. Fix the underlying issue in the component or test
5. Re-run the specific test to validate the fix
6. Execute the full test suite to ensure no regressions

### 4.2 Performance Issue Resolution
1. Identify components not meeting performance targets
2. Run targeted performance tests with diagnostic tools
3. Analyze component rendering and memory usage patterns
4. Implement optimization strategies
5. Re-run performance tests to validate improvements

### 4.3 Cross-Platform Issue Resolution
1. Identify platform-specific test failures
2. Configure platform-specific test environment
3. Debug using platform-specific tools
4. Implement platform-specific fixes or compatibility layers
5. Re-run cross-platform tests to validate fixes

## 5. Documentation and Reporting

### 5.1 Test Execution Documentation
1. Document all test executions in `.cursor/memory.md`
2. Use the standard format:
   ```markdown
   ## Test Execution Results (MM-DD-2025)
   - Critical Test Status: [PASS/FAIL]
   - Performance Test Status: [PASS/FAIL]
   - Coverage: XX%
   - Key Issues: [List issues]
   - Next Steps: [List steps]
   
   _Updated MM-DD-2025 | Human/AI: Name_
   ```

### 5.2 Test Result Reporting
1. Store test HTML reports in designated directories
2. Capture screenshots of any visual test failures
3. Archive test logs with date stamps
4. Create summary reports for management review

### 5.3 Changelog Updates
1. Document test-related changes in `.cursor/changelog.md`
2. Follow the standard versioning format
3. Categorize changes as Added, Fixed, Improved, etc.
4. Include test metrics and improvements

## 6. Recovery Procedures

### 6.1 Test Environment Recovery
1. If tests fail due to environment issues:
   ```powershell
   .\.cursor\scripts\restore-test-environment.ps1
   ```

2. Clear test artifacts and cached data:
   ```powershell
   .\.cursor\scripts\clear-test-cache.ps1
   ```

3. Reset to a clean environment:
   ```powershell
   git clean -xdf
   .\.cursor\scripts\setup-test-env.ps1
   ```

### 6.2 System Resource Recovery
1. If system resources are depleted during testing:
   ```powershell
   .\.cursor\scripts\system-cleanup.ps1
   ```

2. Restart test execution with memory constraints:
   ```powershell
   .\.cursor\scripts\run-all-tests.ps1 -MemoryConstrained
   ```

## 7. Security Considerations

### 7.1 Secure Testing Practices
1. Never execute tests with elevated privileges unless required
2. Use dedicated test accounts for API/integration testing
3. Never use production credentials in test environments
4. Sanitize all test data containing sensitive information

### 7.2 Vulnerability Testing
1. Run security scan as part of test execution:
   ```powershell
   .\.cursor\scripts\security-scan.ps1
   ```

2. Verify all dependencies are up-to-date:
   ```powershell
   npm audit
   ```

## 8. Approval and Sign-off

This SOP was prepared by the U2-tYFeAiz department and approved for use by the U7-tYberius Designz department.

Last Updated: 05-07-2025
Version: 1.0.0

_This document follows the UcF documentation standards as specified in the Dreamflo system._ 