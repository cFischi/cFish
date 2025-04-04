# cursor-manager.ps1
# Cursor Instance Management System
# Purpose: Monitors, manages, and optimizes Cursor instances to prevent resource exhaustion
# Created: 05-07-2025
# Updated: 05-09-2025

[CmdletBinding()]
param(
    [Parameter()]
    [int]$MaxInstances = 1,
    
    [Parameter()]
    [int]$MemoryThresholdPercent = 75,
    
    [Parameter()]
    [int]$ProcessCountThreshold = 250,
    
    [Parameter()]
    [switch]$ForceCleanup = $false,
    
    [Parameter()]
    [string]$LogPath = "$PSScriptRoot\..\logs\cursor-manager.log",
    
    [Parameter()]
    [switch]$AggressiveMemoryReclamation = $false
)

# Ensure log directory exists
$logDir = Split-Path $LogPath -Parent
if (-not (Test-Path $logDir)) {
    try {
        New-Item -Path $logDir -ItemType Directory -Force | Out-Null
        Write-Verbose "Created log directory: $logDir"
    } 
    catch {
        Write-Error "Failed to create log directory: $($_.Exception.Message)"
        exit 1
    }
}

# Define critical services that should not be terminated
$criticalServices = @(
    "winlogon", "wininit", "services", "lsass", "csrss", "smss", "svchost", 
    "spoolsv", "explorer", "dwm", "fontdrvhost", "taskmgr", "audiodg", 
    "sihost", "ctfmon", "RuntimeBroker", "SearchHost", "ShellExperienceHost"
)

# Define process priority tiers for selective termination
$processTerminationTiers = @{
    # Tier 1: High priority for termination (non-essential, high memory usage)
    HighPriority = @{
        Names = @("node", "chrome", "firefox", "msedge", "teams", "slack", "electron")
        MemoryThreshold = 200 # MB
    }
    # Tier 2: Medium priority for termination (potentially useful but not critical)
    MediumPriority = @{
        Names = @("code", "vs_server", "java", "python", "jupyter", "npm", "webpack")
        MemoryThreshold = 150 # MB
    }
    # Tier 3: Low priority for termination (potentially important tools)
    LowPriority = @{
        Names = @("powershell", "cmd", "git", "ssh", "msbuild", "dotnet", "curl")
        MemoryThreshold = 100 # MB
    }
    # Special: Cursor-related processes (managed separately)
    CursorRelated = @{
        Names = @("cursor", "Cursor", "electron", "node")
        MemoryThreshold = 150 # MB
    }
}

# Helper Functions
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    
    try {
        Add-Content -Path $LogPath -Value $logEntry
        
        switch ($Level) {
            "ERROR" { Write-Host $logEntry -ForegroundColor Red }
            "WARNING" { Write-Host $logEntry -ForegroundColor Yellow }
            "SUCCESS" { Write-Host $logEntry -ForegroundColor Green }
            default { Write-Host $logEntry }
        }
    }
    catch {
        Write-Error "Failed to write to log: $($_.Exception.Message)"
    }
}

