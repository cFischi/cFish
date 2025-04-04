# Cursor Instance Monitoring Script
# Version: 0.2.0
# Created: 05-07-2025

# Import management modules
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$managementScript = Join-Path $scriptPath "manage-cursor.ps1"
$npmMemoryScript = Join-Path $scriptPath "npm-memory-manager.ps1"
. $managementScript
. $npmMemoryScript

# Configuration
$CONFIG = @{
    MaxInstances = 3
    MaxMemoryPerInstanceMB = 700
    MaxTotalMemoryMB = 2000
    CheckIntervalSeconds = 30
    LogFile = Join-Path $scriptPath "cursor-monitor.log"
    AutoRecoveryEnabled = $true
    RecoveryAttempts = 3
    RecoveryInterval = 60
    HealthCheckInterval = 300  # 5 minutes
    MetricsRetention = 7      # days
    AlertThresholds = @{
        CpuPercent = 80
        MemoryPercent = 75
        ResponseTime = 5000  # ms
    }
}

function Write-Log {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [Parameter(Mandatory=$false)]
        [ValidateSet('INFO', 'WARNING', 'ERROR')]
        [string]$Level = 'INFO'
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    Write-Host $logMessage
    Add-Content -Path $CONFIG.LogFile -Value $logMessage
}

