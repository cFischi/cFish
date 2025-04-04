# Process Priority Queue System
# Prioritizes processes based on resource usage with emergency termination protocols

# Parameter parsing
param(
    [switch]$MonitorOnly = $false,
    [switch]$ForceCooldownReset = $false
)

$VerbosePreference = "Continue"
$ErrorActionPreference = "Stop"

# Import the process manager module
$ProcessManagerPath = Join-Path $PSScriptRoot "process-manager.ps1"
. $ProcessManagerPath

# Create log directory if it doesn't exist
$LogDir = "./.cursor/logs"
New-Item -ItemType Directory -Path $LogDir -Force | Out-Null

$LogFile = "$LogDir/process-priority-queue-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"

# Configuration
$MemoryThresholdMB = 2048     # 2GB system available memory threshold for emergency mode
$CpuThresholdPercent = 85     # CPU usage threshold for emergency mode
$MaxProcessCount = 200        # Maximum allowed processes before action is taken
$EmergencyMemoryThresholdMB = 1024  # 1GB emergency threshold
$EmergencyCooldownMinutes = 10      # Cooldown period after emergency action
$ProtectedProcesses = @(
    "explorer", "svchost", "lsass", "csrss", "wininit", 
    "services", "smss", "pwsh", "powershell", "cmd", 
    "System", "Idle", "Registry", "fontdrvhost"
)

# Priority levels
$PriorityLevels = @{
    "Critical" = 1
    "High" = 2
    "Medium" = 3
    "Low" = 4
    "Background" = 5
}

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

function Get-SystemState {
    try {
        Write-Log "Getting current system state" "INFO"
        
        # Get memory info
        $computerInfo = Get-ComputerInfo
        $totalMemoryMB = [math]::Round($computerInfo.OsTotalVisibleMemorySize / 1KB, 0)
        $freeMemoryMB = [math]::Round($computerInfo.OsFreePhysicalMemory / 1KB, 0)
        $usedMemoryMB = $totalMemoryMB - $freeMemoryMB
        $memoryPercentUsed = [math]::Round(($usedMemoryMB / $totalMemoryMB) * 100, 2)
        
        # Get CPU metrics
        try {
            $cpuLoad = (Get-CimInstance -ClassName Win32_Processor | Measure-Object -Property LoadPercentage -Average).Average
        } catch {
            Write-Log "Unable to get CPU load: $_" "WARNING"
            $cpuLoad = 0
        }
        
        # Get process count
        $processCount = (Get-Process).Count
        
        # Get cursor process count
        $cursorProcesses = @(Get-Process | Where-Object { $_.ProcessName -like "*cursor*" })
        $cursorProcessCount = $cursorProcesses.Count
        
        # Get node process count
        $nodeProcesses = @(Get-Process | Where-Object { $_.ProcessName -eq "node" })
        $nodeProcessCount = $nodeProcesses.Count
        
        # Create system state object
        $systemState = @{
            Timestamp = Get-Date
            TotalMemoryMB = $totalMemoryMB
            FreeMemoryMB = $freeMemoryMB
            UsedMemoryMB = $usedMemoryMB
            MemoryPercentUsed = $memoryPercentUsed
            CpuPercentUsed = $cpuLoad
            TotalProcessCount = $processCount
            CursorProcessCount = $cursorProcessCount
            NodeProcessCount = $nodeProcessCount
            EmergencyMode = $false
            CriticalEmergency = $false
        }
        
        # Determine if system is in emergency state
        if (($freeMemoryMB -lt $MemoryThresholdMB) -or 
            ($cpuLoad -gt $CpuThresholdPercent) -or 
            ($processCount -gt $MaxProcessCount)) {
            $systemState.EmergencyMode = $true
            
            if ($freeMemoryMB -lt $EmergencyMemoryThresholdMB) {
                $systemState.CriticalEmergency = $true
            }
        }
        
        Write-Log "System State: Total Memory: $totalMemoryMB MB, Free: $freeMemoryMB MB, CPU: $cpuLoad%, Processes: $processCount" "INFO"
        if ($systemState.EmergencyMode) {
            Write-Log "EMERGENCY MODE DETECTED" "WARNING"
            if ($systemState.CriticalEmergency) {
                Write-Log "CRITICAL EMERGENCY - Memory extremely low: $freeMemoryMB MB" "ERROR"
            }
        }
        
        return $systemState
    }
    catch {
        Write-Log "Error getting system state: $_" "ERROR"
        throw $_
    }
}

