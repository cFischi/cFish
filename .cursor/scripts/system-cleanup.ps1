# System Cleanup Script for UcF Launch Testing
# Purpose: Prepare system for installation testing by cleaning up resources

# Enable verbose output
$VerbosePreference = "Continue"
$ErrorActionPreference = "Stop"

# Create log file
$LogFile = "./.cursor/logs/system-cleanup-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"
New-Item -ItemType File -Path $LogFile -Force | Out-Null

function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    $TimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMessage = "$TimeStamp [$Level] $Message"
    Add-Content -Path $LogFile -Value $LogMessage
    Write-Host $LogMessage
}

function Write-MemoryStatus {
    try {
        Write-Log "Getting system memory status..." "INFO"
        $computerInfo = Get-ComputerInfo -ErrorAction Stop
        $totalMemoryGB = [math]::Round($computerInfo.OsTotalVisibleMemorySize / 1MB, 2)
        $freeMemoryGB = [math]::Round($computerInfo.OsFreePhysicalMemory / 1MB, 2)
        $usedMemoryGB = [math]::Round($totalMemoryGB - $freeMemoryGB, 2)
        $memoryUtilization = if ($totalMemoryGB -gt 0) { 
            [math]::Round(($usedMemoryGB / $totalMemoryGB) * 100, 2)
        } else {
            0
        }

        Write-Log "Memory Status:" "INFO"
        Write-Log "Total Memory: ${totalMemoryGB}GB" "INFO"
        Write-Log "Free Memory: ${freeMemoryGB}GB" "INFO"
        Write-Log "Used Memory: ${usedMemoryGB}GB" "INFO"
        Write-Log "Memory Utilization: ${memoryUtilization}%" "INFO"
    }
    catch {
        Write-Log "Error getting memory status: $_" "ERROR"
        throw
    }
}

function Clear-SystemCache {
    try {
        Write-Log "Clearing system cache..." "INFO"
        
        # Clear npm cache
        Write-Log "Clearing npm cache..." "INFO"
        npm cache clean --force
        
        # Clear temp files
        Write-Log "Clearing temp files..." "INFO"
        Remove-Item -Path $env:TEMP\* -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
        
        # Clear PowerShell module cache
        Write-Log "Clearing PowerShell module cache..." "INFO"
        Remove-Item -Path "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\*" -Recurse -Force -ErrorAction SilentlyContinue
        
        Write-Log "System cache cleared." "INFO"
    }
    catch {
        Write-Log "Error clearing system cache: $_" "ERROR"
        throw
    }
}

# Essential process protection
$protectedProcesses = @(
    "cursor",
    "cursor-main",
    "cursor-renderer",
    "cursor-gpu",
    "cursor-extension-host"
)

function Stop-NonEssentialProcesses {
    try {
        Write-Log "INFO" "Starting non-essential process termination"
        
        # Get high memory processes
        $highMemoryProcesses = Get-Process | Where-Object {
            $_.WorkingSet -gt 100MB -and 
            $_.ProcessName -notin $protectedProcesses -and
            $_.ProcessName -notlike "svchost*" -and
            $_.ProcessName -notlike "system*"
        } | Sort-Object WorkingSet -Descending

        foreach ($process in $highMemoryProcesses) {
            $memoryUsageMB = [math]::Round($process.WorkingSet / 1MB, 2)
            Write-Log "INFO" "Evaluating process: $($process.ProcessName) (PID: $($process.Id), Memory: $memoryUsageMB MB)"
            
            # Check if process is protected
            if ($protectedProcesses -contains $process.ProcessName) {
                Write-Log "INFO" "Skipping protected process: $($process.ProcessName)"
                continue
            }

            # Add memory threshold check
            if ($memoryUsageMB -gt 200) {
                try {
                    Write-Log "WARNING" "Attempting to stop high-memory process: $($process.ProcessName)"
                    $process.Kill()
                    Write-Log "INFO" "Successfully terminated process: $($process.ProcessName)"
                }
                catch {
                    Write-Log "ERROR" "Failed to terminate process $($process.ProcessName): $_"
                }
            }
        }
    }
    catch {
        Write-Log "ERROR" "Error in Stop-NonEssentialProcesses: $_"
    }
}

function Invoke-GarbageCollection {
    try {
        Write-Log "Running garbage collection..." "INFO"
        [System.GC]::Collect()
        [System.GC]::WaitForPendingFinalizers()
        Write-Log "Garbage collection completed." "INFO"
    }
    catch {
        Write-Log "Error during garbage collection: $_" "ERROR"
        throw
    }
}

function Test-SystemReadiness {
    try {
        $computerInfo = Get-ComputerInfo
        $freeMemoryGB = [math]::Round($computerInfo.OsFreePhysicalMemory / 1MB, 2)
        $processCount = (Get-Process).Count
        
        $ready = $true
        
        if ($freeMemoryGB -lt 2) {
            Write-Log "WARNING: Less than 2GB of free memory available ($freeMemoryGB GB)" "WARNING"
            $ready = $false
        }
        
        if ($processCount -gt 200) {
            Write-Log "WARNING: Process count too high ($processCount processes)" "WARNING"
            $ready = $false
        }
        
        return $ready
    }
    catch {
        Write-Log "Error testing system readiness: $_" "ERROR"
        throw
    }
}

# Main execution
try {
    Write-Log "Starting aggressive system cleanup..." "INFO"
    Write-Log "PowerShell Version: $($PSVersionTable.PSVersion)" "INFO"
    Write-Log "Execution Policy: $(Get-ExecutionPolicy)" "INFO"
    
    Write-MemoryStatus
    Clear-SystemCache
    Stop-NonEssentialProcesses
    Invoke-GarbageCollection

    Write-Log "`nFinal system status:" "INFO"
    Write-MemoryStatus

    $systemReady = Test-SystemReadiness
    if ($systemReady) {
        Write-Log "`nSystem is ready for testing." "INFO"
    }
    else {
        Write-Log "`nWARNING: System may not be in optimal state for testing." "WARNING"
        Write-Log "Please review warnings above and consider manual intervention." "WARNING"
    }
}
catch {
    Write-Log "Critical error during system cleanup: $_" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    exit 1
}
finally {
    Write-Log "Cleanup script execution completed." "INFO"
} 