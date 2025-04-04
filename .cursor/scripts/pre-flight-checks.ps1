# Pre-Flight Checks for Installation
# Purpose: Verify system resources and environment before installation

$VerbosePreference = "Continue"
$ErrorActionPreference = "Stop"

# Create log directory if it doesn't exist
$LogDir = "./.cursor/logs"
New-Item -ItemType Directory -Path $LogDir -Force | Out-Null

$LogFile = "$LogDir/pre-flight-checks-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"

# Configuration
$MinimumFreeMemoryGB = 2.0
$MinimumDiskSpaceGB = 5.0
$MaxProcessCount = 200
$CriticalServices = @("WinRM", "Spooler", "wuauserv")
$ProtectedProcesses = @("explorer", "svchost", "lsass", "csrss", "wininit", "services", "smss")

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

function Test-SystemResources {
    try {
        Write-Log "Checking system resources..." "INFO"
        
        # Check memory
        $computerInfo = Get-ComputerInfo
        $totalMemoryGB = [math]::Round($computerInfo.OsTotalVisibleMemorySize / 1MB, 2)
        $freeMemoryGB = [math]::Round($computerInfo.OsFreePhysicalMemory / 1MB, 2)
        $memoryPercentFree = [math]::Round(($freeMemoryGB / $totalMemoryGB) * 100, 2)
        
        Write-Log "Total Memory: $totalMemoryGB GB" "INFO"
        Write-Log "Free Memory: $freeMemoryGB GB" "INFO"
        Write-Log "Memory Percent Free: $memoryPercentFree%" "INFO"
        
        # Check disk space
        $systemDrive = $env:SystemDrive
        $driveLetter = $systemDrive.TrimEnd(":")
        $disk = Get-PSDrive $driveLetter
        $freeSpaceGB = [math]::Round($disk.Free / 1GB, 2)
        $totalSpaceGB = [math]::Round(($disk.Used + $disk.Free) / 1GB, 2)
        $diskPercentFree = [math]::Round(($freeSpaceGB / $totalSpaceGB) * 100, 2)
        
        Write-Log "System Drive: $systemDrive" "INFO"
        Write-Log "Free Disk Space: $freeSpaceGB GB" "INFO"
        Write-Log "Disk Percent Free: $diskPercentFree%" "INFO"
        
        # Check process count
        $processCount = (Get-Process).Count
        Write-Log "Current Process Count: $processCount" "INFO"
        
        # Check current CPU usage
        try {
            $cpuLoad = (Get-CimInstance -ClassName Win32_Processor | Measure-Object -Property LoadPercentage -Average).Average
            Write-Log "Current CPU Load: $cpuLoad%" "INFO"
        } catch {
            Write-Log "Unable to get CPU load: $_" "WARNING"
            $cpuLoad = 0
        }
        
        # Create result object
        $result = @{
            Passed = $true
            MemoryStatus = if ($freeMemoryGB -ge $MinimumFreeMemoryGB) { "PASS" } else { "FAIL" }
            DiskStatus = if ($freeSpaceGB -ge $MinimumDiskSpaceGB) { "PASS" } else { "FAIL" }
            ProcessStatus = if ($processCount -le $MaxProcessCount) { "PASS" } else { "WARNING" }
            CpuStatus = if ($cpuLoad -le 70) { "PASS" } else { "WARNING" }
            Details = @{
                TotalMemoryGB = $totalMemoryGB
                FreeMemoryGB = $freeMemoryGB
                MemoryPercentFree = $memoryPercentFree
                FreeSpaceGB = $freeSpaceGB
                DiskPercentFree = $diskPercentFree
                ProcessCount = $processCount
                CpuLoad = $cpuLoad
            }
        }
        
        # Determine overall status
        if ($result.MemoryStatus -eq "FAIL" -or $result.DiskStatus -eq "FAIL") {
            $result.Passed = $false
            Write-Log "Pre-flight check FAILED. Insufficient system resources." "ERROR"
        } elseif ($result.ProcessStatus -eq "WARNING" -or $result.CpuStatus -eq "WARNING") {
            Write-Log "Pre-flight check PASSED with WARNINGS. System resources may be constrained." "WARNING"
        } else {
            Write-Log "Pre-flight check PASSED. System resources are sufficient." "INFO"
        }
        
        return $result
    }
    catch {
        Write-Log "Error checking system resources: $_" "ERROR"
        return @{
            Passed = $false
            Error = $_.ToString()
        }
    }
}