function Get-ProcessPriorities {
    param(
        [hashtable]$SystemState
    )
    
    try {
        Write-Log "Calculating process priorities" "INFO"
        
        # Get all processes
        $allProcesses = Get-Process
        
        # Calculate prioritized list
        $prioritizedProcesses = @()
        
        foreach ($process in $allProcesses) {
            try {
                # Skip protected processes
                $isProtected = $ProtectedProcesses -contains $process.ProcessName
                
                # Calculate memory usage
                $memoryUsageMB = [math]::Round($process.WorkingSet64 / 1MB, 2)
                
                # Calculate memory percentage of total
                $memoryPercentage = [math]::Round(($memoryUsageMB / $SystemState.TotalMemoryMB) * 100, 2)
                
                # Get CPU time as percentage
                $cpuTimePercentage = 0
                try {
                    # This is an approximation since we don't have process-specific CPU percentage directly
                    $cpuTimePercentage = [math]::Round(($process.TotalProcessorTime.TotalMilliseconds / $process.StartTime.Elapsed.TotalMilliseconds) * 100, 2)
                    # Cap at 100%
                    if ($cpuTimePercentage -gt 100) { $cpuTimePercentage = 100 }
                } catch {
                    $cpuTimePercentage = 0
                }
                
                # Determine process type
                $processType = "user"
                if ($process.ProcessName -like "svc*" -or 
                    $process.ProcessName -like "system*" -or 
                    $ProtectedProcesses -contains $process.ProcessName) {
                    $processType = "system"
                } elseif ($process.ProcessName -like "cursor*") {
                    $processType = "cursor"
                } elseif ($process.ProcessName -eq "node") {
                    $processType = "node"
                }
                
                # Calculate priority score (lower is higher priority for termination)
                # Protected processes get highest score (least likely to terminate)
                $priorityScore = 1000
                
                if (-not $isProtected) {
                    # Base score starts at 500
                    $priorityScore = 500
                    
                    # Adjust by memory usage - higher memory use = lower score (higher priority to terminate)
                    $priorityScore -= ($memoryPercentage * 5)
                    
                    # Adjust by CPU usage - higher CPU use = lower score
                    $priorityScore -= ($cpuTimePercentage * 2)
                    
                    # Adjust by process type
                    if ($processType -eq "system") {
                        $priorityScore += 300  # Less likely to terminate
                    } elseif ($processType -eq "cursor") {
                        $priorityScore -= 50   # More likely to terminate in emergency
                    } elseif ($processType -eq "node") {
                        $priorityScore -= 100  # Most likely to terminate in emergency
                    }
                    
                    # Avoid negative scores
                    if ($priorityScore -lt 0) { $priorityScore = 0 }
                }
                
                # Determine priority level
                $priorityLevel = "Medium"
                if ($priorityScore -ge 800) {
                    $priorityLevel = "Critical"
                } elseif ($priorityScore -ge 600) {
                    $priorityLevel = "High"
                } elseif ($priorityScore -ge 400) {
                    $priorityLevel = "Medium"
                } elseif ($priorityScore -ge 200) {
                    $priorityLevel = "Low"
                } else {
                    $priorityLevel = "Background"
                }
                
                # Create process info object
                $processInfo = @{
                    Id = $process.Id
                    Name = $process.ProcessName
                    Type = $processType
                    IsProtected = $isProtected
                    MemoryUsageMB = $memoryUsageMB
                    MemoryPercentage = $memoryPercentage
                    CpuPercentage = $cpuTimePercentage
                    PriorityScore = $priorityScore
                    PriorityLevel = $priorityLevel
                    PriorityValue = $PriorityLevels[$priorityLevel]
                    StartTime = $process.StartTime
                    Threads = $process.Threads.Count
                    Handles = $process.HandleCount
                }
                
                $prioritizedProcesses += $processInfo
            } catch {
                Write-Log "Warning: Error calculating priority for process $($process.ProcessName) (PID: $($process.Id)): $_" "WARNING"
            }
        }
        
        # Sort processes by priority score (ascending = highest termination priority first)
        $sortedProcesses = $prioritizedProcesses | Sort-Object -Property PriorityScore
        
        Write-Log "Calculated priorities for $($sortedProcesses.Count) processes" "INFO"
        
        return $sortedProcesses
    }
    catch {
        Write-Log "Error calculating process priorities: $_" "ERROR"
        throw $_
    }
}

