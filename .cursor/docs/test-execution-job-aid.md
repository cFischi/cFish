# Test Execution Job Aid

## Quick Start Commands

### Full Test Suite
```powershell
.\.cursor\scripts\run-all-tests.ps1
```

### Component-Specific Tests
```powershell
# D3.js visualization tests
npm run test:d3

# Standard component tests
npm test
```

### Installation Scripts Tests
```powershell
.\.cursor\scripts\test-installation-scripts.ps1
```

### Performance Tests
```powershell
.\.cursor\scripts\run-all-tests.ps1 -IncludePerformance
```

## Reports Location

| Test Type | Report Location |
|-----------|----------------|
| All Tests | `.cursor/test-results/reports/consolidated-report.html` |
| Component Tests | `coverage/lcov-report/index.html` |
| Installation Scripts | `.cursor/test-output/reports/test-report.html` |
| Performance Tests | `.cursor/performance-tools/reports/` |

## Critical Success Criteria

✅ **All critical tests pass**
✅ **Test coverage >95% for core components**
✅ **Process Tree render time <16ms**
✅ **Memory usage <100MB**
✅ **Update latency <50ms**

## Troubleshooting Commands

### Environment Issues
```powershell
# Check test environment
.\scripts\pre-flight-checks.ps1 -TestEnvironment

# Restore test environment
.\.cursor\scripts\restore-test-environment.ps1

# Clear test cache
.\.cursor\scripts\clear-test-cache.ps1

# Reset to clean environment
git clean -xdf
.\.cursor\scripts\setup-test-env.ps1
```

### Resource Depletion
```powershell
# Run system cleanup
.\.cursor\scripts\system-cleanup.ps1

# Run memory-constrained tests
.\.cursor\scripts\run-all-tests.ps1 -MemoryConstrained
```

### Security Checks
```powershell
# Run security scan
.\.cursor\scripts\security-scan.ps1

# Check for vulnerabilities
npm audit
```

## Documentation Updates

After test execution, update:
1. `.cursor/memory.md` - Test results entry
2. `.cursor/changelog.md` - Version changes
3. `.cursor/testing-plan.md` - Testing status updates

## Memory Entry Format
```markdown
## Test Execution Results (MM-DD-2025)
- Critical Test Status: [PASS/FAIL]
- Performance Test Status: [PASS/FAIL]
- Coverage: XX%
- Key Issues: [List issues]
- Next Steps: [List steps]

_Updated MM-DD-2025 | Human/AI: Name_
```

---

**For detailed instructions, refer to the [Test Execution SOP](./.cursor/docs/test-execution-sop.md).**

_Last Updated: 05-07-2025 | Version: 1.0.0_ 