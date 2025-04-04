# Test suite for Process Manager
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Import required scripts
$ProcessManagerPath = Join-Path $PSScriptRoot "process-manager.ps1"
$InstallManagerPath = Join-Path $PSScriptRoot "install-manager.ps1"

# Initialize test log
$TestLogPath = Join-Path $PSScriptRoot ".." "logs" "test-process-manager.log"
$null = New-Item -ItemType Directory -Force -Path (Split-Path $TestLogPath)

function Write-TestLog {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMessage = "$Timestamp [$Level] $Message"
    Add-Content -Path $TestLogPath -Value $LogMessage
    Write-Host $LogMessage
}

function Test-ProcessManager {
    $TestResults = @{
        PassedTests = 0
        TotalTests = 0
        FailedTests = @()
        Errors = @()
        Warnings = @()
    }

    try {
        Write-TestLog "Starting process manager tests"

        # Check for npm installation
        $NpmInstalled = $null -ne (Get-Command npm -ErrorAction SilentlyContinue)
        if (-not $NpmInstalled) {
            Write-TestLog "WARNING: npm not found in PATH. Some tests will be skipped." -Level "WARNING"
            $TestResults.Warnings += "npm not installed - some tests skipped"
        }

        # Test 1: Script Import
        $TestResults.TotalTests++
        try {
            . $ProcessManagerPath
            Write-TestLog "Script import successful"
            $TestResults.PassedTests++
        } catch {
            Write-TestLog "Script import failed: $_" -Level "ERROR"
            $TestResults.FailedTests += "Script Import"
            $TestResults.Errors += $_.Exception.Message
            # Exit early if we can't import the script
            throw "Critical failure: Cannot import process manager script"
        }

        # Test 2: Job Object Creation
        $TestResults.TotalTests++
        try {
            if ($script:JobHandle -ne [IntPtr]::Zero) {
                Write-TestLog "Job object creation successful"
                $TestResults.PassedTests++
            } else {
                throw "Job handle is null or zero"
            }
        } catch {
            Write-TestLog "Job object creation failed: $_" -Level "ERROR"
            $TestResults.FailedTests += "Job Object Creation"
            $TestResults.Errors += $_.Exception.Message
        }

        if ($NpmInstalled) {
            # Test 3: Process Start and Job Assignment
            $TestResults.TotalTests++
            try {
                $Result = Start-NpmProcess -Arguments "--version"
                if ($Result) {
                    Write-TestLog "Process start and job assignment successful"
                    $TestResults.PassedTests++
                } else {
                    throw "Process start returned false"
                }
            } catch {
                Write-TestLog "Process start test failed: $_" -Level "ERROR"
                $TestResults.FailedTests += "Process Start"
                $TestResults.Errors += $_.Exception.Message
            }

            # Test 4: Process Metrics Collection
            $TestResults.TotalTests++
            try {
                $Metrics = Get-ProcessMetrics
                if ($null -ne $Metrics) {
                    Write-TestLog "Process metrics collection successful"
                    Write-TestLog "Current metrics: $($Metrics | ConvertTo-Json)"
                    $TestResults.PassedTests++
                } else {
                    throw "Metrics collection returned null"
                }
            } catch {
                Write-TestLog "Metrics collection test failed: $_" -Level "ERROR"
                $TestResults.FailedTests += "Metrics Collection"
                $TestResults.Errors += $_.Exception.Message
            }

            # Test 5: Resource Limits
            $TestResults.TotalTests++
            try {
                $ResourceTest = Start-NpmProcess -Arguments "install --dry-run" -TimeoutSeconds 5
                Write-TestLog "Resource limits test successful"
                $TestResults.PassedTests++
            } catch {
                if ($_.Exception.Message -match "TIMEOUT|RESOURCE_EXCEEDED") {
                    Write-TestLog "Resource limits properly enforced"
                    $TestResults.PassedTests++
                } else {
                    Write-TestLog "Resource limits test failed: $_" -Level "ERROR"
                    $TestResults.FailedTests += "Resource Limits"
                    $TestResults.Errors += $_.Exception.Message
                }
            }
        } else {
            Write-TestLog "Skipping npm-dependent tests due to missing npm installation"
            $TestResults.Warnings += "Skipped tests: Process Start, Metrics Collection, Resource Limits"
        }

        # Test 6: Stall Detection (can run without npm processes)
        $TestResults.TotalTests++
        try {
            Stop-StalledProcesses -StallThresholdMinutes 1
            Write-TestLog "Stall detection test successful"
            $TestResults.PassedTests++
        } catch {
            Write-TestLog "Stall detection test failed: $_" -Level "ERROR"
            $TestResults.FailedTests += "Stall Detection"
            $TestResults.Errors += $_.Exception.Message
        }

        # Test 7: Process Tree Visualization
        $TestResults.TotalTests++
        try {
            $ProcessTree = Get-ProcessTree
            if ($null -ne $ProcessTree -and $ProcessTree.Count -gt 0) {
                # Verify tree structure
                $HasValidStructure = $ProcessTree | Where-Object { 
                    $_.ParentProcessId -ne $null -and 
                    $_.ProcessId -ne $null -and 
                    $_.Name -ne $null -and 
                    $_.ResourceUsage -ne $null 
                }
                if ($HasValidStructure) {
                    Write-TestLog "Process tree visualization test successful"
                    $TestResults.PassedTests++
                } else {
                    throw "Process tree missing required properties"
                }
            } else {
                throw "Process tree returned empty or null"
            }
        } catch {
            Write-TestLog "Process tree visualization test failed: $_" -Level "ERROR"
            $TestResults.FailedTests += "Process Tree Visualization"
            $TestResults.Errors += $_.Exception.Message
        }

        # Test 8: Resource Monitoring
        $TestResults.TotalTests++
        try {
            $ResourceMetrics = Get-ResourceMetrics
            if ($null -ne $ResourceMetrics -and 
                $ResourceMetrics.ContainsKey('CPU') -and 
                $ResourceMetrics.ContainsKey('Memory') -and 
                $ResourceMetrics.ContainsKey('Trends')) {
                Write-TestLog "Resource monitoring test successful"
                Write-TestLog "Current metrics: $($ResourceMetrics | ConvertTo-Json)"
                $TestResults.PassedTests++
            } else {
                throw "Resource metrics missing required data"
            }
        } catch {
            Write-TestLog "Resource monitoring test failed: $_" -Level "ERROR"
            $TestResults.FailedTests += "Resource Monitoring"
            $TestResults.Errors += $_.Exception.Message
        }

        # Test 9: Alert System
        $TestResults.TotalTests++
        try {
            # Test alert creation
            $AlertTest = New-ProcessAlert -Type "Memory" -Threshold 90 -ProcessId $PID
            if ($AlertTest.AlertId -and $AlertTest.Type -eq "Memory") {
                # Test alert retrieval
                $Alerts = Get-ProcessAlerts
                if ($Alerts.Count -gt 0 -and $Alerts[0].AlertId -eq $AlertTest.AlertId) {
                    # Test WebSocket broadcast
                    $BroadcastTest = Send-AlertBroadcast -AlertId $AlertTest.AlertId
                    if ($BroadcastTest) {
                        Write-TestLog "Alert system test successful"
                        $TestResults.PassedTests++
                    } else {
                        throw "Alert broadcast failed"
                    }
                } else {
                    throw "Alert retrieval failed"
                }
            } else {
                throw "Alert creation failed"
            }
        } catch {
            Write-TestLog "Alert system test failed: $_" -Level "ERROR"
            $TestResults.FailedTests += "Alert System"
            $TestResults.Errors += $_.Exception.Message
        }

        # Test 10: Cross-Platform Compatibility
        $TestResults.TotalTests++
        try {
            $RunningOnWindows = $PSVersionTable.Platform -eq 'Win32NT' -or $PSVersionTable.PSEdition -eq 'Desktop'
            $PlatformSpecificTest = if ($RunningOnWindows) {
                Test-WindowsProcessInfo
            } else {
                Test-UnixProcessInfo
            }
            
            if ($PlatformSpecificTest) {
                Write-TestLog "Cross-platform compatibility test successful"
                $TestResults.PassedTests++
            } else {
                throw "Platform-specific process info test failed"
            }
        } catch {
            Write-TestLog "Cross-platform compatibility test failed: $_" -Level "ERROR"
            $TestResults.FailedTests += "Cross-Platform Compatibility"
            $TestResults.Errors += $_.Exception.Message
        }

        # Test 11: Real-Time Updates
        $TestResults.TotalTests++
        try {
            $UpdateTest = Test-RealTimeUpdates
            if ($UpdateTest.UpdateCount -gt 0 -and $UpdateTest.LastUpdateTime) {
                Write-TestLog "Real-time updates test successful"
                $TestResults.PassedTests++
            } else {
                throw "Real-time updates test failed"
            }
        } catch {
            Write-TestLog "Real-time updates test failed: $_" -Level "ERROR"
            $TestResults.FailedTests += "Real-Time Updates"
            $TestResults.Errors += $_.Exception.Message
        }

    } catch {
        Write-TestLog "Unexpected error in test suite: $_" -Level "ERROR"
        $TestResults.Errors += $_.Exception.Message
    } finally {
        # Cleanup
        try {
            Close-JobHandle
            Remove-ProcessAlerts # Clean up test alerts
            Write-TestLog "Cleanup completed successfully"
        } catch {
            Write-TestLog "Cleanup failed: $_" -Level "ERROR"
            $TestResults.Errors += "Cleanup: $($_.Exception.Message)"
        }
    }

    # Generate test report
    $Report = @{
        Results = $TestResults
        PassRate = [math]::Round(($TestResults.PassedTests / $TestResults.TotalTests) * 100, 2)
        Environment = @{
            PowerShell = $PSVersionTable.PSVersion.ToString()
            OS = [System.Environment]::OSVersion.ToString()
            Time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            NpmInstalled = $NpmInstalled
        }
    }

    $ReportPath = Join-Path $PSScriptRoot ".." "logs" "test-report.json"
    $Report | ConvertTo-Json -Depth 10 | Set-Content -Path $ReportPath
    Write-TestLog "Test report generated at: $ReportPath"

    if ($TestResults.FailedTests.Count -gt 0) {
        throw "Tests failed: $($TestResults.FailedTests -join ', ')"
    }

    Write-TestLog "All tests completed successfully"
    if ($TestResults.Warnings.Count -gt 0) {
        Write-TestLog "Warnings: $($TestResults.Warnings -join '; ')" -Level "WARNING"
    }
    return $Report
}

