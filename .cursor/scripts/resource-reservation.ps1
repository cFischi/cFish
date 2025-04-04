# Resource Reservation System
# Prevents resource exhaustion by monitoring and reserving system resources

# Parameter parsing
param (
    [Parameter(Mandatory=$false)]
    [string]$Action,
    
    [Parameter(Mandatory=$false)]
    [string]$ReservationName,
    
    [Parameter(Mandatory=$false)]
    [double]$MemoryGB = 0.5,
    
    [Parameter(Mandatory=$false)]
    [int]$CpuCores = 1,
    
    [Parameter(Mandatory=$false)]
    [double]$DiskSpaceGB = 0.1,
    
    [Parameter(Mandatory=$false)]
    [hashtable]$UpdateConfig
)

$VerbosePreference = "Continue"
$ErrorActionPreference = "Stop"

# Create log directory if it doesn't exist
$LogDir = "./.cursor/logs"
New-Item -ItemType Directory -Path $LogDir -Force | Out-Null

$LogFile = "$LogDir/resource-reservation-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"

# Configuration
$ReservationFile = "./.cursor/data/resource-reservations.json"
$DataDir = "./.cursor/data"
New-Item -ItemType Directory -Path $DataDir -Force | Out-Null

# Default resource allocations (percentage of available)
$DefaultReservations = @{
    "MemoryPercent" = 15  # Reserve 15% of system memory for critical processes
    "CpuPercent" = 20     # Reserve 20% of CPU for critical processes
    "DiskSpacePercent" = 10  # Reserve 10% of disk space
    "HandlesPercent" = 15    # Reserve 15% of system handles
    "ProcessCountMax" = 20   # Maximum number of new processes to spawn
}

# Initialize with default values if no reservation file exists
if (-not (Test-Path $ReservationFile)) {
    $DefaultReservations | ConvertTo-Json | Out-File $ReservationFile -Encoding utf8
}

function Write-Log {
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
    
    # Write to log file
    Add-Content -Path $LogFile -Value $LogMessage
}

function Get-CurrentReservations {
    try {
        if (Test-Path $ReservationFile) {
            $reservations = Get-Content $ReservationFile -Raw | ConvertFrom-Json
            return $reservations
        } else {
            Write-Log "No reservation file found, using defaults" "WARNING"
            return $DefaultReservations
        }
    } catch {
        Write-Log "Error reading reservations: $_" "ERROR"
        return $DefaultReservations
    }
}

function Update-Reservations {
    param (
        [hashtable]$NewReservations
    )
    
    try {
        $current = Get-CurrentReservations
        $currentHashTable = @{}
        
        # Convert PSCustomObject to hashtable
        if ($current -is [PSCustomObject]) {
            $current.PSObject.Properties | ForEach-Object {
                $currentHashTable[$_.Name] = $_.Value
            }
        } else {
            $currentHashTable = $current
        }
        
        # Update only the values that are provided
        foreach ($key in $NewReservations.Keys) {
            $currentHashTable[$key] = $NewReservations[$key]
        }
        
        # Save updated reservations
        $currentHashTable | ConvertTo-Json | Out-File $ReservationFile -Encoding utf8
        Write-Log "Updated resource reservations" "SUCCESS"
        return $true
    } catch {
        Write-Log "Failed to update reservations: $_" "ERROR"
        return $false
    }
}

function Get-SystemResources {
    # Get memory info
    $ComputerInfo = Get-CimInstance Win32_OperatingSystem
    $TotalMemory = [math]::Round($ComputerInfo.TotalVisibleMemorySize / 1MB, 2)
    $FreeMemory = [math]::Round($ComputerInfo.FreePhysicalMemory / 1MB, 2)
    
    # Get CPU info
    $CpuLoad = (Get-CimInstance Win32_Processor | Measure-Object -Property LoadPercentage -Average).Average
    
    # Get disk info
    $SystemDrive = $env:SystemDrive
    # Fix: Properly handle drive letter
    $DriveLetter = $SystemDrive.TrimEnd(":")
    $DiskInfo = Get-PSDrive $DriveLetter
    $TotalDiskSpace = [math]::Round($DiskInfo.Used / 1GB + $DiskInfo.Free / 1GB, 2)
    $FreeDiskSpace = [math]::Round($DiskInfo.Free / 1GB, 2)
    
    # Get process info
    $ProcessCount = (Get-Process).Count
    $HandleCount = (Get-Process | Measure-Object -Property HandleCount -Sum).Sum
    
    return @{
        "TotalMemoryGB" = $TotalMemory
        "FreeMemoryGB" = $FreeMemory
        "CpuUsagePercent" = $CpuLoad
        "TotalDiskSpaceGB" = $TotalDiskSpace
        "FreeDiskSpaceGB" = $FreeDiskSpace
        "ProcessCount" = $ProcessCount
        "HandleCount" = $HandleCount
    }
}

