# Process Inventory Script
# Tracks and monitors running processes with detailed metrics

# Parameter parsing
param (
    [Parameter(Mandatory=$false)]
    [switch]$DetailedReport,
    
    [Parameter(Mandatory=$false)]
    [string]$ReportFormat = "JSON",
    
    [Parameter(Mandatory=$false)]
    [string]$OutputPath,
    
    [Parameter(Mandatory=$false)]
    [switch]$MonitorMode,
    
    [Parameter(Mandatory=$false)]
    [int]$MonitorInterval = 300,
    
    [Parameter(Mandatory=$false)]
    [switch]$ExportToAlertSystem
)

$VerbosePreference = "Continue"
$ErrorActionPreference = "Stop"

# Import the process manager module
$ProcessManagerPath = Join-Path $PSScriptRoot "process-manager.ps1"
$ResourceReservationPath = Join-Path $PSScriptRoot "resource-reservation.ps1"

if (Test-Path $ProcessManagerPath) {
    . $ProcessManagerPath
} else {
    Write-Error "Process manager script not found at $ProcessManagerPath"
    exit 1
}

# Create required directories if they don't exist
$MetricsDir = Join-Path (Split-Path -Parent $PSScriptRoot) "metrics"
$LogDir = Join-Path (Split-Path -Parent $PSScriptRoot) "logs"

New-Item -ItemType Directory -Path $MetricsDir -Force | Out-Null
New-Item -ItemType Directory -Path $LogDir -Force | Out-Null

$LogFile = "$LogDir/process-inventory-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"

# Configuration
$CheckInterval = 60  # Check processes every 60 seconds
$MetricsRetentionDays = 7  # Keep metrics for 7 days
$AlertThresholds = @{
    "CpuPercent" = 80
    "MemoryMB" = 1024
    "HandleCount" = 5000
    "ThreadCount" = 100
    "ResponseTimeMs" = 1000
}

function Write-InventoryLog {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    $TimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMessage = "[$TimeStamp] [$Level] $Message"
    
    # Write to console
    switch ($Level) {
        "ERROR" { Write-Host $LogMessage -ForegroundColor Red }
        "WARNING" { Write-Host $LogMessage -ForegroundColor Yellow }
        "SUCCESS" { Write-Host $LogMessage -ForegroundColor Green }
        default { Write-Host $LogMessage }
    }
    
    # Write to log file
    Add-Content -Path $LogFile -Value $LogMessage
}

function Get-ProcessDetails {
    param (
        [Parameter(Mandatory=$true)]
        [int[]]$ProcessIds,
        
        [Parameter(Mandatory=$false)]
        [switch]$Deep
    )
    
    try {
        $Results = @()
        
        foreach ($Pid in $ProcessIds) {
            try {
                $Process = Get-Process -Id $Pid -ErrorAction SilentlyContinue
                
                if (-not $Process) {
                    continue  # Process no longer exists
                }
                
                # Basic process information
                $ProcessInfo = [PSCustomObject]@{
                    ProcessId = $Process.Id
                    Name = $Process.ProcessName
                    Path = $Process.Path
                    StartTime = $Process.StartTime
                    CpuPercent = [math]::Round(($Process.CPU / (New-TimeSpan -Start $Process.StartTime -End (Get-Date)).TotalSeconds) * 100, 2)
                    WorkingSetMB = [math]::Round($Process.WorkingSet / 1MB, 2)
                    PrivateMemoryMB = [math]::Round($Process.PrivateMemorySize / 1MB, 2)
                    HandleCount = $Process.HandleCount
                    ThreadCount = $Process.Threads.Count
                    ParentProcessId = (Get-CimInstance Win32_Process -Filter "ProcessId = $($Process.Id)").ParentProcessId
                    CommandLine = (Get-CimInstance Win32_Process -Filter "ProcessId = $($Process.Id)").CommandLine
                    Owner = (Get-Process -Id $Process.Id -IncludeUserName).UserName
                    Responding = $Process.Responding
                }
                
                # If deep analysis is requested, get more details
                if ($Deep) {
                    try {
                        # Network connections
                        $Connections = Get-NetTCPConnection -OwningProcess $Pid -ErrorAction SilentlyContinue | 
                            Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort, State
                        $ProcessInfo | Add-Member -MemberType NoteProperty -Name "NetworkConnections" -Value $Connections
                        
                        # Modules loaded
                        $Modules = $Process.Modules | 
                            Select-Object ModuleName, FileName, FileVersion | 
                            Sort-Object ModuleName
                        $ProcessInfo | Add-Member -MemberType NoteProperty -Name "Modules" -Value $Modules
                        
                        # Performance metrics
                        $PerfCounter = Get-Counter "\Process($($Process.ProcessName))\% Processor Time" -ErrorAction SilentlyContinue
                        if ($PerfCounter) {
                            $CpuUsage = $PerfCounter.CounterSamples.CookedValue
                            $ProcessInfo | Add-Member -MemberType NoteProperty -Name "CpuUsageCurrent" -Value $CpuUsage
                        }
                        
                        # IO operations
                        $ProcessInfo | Add-Member -MemberType NoteProperty -Name "IOReadBytes" -Value $Process.ReadOperationCount
                        $ProcessInfo | Add-Member -MemberType NoteProperty -Name "IOWriteBytes" -Value $Process.WriteOperationCount
                    } catch {
                        Write-InventoryLog "Error getting detailed process info for PID $Pid: $($_.Exception.Message)" "WARNING"
                    }
                }
                
                $Results += $ProcessInfo
            } catch {
                Write-InventoryLog "Error processing PID $Pid: $($_.Exception.Message)" "ERROR"
            }
        }
        
        return $Results
    } catch {
        Write-InventoryLog "Error in Get-ProcessDetails: $($_.Exception.Message)" "ERROR"
        return @()
    }
}

