# Cursor Performance Management SOP
**Document ID:** UCF-U3.4-CURSOR-PERF-SOP-20250419
**Version:** 1.0
**Date Created:** 04-19-2025
**Last Updated:** 04-19-2025
**Created By:** Claude 3.7 Sonnet

## Purpose
This Standard Operating Procedure (SOP) provides a structured approach for diagnosing, resolving, and preventing Cursor IDE performance issues, specifically high CPU usage and excessive subprocess proliferation.

## Scope
This SOP applies to all systems running Cursor IDE where performance issues are observed, including high CPU usage, excessive subprocess count, or functionality limitations.

## Responsibilities
- **Developers:** Follow this SOP when experiencing Cursor performance issues
- **System Administrators:** Maintain and update the performance management tools
- **Technical Lead:** Review and approve changes to this SOP

## Prerequisites
- Windows 10/11 operating system
- PowerShell 5.0 or higher
- Administrator access (for advanced troubleshooting)
- Cursor IDE installed

## Definitions
- **Subprocess:** Child processes created by the main Cursor application
- **High-CPU Process:** Any process consistently using more than 10% CPU
- **Critical Process:** Core processes essential for Cursor functionality
- **Safe Process:** Non-critical processes that can be terminated without affecting core functionality

## Procedure

### 1. Initial Assessment

#### 1.1. Verify Cursor Performance Issue
1. Monitor Cursor CPU usage through Task Manager
2. Count the number of Cursor-related processes (cursor.exe, node.exe, electron)
3. Note any functionality limitations (copy/paste problems, lag, etc.)
4. Compare to baseline performance metrics (1-2% idle CPU, 5-8 subprocesses)

#### 1.2. Save Your Work
1. Save all open files in Cursor
2. Commit any changes to version control if applicable
3. Consider taking screenshots of your current workspace

### 2. Immediate Performance Recovery

#### 2.1. Run Active Process Monitor
1. Open Command Prompt or PowerShell
2. Navigate to the scripts directory:
   ```
   cd U5-Data\Scripts
   ```
3. Run the monitoring tool:
   ```
   .\monitor-cursor-processes-new.bat
   ```
4. Review the output to identify high-CPU processes

#### 2.2. Use Selective Process Terminator
1. Run the terminator tool:
   ```
   .\terminate-cursor-subprocesses-new.bat
   ```
2. Choose the appropriate termination mode:
   - **auto:** Automatically terminate top 3 safe high-CPU processes
   - **specific numbers:** Terminate specific processes by number
   - **all:** Terminate all safe high-CPU processes
3. Confirm termination when prompted
4. Check performance after termination

#### 2.3. Document Results
1. Review the generated log files in U5-Data\Logs
2. Note which processes were terminated
3. Record performance improvements after termination

### 3. Root Cause Analysis

#### 3.1. Test with Extensions Disabled
1. Close Cursor completely
2. Start Cursor with extensions disabled:
   ```
   cursor.exe --disable-extensions
   ```
3. Monitor performance for at least 30 minutes
4. Document if performance improves without extensions

#### 3.2. Identify Problematic Extensions
1. If performance improves with extensions disabled, enable half of your extensions
2. Restart Cursor and test performance
3. Continue narrowing down problematic extensions
4. Document any problematic extensions

#### 3.3. Check Configuration
1. Back up Cursor settings:
   ```
   copy "%APPDATA%\Cursor\User\settings.json" "%APPDATA%\Cursor\User\settings.json.bak"
   ```
2. Reset settings to defaults or apply minimal configuration
3. Test performance with minimal configuration
4. Gradually restore settings to identify problematic configurations

### 4. Advanced Troubleshooting

#### 4.1. Check Application Data
1. Close Cursor completely
2. Examine Cursor application data:
   ```
   explorer "%APPDATA%\Cursor"
   explorer "%USERPROFILE%\.cursor"
   ```
3. Look for unusually large files or logs
4. Back up and remove suspicious files for testing

#### 4.2. Analyze System Integration
1. Check for Cursor-related startup items
2. Examine scheduled tasks for Cursor-related entries
3. Look for environment variables affecting Cursor
4. Identify any other applications integrating with Cursor

### 5. Long-Term Resolution