function Reserve-Resources {
    param (
        [string]$ReservationName,
        [double]$MemoryGB,
        [int]$CpuCores = 0,
        [double]$DiskSpaceGB = 0
    )
    
    $resources = Get-SystemResources
    $reservations = Get-CurrentReservations
    
    # Calculate reserved amounts
    $ReservedMemoryGB = $resources.TotalMemoryGB * ($reservations.MemoryPercent / 100)
    $ReservedCpu = $env:NUMBER_OF_PROCESSORS * ($reservations.CpuPercent / 100)
    $ReservedDiskGB = $resources.TotalDiskSpaceGB * ($reservations.DiskSpacePercent / 100)
    
    # Calculate available resources (after system reservations)
    $AvailableMemoryGB = $resources.FreeMemoryGB - $ReservedMemoryGB
    $AvailableCpu = $env:NUMBER_OF_PROCESSORS - $ReservedCpu
    $AvailableDiskGB = $resources.FreeDiskSpaceGB - $ReservedDiskGB
    
    # Check if requested resources are available
    $MemoryOk = $AvailableMemoryGB -ge $MemoryGB
    $CpuOk = $AvailableCpu -ge $CpuCores
    $DiskOk = $AvailableDiskGB -ge $DiskSpaceGB
    
    $AllOk = $MemoryOk -and $CpuOk -and $DiskOk
    
    # Create reservation data object
    $ReservationData = @{
        "Name" = $ReservationName
        "Timestamp" = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        "MemoryGB" = $MemoryGB
        "CpuCores" = $CpuCores
        "DiskSpaceGB" = $DiskSpaceGB
        "Approved" = $AllOk
        "ExpiresAt" = (Get-Date).AddHours(1) # Default expiration is 1 hour
    }
    
    # Store active reservations
    $ActiveReservationsFile = "./.cursor/data/active-reservations.json"
    $ActiveReservations = @()
    
    if (Test-Path $ActiveReservationsFile) {
        try {
            $ActiveReservations = Get-Content $ActiveReservationsFile -Raw | ConvertFrom-Json
            
            # Filter out expired reservations
            $CurrentTime = Get-Date
            $ActiveReservations = $ActiveReservations | Where-Object {
                (Get-Date $_.ExpiresAt) -gt $CurrentTime
            }
        } catch {
            Write-Log "Error reading active reservations, starting fresh" "WARNING"
            $ActiveReservations = @()
        }
    }
    
    # Add new reservation if approved
    if ($AllOk) {
        if ($ActiveReservations -is [array]) {
            $ActiveReservations += $ReservationData
        } else {
            $ActiveReservations = @($ActiveReservations, $ReservationData)
        }
        
        $ActiveReservations | ConvertTo-Json | Out-File $ActiveReservationsFile -Encoding utf8
        
        Write-Log "Resource reservation '$ReservationName' approved" "SUCCESS"
        Write-Log "Reserved: ${MemoryGB}GB memory, $CpuCores CPU cores, ${DiskSpaceGB}GB disk" "INFO"
    } else {
        $Message = "Resource reservation '$ReservationName' denied. "
        if (-not $MemoryOk) { $Message += "Insufficient memory (requested: ${MemoryGB}GB, available: ${AvailableMemoryGB}GB). " }
        if (-not $CpuOk) { $Message += "Insufficient CPU cores (requested: $CpuCores, available: $AvailableCpu). " }
        if (-not $DiskOk) { $Message += "Insufficient disk space (requested: ${DiskSpaceGB}GB, available: ${AvailableDiskGB}GB). " }
        
        Write-Log $Message "ERROR"
    }
    
    return @{
        "Approved" = $AllOk
        "ResourceData" = $ReservationData
        "AvailableResources" = @{
            "MemoryGB" = $AvailableMemoryGB
            "CpuCores" = $AvailableCpu
            "DiskSpaceGB" = $AvailableDiskGB
        }
    }
}