function Get-SystemMetrics {
    try {
        $os = Get-CimInstance -ClassName Win32_OperatingSystem
        $totalMemoryMB = [math]::Round($os.TotalVisibleMemorySize / 1024)
        $freeMemoryMB = [math]::Round($os.FreePhysicalMemory / 1024)
        $usedMemoryPercent = [math]::Round(100 - (($freeMemoryMB / $totalMemoryMB) * 100), 2)
        $totalProcessCount = (Get-Process).Count
        
        # Calculate memory status with more granular levels
        $memoryStatus = "NORMAL"
        if ($usedMemoryPercent -ge $MemoryThresholdPercent + 10) {
            $memoryStatus = "SEVERE"
        }
        elseif ($usedMemoryPercent -ge $MemoryThresholdPercent + 5) {
            $memoryStatus = "CRITICAL"
        }
        elseif ($usedMemoryPercent -ge $MemoryThresholdPercent) {
            $memoryStatus = "WARNING"
        }
        
        # Calculate process count status with more granular levels
        $processStatus = "NORMAL"
        if ($totalProcessCount -ge $ProcessCountThreshold + 50) {
            $processStatus = "SEVERE"
        }
        elseif ($totalProcessCount -ge $ProcessCountThreshold + 25) {
            $processStatus = "CRITICAL"
        }
        elseif ($totalProcessCount -ge $ProcessCountThreshold) {
            $processStatus = "WARNING"
        }
        
        # Get CPU utilization
        $cpuUtil = (Get-CimInstance -ClassName Win32_Processor | Measure-Object -Property LoadPercentage -Average).Average
        
        # Get disk metrics
        $systemDrive = (Get-CimInstance -ClassName Win32_OperatingSystem).SystemDrive.TrimEnd(":")
        $disk = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='$systemDrive`:'"
        $diskFreePercent = [math]::Round(($disk.FreeSpace / $disk.Size) * 100, 2)
        
        return @{
            TotalMemoryMB = $totalMemoryMB
            FreeMemoryMB = $freeMemoryMB
            UsedMemoryPercent = $usedMemoryPercent
            MemoryStatus = $memoryStatus
            ProcessCount = $totalProcessCount
            ProcessStatus = $processStatus
            CpuUtilization = $cpuUtil
            DiskFreePercent = $diskFreePercent
        }
    }
    catch {
        Write-Log "Failed to get system metrics: $($_.Exception.Message)" "ERROR"
        return $null
    }
}

function Get-CursorInstances {
    try {
        # More comprehensive detection of Cursor-related processes
        $cursorProcesses = Get-Process | Where-Object { 
            $_.Name -like "*cursor*" -or 
            $_.Name -like "*Cursor*" -or 
            ($_.Path -ne $null -and $_.Path -like "*Cursor*") -or
            ($_.Company -ne $null -and $_.Company -like "*Cursor*") -or
            ($_.Path -ne $null -and $_.Path -like "*cursor-nodejs*") -or
            ($_.Name -eq "electron" -and ($_.Path -ne $null -and $_.Path -like "*Cursor*")) -or
            ($_.Name -eq "node" -and ($_.Path -ne $null -and $_.Path -like "*Cursor*"))
        }
        
        $instances = @()
        foreach ($proc in $cursorProcesses) {
            $memoryUsageMB = [math]::Round($proc.WorkingSet / 1MB, 2)
            $runtime = if ($proc.StartTime) { (Get-Date) - $proc.StartTime } else { "Unknown" }
            
            $instance = [PSCustomObject]@{
                Id = $proc.Id
                Name = $proc.Name
                StartTime = $proc.StartTime
                RunTime = $runtime
                MemoryUsageMB = $memoryUsageMB
                CpuPercent = $proc.CPU
                Path = "N/A"
                ParentId = $null
                ParentName = $null
                Priority = 0
            }
            
            # Get path with error handling
            try {
                $instance.Path = $proc.Path
            } catch {
                $instance.Path = "N/A"
            }
            
            $instances += $instance
        }
        
        # Try to add parent process info when available
        foreach ($instance in $instances) {
            try {
                $parentProcess = Get-CimInstance -ClassName Win32_Process -Filter "ProcessId = $($instance.Id)" | 
                               Select-Object -ExpandProperty ParentProcessId
                if ($parentProcess) {
                    $parent = Get-Process -Id $parentProcess -ErrorAction SilentlyContinue
                    if ($parent) {
                        $instance.ParentId = $parent.Id
                        $instance.ParentName = $parent.Name
                    }
                }
            } 
            catch {
                # Ignore errors in getting parent process
            }
            
            # Calculate priority score for termination (higher = terminate first)
            # Factors: memory usage (40%), runtime (30%), CPU usage (30%)
            $memoryScore = [math]::Min($instance.MemoryUsageMB / 1000 * 40, 40)
            $runtimeScore = if ($instance.RunTime -is [TimeSpan]) {
                [math]::Max(30 - [math]::Min($instance.RunTime.TotalHours, 24) / 24 * 30, 0)
            } else { 15 } # Middle score for unknown runtime
            $cpuScore = [math]::Min(($instance.CpuPercent / 100) * 30, 30)
            $instance.Priority = $memoryScore + $runtimeScore + $cpuScore
        }
        
        return $instances
    }
    catch {
        Write-Log "Failed to get Cursor instances: $($_.Exception.Message)" "ERROR"
        return @()
    }
}

