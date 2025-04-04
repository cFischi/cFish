# Process Manager for npm installations
# Handles process tracking, termination, and isolation using Windows job objects

# Enable strict mode
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Add Windows API types
$TypeDefinition = @"
using System;
using System.Runtime.InteropServices;

public class JobObject {
    [DllImport("kernel32.dll", CharSet = CharSet.Unicode)]
    public static extern IntPtr CreateJobObject(IntPtr lpJobAttributes, string lpName);

    [DllImport("kernel32.dll")]
    public static extern bool AssignProcessToJobObject(IntPtr hJob, IntPtr hProcess);

    [DllImport("kernel32.dll")]
    public static extern bool SetInformationJobObject(IntPtr hJob, int JobObjectInfoClass, IntPtr lpJobObjectInfo, int cbJobObjectInfoLength);

    [DllImport("kernel32.dll")]
    public static extern bool CloseHandle(IntPtr hObject);
}
"@

Add-Type -TypeDefinition $TypeDefinition

# Initialize logging
$LogPath = Join-Path $PSScriptRoot ".." "logs" "process-manager.log"
$null = New-Item -ItemType Directory -Force -Path (Split-Path $LogPath)

function Write-ProcessLog {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMessage = "$Timestamp [$Level] $Message"
    Add-Content -Path $LogPath -Value $LogMessage
    Write-Host $LogMessage
}

# Create a job object for process isolation
$JobName = "NpmInstallJob_$(Get-Random)"
$script:JobHandle = [JobObject]::CreateJobObject([IntPtr]::Zero, $JobName)

if ($script:JobHandle -eq [IntPtr]::Zero) {
    throw "Failed to create job object"
}

function Add-ProcessToJob {
    param(
        [int]$ProcessId
    )
    
    try {
        $Process = Get-Process -Id $ProcessId -ErrorAction Stop
        $Result = [JobObject]::AssignProcessToJobObject($script:JobHandle, $Process.Handle)
        
        if (-not $Result) {
            Write-ProcessLog "Failed to add process $ProcessId to job object" -Level "WARNING"
        }
        
        return $Result
    } catch {
        Write-ProcessLog "Error adding process to job: $_" -Level "ERROR"
        return $false
    }
}

function Start-NpmProcess {
    param(
        [string]$Arguments,
        [int]$TimeoutSeconds = 300
    )
    
    try {
        Write-ProcessLog "Starting npm process with args: $Arguments"
        
        # Verify npm installation
        $NpmPath = Get-Command npm -ErrorAction SilentlyContinue
        if (-not $NpmPath) {
            throw "npm not found in PATH. Please ensure Node.js is installed and in the system PATH."
        }
        
        $ProcessInfo = New-Object System.Diagnostics.ProcessStartInfo
        $ProcessInfo.FileName = "cmd.exe"
        $ProcessInfo.Arguments = "/c npm $Arguments"
        $ProcessInfo.UseShellExecute = $false
        $ProcessInfo.RedirectStandardOutput = $true
        $ProcessInfo.RedirectStandardError = $true
        $ProcessInfo.CreateNoWindow = $true
        
        $Process = [System.Diagnostics.Process]::Start($ProcessInfo)
        $Added = Add-ProcessToJob -ProcessId $Process.Id
        
        if (-not $Added) {
            Write-ProcessLog "Warning: Process not added to job object" -Level "WARNING"
        }
        
        Write-ProcessLog "Process started with PID: $($Process.Id)"
        
        # Start monitoring thread
        $MonitoringJob = Start-Job -ScriptBlock {
            param($ProcessId, $TimeoutSeconds)
            
            $Process = Get-Process -Id $ProcessId -ErrorAction SilentlyContinue
            $StartTime = Get-Date
            
            while ($Process -and -not $Process.HasExited) {
                $TimeDiff = (Get-Date) - $StartTime
                if ($TimeDiff.TotalSeconds -gt $TimeoutSeconds) {
                    return "TIMEOUT"
                }
                
                try {
                    $CpuUsage = (Get-Counter "\Process($($Process.ProcessName))\% Processor Time" -ErrorAction SilentlyContinue).CounterSamples.CookedValue
                    $MemoryUsage = $Process.WorkingSet64 / 1MB
                    
                    if ($CpuUsage -gt 90 -or $MemoryUsage -gt 1000) {
                        return "RESOURCE_EXCEEDED"
                    }
                } catch {
                    # Ignore counter errors
                }
                
                Start-Sleep -Seconds 1
            }
            
            return "COMPLETED"
        } -ArgumentList $Process.Id, $TimeoutSeconds
        
        # Wait for process completion or timeout
        $Result = Wait-Job $MonitoringJob -Timeout $TimeoutSeconds
        
        if ($Result -eq "TIMEOUT" -or $Result -eq "RESOURCE_EXCEEDED") {
            Write-ProcessLog "Terminating process $($Process.Id) due to: $Result" -Level "WARNING"
            Stop-Process -Id $Process.Id -Force
            throw "Process terminated: $Result"
        }
        
        Write-ProcessLog "Process completed successfully"
        return $true
        
    } catch {
        Write-ProcessLog "Error in process execution: $_" -Level "ERROR"
        throw $_
    }
}

