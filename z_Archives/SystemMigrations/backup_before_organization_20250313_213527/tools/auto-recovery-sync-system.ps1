# auto-recovery-sync-system.ps1
# Auto-recovery mechanism for tYDiSync synchronization system
# Following UcFish digital organization standards
# Department: U5 - Data Management
# Function: 3 - System Recovery
# Version: 0.5.5
# Date: 2025-03-14

#-----------------------------------------------
# Configuration
#-----------------------------------------------
$CONFIG = @{
    SyncSystem = @{
        MainDirectory = "C:\Users\Chris\cFish.io\cFish.io\U5-Data\Synchronization\tydisync"
        StartScript = "C:\Users\Chris\cFish.io\cFish.io\U5-Data\Synchronization\tydisync\start-tydisync.bat"
        LogFile = "C:\Users\Chris\cFish.io\cFish.io\U5-Data\Synchronization\tydisync\logs\tydisync.log"
        StateDirectory = "C:\Users\Chris\cFish.io\cFish.io\U5-Data\Synchronization\tydisync\state"
        RequiredStateFiles = @(
            "sync-status.json",
            "last-sync.timestamp",
            "active-files.json"
        )
    }
    Monitoring = @{
        CheckIntervalSeconds = 300  ##### 5 minutes
        MaxRestartAttempts = 3
        WaitTimeAfterRestartSeconds = 20
    }
    LogFile = "C:\Users\Chris\cFish.io\tools\logs\sync-auto-recovery-$(Get-Date -Format 'yyyyMMdd').log"
    RunAsService = $false  ##### Set to true when running as a scheduled task
}

#-----------------------------------------------
##### Initialize
#-----------------------------------------------
$ErrorActionPreference = "Stop"
$restartAttempts = 0
$lastRestartTime = [DateTime]::MinValue
$scriptRoot = $PSScriptRoot
if (-not $scriptRoot) {
    $scriptRoot = (Get-Location).Path
}

##### Create log directory if it doesn't exist
$logDir = Split-Path -Parent $CONFIG.LogFile
if (-not (Test-Path $logDir)) {
    New-Item -Path $logDir -ItemType Directory -Force | Out-Null
}

#-----------------------------------------------
##### Functions
#-----------------------------------------------
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    ##### Write to console
    switch ($Level) {
        "ERROR" { Write-Host $logMessage -ForegroundColor Red }
        "WARNING" { Write-Host $logMessage -ForegroundColor Yellow }
        "SUCCESS" { Write-Host $logMessage -ForegroundColor Green }
        default { Write-Host $logMessage }
    }
    
    ##### Write to log file
    Add-Content -Path $CONFIG.LogFile -Value $logMessage
}

function Test-SyncSystemRunning {
    ##### Check for node processes
    $nodeProcess = Get-Process -Name "node" -ErrorAction SilentlyContinue | 
                   Where-Object { $_.CommandLine -like "*start-optimized-sync.js*" -or $_.CommandLine -like "*tydisync*" }
    
    if ($null -ne $nodeProcess) {
        Write-Log "Found running node process for tYDiSync" -Level "INFO"
        return $true
    }
    
    ##### Check for cmd.exe processes running the batch file
    $batchProcess = Get-Process -Name "cmd" -ErrorAction SilentlyContinue | 
                    Where-Object { $_.CommandLine -like "*start-tydisync.bat*" -or $_.CommandLine -like "*start-optimized-sync.bat*" }
    
    if ($null -ne $batchProcess) {
        Write-Log "Found running batch process for tYDiSync" -Level "INFO"
        return $true
    }
    
    ##### Check for npm processes that might be running the sync system
    $npmProcess = Get-Process -Name "npm" -ErrorAction SilentlyContinue | 
                  Where-Object { $_.CommandLine -like "*tydisync*" -or $_.CommandLine -like "*sync*" }
    
    if ($null -ne $npmProcess) {
        Write-Log "Found running npm process that might be related to tYDiSync" -Level "INFO"
        return $true
    }
    
    ##### If we've reached this point, no relevant processes were found
    Write-Log "No running tYDiSync processes found" -Level "WARNING"
    return $false
}

