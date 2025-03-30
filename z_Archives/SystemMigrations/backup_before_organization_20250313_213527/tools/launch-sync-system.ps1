# launch-sync-system.ps1
# Simple launcher for tYDiSync synchronization system
# Version: 0.5.5
# Date: 2025-03-14

#-----------------------------------------------
# Configuration
#-----------------------------------------------
$CONFIG = @{
    SyncSystem = @{
        MainDirectory = "C:\Users\Chris\cFish.io\cFish.io\U5-Data\Synchronization\tydisync"
        StartScript = "C:\Users\Chris\cFish.io\cFish.io\U5-Data\Synchronization\tydisync\start-tydisync.bat"
    }
    LogFile = "C:\Users\Chris\cFish.io\tools\logs\sync-launcher-$(Get-Date -Format 'yyyyMMdd').log"
}

#-----------------------------------------------
##### Initialize
#-----------------------------------------------
$ErrorActionPreference = "Stop"
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

function Start-SyncSystem {
    try {
        Write-Log "Starting sync system..." -Level "INFO"
        
        ##### Check if start script exists
        if (-not (Test-Path $CONFIG.SyncSystem.StartScript)) {
            Write-Log "Sync system start script not found at: $($CONFIG.SyncSystem.StartScript)" -Level "ERROR"
            
            ##### Check if the alternative script exists
            $alternativeScript = Join-Path -Path $CONFIG.SyncSystem.MainDirectory -ChildPath "start-optimized-sync.bat"
            if (Test-Path $alternativeScript) {
                Write-Log "Found alternative start script: $alternativeScript" -Level "INFO"
                Write-Log "Using alternative script instead" -Level "INFO"
                $CONFIG.SyncSystem.StartScript = $alternativeScript
            }
            else {
                Write-Log "No alternative script found" -Level "ERROR"
                return $false
            }
        }
        
        ##### Start the sync system process
        Write-Log "Launching: $($CONFIG.SyncSystem.StartScript)" -Level "INFO"
        $startInfo = New-Object System.Diagnostics.ProcessStartInfo
        $startInfo.FileName = $CONFIG.SyncSystem.StartScript
        $startInfo.WorkingDirectory = Split-Path -Parent $CONFIG.SyncSystem.StartScript
        $startInfo.UseShellExecute = $true
        $startInfo.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Normal
        
        $process = [System.Diagnostics.Process]::Start($startInfo)
        Write-Log "Started process with ID: $($process.Id)" -Level "SUCCESS"
        return $true
    }
    catch {
        Write-Log "Failed to start sync system: $_" -Level "ERROR"
        return $false
    }
}

#-----------------------------------------------
##### Main process
#-----------------------------------------------
Write-Log "Sync system launcher started" -Level "INFO"
$result = Start-SyncSystem

if ($result) {
    Write-Log "Sync system launched successfully" -Level "SUCCESS"
    exit 0
}
else {
    Write-Log "Failed to launch sync system" -Level "ERROR"
    exit 1
} 
