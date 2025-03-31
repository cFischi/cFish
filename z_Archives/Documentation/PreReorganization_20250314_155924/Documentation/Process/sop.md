# Standard Operating Procedure: Digital Organization

## Metadata
- **URL**: https://u.cfish.io/sop/digital-organization
- **Last Updated**: 03-13-2025
- **Purpose**: Establish standardized digital organization practices for cFish.io
- **Target Audience**: All cFish.io team members and stakeholders

---

## 1. Daily Digital Workflow

### 1.1 Morning Startup Routine (8:00-9:00 AM)
1. **System Health Check**
   - Run `tools/daily-health-check.ps1` to verify all systems are operational
   - Review any overnight sync issues from tYDiSync~ logs
   - Address critical errors before proceeding

2. **Dashboard Review**
   - Check ClickUp for today's prioritized tasks
   - Verify WordPress content updates from previous day
   - Review Notion documentation updates needed

3. **Synchronization Verification**
   - Ensure all MD-JSON synchronization is complete
   - Validate platform data consistency across tools
   - Run `sync-system/start-optimized-sync.bat` if needed

### 1.2 Midday Operations (12:00-1:00 PM)
1. **Progress Update**
   - Update ClickUp task statuses
   - Document completed work in appropriate Notion pages
   - Commit code changes with proper naming conventions

2. **Cross-Platform Verification**
   - Verify WordPress content reflects current state
   - Check Vendasta dashboard for client updates
   - Ensure ClickUp tasks align with actual progress

### 1.3 End-of-Day Wrap-up (4:00-5:00 PM)
1. **Documentation Update**
   - Ensure all work is documented in proper format
   - Update memory.md with daily achievements
   - Complete any required changelog entries

2. **System Backup**
   - Run `tools/daily-backup.ps1` to create versioned backups
   - Verify backup integrity
   - Push critical changes to GitHub repository

3. **Next-Day Preparation**
   - Review and update task list for next day
   - Document any unresolved issues in ClickUp
   - Set clear objectives for the next session

## 2. File Management System

### 2.1 Directory Structure Standards
Follow the established directory structure as created by `create-directory-structure.ps1`:

- **src/**: Source code organized by department
  - **/u1-overheads**: Business administration code
  - **/u2-research**: R&D projects and prototypes
  - **/u3-operations**: Operations management code
  - **/u4-production**: Production systems
  - **/u5-data-management**: Data handling and analysis
  - **/u6-social**: Social media and communications tools
  - **/u7-specialized**: Specialized departmental tools

- **docs/**: Documentation organized by type
  - **/guides**: User guides and tutorials
  - **/api**: API documentation
  - **/procedures**: Standard operating procedures
  - **/standards**: Coding and organizational standards

- **tests/**: Testing infrastructure
  - **/unit**: Unit tests
  - **/integration**: Integration tests
  - **/performance**: Performance testing scripts

- **resources/**: Shared resources
  - **/templates**: Document and code templates
  - **/assets**: Images, fonts, and other media
  - **/schemas**: Data schemas and definitions

- **config/**: Configuration files

- **tools/**: Utility scripts and tools

- **wp-content/**: WordPress specific files
  - **/themes**: WordPress themes
  - **/plugins/cfish-sync**: cFish synchronization plugin

- **sync-system/**: tYDiSync~ system
  - **/core**: Core functionality
  - **/agents**: Synchronization agents
  - **/utils**: Utility functions
  - **/config**: Configuration files

### 2.2 File Naming Conventions
Follow the file naming convention document in `docs/standards/file-naming-conventions.md`:

```
[CompanyPrefix]-[DeptNumber].[FunctionNumber]-[TaskIdentifier]-[Date].[extension]
```

Example: `ucf-u5.3-data-migration-20250313.js`

### 2.3 Document Formats and Templates

#### Standard Document Templates
- Use templates in `resources/templates/` directory
- Maintain consistent header format as per departmental standards
- Include metadata section in all documentation

#### File Formats by Purpose
- Documentation: Markdown (.md) with JSON equivalent (.json)
- Configuration: JSON or YAML (.json, .yaml)
- Code: Follow language-specific conventions

## 3. Version Control Practices

### 3.1 Git Workflow
1. **Branch Naming Convention**
   - Feature branches: `feature/[brief-description]`
   - Bug fixes: `bugfix/[issue-number]-[brief-description]`
   - Hotfixes: `hotfix/[brief-description]`

2. **Commit Message Format**
   ```
   [Department]: [Brief description]
   
   - Detailed explanation of changes
   - Additional context if needed
   
   Ref: [ClickUp task ID or Notion page link]
   ```

3. **Pull Request Process**
   - Create descriptive PR titles
   - Reference related ClickUp tasks
   - Ensure all tests pass before requesting review
   - Require at least one review before merging

### 3.2 Backups and Recovery
1. **Automated Backups**
   - Daily: Local incremental backups
   - Weekly: Full repository backup
   - Monthly: Offsite backup copy

2. **Recovery Procedure**
   - Document recovery steps in `docs/procedures/disaster-recovery.md`
   - Test recovery process quarterly
   - Maintain backup verification logs

## 4. Cross-Platform Integration

### 4.1 WordPress Integration
1. **Content Synchronization**
   - Use tYDiSync~ to maintain MD-JSON parity
   - Deploy WordPress content via established pipelines
   - Document content updates in ClickUp

2. **Plugin Management**
   - Store plugin configuration in version control
   - Document plugin dependencies and versions
   - Test plugin updates in staging environment first

### 4.2 ClickUp Integration
1. **Task Management**
   - Align ClickUp tasks with directory structure
   - Use consistent task naming conventions
   - Link tasks to relevant documentation

