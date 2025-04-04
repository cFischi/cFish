# resource-config.ps1
# Resource-Aware Architecture Configuration
# Purpose: Configures and enforces resource limits, implements cleanup mechanisms, and monitors usage
# Created: 05-07-2025

[CmdletBinding()]
param(
    [Parameter()]
    [int]$MaxMemoryPercent = 65,
    
    [Parameter()]
    [int]$MaxCpuPercent = 70,
    
    [Parameter()]
    [int]$CleanupThresholdPercent = 75,
    
    [Parameter()]
    [int]$EmergencyThresholdPercent = 85,
    
    [Parameter()]
    [string]$ConfigPath = "$PSScriptRoot\..\config\resource-limits.json",
    
    [Parameter()]
    [string]$LogPath = "$PSScriptRoot\..\logs\resource-config.log"
)

# Ensure log directory exists
$logDir = Split-Path $LogPath -Parent
if (-not (Test-Path $logDir)) {
    try {
        New-Item -Path $logDir -ItemType Directory -Force | Out-Null
        Write-Verbose "Created log directory: $logDir"
    } 
    catch {
        Write-Error "Failed to create log directory: $($_.Exception.Message)"
        exit 1
    }
}

# Ensure config directory exists
$configDir = Split-Path $ConfigPath -Parent
if (-not (Test-Path $configDir)) {
    try {
        New-Item -Path $configDir -ItemType Directory -Force | Out-Null
        Write-Verbose "Created config directory: $configDir"
    } 
    catch {
        Write-Error "Failed to create config directory: $($_.Exception.Message)"
        exit 1
    }
}

# Helper Functions
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    
    try {
        Add-Content -Path $LogPath -Value $logEntry
        
        switch ($Level) {
            "ERROR" { 
                Write-Host $logEntry -ForegroundColor Red 
            }
            "WARNING" { 
                Write-Host $logEntry -ForegroundColor Yellow 
            }
            "SUCCESS" { 
                Write-Host $logEntry -ForegroundColor Green 
            }
            default { 
                Write-Host $logEntry 
            }
        }
    }
    catch {
        Write-Error "Failed to write to log: $($_.Exception.Message)"
    }
}

