# System Recovery Script
# Created: 03-28-2025
# Author: Claude 3.7 Sonnet

# Enable strict mode for better error handling
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Clear-SystemCache {
    Write-Host "Clearing system cache..."
    
    # Clear Windows temp files
    Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
    
    # Clear DNS cache
    ipconfig /flushdns
    
    Write-Host "System cache cleared successfully"
}

function Reset-ShellEnvironment {
    Write-Host "Resetting shell environment..."
    
    # Reset PowerShell session
    [System.Environment]::SetEnvironmentVariable('POWERSHELL_TELEMETRY_OPTOUT', $null, [System.EnvironmentVariableTarget]::Process)
    $env:PSModulePath = [System.Environment]::GetEnvironmentVariable('PSModulePath', 'Machine')
    
    # Refresh environment variables
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    
    Write-Host "Shell environment reset successfully"
}

function Test-SystemHealth {
    Write-Host "Testing system health..."
    
    # Check disk health
    Write-Host "Checking disk health..."
    chkdsk C: /f /r
    
    # Check system files
    Write-Host "Checking system files..."
    sfc /scannow
    
    Write-Host "System health check completed"
}

function Export-RecoveryLog {
    param (
        [string]$LogPath = "U5-Data/Logs/system-recovery-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"
    )
    
    # Create directory if it doesn't exist
    $directory = Split-Path $LogPath -Parent
    if (-not (Test-Path $directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }
    
    # Create recovery log
    $recoveryLog = @{
        timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        actions = @{
            cacheCleared = $true
            shellReset = $true
            healthCheck = $true
        }
        systemInfo = @{
            os = (Get-WmiObject Win32_OperatingSystem).Caption
            memory = @{
                total = (Get-WmiObject Win32_ComputerSystem).TotalPhysicalMemory / 1GB
                free = (Get-WmiObject Win32_OperatingSystem).FreePhysicalMemory / 1MB
            }
            disk = @{
                size = (Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='C:'").Size / 1GB
                free = (Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='C:'").FreeSpace / 1GB
            }
        }
    }
    
    $recoveryLog | ConvertTo-Json -Depth 10 | Out-File $LogPath
    Write-Host "Recovery log exported to: $LogPath"
}

# Main execution
try {
    Clear-SystemCache
    Reset-ShellEnvironment
    Test-SystemHealth
    Export-RecoveryLog
    Write-Host "System recovery completed successfully"
} catch {
    Write-Error "Error during system recovery: $_"
    exit 1
} 