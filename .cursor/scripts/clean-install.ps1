# Clean Installation Script
# Handles clean installation with proper error handling and resource monitoring

# Import required modules
$ProcessManagerPath = Join-Path $PSScriptRoot "process-manager.ps1"
. $ProcessManagerPath

function Test-SystemResources {
    Write-ProcessLog "Checking system resources..."
    
    # Get total and free memory
    $computerSystem = Get-CimInstance CIM_ComputerSystem
    $operatingSystem = Get-CimInstance CIM_OperatingSystem
    $freeMemoryGB = [math]::Round($operatingSystem.FreePhysicalMemory / 1MB, 2)
    $totalMemoryGB = [math]::Round($computerSystem.TotalPhysicalMemory / 1GB, 2)
    
    # Get CPU usage
    $cpuUsage = (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue
    
    # Get free disk space
    $disk = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='C:'"
    $freeDiskGB = [math]::Round($disk.FreeSpace / 1GB, 2)
    
    Write-ProcessLog "System Resources:"
    Write-ProcessLog "- Free Memory: $freeMemoryGB GB / $totalMemoryGB GB"
    Write-ProcessLog "- CPU Usage: $([math]::Round($cpuUsage, 2))%"
    Write-ProcessLog "- Free Disk Space: $freeDiskGB GB"
    
    # Check against thresholds
    $checks = @{
        Memory = $freeMemoryGB -ge 2
        CPU = $cpuUsage -lt 80
        Disk = $freeDiskGB -ge 1
    }
    
    return $checks
}

function Start-CleanInstallation {
    try {
        Write-ProcessLog "Starting clean installation process..."
        
        # Check system resources
        $resources = Test-SystemResources
        if (-not ($resources.Memory -and $resources.CPU -and $resources.Disk)) {
            throw "System resources below required thresholds"
        }
        
        # Clean up existing installation
        Write-ProcessLog "Cleaning up existing installation..."
        if (Test-Path "node_modules") {
            Remove-Item -Recurse -Force "node_modules"
        }
        if (Test-Path "package-lock.json") {
            Remove-Item -Force "package-lock.json"
        }
        
        # Clear npm cache
        Write-ProcessLog "Clearing npm cache..."
        $result = Start-NpmProcess -Arguments "cache clean --force" -TimeoutSeconds 60
        if (-not $result) {
            throw "Failed to clear npm cache"
        }
        
        # Verify Windows SDK
        Write-ProcessLog "Checking Windows SDK installation..."
        $sdk = Get-CimInstance -ClassName Win32_Product | Where-Object { $_.Name -like "*Windows SDK*" }
        if (-not $sdk) {
            Write-ProcessLog "WARNING: Windows SDK not detected. Some native modules may fail to build."
        }
        
        # Start staged installation
        Write-ProcessLog "Starting staged installation..."
        $stagingScript = Join-Path $PSScriptRoot "staged-installer.js"
        if (-not (Test-Path $stagingScript)) {
            throw "Staged installer script not found: $stagingScript"
        }
        
        # Run staged installation
        $result = Start-NpmProcess -Arguments "run staged-install" -TimeoutSeconds 600
        if (-not $result) {
            throw "Staged installation failed"
        }
        
        Write-ProcessLog "Clean installation completed successfully"
        return $true
        
    } catch {
        Write-ProcessLog "Clean installation failed: $_" -Level "ERROR"
        return $false
    }
}

# Execute clean installation
$success = Start-CleanInstallation
if ($success) {
    Write-Host "Clean installation completed successfully" -ForegroundColor Green
    exit 0
} else {
    Write-Host "Clean installation failed. Check logs for details." -ForegroundColor Red
    exit 1
} 