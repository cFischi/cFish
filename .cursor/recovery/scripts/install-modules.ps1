# Script to install required PowerShell modules with error handling and resource management
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue' # Speeds up web requests

# Required modules with dependencies
$requiredModules = @(
    @{
        Name = "Microsoft.PowerShell.Management"
        MinVersion = "7.0.0"
        Dependencies = @()
        Essential = $true
    },
    @{
        Name = "Microsoft.PowerShell.Utility"
        MinVersion = "7.0.0"
        Dependencies = @()
        Essential = $true
    },
    @{
        Name = "ProcessTree"
        MinVersion = "1.0.0"
        Dependencies = @("Microsoft.PowerShell.Management")
        Essential = $false
    },
    @{
        Name = "ResourceMetrics"
        MinVersion = "1.0.0"
        Dependencies = @("Microsoft.PowerShell.Utility")
        Essential = $false
    }
)

# Configuration
$CONFIG = @{
    MinMemoryGB = 1.5          # Lowered from 2
    RetryAttempts = 3
    RetryDelaySeconds = 30
    InstallTimeout = 300
    MemoryCheckInterval = 3    # Lowered from 5
    MaxConcurrentInstalls = 2  # New: limit concurrent installations
    StageDelay = 10           # New: delay between installations
    EmergencyMemoryGB = 1.0   # New: emergency threshold
    ProcessLimit = 500        # New: process limit
}

