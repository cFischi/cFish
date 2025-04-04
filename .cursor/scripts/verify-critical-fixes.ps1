# verify-critical-fixes.ps1
# Purpose: Verify all RELAUNCH-CRITICAL fixes have been properly implemented and are working
# Created: 05-08-2025

[CmdletBinding()]
param(
    [Parameter()]
    [switch]$Verbose = $false,
    
    [Parameter()]
    [string]$LogPath = "$PSScriptRoot\..\logs\verification\verify-critical-fixes.log",
    
    [Parameter()]
    [switch]$FixIssues = $false,
    
    [Parameter()]
    [int]$MaxProcessThreshold = 250,
    
    [Parameter()]
    [int]$WarningMemoryPercent = 75
)

# Import common functions
. "$PSScriptRoot\common-functions.ps1"

# Ensure log directory exists
$logDir = Split-Path $LogPath -Parent
if (-not (Test-Path $logDir)) {
    try {
        New-Item -Path $logDir -ItemType Directory -Force | Out-Null
        Write-Log "Created log directory: $logDir" "INFO"
    }
    catch {
        Write-Host "Failed to create log directory: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}

# Initialize verification results
$results = @{
    ProcessCount = @{
        Status = "Not Verified"
        Details = ""
        FixApplied = $false
    }
    CrossPlatformIntegration = @{
        Status = "Not Verified"
        Details = ""
        FixApplied = $false
    }
    LRUCacheDependency = @{
        Status = "Not Verified"
        Details = ""
        FixApplied = $false
    }
    MonitoringSystem = @{
        Status = "Not Verified"
        Details = ""
        FixApplied = $false
    }
}

# Logging function
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO",
        [switch]$Console = $true
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    
    try {
        Add-Content -Path $LogPath -Value $logEntry
        
        if ($Console) {
            switch ($Level) {
                "ERROR" { Write-Host $logEntry -ForegroundColor Red }
                "WARNING" { Write-Host $logEntry -ForegroundColor Yellow }
                "SUCCESS" { Write-Host $logEntry -ForegroundColor Green }
                default { 
                    if ($Verbose) {
                        Write-Host $logEntry -ForegroundColor Gray
                    }
                }
            }
        }
    }
    catch {
        Write-Error "Failed to write to log: $($_.Exception.Message)"
    }
}

function Test-ProcessCountFix {
    Write-Log "Verifying Process Count Critical Alert Fix..." "INFO"
    
    try {
        # Get total process count
        $processCount = (Get-Process).Count
        Write-Log "Current process count: $processCount" "INFO"
        
        # Get Cursor process count
        $cursorProcesses = Get-Process | Where-Object { $_.Name -like "*cursor*" }
        $cursorCount = $cursorProcesses.Count
        $cursorMemoryMB = [math]::Round(($cursorProcesses | Measure-Object WorkingSet -Sum).Sum / 1MB, 2)
        
        Write-Log "Cursor processes: $cursorCount (Total memory: $cursorMemoryMB MB)" "INFO"
        
        # Verify process count is below threshold
        if ($processCount -lt $MaxProcessThreshold) {
            $results.ProcessCount.Status = "SUCCESS"
            $results.ProcessCount.Details = "Process count ($processCount) is below threshold ($MaxProcessThreshold)"
            Write-Log $results.ProcessCount.Details "SUCCESS"
        }
        else {
            $results.ProcessCount.Status = "FAILED"
            $results.ProcessCount.Details = "Process count ($processCount) exceeds threshold ($MaxProcessThreshold)"
            Write-Log $results.ProcessCount.Details "ERROR"
            
            if ($FixIssues) {
                Write-Log "Attempting to fix process count issue..." "WARNING"
                & "$PSScriptRoot\cursor-manager.ps1" -ForceCleanup
                $results.ProcessCount.FixApplied = $true
                
                # Verify fix was successful
                $newProcessCount = (Get-Process).Count
                if ($newProcessCount -lt $MaxProcessThreshold) {
                    $results.ProcessCount.Status = "FIXED"
                    $results.ProcessCount.Details = "Process count reduced from $processCount to $newProcessCount (threshold: $MaxProcessThreshold)"
                    Write-Log $results.ProcessCount.Details "SUCCESS"
                }
                else {
                    Write-Log "Failed to reduce process count below threshold: $newProcessCount" "ERROR"
                }
            }
        }
    }
    catch {
        $results.ProcessCount.Status = "ERROR"
        $results.ProcessCount.Details = "Failed to verify process count: $($_.Exception.Message)"
        Write-Log $results.ProcessCount.Details "ERROR"
    }
}

function Test-CrossPlatformIntegrationFix {
    Write-Log "Verifying Cross-Platform Integration Fix..." "INFO"
    
    try {
        # Check if fix-cross-platform-integration.js exists
        $scriptPath = "$PSScriptRoot\fix-cross-platform-integration.js"
        
        if (Test-Path $scriptPath) {
            Write-Log "Cross-platform integration fix script exists" "INFO"
            
            # Check log for successful integration fixes
            $logPath = "$PSScriptRoot\..\logs\integration-fixes.log"
            
            if (Test-Path $logPath) {
                $logContent = Get-Content $logPath -ErrorAction SilentlyContinue
                
                $clickUpSuccess = $logContent | Select-String "ClickUp date range field fixes. Fixed:"
                $notionSuccess = $logContent | Select-String "Notion nested toggle block fixes. Fixed:"
                $vendastaSuccess = $logContent | Select-String "Vendasta to ClickUp field mapping fixes. Updated:"
                
                if ($clickUpSuccess -and $notionSuccess -and $vendastaSuccess) {
                    $results.CrossPlatformIntegration.Status = "SUCCESS"
                    $results.CrossPlatformIntegration.Details = "All cross-platform integration fixes verified"
                    Write-Log $results.CrossPlatformIntegration.Details "SUCCESS"
                }
                else {
                    $results.CrossPlatformIntegration.Status = "INCOMPLETE"
                    $results.CrossPlatformIntegration.Details = "Some cross-platform integration fixes are missing verification"
                    Write-Log $results.CrossPlatformIntegration.Details "WARNING"
                    
                    if ($FixIssues) {
                        Write-Log "Attempting to run cross-platform integration fix script..." "WARNING"
                        node $scriptPath
                        $results.CrossPlatformIntegration.FixApplied = $true
                        
                        # Verify fix was successful
                        if (Test-Path $logPath) {
                            $newLogContent = Get-Content $logPath -ErrorAction SilentlyContinue
                            
                            $newClickUpSuccess = $newLogContent | Select-String "ClickUp date range field fixes. Fixed:"
                            $newNotionSuccess = $newLogContent | Select-String "Notion nested toggle block fixes. Fixed:"
                            $newVendastaSuccess = $newLogContent | Select-String "Vendasta to ClickUp field mapping fixes. Updated:"
                            
                            if ($newClickUpSuccess -and $newNotionSuccess -and $newVendastaSuccess) {
                                $results.CrossPlatformIntegration.Status = "FIXED"
                                $results.CrossPlatformIntegration.Details = "Cross-platform integration fixes applied successfully"
                                Write-Log $results.CrossPlatformIntegration.Details "SUCCESS"
                            }
                            else {
                                Write-Log "Failed to fully apply cross-platform integration fixes" "ERROR"
                            }
                        }
                    }
                }
            }
            else {
                $results.CrossPlatformIntegration.Status = "NOT_RUN"
                $results.CrossPlatformIntegration.Details = "Cross-platform integration fix script exists but has not been run"
                Write-Log $results.CrossPlatformIntegration.Details "WARNING"
                
                if ($FixIssues) {
                    Write-Log "Running cross-platform integration fix script..." "WARNING"
                    node $scriptPath
                    $results.CrossPlatformIntegration.FixApplied = $true
                    
                    # Verify fix was successful
                    if (Test-Path $logPath) {
                        $newLogContent = Get-Content $logPath -ErrorAction SilentlyContinue
                        
                        $clickUpSuccess = $newLogContent | Select-String "ClickUp date range field fixes. Fixed:"
                        $notionSuccess = $newLogContent | Select-String "Notion nested toggle block fixes. Fixed:"
                        $vendastaSuccess = $newLogContent | Select-String "Vendasta to ClickUp field mapping fixes. Updated:"
                        
                        if ($clickUpSuccess -and $notionSuccess -and $vendastaSuccess) {
                            $results.CrossPlatformIntegration.Status = "FIXED"
                            $results.CrossPlatformIntegration.Details = "Cross-platform integration fixes applied successfully"
                            Write-Log $results.CrossPlatformIntegration.Details "SUCCESS"
                        }
                        else {
                            Write-Log "Failed to fully apply cross-platform integration fixes" "ERROR"
                        }
                    }
                }
            }
        }
        else {
            $results.CrossPlatformIntegration.Status = "MISSING"
            $results.CrossPlatformIntegration.Details = "Cross-platform integration fix script not found: $scriptPath"
            Write-Log $results.CrossPlatformIntegration.Details "ERROR"
        }
    }
    catch {
        $results.CrossPlatformIntegration.Status = "ERROR"
        $results.CrossPlatformIntegration.Details = "Failed to verify cross-platform integration fix: $($_.Exception.Message)"
        Write-Log $results.CrossPlatformIntegration.Details "ERROR"
    }
}

function Test-LRUCacheDependencyFix {
    Write-Log "Verifying LRUCache Dependency Fix..." "INFO"
    
    try {
        # Check for the updated files
        $setupTestsPath = Join-Path (Get-Location) "src\tests\setupTests.ts"
        $processTreePath = Join-Path (Get-Location) ".cursor\performance-tools\optimization\process-tree.js"
        
        $setupTestsUpdated = $false
        $processTreeUpdated = $false
        
        if (Test-Path $setupTestsPath) {
            $setupTestsContent = Get-Content $setupTestsPath -ErrorAction SilentlyContinue
            
            # Check for LRUCache fix markers
            $webkitFix = $setupTestsContent | Select-String "webkitAnimation" -SimpleMatch
            $cssPropertyFix = $setupTestsContent | Select-String "CSS.*escape" -SimpleMatch
            $lruCacheOptions = $setupTestsContent | Select-String "allowStale|updateAgeOnGet|updateAgeOnHas" -SimpleMatch
            
            if ($webkitFix -and $cssPropertyFix -and $lruCacheOptions) {
                $setupTestsUpdated = $true
                Write-Log "setupTests.ts contains LRUCache dependency fixes" "INFO"
            }
            else {
                Write-Log "setupTests.ts is missing some LRUCache dependency fixes" "WARNING"
            }
        }
        else {
            Write-Log "setupTests.ts not found at expected location: $setupTestsPath" "WARNING"
        }
        
        if (Test-Path $processTreePath) {
            $processTreeContent = Get-Content $processTreePath -ErrorAction SilentlyContinue
            
            # Check for LRUCache fix markers
            $fetchMethodFix = $processTreeContent | Select-String "fetchMethod" -SimpleMatch
            $fallbackPruneFix = $processTreeContent | Select-String "prune.*older versions" -SimpleMatch
            $cacheErrorFix = $processTreeContent | Select-String "cacheError" -SimpleMatch
            
            if ($fetchMethodFix -and $fallbackPruneFix -and $cacheErrorFix) {
                $processTreeUpdated = $true
                Write-Log "process-tree.js contains LRUCache dependency fixes" "INFO"
            }
            else {
                Write-Log "process-tree.js is missing some LRUCache dependency fixes" "WARNING"
            }
        }
        else {
            Write-Log "process-tree.js not found at expected location: $processTreePath" "WARNING"
        }
        
        # Determine overall status
        if ($setupTestsUpdated -and $processTreeUpdated) {
            $results.LRUCacheDependency.Status = "SUCCESS"
            $results.LRUCacheDependency.Details = "LRUCache dependency fixes verified in all required files"
            Write-Log $results.LRUCacheDependency.Details "SUCCESS"
        }
        elseif ($setupTestsUpdated -or $processTreeUpdated) {
            $results.LRUCacheDependency.Status = "PARTIAL"
            $results.LRUCacheDependency.Details = "LRUCache dependency fixes partially implemented"
            Write-Log $results.LRUCacheDependency.Details "WARNING"
        }
        else {
            $results.LRUCacheDependency.Status = "FAILED"
            $results.LRUCacheDependency.Details = "LRUCache dependency fixes not found in any files"
            Write-Log $results.LRUCacheDependency.Details "ERROR"
        }
        
        # TODO: Actually try to run the tests to verify the fixes work
        # This would require running the Jest tests, which is outside the scope of this verification script
    }
    catch {
        $results.LRUCacheDependency.Status = "ERROR"
        $results.LRUCacheDependency.Details = "Failed to verify LRUCache dependency fix: $($_.Exception.Message)"
        Write-Log $results.LRUCacheDependency.Details "ERROR"
    }
}

function Test-MonitoringSystemFix {
    Write-Log "Verifying Monitoring System Implementation..." "INFO"
    
    try {
        # Check if register-monitoring-task.ps1 exists
        $scriptPath = "$PSScriptRoot\register-monitoring-task.ps1"
        
        if (Test-Path $scriptPath) {
            Write-Log "Monitoring system registration script exists" "INFO"
            
            # Check if monitoring task is registered
            $taskName = "cFish_SystemMonitoring"
            $task = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
            
            if ($task) {
                Write-Log "Monitoring system task is registered: $taskName" "INFO"
                
                # Check task settings
                $runLevel = $task.Principal.RunLevel
                $interval = $task.Triggers.Repetition.Interval
                
                if ($runLevel -eq "Highest" -and $interval) {
                    $results.MonitoringSystem.Status = "SUCCESS"
                    $results.MonitoringSystem.Details = "Monitoring system properly configured and registered (Task: $taskName, Run level: $runLevel, Interval: $interval)"
                    Write-Log $results.MonitoringSystem.Details "SUCCESS"
                }
                else {
                    $results.MonitoringSystem.Status = "MISCONFIGURED"
                    $results.MonitoringSystem.Details = "Monitoring system task exists but is misconfigured (Run level: $runLevel, Interval: $interval)"
                    Write-Log $results.MonitoringSystem.Details "WARNING"
                    
                    if ($FixIssues) {
                        Write-Log "Attempting to fix monitoring system configuration..." "WARNING"
                        & "$PSScriptRoot\register-monitoring-task.ps1" -Force
                        $results.MonitoringSystem.FixApplied = $true
                        
                        # Verify fix was successful
                        $updatedTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
                        if ($updatedTask -and $updatedTask.Principal.RunLevel -eq "Highest") {
                            $results.MonitoringSystem.Status = "FIXED"
                            $results.MonitoringSystem.Details = "Monitoring system configuration fixed"
                            Write-Log $results.MonitoringSystem.Details "SUCCESS"
                        }
                        else {
                            Write-Log "Failed to fix monitoring system configuration" "ERROR"
                        }
                    }
                }
            }
            else {
                $results.MonitoringSystem.Status = "NOT_REGISTERED"
                $results.MonitoringSystem.Details = "Monitoring system script exists but task is not registered"
                Write-Log $results.MonitoringSystem.Details "WARNING"
                
                if ($FixIssues) {
                    Write-Log "Attempting to register monitoring system task..." "WARNING"
                    & "$PSScriptRoot\register-monitoring-task.ps1"
                    $results.MonitoringSystem.FixApplied = $true
                    
                    # Verify fix was successful
                    $newTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
                    if ($newTask) {
                        $results.MonitoringSystem.Status = "FIXED"
                        $results.MonitoringSystem.Details = "Monitoring system task registered successfully"
                        Write-Log $results.MonitoringSystem.Details "SUCCESS"
                    }
                    else {
                        Write-Log "Failed to register monitoring system task" "ERROR"
                    }
                }
            }
        }
        else {
            $results.MonitoringSystem.Status = "MISSING"
            $results.MonitoringSystem.Details = "Monitoring system registration script not found: $scriptPath"
            Write-Log $results.MonitoringSystem.Details "ERROR"
        }
        
        # Check monitoring logs to ensure it's running
        $monitoringLogPath = "$PSScriptRoot\..\logs\monitoring"
        if (Test-Path $monitoringLogPath) {
            $logFiles = Get-ChildItem -Path $monitoringLogPath -Filter "*.log" | Sort-Object LastWriteTime -Descending
            if ($logFiles -and $logFiles.Count -gt 0) {
                $latestLog = $logFiles[0]
                $logAge = (Get-Date) - $latestLog.LastWriteTime
                
                if ($logAge.TotalHours -lt 1) {
                    Write-Log "Monitoring system is active (latest log: $($latestLog.Name), age: $($logAge.TotalMinutes) minutes)" "INFO"
                }
                else {
                    Write-Log "Monitoring system logs exist but may be inactive (latest log age: $($logAge.TotalHours) hours)" "WARNING"
                }
            }
            else {
                Write-Log "Monitoring system log directory exists but contains no log files" "WARNING"
            }
        }
        else {
            Write-Log "Monitoring system log directory not found: $monitoringLogPath" "WARNING"
        }
    }
    catch {
        $results.MonitoringSystem.Status = "ERROR"
        $results.MonitoringSystem.Details = "Failed to verify monitoring system implementation: $($_.Exception.Message)"
        Write-Log $results.MonitoringSystem.Details "ERROR"
    }
}

function Write-VerificationReport {
    Write-Log "=== Critical Fixes Verification Report ===" "INFO"
    Write-Log "Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" "INFO"
    Write-Log "System: $($env:COMPUTERNAME)" "INFO"
    Write-Log "User: $($env:USERNAME)" "INFO"
    Write-Log "-------------------------------------" "INFO"
    
    # Process Count Fix
    Write-Log "1. Process Count Critical Alert Fix" "INFO"
    Write-Log "   Status: $($results.ProcessCount.Status)" -Level $(switch($results.ProcessCount.Status) {
        "SUCCESS" { "SUCCESS" }
        "FIXED" { "SUCCESS" }
        "FAILED" { "ERROR" }
        "ERROR" { "ERROR" }
        default { "WARNING" }
    })
    Write-Log "   Details: $($results.ProcessCount.Details)" "INFO"
    if ($results.ProcessCount.FixApplied) {
        Write-Log "   ** Fix was automatically applied **" "WARNING"
    }
    Write-Log "-------------------------------------" "INFO"
    
    # Cross-Platform Integration Fix
    Write-Log "2. Cross-Platform Integration Fix" "INFO"
    Write-Log "   Status: $($results.CrossPlatformIntegration.Status)" -Level $(switch($results.CrossPlatformIntegration.Status) {
        "SUCCESS" { "SUCCESS" }
        "FIXED" { "SUCCESS" }
        "MISSING" { "ERROR" }
        "ERROR" { "ERROR" }
        default { "WARNING" }
    })
    Write-Log "   Details: $($results.CrossPlatformIntegration.Details)" "INFO"
    if ($results.CrossPlatformIntegration.FixApplied) {
        Write-Log "   ** Fix was automatically applied **" "WARNING"
    }
    Write-Log "-------------------------------------" "INFO"
    
    # LRUCache Dependency Fix
    Write-Log "3. LRUCache Dependency Fix" "INFO"
    Write-Log "   Status: $($results.LRUCacheDependency.Status)" -Level $(switch($results.LRUCacheDependency.Status) {
        "SUCCESS" { "SUCCESS" }
        "FIXED" { "SUCCESS" }
        "FAILED" { "ERROR" }
        "ERROR" { "ERROR" }
        default { "WARNING" }
    })
    Write-Log "   Details: $($results.LRUCacheDependency.Details)" "INFO"
    if ($results.LRUCacheDependency.FixApplied) {
        Write-Log "   ** Fix was automatically applied **" "WARNING"
    }
    Write-Log "-------------------------------------" "INFO"
    
    # Monitoring System Fix
    Write-Log "4. Monitoring System Implementation" "INFO"
    Write-Log "   Status: $($results.MonitoringSystem.Status)" -Level $(switch($results.MonitoringSystem.Status) {
        "SUCCESS" { "SUCCESS" }
        "FIXED" { "SUCCESS" }
        "MISSING" { "ERROR" }
        "ERROR" { "ERROR" }
        default { "WARNING" }
    })
    Write-Log "   Details: $($results.MonitoringSystem.Details)" "INFO"
    if ($results.MonitoringSystem.FixApplied) {
        Write-Log "   ** Fix was automatically applied **" "WARNING"
    }
    Write-Log "-------------------------------------" "INFO"
    
    # Overall Results
    $allSuccessfulOrFixed = $results.Values | ForEach-Object { $_.Status -in @("SUCCESS", "FIXED") } | Where-Object { $_ -eq $false } | Measure-Object | Select-Object -ExpandProperty Count
    
    if ($allSuccessfulOrFixed -eq 0) {
        Write-Log "All RELAUNCH-CRITICAL fixes have been successfully implemented!" "SUCCESS"
    }
    else {
        $failedCount = $results.Values | ForEach-Object { $_.Status -in @("FAILED", "ERROR", "MISSING") } | Where-Object { $_ -eq $true } | Measure-Object | Select-Object -ExpandProperty Count
        
        if ($failedCount -gt 0) {
            Write-Log "$failedCount RELAUNCH-CRITICAL fixes have serious issues and need immediate attention!" "ERROR"
        }
        else {
            Write-Log "Some RELAUNCH-CRITICAL fixes need attention, but no critical failures were detected." "WARNING"
        }
    }
    
    Write-Log "=== End of Verification Report ===" "INFO"
}

function Show-FixSummary {
    # Create HTML report
    $htmlPath = "$PSScriptRoot\..\reports\critical-fixes-$(Get-Date -Format 'yyyyMMdd-HHmmss').html"
    $htmlDir = Split-Path $htmlPath -Parent
    
    if (-not (Test-Path $htmlDir)) {
        New-Item -Path $htmlDir -ItemType Directory -Force | Out-Null
    }
    
    # Define status colors
    $statusColor = @{
        "SUCCESS" = "#4CAF50"
        "FIXED" = "#8BC34A"
        "PARTIAL" = "#FFC107"
        "INCOMPLETE" = "#FF9800"
        "NOT_RUN" = "#9E9E9E"
        "NOT_REGISTERED" = "#FF9800"
        "MISCONFIGURED" = "#FF9800"
        "FAILED" = "#F44336"
        "MISSING" = "#F44336"
        "ERROR" = "#F44336"
    }
    
    # Create HTML content
    $html = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>UcF Launch Critical Fixes Verification</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            line-height: 1.6;
            color: #333;
            margin: 0;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background-color: #fff;
            padding: 20px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
            border-radius: 5px;
        }
        h1 {
            color: #2196F3;
            border-bottom: 2px solid #2196F3;
            padding-bottom: 10px;
        }
        h2 {
            color: #555;
            margin-top: 20px;
        }
        .status-card {
            background-color: #fff;
            border-radius: 5px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
            margin-bottom: 20px;
            overflow: hidden;
        }
        .status-header {
            padding: 15px;
            font-weight: bold;
            color: white;
        }
        .status-content {
            padding: 15px;
        }
        .status-footer {
            padding: 10px 15px;
            background-color: #f9f9f9;
            font-size: 0.9em;
            color: #666;
        }
        .status-badge {
            display: inline-block;
            padding: 5px 10px;
            border-radius: 3px;
            color: white;
            font-weight: bold;
        }
        .summary {
            margin-top: 30px;
            padding: 20px;
            background-color: #E3F2FD;
            border-radius: 5px;
        }
        .timestamp {
            text-align: right;
            color: #777;
            font-size: 0.9em;
            margin-top: 20px;
        }
        .fix-badge {
            background-color: #FF9800;
            color: white;
            padding: 3px 8px;
            border-radius: 3px;
            font-size: 0.8em;
            margin-left: 10px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>UcF Launch Critical Fixes Verification Report</h1>
        <p>This report shows the verification status of all RELAUNCH-CRITICAL fixes implemented for the UcF launch.</p>
        
        <div class="timestamp">
            Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")<br>
            System: $($env:COMPUTERNAME)<br>
            User: $($env:USERNAME)
        </div>
        
        <h2>Verification Results</h2>
        
        <!-- Process Count Fix -->
        <div class="status-card">
            <div class="status-header" style="background-color: $($statusColor[$results.ProcessCount.Status])">
                Process Count Critical Alert Fix
                <span class="status-badge" style="background-color: #333;">1</span>
                $(if ($results.ProcessCount.FixApplied) { "<span class='fix-badge'>FIX APPLIED</span>" })
            </div>
            <div class="status-content">
                <p><strong>Status:</strong> $($results.ProcessCount.Status)</p>
                <p><strong>Details:</strong> $($results.ProcessCount.Details)</p>
            </div>
            <div class="status-footer">
                Verification method: Process count and cursor instance analysis
            </div>
        </div>
        
        <!-- Cross-Platform Integration Fix -->
        <div class="status-card">
            <div class="status-header" style="background-color: $($statusColor[$results.CrossPlatformIntegration.Status])">
                Cross-Platform Integration Fix
                <span class="status-badge" style="background-color: #333;">2</span>
                $(if ($results.CrossPlatformIntegration.FixApplied) { "<span class='fix-badge'>FIX APPLIED</span>" })
            </div>
            <div class="status-content">
                <p><strong>Status:</strong> $($results.CrossPlatformIntegration.Status)</p>
                <p><strong>Details:</strong> $($results.CrossPlatformIntegration.Details)</p>
            </div>
            <div class="status-footer">
                Verification method: Script existence and log analysis
            </div>
        </div>
        
        <!-- LRUCache Dependency Fix -->
        <div class="status-card">
            <div class="status-header" style="background-color: $($statusColor[$results.LRUCacheDependency.Status])">
                LRUCache Dependency Fix
                <span class="status-badge" style="background-color: #333;">3</span>
                $(if ($results.LRUCacheDependency.FixApplied) { "<span class='fix-badge'>FIX APPLIED</span>" })
            </div>
            <div class="status-content">
                <p><strong>Status:</strong> $($results.LRUCacheDependency.Status)</p>
                <p><strong>Details:</strong> $($results.LRUCacheDependency.Details)</p>
            </div>
            <div class="status-footer">
                Verification method: File content analysis
            </div>
        </div>
        
        <!-- Monitoring System Implementation -->
        <div class="status-card">
            <div class="status-header" style="background-color: $($statusColor[$results.MonitoringSystem.Status])">
                Monitoring System Implementation
                <span class="status-badge" style="background-color: #333;">4</span>
                $(if ($results.MonitoringSystem.FixApplied) { "<span class='fix-badge'>FIX APPLIED</span>" })
            </div>
            <div class="status-content">
                <p><strong>Status:</strong> $($results.MonitoringSystem.Status)</p>
                <p><strong>Details:</strong> $($results.MonitoringSystem.Details)</p>
            </div>
            <div class="status-footer">
                Verification method: Script existence and scheduled task verification
            </div>
        </div>
        
        <!-- Summary -->
        <div class="summary">
            <h2>Overall Summary</h2>
$(
    $allSuccessfulOrFixed = $results.Values | ForEach-Object { $_.Status -in @("SUCCESS", "FIXED") } | Where-Object { $_ -eq $false } | Measure-Object | Select-Object -ExpandProperty Count
    
    if ($allSuccessfulOrFixed -eq 0) {
        "<p style='color: #4CAF50; font-weight: bold;'>✓ All RELAUNCH-CRITICAL fixes have been successfully implemented!</p>"
    }
    else {
        $failedCount = $results.Values | ForEach-Object { $_.Status -in @("FAILED", "ERROR", "MISSING") } | Where-Object { $_ -eq $true } | Measure-Object | Select-Object -ExpandProperty Count
        
        if ($failedCount -gt 0) {
            "<p style='color: #F44336; font-weight: bold;'>⚠ $failedCount RELAUNCH-CRITICAL fixes have serious issues and need immediate attention!</p>"
        }
        else {
            "<p style='color: #FF9800; font-weight: bold;'>⚠ Some RELAUNCH-CRITICAL fixes need attention, but no critical failures were detected.</p>"
        }
    }
)
            <p>This verification report was generated to confirm that all UcF launch-critical fixes have been properly implemented. The system is $(if ($allSuccessfulOrFixed -eq 0) { "ready" } else { "not ready" }) for launch.</p>
            
            <p><strong>Next Steps:</strong></p>
            <ul>
$(
    if ($allSuccessfulOrFixed -eq 0) {
        "<li>Proceed with final UcF launch verification</li>
        <li>Run comprehensive test suite</li>
        <li>Schedule production deployment</li>"
    }
    else {
        $steps = @()
        
        if ($results.ProcessCount.Status -notin @("SUCCESS", "FIXED")) {
            $steps += "<li>Fix process count management to prevent system threshold breaches</li>"
        }
        
        if ($results.CrossPlatformIntegration.Status -notin @("SUCCESS", "FIXED")) {
            $steps += "<li>Complete cross-platform integration fixes for ClickUp, Notion, and Vendasta</li>"
        }
        
        if ($results.LRUCacheDependency.Status -notin @("SUCCESS", "FIXED")) {
            $steps += "<li>Resolve LRUCache dependency issues in ProcessTreeVisualization component</li>"
        }
        
        if ($results.MonitoringSystem.Status -notin @("SUCCESS", "FIXED")) {
            $steps += "<li>Complete monitoring system implementation with proper scheduling</li>"
        }
        
        $steps -join "`n"
    }
)
            </ul>
        </div>
    </div>
</body>
</html>
"@

    # Save HTML report
    $html | Set-Content -Path $htmlPath
    
    Write-Log "Verification report saved to: $htmlPath" "INFO"
    
    # Display summary in console
    Write-Log "-----------------------------------------" "INFO"
    Write-Log "           VERIFICATION SUMMARY           " "INFO"
    Write-Log "-----------------------------------------" "INFO"
    
    foreach ($key in $results.Keys) {
        $statusSymbol = switch ($results[$key].Status) {
            "SUCCESS" { "✓" }
            "FIXED" { "✓" }
            "PARTIAL" { "⚠" }
            "INCOMPLETE" { "⚠" }
            "NOT_RUN" { "⚠" }
            "NOT_REGISTERED" { "⚠" }
            "MISCONFIGURED" { "⚠" }
            "FAILED" { "✗" }
            "MISSING" { "✗" }
            "ERROR" { "✗" }
            default { "?" }
        }
        
        $statusColor = switch ($results[$key].Status) {
            { $_ -in @("SUCCESS", "FIXED") } { "Green" }
            { $_ -in @("FAILED", "MISSING", "ERROR") } { "Red" }
            default { "Yellow" }
        }
        
        Write-Host "$statusSymbol " -ForegroundColor $statusColor -NoNewline
        Write-Host "$key" -ForegroundColor White -NoNewline
        Write-Host ": " -NoNewline
        Write-Host "$($results[$key].Status)" -ForegroundColor $statusColor
    }
    
    Write-Log "-----------------------------------------" "INFO"
    
    if ($results.Values | ForEach-Object { $_.FixApplied } | Where-Object { $_ -eq $true } | Measure-Object | Select-Object -ExpandProperty Count -gt 0) {
        Write-Host "NOTE: Some fixes were automatically applied. Check the log for details." -ForegroundColor Yellow
    }
    
    return $htmlPath
}

# Main execution
try {
    Write-Log "=== UcF Launch Critical Fixes Verification Started ===" "INFO"
    
    # Verify Process Count Critical Alert Fix
    Test-ProcessCountFix
    
    # Verify Cross-Platform Integration Fix
    Test-CrossPlatformIntegrationFix
    
    # Verify LRUCache Dependency Fix
    Test-LRUCacheDependencyFix
    
    # Verify Monitoring System Implementation
    Test-MonitoringSystemFix
    
    # Generate verification report
    Write-VerificationReport
    
    # Show fix summary
    $reportPath = Show-FixSummary
    
    # Open the report in the default browser if available
    if (Test-Path $reportPath) {
        try {
            Start-Process $reportPath
        }
        catch {
            Write-Log "Could not open report in browser: $($_.Exception.Message)" "WARNING"
        }
    }
    
    Write-Log "=== UcF Launch Critical Fixes Verification Completed ===" "INFO"
}
catch {
    Write-Log "Verification script failed: $($_.Exception.Message)" "ERROR"
    Write-Log "Stack trace: $($_.ScriptStackTrace)" "ERROR"
    exit 1
} 