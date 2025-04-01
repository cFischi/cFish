# Monitoring Scheduled Tasks Procedure

**URL:** https://cfish.io/docs/procedures/monitor-scheduled-tasks  
**Last Updated:** 03-14-2025  
**Document ID:** ucf-u5.1-monitor-scheduled-tasks-20250314  
**Department:** U5 - Data Management  
**Author:** tY FischEYe  

## Overview

This procedure outlines the process for monitoring the execution of scheduled tasks in the cFish.io digital organization system. Regular monitoring ensures that automated health checks and backups are functioning properly.

## Prerequisites

- Windows operating system with PowerShell 5.1 or higher
- Administrative privileges on the system
- Access to the cFish.io repository

## Steps

### 1. Run the Monitoring Script

1. Navigate to the tools directory:
   ```
   cd C:\Users\Chris\cFish.io\tools
   ```

2. Execute the monitoring batch file:
   ```
   monitor-scheduled-tasks.bat
   ```

3. Review the console output for any immediate errors or warnings.

### 2. Check the Log Files

1. Navigate to the logs directory:
   ```
   cd C:\Users\Chris\cFish.io\logs
   ```

2. Open the latest schedule monitoring log:
   ```
   notepad schedule-monitor-YYYYMMDD.log
   ```
   (Replace YYYYMMDD with the current date)

3. Review the log for any WARNING or ERROR entries.

4. If alerts exist, check the alerts log:
   ```
   notepad schedule-monitor-alerts.log
   ```

### 3. Review memory.md Updates

1. Open the memory.md file in your preferred text editor:
   ```
   notepad C:\Users\Chris\cFish.io\memory.md
   ```

2. Verify that the "Scheduled Task Monitoring" section has been updated with the latest information.

3. Check the status indicators:
   - ✅ indicates tasks that ran successfully
   - ❌ indicates tasks that failed to run or were not found

### 4. Resolve Issues

If any tasks show as not running properly:

1. Check if the task is properly registered in Task Scheduler:
   ```powershell
   Get-ScheduledTask -TaskName "cFish.io Daily Health Check"
   Get-ScheduledTask -TaskName "cFish.io Daily Backup"
   ```

2. Verify the task script paths are correct:
   ```powershell
   (Get-ScheduledTask -TaskName "cFish.io Daily Health Check").Actions.Execute
   (Get-ScheduledTask -TaskName "cFish.io Daily Backup").Actions.Execute
   ```

3. Check if the scripts exist and are accessible:
   ```
   dir C:\Users\Chris\cFish.io\tools\daily-health-check.ps1
   dir C:\Users\Chris\cFish.io\tools\daily-backup.ps1
   ```

4. If needed, reschedule the tasks using the automation scheduling script:
   ```
   cd C:\Users\Chris\cFish.io\tools
   .\run-scheduler-as-admin.bat
   ```

## Frequency

- Execute this procedure daily to verify the proper functioning of scheduled tasks.
- Recommended time: Every morning at 9:00 AM (after the health check should have run).

## Expected Results

- Both daily health check and backup tasks should show as properly scheduled and executed.
- memory.md should be updated with current status information.
- Alert logs should be empty if all tasks are functioning properly.

## Troubleshooting

| Issue | Resolution |
|-------|------------|
| Task not found | Re-run the scheduling script with the run-scheduler-as-admin.bat batch file |
| Script not found | Verify the path to the script is correct in the task definition |
| Insufficient permissions | Ensure the task is configured to run with the highest privileges |
| Script execution errors | Check the task history in Task Scheduler for specific error messages |

## Related Documents

- [Digital Organization Quick Reference Guide](../quick-reference/tyf-u5.2-digital-organization-quick-reference-20250313.md)
- [Daily Health Check Documentation](../u5-data-management/ucf-u5.1-daily-health-check-documentation-20250313.md)
- [Daily Backup Documentation](../u5-data-management/ucf-u5.2-daily-backup-documentation-20250313.md)

_Updated 03-14-2025 | AI: Cursor (Claude 3.7 Sonnet)_ 