function Get-ProcessPriorityTier {
    param (
        [Parameter(Mandatory=$true)]
        [System.Diagnostics.Process]$Process
    )
    
    $processName = $Process.Name.ToLower()
    $memoryUsageMB = [math]::Round($Process.WorkingSet / 1MB, 2)
    
    # Check if it's a critical service
    if ($criticalServices -contains $processName) {
        return "Critical"
    }
    
    # Check for system-critical processes
    try {
        # Get services associated with this process
        $services = Get-CimInstance -ClassName Win32_Service -Filter "ProcessId = $($Process.Id)" -ErrorAction SilentlyContinue
        if ($services -and ($services | Where-Object { $_.StartMode -eq "Auto" -and $_.State -eq "Running" })) {
            return "Critical" # Running auto-start services are considered critical
        }
    } catch {
        # Ignore errors in checking services
    }
    
    # Check against priority tiers
    foreach ($tier in @("HighPriority", "MediumPriority", "LowPriority")) {
        if (($processTerminationTiers[$tier].Names | ForEach-Object { $processName -like "*$_*" }) -contains $true) {
            if ($memoryUsageMB -ge $processTerminationTiers[$tier].MemoryThreshold) {
                return $tier
            }
            else {
                return "Below$tier" # Below threshold for its tier
            }
        }
    }
    
    # Check if it's Cursor-related but handled separately
    if (($processTerminationTiers["CursorRelated"].Names | ForEach-Object { $processName -like "*$_*" }) -contains $true) {
        return "CursorRelated"
    }
    
    # Default for unrecognized processes
    if ($memoryUsageMB -gt 200) {
        return "HighMemory"
    }
    elseif ($memoryUsageMB -gt 100) {
        return "MediumMemory"
    }
    else {
        return "LowMemory"
    }
}

function Get-HighMemoryProcesses {
    [CmdletBinding()]
    param(
        [int]$Count = 10,
        [int]$MinMemoryMB = 100
    )
    
    try {
        $processes = Get-Process | Where-Object { 
            $_.WorkingSet -gt ($MinMemoryMB * 1MB)
        } | Sort-Object -Property WorkingSet -Descending | Select-Object -First $Count
        
        $results = @()
        foreach ($proc in $processes) {
            $memoryUsageMB = [math]::Round($proc.WorkingSet / 1MB, 2)
            $priorityTier = Get-ProcessPriorityTier -Process $proc
            
            # Determine if the process is critical
            $criticalService = $priorityTier -eq "Critical"
            
            # Calculate CPU usage percent
            $cpuUsage = if ($proc.CPU) { $proc.CPU } else { 0 }
            
            # Get command line if possible
            $commandLine = $null
            try {
                $wmiProcess = Get-CimInstance -ClassName Win32_Process -Filter "ProcessId = $($proc.Id)" -ErrorAction SilentlyContinue
                if ($wmiProcess) {
                    $commandLine = $wmiProcess.CommandLine
                }
            } catch {
                # Ignore errors
            }
            
            $result = [PSCustomObject]@{
                Id = $proc.Id
                Name = $proc.Name
                MemoryUsageMB = $memoryUsageMB
                CPU = $cpuUsage
                PriorityTier = $priorityTier
                Path = "N/A"
                IsCritical = $criticalService
                CommandLine = $commandLine
                Handles = $proc.Handles
                Threads = $proc.Threads.Count
                StartTime = $proc.StartTime
            }
            
            # Get path with error handling
            try {
                $result.Path = $proc.Path
            } catch {
                # Path remains N/A
            }
            
            $results += $result
        }
        
        return $results
    }
    catch {
        Write-Log "Failed to get high memory processes: $($_.Exception.Message)" "ERROR"
        return @()
    }
}

