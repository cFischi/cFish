# System Monitoring Script
# Purpose: Continuously monitor system resources and process states
# Created: 05-08-2025
# Updated: 05-09-2025

[CmdletBinding()]
param(
    [Parameter()]
    [string]$ConfigPath = "$PSScriptRoot\..\config\monitoring",
    
    [Parameter()]
    [string]$LogPath = "$PSScriptRoot\..\logs\monitoring"
)

$VerbosePreference = "Continue"
$ErrorActionPreference = "Stop"

# Load configuration
$configFile = Join-Path $ConfigPath "monitoring-config.json"
$config = $null

if (Test-Path $configFile) {
    try {
        $config = Get-Content -Path $configFile -Raw | ConvertFrom-Json
        Write-Verbose "Configuration loaded from $configFile"
    }
    catch {
        Write-Error "Failed to load configuration: $($_.Exception.Message)"
        exit 1
    }
}
else {
    # Default configuration if file doesn't exist
    $config = @{
        UpdateInterval = 30
        Thresholds = @{
            Memory = @{
                Warning = 75
                Critical = 85
                Emergency = 90
            }
            Process = @{
                MaxTotal = 250
                MaxCursor = 3
                MaxMemoryPerCursor = 300
                TotalCursorMemory = 1000
            }
            Disk = @{
                Warning = 80
                Critical = 90
            }
            CPU = @{
                Warning = 70
                Critical = 85
            }
        }
        Alerts = @{
            Email = @{
                Enabled = $true
                Recipients = @("admin@cfish.io", "alerts@cfish.io")
                FromAddress = "monitoring@cfish.io"
                SmtpServer = "smtp.cfish.io"
                SmtpPort = 587
                UseTLS = $true
            }
            AutoRemediate = @{
                Enabled = $true
                Actions = @(
                    "CleanupProcesses",
                    "TriggerGarbageCollection",
                    "OptimizeCursorInstances"
                )
            }
        }
        Reporting = @{
            LogRetention = 7
            MetricsPath = Join-Path $LogPath "metrics"
            AlertsPath = Join-Path $LogPath "alerts"
        }
    }
    
    Write-Warning "Configuration file not found. Using default values."
}

# Create required directories
$metricsDir = $config.Reporting.MetricsPath
$alertsDir = $config.Reporting.AlertsPath
$logDir = $LogPath

@($metricsDir, $alertsDir, $logDir) | ForEach-Object {
    if (-not (Test-Path $_)) {
        try {
            New-Item -ItemType Directory -Path $_ -Force | Out-Null
            Write-Verbose "Created directory: $_"
        }
        catch {
            Write-Error "Failed to create directory: $_ - $($_.Exception.Message)"
            exit 1
        }
    }
}

$logFile = Join-Path $logDir "monitoring-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"
$metricsFile = Join-Path $metricsDir "metrics-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
$alertHistoryFile = Join-Path $alertsDir "alert-history.json"

# Initialize alert history if it doesn't exist
if (-not (Test-Path $alertHistoryFile)) {
    @{
        LastAlerts = @{}
        EmailSent = @{}
    } | ConvertTo-Json | Set-Content -Path $alertHistoryFile
}

function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    $timeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "$timeStamp [$Level] $Message"
    
    try {
        Add-Content -Path $logFile -Value $logMessage
        
        switch ($Level) {
            "ERROR" { Write-Host $logMessage -ForegroundColor Red }
            "WARNING" { Write-Host $logMessage -ForegroundColor Yellow }
            "ALERT" { Write-Host $logMessage -ForegroundColor Magenta }
            "SUCCESS" { Write-Host $logMessage -ForegroundColor Green }
            default { Write-Host $logMessage }
        }
    }
    catch {
        Write-Error "Failed to write to log: $($_.Exception.Message)"
    }
}

