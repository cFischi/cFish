# Daily-Health-Check.ps1
# This script performs daily health checks for cFish.io systems
# Following UcFish digital organization standards
# File: ucf-u5.1-daily-health-check.ps1

#-----------------------------------------------
# Configuration
#-----------------------------------------------
$CONFIG = @{
    LogDirectory = "logs"
    SyncSystem = @{
        Path = "sync-system"
        LogFile = "sync-system\tydisync-debug.log"
        ConfigFile = "sync-system\config\tydisync-config.json"
    }
    Thresholds = @{
        DiskSpaceWarning = 10GB  ##### Warning if less than 10GB available
        CPUWarningPercent = 80   ##### Warning if CPU usage > 80%
        MemoryWarningPercent = 80 ##### Warning if memory usage > 80%
        LogSizeWarning = 100MB   ##### Warning if log file > 100MB
    }
    CheckDirectories = @(
        @{ Path = "md"; Description = "Markdown content directory" },
        @{ Path = "json"; Description = "JSON content directory" },
        @{ Path = "wp-content"; Description = "WordPress content directory" },
        @{ Path = "backups"; Description = "Backup files directory" }
    )
}

#-----------------------------------------------
##### Initialize
#-----------------------------------------------
$ErrorActionPreference = "Stop"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$reportDate = Get-Date -Format "yyyyMMdd"
$reportFile = "$($CONFIG.LogDirectory)\health-check-$reportDate.log"
$issueCount = 0
$warningCount = 0

##### Create log directory if not exists
if (-not (Test-Path $CONFIG.LogDirectory)) {
    New-Item -Path $CONFIG.LogDirectory -ItemType Directory -Force | Out-Null
}

##### Function to log messages
function Write-HealthLog {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [Parameter(Mandatory=$false)]
        [ValidateSet("INFO", "WARNING", "ERROR")]
        [string]$Level = "INFO"
    )
    
    $logMessage = "[$timestamp] [$Level] $Message"
    
    switch ($Level) {
        "INFO" { 
            Write-Host $logMessage -ForegroundColor Green
        }
        "WARNING" { 
            Write-Host $logMessage -ForegroundColor Yellow
            ${script}:warningCount++
        }
        "ERROR" { 
            Write-Host $logMessage -ForegroundColor Red
            ${script}:issueCount++
        }
    }
    
    Add-Content -Path $reportFile -Value $logMessage
}

