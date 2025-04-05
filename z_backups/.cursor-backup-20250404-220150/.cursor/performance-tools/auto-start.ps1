# Auto-start script for monitoring system
$ErrorActionPreference = "Stop"
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$logFile = Join-Path $scriptPath "..\logs\monitoring.log"
$alertsPath = Join-Path $scriptPath "..\logs\alerts"

# Create logs and alerts directories if they don't exist
if (!(Test-Path (Split-Path $logFile))) {
    New-Item -ItemType Directory -Path (Split-Path $logFile) -Force
}
if (!(Test-Path $alertsPath)) {
    New-Item -ItemType Directory -Path $alertsPath -Force
}

function Write-Log {
    param($Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $Message" | Out-File -FilePath $logFile -Append
    Write-Host $Message
}

function Send-AlertNotification {
    param(
        [string]$level,
        [string]$message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd-HHmmss"
    $alertFile = Join-Path $alertsPath "$level-$timestamp.alert"
    @{
        timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        level = $level
        message = $message
    } | ConvertTo-Json | Out-File $alertFile
    Write-Log "ALERT [$level]: $message"
}

function Handle-Crash {
    param($errorDetails)
    
    Write-Log "ALERT: System crash detected - $errorDetails"
    
    # Attempt recovery
    try {
        Write-Log "Attempting system recovery..."
        Stop-MonitoringSystem
        Start-Sleep -Seconds 5
        Start-MonitoringSystem
        Write-Log "Recovery successful"
    } catch {
        Write-Log "Recovery failed: $_"
        Send-AlertNotification -level "CRITICAL" -message "Monitoring system recovery failed"
    }
}

function Stop-MonitoringSystem {
    if (Test-Path "monitoring.pid") {
        $processId = Get-Content "monitoring.pid"
        $process = Get-Process -Id $processId -ErrorAction SilentlyContinue
        if ($process) {
            Stop-Process -Id $processId -Force
            Remove-Item "monitoring.pid" -Force
            Write-Log "Monitoring system stopped"
        }
    }
}

function Start-MonitoringSystem {
    try {
        # Change to the script directory
        Set-Location $scriptPath
        
        # Start the monitoring system
        $process = Start-Process -FilePath "node" -ArgumentList "start-monitoring.js" -NoNewWindow -PassThru
        
        Write-Log "Monitoring system started with PID: $($process.Id)"
        
        # Create a marker file to indicate the system is running
        $process.Id | Out-File -FilePath "monitoring.pid"
        
        return $true
    } catch {
        Write-Log "Error starting monitoring system: $_"
        Send-AlertNotification -level "ERROR" -message "Failed to start monitoring system: $_"
        return $false
    }
}

try {
    Write-Log "Starting monitoring system..."
    
    if (!(Start-MonitoringSystem)) {
        Write-Log "Initial start failed, attempting recovery..."
        Start-Sleep -Seconds 10
        if (!(Start-MonitoringSystem)) {
            Send-AlertNotification -level "CRITICAL" -message "Multiple start attempts failed"
            exit 1
        }
    }
    
} catch {
    Handle-Crash $_
    exit 1
} 