function Invoke-MemoryReclamation {
    [CmdletBinding()]
    param(
        [switch]$Aggressive = $false
    )
    
    Write-Log "Starting memory reclamation process$(if($Aggressive){' (aggressive mode)'})" "INFO"
    $recoveredMB = 0
    
    # Tier 1: Clear system file cache
    try {
        Write-Log "Clearing system file cache..." "INFO"
        # Use .NET method to clear file system cache if available
        $type = [AppDomain]::CurrentDomain.GetAssemblies() | 
            Where-Object { $_.FullName -like "System.Management.Automation*" } | 
            ForEach-Object { $_.GetType("Microsoft.PowerShell.Commands.Internal.ClearCache") }
        if ($type) {
            $clearMethod = $type.GetMethod("ClearAllCache", [System.Reflection.BindingFlags]::Static -bor [System.Reflection.BindingFlags]::NonPublic)
            if ($clearMethod) {
                $clearMethod.Invoke($null, @())
                Write-Log "Successfully cleared system file cache" "SUCCESS"
                $recoveredMB += 100 # Estimated recovery
            }
        }
    }
    catch {
        Write-Log "Failed to clear system file cache: $($_.Exception.Message)" "WARNING"
    }
    
    # Tier 2: EmptyWorkingSet on non-critical processes
    try {
        Write-Log "Trimming working sets of non-critical processes..." "INFO"
        $trimmedCount = 0
        $beforeMemory = (Get-CimInstance -ClassName Win32_OperatingSystem).FreePhysicalMemory / 1024
        
        # Get all processes sorted by memory usage
        $allProcesses = Get-Process | Sort-Object -Property WorkingSet -Descending
        
        foreach ($proc in $allProcesses) {
            try {
                # Skip critical processes
                $priorityTier = Get-ProcessPriorityTier -Process $proc
                if ($priorityTier -eq "Critical") {
                    continue
                }
                
                # Get memory usage before trim
                $beforeProcMemory = $proc.WorkingSet / 1MB
                
                # Attempt to trim working set
                [System.Runtime.InteropServices.Marshal]::GetFunctionPointerForDelegate([System.Func[IntPtr, bool]] {
                    param($process)
                    [System.Runtime.InteropServices.NativeMethods]::EmptyWorkingSet($process)
                    return $true
                }) | Out-Null
                
                $proc.Refresh()
                $afterProcMemory = $proc.WorkingSet / 1MB
                $trimmedMB = $beforeProcMemory - $afterProcMemory
                
                if ($trimmedMB -gt 1) {
                    $trimmedCount++
                    $recoveredMB += $trimmedMB
                }
                
                # Limit to 50 processes unless in aggressive mode
                if (!$Aggressive -and $trimmedCount -ge 50) {
                    break
                }
            }
            catch {
                # Ignore errors for individual processes
            }
        }
        
        # Explicitly call garbage collection
        [System.GC]::Collect()
        [System.GC]::WaitForPendingFinalizers()
        [System.GC]::Collect()
        
        $afterMemory = (Get-CimInstance -ClassName Win32_OperatingSystem).FreePhysicalMemory / 1024
        $totalRecovered = $afterMemory - $beforeMemory
        
        Write-Log "Trimmed working sets for $trimmedCount processes, recovered approximately $([math]::Round($totalRecovered, 2))MB" "SUCCESS"
    }
    catch {
        Write-Log "Failed to perform working set trimming: $($_.Exception.Message)" "WARNING"
    }
    
    # Tier 3: Terminate high-memory, non-critical processes if in aggressive mode
    if ($Aggressive) {
        Write-Log "Aggressive mode enabled, checking for high-memory processes to terminate" "WARNING"
        
        # Get high memory processes with more details
        $highMemoryProcesses = Get-HighMemoryProcesses -Count 30 -MinMemoryMB 150
        
        # Group by priority tier
        $processTiers = @{
            "HighPriority" = $highMemoryProcesses | Where-Object { $_.PriorityTier -eq "HighPriority" }
            "MediumPriority" = $highMemoryProcesses | Where-Object { $_.PriorityTier -eq "MediumPriority" }
            "LowPriority" = $highMemoryProcesses | Where-Object { $_.PriorityTier -eq "LowPriority" }
            "HighMemory" = $highMemoryProcesses | Where-Object { $_.PriorityTier -eq "HighMemory" }
            "MediumMemory" = $highMemoryProcesses | Where-Object { $_.PriorityTier -eq "MediumMemory" }
        }
        
        $totalTerminated = 0
        $terminationMemoryMB = 0
        
        # Process in tier order (high to low priority for termination)
        foreach ($tier in @("HighPriority", "HighMemory", "MediumPriority", "MediumMemory", "LowPriority")) {
            $processes = $processTiers[$tier]
            if (!$processes) { continue }
            
            foreach ($process in $processes) {
                # Skip critical processes and cursor-related processes (handled separately)
                if ($process.IsCritical -or $process.PriorityTier -eq "CursorRelated") {
                    continue
                }
                
                Write-Log "Terminating high memory process: $($process.Name) (PID: $($process.Id), Memory: $($process.MemoryUsageMB)MB, Tier: $tier)" "WARNING"
                
                try {
                    Stop-Process -Id $process.Id -Force
                    Write-Log "Successfully terminated process $($process.Id)" "SUCCESS"
                    $totalTerminated++
                    $terminationMemoryMB += $process.MemoryUsageMB
                    $recoveredMB += $process.MemoryUsageMB
                    
                    # Check if we've made enough progress
                    if ($totalTerminated -ge 3) {
                        Start-Sleep -Seconds 1
                        $updatedMetrics = Get-SystemMetrics
                        if ($updatedMetrics.MemoryStatus -eq "NORMAL" -or $updatedMetrics.MemoryStatus -eq "WARNING") {
                            Write-Log "Memory status improved to $($updatedMetrics.MemoryStatus) after terminating $totalTerminated processes" "SUCCESS"
                            break
                        }
                    }
                }
                catch {
                    Write-Log "Failed to terminate process $($process.Id): $($_.Exception.Message)" "ERROR"
                }
                
                # Stop after terminating enough processes
                if ($totalTerminated -ge 5) {
                    break
                }
            }
            
            # If we've terminated enough processes, stop checking lower tiers
            if ($totalTerminated -ge 5) {
                break
            }
        }
        
        if ($totalTerminated -gt 0) {
            Write-Log "Terminated $totalTerminated high memory processes, freed approximately $terminationMemoryMB MB" "SUCCESS"
        } else {
            Write-Log "No suitable high memory processes were terminated" "INFO"
        }
    }
    
    Write-Log "Memory reclamation complete, recovered approximately $([math]::Round($recoveredMB, 2))MB" "SUCCESS"
    return $recoveredMB
}