function Test-WindowsProcessInfo {
    try {
        $ProcessInfo = Get-WindowsProcessDetails -ProcessId $PID
        return $null -ne $ProcessInfo -and 
               $ProcessInfo.CommandLine -and 
               $ProcessInfo.WorkingSet -and 
               $ProcessInfo.ParentProcessId
    } catch {
        return $false
    }
}

function Test-UnixProcessInfo {
    try {
        $ProcessInfo = Get-UnixProcessDetails -ProcessId $PID
        return $null -ne $ProcessInfo -and 
               $ProcessInfo.Command -and 
               $ProcessInfo.RSS -and 
               $ProcessInfo.PPID
    } catch {
        return $false
    }
}

function Test-RealTimeUpdates {
    $UpdateCount = 0
    $LastUpdateTime = $null
    $Timer = [System.Diagnostics.Stopwatch]::StartNew()

    while ($Timer.Elapsed.TotalSeconds -lt 5) {
        $Metrics = Get-ResourceMetrics
        if ($null -ne $Metrics) {
            $UpdateCount++
            $LastUpdateTime = Get-Date
        }
        Start-Sleep -Milliseconds 500
    }

    return @{
        UpdateCount = $UpdateCount
        LastUpdateTime = $LastUpdateTime
    }
}

# Run tests
Test-ProcessManager 