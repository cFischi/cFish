# Quick Reference Guide: cFish.io Software Inventory Management

## Daily Checklist
- [ ] Run daily health check (`daily-health-check.bat`)
- [ ] Review health report
- [ ] Sync memory files (`sync-memory-files.ps1`)
- [ ] Update JSON conversion (`convert-md-to-json.ps1`)
- [ ] Check error logs
- [ ] Verify system integration status

## Weekly Checklist
- [ ] Run file naming compliance check
- [ ] Verify directory structure
- [ ] Execute DMMS benchmarks
- [ ] Generate performance reports
- [ ] Update documentation references
- [ ] Test cross-platform integrations

## Monthly Checklist
- [ ] Complete inventory audit
- [ ] Archive obsolete scripts
- [ ] Update version documentation
- [ ] Test all integrations
- [ ] Generate monthly reports
- [ ] Review and update SOPs

## Common Commands

### System Health
```powershell
# Daily health check
./U7-Systems/Scripts/daily-health-check.bat

# Generate health report
./U5-Data/Scripts/generate-health-report.ps1

# Check file naming
./U7-Systems/Scripts/check-file-naming-standard.ps1
```

### Documentation
```powershell
# Sync memory files
./U5-Data/Scripts/sync-memory-files.ps1

# Convert to JSON
./U5-Data/Scripts/convert-md-to-json.ps1

# Update references
./U5-Data/Scripts/update-document-references.ps1
```

### Integration
```powershell
# Test integrations
./U4-Production/Tools/integration-test-suite.ps1

# Performance benchmark
./U5-Data/Scripts/dmms-performance-benchmark.ps1
```

## File Naming Quick Reference
```
ucf-[department].[function]-[description]-[date].[extension]

Departments:
U1 - Administration
U2 - Research
U3 - Operations
U4 - Production
U5 - Data
U6 - Marketing
U7 - Systems

Functions:
1 - Documentation
2 - Configuration
3 - Tools
4 - Scripts/Development
5 - Testing
6 - Automation
7 - Infrastructure
8 - Integration
9 - Miscellaneous
```

## Emergency Procedures Quick Reference

### System Issues
1. Document error
2. Access backup
3. Implement fix
4. Test solution
5. Update documentation
6. Report resolution

### Documentation Issues
1. Access backup
2. Verify content
3. Restore documentation
4. Update references
5. Verify integrity
6. Document incident

## Key Metrics Reference

### Performance Targets
- Script execution: < 500ms
- Sync success: > 99.9%
- Integration uptime: > 99.9%
- Error rate: < 0.1%

### Quality Targets
- Documentation accuracy: > 99%
- Reference integrity: > 99%
- Compliance rate: > 95%
- Update timeliness: > 90%

## Key Contacts
- System Issues: U7-Systems Lead
- Documentation: U5-Data Lead
- Integration: U4-Production Lead
- Emergency Support: U3-Operations Lead

## Related Documents
- Main SOP: ucf-u3.3-cfish-software-inventory-management-sop-20250326.md
- Inventory: ucf-u5.1-cfish-script-software-inventory-20250326.md
- Integration Specs: ucf-u7.3-system-integration-specifications-20250326.md

_Updated 03-26-2025 | AI: Cursor (Claude 3.7 Sonnet)_ 