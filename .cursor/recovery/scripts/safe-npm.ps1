# safe-npm.ps1
# Wrapper script for safe npm operations with memory management

# Configuration
$CONFIG = @{
    MaxRetries = 3
    RetryDelay = 30
    MemoryThreshold = 1.5  # Lowered from 2GB
    ProcessLimit = 500     # Lowered from 1000
    TimeoutSeconds = 300
    StageDelay = 10       # Delay between installation stages
    ChunkSize = 10        # Number of packages to install at once
}

# Import required modules
$ErrorActionPreference = 'Stop'
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path

# Ensure memory manager module exists
$memoryManagerPath = Join-Path $scriptPath "npm-memory-manager.ps1"
if (-not (Test-Path $memoryManagerPath)) {
    Write-Error "Memory manager module not found at: $memoryManagerPath"
    exit 1
}

# Import memory manager module
try {
    Import-Module $memoryManagerPath -Force
}
catch {
    Write-Error "Failed to import memory manager module: $_"
    exit 1
}

# Parse command line arguments
$npmCommand = $args -join " "

if ([string]::IsNullOrEmpty($npmCommand)) {
    Write-Host @"
Usage: .\safe-npm.ps1 <npm command>
Example: .\safe-npm.ps1 install

Options:
  install    Install dependencies (uses staged installation)
  update     Update dependencies safely
  audit      Run security audit
  clean      Clean npm cache and temporary files

Configuration:
  Max Retries: $($CONFIG.MaxRetries)
  Retry Delay: $($CONFIG.RetryDelay) seconds
  Memory Threshold: $($CONFIG.MemoryThreshold) GB
  Process Limit: $($CONFIG.ProcessLimit)
  Timeout: $($CONFIG.TimeoutSeconds) seconds
"@
    exit 1
}

# Check system state before proceeding
try {
    $metrics = Get-MemoryMetrics
    
    Write-Host "`nSystem State:"
    Write-Host "  Memory Usage: $($metrics.MemoryUsagePercent)%"
    Write-Host "  Free Memory: $($metrics.FreePhysicalMemory) GB"
    Write-Host "  Process Count: $((Get-Process).Count)`n"
    
    if ($metrics.MemoryUsagePercent -gt 90) {
        Write-Error "System memory usage too high (${metrics.MemoryUsagePercent}%). Please free up memory before proceeding."
        exit 1
    }
    
    if ((Get-Process).Count -gt $CONFIG.ProcessLimit) {
        Write-Error "Too many processes running. Please close unnecessary applications."
        exit 1
    }
}
catch {
    Write-Error "Failed to check system state: $_"
    exit 1
}

# Special handling for install command
if ($npmCommand -eq "install") {
    Write-Host "Using staged installation process for better stability..."
    try {
        # Clean npm cache first
        Write-Host "Cleaning npm cache..." -NoNewline
        npm cache clean --force
        Write-Host "✓ Done!" -ForegroundColor Green
        
        # Get list of dependencies
        $packageJson = Get-Content "package.json" | ConvertFrom-Json
        $dependencies = @()
        $devDependencies = @()
        $optionalDependencies = @()
        
        if ($packageJson.dependencies) {
            $dependencies = $packageJson.dependencies.PSObject.Properties | ForEach-Object { "$($_.Name)@$($_.Value)" }
        }
        if ($packageJson.devDependencies) {
            $devDependencies = $packageJson.devDependencies.PSObject.Properties | ForEach-Object { "$($_.Name)@$($_.Value)" }
        }
        if ($packageJson.optionalDependencies) {
            $optionalDependencies = $packageJson.optionalDependencies.PSObject.Properties | ForEach-Object { "$($_.Name)@$($_.Value)" }
        }
        
        # Installation stages with chunking
        $stages = @(
            @{
                Name = "Core Dependencies"
                Packages = $dependencies
                Essential = $true
            },
            @{
                Name = "Development Dependencies"
                Packages = $devDependencies
                Essential = $false
            },
            @{
                Name = "Optional Dependencies"
                Packages = $optionalDependencies
                Essential = $false
            }
        )
        
        foreach ($stage in $stages) {
            if ($stage.Packages.Count -eq 0) {
                Write-Host "`nSkipping $($stage.Name) - no packages to install"
                continue
            }
            
            Write-Host "`nInstalling $($stage.Name)..."
            $chunks = [Math]::Ceiling($stage.Packages.Count / $CONFIG.ChunkSize)
            
            for ($i = 0; $i -lt $chunks; $i++) {
                $start = $i * $CONFIG.ChunkSize
                $end = [Math]::Min(($i + 1) * $CONFIG.ChunkSize, $stage.Packages.Count)
                $chunk = $stage.Packages[$start..($end-1)]
                
                Write-Host "`nInstalling chunk $($i+1) of $chunks ($($chunk.Count) packages)..."
                $command = "npm install " + ($chunk -join " ")
                
                $success = Start-NpmOperation -Command $command -MaxRetries $CONFIG.MaxRetries
                
                if (-not $success) {
                    if ($stage.Essential) {
                        Write-Error "Failed to install essential dependencies"
                        exit 1
                    } else {
                        Write-Warning "Failed to install some non-essential packages in $($stage.Name)"
                        continue
                    }
                }
                
                # Wait between chunks to allow system to stabilize
                if ($i -lt $chunks - 1) {
                    Write-Host "Waiting $($CONFIG.StageDelay) seconds before next chunk..."
                    Start-Sleep -Seconds $CONFIG.StageDelay
                }
            }
        }
        
        Write-Host "`n✓ All dependencies installed successfully!" -ForegroundColor Green
        exit 0
    }
    catch {
        Write-Error "Staged installation failed: $_"
        exit 1
    }
}

# Execute the npm command with memory management
$success = Start-NpmOperation -Command $npmCommand -MaxRetries $CONFIG.MaxRetries

if (-not $success) {
    Write-Error "Operation failed. Check logs for details."
    exit 1
}

Write-Host "`n✓ Operation completed successfully!" -ForegroundColor Green
exit 0 