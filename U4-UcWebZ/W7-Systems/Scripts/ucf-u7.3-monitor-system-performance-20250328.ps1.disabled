# System Performance Monitoring Script
# Created: 03-28-2025
# Author: Claude 3.7 Sonnet

# Enable strict mode for better error handling
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-SystemMetrics {
    param (
        [int]$SampleCount = 5,
        [int]$SampleInterval = 2
    )
    
    $metrics = @{
        CPU = @()
        Memory = @()
        DiskSpace = @()
        ProcessCount = @()
    }
    
    Write-Host "Collecting system metrics..."
    for ($i = 1; $i -le $SampleCount; $i++) {
        # CPU Usage
        $cpuUsage = (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue
        $metrics.CPU += $cpuUsage
        
        # Memory Usage
        $os = Get-WmiObject Win32_OperatingSystem
        $memoryUsage = (($os.TotalVisibleMemorySize - $os.FreePhysicalMemory) / $os.TotalVisibleMemorySize) * 100
        $metrics.Memory += $memoryUsage
        
        # Disk Space
        $disk = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='C:'"
        $diskSpace = ($disk.Size - $disk.FreeSpace) / $disk.Size * 100
        $metrics.DiskSpace += $diskSpace
        
        # Process Count
        $processCount = (Get-Process).Count
        $metrics.ProcessCount += $processCount
        
        Write-Progress -Activity "Collecting Metrics" -Status "Sample $i of $SampleCount" -PercentComplete (($i / $SampleCount) * 100)
        Start-Sleep -Seconds $SampleInterval
    }
    
    Write-Host "`nSystem Metrics Summary:"
    Write-Host "===================="
    Write-Host "CPU Usage (Average): $([math]::Round(($metrics.CPU | Measure-Object -Average).Average, 2))%"
    Write-Host "Memory Usage (Average): $([math]::Round(($metrics.Memory | Measure-Object -Average).Average, 2))%"
    Write-Host "Disk Space Used (C:): $([math]::Round(($metrics.DiskSpace | Measure-Object -Average).Average, 2))%"
    Write-Host "Process Count (Average): $([math]::Round(($metrics.ProcessCount | Measure-Object -Average).Average))"
    
    return $metrics
}

function Export-MetricsToJson {
    param (
        [Parameter(Mandatory=$true)]
        [hashtable]$Metrics,
        [string]$OutputPath = "U5-Data/Monitoring/system-metrics-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
    )
    
    # Create directory if it doesn't exist
    $directory = Split-Path $OutputPath -Parent
    if (-not (Test-Path $directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }
    
    $metricsObject = @{
        timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        metrics = $Metrics
        summary = @{
            cpu = @{
                average = [math]::Round(($Metrics.CPU | Measure-Object -Average).Average, 2)
                max = [math]::Round(($Metrics.CPU | Measure-Object -Maximum).Maximum, 2)
                min = [math]::Round(($Metrics.CPU | Measure-Object -Minimum).Minimum, 2)
            }
            memory = @{
                average = [math]::Round(($Metrics.Memory | Measure-Object -Average).Average, 2)
                max = [math]::Round(($Metrics.Memory | Measure-Object -Maximum).Maximum, 2)
                min = [math]::Round(($Metrics.Memory | Measure-Object -Minimum).Minimum, 2)
            }
            diskSpace = @{
                average = [math]::Round(($Metrics.DiskSpace | Measure-Object -Average).Average, 2)
            }
            processCount = @{
                average = [math]::Round(($Metrics.ProcessCount | Measure-Object -Average).Average)
            }
        }
    }
    
    $metricsObject | ConvertTo-Json -Depth 10 | Out-File $OutputPath
    Write-Host "Metrics exported to: $OutputPath"
}

# Main execution
try {
    $metrics = Get-SystemMetrics -SampleCount 5 -SampleInterval 2
    Export-MetricsToJson -Metrics $metrics
} catch {
    Write-Error "Error collecting system metrics: $_"
    exit 1
} 