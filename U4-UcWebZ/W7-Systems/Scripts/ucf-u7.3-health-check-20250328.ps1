# System Health Check Script
# Created: 03-28-2025
# Author: Claude 3.7 Sonnet

# Enable strict mode for better error handling
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Test-SystemResources {
    Write-Host "Testing system resources..."
    
    # Check CPU usage
    $cpuUsage = (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue
    
    # Check memory usage
    $os = Get-WmiObject Win32_OperatingSystem
    $memoryUsage = (($os.TotalVisibleMemorySize - $os.FreePhysicalMemory) / $os.TotalVisibleMemorySize) * 100
    
    # Check disk space
    $disk = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='C:'"
    $diskUsage = ($disk.Size - $disk.FreeSpace) / $disk.Size * 100
    
    $resourceStatus = @{
        cpu = @{
            usage = [math]::Round($cpuUsage, 2)
            status = if ($cpuUsage -lt 80) { "Healthy" } else { "Warning" }
        }
        memory = @{
            usage = [math]::Round($memoryUsage, 2)
            status = if ($memoryUsage -lt 90) { "Healthy" } else { "Warning" }
        }
        disk = @{
            usage = [math]::Round($diskUsage, 2)
            status = if ($diskUsage -lt 90) { "Healthy" } else { "Warning" }
        }
    }
    
    return $resourceStatus
}

function Test-ServiceHealth {
    Write-Host "Testing service health..."
    
    $criticalServices = @(
        "wuauserv",      # Windows Update
        "WinDefend",     # Windows Defender
        "EventLog",      # Event Log
        "RpcSs",        # Remote Procedure Call
        "LanmanServer"   # Server
    )
    
    $serviceStatus = @{}
    foreach ($service in $criticalServices) {
        $svc = Get-Service -Name $service -ErrorAction SilentlyContinue
        if ($svc) {
            $serviceStatus[$service] = @{
                status = $svc.Status
                startType = $svc.StartType
                health = if ($svc.Status -eq "Running") { "Healthy" } else { "Warning" }
            }
        }
    }
    
    return $serviceStatus
}

function Test-NetworkHealth {
    Write-Host "Testing network health..."
    
    $networkStatus = @{
        dns = $false
        internet = $false
        latency = 0
    }
    
    # Test DNS resolution
    try {
        Resolve-DnsName "www.google.com" -ErrorAction Stop | Out-Null
        $networkStatus.dns = $true
    } catch {
        Write-Warning "DNS resolution failed"
    }
    
    # Test internet connectivity
    try {
        $ping = Test-Connection "8.8.8.8" -Count 1 -ErrorAction Stop
        $networkStatus.internet = $true
        $networkStatus.latency = $ping.ResponseTime
    } catch {
        Write-Warning "Internet connectivity test failed"
    }
    
    return $networkStatus
}

function Export-HealthCheckLog {
    param (
        [Parameter(Mandatory=$true)]
        [hashtable]$ResourceStatus,
        [Parameter(Mandatory=$true)]
        [hashtable]$ServiceStatus,
        [Parameter(Mandatory=$true)]
        [hashtable]$NetworkStatus,
        [string]$LogPath = "U5-Data/Logs/health-check-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"
    )
    
    # Create directory if it doesn't exist
    $directory = Split-Path $LogPath -Parent
    if (-not (Test-Path $directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }
    
    # Create health check log
    $healthLog = @{
        timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        resources = $ResourceStatus
        services = $ServiceStatus
        network = $NetworkStatus
        summary = @{
            overallHealth = if (
                $ResourceStatus.cpu.status -eq "Healthy" -and
                $ResourceStatus.memory.status -eq "Healthy" -and
                $ResourceStatus.disk.status -eq "Healthy" -and
                $NetworkStatus.internet
            ) { "Healthy" } else { "Warning" }
        }
    }
    
    $healthLog | ConvertTo-Json -Depth 10 | Out-File $LogPath
    Write-Host "Health check log exported to: $LogPath"
    
    return $healthLog.summary.overallHealth
}

# Main execution
try {
    $resourceStatus = Test-SystemResources
    $serviceStatus = Test-ServiceHealth
    $networkStatus = Test-NetworkHealth
    
    $overallHealth = Export-HealthCheckLog -ResourceStatus $resourceStatus -ServiceStatus $serviceStatus -NetworkStatus $networkStatus
    
    Write-Host "`nHealth Check Summary:"
    Write-Host "===================="
    Write-Host "Overall Health: $overallHealth"
    Write-Host "CPU Usage: $($resourceStatus.cpu.usage)% ($($resourceStatus.cpu.status))"
    Write-Host "Memory Usage: $($resourceStatus.memory.usage)% ($($resourceStatus.memory.status))"
    Write-Host "Disk Usage: $($resourceStatus.disk.usage)% ($($resourceStatus.disk.status))"
    Write-Host "Network Status: $(if ($networkStatus.internet) { 'Connected' } else { 'Disconnected' })"
    
    if ($overallHealth -eq "Warning") {
        Write-Warning "System requires attention - check health check log for details"
        exit 1
    }
} catch {
    Write-Error "Error during health check: $_"
    exit 1
} 