function Test-ServicesStatus {
    try {
        Write-Log "Checking critical services..." "INFO"
        
        $servicesStatus = @{}
        
        foreach ($service in $CriticalServices) {
            try {
                $serviceObj = Get-Service -Name $service -ErrorAction SilentlyContinue
                if ($serviceObj) {
                    $status = $serviceObj.Status.ToString()
                    $servicesStatus[$service] = $status
                    Write-Log "Service $service: $status" "INFO"
                } else {
                    $servicesStatus[$service] = "Not Found"
                    Write-Log "Service $service not found" "WARNING"
                }
            } catch {
                $servicesStatus[$service] = "Error"
                Write-Log "Error checking service $service: $_" "WARNING"
            }
        }
        
        return @{
            Passed = $true
            Details = $servicesStatus
        }
    }
    catch {
        Write-Log "Error checking services: $_" "ERROR"
        return @{
            Passed = $false
            Error = $_.ToString()
        }
    }
}

function Test-InstallationProcesses {
    try {
        Write-Log "Checking for existing installation processes..." "INFO"
        
        $npmProcesses = Get-Process -Name "npm" -ErrorAction SilentlyContinue
        $nodeProcesses = Get-Process -Name "node" -ErrorAction SilentlyContinue | Where-Object { $_.Path -match "node_modules" }
        
        $installationProcesses = @{
            NpmCount = if ($npmProcesses) { $npmProcesses.Count } else { 0 }
            NodeModulesCount = if ($nodeProcesses) { $nodeProcesses.Count } else { 0 }
            Details = @()
        }
        
        if ($npmProcesses) {
            foreach ($process in $npmProcesses) {
                try {
                    $detail = @{
                        Id = $process.Id
                        StartTime = $process.StartTime
                        RunningFor = (Get-Date) - $process.StartTime
                        WorkingSetMB = [math]::Round($process.WorkingSet64 / 1MB, 2)
                        CPUTime = $process.TotalProcessorTime
                    }
                    $installationProcesses.Details += $detail
                    Write-Log "NPM Process ID $($process.Id) running for $($detail.RunningFor)" "INFO"
                } catch {
                    Write-Log "Error processing npm process details: $_" "WARNING"
                }
            }
        }
        
        $result = @{
            Passed = ($installationProcesses.NpmCount -eq 0 -and $installationProcesses.NodeModulesCount -eq 0)
            Details = $installationProcesses
        }
        
        if (-not $result.Passed) {
            Write-Log "Found existing installation processes. These should be terminated before proceeding." "WARNING"
        } else {
            Write-Log "No existing installation processes found." "INFO"
        }
        
        return $result
    }
    catch {
        Write-Log "Error checking installation processes: $_" "ERROR"
        return @{
            Passed = $false
            Error = $_.ToString()
        }
    }
}

function Get-ModuleAvailability {
    try {
        Write-Log "Checking PowerShell module availability..." "INFO"
        
        $requiredModules = @(
            "Microsoft.PowerShell.Management",
            "Microsoft.PowerShell.Utility"
        )
        
        $optionalModules = @(
            "ProcessTree",
            "ResourceMetrics"
        )
        
        $moduleStatus = @{
            Required = @{}
            Optional = @{}
        }
        
        foreach ($module in $requiredModules) {
            $isAvailable = Get-Module -Name $module -ListAvailable
            $moduleStatus.Required[$module] = if ($isAvailable) { $true } else { $false }
            Write-Log "Required module $module: $(if ($isAvailable) { 'Available' } else { 'Not Available' })" "INFO"
        }
        
        foreach ($module in $optionalModules) {
            $isAvailable = Get-Module -Name $module -ListAvailable
            $moduleStatus.Optional[$module] = if ($isAvailable) { $true } else { $false }
            Write-Log "Optional module $module: $(if ($isAvailable) { 'Available' } else { 'Not Available' })" "INFO"
        }
        
        $result = @{
            Passed = -not ($moduleStatus.Required.Values -contains $false)
            Details = $moduleStatus
        }
        
        if (-not $result.Passed) {
            Write-Log "Some required PowerShell modules are missing." "ERROR"
        } else {
            Write-Log "All required PowerShell modules are available." "INFO"
        }
        
        return $result
    }
    catch {
        Write-Log "Error checking module availability: $_" "ERROR"
        return @{
            Passed = $false
            Error = $_.ToString()
        }
    }
}