function Get-SystemResourceInfo {
    try {
        # Get memory information
        $os = Get-CimInstance -ClassName Win32_OperatingSystem
        $totalMemoryMB = [math]::Round($os.TotalVisibleMemorySize / 1024)
        $freeMemoryMB = [math]::Round($os.FreePhysicalMemory / 1024)
        $usedMemoryPercent = [math]::Round(100 - (($freeMemoryMB / $totalMemoryMB) * 100), 2)
        
        # Get CPU information
        $cpuLoad = (Get-CimInstance -ClassName Win32_Processor | Measure-Object -Property LoadPercentage -Average).Average
        
        # Get process count
        $processCount = (Get-Process).Count
        
        # Get disk information
        $systemDrive = $env:SystemDrive
        $diskInfo = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='$systemDrive'"
        $totalSpaceGB = [math]::Round($diskInfo.Size / 1GB, 2)
        $freeSpaceGB = [math]::Round($diskInfo.FreeSpace / 1GB, 2)
        $usedSpacePercent = [math]::Round(100 - (($freeSpaceGB / $totalSpaceGB) * 100), 2)
        
        # Determine memory status
        $memoryStatus = "NORMAL"
        if ($usedMemoryPercent -ge $EmergencyThresholdPercent) {
            $memoryStatus = "EMERGENCY"
        }
        elseif ($usedMemoryPercent -ge $CleanupThresholdPercent) {
            $memoryStatus = "WARNING"
        }
        elseif ($usedMemoryPercent -ge $MaxMemoryPercent) {
            $memoryStatus = "ATTENTION"
        }
        
        # Determine CPU status
        $cpuStatus = "NORMAL"
        if ($cpuLoad -ge $EmergencyThresholdPercent) {
            $cpuStatus = "EMERGENCY"
        }
        elseif ($cpuLoad -ge $CleanupThresholdPercent) {
            $cpuStatus = "WARNING"
        }
        elseif ($cpuLoad -ge $MaxCpuPercent) {
            $cpuStatus = "ATTENTION"
        }
        
        # Determine disk status
        $diskStatus = "NORMAL"
        if ($usedSpacePercent -ge 95) {
            $diskStatus = "EMERGENCY"
        }
        elseif ($usedSpacePercent -ge 90) {
            $diskStatus = "WARNING"
        }
        elseif ($usedSpacePercent -ge 85) {
            $diskStatus = "ATTENTION"
        }
        
        # Determine process status
        $processStatus = "NORMAL"
        if ($processCount -ge 300) {
            $processStatus = "WARNING"
        }
        elseif ($processCount -ge 200) {
            $processStatus = "ATTENTION"
        }
        
        # Determine system status
        $systemStatus = "NORMAL"
        if ($usedMemoryPercent -ge $EmergencyThresholdPercent -or
            $cpuLoad -ge $EmergencyThresholdPercent -or
            $usedSpacePercent -ge 95 -or
            $processCount -ge 300) {
            $systemStatus = "EMERGENCY"
        }
        
        return @{
            Memory = @{
                TotalMB = $totalMemoryMB
                FreeMB = $freeMemoryMB
                UsedPercent = $usedMemoryPercent
                Status = $memoryStatus
            }
            CPU = @{
                LoadPercent = $cpuLoad
                Status = $cpuStatus
            }
            Disk = @{
                TotalGB = $totalSpaceGB
                FreeGB = $freeSpaceGB
                UsedPercent = $usedSpacePercent
                Status = $diskStatus
            }
            Processes = @{
                Count = $processCount
                Status = $processStatus
            }
            System = @{
                Name = $env:COMPUTERNAME
                OSVersion = $os.Caption
                LastBootTime = $os.LastBootUpTime
                Status = $systemStatus
            }
        }
    }
    catch {
        Write-Log "Failed to get system resource info: $($_.Exception.Message)" "ERROR"
        return $null
    }
}

function Get-ResourceLimitConfig {
    param(
        [switch]$CreateIfMissing = $true
    )
    
    try {
        if (Test-Path $ConfigPath) {
            $config = Get-Content -Path $ConfigPath -Raw | ConvertFrom-Json
            return $config
        }
        elseif ($CreateIfMissing) {
            $defaultConfig = @{
                version = "1.0.0"
                timestamp = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
                system = @{
                    maxMemoryPercent = $MaxMemoryPercent
                    maxCpuPercent = $MaxCpuPercent
                    cleanupThresholdPercent = $CleanupThresholdPercent
                    emergencyThresholdPercent = $EmergencyThresholdPercent
                }
                components = @{
                    core = @{
                        memoryLimitMB = 256
                        cpuLimitPercent = 20
                        priority = "high"
                    }
                    visualization = @{
                        memoryLimitMB = 384
                        cpuLimitPercent = 30
                        priority = "normal"
                    }
                    monitoring = @{
                        memoryLimitMB = 128
                        cpuLimitPercent = 10
                        priority = "normal"
                    }
                    testing = @{
                        memoryLimitMB = 256
                        cpuLimitPercent = 15
                        priority = "low"
                    }
                    installation = @{
                        memoryLimitMB = 512
                        cpuLimitPercent = 30
                        priority = "low"
                    }
                }
                cleanup = @{
                    intervals = @{
                        normal = 300  # 5 minutes
                        attention = 180  # 3 minutes
                        warning = 60  # 1 minute
                        emergency = 30  # 30 seconds
                    }
                    targets = @{
                        tempFiles = $true
                        logFiles = $true
                        nodeTempFiles = $true
                        npmCache = $true
                    }
                    retention = @{
                        logs = 7  # days
                        backups = 3  # count
                        temp = 1  # days
                    }
                }
                monitoring = @{
                    enabled = $true
                    interval = 60  # seconds
                    logRetention = 7  # days
                    memoryAlertThreshold = 80  # percent
                    cpuAlertThreshold = 75  # percent
                    diskAlertThreshold = 90  # percent
                }
            }
            
            # Save default config
            $defaultConfig | ConvertTo-Json -Depth 10 | Out-File -FilePath $ConfigPath -Encoding utf8
            Write-Log "Created default resource configuration at $ConfigPath" "SUCCESS"
            
            return $defaultConfig
        }
        else {
            Write-Log "Configuration file not found at $ConfigPath" "ERROR"
            return $null
        }
    }
    catch {
        Write-Log "Failed to get resource configuration: $($_.Exception.Message)" "ERROR"
        return $null
    }
}