#-----------------------------------------------
##### Check System Resources
#-----------------------------------------------
function Test-SystemResources {
    Write-HealthLog "Checking system resources..."
    
    ##### Check disk space
    $drive = Get-PSDrive -Name C
    $freeSpace = $drive.Free
    $usedSpace = $drive.Used
    $totalSpace = $freeSpace + $usedSpace
    $freeSpacePercent = [math]::Round(($freeSpace / $totalSpace) * 100, 2)
    
    Write-HealthLog "Disk space: $([math]::Round($freeSpace / 1GB, 2)) GB free ($freeSpacePercent%)"
    
    if ($freeSpace -lt $CONFIG.Thresholds.DiskSpaceWarning) {
        Write-HealthLog "Low disk space detected! Less than $([math]::Round($CONFIG.Thresholds.DiskSpaceWarning / 1GB, 2)) GB available." -Level "WARNING"
    }
    
    ##### Get CPU usage - note this is a point-in-time measurement
    try {
        $cpuUsage = (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue
        $cpuUsageRounded = [math]::Round($cpuUsage, 2)
        
        Write-HealthLog "CPU Usage: $cpuUsageRounded%"
        
        if ($cpuUsage -gt $CONFIG.Thresholds.CPUWarningPercent) {
            Write-HealthLog "High CPU usage detected! Current usage: $cpuUsageRounded%" -Level "WARNING"
        }
    }
    catch {
        Write-HealthLog "Could not retrieve CPU usage information: $_" -Level "WARNING"
    }
    
    ##### Get memory usage
    try {
        $osInfo = Get-CimInstance Win32_OperatingSystem
        $totalMemory = $osInfo.TotalVisibleMemorySize * 1KB
        $freeMemory = $osInfo.FreePhysicalMemory * 1KB
        $usedMemory = $totalMemory - $freeMemory
        $memoryUsagePercent = [math]::Round(($usedMemory / $totalMemory) * 100, 2)
        
        Write-HealthLog "Memory Usage: $memoryUsagePercent% ($([math]::Round($usedMemory / 1GB, 2)) GB of $([math]::Round($totalMemory / 1GB, 2)) GB)"
        
        if ($memoryUsagePercent -gt $CONFIG.Thresholds.MemoryWarningPercent) {
            Write-HealthLog "High memory usage detected! Current usage: $memoryUsagePercent%" -Level "WARNING"
        }
    }
    catch {
        Write-HealthLog "Could not retrieve memory usage information: $_" -Level "WARNING"
    }
}

#-----------------------------------------------
##### Check tYDiSync~ System
#-----------------------------------------------
function Test-SyncSystem {
    Write-HealthLog "Checking tYDiSync~ system..."
    
    ##### Check if sync system directory exists
    if (-not (Test-Path $CONFIG.SyncSystem.Path)) {
        Write-HealthLog "Sync system directory not found at $($CONFIG.SyncSystem.Path)" -Level "ERROR"
        return
    }
    
    ##### Check log file
    if (Test-Path $CONFIG.SyncSystem.LogFile) {
        $logFile = Get-Item $CONFIG.SyncSystem.LogFile
        $logSize = $logFile.Length
        $logLastWrite = $logFile.LastWriteTime
        $logAgeHours = (New-TimeSpan -Start $logLastWrite -End (Get-Date)).TotalHours
        
        Write-HealthLog "Sync log file size: $([math]::Round($logSize / 1MB, 2)) MB, last updated $([math]::Round($logAgeHours, 2)) hours ago"
        
        if ($logSize -gt $CONFIG.Thresholds.LogSizeWarning) {
            Write-HealthLog "Sync log file is larger than $([math]::Round($CONFIG.Thresholds.LogSizeWarning / 1MB, 2)) MB. Consider log rotation." -Level "WARNING"
        }
        
        if ($logAgeHours -gt 24) {
            Write-HealthLog "Sync log file hasn't been updated in over 24 hours. Check if sync system is running." -Level "WARNING"
        }
        
        ##### Check for errors in the log file (last 50 lines)
        $logContent = Get-Content $CONFIG.SyncSystem.LogFile -Tail 50
        $errorCount = ($logContent | Select-String -Pattern "ERROR|CRITICAL|FATAL" -SimpleMatch).Count
        
        if ($errorCount -gt 0) {
            Write-HealthLog "Found $errorCount error(s) in recent sync log entries." -Level "WARNING"
            
            ##### Extract and display the last 3 error messages
            $errorLines = $logContent | Select-String -Pattern "ERROR|CRITICAL|FATAL" -SimpleMatch | Select-Object -Last 3
            foreach ($errorLine in $errorLines) {
                Write-HealthLog "Log Error: $errorLine" -Level "WARNING"
            }
        }
    }
    else {
        Write-HealthLog "Sync log file not found at $($CONFIG.SyncSystem.LogFile)" -Level "WARNING"
    }
    
    ##### Check config file
    if (Test-Path $CONFIG.SyncSystem.ConfigFile) {
        try {
            $syncConfig = Get-Content $CONFIG.SyncSystem.ConfigFile -Raw | ConvertFrom-Json
            Write-HealthLog "Sync configuration loaded successfully."
            
            ##### Validate some config parameters
            if (-not $syncConfig.watchDirectories -or $syncConfig.watchDirectories.Count -eq 0) {
                Write-HealthLog "No watch directories configured in sync system." -Level "WARNING"
            }
        }
        catch {
            Write-HealthLog "Failed to parse sync configuration file: $_" -Level "ERROR"
        }
    }
    else {
        Write-HealthLog "Sync configuration file not found at $($CONFIG.SyncSystem.ConfigFile)" -Level "WARNING"
    }
    
    ##### Check if sync process is running
    try {
        $nodeProcesses = Get-Process -Name "node" -ErrorAction SilentlyContinue
        
        if ($nodeProcesses -and $nodeProcesses.Count -gt 0) {
            Write-HealthLog "Node.js processes found: $($nodeProcesses.Count). Assuming sync system is running."
            ##### Attempt to get more details if possible
            try {
                $syncProcess = $nodeProcesses | Where-Object { $_.CommandLine -and $_.CommandLine.Contains("start-optimized-sync.js") }
                if ($syncProcess) {
                    Write-HealthLog "Confirmed sync system process found (PID: $($syncProcess.Id))"
                }
            }
            catch {
                ##### CommandLine property might not be accessible without elevation
                Write-HealthLog "Could not check command line details of node processes"
            }
        }
        else {
            Write-HealthLog "No Node.js processes found. Sync system is not currently running" -Level "WARNING"
        }
    }
    catch {
        Write-HealthLog "Error checking for sync system process: $_" -Level "WARNING"
    }
}

#-----------------------------------------------
##### Check Content Directories
#-----------------------------------------------
function Test-ContentDirectories {
    Write-HealthLog "Checking content directories..."
    
    foreach ($dir in $CONFIG.CheckDirectories) {
        if (Test-Path $dir.Path) {
            $stats = Get-ChildItem $dir.Path -Recurse -File -ErrorAction SilentlyContinue | Measure-Object
            $fileCount = $stats.Count
            
            Write-HealthLog "$($dir.Description): $fileCount files found"
            
            ##### Check for empty directories that should have content
            if ($fileCount -eq 0) {
                Write-HealthLog "$($dir.Description) is empty. This may indicate a synchronization issue." -Level "WARNING"
            }
        }
        else {
            Write-HealthLog "$($dir.Description) not found at $($dir.Path)" -Level "ERROR"
        }
    }
    
    ##### Check for MD-JSON file count consistency
    $mdFiles = Get-ChildItem "md" -Filter "*.md" -Recurse -ErrorAction SilentlyContinue | Measure-Object
    $jsonFiles = Get-ChildItem "json" -Filter "*.json" -Recurse -ErrorAction SilentlyContinue | Measure-Object
    
    Write-HealthLog "MD Files: $($mdFiles.Count), JSON Files: $($jsonFiles.Count)"
    
    if ($mdFiles.Count -gt 0 -and $jsonFiles.Count -gt 0) {
        $ratio = [math]::Abs(1 - ($jsonFiles.Count / $mdFiles.Count))
        
        if ($ratio -gt 0.1) { ##### More than 10% difference
            Write-HealthLog "Significant difference between MD and JSON file counts. Possible synchronization issue." -Level "WARNING"
        }
    }
}

#-----------------------------------------------
##### Check Recent Backups
#-----------------------------------------------
function Test-RecentBackups {
    Write-HealthLog "Checking recent backups..."
    
    $backupDir = "backups"
    
    if (Test-Path $backupDir) {
        $recentBackups = Get-ChildItem $backupDir -File | Where-Object { $_.LastWriteTime -gt (Get-Date).AddDays(-1) }
        
        if ($recentBackups.Count -gt 0) {
            Write-HealthLog "Found $($recentBackups.Count) backups created in the last 24 hours."
        }
        else {
            Write-HealthLog "No recent backups found in the last 24 hours." -Level "WARNING"
        }
    }
    else {
        Write-HealthLog "Backup directory not found at $backupDir" -Level "WARNING"
    }
}

#-----------------------------------------------
##### Run Checks
#-----------------------------------------------
try {
    Write-HealthLog "===== cFish.io Daily Health Check - $timestamp ====="
    
    Test-SystemResources
    Test-SyncSystem
    Test-ContentDirectories
    Test-RecentBackups
    
    ##### Summary
    if ($issueCount -gt 0 -or $warningCount -gt 0) {
        Write-HealthLog "===== Health Check Complete: $issueCount issues, $warningCount warnings ====="
        if ($issueCount -gt 0) {
            exit 1
        }
        else {
            exit 0
        }
    }
    else {
        Write-HealthLog "===== Health Check Complete: System Healthy ====="
        exit 0
    }
}
catch {
    Write-HealthLog "Critical error during health check: $_" -Level "ERROR"
    exit 1
} 