function Invoke-ProcessTermination {
    param(
        [hashtable]$Process,
        [switch]$Force = $false,
        [switch]$EmergencyMode = $false
    )
    
    try {
        # Double-check that it's not a protected process
        if ($Process.IsProtected -and -not $Force) {
            Write-Log "Cannot terminate protected process: $($Process.Name) (PID: $($Process.Id))" "WARNING"
            return $false
        }
        
        # Verify process still exists
        $liveProcess = Get-Process -Id $Process.Id -ErrorAction SilentlyContinue
        if (-not $liveProcess) {
            Write-Log "Process no longer exists: $($Process.Name) (PID: $($Process.Id))" "WARNING"
            return $true  # Consider it a success since it's already gone
        }
        
        # Log the termination
        $logLevel = "WARNING"
        if ($EmergencyMode) { $logLevel = "ERROR" }
        
        Write-Log "Terminating process: $($Process.Name) (PID: $($Process.Id)), Memory: $($Process.MemoryUsageMB) MB, CPU: $($Process.CpuPercentage)%, Priority: $($Process.PriorityLevel)" $logLevel
        
        # Perform the termination
        Stop-Process -Id $Process.Id -Force
        
        # Verify process is gone
        Start-Sleep -Milliseconds 500
        $checkProcess = Get-Process -Id $Process.Id -ErrorAction SilentlyContinue
        
        if ($checkProcess) {
            Write-Log "Failed to terminate process: $($Process.Name) (PID: $($Process.Id))" "ERROR"
            return $false
        } else {
            Write-Log "Successfully terminated process: $($Process.Name) (PID: $($Process.Id))" "INFO"
            return $true
        }
    }
    catch {
        Write-Log "Error terminating process: $_" "ERROR"
        return $false
    }
}

function Start-EmergencyProtocol {
    param(
        [hashtable]$SystemState,
        [array]$PrioritizedProcesses,
        [switch]$CriticalEmergency = $false
    )
    
    try {
        $emergencyLevel = "Standard"
        if ($CriticalEmergency) { $emergencyLevel = "Critical" }
        
        Write-Log "Starting $emergencyLevel emergency protocol" "WARNING"
        
        # Define how many processes to terminate based on emergency level
        $terminationCount = 3  # Standard emergency terminates up to 3 processes
        if ($CriticalEmergency) {
            $terminationCount = 10  # Critical emergency terminates up to 10 processes
        }
        
        # Track terminated processes
        $terminatedProcesses = @()
        $terminationCount = [Math]::Min($terminationCount, $PrioritizedProcesses.Count)
        
        for ($i = 0; $i -lt $terminationCount; $i++) {
            $process = $PrioritizedProcesses[$i]
            
            # Skip protected processes
            if ($process.IsProtected) {
                Write-Log "Skipping protected process: $($process.Name) (PID: $($process.Id))" "INFO"
                continue
            }
            
            # Skip system processes unless in critical emergency
            if ($process.Type -eq "system" -and -not $CriticalEmergency) {
                Write-Log "Skipping system process: $($process.Name) (PID: $($process.Id))" "INFO"
                continue
            }
            
            # Terminate the process
            $success = Invoke-ProcessTermination -Process $process -EmergencyMode
            
            if ($success) {
                $terminatedProcesses += $process
                
                # Check if system state has improved after each termination
                $newSystemState = Get-SystemState
                
                # If we're no longer in emergency, we can stop
                if (-not $newSystemState.EmergencyMode) {
                    Write-Log "Emergency condition resolved after terminating $($terminatedProcesses.Count) processes" "INFO"
                    break
                }
                
                # Brief pause to let system adjust
                Start-Sleep -Seconds 2
            }
        }
        
        # Log summary
        Write-Log "Emergency protocol completed. Terminated $($terminatedProcesses.Count) processes" "INFO"
        
        # Set emergency cooldown timestamp
        $timestamp = Get-Date
        $cooldownFile = "$LogDir/emergency-cooldown.json"
        
        $cooldownData = @{
            Timestamp = $timestamp.ToString("o")
            ExpiresAt = $timestamp.AddMinutes($EmergencyCooldownMinutes).ToString("o")
            TerminatedProcessCount = $terminatedProcesses.Count
            EmergencyLevel = $emergencyLevel
        }
        
        $cooldownData | ConvertTo-Json | Set-Content -Path $cooldownFile
        Write-Log "Emergency cooldown set until $($cooldownData.ExpiresAt)" "INFO"
        
        return $terminatedProcesses
    }
    catch {
        Write-Log "Error in emergency protocol: $_" "ERROR"
        throw $_
    }
}