#### 5.1. Implement Effective Solution
Based on root cause analysis, implement the appropriate solution:
- Disable or replace problematic extensions
- Optimize configuration settings
- Clean application data
- Adjust system integration
- Consider clean reinstallation in extreme cases

#### 5.2. Establish Prevention Measures
1. Implement regular performance checks
2. Create extension management policy
3. Establish configuration standards
4. Schedule regular Cursor restarts
5. Apply updates promptly

#### 5.3. Document Resolution
1. Update memory.md with resolution details
2. Create entry in changelog.md if applicable
3. Record successful approach for future reference

## Tools

### Active Process Monitor
- **Path:** `U5-Data\Scripts\monitor-cursor-processes-new.ps1`
- **Batch Wrapper:** `U5-Data\Scripts\monitor-cursor-processes-new.bat`
- **Purpose:** Identifies Cursor-related processes consuming excessive CPU resources
- **Output:** Detailed logs of all processes with CPU usage, memory usage, and command-line details

### Selective Process Terminator
- **Path:** `U5-Data\Scripts\terminate-cursor-subprocesses-new.ps1`
- **Batch Wrapper:** `U5-Data\Scripts\terminate-cursor-subprocesses-new.bat`
- **Purpose:** Safely terminates problematic processes while preserving core functionality
- **Safety:** Contains protection for critical processes to prevent termination of essential components

## Performance Metrics

### Normal Performance
- **CPU Usage:** 1-2% idle
- **Process Count:** 5-8 subprocesses
- **Copy/Paste:** Fully functional
- **Response Time:** Immediate, no lag

### Degraded Performance
- **CPU Usage:** 25-60%
- **Process Count:** 19+ subprocesses
- **Copy/Paste:** Limited functionality with external sources
- **Response Time:** Noticeable lag or stuttering

## Troubleshooting Reference

### Common High-CPU Processes
| Process Pattern | Risk Level | Safe to Terminate | Notes |
|-----------------|------------|-------------------|-------|
| *workbench.js* | Critical | No | Core editor functionality |
| *main.js* | Critical | No | Main Cursor process |
| *extension-host* | Moderate | Sometimes | Extension framework |
| *renderer* for extensions | Low-Moderate | Usually | Extension-specific renderers |
| *languageserver* | Moderate | Sometimes | Language services |
| *node* worker processes | Low | Usually | Background tasks |

### Common Issues and Solutions
| Issue | Potential Causes | Solutions |
|-------|------------------|-----------|
| High CPU after startup | Extension initialization | Wait for completion or terminate specific processes |
| Increasing CPU over time | Memory leaks, background tasks | Restart Cursor or terminate specific processes |
| Excessive process count | Extension proliferation | Disable unnecessary extensions |
| Copy/paste issues | Background process interference | Terminate problematic processes |

## References
- Cursor Performance Management Action Plan
- Cursor Performance Troubleshooting Summary
- Cursor documentation

## Document Control
- **Version:** 1.0
- **Created:** 04-19-2025
- **Author:** Claude 3.7 Sonnet
- **Approved By:** Cursor Performance Management Team
- **Next Review:** 10-19-2025

_Updated 04-19-2025 | AI: Cursor (Claude 3.7 Sonnet)_

## Appendices

### Appendix A: Quick Reference Command Guide
```
# Active Process Monitor
.\U5-Data\Scripts\monitor-cursor-processes-new.bat

# Selective Process Terminator
.\U5-Data\Scripts\terminate-cursor-subprocesses-new.bat

# Start Cursor with Extensions Disabled
cursor.exe --disable-extensions
```

### Appendix B: Normal vs. Problematic Process Counts
| Metric | Normal Range | Caution Range | Problematic Range |
|--------|--------------|--------------|-------------------|
| Subprocess Count | 5-8 | 9-12 | 13+ |
| Main Process CPU | 0-5% | 6-10% | 11%+ |
| Total CPU Usage | 0-10% | 11-20% | 21%+ |
| Memory Usage | 500-1000MB | 1000-1500MB | 1500MB+ |

---

**Approvals:**
- Technical Lead: ________________________ Date: __________
- Development Manager: ___________________ Date: __________

**Document History:**
- v1.0 (04-19-2025) - Initial SOP creation 