function Stop-StalledProcesses {
    param(
        [int]$StallThresholdMinutes = 10
    )
    
    try {
        Write-ProcessLog "Checking for stalled npm processes"
        
        $StalledProcesses = Get-Process | Where-Object {
            $_.ProcessName -eq "npm" -and
            $_.StartTime -lt (Get-Date).AddMinutes(-$StallThresholdMinutes)
        }
        
        foreach ($Process in $StalledProcesses) {
            Write-ProcessLog "Terminating stalled process: $($Process.Id)" -Level "WARNING"
            Stop-Process -Id $Process.Id -Force
        }
        
        Write-ProcessLog "Stalled process check completed"
    } catch {
        Write-ProcessLog "Error checking stalled processes: $_" -Level "ERROR"
        throw $_
    }
}

function Get-ProcessMetrics {
    try {
        Write-ProcessLog "Collecting process metrics"
        
        $NpmProcesses = Get-Process npm -ErrorAction SilentlyContinue
        if (-not $NpmProcesses) {
            return @{
                TotalProcesses = 0
                TotalMemory = 0
                CpuUsage = 0
            }
        }
        
        $Metrics = @{
            TotalProcesses = $NpmProcesses.Count
            TotalMemory = ($NpmProcesses | Measure-Object WorkingSet64 -Sum).Sum / 1MB
            CpuUsage = 0  # Initialize to 0
        }
        
        try {
            $CpuCounter = Get-Counter "\Process(npm)\% Processor Time" -ErrorAction SilentlyContinue
            if ($CpuCounter) {
                $Metrics.CpuUsage = $CpuCounter.CounterSamples.CookedValue
            }
        } catch {
            Write-ProcessLog "Warning: Could not get CPU metrics" -Level "WARNING"
        }
        
        Write-ProcessLog "Process metrics: $($Metrics | ConvertTo-Json)"
        return $Metrics
    } catch {
        Write-ProcessLog "Error collecting process metrics: $_" -Level "ERROR"
        throw $_
    }
}

function Close-JobHandle {
    if ($script:JobHandle -ne [IntPtr]::Zero) {
        [JobObject]::CloseHandle($script:JobHandle)
        Write-ProcessLog "Job object handle closed"
        $script:JobHandle = [IntPtr]::Zero
    }
}

# Process Manager Script
# Handles spawning, monitoring, and terminating processes safely

$ProcessLogFile = "./.cursor/logs/process-manager.log"

# Create log directory if it doesn't exist
$LogDir = "./.cursor/logs"
New-Item -ItemType Directory -Path $LogDir -Force | Out-Null

# Configuration
$EmergencyConfig = @{
    "ProtectedProcesses" = @(
        "explorer", "svchost", "lsass", "csrss", "wininit", 
        "services", "smss", "winlogon", "dwm", "taskmgr", 
        "powershell", "cmd", "conhost"
    )
    "CriticalSystemServices" = @(
        "wuauserv", "WinRM", "spooler", "LanmanServer", "W32Time", 
        "RpcSs", "DHCP", "EventLog", "PlugPlay", "Power", "Dnscache"
    )
    "ValidationPrompts" = $true      # Prompt for validation before emergency termination
    "RequireKeywordConfirmation" = $true  # Require special keyword for confirmation
    "ConfirmationKeyword" = "CONFIRM-TERMINATE"  # Keyword required for emergency termination
    "EmergencyCooldownMinutes" = 15  # Cooldown period after emergency termination
    "LogEmergencyActions" = $true    # Log all emergency actions to a separate file
}