2. **Status Tracking**
   - Update task status at least twice daily
   - Use ClickUp automations for repetitive workflows
   - Document status changes in work logs

### 4.3 Notion Integration
1. **Knowledge Base Management**
   - Organize Notion pages by department
   - Maintain consistent page templates
   - Regularly update cross-references

2. **Document Synchronization**
   - Use tYDiSync~ to synchronize critical documentation
   - Verify Notion links remain valid
   - Document major updates in changelog

### 4.4 Vendasta Integration
1. **Client Management**
   - Update client status in both Vendasta and ClickUp
   - Maintain consistent client naming across platforms
   - Document client interactions in standardized format

## 5. Quality Assurance

### 5.1 Code Quality Standards
1. **Linting and Formatting**
   - Use ESLint for JavaScript code
   - Use PHPCS for WordPress PHP code
   - Configure Cursor's formatOnSave with 2-space tabs

2. **Testing Requirements**
   - Write unit tests for all new features
   - Maintain minimum 80% code coverage
   - Document testing approach for each module

### 5.2 Documentation Quality
1. **Review Process**
   - Review all documentation changes
   - Verify formatting consistency
   - Check links and references

2. **Documentation Testing**
   - Validate all code examples
   - Ensure screenshots are current
   - Test procedures with a new user perspective

### 5.3 Monitoring and Auditing
1. **System Monitoring**
   - Monitor tYDiSync~ performance and errors
   - Track WordPress uptime and performance
   - Log synchronization errors

2. **Regular Audits**
   - Conduct monthly file organization audits
   - Verify adherence to naming conventions
   - Validate cross-platform data consistency

## 6. Training and Onboarding

### 6.1 New Team Member Onboarding
1. **Documentation Introduction**
   - Review this SOP and file naming conventions
   - Complete digital organization tutorial
   - Set up development environment with correct settings

2. **Platform Access**
   - Provide access to required platforms (WordPress, ClickUp, Notion, Vendasta)
   - Configure appropriate permission levels
   - Document access grants in secure location

### 6.2 Continuous Learning
1. **Monthly Training Sessions**
   - Review updates to organizational practices
   - Share efficiency tips and tools
   - Address common questions and issues

2. **Documentation Updates**
   - Contribute improvements to documentation
   - Document lessons learned
   - Suggest optimizations to workflows

## 7. Emergency Procedures

### 7.1 Data Loss Prevention
1. **Prevention Measures**
   - Configure automatic save intervals in tools
   - Use versioned documents when possible
   - Commit changes frequently

2. **Recovery Options**
   - Document recovery from various failure scenarios
   - Maintain recovery point objectives (RPOs)
   - Test recovery paths quarterly

### 7.2 System Failure Response
1. **Synchronization Failures**
   - Document troubleshooting steps for tYDiSync~ issues
   - Maintain manual synchronization procedures as backup
   - Establish communication plan for outages

2. **Cross-Platform Issues**
   - Document procedures for handling inconsistencies
   - Establish priority platform for truth in conflicts
   - Define reconciliation process

## 8. Compliance and Documentation

### 8.1 Changelog Management
1. **Standard Format**
   ```
   ## [Version] - [YYYY-MM-DD]
   
   ### Added
   - [New feature description]
   
   ### Changed
   - [Change description]
   
   ### Fixed
   - [Bug fix description]
   ```

2. **Update Requirements**
   - Update changelog with all significant changes
   - Follow semantic versioning
   - Include date in ISO format

### 8.2 Memory.md Updates
1. **Entry Format**
   ```
   ## [Title] (MM-DD-YYYY)
   - [Achievement or task completed]
   - [Additional information]
   
   _Updated MM-DD-YYYY | AI: Cursor (Claude 3.7 Sonnet)_
   ```

2. **Update Protocol**
   - Add new entries at the top of the file
   - Include current date in format MM-DD-YYYY
   - Sign entries with appropriate signature line

## 4. System Maintenance

### 4.1 Routine Maintenance Tasks

1. **Daily Health Checks**
   - Execute daily health check script every morning
   - Review logs for warnings and errors
   - Address issues promptly based on severity

2. **Backup Procedures**
   - Run daily, weekly, and monthly backups as scheduled
   - Verify backup integrity regularly
   - Test restoration procedures quarterly

3. **Sync System Maintenance**
   - Monitor tYDiSync~ logs for errors
   - Check for path-related issues in sync logs
   - Run sync system path fix procedure if errors contain `sync-system/sync-system/state/` paths
   - Restart sync system after configuration changes

### 4.2 Troubleshooting Common Issues

1. **Sync Path Issues**
   - If sync system logs show path errors, run `ucf-u5.3-sync-system-path-fix-20250313.js`
   - Follow the procedure documented in `docs/procedures/ucf-u5.3-sync-system-path-fix-procedure-20250313.md`
   - Verify fix by checking the logs for continued errors

2. **File Organization Issues**
   - For files in incorrect locations, use migration script
   - Run `tools/ucf-u5.3-file-migration-20250313.ps1`
   - Follow the procedure documented in `docs/procedures/File-Migration-Procedure.md`

3. **System Resource Constraints**
   - For high CPU/memory usage, check running processes
   - Consider optimizing sync operations for lower resource usage
   - Adjust batch size and processing intervals in sync configuration

---

## Review and Updates

This SOP should be reviewed and updated quarterly to ensure it remains aligned with organizational needs and technological changes.

### Next Review Date: 06-13-2025

---

_Updated 03-13-2025 | AI: Cursor (Claude 3.7 Sonnet)_