function Optimize-CursorInstances {
    [CmdletBinding()]
    param(
        [switch]$TerminateAll = $false,
        [switch]$AggressiveCleanup = $false
    )
    
    try {
        $instances = Get-CursorInstances
        $systemMetrics = Get-SystemMetrics
        
        Write-Log "System Memory: $($systemMetrics.UsedMemoryPercent)% used ($($systemMetrics.FreeMemoryMB)MB free of $($systemMetrics.TotalMemoryMB)MB total)"
        Write-Log "Process Count: $($systemMetrics.ProcessCount) processes (threshold: $ProcessCountThreshold)"
        Write-Log "Found $($instances.Count) Cursor instances running"
        
        # Initialize action flags based on system status
        $needsMemoryCleanup = $systemMetrics.MemoryStatus -eq "CRITICAL" -or $systemMetrics.MemoryStatus -eq "SEVERE" -or $ForceCleanup
        $needsProcessCleanup = $systemMetrics.ProcessStatus -eq "CRITICAL" -or $systemMetrics.ProcessStatus -eq "SEVERE" -or $AggressiveCleanup
        
        # If there's a critical condition or force cleanup is enabled, take action
        if ($needsMemoryCleanup -or $needsProcessCleanup -or $TerminateAll) {
            if ($needsMemoryCleanup) {
                Write-Log "Memory usage is $($systemMetrics.MemoryStatus) ($($systemMetrics.UsedMemoryPercent)%) or force cleanup requested" "WARNING"
            }
            
            if ($needsProcessCleanup) {
                Write-Log "Process count is $($systemMetrics.ProcessStatus) ($($systemMetrics.ProcessCount)) or aggressive cleanup requested" "WARNING"
            }
            
            # First handle Cursor instances
            if ($TerminateAll) {
                Write-Log "Terminating ALL Cursor instances" "WARNING"
                $toTerminate = $instances
            }
            else {
                # Keep the newest instance, terminate others
                # Sort by priority and then by start time (newest first)
                $toKeep = $instances | Sort-Object StartTime -Descending | Select-Object -First $MaxInstances
                $toTerminate = $instances | Where-Object { $toKeep.Id -notcontains $_.Id } | Sort-Object Priority -Descending
            }
            
            foreach ($process in $toTerminate) {
                Write-Log "Terminating Cursor instance: $($process.Id) (Memory: $($process.MemoryUsageMB)MB, Runtime: $($process.RunTime), Priority: $($process.Priority))" "WARNING"
                
                try {
                    Stop-Process -Id $process.Id -Force
                    Write-Log "Successfully terminated process $($process.Id)" "SUCCESS"
                }
                catch {
                    Write-Log "Failed to terminate process $($process.Id): $($_.Exception.Message)" "ERROR"
                }
            }
            
            if ($toTerminate.Count -gt 0) {
                Write-Log "Terminated $($toTerminate.Count) Cursor instances" "SUCCESS"
            }
            else {
                Write-Log "No Cursor instances to terminate" "INFO"
            }
            
            # Memory reclamation - start with standard approach
            Invoke-MemoryReclamation
            
            # If memory is still critical, or process count is critical, perform aggressive cleanup
            $updatedMetrics = Get-SystemMetrics
            if ($updatedMetrics.MemoryStatus -eq "CRITICAL" -or $updatedMetrics.MemoryStatus -eq "SEVERE" -or 
                $updatedMetrics.ProcessStatus -eq "CRITICAL" -or $updatedMetrics.ProcessStatus -eq "SEVERE" -or 
                $AggressiveCleanup -or $AggressiveMemoryReclamation) {
                
                Write-Log "System resources still critical or aggressive cleanup requested. Implementing aggressive memory reclamation" "WARNING"
                Invoke-MemoryReclamation -Aggressive
            }
            
            # Verify after actions
            Start-Sleep -Seconds 2
            $remainingInstances = Get-CursorInstances
            Write-Log "Remaining Cursor instances: $($remainingInstances.Count)" "INFO"
            
            # Check process count and memory again
            $updatedMetrics = Get-SystemMetrics
            Write-Log "Updated process count: $($updatedMetrics.ProcessCount) (status: $($updatedMetrics.ProcessStatus))" "INFO"
            Write-Log "Updated memory usage: $($updatedMetrics.UsedMemoryPercent)% (status: $($updatedMetrics.MemoryStatus))" "INFO"
            
            # Trigger garbage collection
            [System.GC]::Collect()
            Write-Log "Garbage collection triggered" "INFO"
        }
        else {
            if ($instances.Count -gt $MaxInstances) {
                Write-Log "Number of instances ($($instances.Count)) exceeds maximum ($MaxInstances), optimizing..." "WARNING"
                
                # Keep the newest instances, terminate others
                $toKeep = $instances | Sort-Object StartTime -Descending | Select-Object -First $MaxInstances
                $toTerminate = $instances | Where-Object { $toKeep.Id -notcontains $_.Id } | Sort-Object Priority -Descending
                
                foreach ($process in $toTerminate) {
                    Write-Log "Terminating excess Cursor instance: $($process.Id) (Memory: $($process.MemoryUsageMB)MB, Runtime: $($process.RunTime), Priority: $($process.Priority))" "WARNING"
                    
                    try {
                        Stop-Process -Id $process.Id -Force
                        Write-Log "Successfully terminated process $($process.Id)" "SUCCESS"
                    }
                    catch {
                        Write-Log "Failed to terminate process $($process.Id): $($_.Exception.Message)" "ERROR"
                    }
                }
                
                # Verify after termination
                Start-Sleep -Seconds 2
                $remainingInstances = Get-CursorInstances
                Write-Log "Remaining Cursor instances: $($remainingInstances.Count)" "INFO"
            }
            else {
                Write-Log "Instance count ($($instances.Count)) within limits, no action needed" "SUCCESS"
                
                # Consider light memory optimization if we're approaching thresholds
                if ($systemMetrics.UsedMemoryPercent -gt ($MemoryThresholdPercent - 10)) {
                    Write-Log "Memory usage approaching threshold, performing light optimization" "INFO"
                    Invoke-MemoryReclamation
                }
            }
        }
        
        # Get updated metrics
        $updatedMetrics = Get-SystemMetrics
        Write-Log "Final metrics:" "INFO"
        Write-Log "  Memory: $($updatedMetrics.UsedMemoryPercent)% used ($($updatedMetrics.FreeMemoryMB)MB free)" "INFO"
        Write-Log "  Process Count: $($updatedMetrics.ProcessCount) processes" "INFO"
        Write-Log "  CPU Utilization: $($updatedMetrics.CpuUtilization)%" "INFO"
        Write-Log "  Disk Free: $($updatedMetrics.DiskFreePercent)%" "INFO"
        
        return @{
            Success = $true
            OriginalMetrics = $systemMetrics
            UpdatedMetrics = $updatedMetrics
            InstancesBefore = $instances.Count
            InstancesAfter = (Get-CursorInstances).Count
            ProcessesBefore = $systemMetrics.ProcessCount
            ProcessesAfter = $updatedMetrics.ProcessCount
        }
    }
    catch {
        Write-Log "Failed to optimize Cursor instances: $($_.Exception.Message)" "ERROR"
        return @{
            Success = $false
            Error = $_.Exception.Message
        }
    }
}

