# npm-memory-manager.ps1
# Script to manage memory usage during npm operations

# Configuration
$CONFIG = @{
    MaxMemoryPercent = 65        # Lowered from 75 to be more conservative
    WarningMemoryPercent = 60    # Lowered from 70
    CriticalMemoryPercent = 75   # Lowered from 85
    MaxProcessCount = 500        # Lowered from 1000
    ProcessCheckInterval = 3      # Reduced from 5 seconds
    CleanupThreshold = 70        # Lowered from 90
    TempDir = "C:\temp\npm-cache"
    LogDir = ".\logs"
    MetricsDir = ".\metrics"
    ConfigDir = ".\config"
    MaxNpmProcesses = 5          # New: limit concurrent npm processes
    MaxNodeProcesses = 10        # New: limit concurrent node processes
    EmergencyMemoryPercent = 85  # New: trigger emergency cleanup
    ProcessTimeout = 300         # New: process timeout in seconds
    AutoRecoveryEnabled = $true  # New: enable auto recovery
    RecoveryAttempts = 3        # New: max recovery attempts
    RecoveryInterval = 60       # New: seconds between recovery attempts
    AutoCleanupSchedule = @{    # New: scheduled cleanup times
        Morning = "08:00"
        Afternoon = "14:00"
        Evening = "20:00"
    }
}