function Get-SystemMetrics {
    try {
        # Get memory info
        $osInfo = Get-CimInstance -ClassName Win32_OperatingSystem
        $totalMemoryGB = [math]::Round($osInfo.TotalVisibleMemorySize / (1024 * 1024), 2)
        $freeMemoryGB = [math]::Round($osInfo.FreePhysicalMemory / (1024 * 1024), 2)
        $usedMemoryGB = [math]::Round($totalMemoryGB - $freeMemoryGB, 2)
        $memoryUtilization = [math]::Round(($usedMemoryGB / $totalMemoryGB) * 100, 2)
        
        # Get process info
        $processCount = (Get-Process).Count
        $cursorProcesses = Get-Process | Where-Object { 
            $_.ProcessName -like "cursor*" -or 
            ($_.Path -ne $null -and $_.Path -like "*cursor*") 
        }
        $totalCursorMemoryMB = [math]::Round(($cursorProcesses | Measure-Object WorkingSet64 -Sum).Sum / 1MB, 2)
        
        # Get CPU info
        $cpuLoad = (Get-CimInstance -ClassName Win32_Processor | Measure-Object -Property LoadPercentage -Average).Average
        
        # Get disk info
        $disks = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3"
        $diskMetrics = $disks | ForEach-Object {
            $freeSpacePercent = [math]::Round(($_.FreeSpace / $_.Size) * 100, 2)
            $usedSpacePercent = 100 - $freeSpacePercent
            
            @{
                DriveLetter = $_.DeviceID
                SizeGB = [math]::Round($_.Size / 1GB, 2)
                FreeGB = [math]::Round($_.FreeSpace / 1GB, 2)
                UsedPercent = $usedSpacePercent
            }
        }
        
        return @{
            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            ComputerName = $env:COMPUTERNAME
            Memory = @{
                TotalGB = $totalMemoryGB
                FreeGB = $freeMemoryGB
                UsedGB = $usedMemoryGB
                UtilizationPercent = $memoryUtilization
            }
            Processes = @{
                Total = $processCount
                CursorInstances = $cursorProcesses.Count
                TotalCursorMemoryMB = $totalCursorMemoryMB
                HighMemoryProcesses = (Get-Process | Where-Object { $_.WorkingSet64 -gt 200MB }).Count
            }
            CPU = @{
                UtilizationPercent = $cpuLoad
            }
            Disk = $diskMetrics
        }
    }
    catch {
        Write-Log "Error getting system metrics: $($_.Exception.Message)" "ERROR"
        throw
    }
}