function Get-CursorInstanceDetails {
    try {
        $instances = Get-CursorInstances
        
        if ($instances.Count -eq 0) {
            Write-Log "No Cursor instances found" "INFO"
            return $null
        }
        
        $totalMemory = ($instances | Measure-Object -Property MemoryUsageMB -Sum).Sum
        
        Write-Log "Cursor Instance Details:" "INFO"
        Write-Log "Total Instances: $($instances.Count)" "INFO"
        Write-Log "Total Memory Usage: $totalMemory MB" "INFO"
        
        foreach ($instance in $instances) {
            $parentInfo = if ($instance.ParentName) { "Parent: $($instance.ParentName) (PID: $($instance.ParentId))" } else { "" }
            Write-Log "Instance ID: $($instance.Id), Name: $($instance.Name), Memory: $($instance.MemoryUsageMB)MB, Runtime: $($instance.RunTime), Priority: $($instance.Priority) $parentInfo" "INFO"
        }
        
        return $instances
    }
    catch {
        Write-Log "Failed to get Cursor instance details: $($_.Exception.Message)" "ERROR"
        return $null
    }
}

function Get-SystemResourceReport {
    try {
        $metrics = Get-SystemMetrics
        $highMemProcesses = Get-HighMemoryProcesses -Count 15 -MinMemoryMB 100
        
        Write-Log "System Resource Report:" "INFO"
        Write-Log "Memory Usage: $($metrics.UsedMemoryPercent)% ($($metrics.FreeMemoryMB)MB free of $($metrics.TotalMemoryMB)MB total)" "INFO"
        Write-Log "Memory Status: $($metrics.MemoryStatus)" "INFO"
        Write-Log "Process Count: $($metrics.ProcessCount) (Status: $($metrics.ProcessStatus))" "INFO"
        Write-Log "CPU Utilization: $($metrics.CpuUtilization)%" "INFO" 
        Write-Log "Disk Free: $($metrics.DiskFreePercent)%" "INFO"
        
        Write-Log "Top Memory Consumers:" "INFO"
        foreach ($process in $highMemProcesses | Sort-Object -Property MemoryUsageMB -Descending | Select-Object -First 10) {
            $criticalTag = if ($process.IsCritical) { "[CRITICAL] " } else { "" }
            Write-Log "  $criticalTag$($process.Name) (PID: $($process.Id)): $($process.MemoryUsageMB)MB, CPU: $($process.CPU)%, Tier: $($process.PriorityTier)" "INFO"
        }
        
        # Count processes by priority tier
        $tierCounts = @{}
        foreach ($process in $highMemProcesses) {
            if (!$tierCounts.ContainsKey($process.PriorityTier)) {
                $tierCounts[$process.PriorityTier] = 0
            }
            $tierCounts[$process.PriorityTier]++
        }
        
        Write-Log "Process Priority Tiers:" "INFO"
        foreach ($tier in $tierCounts.Keys | Sort-Object) {
            Write-Log "  $tier`: $($tierCounts[$tier]) processes" "INFO"
        }
        
        return @{
            Metrics = $metrics
            HighMemoryProcesses = $highMemProcesses
            PriorityTiers = $tierCounts
        }
    }
    catch {
        Write-Log "Failed to generate system resource report: $($_.Exception.Message)" "ERROR"
        return $null
    }
}