function Write-ProcessLog {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    $TimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMessage = "[$TimeStamp] [$Level] $Message"
    
    # Write to console
    switch ($Level) {
        "ERROR" { Write-Host $LogMessage -ForegroundColor Red }
        "WARNING" { Write-Host $LogMessage -ForegroundColor Yellow }
        "SUCCESS" { Write-Host $LogMessage -ForegroundColor Green }
        default { Write-Host $LogMessage }
    }
    
    # Create log directory if it doesn't exist
    if (-not (Test-Path $LogDir)) {
        New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
    }
    
    # Write to log file
    Add-Content -Path $ProcessLogFile -Value $LogMessage
    
    # If this is an emergency action, also log to emergency log
    if ($Level -eq "EMERGENCY") {
        $EmergencyLogFile = "./.cursor/logs/emergency-actions.log"
        Add-Content -Path $EmergencyLogFile -Value $LogMessage
    }
}

function Start-ManagedProcess {
    param(
        [string]$ProcessPath,
        [string[]]$ArgumentList,
        [string]$WorkingDirectory = (Get-Location),
        [string]$GroupName = "default",
        [switch]$NoWindow,
        [switch]$WaitForExit,
        [int]$TimeoutSeconds = 0
    )
    
    try {
        # Create process info
        $ProcessInfo = New-Object System.Diagnostics.ProcessStartInfo
        $ProcessInfo.FileName = $ProcessPath
        $ProcessInfo.WorkingDirectory = $WorkingDirectory
        
        if ($ArgumentList) {
            $ProcessInfo.Arguments = $ArgumentList -join " "
        }
        
        if ($NoWindow) {
            $ProcessInfo.CreateNoWindow = $true
            $ProcessInfo.WindowStyle = "Hidden"
            $ProcessInfo.UseShellExecute = $false
            $ProcessInfo.RedirectStandardOutput = $true
            $ProcessInfo.RedirectStandardError = $true
        }
        
        # Create and start process
        Write-ProcessLog "Starting process $ProcessPath with arguments: $($ArgumentList -join ' ')" "INFO"
        
        $Process = New-Object System.Diagnostics.Process
        $Process.StartInfo = $ProcessInfo
        $Process.Start() | Out-Null
        
        # Record process details
        $ProcessRecord = @{
            Id = $Process.Id
            Name = $Process.ProcessName
            Path = $ProcessPath
            Arguments = $ArgumentList
            StartTime = Get-Date
            GroupName = $GroupName
            Owner = $env:USERNAME
        }
        
        # Store process record in a group-specific file
        $GroupDir = "./.cursor/data/process-groups"
        New-Item -ItemType Directory -Path $GroupDir -Force | Out-Null
        
        $GroupFile = "$GroupDir/$GroupName.json"
        $GroupData = @()
        
        if (Test-Path $GroupFile) {
            $GroupData = Get-Content $GroupFile | ConvertFrom-Json
        }
        
        # Add current process to group data
        $GroupData += $ProcessRecord
        
        # Save updated group data
        $GroupData | ConvertTo-Json | Out-File $GroupFile -Force
        
        Write-ProcessLog "Process started with PID $($Process.Id), added to group '$GroupName'" "SUCCESS"
        
        # Wait for exit if requested
        if ($WaitForExit) {
            if ($TimeoutSeconds -gt 0) {
                $completed = $Process.WaitForExit($TimeoutSeconds * 1000)
                if (-not $completed) {
                    Write-ProcessLog "Process $($Process.Id) timed out after $TimeoutSeconds seconds" "WARNING"
                    return @{ Id = $Process.Id; TimedOut = $true }
                }
            } else {
                $Process.WaitForExit()
            }
            
            Write-ProcessLog "Process $($Process.Id) exited with code $($Process.ExitCode)" "INFO"
            return @{ Id = $Process.Id; ExitCode = $Process.ExitCode }
        } else {
            return @{ Id = $Process.Id }
        }
    } catch {
        Write-ProcessLog "Failed to start process $ProcessPath : $_" "ERROR"
        return $null
    }
}

