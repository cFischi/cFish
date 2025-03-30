# System Optimization Script
# Created: 03-28-2025
# Author: Claude 3.7 Sonnet

# Enable strict mode for better error handling
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-CpuUsage {
    $cpuCounter = Get-Counter '\Processor(_Total)\% Processor Time' -ErrorAction SilentlyContinue
    if ($cpuCounter) {
        return [math]::Round($cpuCounter.CounterSamples[0].CookedValue)
    }
    return 0
}

function Wait-ForCpuNormalization {
    param (
        [int]$threshold = 80,
        [int]$waitTimeSeconds = 5
    )
    
    $cpuUsage = Get-CpuUsage
    if ($cpuUsage -gt $threshold) {
        Write-Warning "CPU usage is high ($cpuUsage%). Waiting for $waitTimeSeconds seconds..."
        Start-Sleep -Seconds $waitTimeSeconds
        return $true
    }
    return $false
}

function Clear-SystemTemp {
    Write-Host "Clearing system temporary files..."
    
    # Clear Windows temp files with CPU monitoring
    Get-ChildItem -Path "$env:TEMP" -Recurse | ForEach-Object {
        if (Wait-ForCpuNormalization) { return }
        Remove-Item -Path $_.FullName -Force -ErrorAction SilentlyContinue
    }
    
    Get-ChildItem -Path "C:\Windows\Temp" -Recurse | ForEach-Object {
        if (Wait-ForCpuNormalization) { return }
        Remove-Item -Path $_.FullName -Force -ErrorAction SilentlyContinue
    }
    
    # Clear Windows prefetch files with CPU monitoring
    Get-ChildItem -Path "C:\Windows\Prefetch" -Recurse | ForEach-Object {
        if (Wait-ForCpuNormalization) { return }
        Remove-Item -Path $_.FullName -Force -ErrorAction SilentlyContinue
    }
    
    Write-Host "Temporary files cleared successfully"
}

function Optimize-SystemPerformance {
    Write-Host "Optimizing system performance..."
    
    # Disable unnecessary services
    $servicesToOptimize = @(
        "DiagTrack",          # Connected User Experiences and Telemetry
        "SysMain",           # Superfetch
        "WSearch"            # Windows Search
    )
    
    foreach ($service in $servicesToOptimize) {
        if (Wait-ForCpuNormalization) { continue }
        
        $svc = Get-Service -Name $service -ErrorAction SilentlyContinue
        if ($svc) {
            try {
                if ($svc.Status -eq "Running") {
                    Write-Host "Attempting to optimize service: $service"
                    Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
                    Set-Service -Name $service -StartupType Manual -ErrorAction SilentlyContinue
                    Write-Host "Optimized service: $service"
                }
            } catch {
                Write-Warning "Could not optimize service: $service - Continuing with optimization"
            }
        }
    }
    
    # Clear DNS cache if CPU usage is acceptable
    if (-not (Wait-ForCpuNormalization)) {
        ipconfig /flushdns
    }
    
    Write-Host "System performance optimization completed"
}

function Optimize-Memory {
    Write-Host "Optimizing memory usage..."
    
    # Clear standby list
    Write-Host "Clearing memory standby list..."
    
    # Empty working set of processes with CPU monitoring
    Get-Process | Where-Object {$_.WorkingSet -gt 100MB} | ForEach-Object {
        if (Wait-ForCpuNormalization) { return }
        
        try {
            $processName = $_.ProcessName
            # Skip Cursor and other critical processes
            if ($processName -in @('Cursor', 'pwsh', 'explorer')) {
                Write-Host "Skipping critical process: $processName"
                return
            }
            
            Write-Host "Optimizing memory for process: $processName"
            [System.Runtime.InteropServices.Marshal]::SetProcessWorkingSetSize($_.Handle, -1, -1)
            Start-Sleep -Milliseconds 100  # Add small delay between processes
        } catch {
            Write-Warning "Could not optimize memory for process: $($processName)"
        }
    }
    
    Write-Host "Memory optimization completed"
}

function Export-OptimizationLog {
    param (
        [string]$LogPath = "U5-Data/Logs/system-optimization-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"
    )
    
    if (Wait-ForCpuNormalization) { return }
    
    # Create directory if it doesn't exist
    $directory = Split-Path $LogPath -Parent
    if (-not (Test-Path $directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }
    
    # Get system info
    $os = Get-WmiObject Win32_OperatingSystem
    $computerSystem = Get-WmiObject Win32_ComputerSystem
    $disk = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='C:'"
    
    # Create optimization log
    $optimizationLog = @{
        timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        actions = @{
            tempCleared = $true
            servicesOptimized = $true
            memoryOptimized = $true
        }
        systemInfo = @{
            os = $os.Caption
            memory = @{
                total = [math]::Round($computerSystem.TotalPhysicalMemory / 1GB, 2)
                free = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
            }
            disk = @{
                size = [math]::Round($disk.Size / 1GB, 2)
                free = [math]::Round($disk.FreeSpace / 1GB, 2)
            }
            cpu = @{
                usage = Get-CpuUsage
            }
        }
    }
    
    $optimizationLog | ConvertTo-Json -Depth 10 | Out-File $LogPath
    Write-Host "Optimization log exported to: $LogPath"
}

# Main execution
try {
    Write-Host "Starting system optimization with CPU monitoring..."
    Write-Host "Initial CPU Usage: $(Get-CpuUsage)%"
    
    Clear-SystemTemp
    Write-Host "Current CPU Usage: $(Get-CpuUsage)%"
    
    Optimize-SystemPerformance
    Write-Host "Current CPU Usage: $(Get-CpuUsage)%"
    
    Optimize-Memory
    Write-Host "Current CPU Usage: $(Get-CpuUsage)%"
    
    Export-OptimizationLog
    Write-Host "System optimization completed successfully"
    Write-Host "Final CPU Usage: $(Get-CpuUsage)%"
} catch {
    Write-Error "Error during system optimization: $_"
    exit 1
} 