function Test-EmergencyCooldown {
    try {
        $cooldownFile = "$LogDir/emergency-cooldown.json"
        
        if (-not (Test-Path $cooldownFile)) {
            return $false
        }
        
        $cooldownData = Get-Content -Path $cooldownFile | ConvertFrom-Json
        $expiresAt = [DateTime]::Parse($cooldownData.ExpiresAt)
        
        if ((Get-Date) -lt $expiresAt) {
            $minutesLeft = [math]::Round(($expiresAt - (Get-Date)).TotalMinutes, 1)
            Write-Log "Emergency cooldown in effect. $minutesLeft minutes remaining." "INFO"
            return $true
        }
        
        return $false
    }
    catch {
        Write-Log "Error checking emergency cooldown: $_" "WARNING"
        return $false
    }
}

function Start-ProcessPriorityQueue {
    param(
        [switch]$MonitorOnly = $false,
        [switch]$ForceCooldownReset = $false
    )
    
    try {
        Write-Log "Starting Process Priority Queue" "INFO"
        
        # Reset cooldown if requested
        if ($ForceCooldownReset) {
            $cooldownFile = "$LogDir/emergency-cooldown.json"
            if (Test-Path $cooldownFile) {
                Remove-Item -Path $cooldownFile -Force
                Write-Log "Emergency cooldown forcibly reset" "WARNING"
            }
        }
        
        # Get current system state
        $systemState = Get-SystemState
        
        # Calculate process priorities
        $prioritizedProcesses = Get-ProcessPriorities -SystemState $systemState
        
        # Export process priority data
        $priorityDataFile = "$LogDir/process-priorities-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
        $exportData = @{
            SystemState = $systemState
            PrioritizedProcesses = $prioritizedProcesses
            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }
        $exportData | ConvertTo-Json -Depth 10 | Set-Content -Path $priorityDataFile
        Write-Log "Process priority data exported to $priorityDataFile" "INFO"
        
        # Check if system is in emergency mode
        if ($systemState.EmergencyMode -and -not $MonitorOnly) {
            # Check if emergency cooldown is in effect
            $cooldownActive = Test-EmergencyCooldown
            
            if (-not $cooldownActive) {
                # Execute emergency protocol
                Start-EmergencyProtocol -SystemState $systemState `
                                        -PrioritizedProcesses $prioritizedProcesses `
                                        -CriticalEmergency:$systemState.CriticalEmergency
            } else {
                Write-Log "Emergency mode detected, but cooldown is active. Taking no action." "WARNING"
            }
        } elseif ($systemState.EmergencyMode -and $MonitorOnly) {
            Write-Log "Emergency mode detected, but monitor-only mode is enabled. Taking no action." "WARNING"
        } else {
            Write-Log "System state is normal. No emergency action required." "INFO"
        }
        
        # Return the prioritized processes
        return $prioritizedProcesses
    }
    catch {
        Write-Log "Critical error in Process Priority Queue: $($_.Exception.Message)" "ERROR"
        Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
        throw $_
    }
}

# Main execution
try {
    $results = Start-ProcessPriorityQueue -MonitorOnly  # Start in monitor-only mode by default
    Write-Log "Process Priority Queue execution completed. Found $($results.Count) processes." "INFO"
    
    # Return the top 10 termination candidates for informational purposes
    $topCandidates = $results | Where-Object { -not $_.IsProtected } | Sort-Object -Property PriorityScore | Select-Object -First 10
    
    if ($topCandidates.Count -gt 0) {
        Write-Log "Top termination candidates (lowest priority score = highest termination priority):" "INFO"
        $topCandidates | ForEach-Object {
            Write-Log "  - $($_.Name) (PID: $($_.Id)), Memory: $($_.MemoryUsageMB) MB, Score: $($_.PriorityScore), Level: $($_.PriorityLevel)" "INFO"
        }
    }
    
    exit 0
}
catch {
    Write-Log "Unhandled exception in Process Priority Queue: $($_.Exception.Message)" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    exit 1
} 