function Test-AdminPrivileges {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Get-SystemMetrics {
    $os = Get-WmiObject Win32_OperatingSystem
    $metrics = @{
        FreePhysicalMemoryGB = [math]::Round(($os.FreePhysicalMemory / 1MB), 2)
        TotalPhysicalMemoryGB = [math]::Round(($os.TotalVisibleMemorySize / 1MB), 2)
        FreeVirtualMemoryGB = [math]::Round(($os.FreeVirtualMemory / 1MB), 2)
        ProcessCount = (Get-Process).Count
    }
    return $metrics
}

function Test-SystemResources {
    $metrics = Get-SystemMetrics
    $checks = @(
        @{
            Name = "Memory"
            Passed = $metrics.FreePhysicalMemoryGB -ge $CONFIG.MinMemoryGB
            Message = "Insufficient memory: $($metrics.FreePhysicalMemoryGB)GB available, $($CONFIG.MinMemoryGB)GB required"
        },
        @{
            Name = "Processes"
            Passed = $metrics.ProcessCount -lt $CONFIG.ProcessLimit
            Message = "High process count: $($metrics.ProcessCount) processes running"
        },
        @{
            Name = "PowerShell Processes"
            Passed = (Get-Process pwsh).Count -lt $CONFIG.MaxConcurrentInstalls
            Message = "Too many PowerShell processes running"
        }
    )
    
    # Emergency cleanup if memory is critically low
    if ($metrics.FreePhysicalMemoryGB -lt $CONFIG.EmergencyMemoryGB) {
        Write-Warning "Emergency memory cleanup triggered"
        [System.GC]::Collect()
        [System.GC]::WaitForPendingFinalizers()
        
        # Kill any hung PowerShell processes
        Get-Process pwsh | Where-Object {
            $_.StartTime -lt (Get-Date).AddSeconds(-$CONFIG.InstallTimeout)
        } | ForEach-Object {
            Write-Warning "Terminating hung PowerShell process: $($_.Id)"
            $_ | Stop-Process -Force
        }
    }
    
    $failed = $checks | Where-Object { -not $_.Passed }
    if ($failed) {
        foreach ($check in $failed) {
            Write-Warning $check.Message
        }
        return $false
    }
    return $true
}

function Install-RequiredModule {
    param (
        [Parameter(Mandatory=$true)]
        [string]$ModuleName,
        [string]$MinVersion,
        [string[]]$Dependencies,
        [bool]$Essential = $false
    )
    
    try {
        Write-Host "Processing module: $ModuleName..."
        
        # Check dependencies first
        foreach ($dep in $Dependencies) {
            $depModule = $requiredModules | Where-Object { $_.Name -eq $dep }
            if ($depModule -and -not (Install-RequiredModule @depModule)) {
                throw "Dependency $dep installation failed"
            }
        }
        
        # Check if module is already installed with correct version
        $module = Get-Module -Name $ModuleName -ListAvailable | 
            Where-Object { $MinVersion -eq $null -or $_.Version -ge $MinVersion }
            
        if ($module) {
            Write-Host "✓ Module $ModuleName is already installed with version $($module.Version)" -ForegroundColor Green
            return $true
        }

        # Wait if too many PowerShell processes
        while ((Get-Process pwsh).Count -ge $CONFIG.MaxConcurrentInstalls) {
            Write-Host "Waiting for other installations to complete..."
            Start-Sleep -Seconds $CONFIG.StageDelay
        }

        # Verify system resources
        if (-not (Test-SystemResources)) {
            if ($Essential) {
                Write-Warning "Retrying essential module installation after delay..."
                Start-Sleep -Seconds $CONFIG.RetryDelaySeconds
            } else {
                Write-Warning "Skipping non-essential module due to resource constraints"
                return $false
            }
        }

        # Installation with retry logic
        $attempt = 1
        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
        
        while ($attempt -le $CONFIG.RetryAttempts -and $stopwatch.Elapsed.TotalSeconds -lt $CONFIG.InstallTimeout) {
            try {
                Write-Host "Installing $ModuleName (Attempt $attempt/$($CONFIG.RetryAttempts))..." -NoNewline
                
                # Use -Force only for essential modules
                $params = @{
                    Name = $ModuleName
                    Scope = "CurrentUser"
                    AllowClobber = $true
                }
                if ($Essential) {
                    $params.Force = $true
                }
                
                Install-Module @params
                
                # Verify installation
                $installed = Get-Module -Name $ModuleName -ListAvailable |
                    Where-Object { $MinVersion -eq $null -or $_.Version -ge $MinVersion }
                
                if ($installed) {
                    Write-Host "✓ Success!" -ForegroundColor Green
                    return $true
                }
                
                throw "Module verification failed"
            }
            catch {
                Write-Host "✗ Failed!" -ForegroundColor Red
                Write-Warning "Attempt $attempt failed: $_"
                
                if ($attempt -lt $CONFIG.RetryAttempts) {
                    Write-Host "Waiting $($CONFIG.RetryDelaySeconds) seconds before retry..."
                    Start-Sleep -Seconds $CONFIG.RetryDelaySeconds
                }
                $attempt++
            }
            
            # Check system resources periodically
            if ($attempt -le $CONFIG.RetryAttempts) {
                Start-Sleep -Seconds $CONFIG.MemoryCheckInterval
                if (-not (Test-SystemResources)) {
                    if (-not $Essential) {
                        Write-Warning "Skipping non-essential module due to resource constraints"
                        return $false
                    }
                }
            }
        }
        
        if ($Essential) {
            throw "Essential module installation failed after $($CONFIG.RetryAttempts) attempts"
        } else {
            Write-Warning "Non-essential module installation failed after $($CONFIG.RetryAttempts) attempts"
            return $false
        }
    }
    catch {
        Write-Error "Failed to install module $ModuleName. Error: $_"
        if ($Essential) {
            throw
        }
        return $false
    }
}

function Start-ModuleInstallation {
    if (-not (Test-AdminPrivileges)) {
        Write-Warning "Script is not running with administrator privileges. Some operations may fail."
    }

    # Set TLS 1.2 for PowerShell Gallery
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    # Initialize NuGet package provider if needed
    if (-not (Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue)) {
        try {
            Write-Host "Installing NuGet package provider..." -NoNewline
            Install-PackageProvider -Name NuGet -Force -Scope CurrentUser | Out-Null
            Write-Host "✓ Done!" -ForegroundColor Green
        }
        catch {
            Write-Error "Failed to install NuGet package provider. Error: $_"
            return $false
        }
    }

    # Install required modules
    $failed = @()
    foreach ($module in $requiredModules) {
        if (-not (Install-RequiredModule @module)) {
            $failed += $module.Name
        }
    }

    if ($failed.Count -gt 0) {
        Write-Error "Failed to install the following modules: $($failed -join ', ')"
        return $false
    }

    Write-Host "`n✓ All required modules have been installed successfully!" -ForegroundColor Green
    return $true
}

# Main execution
try {
    Write-Host "Starting module installation with system checks...`n"
    
    # Initial system check
    if (-not (Test-SystemResources)) {
        Write-Warning "System resource check failed. Installation may be unstable."
        Start-Sleep -Seconds 5
    }
    
    $result = Start-ModuleInstallation
    if (-not $result) {
        exit 1
    }
}
catch {
    Write-Error "An unexpected error occurred: $_"
    exit 1
} 