function Test-StateDirectoryReady {
    $stateDir = $CONFIG.SyncSystem.StateDirectory
    
    ##### Check if state directory exists
    if (-not (Test-Path $stateDir)) {
        Write-Log "State directory does not exist: $stateDir" -Level "WARNING"
        try {
            New-Item -Path $stateDir -ItemType Directory -Force | Out-Null
            Write-Log "Created state directory: $stateDir" -Level "SUCCESS"
        }
        catch {
            Write-Log "Failed to create state directory: $_" -Level "ERROR"
            return $false
        }
    }
    
    ##### Check if required state files exist, create placeholders if missing
    $allFilesExist = $true
    
    foreach ($file in $CONFIG.SyncSystem.RequiredStateFiles) {
        $filePath = Join-Path -Path $stateDir -ChildPath $file
        if (-not (Test-Path $filePath)) {
            Write-Log "State file missing: $file" -Level "WARNING"
            
            try {
                switch ($file) {
                    "sync-status.json" {
                        @{
                            "status" = "idle"
                            "lastSyncTime" = [DateTime]::Now.ToString("o")
                            "syncCount" = 0
                            "errors" = @()
                            "initialized" = $true
                        } | ConvertTo-Json | Set-Content -Path $filePath
                    }
                    "last-sync.timestamp" {
                        [DateTime]::Now.ToString("o") | Set-Content -Path $filePath
                    }
                    "active-files.json" {
                        @{
                            "files" = @()
                            "lastUpdated" = [DateTime]::Now.ToString("o")
                        } | ConvertTo-Json | Set-Content -Path $filePath
                    }
                    default {
                        ##### Empty file for any other required files
                        "" | Set-Content -Path $filePath
                    }
                }
                
                Write-Log "Created placeholder state file: $file" -Level "SUCCESS"
            }
            catch {
                Write-Log "Failed to create state file '$file': $_" -Level "ERROR"
                $allFilesExist = $false
            }
        }
    }
    
    return $allFilesExist
}

function Start-SyncSystem {
    try {
        Write-Log "Starting sync system..." -Level "INFO"
        
        ##### Check if start script exists
        if (-not (Test-Path $CONFIG.SyncSystem.StartScript)) {
            Write-Log "Sync system start script not found at: $($CONFIG.SyncSystem.StartScript)" -Level "ERROR"
            
            ##### Check if the alternative script exists
            $alternativeScript = Join-Path -Path (Split-Path -Parent $CONFIG.SyncSystem.StartScript) -ChildPath "start-optimized-sync.bat"
            if (Test-Path $alternativeScript) {
                Write-Log "Found alternative start script: $alternativeScript" -Level "INFO"
                
                ##### Create a wrapper script
                try {
                    $wrapperContent = @"
@echo off
REM =========================================================
REM   tYDiSync - Synchronization System Launcher
REM   Version: 0.5.5
REM   Date: 2025-03-14
REM =========================================================
REM   This file serves as the main entry point for the tYDiSync system
REM   It redirects to the actual implementation file for better maintainability
REM =========================================================

echo.
echo =========================================================
echo   tYDiSync - Synchronization System Launcher
echo =========================================================
echo.

REM Get the directory of this batch file
set "SCRIPT_DIR=%~dp0"
cd "%SCRIPT_DIR%"

REM Check if the target script exists
if not exist "%SCRIPT_DIR%start-optimized-sync.bat" (
    echo ERROR: Implementation file not found.
    echo Expected: %SCRIPT_DIR%start-optimized-sync.bat
    echo.
    echo Please run the auto-recovery script to fix this issue.
    exit /b 1
)

REM Launch the actual implementation
echo Launching synchronization system...
echo.
call "%SCRIPT_DIR%start-optimized-sync.bat" %*

REM Return the exit code from the implementation
exit /b %ERRORLEVEL%
"@
                    $wrapperContent | Set-Content -Path $CONFIG.SyncSystem.StartScript -Force
                    Write-Log "Created wrapper script: $($CONFIG.SyncSystem.StartScript)" -Level "SUCCESS"
                }
                catch {
                    Write-Log "Failed to create wrapper script: $_" -Level "ERROR"
                }
            }
            else {
                return $false
            }
        }
        
        ##### Start the sync system process
        $startInfo = New-Object System.Diagnostics.ProcessStartInfo
        $startInfo.FileName = $CONFIG.SyncSystem.StartScript
        $startInfo.WorkingDirectory = Split-Path -Parent $CONFIG.SyncSystem.StartScript
        $startInfo.UseShellExecute = $true
        $startInfo.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Normal
        
        $process = [System.Diagnostics.Process]::Start($startInfo)
        Write-Log "Started process with ID: $($process.Id)" -Level "INFO"
        
        ##### Wait for process to start
        $timeout = (Get-Date).AddSeconds($CONFIG.Monitoring.WaitTimeAfterRestartSeconds)
        while ((Get-Date) -lt $timeout) {
            if (Test-SyncSystemRunning) {
                Write-Log "Sync system started successfully" -Level "SUCCESS"
                return $true
            }
            Start-Sleep -Seconds 1
        }
        
        Write-Log "Timeout waiting for sync system to start" -Level "ERROR"
        return $false
    }
    catch {
        Write-Log "Failed to start sync system: $_" -Level "ERROR"
        return $false
    }
}

