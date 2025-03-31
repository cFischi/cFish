# Standard Operating Procedure: Monitoring Scheduled Tasks

**Document ID:** ucf-u5.1-monitor-scheduled-tasks-20250313  
**Version:** 1.0  
**Created:** 03-13-2025  
**Last Updated:** 03-13-2025  
**Department:** U3-Operations  
**Category:** Monitoring  

## Purpose

This Standard Operating Procedure (SOP) outlines the process for monitoring scheduled tasks in the cFish.io Digital Organization System. Regular monitoring ensures that automated tasks are executing properly and system health is maintained.

## Scope

This procedure applies to all scheduled tasks configured in the cFish.io Digital Organization System, including but not limited to health checks, backups, and synchronization verification.

## Responsibilities

- **System Administrator:** Responsible for implementing and maintaining the monitoring system
- **Operations Team:** Responsible for reviewing monitoring reports and addressing issues
- **All Users:** Responsible for reporting any observed issues with scheduled tasks

## Prerequisites

- Access to the cFish.io system
- Familiarity with PowerShell scripting
- Understanding of the cFish.io directory structure
- Access to Windows Task Scheduler (for manual verification)

## Procedure

### 1. Automated Monitoring

The system includes an automated monitoring script (`ucf-u5.1-schedule-monitor-20250313.ps1`) that runs daily at 6:00 AM to check the status of all scheduled tasks.

#### 1.1 Automated Checks Performed

The automated monitoring performs the following checks:

1. **Script Existence:** Verifies that all script files referenced by scheduled tasks exist in their expected locations
2. **Task Execution:** Checks if tasks ran at their scheduled times
3. **Task Results:** Examines task exit codes to determine success or failure
4. **Log Analysis:** Reviews task log files for completion messages or errors

#### 1.2 Automated Reporting

The monitoring script automatically:

1. Updates the tasks status file at `cFish.io\U3-Operations\Monitoring\scheduled-tasks\tasks-status.json`
2. Writes detailed logs to `cFish.io\U3-Operations\Monitoring\logs\schedule-monitor-log.txt`
3. Adds a summary entry to `cFish.io\Documentation\memory.md`

### 2. Manual Monitoring Procedure

In addition to automated monitoring, manual verification should be performed weekly to ensure system health.

#### 2.1 Review Monitoring Logs

1. Open the schedule monitoring log file at `cFish.io\U3-Operations\Monitoring\logs\schedule-monitor-log.txt`
2. Review entries from the past week, noting any warnings or errors
3. Check for patterns of recurring issues

#### 2.2 Verify Task Status

1. Open the tasks status file at `cFish.io\U3-Operations\Monitoring\scheduled-tasks\tasks-status.json`
2. Verify that all tasks show a recent "LastRunTime" value
3. Confirm that all tasks have a "Status" of "Success"

#### 2.3 Check Windows Task Scheduler

1. Open Windows Task Scheduler
2. Navigate to the task library
3. Locate the cFish.io tasks (prefixed with "cFish-")
4. Verify that each task shows a "Last Run Result" of "0x0" (success)
5. Check that the "Next Run Time" is set appropriately

#### 2.4 Review Task-Specific Logs

For each scheduled task, review its specific log file:

1. Health Check: `cFish.io\U3-Operations\Monitoring\logs\health-check-log.txt`
2. Backup: `cFish.io\U3-Operations\Monitoring\logs\backup-log.txt`
3. Sync Verification: `cFish.io\U3-Operations\Monitoring\logs\sync-verification.log`

### 3. Troubleshooting Failed Tasks

If a task is found to have failed, follow these steps to diagnose and resolve the issue:

#### 3.1 Check Script Existence

1. Verify that the script file exists at the expected location
2. If missing, restore from backup or recreate the script

#### 3.2 Review Task Configuration

1. Open Windows Task Scheduler
2. Check the task properties, including:
   - Trigger settings (schedule)
   - Action settings (program/script path)
   - Conditions and settings

#### 3.3 Test Script Execution

1. Open PowerShell
2. Navigate to the script directory
3. Run the script manually to check for errors
4. Review the output and error messages

#### 3.4 Common Issues and Solutions

| Issue | Possible Causes | Solutions |
|-------|----------------|-----------|
| Task not running | Disabled task, incorrect schedule | Enable task, correct schedule |
| Script errors | Missing dependencies, permission issues | Install dependencies, adjust permissions |
| Path errors | Incorrect file paths, moved files | Update paths in task configuration |
| Timeout errors | Task running too long | Adjust timeout settings, optimize script |

### 4. Reporting and Documentation

#### 4.1 Weekly Monitoring Report

Create a weekly monitoring report that includes:

1. Summary of task execution status
2. Any issues identified and their resolution
3. Recommendations for system improvements

#### 4.2 Update memory.md

For significant issues or changes, add an entry to `cFish.io\Documentation\memory.md` with:

1. Description of the issue
2. Steps taken to resolve it
3. Preventive measures implemented
4. Follow the standard memory.md update format

## Scheduled Tasks Overview

The following tasks are configured in the system:

### Daily Health Check
- **Script:** `ucf-u5.1-health-check-20250313.ps1`
- **Schedule:** Daily at 1:00 AM
- **Purpose:** Verifies system health and reports status
- **Log File:** `cFish.io\U3-Operations\Monitoring\logs\health-check-log.txt`

### Daily Backup
- **Script:** `ucf-u5.1-backup-20250313.ps1`
- **Schedule:** Daily at 2:00 AM
- **Purpose:** Creates backups of critical files
- **Log File:** `cFish.io\U3-Operations\Monitoring\logs\backup-log.txt`

### Sync System Verification
- **Script:** `ucf-u5.1-verify-sync-system-20250313.ps1`
- **Schedule:** Daily at 3:00 AM
- **Purpose:** Verifies tYDiSync system functionality
- **Log File:** `cFish.io\U3-Operations\Monitoring\logs\sync-verification.log`

### Schedule Monitoring
- **Script:** `ucf-u5.1-schedule-monitor-20250313.ps1`
- **Schedule:** Daily at 6:00 AM
- **Purpose:** Monitors execution of scheduled tasks
- **Log File:** `cFish.io\U3-Operations\Monitoring\logs\schedule-monitor-log.txt`

## References

- cFish.io Digital Organization System Guide
- Windows Task Scheduler Documentation
- PowerShell Scripting Guide

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 03-13-2025 | AI: Cursor (Claude 3.7 Sonnet) | Initial document creation |

_Updated 03-13-2025 | AI: Cursor (Claude 3.7 Sonnet)_ 