function Stop-ManagedProcess {
    param(
        [Parameter(Mandatory=$true, ParameterSetName="ById")]
        [int]$ProcessId,
        
        [Parameter(Mandatory=$true, ParameterSetName="ByGroup")]
        [string]$GroupName,
        
        [switch]$Force,
        [int]$GracePeriodSeconds = 10
    )
    
    try {
        if ($PSCmdlet.ParameterSetName -eq "ByGroup") {
            # Stop all processes in a group
            $GroupFile = "./.cursor/data/process-groups/$GroupName.json"
            
            if (-not (Test-Path $GroupFile)) {
                Write-ProcessLog "Process group '$GroupName' not found" "WARNING"
                return $false
            }
            
            $GroupData = Get-Content $GroupFile | ConvertFrom-Json
            $Results = @()
            
            foreach ($ProcessRecord in $GroupData) {
                $StopResult = Stop-ManagedProcess -ProcessId $ProcessRecord.Id -Force:$Force -GracePeriodSeconds $GracePeriodSeconds
                $Results += @{
                    Id = $ProcessRecord.Id
                    Name = $ProcessRecord.Name
                    Result = $StopResult
                }
            }
            
            # Remove the group file
            Remove-Item $GroupFile -Force
            
            Write-ProcessLog "Stopped process group '$GroupName'" "SUCCESS"
            return $Results
        } else {
            # Stop a single process
            $Process = Get-Process -Id $ProcessId -ErrorAction SilentlyContinue
            
            if (-not $Process) {
                Write-ProcessLog "Process with ID $ProcessId not found" "WARNING"
                return $false
            }
            
            Write-ProcessLog "Stopping process $($Process.Name) (PID $ProcessId)" "INFO"
            
            if ($Force) {
                $Process.Kill()
                Write-ProcessLog "Process $ProcessId forcefully terminated" "SUCCESS"
                return $true
            } else {
                $Process.CloseMainWindow() | Out-Null
                
                # Wait for the process to exit gracefully
                $exitedGracefully = $Process.WaitForExit($GracePeriodSeconds * 1000)
                
                if (-not $exitedGracefully) {
                    Write-ProcessLog "Process $ProcessId did not exit within grace period, forcing termination" "WARNING"
                    $Process.Kill()
                }
                
                Write-ProcessLog "Process $ProcessId terminated" "SUCCESS"
                return $true
            }
        }
    } catch {
        Write-ProcessLog "Failed to stop process $ProcessId : $_" "ERROR"
        return $false
    }
}

function Get-ProcessGroups {
    $GroupDir = "./.cursor/data/process-groups"
    
    if (-not (Test-Path $GroupDir)) {
        return @()
    }
    
    $GroupFiles = Get-ChildItem "$GroupDir/*.json"
    $Groups = @()
    
    foreach ($File in $GroupFiles) {
        $GroupName = [System.IO.Path]::GetFileNameWithoutExtension($File.Name)
        $GroupData = Get-Content $File.FullName | ConvertFrom-Json
        
        $ActiveProcesses = @()
        
        foreach ($ProcessRecord in $GroupData) {
            # Check if process is still running
            if (Get-Process -Id $ProcessRecord.Id -ErrorAction SilentlyContinue) {
                $ActiveProcesses += $ProcessRecord
            }
        }
        
        $Groups += @{
            Name = $GroupName
            ProcessCount = $ActiveProcesses.Count
            Processes = $ActiveProcesses
            CreatedAt = $File.CreationTime
        }
    }
    
    return $Groups
}