function Restart-SyncSystem {
    $restartAttempts++
    $lastRestartTime = [DateTime]::Now
    
    Write-Log "Attempting to restart sync system (Attempt $restartAttempts of $($CONFIG.Monitoring.MaxRestartAttempts))" -Level "WARNING"
    
    ##### Ensure state directory is ready
    if (-not (Test-StateDirectoryReady)) {
        Write-Log "State directory setup failed, attempting to continue anyway" -Level "WARNING"
    }
    
    ##### Kill any existing sync processes that might be hung
    Get-Process -Name "node" -ErrorAction SilentlyContinue | 
    Where-Object { $_.CommandLine -like "*tydisync.js*" } | 
    ForEach-Object {
        Write-Log "Terminating existing sync process (PID: $($_.Id))" -Level "WARNING"
        Stop-Process -Id $_.Id -Force
    }
    
    ##### Start the sync system
    $result = Start-SyncSystem
    
    if ($result) {
        Write-Log "Sync system recovery successful" -Level "SUCCESS"
        ##### Reset restart counter on successful restart
        $restartAttempts = 0
        return $true
    }
    else {
        if ($restartAttempts -ge $CONFIG.Monitoring.MaxRestartAttempts) {
            Write-Log "Maximum restart attempts reached, giving up for now" -Level "ERROR"
        }
        return $false
    }
}

function Initialize-Recovery {
    Write-Log "Auto-recovery mechanism started" -Level "INFO"
    Write-Log "Monitoring sync system: $($CONFIG.SyncSystem.MainDirectory)" -Level "INFO"
    
    ##### Initial check
    if (-not (Test-SyncSystemRunning)) {
        Write-Log "Sync system is not running on startup, attempting to start" -Level "WARNING"
        Restart-SyncSystem | Out-Null
    }
    else {
        Write-Log "Sync system is already running" -Level "SUCCESS"
    }
}

function Monitor-SyncSystem {
    while ($true) {
        ##### Check if sync system is running
        if (-not (Test-SyncSystemRunning)) {
            Write-Log "Sync system is not running, attempting recovery" -Level "WARNING"
            
            ##### Check if we can restart
            if ($restartAttempts -lt $CONFIG.Monitoring.MaxRestartAttempts) {
                ##### Check if enough time has passed since the last restart attempt
                $timeSinceLastRestart = [DateTime]::Now - $lastRestartTime
                if ($timeSinceLastRestart.TotalMinutes -ge 15) {
                    ##### Reset restart counter after 15 minutes of stability
                    $restartAttempts = 0
                }
                
                Restart-SyncSystem | Out-Null
            }
            else {
                Write-Log "Maximum restart attempts reached, waiting for 15 minutes before trying again" -Level "ERROR"
                Start-Sleep -Seconds 900  ##### 15 minutes
                $restartAttempts = 0  ##### Reset counter after waiting
            }
        }
        
        ##### Wait for the next check
        Start-Sleep -Seconds $CONFIG.Monitoring.CheckIntervalSeconds
    }
}

#-----------------------------------------------
##### Main process
#-----------------------------------------------
Initialize-Recovery

if ($CONFIG.RunAsService) {
    ##### Run continuous monitoring when in service mode
    Monitor-SyncSystem
}
else {
    ##### When run manually, just do a single recovery attempt
    if (-not (Test-SyncSystemRunning)) {
        Write-Log "Sync system is not running, attempting recovery" -Level "WARNING"
        $result = Restart-SyncSystem
        
        if ($result) {
            Write-Log "Recovery successful" -Level "SUCCESS"
            exit 0
        }
        else {
            Write-Log "Recovery failed" -Level "ERROR"
            exit 1
        }
    }
    else {
        Write-Log "Sync system is already running, no recovery needed" -Level "SUCCESS"
        exit 0
    }
} 