# Main execution
try {
    Write-Log "===== Cursor Manager Started =====" "INFO"
    Write-Log "Max Instances: $MaxInstances, Memory Threshold: $MemoryThresholdPercent%, Process Threshold: $ProcessCountThreshold" "INFO"
    Write-Log "Force Cleanup: $ForceCleanup, Aggressive Memory Reclamation: $AggressiveMemoryReclamation" "INFO"
    
    # Get system state before optimization
    $beforeMetrics = Get-SystemMetrics
    Write-Log "Initial system state:" "INFO"
    Write-Log "  Memory: $($beforeMetrics.UsedMemoryPercent)% used ($($beforeMetrics.FreeMemoryMB)MB free of $($beforeMetrics.TotalMemoryMB)MB total)" "INFO"
    Write-Log "  Process Count: $($beforeMetrics.ProcessCount) processes (threshold: $ProcessCountThreshold)" "INFO"
    Write-Log "  Memory Status: $($beforeMetrics.MemoryStatus)" "INFO"
    Write-Log "  Process Status: $($beforeMetrics.ProcessStatus)" "INFO"
    
    # Get detailed information about Cursor instances
    $instanceDetails = Get-CursorInstanceDetails
    
    # Generate system resource report
    Get-SystemResourceReport
    
    # Determine if aggressive cleanup is needed based on system status
    $aggressiveCleanup = $beforeMetrics.ProcessStatus -eq "CRITICAL" -or $beforeMetrics.ProcessStatus -eq "SEVERE" -or 
                         $beforeMetrics.MemoryStatus -eq "CRITICAL" -or $beforeMetrics.MemoryStatus -eq "SEVERE" -or
                         $AggressiveMemoryReclamation
    
    # Optimize Cursor instances with appropriate flags
    $result = Optimize-CursorInstances -AggressiveCleanup:$aggressiveCleanup
    
    if ($result.Success) {
        Write-Log "Optimization completed successfully" "SUCCESS"
        
        # Summarize changes
        $memoryChange = $result.OriginalMetrics.UsedMemoryPercent - $result.UpdatedMetrics.UsedMemoryPercent
        $processChange = $result.ProcessesBefore - $result.ProcessesAfter
        $instanceChange = $result.InstancesBefore - $result.InstancesAfter
        
        Write-Log "System Changes:" "SUCCESS"
        Write-Log "  Cursor Instances: $($result.InstancesBefore) → $($result.InstancesAfter) ($(if ($instanceChange -gt 0) {"-$instanceChange"} else {"No change"}))" "SUCCESS"
        Write-Log "  Process Count: $($result.ProcessesBefore) → $($result.ProcessesAfter) ($(if ($processChange -gt 0) {"-$processChange"} else {"No change"}))" "SUCCESS"
        Write-Log "  Memory Usage: $($result.OriginalMetrics.UsedMemoryPercent)% → $($result.UpdatedMetrics.UsedMemoryPercent)% ($(if ($memoryChange -gt 0) {"-$memoryChange%"} else {"No change"}))" "SUCCESS"
        Write-Log "  Free Memory: $($result.UpdatedMetrics.FreeMemoryMB)MB" "SUCCESS"
        
        # Recommend additional actions if needed
        if ($result.UpdatedMetrics.ProcessStatus -eq "CRITICAL" -or $result.UpdatedMetrics.ProcessStatus -eq "SEVERE") {
            Write-Log "Process count still $($result.UpdatedMetrics.ProcessStatus), consider manual cleanup or system restart" "WARNING"
        }
        
        if ($result.UpdatedMetrics.MemoryStatus -eq "CRITICAL" -or $result.UpdatedMetrics.MemoryStatus -eq "SEVERE") {
            Write-Log "Memory usage still $($result.UpdatedMetrics.MemoryStatus), consider manual cleanup or system restart" "WARNING"
        }
    }
    else {
        Write-Log "Optimization failed: $($result.Error)" "ERROR"
    }
    
    Write-Log "===== Cursor Manager Completed =====" "INFO"
}
catch {
    Write-Log "Unexpected error: $($_.Exception.Message)" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    exit 1
} 