function Test-CursorHealth {
    param(
        [switch]$Detailed
    )
    
    $health = @{
        IsHealthy = $true
        Warnings = @()
        Metrics = @{}
    }
    
    # Check Cursor processes
    $cursorProcesses = Get-CursorInstances
    $health.Metrics.ProcessCount = $cursorProcesses.Count
    
    # Check memory usage
    $memoryMetrics = Get-MemoryMetrics
    $health.Metrics.MemoryUsage = $memoryMetrics
    
    # Check npm dependencies
    try {
        $npmCheck = npm audit
        if ($npmCheck -match "vulnerabilities") {
            $health.Warnings += "NPM vulnerabilities detected"
            $health.IsHealthy = $false
        }
    }
    catch {
        $health.Warnings += "Failed to check npm dependencies: $_"
        $health.IsHealthy = $false
    }
    
    # Check response times
    try {
        $startTime = Get-Date
        $cursorProcesses | ForEach-Object {
            if ($_.Responding -eq $false) {
                $health.Warnings += "Non-responsive Cursor instance: PID $($_.Id)"
                $health.IsHealthy = $false
            }
        }
        $responseTime = ((Get-Date) - $startTime).TotalMilliseconds
        $health.Metrics.ResponseTime = $responseTime
        
        if ($responseTime -gt $CONFIG.AlertThresholds.ResponseTime) {
            $health.Warnings += "Slow response time: $responseTime ms"
            $health.IsHealthy = $false
        }
    }
    catch {
        $health.Warnings += "Failed to check response times: $_"
        $health.IsHealthy = $false
    }
    
    # Check CPU usage
    try {
        $cpuUsage = (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue
        $health.Metrics.CpuUsage = $cpuUsage
        
        if ($cpuUsage -gt $CONFIG.AlertThresholds.CpuPercent) {
            $health.Warnings += "High CPU usage: $cpuUsage%"
            $health.IsHealthy = $false
        }
    }
    catch {
        $health.Warnings += "Failed to check CPU usage: $_"
        $health.IsHealthy = $false
    }
    
    return $health
}

function Start-CursorRecovery {
    param(
        [string]$TriggerReason,
        [hashtable]$HealthStatus
    )
    
    Write-Log "Starting Cursor recovery - Trigger: $TriggerReason" -Level WARNING
    
    $recoverySteps = @(
        @{
            Name = "Stop excess instances"
            Action = {
                $instances = Get-CursorInstances
                if ($instances.Count -gt $CONFIG.MaxInstances) {
                    $instances | Sort-Object MemoryMB -Descending | 
                    Select-Object -Skip $CONFIG.MaxInstances | 
                    ForEach-Object { Stop-CursorInstance -ProcessId $_.Id }
                }
            }
        },
        @{
            Name = "Clear Cursor cache"
            Action = {
                $cursorCache = Join-Path $env:APPDATA "Cursor"
                if (Test-Path $cursorCache) {
                    Remove-Item -Path $cursorCache -Recurse -Force
                }
            }
        },
        @{
            Name = "NPM cleanup"
            Action = {
                Start-ProcessCleanup -Force
            }
        },
        @{
            Name = "System resources"
            Action = {
                [System.GC]::Collect()
                [System.GC]::WaitForPendingFinalizers()
            }
        }
    )
    
    $attemptCount = 0
    $recovered = $false
    
    while (-not $recovered -and $attemptCount -lt $CONFIG.RecoveryAttempts) {
        $attemptCount++
        Write-Log "Recovery attempt $attemptCount of $($CONFIG.RecoveryAttempts)" -Level INFO
        
        foreach ($step in $recoverySteps) {
            try {
                Write-Log "Executing recovery step: $($step.Name)" -Level INFO
                & $step.Action
            }
            catch {
                Write-Log "Failed recovery step $($step.Name): $_" -Level ERROR
            }
        }
        
        # Check if recovery was successful
        $newHealth = Test-CursorHealth
        if ($newHealth.IsHealthy) {
            $recovered = $true
            Write-Log "Recovery successful" -Level INFO
        }
        else {
            Write-Log "Recovery attempt $attemptCount failed - Warnings: $($newHealth.Warnings -join '; ')" -Level WARNING
            Start-Sleep -Seconds $CONFIG.RecoveryInterval
        }
    }
    
    if (-not $recovered) {
        Write-Log "Recovery failed after $attemptCount attempts" -Level ERROR
        throw "Automated recovery failed to restore Cursor stability"
    }
    
    return $recovered
}

function Start-CursorMonitoring {
    Write-Log "Starting enhanced Cursor instance monitoring..."
    Write-Log "Configuration: Max Instances=$($CONFIG.MaxInstances), Max Memory Per Instance=$($CONFIG.MaxMemoryPerInstanceMB)MB, Max Total Memory=$($CONFIG.MaxTotalMemoryMB)MB"
    
    $lastHealthCheck = Get-Date
    
    while ($true) {
        try {
            # Regular monitoring
            $memStatus = Get-SystemMemoryStatus
            if ($memStatus) {
                Write-Log "System Memory - Total: $($memStatus.TotalGB)GB, Used: $($memStatus.UsedGB)GB, Free: $($memStatus.FreeGB)GB, Usage: $($memStatus.UsagePercent)%"
            }
            
            $cursorUsage = Get-CursorMemoryUsage
            if ($cursorUsage) {
                Write-Log "Cursor Instances: $($cursorUsage.InstanceCount), Total Memory: $($cursorUsage.TotalMemoryMB)MB"
                
                # Instance management
                if ($cursorUsage.InstanceCount -gt $CONFIG.MaxInstances) {
                    Write-Log "WARNING: Too many Cursor instances running ($($cursorUsage.InstanceCount)/$($CONFIG.MaxInstances))" -Level WARNING
                    if ($CONFIG.AutoRecoveryEnabled) {
                        Start-CursorRecovery -TriggerReason "Excess instances" -HealthStatus @{ Instances = $cursorUsage }
                    }
                }
                
                # Memory management
                foreach ($instance in $cursorUsage.Instances) {
                    if ($instance.MemoryMB -gt $CONFIG.MaxMemoryPerInstanceMB) {
                        Write-Log "WARNING: Cursor instance exceeding memory limit (PID: $($instance.Id), Memory: $($instance.MemoryMB)MB)" -Level WARNING
                        if ($CONFIG.AutoRecoveryEnabled) {
                            Start-CursorRecovery -TriggerReason "Instance memory limit" -HealthStatus @{ Instance = $instance }
                        }
                    }
                }
                
                if ($cursorUsage.TotalMemoryMB -gt $CONFIG.MaxTotalMemoryMB) {
                    Write-Log "WARNING: Total Cursor memory usage exceeding limit ($($cursorUsage.TotalMemoryMB)MB/$($CONFIG.MaxTotalMemoryMB)MB)" -Level WARNING
                    if ($CONFIG.AutoRecoveryEnabled) {
                        Start-CursorRecovery -TriggerReason "Total memory limit" -HealthStatus @{ TotalMemory = $cursorUsage.TotalMemoryMB }
                    }
                }
            }
            
            # Periodic health check
            if (((Get-Date) - $lastHealthCheck).TotalSeconds -ge $CONFIG.HealthCheckInterval) {
                $health = Test-CursorHealth -Detailed
                if (-not $health.IsHealthy) {
                    Write-Log "Health check failed: $($health.Warnings -join '; ')" -Level WARNING
                    if ($CONFIG.AutoRecoveryEnabled) {
                        Start-CursorRecovery -TriggerReason "Failed health check" -HealthStatus $health
                    }
                }
                $lastHealthCheck = Get-Date
            }
            
            Start-Sleep -Seconds $CONFIG.CheckIntervalSeconds
        }
        catch {
            Write-Log "ERROR: Monitoring error occurred: $_" -Level ERROR
            Start-Sleep -Seconds ($CONFIG.CheckIntervalSeconds * 2)
        }
    }
}

# Start monitoring
Start-CursorMonitoring 