# Master System Maintenance Script
# Created: 03-28-2025
# Author: Claude 3.7 Sonnet

# Enable strict mode for better error handling
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-Header {
    param (
        [string]$Title
    )
    
    Write-Host "`n========== $Title ==========" -ForegroundColor Cyan
}

function Export-MaintenanceLog {
    param (
        [string]$LogPath = "U5-Data/Logs/system-maintenance-$(Get-Date -Format 'yyyyMMdd-HHmmss').log",
        [hashtable]$Results
    )
    
    # Create directory if it doesn't exist
    $directory = Split-Path $LogPath -Parent
    if (-not (Test-Path $directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }
    
    # Create maintenance log
    $maintenanceLog = @{
        timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        results = $Results
        summary = @{
            overallStatus = if (
                $Results.monitoring.status -eq "Success" -and
                $Results.optimization.status -eq "Success" -and
                $Results.recovery.status -eq "Success" -and
                $Results.healthCheck.status -eq "Success"
            ) { "Success" } else { "Warning" }
        }
    }
    
    $maintenanceLog | ConvertTo-Json -Depth 10 | Out-File $LogPath
    Write-Host "Maintenance log exported to: $LogPath"
    
    return $maintenanceLog.summary.overallStatus
}

# Main execution
try {
    $results = @{
        monitoring = @{
            status = "Pending"
            error = $null
        }
        optimization = @{
            status = "Pending"
            error = $null
        }
        recovery = @{
            status = "Pending"
            error = $null
        }
        healthCheck = @{
            status = "Pending"
            error = $null
        }
    }
    
    # Run system performance monitoring
    Write-Header "System Performance Monitoring"
    try {
        & "$PSScriptRoot\ucf-u7.3-monitor-system-performance-20250328.ps1"
        $results.monitoring.status = "Success"
    } catch {
        $results.monitoring.status = "Failed"
        $results.monitoring.error = $_.Exception.Message
        Write-Warning "Performance monitoring failed: $_"
    }
    
    # Run system optimization
    Write-Header "System Optimization"
    try {
        & "$PSScriptRoot\ucf-u7.3-optimize-system-20250328.ps1"
        $results.optimization.status = "Success"
    } catch {
        $results.optimization.status = "Failed"
        $results.optimization.error = $_.Exception.Message
        Write-Warning "System optimization failed: $_"
    }
    
    # Run system recovery
    Write-Header "System Recovery"
    try {
        & "$PSScriptRoot\ucf-u7.3-system-recovery-20250328.ps1"
        $results.recovery.status = "Success"
    } catch {
        $results.recovery.status = "Failed"
        $results.recovery.error = $_.Exception.Message
        Write-Warning "System recovery failed: $_"
    }
    
    # Run health check
    Write-Header "System Health Check"
    try {
        & "$PSScriptRoot\ucf-u7.3-health-check-20250328.ps1"
        $results.healthCheck.status = "Success"
    } catch {
        $results.healthCheck.status = "Failed"
        $results.healthCheck.error = $_.Exception.Message
        Write-Warning "Health check failed: $_"
    }
    
    # Export maintenance log
    Write-Header "Maintenance Summary"
    $overallStatus = Export-MaintenanceLog -Results $results
    
    if ($overallStatus -eq "Warning") {
        Write-Warning "System maintenance completed with warnings - check maintenance log for details"
        exit 1
    } else {
        Write-Host "System maintenance completed successfully" -ForegroundColor Green
    }
} catch {
    Write-Error "Error during system maintenance: $_"
    exit 1
} 