# Installation Manager Script
# Uses process-manager.ps1 to safely handle npm installations

# Import the process manager module
$ProcessManagerPath = Join-Path $PSScriptRoot "process-manager.ps1"
$PreFlightChecksPath = Join-Path $PSScriptRoot "pre-flight-checks.ps1"
. $ProcessManagerPath

# Create backup directory if it doesn't exist
$BackupDir = Join-Path $PSScriptRoot ".." "backup"
New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null

function Backup-ModuleState {
    param(
        [string]$GroupName
    )
    
    try {
        Write-ProcessLog "Creating backup for package group: $GroupName" "INFO"
        
        # Create backup timestamp
        $BackupTimestamp = Get-Date -Format "yyyyMMdd-HHmmss"
        $BackupName = "backup-$GroupName-$BackupTimestamp"
        $BackupPath = Join-Path $BackupDir $BackupName
        
        # Create the backup directory
        New-Item -ItemType Directory -Path $BackupPath -Force | Out-Null
        
        # Backup package.json if it exists
        $PackageJsonPath = "package.json"
        if (Test-Path $PackageJsonPath) {
            Copy-Item -Path $PackageJsonPath -Destination (Join-Path $BackupPath "package.json")
            Write-ProcessLog "Backed up package.json" "INFO"
        }
        
        # Backup package-lock.json if it exists
        $PackageLockPath = "package-lock.json"
        if (Test-Path $PackageLockPath) {
            Copy-Item -Path $PackageLockPath -Destination (Join-Path $BackupPath "package-lock.json")
            Write-ProcessLog "Backed up package-lock.json" "INFO"
        }
        
        # Backup just the relevant node_modules for this group
        $NodeModulesPath = "node_modules"
        if (Test-Path $NodeModulesPath) {
            # Parse package group to get individual package names
            $Packages = $PackageGroups[$GroupName] -replace "--save ", "" -split " "
            
            foreach ($Package in $Packages) {
                # Handle version specifier if present
                $PackageName = $Package -split "@" | Select-Object -First 1
                $PackageDir = Join-Path $NodeModulesPath $PackageName
                
                if (Test-Path $PackageDir) {
                    $TargetDir = Join-Path $BackupPath "node_modules" $PackageName
                    New-Item -ItemType Directory -Path (Split-Path $TargetDir) -Force | Out-Null
                    Copy-Item -Path $PackageDir -Destination $TargetDir -Recurse
                    Write-ProcessLog "Backed up package: $PackageName" "INFO"
                }
            }
        }
        
        # Create backup metadata
        $Metadata = @{
            GroupName = $GroupName
            Timestamp = $BackupTimestamp
            Packages = $PackageGroups[$GroupName]
            BackupPath = $BackupPath
        }
        
        $MetadataPath = Join-Path $BackupPath "metadata.json"
        $Metadata | ConvertTo-Json | Set-Content -Path $MetadataPath
        
        Write-ProcessLog "Created backup for $GroupName at $BackupPath" "INFO"
        return $BackupPath
    }
    catch {
        Write-ProcessLog "Error creating backup: $_" "ERROR"
        return $null
    }
}

function Restore-ModuleState {
    param(
        [string]$BackupPath
    )
    
    try {
        Write-ProcessLog "Restoring from backup: $BackupPath" "INFO"
        
        if (-not (Test-Path $BackupPath)) {
            Write-ProcessLog "Backup path not found: $BackupPath" "ERROR"
            return $false
        }
        
        # Load backup metadata
        $MetadataPath = Join-Path $BackupPath "metadata.json"
        if (-not (Test-Path $MetadataPath)) {
            Write-ProcessLog "Backup metadata not found: $MetadataPath" "ERROR"
            return $false
        }
        
        $Metadata = Get-Content -Path $MetadataPath | ConvertFrom-Json
        Write-ProcessLog "Restoring backup for group: $($Metadata.GroupName)" "INFO"
        
        # Restore package.json if it exists in backup
        $BackupPackageJson = Join-Path $BackupPath "package.json"
        if (Test-Path $BackupPackageJson) {
            Copy-Item -Path $BackupPackageJson -Destination "package.json" -Force
            Write-ProcessLog "Restored package.json" "INFO"
        }
        
        # Restore package-lock.json if it exists in backup
        $BackupPackageLock = Join-Path $BackupPath "package-lock.json"
        if (Test-Path $BackupPackageLock) {
            Copy-Item -Path $BackupPackageLock -Destination "package-lock.json" -Force
            Write-ProcessLog "Restored package-lock.json" "INFO"
        }
        
        # Restore node_modules
        $BackupNodeModules = Join-Path $BackupPath "node_modules"
        if (Test-Path $BackupNodeModules) {
            $NodeModulesPath = "node_modules"
            if (-not (Test-Path $NodeModulesPath)) {
                New-Item -ItemType Directory -Path $NodeModulesPath -Force | Out-Null
            }
            
            # Copy all backed up node_modules
            Get-ChildItem -Path $BackupNodeModules -Directory | ForEach-Object {
                $PackageName = $_.Name
                $SourcePath = $_.FullName
                $TargetPath = Join-Path $NodeModulesPath $PackageName
                
                # Remove existing if present
                if (Test-Path $TargetPath) {
                    Remove-Item -Path $TargetPath -Recurse -Force
                }
                
                # Restore from backup
                Copy-Item -Path $SourcePath -Destination $TargetPath -Recurse
                Write-ProcessLog "Restored package: $PackageName" "INFO"
            }
        }
        
        Write-ProcessLog "Restored backup from $BackupPath" "INFO"
        return $true
    }
    catch {
        Write-ProcessLog "Error restoring backup: $_" "ERROR"
        return $false
    }
}