function Release-Resources {
    param (
        [string]$ReservationName
    )
    
    $ActiveReservationsFile = "./.cursor/data/active-reservations.json"
    
    if (-not (Test-Path $ActiveReservationsFile)) {
        Write-Log "No active reservations file found" "WARNING"
        return $false
    }
    
    try {
        $ActiveReservations = Get-Content $ActiveReservationsFile -Raw | ConvertFrom-Json
        
        # Filter out the reservation to release
        $FilteredReservations = $ActiveReservations | Where-Object { $_.Name -ne $ReservationName }
        
        if ($FilteredReservations.Count -eq $ActiveReservations.Count) {
            Write-Log "Reservation '$ReservationName' not found" "WARNING"
            return $false
        }
        
        # Save updated reservations
        $FilteredReservations | ConvertTo-Json | Out-File $ActiveReservationsFile -Encoding utf8
        
        Write-Log "Released resources for '$ReservationName'" "SUCCESS"
        return $true
    } catch {
        Write-Log "Error releasing resources: $_" "ERROR"
        return $false
    }
}

function Get-ActiveReservations {
    $ActiveReservationsFile = "./.cursor/data/active-reservations.json"
    
    if (-not (Test-Path $ActiveReservationsFile)) {
        Write-Log "No active reservations file found" "INFO"
        return @()
    }
    
    try {
        $ActiveReservations = Get-Content $ActiveReservationsFile -Raw | ConvertFrom-Json
        
        # Filter out expired reservations
        $CurrentTime = Get-Date
        $ActiveReservations = $ActiveReservations | Where-Object {
            (Get-Date $_.ExpiresAt) -gt $CurrentTime
        }
        
        return $ActiveReservations
    } catch {
        Write-Log "Error reading active reservations: $_" "ERROR"
        return @()
    }
}

# Main execution
try {
    Write-Log "Resource Reservation System started" "INFO"
    Write-Log "Action: $Action, ReservationName: $ReservationName" "INFO"
    
    $currentResources = Get-SystemResources
    Write-Log "Current system resources: $($currentResources | ConvertTo-Json -Compress)" "INFO"
    
    switch ($Action) {
        "reserve" {
            if (-not $ReservationName) {
                Write-Log "ReservationName is required for reserve action" "ERROR"
                exit 1
            }
            
            $result = Reserve-Resources -ReservationName $ReservationName -MemoryGB $MemoryGB -CpuCores $CpuCores -DiskSpaceGB $DiskSpaceGB
            
            if (-not $result.Approved) {
                exit 1
            }
        }
        "release" {
            if (-not $ReservationName) {
                Write-Log "ReservationName is required for release action" "ERROR"
                exit 1
            }
            
            $result = Release-Resources -ReservationName $ReservationName
            
            if (-not $result) {
                exit 1
            }
        }
        "list" {
            $reservations = Get-ActiveReservations
            Write-Log "Active reservations: $($reservations | ConvertTo-Json -Compress)" "INFO"
        }
        "update-config" {
            if (-not $UpdateConfig) {
                Write-Log "UpdateConfig is required for update-config action" "ERROR"
                exit 1
            }
            
            $result = Update-Reservations -NewReservations $UpdateConfig
            
            if (-not $result) {
                exit 1
            }
        }
        default {
            # Just output current state
            $reservations = Get-CurrentReservations
            $active = Get-ActiveReservations
            
            Write-Log "Resource reservation configuration: $($reservations | ConvertTo-Json -Compress)" "INFO"
            Write-Log "Active reservations: $($active | ConvertTo-Json -Compress)" "INFO"
        }
    }
    
    Write-Log "Resource Reservation System completed successfully" "SUCCESS"
    exit 0
} catch {
    Write-Log "Error in Resource Reservation System: $_" "ERROR"
    exit 1
} 