function Save-ProcessMetrics {
    param (
        [Parameter(Mandatory=$true)]
        [PSCustomObject[]]$ProcessData,
        
        [Parameter(Mandatory=$false)]
        [string]$Label = ""
    )
    
    try {
        $Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
        $FileName = if ($Label) { 
            "process-metrics-$Label-$Timestamp.json" 
        } else { 
            "process-metrics-$Timestamp.json" 
        }
        
        $FilePath = Join-Path $MetricsDir $FileName
        
        # Add timestamp to the data
        $MetricsData = [PSCustomObject]@{
            Timestamp = (Get-Date).ToString("o")
            Processes = $ProcessData
            SystemInfo = @{
                TotalMemoryGB = [math]::Round((Get-CimInstance Win32_OperatingSystem).TotalVisibleMemorySize / 1MB, 2)
                FreeMemoryGB = [math]::Round((Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory / 1MB, 2)
                CpuCount = (Get-CimInstance Win32_ComputerSystem).NumberOfLogicalProcessors
                SystemUptime = [math]::Round(((Get-Date) - (Get-CimInstance Win32_OperatingSystem).LastBootUpTime).TotalHours, 2)
            }
        }
        
        $MetricsData | ConvertTo-Json -Depth 4 | Out-File -FilePath $FilePath -Encoding utf8
        Write-InventoryLog "Saved process metrics to $FilePath" "SUCCESS"
        
        # Clean up old metric files
        $CutoffDate = (Get-Date).AddDays(-$MetricsRetentionDays)
        Get-ChildItem -Path $MetricsDir -Filter "process-metrics-*.json" | 
            Where-Object { $_.CreationTime -lt $CutoffDate } | 
            ForEach-Object {
                Remove-Item -Path $_.FullName -Force
                Write-InventoryLog "Removed old metrics file: $($_.Name)" "INFO"
            }
            
        return $FilePath
    } catch {
        Write-InventoryLog "Error saving process metrics: $_" "ERROR"
        return $null
    }
}

function Detect-ProcessAnomalies {
    param (
        [Parameter(Mandatory=$true)]
        [PSCustomObject[]]$ProcessData
    )
    
    try {
        $Anomalies = @()
        
        foreach ($Process in $ProcessData) {
            $AnomalyDetected = $false
            $AnomalyReason = @()
            
            # Check CPU usage
            if ($Process.CpuPercent -gt $AlertThresholds.CpuPercent) {
                $AnomalyDetected = $true
                $AnomalyReason += "High CPU usage: $($Process.CpuPercent)%"
            }
            
            # Check memory usage
            if ($Process.PrivateMemoryMB -gt $AlertThresholds.MemoryMB) {
                $AnomalyDetected = $true
                $AnomalyReason += "High memory usage: $($Process.PrivateMemoryMB) MB"
            }
            
            # Check handle count
            if ($Process.HandleCount -gt $AlertThresholds.HandleCount) {
                $AnomalyDetected = $true
                $AnomalyReason += "High handle count: $($Process.HandleCount)"
            }
            
            # Check thread count
            if ($Process.ThreadCount -gt $AlertThresholds.ThreadCount) {
                $AnomalyDetected = $true
                $AnomalyReason += "High thread count: $($Process.ThreadCount)"
            }
            
            # Check if process is not responding
            if (-not $Process.Responding) {
                $AnomalyDetected = $true
                $AnomalyReason += "Process not responding"
            }
            
            if ($AnomalyDetected) {
                $Anomaly = [PSCustomObject]@{
                    ProcessId = $Process.ProcessId
                    Name = $Process.Name
                    Reasons = $AnomalyReason
                    Timestamp = (Get-Date).ToString("o")
                    Severity = if ($AnomalyReason.Count -gt 1) { "HIGH" } else { "MEDIUM" }
                }
                
                $Anomalies += $Anomaly
                
                Write-InventoryLog "Anomaly detected for $($Process.Name) (PID $($Process.ProcessId)): $($AnomalyReason -join ', ')" "WARNING"
            }
        }
        
        # Save anomalies if any were detected
        if ($Anomalies.Count -gt 0) {
            $AnomaliesFile = Join-Path $MetricsDir "process-anomalies-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
            $Anomalies | ConvertTo-Json -Depth 3 | Out-File -FilePath $AnomaliesFile -Encoding utf8
            Write-InventoryLog "Saved $($Anomalies.Count) process anomalies to $AnomaliesFile" "WARNING"
        }
        
        return $Anomalies
    } catch {
        Write-InventoryLog "Error detecting process anomalies: $_" "ERROR"
        return @()
    }
}

function Get-ProcessHierarchy {
    try {
        $AllProcesses = Get-Process
        $ProcessDict = @{}
        $RootProcesses = @()
        
        # First pass: collect all processes and their information
        foreach ($Process in $AllProcesses) {
            try {
                $CimProcess = Get-CimInstance Win32_Process -Filter "ProcessId = $($Process.Id)"
                $ParentId = $CimProcess.ParentProcessId
                
                $ProcessInfo = [PSCustomObject]@{
                    ProcessId = $Process.Id
                    ParentProcessId = $ParentId
                    Name = $Process.ProcessName
                    StartTime = $Process.StartTime
                    CpuPercent = if ($Process.StartTime) {
                        $RunTime = (New-TimeSpan -Start $Process.StartTime -End (Get-Date)).TotalSeconds
                        if ($RunTime -gt 0) {
                            [math]::Round(($Process.CPU / $RunTime) * 100, 2)
                        } else {
                            0
                        }
                    } else {
                        0
                    }
                    MemoryMB = [math]::Round($Process.WorkingSet / 1MB, 2)
                    Children = @()
                }
                
                $ProcessDict[$Process.Id] = $ProcessInfo
            } catch {
                # Skip processes that we can't access
                continue
            }
        }
        
        # Second pass: build the hierarchy
        foreach ($ProcessInfo in $ProcessDict.Values) {
            if ($ProcessDict.ContainsKey($ProcessInfo.ParentProcessId)) {
                $ProcessDict[$ProcessInfo.ParentProcessId].Children += $ProcessInfo
            } else {
                $RootProcesses += $ProcessInfo
            }
        }
        
        # Return the hierarchy
        $Hierarchy = [PSCustomObject]@{
            RootProcesses = $RootProcesses
            AllProcesses = $ProcessDict
            Timestamp = (Get-Date).ToString("o")
        }
        
        # Save to file
        $HierarchyFile = Join-Path $MetricsDir "process-hierarchy-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
        $Hierarchy | ConvertTo-Json -Depth 10 | Out-File -FilePath $HierarchyFile -Encoding utf8
        Write-InventoryLog "Saved process hierarchy to $HierarchyFile" "SUCCESS"
        
        return $Hierarchy
    } catch {
        Write-InventoryLog "Error building process hierarchy: $_" "ERROR"
        return $null
    }
}

function Generate-ProcessReport {
    param (
        [Parameter(Mandatory=$false)]
        [switch]$DetailedReport,
        
        [Parameter(Mandatory=$false)]
        [string]$ReportFormat = "JSON"
    )
    
    try {
        # Get all running processes
        $AllProcesses = Get-Process
        $ProcessIds = $AllProcesses | Select-Object -ExpandProperty Id
        
        # Get detailed info for all processes
        $ProcessData = Get-ProcessDetails -ProcessIds $ProcessIds -Deep:$DetailedReport
        
        # Save metrics
        $MetricsFile = Save-ProcessMetrics -ProcessData $ProcessData -Label $(if ($DetailedReport) { "detailed" } else { "basic" })
        
        # Check for anomalies
        $Anomalies = Detect-ProcessAnomalies -ProcessData $ProcessData
        
        # Get process hierarchy
        $Hierarchy = Get-ProcessHierarchy
        
        # Create summary statistics
        $Summary = [PSCustomObject]@{
            TotalProcessCount = $ProcessData.Count
            AnomalyCount = $Anomalies.Count
            TopCpuProcesses = $ProcessData | Sort-Object -Property CpuPercent -Descending | Select-Object -First 5 | ForEach-Object {
                [PSCustomObject]@{
                    Name = $_.Name
                    ProcessId = $_.ProcessId
                    CpuPercent = $_.CpuPercent
                }
            }
            TopMemoryProcesses = $ProcessData | Sort-Object -Property PrivateMemoryMB -Descending | Select-Object -First 5 | ForEach-Object {
                [PSCustomObject]@{
                    Name = $_.Name
                    ProcessId = $_.ProcessId
                    MemoryMB = $_.PrivateMemoryMB
                }
            }
            LongestRunningProcesses = $ProcessData | Sort-Object -Property StartTime | Select-Object -First 5 | ForEach-Object {
                $RunTime = New-TimeSpan -Start $_.StartTime -End (Get-Date)
                [PSCustomObject]@{
                    Name = $_.Name
                    ProcessId = $_.ProcessId
                    RunningFor = "$($RunTime.Days)d $($RunTime.Hours)h $($RunTime.Minutes)m"
                }
            }
            SystemResources = @{
                TotalMemoryGB = [math]::Round((Get-CimInstance Win32_OperatingSystem).TotalVisibleMemorySize / 1MB, 2)
                FreeMemoryGB = [math]::Round((Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory / 1MB, 2)
                MemoryUsedPercent = [math]::Round(((Get-CimInstance Win32_OperatingSystem).TotalVisibleMemorySize - (Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory) / (Get-CimInstance Win32_OperatingSystem).TotalVisibleMemorySize * 100, 2)
                CpuUsagePercent = (Get-Counter '\Processor(_Total)\% Processor Time' -ErrorAction SilentlyContinue).CounterSamples.CookedValue
            }
            GeneratedAt = (Get-Date).ToString("o")
        }
        
        # Save the summary
        $SummaryFile = Join-Path $MetricsDir "process-summary-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
        $Summary | ConvertTo-Json -Depth 3 | Out-File -FilePath $SummaryFile -Encoding utf8
        Write-InventoryLog "Saved process summary to $SummaryFile" "SUCCESS"
        
        # If HTML report requested, generate HTML
        if ($ReportFormat -eq "HTML") {
            $HtmlFile = Join-Path $MetricsDir "process-report-$(Get-Date -Format 'yyyyMMdd-HHmmss').html"
            
            $HtmlContent = @"
<!DOCTYPE html>
<html>
<head>
    <title>Process Inventory Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        h1, h2 { color: #333; }
        table { border-collapse: collapse; width: 100%; margin-bottom: 20px; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
        tr:nth-child(even) { background-color: #f9f9f9; }
        .warning { color: #e74c3c; }
        .info { color: #3498db; }
        .success { color: #2ecc71; }
    </style>
</head>
<body>
    <h1>Process Inventory Report</h1>
    <p>Generated at: $((Get-Date).ToString("yyyy-MM-dd HH:mm:ss"))</p>
    
    <h2>System Summary</h2>
    <table>
        <tr><th>Metric</th><th>Value</th></tr>
        <tr><td>Total Process Count</td><td>$($Summary.TotalProcessCount)</td></tr>
        <tr><td>Anomaly Count</td><td>$($Summary.AnomalyCount)</td></tr>
        <tr><td>Total Memory (GB)</td><td>$($Summary.SystemResources.TotalMemoryGB)</td></tr>
        <tr><td>Free Memory (GB)</td><td>$($Summary.SystemResources.FreeMemoryGB)</td></tr>
        <tr><td>Memory Used (%)</td><td>$($Summary.SystemResources.MemoryUsedPercent)</td></tr>
        <tr><td>CPU Usage (%)</td><td>$($Summary.SystemResources.CpuUsagePercent)</td></tr>
    </table>
    
    <h2>Top CPU Consuming Processes</h2>
    <table>
        <tr><th>Name</th><th>PID</th><th>CPU (%)</th></tr>
$(
    $Summary.TopCpuProcesses | ForEach-Object {
        "<tr><td>$($_.Name)</td><td>$($_.ProcessId)</td><td>$($_.CpuPercent)</td></tr>"
    } -join "`n"
)
    </table>
    
    <h2>Top Memory Consuming Processes</h2>
    <table>
        <tr><th>Name</th><th>PID</th><th>Memory (MB)</th></tr>
$(
    $Summary.TopMemoryProcesses | ForEach-Object {
        "<tr><td>$($_.Name)</td><td>$($_.ProcessId)</td><td>$($_.MemoryMB)</td></tr>"
    } -join "`n"
)
    </table>
    
    <h2>Longest Running Processes</h2>
    <table>
        <tr><th>Name</th><th>PID</th><th>Running For</th></tr>
$(
    $Summary.LongestRunningProcesses | ForEach-Object {
        "<tr><td>$($_.Name)</td><td>$($_.ProcessId)</td><td>$($_.RunningFor)</td></tr>"
    } -join "`n"
)
    </table>
    
    <h2>Process Anomalies</h2>
$(
    if ($Anomalies.Count -gt 0) {
        @"
    <table>
        <tr><th>Name</th><th>PID</th><th>Reasons</th><th>Severity</th></tr>
$(
        $Anomalies | ForEach-Object {
            "<tr><td>$($_.Name)</td><td>$($_.ProcessId)</td><td>$($_.Reasons -join '<br>')</td><td>$($_.Severity)</td></tr>"
        } -join "`n"
)
    </table>
"@
    } else {
        "<p>No anomalies detected.</p>"
    }
)
</body>
</html>
"@
            
            $HtmlContent | Out-File -FilePath $HtmlFile -Encoding utf8
            Write-InventoryLog "Generated HTML report at $HtmlFile" "SUCCESS"
        }
        
        return [PSCustomObject]@{
            Success = $true
            MetricsFile = $MetricsFile
            SummaryFile = $SummaryFile
            HtmlFile = if ($ReportFormat -eq "HTML") { $HtmlFile } else { $null }
            Anomalies = $Anomalies
            Summary = $Summary
        }
    } catch {
        Write-InventoryLog "Error generating process report: $_" "ERROR"
        return [PSCustomObject]@{
            Success = $false
            Error = $_.Exception.Message
        }
    }
}

# Main execution
try {
    Write-InventoryLog "Process Inventory started" "INFO"
    
    if ($MonitorMode) {
        Write-InventoryLog "Starting monitor mode with interval of $MonitorInterval seconds" "INFO"
        
        $Counter = 0
        $DetailedInterval = 6  # Every 6th run is detailed (e.g., every 30 minutes if interval is 5 minutes)
        
        while ($true) {
            $DetailedThisRun = ($Counter % $DetailedInterval -eq 0)
            
            Write-InventoryLog "Running inventory check #$Counter $(if ($DetailedThisRun) { "(detailed)" } else { "(basic)" })" "INFO"
            
            $Report = Generate-ProcessReport -DetailedReport:$DetailedThisRun -ReportFormat $ReportFormat
            
            if (-not $Report.Success) {
                Write-InventoryLog "Failed to generate report: $($Report.Error)" "ERROR"
            } else {
                # If anomalies detected and export requested, export to alert system
                if ($ExportToAlertSystem -and $Report.Anomalies.Count -gt 0) {
                    # TODO: Implement alert system integration
                    Write-InventoryLog "Exported $($Report.Anomalies.Count) anomalies to alert system" "WARNING"
                }
            }
            
            $Counter++
            Write-InventoryLog "Sleeping for $MonitorInterval seconds" "INFO"
            Start-Sleep -Seconds $MonitorInterval
        }
    } else {
        # One-time run
        $Report = Generate-ProcessReport -DetailedReport:$DetailedReport -ReportFormat $ReportFormat
        
        if (-not $Report.Success) {
            Write-InventoryLog "Failed to generate report: $($Report.Error)" "ERROR"
            exit 1
        } else {
            # If output path specified, copy reports there
            if ($OutputPath) {
                if (-not (Test-Path $OutputPath)) {
                    New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
                }
                
                Copy-Item -Path $Report.MetricsFile -Destination $OutputPath -Force
                Copy-Item -Path $Report.SummaryFile -Destination $OutputPath -Force
                
                if ($Report.HtmlFile) {
                    Copy-Item -Path $Report.HtmlFile -Destination $OutputPath -Force
                }
                
                Write-InventoryLog "Copied reports to $OutputPath" "SUCCESS"
            }
            
            # Return summary to console
            Write-InventoryLog "Process Inventory completed successfully" "SUCCESS"
            Write-InventoryLog "Found $($Report.Summary.TotalProcessCount) processes, $($Report.Anomalies.Count) anomalies" "INFO"
            Write-InventoryLog "System memory: $($Report.Summary.SystemResources.MemoryUsedPercent)% used, CPU: $($Report.Summary.SystemResources.CpuUsagePercent)%" "INFO"
        }
    }
    
    exit 0
} catch {
    Write-InventoryLog "Error in Process Inventory: $_" "ERROR"
    exit 1
} 