function Start-SafeInstallation {
    param(
        [string]$PackageGroup,
        [int]$MaxRetries = 3,
        [int]$TimeoutSeconds = 300,
        [switch]$SkipBackup = $false,
        [string]$ReservationId = $null
    )
    
    Write-ProcessLog "Starting safe installation for package group: $PackageGroup" "INFO"
    
    # Run pre-flight checks if not already done
    if (-not $ReservationId) {
        Write-ProcessLog "No resource reservation provided, running pre-flight checks" "INFO"
        
        if (Test-Path $PreFlightChecksPath) {
            try {
                # Run pre-flight checks as a separate process to ensure isolation
                $preFlightResult = & $PreFlightChecksPath
                $preFlightExitCode = $LASTEXITCODE
                
                if ($preFlightExitCode -ne 0) {
                    Write-ProcessLog "Pre-flight checks failed with exit code: $preFlightExitCode" "ERROR"
                    throw "Pre-flight checks failed. Installation aborted."
                } else {
                    Write-ProcessLog "Pre-flight checks passed" "INFO"
                    
                    # Try to retrieve the reservation ID from the pre-flight results
                    try {
                        $latestPreFlightResult = Get-ChildItem -Path "./.cursor/logs/pre-flight-results-*.json" | 
                                                Sort-Object LastWriteTime -Descending | 
                                                Select-Object -First 1
                        
                        if ($latestPreFlightResult) {
                            $preFlightData = Get-Content -Path $latestPreFlightResult.FullName | ConvertFrom-Json
                            $ReservationId = $preFlightData.ReservationId
                            Write-ProcessLog "Using resource reservation from pre-flight: $ReservationId" "INFO"
                        }
                    } catch {
                        Write-ProcessLog "Error retrieving reservation ID: $_" "WARNING"
                    }
                }
            } catch {
                Write-ProcessLog "Error running pre-flight checks: $_" "ERROR"
                throw "Pre-flight check execution failed. Installation aborted."
            }
        } else {
            Write-ProcessLog "Pre-flight checks script not found: $PreFlightChecksPath" "WARNING"
        }
    }
    
    # Clean up any stalled processes before starting
    Stop-StalledProcesses
    
    # Create backup unless explicitly skipped
    $BackupPath = $null
    if (-not $SkipBackup) {
        # Extract group name from the package group
        $GroupName = $PackageGroups.Keys | Where-Object { $PackageGroups[$_] -eq $PackageGroup } | Select-Object -First 1
        if (-not $GroupName) { $GroupName = "unknown" }
        
        $BackupPath = Backup-ModuleState -GroupName $GroupName
        if (-not $BackupPath) {
            Write-ProcessLog "Backup creation failed, proceeding with caution" "WARNING"
        } else {
            Write-ProcessLog "Created backup at $BackupPath" "INFO"
        }
    }
    
    $RetryCount = 0
    $Success = $false
    
    while (-not $Success -and $RetryCount -lt $MaxRetries) {
        try {
            # Get current metrics before starting
            $StartMetrics = Get-ProcessMetrics
            Write-ProcessLog "Initial metrics: $($StartMetrics | ConvertTo-Json)" "INFO"
            
            # Start the npm installation process
            $Result = Start-NpmProcess -Arguments "install $PackageGroup" -TimeoutSeconds $TimeoutSeconds
            
            if ($Result) {
                Write-ProcessLog "Installation completed successfully" "INFO"
                $Success = $true
            }
        } catch {
            $RetryCount++
            Write-ProcessLog "Installation attempt $RetryCount failed: $_" "WARNING"
            
            if ($RetryCount -lt $MaxRetries) {
                Write-ProcessLog "Waiting 30 seconds before retry..." "INFO"
                Start-Sleep -Seconds 30
            } else {
                Write-ProcessLog "All retry attempts failed" "ERROR"
                
                # Attempt to restore from backup
                if ($BackupPath -and (Test-Path $BackupPath)) {
                    Write-ProcessLog "Attempting to restore from backup..." "WARNING"
                    $RestoreSuccess = Restore-ModuleState -BackupPath $BackupPath
                    
                    if ($RestoreSuccess) {
                        Write-ProcessLog "Successfully restored from backup" "INFO"
                    } else {
                        Write-ProcessLog "Failed to restore from backup" "ERROR"
                    }
                }
            }
        }
    }
    
    # Release the resource reservation if provided
    if ($ReservationId) {
        try {
            $releaseScript = @"
                . '$PreFlightChecksPath'
                Release-SystemResources -ReservationId '$ReservationId'
"@
            $tempScriptPath = Join-Path $env:TEMP "release-resources.ps1"
            Set-Content -Path $tempScriptPath -Value $releaseScript
            
            & powershell -File $tempScriptPath
            Remove-Item -Path $tempScriptPath -Force
            
            Write-ProcessLog "Resource reservation released: $ReservationId" "INFO"
        } catch {
            Write-ProcessLog "Error releasing resource reservation: $_" "WARNING"
        }
    }
    
    if (-not $Success) {
        Write-ProcessLog "Installation failed after $MaxRetries attempts" "ERROR"
        throw "Installation failed after $MaxRetries attempts"
    }
    
    # Get final metrics
    $EndMetrics = Get-ProcessMetrics
    Write-ProcessLog "Final metrics: $($EndMetrics | ConvertTo-Json)" "INFO"
    
    return $Success
}

