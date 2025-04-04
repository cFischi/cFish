# UcF Monitoring Orchestrator
# Version: 0.1.0
# Created: 05-07-2025

# Import required modules
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$cursorMonitor = Join-Path $scriptPath "monitor-cursor.ps1"
$npmMemoryManager = Join-Path $scriptPath "npm-memory-manager.ps1"

# Configuration
$CONFIG = @{
    LogDir = ".\logs"
    MetricsDir = ".\metrics"
    ConfigDir = ".\config"
    RetentionDays = 7
    HealthCheckInterval = 300  # 5 minutes
    RestartInterval = 86400   # 24 hours
    AlertThresholds = @{
        DiskSpacePercent = 85
        LogSizeMB = 100
    }
}

# Create necessary directories
function Initialize-Environment {
    $dirs = @($CONFIG.LogDir, $CONFIG.MetricsDir, $CONFIG.ConfigDir)
    foreach ($dir in $dirs) {
        if (-not (Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
        }
    }
}

# Logging function
function Write-OrchestrationLog {
    param(
        [string]$Message,
        [ValidateSet('INFO', 'WARNING', 'ERROR', 'CRITICAL')]
        [string]$Level = 'INFO'
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logFile = Join-Path $CONFIG.LogDir "orchestrator-$((Get-Date).ToString('yyyy-MM-dd')).log"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    Add-Content -Path $logFile -Value $logMessage
    Write-Host $logMessage
}

# Cleanup old logs and metrics
function Start-DataRetention {
    $cutoffDate = (Get-Date).AddDays(-$CONFIG.RetentionDays)
    
    # Clean old logs
    Get-ChildItem -Path $CONFIG.LogDir -File | Where-Object {
        $_.LastWriteTime -lt $cutoffDate
    } | Remove-Item -Force
    
    # Clean old metrics
    Get-ChildItem -Path $CONFIG.MetricsDir -File | Where-Object {
        $_.LastWriteTime -lt $cutoffDate
    } | Remove-Item -Force
}

# Check disk space
function Test-DiskSpace {
    $drive = Get-PSDrive -Name C
    $usedPercent = [math]::Round(($drive.Used / ($drive.Used + $drive.Free)) * 100, 2)
    
    if ($usedPercent -gt $CONFIG.AlertThresholds.DiskSpacePercent) {
        Write-OrchestrationLog "WARNING: High disk usage ($usedPercent%)" -Level WARNING
        return $false
    }
    
    return $true
}

# Start monitoring processes
function Start-MonitoringProcesses {
    Write-OrchestrationLog "Starting monitoring processes..."
    
    try {
        # Start npm memory manager
        Start-Job -FilePath $npmMemoryManager -Name "NpmMemoryManager"
        Write-OrchestrationLog "Started npm memory manager"
        
        # Start Cursor monitor
        Start-Job -FilePath $cursorMonitor -Name "CursorMonitor"
        Write-OrchestrationLog "Started Cursor monitor"
    }
    catch {
        Write-OrchestrationLog "Failed to start monitoring processes: $_" -Level ERROR
        throw
    }
}

# Monitor running jobs
function Watch-MonitoringJobs {
    $jobs = Get-Job
    
    foreach ($job in $jobs) {
        if ($job.State -eq "Failed") {
            Write-OrchestrationLog "Job $($job.Name) failed: $($job.ChildJobs[0].JobStateInfo.Reason)" -Level ERROR
            
            # Attempt to restart the job
            Remove-Job -Id $job.Id -Force
            Start-MonitoringProcesses
        }
    }
}

# Main orchestration loop
function Start-Orchestration {
    Write-OrchestrationLog "Starting UcF monitoring orchestration..."
    
    # Initialize environment
    Initialize-Environment
    
    # Start monitoring processes
    Start-MonitoringProcesses
    
    $lastHealthCheck = Get-Date
    $lastRestart = Get-Date
    
    while ($true) {
        try {
            # Check disk space
            if (-not (Test-DiskSpace)) {
                Start-DataRetention
            }
            
            # Monitor jobs
            Watch-MonitoringJobs
            
            # Periodic health check
            if (((Get-Date) - $lastHealthCheck).TotalSeconds -ge $CONFIG.HealthCheckInterval) {
                Write-OrchestrationLog "Performing health check..."
                
                # Check log sizes
                Get-ChildItem -Path $CONFIG.LogDir -File | Where-Object {
                    $_.Length -gt ($CONFIG.AlertThresholds.LogSizeMB * 1MB)
                } | ForEach-Object {
                    Write-OrchestrationLog "Large log file detected: $($_.Name)" -Level WARNING
                    # Archive large logs
                    $archiveName = "$($_.BaseName)-$((Get-Date).ToString('yyyyMMddHHmmss'))$($_.Extension)"
                    Move-Item $_.FullName (Join-Path $CONFIG.LogDir $archiveName)
                }
                
                $lastHealthCheck = Get-Date
            }
            
            # Periodic restart
            if (((Get-Date) - $lastRestart).TotalSeconds -ge $CONFIG.RestartInterval) {
                Write-OrchestrationLog "Performing scheduled restart of monitoring processes..."
                
                # Stop all monitoring jobs
                Get-Job | Stop-Job
                Get-Job | Remove-Job
                
                # Start fresh instances
                Start-MonitoringProcesses
                
                $lastRestart = Get-Date
            }
            
            Start-Sleep -Seconds 60
        }
        catch {
            Write-OrchestrationLog "Orchestration error: $_" -Level ERROR
            Start-Sleep -Seconds 120
        }
    }
}

# Start orchestration
Start-Orchestration 