function Test-Thresholds {
    param($Metrics)
    
    try {
        $alerts = @()
        $alertLevels = @{
            "WARNING" = 0
            "CRITICAL" = 1
            "EMERGENCY" = 2
        }
        $highestAlertLevel = -1
        
        # Memory thresholds
        if ($Metrics.Memory.UtilizationPercent -ge $config.Thresholds.Memory.Emergency) {
            $alerts += [PSCustomObject]@{
                Type = "Memory"
                Level = "EMERGENCY"
                Message = "Memory utilization at $($Metrics.Memory.UtilizationPercent)%"
                Details = "Used: $($Metrics.Memory.UsedGB)GB / Total: $($Metrics.Memory.TotalGB)GB"
            }
            $highestAlertLevel = [Math]::Max($highestAlertLevel, $alertLevels["EMERGENCY"])
        }
        elseif ($Metrics.Memory.UtilizationPercent -ge $config.Thresholds.Memory.Critical) {
            $alerts += [PSCustomObject]@{
                Type = "Memory"
                Level = "CRITICAL"
                Message = "Memory utilization at $($Metrics.Memory.UtilizationPercent)%"
                Details = "Used: $($Metrics.Memory.UsedGB)GB / Total: $($Metrics.Memory.TotalGB)GB"
            }
            $highestAlertLevel = [Math]::Max($highestAlertLevel, $alertLevels["CRITICAL"])
        }
        elseif ($Metrics.Memory.UtilizationPercent -ge $config.Thresholds.Memory.Warning) {
            $alerts += [PSCustomObject]@{
                Type = "Memory"
                Level = "WARNING"
                Message = "Memory utilization at $($Metrics.Memory.UtilizationPercent)%"
                Details = "Used: $($Metrics.Memory.UsedGB)GB / Total: $($Metrics.Memory.TotalGB)GB"
            }
            $highestAlertLevel = [Math]::Max($highestAlertLevel, $alertLevels["WARNING"])
        }
        
        # Process thresholds
        if ($Metrics.Processes.Total -gt $config.Thresholds.Process.MaxTotal) {
            $alerts += [PSCustomObject]@{
                Type = "Process"
                Level = "CRITICAL"
                Message = "Total process count ($($Metrics.Processes.Total)) exceeds maximum ($($config.Thresholds.Process.MaxTotal))"
                Details = "Cursor instances: $($Metrics.Processes.CursorInstances), High memory processes: $($Metrics.Processes.HighMemoryProcesses)"
            }
            $highestAlertLevel = [Math]::Max($highestAlertLevel, $alertLevels["CRITICAL"])
        }
        
        if ($Metrics.Processes.CursorInstances -gt $config.Thresholds.Process.MaxCursor) {
            $alerts += [PSCustomObject]@{
                Type = "Cursor"
                Level = "WARNING"
                Message = "Cursor instance count ($($Metrics.Processes.CursorInstances)) exceeds maximum ($($config.Thresholds.Process.MaxCursor))"
                Details = "Total Cursor memory: $($Metrics.Processes.TotalCursorMemoryMB) MB"
            }
            $highestAlertLevel = [Math]::Max($highestAlertLevel, $alertLevels["WARNING"])
        }
        
        if ($Metrics.Processes.TotalCursorMemoryMB -gt $config.Thresholds.Process.TotalCursorMemory) {
            $alerts += [PSCustomObject]@{
                Type = "CursorMemory"
                Level = "WARNING"
                Message = "Total Cursor memory ($($Metrics.Processes.TotalCursorMemoryMB) MB) exceeds maximum ($($config.Thresholds.Process.TotalCursorMemory) MB)"
                Details = "Cursor instances: $($Metrics.Processes.CursorInstances)"
            }
            $highestAlertLevel = [Math]::Max($highestAlertLevel, $alertLevels["WARNING"])
        }
        
        # CPU thresholds
        if ($Metrics.CPU.UtilizationPercent -ge $config.Thresholds.CPU.Critical) {
            $alerts += [PSCustomObject]@{
                Type = "CPU"
                Level = "CRITICAL"
                Message = "CPU utilization at $($Metrics.CPU.UtilizationPercent)%"
                Details = "System may be under heavy load or experiencing performance issues"
            }
            $highestAlertLevel = [Math]::Max($highestAlertLevel, $alertLevels["CRITICAL"])
        }
        elseif ($Metrics.CPU.UtilizationPercent -ge $config.Thresholds.CPU.Warning) {
            $alerts += [PSCustomObject]@{
                Type = "CPU"
                Level = "WARNING"
                Message = "CPU utilization at $($Metrics.CPU.UtilizationPercent)%"
                Details = "System may be under moderate load"
            }
            $highestAlertLevel = [Math]::Max($highestAlertLevel, $alertLevels["WARNING"])
        }
        
        # Disk thresholds
        foreach ($disk in $Metrics.Disk) {
            if ($disk.UsedPercent -ge $config.Thresholds.Disk.Critical) {
                $alerts += [PSCustomObject]@{
                    Type = "Disk"
                    Level = "CRITICAL"
                    Message = "Disk $($disk.DriveLetter) utilization at $($disk.UsedPercent)%"
                    Details = "Free: $($disk.FreeGB)GB / Total: $($disk.SizeGB)GB"
                }
                $highestAlertLevel = [Math]::Max($highestAlertLevel, $alertLevels["CRITICAL"])
            }
            elseif ($disk.UsedPercent -ge $config.Thresholds.Disk.Warning) {
                $alerts += [PSCustomObject]@{
                    Type = "Disk"
                    Level = "WARNING"
                    Message = "Disk $($disk.DriveLetter) utilization at $($disk.UsedPercent)%"
                    Details = "Free: $($disk.FreeGB)GB / Total: $($disk.SizeGB)GB"
                }
                $highestAlertLevel = [Math]::Max($highestAlertLevel, $alertLevels["WARNING"])
            }
        }
        
        return @{
            Alerts = $alerts
            HighestLevel = $(switch ($highestAlertLevel) {
                2 { "EMERGENCY" }
                1 { "CRITICAL" }
                0 { "WARNING" }
                default { "NORMAL" }
            })
        }
    }
    catch {
        Write-Log "Error testing thresholds: $($_.Exception.Message)" "ERROR"
        throw
    }
}