# Example package groups for staged installation
$PackageGroups = @{
    "core" = "--save fs-extra@11.2.0 chalk@4.1.2"
    "monitoring" = "--save systeminformation@5.21.24 node-os-utils@1.3.7"
    "ui" = "--save cli-progress@3.12.0 moment@2.30.1"
}

# Main installation sequence
function Start-StagedInstallation {
    param(
        [switch]$RunPreFlightChecks = $true,
        [switch]$CreateBackups = $true,
        [int]$CooldownSeconds = 60
    )
    
    try {
        $ReservationId = $null
        
        # Run pre-flight checks if requested
        if ($RunPreFlightChecks) {
            Write-ProcessLog "Running pre-flight checks before installation" "INFO"
            
            if (Test-Path $PreFlightChecksPath) {
                try {
                    $preFlightResult = & $PreFlightChecksPath
                    $preFlightExitCode = $LASTEXITCODE
                    
                    if ($preFlightExitCode -ne 0) {
                        Write-ProcessLog "Pre-flight checks failed with exit code: $preFlightExitCode" "ERROR"
                        throw "Pre-flight checks failed. Installation aborted."
                    } else {
                        Write-ProcessLog "Pre-flight checks passed" "INFO"
                        
                        # Try to retrieve the reservation ID from the pre-flight results
                        try {
                            $latestPreFlightResult = Get-ChildItem -Path "./.cursor/logs/pre-flight-results-*.json" | 
                                                    Sort-Object LastWriteTime -Descending | 
                                                    Select-Object -First 1
                            
                            if ($latestPreFlightResult) {
                                $preFlightData = Get-Content -Path $latestPreFlightResult.FullName | ConvertFrom-Json
                                $ReservationId = $preFlightData.ReservationId
                                Write-ProcessLog "Using resource reservation from pre-flight: $ReservationId" "INFO"
                            }
                        } catch {
                            Write-ProcessLog "Error retrieving reservation ID: $_" "WARNING"
                        }
                    }
                } catch {
                    Write-ProcessLog "Error running pre-flight checks: $_" "ERROR"
                    throw "Pre-flight check execution failed. Installation aborted."
                }
            } else {
                Write-ProcessLog "Pre-flight checks script not found: $PreFlightChecksPath" "WARNING"
            }
        }
        
        foreach ($Group in $PackageGroups.GetEnumerator()) {
            Write-ProcessLog "Installing $($Group.Key) dependencies..." "INFO"
            $Success = Start-SafeInstallation -PackageGroup $Group.Value -MaxRetries 3 -TimeoutSeconds 300 `
                -SkipBackup:(-not $CreateBackups) -ReservationId $ReservationId
            
            if ($Success) {
                Write-ProcessLog "$($Group.Key) dependencies installed successfully" "INFO"
            } else {
                Write-ProcessLog "$($Group.Key) installation failed" "ERROR"
                throw "Installation of $($Group.Key) failed. Aborting further installations."
            }
            
            # Add a cooldown period between groups
            Write-ProcessLog "Waiting $CooldownSeconds seconds before next package group..." "INFO"
            Start-Sleep -Seconds $CooldownSeconds
        }
        
        Write-ProcessLog "All installations completed successfully" "INFO"
        return $true
    } catch {
        Write-ProcessLog "Installation sequence failed: $_" "ERROR"
        
        # In case of failure, ensure resource reservation is released
        if ($ReservationId) {
            try {
                $releaseScript = @"
                    . '$PreFlightChecksPath'
                    Release-SystemResources -ReservationId '$ReservationId'
"@
                $tempScriptPath = Join-Path $env:TEMP "release-resources.ps1"
                Set-Content -Path $tempScriptPath -Value $releaseScript
                
                & powershell -File $tempScriptPath
                Remove-Item -Path $tempScriptPath -Force
                
                Write-ProcessLog "Resource reservation released: $ReservationId" "INFO"
            } catch {
                Write-ProcessLog "Error releasing resource reservation: $_" "WARNING"
            }
        }
        
        throw $_
    }
} 