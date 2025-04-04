# Cursor Instance Management Script
# Version: 0.1.2
# Created: 05-07-2025

# Enable strict mode and error handling
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Define functions
function Get-CursorInstances {
    try {
        $processes = Get-Process | Where-Object { $_.ProcessName -like "*cursor*" }
        return $processes | Select-Object ProcessName, Id, @{
            Name = "MemoryMB";
            Expression = { [math]::Round($_.WorkingSet / 1MB, 2) }
        }
    }
    catch {
        Write-Error "Failed to get Cursor instances: $_"
        return $null
    }
}

function Get-SystemMemoryStatus {
    try {
        $os = Get-CimInstance -ClassName Win32_OperatingSystem
        $total = [math]::Round($os.TotalVisibleMemorySize / 1KB, 2)
        $free = [math]::Round($os.FreePhysicalMemory / 1KB, 2)
        $used = $total - $free
        $percent = [math]::Round(($used / $total) * 100, 2)

        return @{
            TotalGB = $total
            UsedGB = $used
            FreeGB = $free
            UsagePercent = $percent
        }
    }
    catch {
        Write-Error "Failed to get system memory status: $_"
        return $null
    }
}

function Stop-CursorInstance {
    param(
        [Parameter(Mandatory=$true)]
        [int]$ProcessId
    )
    
    try {
        $process = Get-Process -Id $ProcessId -ErrorAction Stop
        if ($process.ProcessName -like "*cursor*") {
            Stop-Process -Id $ProcessId -Force
            Write-Output "Successfully stopped Cursor instance (PID: $ProcessId)"
        }
        else {
            Write-Error "Process ID $ProcessId is not a Cursor instance"
        }
    }
    catch {
        Write-Error "Failed to stop Cursor instance: $_"
    }
}

function Get-CursorMemoryUsage {
    try {
        $instances = Get-CursorInstances
        if ($null -eq $instances) {
            Write-Output "No Cursor instances found."
            return
        }
        
        $totalMemory = ($instances | Measure-Object -Property MemoryMB -Sum).Sum
        
        Write-Output "=== Cursor Memory Usage Report ==="
        Write-Output "Number of instances: $($instances.Count)"
        Write-Output "Total memory usage: $([math]::Round($totalMemory, 2)) MB"
        Write-Output "`nInstance details:"
        $instances | Format-Table -AutoSize
        
        $sysMemory = Get-SystemMemoryStatus
        if ($null -ne $sysMemory) {
            Write-Output "`nSystem Memory Status:"
            Write-Output "Total Memory: $($sysMemory.TotalGB) GB"
            Write-Output "Used Memory: $($sysMemory.UsedGB) GB"
            Write-Output "Free Memory: $($sysMemory.FreeGB) GB"
            Write-Output "Memory Usage: $($sysMemory.UsagePercent)%"
        }
    }
    catch {
        Write-Error "Failed to get Cursor memory usage: $_"
    }
}

# If the script is being run directly (not imported as a module)
if ($MyInvocation.InvocationName -ne '.') {
    Write-Output "Running memory usage check..."
    Get-CursorMemoryUsage
} 