function Reserve-SystemResources {
    param(
        [double]$MemoryReservationGB = 1.0,
        [int]$CpuReservationPercent = 50
    )
    try {
        Write-Log "Reserving system resources..." "INFO"
        Write-Log "Memory Reservation: $MemoryReservationGB GB" "INFO"
        Write-Log "CPU Reservation: $CpuReservationPercent%" "INFO"
        
        $computerInfo = Get-ComputerInfo
        $totalMemoryGB = [math]::Round($computerInfo.OsTotalVisibleMemorySize / 1MB, 2)
        $freeMemoryGB = [math]::Round($computerInfo.OsFreePhysicalMemory / 1MB, 2)
        
        if ($freeMemoryGB -lt ($MemoryReservationGB + 0.5)) {
            Write-Log "Insufficient memory to make reservation. Available: $freeMemoryGB GB, Requested: $MemoryReservationGB GB" "WARNING"
            return $false
        }
        
        # Create a reservation file to mark the resources as reserved
        $reservationId = [Guid]::NewGuid().ToString()
        $reservationFile = "$LogDir/resource-reservation-$reservationId.json"
        
        $reservation = @{
            Id = $reservationId
            TimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            MemoryReservationGB = $MemoryReservationGB
            CpuReservationPercent = $CpuReservationPercent
            ExpireTime = (Get-Date).AddHours(1)
            Status = "Active"
        }
        
        $reservation | ConvertTo-Json | Set-Content -Path $reservationFile
        Write-Log "Resource reservation created with ID: $reservationId" "INFO"
        Write-Log "Reservation file: $reservationFile" "INFO"
        
        return $reservationId
    }
    catch {
        Write-Log "Error reserving system resources: $_" "ERROR"
        return $null
    }
}

function Release-SystemResources {
    param(
        [string]$ReservationId
    )
    try {
        if (-not $ReservationId) {
            Write-Log "No reservation ID provided" "WARNING"
            return $false
        }
        
        Write-Log "Releasing system resource reservation: $ReservationId" "INFO"
        
        $reservationFile = "$LogDir/resource-reservation-$ReservationId.json"
        if (Test-Path $reservationFile) {
            $reservation = Get-Content -Path $reservationFile | ConvertFrom-Json
            $reservation.Status = "Released"
            $reservation.ReleaseTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            $reservation | ConvertTo-Json | Set-Content -Path $reservationFile
            
            Write-Log "Resource reservation released: $ReservationId" "INFO"
            return $true
        } else {
            Write-Log "Reservation file not found: $reservationFile" "WARNING"
            return $false
        }
    }
    catch {
        Write-Log "Error releasing system resources: $_" "ERROR"
        return $false
    }
}

function Run-PreFlightChecks {
    try {
        Write-Log "Starting pre-flight checks..." "INFO"
        
        $results = @{
            SystemResources = Test-SystemResources
            ServicesStatus = Test-ServicesStatus
            InstallationProcesses = Test-InstallationProcesses
            ModuleAvailability = Get-ModuleAvailability
            TimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            OverallStatus = "PASS"
        }
        
        # Determine overall status
        if (-not $results.SystemResources.Passed -or 
            -not $results.ModuleAvailability.Passed) {
            $results.OverallStatus = "FAIL"
            Write-Log "Pre-flight checks FAILED" "ERROR"
        } elseif (-not $results.InstallationProcesses.Passed) {
            $results.OverallStatus = "WARNING"
            Write-Log "Pre-flight checks PASSED with WARNINGS" "WARNING"
        } else {
            Write-Log "All pre-flight checks PASSED" "INFO"
        }
        
        # Export results
        $resultsFile = "$LogDir/pre-flight-results-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
        $results | ConvertTo-Json -Depth 10 | Set-Content -Path $resultsFile
        Write-Log "Pre-flight check results exported to $resultsFile" "INFO"
        
        # If passed, create resource reservation
        if ($results.OverallStatus -ne "FAIL") {
            $reservationId = Reserve-SystemResources -MemoryReservationGB 1.5 -CpuReservationPercent 60
            if ($reservationId) {
                $results.ReservationId = $reservationId
                Write-Log "Resource reservation created: $reservationId" "INFO"
                
                # Update the results file with reservation ID
                $results | ConvertTo-Json -Depth 10 | Set-Content -Path $resultsFile
            }
        }
        
        return $results
    }
    catch {
        Write-Log "Critical error during pre-flight checks: $_" "ERROR"
        Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
        return @{
            OverallStatus = "FAIL"
            Error = $_.ToString()
            TimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }
    }
}

# Main execution
try {
    $results = Run-PreFlightChecks
    Write-Log "Pre-flight check overall status: $($results.OverallStatus)" "INFO"
    
    # Return the exit code based on the result
    if ($results.OverallStatus -eq "FAIL") {
        Write-Log "Exiting with failure code" "ERROR"
        exit 1
    } else {
        Write-Log "Pre-flight checks completed successfully" "INFO"
        exit 0
    }
}
catch {
    Write-Log "Unhandled exception during pre-flight checks: $_" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    exit 1
} 