# Create necessary directories
function Initialize-Environment {
    $dirs = @(
        $CONFIG.TempDir,
        $CONFIG.LogDir,
        $CONFIG.MetricsDir,
        $CONFIG.ConfigDir
    )
    
    foreach ($dir in $dirs) {
        if (-not (Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
        }
    }
    
    # Initialize configuration files
    $configFiles = @{
        "memory-thresholds.json" = @{
            Warning = $CONFIG.WarningMemoryPercent
            Critical = $CONFIG.CriticalMemoryPercent
            MaxAllowed = $CONFIG.MaxMemoryPercent
            ProcessLimit = $CONFIG.MaxProcessCount
        }
        "cleanup-triggers.json" = @{
            MemoryThreshold = $CONFIG.CleanupThreshold
            ProcessThreshold = $CONFIG.MaxProcessCount
            AutoCleanup = $true
        }
    }
    
    foreach ($file in $configFiles.Keys) {
        $path = Join-Path $CONFIG.ConfigDir $file
        if (-not (Test-Path $path)) {
            $configFiles[$file] | ConvertTo-Json | Set-Content $path
        }
    }
}

# Enhanced logging with severity levels and file rotation
function Write-MemoryLog {
    param(
        [string]$Message,
        [ValidateSet('INFO', 'WARNING', 'ERROR', 'CRITICAL')]
        [string]$Level = 'INFO'
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logFile = Join-Path $CONFIG.LogDir "npm-memory-$((Get-Date).ToString('yyyy-MM-dd')).log"
    $logMessage = "$timestamp [$Level] $Message"
    
    # Rotate logs if too large (>10MB)
    if ((Test-Path $logFile) -and (Get-Item $logFile).Length -gt 10MB) {
        $archive = Join-Path $CONFIG.LogDir "npm-memory-$((Get-Date).ToString('yyyy-MM-dd-HHmmss')).log"
        Move-Item $logFile $archive
    }
    
    # Write to log file
    $logMessage | Out-File -Append -FilePath $logFile
    
    # Console output with colors
    switch ($Level) {
        'WARNING' { Write-Host $logMessage -ForegroundColor Yellow }
        'ERROR' { Write-Host $logMessage -ForegroundColor Red }
        'CRITICAL' { Write-Host $logMessage -ForegroundColor Red -BackgroundColor White }
        default { Write-Host $logMessage }
    }
}

# Enhanced memory metrics collection
function Get-MemoryMetrics {
    $os = Get-WmiObject Win32_OperatingSystem
    $computerSystem = Get-WmiObject Win32_ComputerSystem
    $processes = Get-Process
    
    $metrics = @{
        TotalPhysicalMemory = [math]::Round($computerSystem.TotalPhysicalMemory / 1GB, 2)
        FreePhysicalMemory = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
        TotalVirtualMemory = [math]::Round($os.TotalVirtualMemorySize / 1MB, 2)
        FreeVirtualMemory = [math]::Round($os.FreeVirtualMemory / 1MB, 2)
        MemoryUsagePercent = [math]::Round(((($os.TotalVisibleMemorySize - $os.FreePhysicalMemory) * 100) / $os.TotalVisibleMemorySize), 2)
        ProcessCount = $processes.Count
        NpmProcessCount = ($processes | Where-Object { $_.Name -like "*npm*" }).Count
        NodeProcessCount = ($processes | Where-Object { $_.Name -like "*node*" }).Count
        TopMemoryProcesses = $processes | Sort-Object WorkingSet64 -Descending | Select-Object -First 5 |
            ForEach-Object { @{
                Name = $_.Name
                Memory = [math]::Round($_.WorkingSet64 / 1MB, 2)
                CPU = $_.CPU
            }}
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    }
    
    # Save metrics to file with timestamp
    $metricsFile = Join-Path $CONFIG.MetricsDir "memory-metrics-$((Get-Date).ToString('yyyy-MM-dd-HH')).json"
    $metrics | ConvertTo-Json -Depth 10 | Set-Content $metricsFile
    
    return $metrics
}

# Process cleanup function
function Start-ProcessCleanup {
    param(
        [switch]$Force
    )
    
    $metrics = Get-MemoryMetrics
    $cleanupNeeded = $Force -or $metrics.MemoryUsagePercent -gt $CONFIG.CleanupThreshold
    
    if ($cleanupNeeded) {
        Write-MemoryLog "Starting process cleanup..." -Level 'WARNING'
        
        # Stop unnecessary npm processes
        Get-Process | Where-Object { $_.Name -like "*npm*" -and $_.Id -ne $PID } | ForEach-Object {
            try {
                Write-MemoryLog "Stopping process: $($_.Name) (ID: $($_.Id))" -Level 'INFO'
                $_ | Stop-Process -Force
            }
            catch {
                Write-MemoryLog "Failed to stop process $($_.Name): $_" -Level 'ERROR'
            }
        }
        
        # Clean npm cache
        try {
            npm cache clean --force
            Write-MemoryLog "Cleaned npm cache" -Level 'INFO'
        }
        catch {
            Write-MemoryLog "Failed to clean npm cache: $_" -Level 'ERROR'
        }
        
        # Force garbage collection
        [System.GC]::Collect()
        [System.GC]::WaitForPendingFinalizers()
        
        Write-MemoryLog "Process cleanup completed" -Level 'INFO'
    }
}

# Enhanced memory safety check
function Test-MemorySafe {
    $metrics = Get-MemoryMetrics
    $thresholds = Get-Content (Join-Path $CONFIG.ConfigDir "memory-thresholds.json") | ConvertFrom-Json
    
    $status = @{
        IsSafe = $true
        Warnings = @()
        MemoryStatus = @{
            Current = $metrics.MemoryUsagePercent
            Warning = $thresholds.Warning
            Critical = $thresholds.Critical
            MaxAllowed = $thresholds.MaxAllowed
        }
        ProcessStatus = @{
            Total = $metrics.ProcessCount
            Npm = $metrics.NpmProcessCount
            Node = $metrics.NodeProcessCount
            Limit = $thresholds.ProcessLimit
        }
        DetailedMetrics = $metrics
    }
    
    # Check memory thresholds
    if ($metrics.MemoryUsagePercent -ge $thresholds.Critical) {
        $status.Warnings += "CRITICAL: Memory usage at $($metrics.MemoryUsagePercent)%"
        $status.IsSafe = $false
        Write-MemoryLog "Memory usage critical: $($metrics.MemoryUsagePercent)%" -Level 'CRITICAL'
    }
    elseif ($metrics.MemoryUsagePercent -ge $thresholds.Warning) {
        $status.Warnings += "WARNING: Memory usage at $($metrics.MemoryUsagePercent)%"
        Write-MemoryLog "Memory usage warning: $($metrics.MemoryUsagePercent)%" -Level 'WARNING'
    }
    
    # Check process limits
    if ($metrics.ProcessCount -gt $thresholds.ProcessLimit) {
        $status.Warnings += "WARNING: High process count ($($metrics.ProcessCount))"
        $status.IsSafe = $false
        Write-MemoryLog "Process count exceeded limit: $($metrics.ProcessCount)" -Level 'WARNING'
    }
    
    # Check npm/node process count
    if ($metrics.NpmProcessCount -gt 10) {
        $status.Warnings += "WARNING: High npm process count ($($metrics.NpmProcessCount))"
        Write-MemoryLog "High npm process count: $($metrics.NpmProcessCount)" -Level 'WARNING'
    }
    
    return $status
}

# New: Automated Recovery Function
function Start-AutomatedRecovery {
    param(
        [string]$TriggerReason,
        [hashtable]$CurrentMetrics
    )
    
    Write-MemoryLog "Starting automated recovery - Trigger: $TriggerReason" -Level 'WARNING'
    
    $recoverySteps = @(
        @{
            Name = "Stop excess processes"
            Action = { Start-ProcessCleanup -Force }
        },
        @{
            Name = "Clear npm cache"
            Action = { npm cache clean --force }
        },
        @{
            Name = "Reset node_modules"
            Action = {
                if (Test-Path "node_modules") {
                    Remove-Item "node_modules" -Recurse -Force
                    npm install --production
                }
            }
        },
        @{
            Name = "System garbage collection"
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
        Write-MemoryLog "Recovery attempt $attemptCount of $($CONFIG.RecoveryAttempts)" -Level 'INFO'
        
        foreach ($step in $recoverySteps) {
            try {
                Write-MemoryLog "Executing recovery step: $($step.Name)" -Level 'INFO'
                & $step.Action
            }
            catch {
                Write-MemoryLog "Failed recovery step $($step.Name): $_" -Level 'ERROR'
            }
        }
        
        # Check if recovery was successful
        $newMetrics = Get-MemoryMetrics
        if ($newMetrics.MemoryUsagePercent -lt $CONFIG.WarningMemoryPercent) {
            $recovered = $true
            Write-MemoryLog "Recovery successful - Memory usage: $($newMetrics.MemoryUsagePercent)%" -Level 'INFO'
        }
        else {
            Write-MemoryLog "Recovery attempt $attemptCount failed - Memory usage: $($newMetrics.MemoryUsagePercent)%" -Level 'WARNING'
            Start-Sleep -Seconds $CONFIG.RecoveryInterval
        }
    }
    
    if (-not $recovered) {
        Write-MemoryLog "Recovery failed after $attemptCount attempts" -Level 'CRITICAL'
        throw "Automated recovery failed to restore system stability"
    }
    
    return $recovered
}

# New: Scheduled Cleanup Function
function Start-ScheduledCleanup {
    $currentTime = Get-Date -Format "HH:mm"
    
    foreach ($schedule in $CONFIG.AutoCleanupSchedule.GetEnumerator()) {
        if ($currentTime -eq $schedule.Value) {
            Write-MemoryLog "Starting scheduled cleanup: $($schedule.Key)" -Level 'INFO'
            Start-ProcessCleanup -Force
            
            # Additional scheduled maintenance
            try {
                npm doctor
                npm audit fix
                Write-MemoryLog "Completed npm maintenance tasks" -Level 'INFO'
            }
            catch {
                Write-MemoryLog "Failed npm maintenance: $_" -Level 'ERROR'
            }
        }
    }
}

# Enhanced process monitoring and control
function Start-ProcessMonitoring {
    param(
        [switch]$Aggressive
    )
    
    Write-MemoryLog "Starting enhanced process monitoring" -Level 'INFO'
    
    while ($true) {
        try {
            $metrics = Get-MemoryMetrics
            $memoryStatus = Test-MemorySafe
            
            # Check for scheduled cleanup
            Start-ScheduledCleanup
            
            # Emergency checks
            if ($metrics.MemoryUsagePercent -gt $CONFIG.EmergencyMemoryPercent) {
                Write-MemoryLog "Emergency memory threshold exceeded: $($metrics.MemoryUsagePercent)%" -Level 'CRITICAL'
                if ($CONFIG.AutoRecoveryEnabled) {
                    Start-AutomatedRecovery -TriggerReason "Emergency memory threshold" -CurrentMetrics $metrics
                }
            }
            
            # Process management
            if ($metrics.ProcessCount -gt $CONFIG.MaxProcessCount) {
                Write-MemoryLog "Process count exceeded threshold: $($metrics.ProcessCount)" -Level 'WARNING'
                Start-ProcessCleanup -Force
            }
            
            # Regular cleanup checks
            if (-not $memoryStatus.IsSafe) {
                foreach ($warning in $memoryStatus.Warnings) {
                    Write-MemoryLog $warning -Level 'WARNING'
                }
                
                if ($CONFIG.AutoRecoveryEnabled) {
                    Start-AutomatedRecovery -TriggerReason "Unsafe memory status" -CurrentMetrics $metrics
                }
            }
            
            Start-Sleep -Seconds $CONFIG.ProcessCheckInterval
        }
        catch {
            Write-MemoryLog "Monitoring error: $_" -Level 'ERROR'
            Start-Sleep -Seconds ($CONFIG.ProcessCheckInterval * 2)
        }
    }
}

# Enhanced npm operation with process monitoring
function Start-NpmOperation {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Command,
        [int]$MaxRetries = 3,
        [int]$RetryDelaySeconds = 30
    )

    Initialize-Environment
    
    # Initial safety check with aggressive cleanup
    $safety = Test-MemorySafe
    if (-not $safety.IsSafe) {
        Write-MemoryLog "System not safe for npm operation: $($safety.Warnings -join '; ')" -Level 'ERROR'
        Start-ProcessCleanup -Force
        Start-ProcessMonitoring -Aggressive
        $safety = Test-MemorySafe
        if (-not $safety.IsSafe) {
            return $false
        }
    }
    
    # Configure npm
    if (-not (Set-NpmConfig)) {
        return $false
    }
    
    $retryCount = 0
    while ($retryCount -lt $MaxRetries) {
        try {
            $attemptMsg = "Attempt {0} of {1}: npm {2}" -f ($retryCount + 1), $MaxRetries, $Command
            Write-MemoryLog $attemptMsg
            
            # Start process monitoring
            $monitorJob = Start-Job -ScriptBlock {
                param($interval, $metricsDir, $config)
                while ($true) {
                    $metrics = Get-MemoryMetrics
                    Start-ProcessMonitoring
                    Start-Sleep -Seconds $interval
                }
            } -ArgumentList $CONFIG.ProcessCheckInterval, $CONFIG.MetricsDir, $CONFIG
            
            # Execute npm command
            $result = Invoke-Expression "npm $Command"
            Write-MemoryLog "Operation completed successfully"
            
            # Stop monitoring
            Stop-Job $monitorJob
            Remove-Job $monitorJob
            
            # Cleanup after successful operation
            Start-ProcessCleanup
            return $true
        }
        catch {
            $retryCount++
            $errorMessage = $_.Exception.Message
            Write-MemoryLog "Operation failed - $errorMessage" -Level 'ERROR'
            
            if ($retryCount -lt $MaxRetries) {
                Write-MemoryLog "Waiting $RetryDelaySeconds seconds before retry..." -Level 'WARNING'
                Start-Sleep -Seconds $RetryDelaySeconds
                
                # Check system state and cleanup if needed
                $safety = Test-MemorySafe
                if (-not $safety.IsSafe) {
                    Write-MemoryLog "System not safe for retry, cleaning up..." -Level 'WARNING'
                    Start-ProcessCleanup -Force
                }
            }
        }
    }
    
    Write-MemoryLog "Operation failed after $MaxRetries attempts" -Level 'ERROR'
    return $false
}

# Configure npm settings with validation
function Set-NpmConfig {
    try {
        # Verify temp directory exists and is writable
        if (-not (Test-Path $CONFIG.TempDir)) {
            New-Item -ItemType Directory -Path $CONFIG.TempDir -Force | Out-Null
        }
        
        # Test write access
        $testFile = Join-Path $CONFIG.TempDir "write-test.tmp"
        "test" | Out-File -FilePath $testFile
        Remove-Item $testFile
        
        # Configure npm
        npm config set cache $CONFIG.TempDir
        npm config set tmp $CONFIG.TempDir
        
        # Verify configuration
        $cacheDir = npm config get cache
        $tmpDir = npm config get tmp
        
        if ($cacheDir -ne $CONFIG.TempDir -or $tmpDir -ne $CONFIG.TempDir) {
            throw "NPM configuration verification failed"
        }
        
        Write-MemoryLog "NPM configured to use temporary directory: $($CONFIG.TempDir)" -Level 'INFO'
        return $true
    }
    catch {
        Write-MemoryLog "Failed to configure NPM: $_" -Level 'ERROR'
        return $false
    }
}

# Export functions
Export-ModuleMember -Function Start-NpmOperation, Get-MemoryMetrics, Test-MemorySafe, Start-ProcessCleanup 