function Invoke-EmergencyTermination {
    param(
        [Parameter(Mandatory=$true, ParameterSetName="ById")]
        [int]$ProcessId,
        
        [Parameter(Mandatory=$true, ParameterSetName="ByPattern")]
        [string]$NamePattern,
        
        [Parameter(Mandatory=$false)]
        [switch]$Force,
        
        [Parameter(Mandatory=$false)]
        [switch]$SkipValidation,
        
        [Parameter(Mandatory=$false)]
        [string]$Reason = "Emergency termination required"
    )
    
    try {
        # Check for cooldown period
        $EmergencyLogFile = "./.cursor/logs/emergency-actions.log"
        if (Test-Path $EmergencyLogFile) {
            $LastEmergencyAction = Get-Content $EmergencyLogFile | Select-Object -Last 1
            if ($LastEmergencyAction) {
                try {
                    $Timestamp = [datetime]::ParseExact($LastEmergencyAction.Substring(1, 19), "yyyy-MM-dd HH:mm:ss", $null)
                    $CooldownMinutes = $EmergencyConfig.EmergencyCooldownMinutes
                    $CooldownOver = $Timestamp.AddMinutes($CooldownMinutes) -lt (Get-Date)
                    
                    if (-not $CooldownOver) {
                        $TimeLeft = $Timestamp.AddMinutes($CooldownMinutes) - (Get-Date)
                        Write-ProcessLog "Emergency termination in cooldown period. $([math]::Round($TimeLeft.TotalMinutes, 1)) minutes left." "WARNING"
                        return @{
                            Success = $false
                            Reason = "Cooldown period active"
                            TimeLeft = $TimeLeft
                        }
                    }
                } catch {
                    # Ignore parsing errors
                }
            }
        }
        
        $ProcessesToTerminate = @()
        
        # Identify processes to terminate
        if ($PSCmdlet.ParameterSetName -eq "ById") {
            $Process = Get-Process -Id $ProcessId -ErrorAction SilentlyContinue
            if ($Process) {
                $ProcessesToTerminate += $Process
            } else {
                Write-ProcessLog "Process with ID $ProcessId not found" "ERROR"
                return @{
                    Success = $false
                    Reason = "Process not found"
                }
            }
        } else {
            $ProcessesToTerminate = Get-Process | Where-Object { $_.ProcessName -like $NamePattern }
            
            if ($ProcessesToTerminate.Count -eq 0) {
                Write-ProcessLog "No processes found matching pattern '$NamePattern'" "WARNING"
                return @{
                    Success = $false
                    Reason = "No matching processes"
                }
            }
        }
        
        # Validate that we're not terminating protected processes
        $ProtectedFound = $false
        $ProtectedProcesses = @()
        
        foreach ($Process in $ProcessesToTerminate) {
            if ($EmergencyConfig.ProtectedProcesses -contains $Process.ProcessName.ToLower()) {
                $ProtectedFound = $true
                $ProtectedProcesses += $Process
            }
        }
        
        if ($ProtectedFound -and -not $Force) {
            $ProtectedList = $ProtectedProcesses | ForEach-Object { "$($_.ProcessName) (PID $($_.Id))" } | Join-String -Separator ", "
            Write-ProcessLog "Termination aborted: Protected processes found: $ProtectedList" "ERROR"
            return @{
                Success = $false
                Reason = "Protected processes found"
                ProtectedProcesses = $ProtectedProcesses
            }
        }
        
        # Validate critical system services
        $ServicesToCheck = Get-Service | Where-Object { $EmergencyConfig.CriticalSystemServices -contains $_.Name }
        $CriticalProcessIds = @()
        
        foreach ($Service in $ServicesToCheck) {
            $ServicePID = (Get-WmiObject Win32_Service | Where-Object { $_.Name -eq $Service.Name }).ProcessId
            if ($ServicePID -gt 0) {
                $CriticalProcessIds += $ServicePID
            }
        }
        
        $CriticalFound = $false
        $CriticalProcesses = @()
        
        foreach ($Process in $ProcessesToTerminate) {
            if ($CriticalProcessIds -contains $Process.Id) {
                $CriticalFound = $true
                $CriticalProcesses += $Process
            }
        }
        
        if ($CriticalFound -and -not $Force) {
            $CriticalList = $CriticalProcesses | ForEach-Object { "$($_.ProcessName) (PID $($_.Id))" } | Join-String -Separator ", "
            Write-ProcessLog "Termination aborted: Critical system service processes found: $CriticalList" "ERROR"
            return @{
                Success = $false
                Reason = "Critical service processes found"
                CriticalProcesses = $CriticalProcesses
            }
        }
        
        # User validation for emergency termination
        if ($EmergencyConfig.ValidationPrompts -and -not $SkipValidation) {
            $ProcessList = $ProcessesToTerminate | ForEach-Object { "$($_.ProcessName) (PID $($_.Id))" } | Join-String -Separator "`n"
            Write-ProcessLog "WARNING: Preparing to terminate the following processes:" "WARNING"
            Write-ProcessLog $ProcessList "WARNING"
            
            $Confirmation = Read-Host "Are you sure you want to terminate these processes? (Y/N)"
            
            if ($Confirmation -ne "Y") {
                Write-ProcessLog "Termination aborted by user" "INFO"
                return @{
                    Success = $false
                    Reason = "User aborted"
                }
            }
            
            if ($EmergencyConfig.RequireKeywordConfirmation) {
                $KeywordConfirmation = Read-Host "Type '$($EmergencyConfig.ConfirmationKeyword)' to confirm emergency termination"
                
                if ($KeywordConfirmation -ne $EmergencyConfig.ConfirmationKeyword) {
                    Write-ProcessLog "Termination aborted: Invalid confirmation keyword" "ERROR"
                    return @{
                        Success = $false
                        Reason = "Invalid confirmation keyword"
                    }
                }
            }
        }
        
        # Log emergency action
        Write-ProcessLog "Executing emergency termination of $($ProcessesToTerminate.Count) processes. Reason: $Reason" "EMERGENCY"
        
        # Perform termination
        $Results = @()
        
        foreach ($Process in $ProcessesToTerminate) {
            try {
                $ProcessName = $Process.ProcessName
                $ProcessId = $Process.Id
                
                $Process.Kill()
                Write-ProcessLog "Terminated process $ProcessName (PID $ProcessId)" "EMERGENCY"
                
                $Results += @{
                    ProcessId = $ProcessId
                    ProcessName = $ProcessName
                    Success = $true
                }
            } catch {
                Write-ProcessLog "Failed to terminate process $($Process.ProcessName) (PID $($Process.Id)): $_" "ERROR"
                
                $Results += @{
                    ProcessId = $Process.Id
                    ProcessName = $Process.ProcessName
                    Success = $false
                    Error = $_.Exception.Message
                }
            }
        }
        
        # Return results
        return @{
            Success = ($Results | Where-Object { -not $_.Success }).Count -eq 0
            ProcessesTerminated = $Results.Count
            DetailedResults = $Results
        }
    } catch {
        Write-ProcessLog "Emergency termination failed: $_" "ERROR"
        return @{
            Success = $false
            Reason = "Exception occurred"
            Error = $_.Exception.Message
        }
    }
}

