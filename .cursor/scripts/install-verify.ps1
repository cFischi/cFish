# Installation Verification Script
# Handles dependency validation, state tracking, and rollback functionality

# Enable strict mode
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Import process manager
$ProcessManagerPath = Join-Path $PSScriptRoot "process-manager.ps1"
. $ProcessManagerPath

# Initialize logging
$LogPath = Join-Path $PSScriptRoot ".." "logs" "install-verify.log"
$null = New-Item -ItemType Directory -Force -Path (Split-Path $LogPath)

function Write-VerifyLog {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMessage = "$Timestamp [$Level] $Message"
    Add-Content -Path $LogPath -Value $LogMessage
    Write-Host $LogMessage
}

function Test-ProcessState {
    try {
        Write-VerifyLog "Checking npm process state"
        
        $NpmProcesses = Get-Process npm -ErrorAction SilentlyContinue
        $Metrics = Get-ProcessMetrics
        
        $State = @{
            ActiveProcesses = $NpmProcesses.Count
            MemoryUsage = $Metrics.TotalMemory
            CpuUsage = $Metrics.CpuUsage
            IsHealthy = $true
        }
        
        # Check process health
        if ($State.ActiveProcesses -gt 5) {
            $State.IsHealthy = $false
            Write-VerifyLog "Too many npm processes running" -Level "WARNING"
        }
        
        if ($State.MemoryUsage -gt 1000) {
            $State.IsHealthy = $false
            Write-VerifyLog "Memory usage too high" -Level "WARNING"
        }
        
        if ($State.CpuUsage -gt 80) {
            $State.IsHealthy = $false
            Write-VerifyLog "CPU usage too high" -Level "WARNING"
        }
        
        Write-VerifyLog "Process state check completed: $($State | ConvertTo-Json)"
        return $State
    } catch {
        Write-VerifyLog "Error checking process state: $_" -Level "ERROR"
        throw $_
    }
}

function Test-Dependencies {
    param(
        [string]$PackageGroup
    )
    
    try {
        Write-VerifyLog "Verifying dependencies for group: $PackageGroup"
        
        # Read package.json
        $PackageJson = Get-Content (Join-Path $PSScriptRoot ".." "package.json") | ConvertFrom-Json
        
        # Verify installed dependencies
        $Missing = @()
        $Version = @()
        
        foreach ($Dep in $PackageJson.dependencies.PSObject.Properties) {
            $Name = $Dep.Name
            $ExpectedVersion = $Dep.Value
            
            # Check if module exists
            $ModulePath = Join-Path $PSScriptRoot ".." "node_modules" $Name "package.json"
            if (-not (Test-Path $ModulePath)) {
                $Missing += $Name
                continue
            }
            
            # Check version
            $InstalledVersion = (Get-Content $ModulePath | ConvertFrom-Json).version
            if ($InstalledVersion -ne $ExpectedVersion) {
                $Version += @{
                    name = $Name
                    expected = $ExpectedVersion
                    installed = $InstalledVersion
                }
            }
        }
        
        $Result = @{
            missing = $Missing
            version_mismatch = $Version
            is_valid = ($Missing.Count -eq 0 -and $Version.Count -eq 0)
        }
        
        Write-VerifyLog "Dependency check completed: $($Result | ConvertTo-Json)"
        return $Result
    } catch {
        Write-VerifyLog "Error verifying dependencies: $_" -Level "ERROR"
        throw $_
    }
}

function Save-InstallationState {
    try {
        Write-VerifyLog "Saving installation state"
        
        $State = @{
            timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            process_state = Test-ProcessState
            dependencies = Test-Dependencies
            node_modules = Get-ChildItem (Join-Path $PSScriptRoot ".." "node_modules") -Recurse | 
                Where-Object { -not $_.PSIsContainer } | 
                ForEach-Object { @{
                    path = $_.FullName
                    hash = (Get-FileHash $_.FullName).Hash
                }
            }
        }
        
        $StatePath = Join-Path $PSScriptRoot ".." "recovery" "install-state.json"
        $State | ConvertTo-Json -Depth 10 | Set-Content $StatePath
        
        Write-VerifyLog "Installation state saved successfully"
        return $true
    } catch {
        Write-VerifyLog "Error saving installation state: $_" -Level "ERROR"
        throw $_
    }
}

function Restore-InstallationState {
    try {
        Write-VerifyLog "Attempting to restore installation state"
        
        $StatePath = Join-Path $PSScriptRoot ".." "recovery" "install-state.json"
        if (-not (Test-Path $StatePath)) {
            throw "No saved state found"
        }
        
        $State = Get-Content $StatePath | ConvertFrom-Json
        
        # Stop any running npm processes
        Stop-StalledProcesses
        
        # Clean current installation
        $NodeModules = Join-Path $PSScriptRoot ".." "node_modules"
        if (Test-Path $NodeModules) {
            Remove-Item $NodeModules -Recurse -Force
        }
        
        # Restore from saved state
        foreach ($File in $State.node_modules) {
            $TargetPath = Join-Path $PSScriptRoot ".." $File.path
            $SourcePath = Join-Path (Split-Path $StatePath) $File.path
            
            if (Test-Path $SourcePath) {
                $null = New-Item -ItemType Directory -Force -Path (Split-Path $TargetPath)
                Copy-Item $SourcePath $TargetPath -Force
            }
        }
        
        Write-VerifyLog "Installation state restored successfully"
        return $true
    } catch {
        Write-VerifyLog "Error restoring installation state: $_" -Level "ERROR"
        throw $_
    }
}

# Export functions for external use
Export-ModuleMember -Function Test-ProcessState, Test-Dependencies, Save-InstallationState, Restore-InstallationState 