function Set-ResourceLimits {
    param(
        [PSObject]$Config,
        [PSObject]$ResourceInfo
    )
    
    try {
        $env:NODE_OPTIONS = "--max-old-space-size=$($Config.components.core.memoryLimitMB)"
        Write-Log "Set Node.js memory limit to $($Config.components.core.memoryLimitMB)MB" "INFO"
        
        # Create .env file with resource limits
        $envFilePath = "$PSScriptRoot\..\config\.env"
        @"
# Resource Limits Configuration
# Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

# System Limits
MAX_MEMORY_PERCENT=$($Config.system.maxMemoryPercent)
MAX_CPU_PERCENT=$($Config.system.maxCpuPercent)
CLEANUP_THRESHOLD_PERCENT=$($Config.system.cleanupThresholdPercent)
EMERGENCY_THRESHOLD_PERCENT=$($Config.system.emergencyThresholdPercent)

# Component Limits
CORE_MEMORY_LIMIT_MB=$($Config.components.core.memoryLimitMB)
CORE_CPU_LIMIT_PERCENT=$($Config.components.core.cpuLimitPercent)

VISUALIZATION_MEMORY_LIMIT_MB=$($Config.components.visualization.memoryLimitMB)
VISUALIZATION_CPU_LIMIT_PERCENT=$($Config.components.visualization.cpuLimitPercent)

MONITORING_MEMORY_LIMIT_MB=$($Config.components.monitoring.memoryLimitMB)
MONITORING_CPU_LIMIT_PERCENT=$($Config.components.monitoring.cpuLimitPercent)

TESTING_MEMORY_LIMIT_MB=$($Config.components.testing.memoryLimitMB)
TESTING_CPU_LIMIT_PERCENT=$($Config.components.testing.cpuLimitPercent)

INSTALLATION_MEMORY_LIMIT_MB=$($Config.components.installation.memoryLimitMB)
INSTALLATION_CPU_LIMIT_PERCENT=$($Config.components.installation.cpuLimitPercent)

# System Resource Status
SYSTEM_MEMORY_TOTAL_MB=$($ResourceInfo.Memory.TotalMB)
SYSTEM_MEMORY_FREE_MB=$($ResourceInfo.Memory.FreeMB)
SYSTEM_MEMORY_USED_PERCENT=$($ResourceInfo.Memory.UsedPercent)
SYSTEM_MEMORY_STATUS=$($ResourceInfo.Memory.Status)

SYSTEM_CPU_LOAD_PERCENT=$($ResourceInfo.CPU.LoadPercent)
SYSTEM_CPU_STATUS=$($ResourceInfo.CPU.Status)

SYSTEM_DISK_TOTAL_GB=$($ResourceInfo.Disk.TotalGB)
SYSTEM_DISK_FREE_GB=$($ResourceInfo.Disk.FreeGB)
SYSTEM_DISK_USED_PERCENT=$($ResourceInfo.Disk.UsedPercent)
SYSTEM_DISK_STATUS=$($ResourceInfo.Disk.Status)

SYSTEM_PROCESS_COUNT=$($ResourceInfo.Processes.Count)
SYSTEM_PROCESS_STATUS=$($ResourceInfo.Processes.Status)

SYSTEM_STATUS=$($ResourceInfo.System.Status)
"@ | Out-File -FilePath $envFilePath -Encoding utf8
        
        Write-Log "Generated environment configuration at $envFilePath" "SUCCESS"
        
        # Create resource-status.json for monitoring
        $statusFilePath = "$PSScriptRoot\..\config\resource-status.json"
        $status = @{
            timestamp = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
            resources = $ResourceInfo
            limits = $Config.system
            components = $Config.components
        }
        
        $status | ConvertTo-Json -Depth 10 | Out-File -FilePath $statusFilePath -Encoding utf8
        Write-Log "Generated resource status at $statusFilePath" "SUCCESS"
        
        return $true
    }
    catch {
        Write-Log "Failed to set resource limits: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Start-ResourceMonitoring {
    param(
        [PSObject]$Config
    )
    
    try {
        if (-not $Config.monitoring.enabled) {
            Write-Log "Resource monitoring is disabled in configuration" "INFO"
            return $false
        }
        
        $monitoringScriptPath = "$PSScriptRoot\resource-monitor.ps1"
        $monitoringLogPath = "$PSScriptRoot\..\logs\resource-monitor.log"
        
        # Create monitoring script if it doesn't exist
        if (-not (Test-Path $monitoringScriptPath)) {
            @"
# resource-monitor.ps1
# Resource Monitoring Script
# Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

[CmdletBinding()]
param(
    [Parameter()]
    [int]`$Interval = $($Config.monitoring.interval),
    
    [Parameter()]
    [int]`$MemoryThreshold = $($Config.monitoring.memoryAlertThreshold),
    
    [Parameter()]
    [int]`$CpuThreshold = $($Config.monitoring.cpuAlertThreshold),
    
    [Parameter()]
    [int]`$DiskThreshold = $($Config.monitoring.diskAlertThreshold),
    
    [Parameter()]
    [string]`$LogPath = "$monitoringLogPath",
    
    [Parameter()]
    [string]`$StatusPath = "$PSScriptRoot\..\config\resource-status.json"
)

# Monitoring loop
`$running = `$true
`$counter = 0

function Write-MonitorLog {
    param(
        [string]`$Message,
        [string]`$Level = "INFO"
    )
    
    `$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    `$logEntry = "[`$timestamp] [`$Level] `$Message"
    
    Add-Content -Path `$LogPath -Value `$logEntry
    Write-Host `$logEntry
}

function Get-SystemResourceInfo {
    try {
        # Get memory information
        `$os = Get-CimInstance -ClassName Win32_OperatingSystem
        `$totalMemoryMB = [math]::Round(`$os.TotalVisibleMemorySize / 1024)
        `$freeMemoryMB = [math]::Round(`$os.FreePhysicalMemory / 1024)
        `$usedMemoryPercent = [math]::Round(100 - ((`$freeMemoryMB / `$totalMemoryMB) * 100), 2)
        
        # Get CPU information
        `$cpuLoad = (Get-CimInstance -ClassName Win32_Processor | Measure-Object -Property LoadPercentage -Average).Average
        
        # Get process count
        `$processCount = (Get-Process).Count
        
        # Get disk information
        `$systemDrive = `$env:SystemDrive
        `$diskInfo = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='`$systemDrive'"
        `$totalSpaceGB = [math]::Round(`$diskInfo.Size / 1GB, 2)
        `$freeSpaceGB = [math]::Round(`$diskInfo.FreeSpace / 1GB, 2)
        `$usedSpacePercent = [math]::Round(100 - ((`$freeSpaceGB / `$totalSpaceGB) * 100), 2)
        
        # Determine memory status
        `$memoryStatus = "NORMAL"
        if (`$usedMemoryPercent -ge 90) {
            `$memoryStatus = "CRITICAL"
        }
        elseif (`$usedMemoryPercent -ge `$MemoryThreshold) {
            `$memoryStatus = "WARNING"
        }
        
        # Determine CPU status
        `$cpuStatus = "NORMAL"
        if (`$cpuLoad -ge 90) {
            `$cpuStatus = "CRITICAL"
        }
        elseif (`$cpuLoad -ge `$CpuThreshold) {
            `$cpuStatus = "WARNING"
        }
        
        # Determine disk status
        `$diskStatus = "NORMAL"
        if (`$usedSpacePercent -ge 95) {
            `$diskStatus = "CRITICAL"
        }
        elseif (`$usedSpacePercent -ge `$DiskThreshold) {
            `$diskStatus = "WARNING"
        }
        
        # Determine process status
        `$processStatus = "NORMAL"
        if (`$processCount -ge 300) {
            `$processStatus = "WARNING"
        }
        elseif (`$processCount -ge 200) {
            `$processStatus = "ATTENTION"
        }
        
        return @{
            Memory = @{
                TotalMB = `$totalMemoryMB
                FreeMB = `$freeMemoryMB
                UsedPercent = `$usedMemoryPercent
                Status = `$memoryStatus
            }
            CPU = @{
                LoadPercent = `$cpuLoad
                Status = `$cpuStatus
            }
            Disk = @{
                TotalGB = `$totalSpaceGB
                FreeGB = `$freeSpaceGB
                UsedPercent = `$usedSpacePercent
                Status = `$diskStatus
            }
            Processes = @{
                Count = `$processCount
                Status = `$processStatus
            }
            Timestamp = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
        }
    }
    catch {
        Write-MonitorLog "Failed to get system resource info: `$(`$_.Exception.Message)" "ERROR"
        return `$null
    }
}

Write-MonitorLog "Resource monitoring started (Interval: `$Interval seconds)" "INFO"

# Main monitoring loop
while (`$running) {
    try {
        `$counter++
        `$resources = Get-SystemResourceInfo
        
        if (`$null -eq `$resources) {
            Write-MonitorLog "Failed to get resource information" "ERROR"
            continue
        }
        
        # Update status file
        `$status = @{
            timestamp = `$resources.Timestamp
            resources = `$resources
        }
        
        `$status | ConvertTo-Json -Depth 10 | Out-File -FilePath `$StatusPath -Encoding utf8
        
        # Log resources if threshold exceeded or every 10 cycles
        if (
            `$resources.Memory.Status -ne "NORMAL" -or
            `$resources.CPU.Status -ne "NORMAL" -or
            `$resources.Disk.Status -ne "NORMAL" -or
            `$counter % 10 -eq 0
        ) {
            Write-MonitorLog "Memory: `$(`$resources.Memory.UsedPercent)% (Free: `$(`$resources.Memory.FreeMB)MB) - Status: `$(`$resources.Memory.Status)" "INFO"
            Write-MonitorLog "CPU: `$(`$resources.CPU.LoadPercent)% - Status: `$(`$resources.CPU.Status)" "INFO"
            Write-MonitorLog "Disk: `$(`$resources.Disk.UsedPercent)% (Free: `$(`$resources.Disk.FreeGB)GB) - Status: `$(`$resources.Disk.Status)" "INFO"
            Write-MonitorLog "Processes: `$(`$resources.Processes.Count)" "INFO"
        }
        
        # Alert if resource status is critical
        if (
            `$resources.Memory.Status -eq "CRITICAL" -or
            `$resources.CPU.Status -eq "CRITICAL" -or
            `$resources.Disk.Status -eq "CRITICAL"
        ) {
            Write-MonitorLog "CRITICAL RESOURCE STATUS DETECTED!" "ERROR"
            
            # Emergency cleanup for critical memory state
            if (`$resources.Memory.Status -eq "CRITICAL") {
                Write-MonitorLog "Emergency memory cleanup required" "ERROR"
                # Implement cleanup logic here or call external script
            }
        }
        
        Start-Sleep -Seconds `$Interval
    }
    catch {
        Write-MonitorLog "Monitoring error: `$(`$_.Exception.Message)" "ERROR"
        Start-Sleep -Seconds 30  # Wait longer after error
    }
}
"@ | Out-File -FilePath $monitoringScriptPath -Encoding utf8
            
            Write-Log "Created resource monitoring script at $monitoringScriptPath" "SUCCESS"
        }
        
        # Start monitoring in background
        $powershellPath = "powershell.exe"
        $arguments = "-ExecutionPolicy Bypass -NoProfile -File `"$monitoringScriptPath`""
        
        Start-Process -FilePath $powershellPath -ArgumentList $arguments -WindowStyle Hidden
        Write-Log "Started resource monitoring process" "SUCCESS"
        
        return $true
    }
    catch {
        Write-Log "Failed to start resource monitoring: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Start-CleanupSchedule {
    param(
        [PSObject]$Config
    )
    
    try {
        $cleanupScriptPath = "$PSScriptRoot\resource-cleanup.ps1"
        
        # Create cleanup script if it doesn't exist
        if (-not (Test-Path $cleanupScriptPath)) {
            @"
# resource-cleanup.ps1
# Resource Cleanup Script
# Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

[CmdletBinding()]
param(
    [Parameter()]
    [string]`$ConfigPath = "$ConfigPath",
    
    [Parameter()]
    [string]`$LogPath = "$PSScriptRoot\..\logs\resource-cleanup.log",
    
    [Parameter()]
    [switch]`$Force = `$false
)

function Write-CleanupLog {
    param(
        [string]`$Message,
        [string]`$Level = "INFO"
    )
    
    `$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    `$logEntry = "[`$timestamp] [`$Level] `$Message"
    
    Add-Content -Path `$LogPath -Value `$logEntry
    Write-Host `$logEntry
}

function Get-ResourceStatus {
    try {
        `$statusPath = "$PSScriptRoot\..\config\resource-status.json"
        
        if (Test-Path `$statusPath) {
            `$status = Get-Content -Path `$statusPath -Raw | ConvertFrom-Json
            return `$status
        }
        else {
            Write-CleanupLog "Resource status file not found" "ERROR"
            return `$null
        }
    }
    catch {
        Write-CleanupLog "Failed to get resource status: `$(`$_.Exception.Message)" "ERROR"
        return `$null
    }
}

function Get-CleanupConfig {
    try {
        if (Test-Path `$ConfigPath) {
            `$config = Get-Content -Path `$ConfigPath -Raw | ConvertFrom-Json
            return `$config
        }
        else {
            Write-CleanupLog "Configuration file not found" "ERROR"
            return `$null
        }
    }
    catch {
        Write-CleanupLog "Failed to get cleanup configuration: `$(`$_.Exception.Message)" "ERROR"
        return `$null
    }
}

function Invoke-TempFilesCleanup {
    try {
        `$tempDir = [System.IO.Path]::GetTempPath()
        `$tempFiles = Get-ChildItem -Path `$tempDir -File -Recurse | Where-Object {
            `$_.LastWriteTime -lt (Get-Date).AddDays(-1)
        }
        
        Write-CleanupLog "Found `$(`$tempFiles.Count) temporary files to clean up" "INFO"
        
        foreach (`$file in `$tempFiles) {
            try {
                Remove-Item -Path `$file.FullName -Force -ErrorAction SilentlyContinue
            }
            catch {
                # Just log and continue, don't fail the entire cleanup
                Write-CleanupLog "Failed to remove `$(`$file.FullName): `$(`$_.Exception.Message)" "WARNING"
            }
        }
        
        return `$tempFiles.Count
    }
    catch {
        Write-CleanupLog "Failed to clean up temp files: `$(`$_.Exception.Message)" "ERROR"
        return 0
    }
}

function Invoke-NodeModulesCleanup {
    try {
        `$npmCache = npm cache verify
        Write-CleanupLog "NPM cache verified: `$npmCache" "INFO"
        
        return `$true
    }
    catch {
        Write-CleanupLog "Failed to clean up Node modules: `$(`$_.Exception.Message)" "ERROR"
        return `$false
    }
}

function Invoke-LogFilesCleanup {
    param(
        [int]`$RetentionDays = 7
    )
    
    try {
        `$logDir = "$PSScriptRoot\..\logs"
        
        if (-not (Test-Path `$logDir)) {
            Write-CleanupLog "Log directory not found" "WARNING"
            return 0
        }
        
        `$oldLogFiles = Get-ChildItem -Path `$logDir -File -Filter "*.log" | Where-Object {
            `$_.LastWriteTime -lt (Get-Date).AddDays(-`$RetentionDays)
        }
        
        Write-CleanupLog "Found `$(`$oldLogFiles.Count) log files older than `$RetentionDays days" "INFO"
        
        foreach (`$file in `$oldLogFiles) {
            try {
                Remove-Item -Path `$file.FullName -Force
            }
            catch {
                Write-CleanupLog "Failed to remove `$(`$file.FullName): `$(`$_.Exception.Message)" "WARNING"
            }
        }
        
        return `$oldLogFiles.Count
    }
    catch {
        Write-CleanupLog "Failed to clean up log files: `$(`$_.Exception.Message)" "ERROR"
        return 0
    }
}

function Invoke-ResourceCleanup {
    param(
        [PSObject]`$Config,
        [PSObject]`$Status
    )
    
    try {
        `$cleanupResults = @{
            Timestamp = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
            TempFiles = 0
            LogFiles = 0
            NodeModules = `$false
            Status = "SUCCESS"
        }
        
        # Determine if cleanup is needed based on status
        `$needsCleanup = `$Force
        
        if (`$null -ne `$Status) {
            `$memoryStatus = `$Status.resources.Memory.Status
            if (`$memoryStatus -eq "WARNING" -or `$memoryStatus -eq "CRITICAL") {
                `$needsCleanup = `$true
                Write-CleanupLog "Cleanup needed due to memory status: `$memoryStatus" "WARNING"
            }
        }
        
        if (-not `$needsCleanup) {
            Write-CleanupLog "No cleanup needed at this time" "INFO"
            return `$cleanupResults
        }
        
        # Clean up temp files
        if (`$Config.cleanup.targets.tempFiles) {
            Write-CleanupLog "Starting temporary files cleanup" "INFO"
            `$cleanupResults.TempFiles = Invoke-TempFilesCleanup
        }
        
        # Clean up log files
        if (`$Config.cleanup.targets.logFiles) {
            Write-CleanupLog "Starting log files cleanup" "INFO"
            `$cleanupResults.LogFiles = Invoke-LogFilesCleanup -RetentionDays `$Config.cleanup.retention.logs
        }
        
        # Clean up Node modules
        if (`$Config.cleanup.targets.npmCache) {
            Write-CleanupLog "Starting Node modules cleanup" "INFO"
            `$cleanupResults.NodeModules = Invoke-NodeModulesCleanup
        }
        
        # Force garbage collection
        [System.GC]::Collect()
        Write-CleanupLog "Forced garbage collection" "INFO"
        
        # Record cleanup results
        `$resultsPath = "$PSScriptRoot\..\logs\cleanup-results.json"
        `$cleanupResults | ConvertTo-Json -Depth 5 | Out-File -FilePath `$resultsPath -Encoding utf8
        
        Write-CleanupLog "Cleanup completed successfully" "SUCCESS"
        return `$cleanupResults
    }
    catch {
        Write-CleanupLog "Cleanup failed: `$(`$_.Exception.Message)" "ERROR"
        return @{
            Timestamp = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
            Status = "FAILED"
            Error = `$_.Exception.Message
        }
    }
}

# Main execution
try {
    Write-CleanupLog "===== Resource Cleanup Started =====" "INFO"
    
    # Get configuration
    `$config = Get-CleanupConfig
    if (`$null -eq `$config) {
        Write-CleanupLog "Failed to get configuration, aborting" "ERROR"
        exit 1
    }
    
    # Get current status
    `$status = Get-ResourceStatus
    
    # Perform cleanup
    `$results = Invoke-ResourceCleanup -Config `$config -Status `$status
    
    Write-CleanupLog "Cleanup summary:" "INFO"
    Write-CleanupLog "Temp files removed: `$(`$results.TempFiles)" "INFO"
    Write-CleanupLog "Log files removed: `$(`$results.LogFiles)" "INFO"
    Write-CleanupLog "Node modules cleaned: `$(`$results.NodeModules)" "INFO"
    
    Write-CleanupLog "===== Resource Cleanup Completed =====" "SUCCESS"
}
catch {
    Write-CleanupLog "Unexpected error: `$(`$_.Exception.Message)" "ERROR"
    Write-CleanupLog "Stack Trace: `$(`$_.ScriptStackTrace)" "ERROR"
    exit 1
}
"@ | Out-File -FilePath $cleanupScriptPath -Encoding utf8
            
            Write-Log "Created resource cleanup script at $cleanupScriptPath" "SUCCESS"
        }
        
        # Schedule cleanup based on system status
        $status = $ResourceInfo.Memory.Status
        $interval = $Config.cleanup.intervals.$($status.ToLower())
        
        # Create scheduled task
        $taskName = "ResourceCleanup"
        $powershellPath = "powershell.exe"
        $arguments = "-ExecutionPolicy Bypass -NoProfile -File `"$cleanupScriptPath`""
        
        # Schedule initial cleanup now
        Start-Process -FilePath $powershellPath -ArgumentList $arguments -WindowStyle Hidden
        Write-Log "Started initial resource cleanup" "SUCCESS"
        
        # Create a scheduled task for regular cleanup
        if ($status -eq "WARNING" -or $status -eq "EMERGENCY") {
            Write-Log "Resource status is $status, scheduling frequent cleanup (every $interval seconds)" "WARNING"
            
            # For immediate situations, we'll use a background job rather than a scheduled task
            Start-Job -ScriptBlock {
                param($cleanupScript, $interval)
                
                while ($true) {
                    Start-Process -FilePath "powershell.exe" -ArgumentList "-ExecutionPolicy Bypass -NoProfile -File `"$cleanupScript`"" -WindowStyle Hidden
                    Start-Sleep -Seconds $interval
                }
            } -ArgumentList $cleanupScriptPath, $interval
            
            Write-Log "Started cleanup job with $interval second interval" "SUCCESS"
        }
        
        return $true
    }
    catch {
        Write-Log "Failed to setup cleanup schedule: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

# Main execution
try {
    Write-Log "===== Resource Configuration Started =====" "INFO"
    
    # Get system resource information
    $resourceInfo = Get-SystemResourceInfo
    if ($null -eq $resourceInfo) {
        Write-Log "Failed to get system resource information, aborting" "ERROR"
        exit 1
    }
    
    Write-Log "System resources:" "INFO"
    Write-Log "Memory: $($resourceInfo.Memory.UsedPercent)% used ($($resourceInfo.Memory.FreeMB)MB free of $($resourceInfo.Memory.TotalMB)MB total) - Status: $($resourceInfo.Memory.Status)" "INFO"
    Write-Log "CPU: $($resourceInfo.CPU.LoadPercent)% - Status: $($resourceInfo.CPU.Status)" "INFO"
    Write-Log "Disk: $($resourceInfo.Disk.UsedPercent)% used ($($resourceInfo.Disk.FreeGB)GB free of $($resourceInfo.Disk.TotalGB)GB total) - Status: $($resourceInfo.Disk.Status)" "INFO"
    Write-Log "Processes: $($resourceInfo.Processes.Count) - Status: $($resourceInfo.Processes.Status)" "INFO"
    Write-Log "System status: $($resourceInfo.System.Status)" "INFO"
    
    # Get or create resource limit configuration
    $config = Get-ResourceLimitConfig -CreateIfMissing
    if ($null -eq $config) {
        Write-Log "Failed to get or create resource configuration, aborting" "ERROR"
        exit 1
    }
    
    # Set resource limits
    $limitsResult = Set-ResourceLimits -Config $config -ResourceInfo $resourceInfo
    if (-not $limitsResult) {
        Write-Log "Failed to set resource limits, aborting" "ERROR"
        exit 1
    }
    
    # Start resource monitoring
    $monitoringResult = Start-ResourceMonitoring -Config $config
    if (-not $monitoringResult) {
        Write-Log "Failed to start resource monitoring" "WARNING"
    }
    
    # Setup cleanup schedule
    $cleanupResult = Start-CleanupSchedule -Config $config
    if (-not $cleanupResult) {
        Write-Log "Failed to setup cleanup schedule" "WARNING"
    }
    
    Write-Log "===== Resource Configuration Completed =====" "SUCCESS"
}
catch {
    Write-Log "Unexpected error: $($_.Exception.Message)" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    exit 1
} 