function Test-ProcessSafety {
    param(
        [Parameter(Mandatory=$true)]
        [int]$ProcessId
    )
    
    try {
        $Process = Get-Process -Id $ProcessId -ErrorAction SilentlyContinue
        
        if (-not $Process) {
            return @{
                IsSafe = $false
                Reason = "Process not found"
            }
        }
        
        # Check if it's a protected process
        if ($EmergencyConfig.ProtectedProcesses -contains $Process.ProcessName.ToLower()) {
            return @{
                IsSafe = $false
                Reason = "Protected system process"
                ProcessName = $Process.ProcessName
            }
        }
        
        # Check if it's a critical service process
        $ServicesToCheck = Get-Service | Where-Object { $EmergencyConfig.CriticalSystemServices -contains $_.Name }
        $CriticalProcessIds = @()
        
        foreach ($Service in $ServicesToCheck) {
            $ServicePID = (Get-WmiObject Win32_Service | Where-Object { $_.Name -eq $Service.Name }).ProcessId
            if ($ServicePID -gt 0) {
                $CriticalProcessIds += $ServicePID
            }
        }
        
        if ($CriticalProcessIds -contains $Process.Id) {
            $ServiceName = (Get-Service | Where-Object { 
                (Get-WmiObject Win32_Service | Where-Object { $_.Name -eq $Service.Name }).ProcessId -eq $Process.Id 
            }).DisplayName
            
            return @{
                IsSafe = $false
                Reason = "Critical system service"
                ServiceName = $ServiceName
            }
        }
        
        # All checks passed
        return @{
            IsSafe = $true
            ProcessName = $Process.ProcessName
        }
    } catch {
        Write-ProcessLog "Error checking process safety: $_" "ERROR"
        return @{
            IsSafe = $false
            Reason = "Error checking process safety"
            Error = $_.Exception.Message
        }
    }
}

# Validate config file exists or create default
$ConfigPath = "./.cursor/config/process-manager-config.json"
$ConfigDir = "./.cursor/config"

if (-not (Test-Path $ConfigDir)) {
    New-Item -ItemType Directory -Path $ConfigDir -Force | Out-Null
}

if (-not (Test-Path $ConfigPath)) {
    $Config = @{
        EmergencyConfig = $EmergencyConfig
    }
    
    $Config | ConvertTo-Json -Depth 3 | Out-File $ConfigPath -Force
    Write-ProcessLog "Created default process manager configuration" "INFO"
} else {
    # Load existing config
    try {
        $Config = Get-Content $ConfigPath | ConvertFrom-Json
        
        # Update EmergencyConfig if it exists in the file
        if ($Config.EmergencyConfig) {
            $EmergencyConfig = $Config.EmergencyConfig
        }
    } catch {
        Write-ProcessLog "Error loading configuration: $_" "ERROR"
    }
}

# Create data directory
$DataDir = "./.cursor/data/process-groups"
if (-not (Test-Path $DataDir)) {
    New-Item -ItemType Directory -Path $DataDir -Force | Out-Null
}

Write-ProcessLog "Process Manager initialized" "SUCCESS" 