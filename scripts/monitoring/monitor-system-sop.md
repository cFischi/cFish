# UcF Monitoring System - Standard Operating Procedure
**Version:** 1.0.0
**Created:** 05-09-2025
**Department:** U7 - Systems

## Overview
This document outlines the standard operating procedures for the UcF monitoring system implemented for the cFish.io relaunch. The monitoring system provides real-time tracking of system resources, process states, and application health with automated alerts and remediation capabilities.

## System Components
- **Monitor Scripts**: PowerShell scripts for data collection and monitoring
- **Configuration System**: JSON-based configuration files with customizable thresholds
- **Alert System**: Email and dashboard notifications for threshold violations
- **Dashboard**: Real-time visualization of system metrics
- **Remediation System**: Automated fixes for critical issues

## Monitoring System Setup
### Initial Configuration
1. Verify configuration files in `.cursor/config/monitoring/`:
   - `monitoring-config.json`: Primary configuration
   - `alert-config.json`: Alert settings

2. Customize thresholds as needed:
   ```json
   "Thresholds": {
     "Memory": {
       "Warning": 75,
       "Critical": 85,
       "Emergency": 90
     }
   }
   ```

3. Configure alert recipients:
   ```json
   "Email": {
     "Recipients": ["admin@cfish.io", "alerts@cfish.io"]
   }
   ```

4. Deploy the monitoring system:
   ```powershell
   .\scripts\deploy-monitoring-system.ps1
   ```

## Regular Monitoring Tasks
### Daily Checks (8:00 AM)
1. Review the monitoring dashboard for system status
2. Check alert history for overnight issues
3. Verify scheduled task is running properly:
   ```powershell
   Get-ScheduledTask -TaskName "cFishSystemMonitoring" | Get-ScheduledTaskInfo
   ```
4. Review log files in `.cursor/logs/monitoring/`

### Weekly Maintenance (Friday 4:00 PM)
1. Review performance trends from the past week
2. Adjust thresholds if needed based on patterns
3. Verify email alert functionality with test alert
4. Check log rotation and cleanup is functioning
5. Update documentation with any changes made

## Alert Response Procedures
### Warning Level Alerts
1. Review the alert details in the monitoring dashboard
2. Check system metrics to understand context
3. Document the alert in the incident log
4. Monitor for escalation to higher levels
5. Implement preventive measures if patterns emerge

### Critical Level Alerts
1. Immediately review system metrics in the dashboard
2. Check the auto-remediation log for action results
3. Manually intervene if auto-remediation failed:
   ```powershell
   .\scripts\cursor-manager.ps1 -ForceCleanup -AggressiveMemoryReclamation
   ```
4. Document the incident with cause analysis
5. Implement preventive measures

### Emergency Level Alerts
1. Immediately intervene with highest priority
2. Execute emergency cleanup procedure:
   ```powershell
   .\scripts\cursor-manager.ps1 -ForceCleanup -AggressiveMemoryReclamation -EmergencyMode
   ```
3. Notify the team via emergency communication channel
4. Document detailed incident report
5. Schedule post-incident review

## Dashboard Usage
### Accessing the Dashboard
1. The dashboard can be started manually:
   ```powershell
   .\scripts\start-monitoring-dashboard.ps1
   ```
2. Navigate using the following views:
   - System Overview: High-level metrics
   - Process Details: Individual process metrics
   - Application Status: Component health
   - Integration Status: Cross-platform integration health

### Interpreting Dashboard Metrics
- **Green**: Metrics within normal range
- **Yellow**: Warning threshold exceeded
- **Red**: Critical threshold exceeded
- **Flashing Red**: Emergency threshold exceeded

## Troubleshooting
### Monitoring Service Not Running
1. Check scheduled task status:
   ```powershell
   Get-ScheduledTask -TaskName "cFishSystemMonitoring" | Get-ScheduledTaskInfo
   ```
2. Verify log files for errors
3. Restart the monitoring service:
   ```powershell
   Unregister-ScheduledTask -TaskName "cFishSystemMonitoring" -Confirm:$false
   .\scripts\deploy-monitoring-system.ps1
   ```

### Email Alerts Not Sending
1. Verify SMTP configuration in `alert-config.json`
2. Check email logs in `.cursor/logs/monitoring/email/`
3. Test email functionality:
   ```powershell
   .\scripts\test-email-alerts.ps1
   ```

### Dashboard Not Displaying Data
1. Verify metrics files exist in `.cursor/logs/monitoring/metrics/`
2. Check dashboard logs for errors
3. Restart the dashboard:
   ```powershell
   Stop-Process -Name "monitoring-dashboard" -Force -ErrorAction SilentlyContinue
   .\scripts\start-monitoring-dashboard.ps1
   ```

## Maintenance Procedures
### Updating Configurations
1. Edit configuration files in `.cursor/config/monitoring/`
2. Restart the monitoring service to apply changes:
   ```powershell
   Restart-ScheduledTask -TaskName "cFishSystemMonitoring"
   ```

### Log Management
1. Logs are automatically rotated based on configuration
2. Manual log cleanup if needed:
   ```powershell
   .\scripts\cleanup-monitoring-logs.ps1 -Days 7
   ```

## Cross-Platform Integration Monitoring
The monitoring system tracks integration status with:
- WordPress (cFish.io)
- ClickUp (cFish.App)
- Notion (U.cFish.io)
- Vendasta (cFish.Vip)

Alerts are generated for integration failures with detailed diagnostics.

## Verification Checklist
- [ ] Monitoring service running properly
- [ ] Email alerts configured correctly
- [ ] Dashboard accessible and displaying data
- [ ] Auto-remediation functioning
- [ ] Log rotation working
- [ ] Cross-platform integration monitoring active

---

**Document Owner:** U7 - tYberius Designz
**Last Updated:** 05-09-2025
**Related Documents:**
- `.cursor/changelog.md`
- `.cursor/memory.md`
- `scripts/deploy-monitoring-system.ps1`
- `scripts/monitor-system.ps1` 