function Send-AlertEmail {
    param(
        [array]$Alerts,
        [string]$HighestLevel,
        [hashtable]$Metrics
    )
    
    if (-not $config.Alerts.Email.Enabled) {
        Write-Log "Email alerts are disabled in configuration" "INFO"
        return
    }
    
    try {
        # Load alert history
        $alertHistory = Get-Content -Path $alertHistoryFile -Raw | ConvertFrom-Json
        
        # Check if we've already sent an email for this alert level recently
        $now = Get-Date
        $emailCooldown = 30 # minutes
        
        if ($alertHistory.EmailSent.$HighestLevel -ne $null) {
            $lastSent = [DateTime]::Parse($alertHistory.EmailSent.$HighestLevel)
            $timeSinceLastEmail = ($now - $lastSent).TotalMinutes
            
            if ($timeSinceLastEmail -lt $emailCooldown) {
                Write-Log "Skipping email for $HighestLevel alert - last email sent $timeSinceLastEmail minutes ago (cooldown: $emailCooldown minutes)" "INFO"
                return
            }
        }
        
        # Prepare email
        $subject = "[$HighestLevel] System Alert - $($env:COMPUTERNAME) - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
        $body = @"
<html>
<head>
    <style>
        body { font-family: Arial, sans-serif; }
        .alert { margin-bottom: 15px; padding: 10px; border-radius: 5px; }
        .WARNING { background-color: #fff3cd; border: 1px solid #ffeeba; }
        .CRITICAL { background-color: #f8d7da; border: 1px solid #f5c6cb; }
        .EMERGENCY { background-color: #d9534f; border: 1px solid #d43f3a; color: white; }
        table { border-collapse: collapse; width: 100%; margin-top: 20px; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
    </style>
</head>
<body>
    <h2>System Alert: $($env:COMPUTERNAME)</h2>
    <p>The following alerts were detected:</p>
    
    <div class="alerts">
"@
        
        foreach ($alert in $Alerts) {
            $body += @"
        <div class="alert $($alert.Level)">
            <strong>[$($alert.Level)] $($alert.Type):</strong> $($alert.Message)<br>
            <small>$($alert.Details)</small>
        </div>
"@
        }
        
        $body += @"
    </div>
    
    <h3>System Metrics</h3>
    <table>
        <tr><th>Metric</th><th>Value</th></tr>
        <tr><td>Memory Utilization</td><td>$($Metrics.Memory.UtilizationPercent)%</td></tr>
        <tr><td>Memory Used/Total</td><td>$($Metrics.Memory.UsedGB)GB / $($Metrics.Memory.TotalGB)GB</td></tr>
        <tr><td>Process Count</td><td>$($Metrics.Processes.Total)</td></tr>
        <tr><td>Cursor Instances</td><td>$($Metrics.Processes.CursorInstances)</td></tr>
        <tr><td>Cursor Memory</td><td>$($Metrics.Processes.TotalCursorMemoryMB) MB</td></tr>
        <tr><td>CPU Utilization</td><td>$($Metrics.CPU.UtilizationPercent)%</td></tr>
    </table>
    
    <p>Time: $($Metrics.Timestamp)</p>
    <p>This is an automated alert from the UcF System Monitoring Service.</p>
</body>
</html>
"@
        
        # Send email
        $smtpServer = $config.Alerts.Email.SmtpServer
        $smtpPort = $config.Alerts.Email.SmtpPort
        $fromAddress = $config.Alerts.Email.FromAddress
        $recipients = $config.Alerts.Email.Recipients -join ","
        
        $emailParams = @{
            From = $fromAddress
            To = $recipients
            Subject = $subject
            Body = $body
            BodyAsHtml = $true
            SmtpServer = $smtpServer
            Port = $smtpPort
            UseSsl = $config.Alerts.Email.UseTLS
        }
        
        Send-MailMessage @emailParams
        
        # Update alert history
        $alertHistory.EmailSent.$HighestLevel = $now.ToString("o")
        $alertHistory | ConvertTo-Json | Set-Content -Path $alertHistoryFile
        
        Write-Log "Sent email alert for $HighestLevel condition to $recipients" "INFO"
    }
    catch {
        Write-Log "Failed to send alert email: $($_.Exception.Message)" "ERROR"
    }
}

function Invoke-Remediation {
    param(
        [array]$Alerts,
        [string]$HighestLevel
    )
    
    if (-not $config.Alerts.AutoRemediate.Enabled) {
        Write-Log "Auto-remediation is disabled in configuration" "INFO"
        return
    }
    
    try {
        # Check which types of alerts we have
        $memoryAlert = $Alerts | Where-Object { $_.Type -eq "Memory" } | Sort-Object { $alertLevels[$_.Level] } -Descending | Select-Object -First 1
        $processAlert = $Alerts | Where-Object { $_.Type -eq "Process" } | Sort-Object { $alertLevels[$_.Level] } -Descending | Select-Object -First 1
        $cursorAlert = $Alerts | Where-Object { $_.Type -eq "Cursor" -or $_.Type -eq "CursorMemory" } | Sort-Object { $alertLevels[$_.Level] } -Descending | Select-Object -First 1
        
        # Take remediation actions based on alert types and severity
        if ($memoryAlert -or $processAlert -or $cursorAlert) {
            Write-Log "Starting auto-remediation for system alerts..." "WARNING"
            
            # Run cursor manager to optimize instances
            if ($cursorAlert -or ($memoryAlert -and $memoryAlert.Level -in @("CRITICAL", "EMERGENCY"))) {
                Write-Log "Running cursor-manager.ps1 for instance optimization..." "INFO"
                try {
                    & "$PSScriptRoot\cursor-manager.ps1" -ForceCleanup -AggressiveCleanup
                    Write-Log "Successfully ran cursor-manager.ps1" "SUCCESS"
                }
                catch {
                    Write-Log "Failed to run cursor-manager.ps1: $($_.Exception.Message)" "ERROR"
                }
            }
            
            # Force garbage collection
            if ($memoryAlert -and $memoryAlert.Level -in @("CRITICAL", "EMERGENCY")) {
                Write-Log "Forcing garbage collection..." "INFO"
                try {
                    [System.GC]::Collect()
                    [System.GC]::WaitForPendingFinalizers()
                    [System.GC]::Collect()
                    Write-Log "Garbage collection completed" "SUCCESS"
                }
                catch {
                    Write-Log "Failed to run garbage collection: $($_.Exception.Message)" "ERROR"
                }
            }
        }
    }
    catch {
        Write-Log "Error during remediation: $($_.Exception.Message)" "ERROR"
    }
}

function Export-Metrics {
    param($Metrics)
    
    try {
        $Metrics | ConvertTo-Json -Depth 10 | Set-Content -Path $metricsFile
        Write-Log "Metrics exported to $metricsFile" "INFO"
    }
    catch {
        Write-Log "Error exporting metrics: $($_.Exception.Message)" "ERROR"
    }
}

function Remove-OldLogs {
    try {
        $cutoffDate = (Get-Date).AddDays(-$config.Reporting.LogRetention)
        
        # Clean up log files
        Get-ChildItem -Path $logDir, $metricsDir, $alertsDir -File | 
            Where-Object { $_.LastWriteTime -lt $cutoffDate -and $_.Name -ne "alert-history.json" } | 
            ForEach-Object {
                Write-Log "Removing old log file: $($_.FullName)" "INFO"
                Remove-Item -Path $_.FullName -Force
            }
    }
    catch {
        Write-Log "Error cleaning old logs: $($_.Exception.Message)" "WARNING"
    }
}

# Main monitoring loop
try {
    Write-Log "===== System Monitoring Started =====" "INFO"
    Write-Log "Computer: $($env:COMPUTERNAME)" "INFO"
    Write-Log "Monitoring interval: $($config.UpdateInterval) seconds" "INFO"
    Write-Log "Log file: $logFile" "INFO"
    
    while ($true) {
        # Get current system metrics
        $metrics = Get-SystemMetrics
        
        # Check against thresholds
        $thresholdResults = Test-Thresholds $metrics
        $alerts = $thresholdResults.Alerts
        $highestAlertLevel = $thresholdResults.HighestLevel
        
        # Log all alerts
        if ($alerts.Count -gt 0) {
            Write-Log "Detected $($alerts.Count) alerts (Highest level: $highestAlertLevel)" "WARNING"
            
            foreach ($alert in $alerts) {
                Write-Log "[$($alert.Level)] $($alert.Type): $($alert.Message) - $($alert.Details)" "ALERT"
            }
            
            # Send email alerts for significant conditions
            if ($highestAlertLevel -in @("WARNING", "CRITICAL", "EMERGENCY")) {
                Send-AlertEmail -Alerts $alerts -HighestLevel $highestAlertLevel -Metrics $metrics
            }
            
            # Try to auto-remediate issues
            Invoke-Remediation -Alerts $alerts -HighestLevel $highestAlertLevel
        }
        else {
            Write-Log "System status normal - Memory: $($metrics.Memory.UtilizationPercent)%, Processes: $($metrics.Processes.Total), Cursor: $($metrics.Processes.CursorInstances)" "INFO"
        }
        
        # Export metrics for analysis
        Export-Metrics $metrics
        
        # Clean up old logs
        Remove-OldLogs
        
        # Wait for next monitoring interval
        Start-Sleep -Seconds $config.UpdateInterval
    }
}
catch {
    Write-Log "Critical error in monitoring: $($_.Exception.Message)" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    exit 1
}
finally {
    Write-Log "===== Monitoring script execution completed =====" "INFO"
} 