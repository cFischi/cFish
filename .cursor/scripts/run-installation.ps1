# Run Installation Script
# Executes the staged installation process with proper error handling and logging

# Import required scripts
$ProcessManagerPath = Join-Path $PSScriptRoot "process-manager.ps1"
$InstallManagerPath = Join-Path $PSScriptRoot "install-manager.ps1"
$PreFlightChecksPath = Join-Path $PSScriptRoot "pre-flight-checks.ps1"
. $ProcessManagerPath
. $InstallManagerPath

function Start-InstallationProcess {
    param(
        [switch]$RunTests = $true,
        [switch]$ForceCleanup = $false,
        [switch]$SkipBackup = $false,
        [switch]$SkipPreFlightChecks = $false,
        [int]$CooldownSeconds = 60
    )
    
    Write-ProcessLog "Starting installation process" "INFO"
    
    try {
        # Initial cleanup if forced
        if ($ForceCleanup) {
            Write-ProcessLog "Performing forced cleanup" "INFO"
            Stop-StalledProcesses
        }
        
        # Run tests if requested
        if ($RunTests) {
            Write-ProcessLog "Running pre-installation tests" "INFO"
            $TestReport = & (Join-Path $PSScriptRoot "test-process-manager.ps1")
            
            if ($TestReport.PassedTests -lt $TestReport.TotalTests) {
                throw "Pre-installation tests failed: $($TestReport.PassedTests) of $($TestReport.TotalTests) passed"
            }
        }
        
        # Verify pre-flight checks script exists
        if (-not $SkipPreFlightChecks -and -not (Test-Path $PreFlightChecksPath)) {
            Write-ProcessLog "Pre-flight checks script not found: $PreFlightChecksPath" "WARNING"
            $SkipPreFlightChecks = $true
        }
        
        # Run pre-flight checks independently if not skipped
        $ReservationId = $null
        if (-not $SkipPreFlightChecks) {
            Write-ProcessLog "Running pre-flight system checks..." "INFO"
            
            try {
                # Run pre-flight checks
                $preFlightResult = & $PreFlightChecksPath
                $preFlightExitCode = $LASTEXITCODE
                
                if ($preFlightExitCode -ne 0) {
                    Write-ProcessLog "Pre-flight checks failed with exit code: $preFlightExitCode" "ERROR"
                    throw "Pre-flight checks failed. System resources insufficient or critical services unavailable."
                }
                
                # Retrieve resource reservation ID
                try {
                    $latestPreFlightResult = Get-ChildItem -Path "./.cursor/logs/pre-flight-results-*.json" | 
                                             Sort-Object LastWriteTime -Descending | 
                                             Select-Object -First 1
                    
                    if ($latestPreFlightResult) {
                        $preFlightData = Get-Content -Path $latestPreFlightResult.FullName | ConvertFrom-Json
                        $ReservationId = $preFlightData.ReservationId
                        
                        if ($ReservationId) {
                            Write-ProcessLog "Resource reservation created: $ReservationId" "INFO"
                        } else {
                            Write-ProcessLog "No resource reservation found in pre-flight results" "WARNING"
                        }
                    }
                } catch {
                    Write-ProcessLog "Error retrieving pre-flight results: $_" "WARNING"
                }
            } catch {
                Write-ProcessLog "Error during pre-flight checks: $_" "ERROR"
                throw "Pre-flight checks execution failed. Installation aborted."
            }
        }
        
        # Start installation sequence
        Write-ProcessLog "Beginning staged installation with resource reservation: $ReservationId" "INFO"
        
        # Use the enhanced staged installation function
        $InstallationSuccess = Start-StagedInstallation -RunPreFlightChecks:$false `
                                                       -CreateBackups:(-not $SkipBackup) `
                                                       -CooldownSeconds $CooldownSeconds
        
        if (-not $InstallationSuccess) {
            throw "Staged installation failed"
        }
        
        Write-ProcessLog "Installation sequence completed successfully" "INFO"
        
        # Run post-installation tests if requested
        if ($RunTests) {
            Write-ProcessLog "Running post-installation tests" "INFO"
            $TestReport = & (Join-Path $PSScriptRoot "test-process-manager.ps1")
            Write-ProcessLog "Post-installation tests: $($TestReport.PassedTests) of $($TestReport.TotalTests) passed" "INFO"
        }
        
        return $true
    } catch {
        Write-ProcessLog "Installation process failed: $_" "ERROR"
        
        # Attempt cleanup
        try {
            Write-ProcessLog "Attempting cleanup after failure" "INFO"
            Stop-StalledProcesses
        } catch {
            Write-ProcessLog "Cleanup after failure also failed: $_" "ERROR"
        }
        
        throw $_
    }
}

# Main execution
try {
    $Result = Start-InstallationProcess -RunTests -ForceCleanup -CooldownSeconds 60
    
    if ($Result) {
        Write-ProcessLog "Installation completed successfully" "INFO"
        exit 0
    } else {
        Write-ProcessLog "Installation failed" "ERROR"
        exit 1
    }
} catch {
    Write-ProcessLog "Fatal error during installation: $_" "ERROR"
    exit 1
} 