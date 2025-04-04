# Memory Manager Test Suite
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Import required modules
$NpmMemoryManagerPath = Join-Path $PSScriptRoot ".." ".." "scripts" "npm-memory-manager.ps1"
$ProcessManagerPath = Join-Path $PSScriptRoot "process-manager.ps1"

# Initialize test log
$TestLogPath = Join-Path $PSScriptRoot ".." "logs" "test-memory-manager.log"
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

function Test-MemoryManager {
    $TestResults = @{
        PassedTests = 0
        TotalTests = 0
        FailedTests = @()
        Errors = @()
        Warnings = @()
        Metrics = @{}
    }

    try {
        Write-TestLog "Starting memory manager tests"

        # Test 1: Module Import
        $TestResults.TotalTests++
        try {
            . $NpmMemoryManagerPath
            Write-TestLog "Memory manager module import successful"
            $TestResults.PassedTests++
        } catch {
            Write-TestLog "Memory manager module import failed: $_" -Level "ERROR"
            $TestResults.FailedTests += "Module Import"
            $TestResults.Errors += $_.Exception.Message
            throw "Critical failure: Cannot import memory manager module"
        }

        # Test 2: Environment Setup
        $TestResults.TotalTests++
        try {
            Initialize-Environment
            if ((Test-Path $TEMP_DIR) -and (Test-Path ".\logs")) {
                Write-TestLog "Environment setup successful"
                $TestResults.PassedTests++
            } else {
                throw "Required directories not created"
            }
        } catch {
            Write-TestLog "Environment setup failed: $_" -Level "ERROR"
            $TestResults.FailedTests += "Environment Setup"
            $TestResults.Errors += $_.Exception.Message
        }

        # Test 3: Memory Usage Monitoring
        $TestResults.TotalTests++
        try {
            $initialUsage = Get-MemoryUsage
            $TestResults.Metrics.Add("InitialMemoryUsage", $initialUsage)
            Write-TestLog "Initial memory usage: $initialUsage%"
            
            # Simulate memory pressure
            $array = 1..1000000 | ForEach-Object { "x" * 100 }
            
            $pressureUsage = Get-MemoryUsage
            $TestResults.Metrics.Add("PressureMemoryUsage", $pressureUsage)
            Write-TestLog "Memory usage under pressure: $pressureUsage%"
            
            if ($pressureUsage -gt $initialUsage) {
                Write-TestLog "Memory monitoring test successful"
                $TestResults.PassedTests++
            } else {
                throw "Memory pressure not detected"
            }
            
            # Cleanup
            $array = $null
            [System.GC]::Collect()
        } catch {
            Write-TestLog "Memory monitoring test failed: $_" -Level "ERROR"
            $TestResults.FailedTests += "Memory Monitoring"
            $TestResults.Errors += $_.Exception.Message
        }

        # Test 4: Memory Safety Check
        $TestResults.TotalTests++
        try {
            $isSafe = Test-MemorySafe
            $currentUsage = Get-MemoryUsage
            $TestResults.Metrics.Add("CurrentMemoryUsage", $currentUsage)
            
            if ($currentUsage -lt $MAX_MEMORY_PERCENT -eq $isSafe) {
                Write-TestLog "Memory safety check test successful"
                $TestResults.PassedTests++
            } else {
                throw "Memory safety check inconsistent with current usage"
            }
        } catch {
            Write-TestLog "Memory safety check test failed: $_" -Level "ERROR"
            $TestResults.FailedTests += "Memory Safety Check"
            $TestResults.Errors += $_.Exception.Message
        }

        # Test 5: NPM Configuration
        $TestResults.TotalTests++
        try {
            Set-NpmConfig
            $cacheDir = npm config get cache
            $tmpDir = npm config get tmp
            
            if ($cacheDir -eq $TEMP_DIR -and $tmpDir -eq $TEMP_DIR) {
                Write-TestLog "NPM configuration test successful"
                $TestResults.PassedTests++
            } else {
                throw "NPM configuration not set correctly"
            }
        } catch {
            Write-TestLog "NPM configuration test failed: $_" -Level "ERROR"
            $TestResults.FailedTests += "NPM Configuration"
            $TestResults.Errors += $_.Exception.Message
        }

        # Test 6: Safe NPM Operation
        $TestResults.TotalTests++
        try {
            $result = Start-NpmOperation -Command "--version"
            if ($result) {
                Write-TestLog "Safe NPM operation test successful"
                $TestResults.PassedTests++
            } else {
                throw "Safe NPM operation failed"
            }
        } catch {
            Write-TestLog "Safe NPM operation test failed: $_" -Level "ERROR"
            $TestResults.FailedTests += "Safe NPM Operation"
            $TestResults.Errors += $_.Exception.Message
        }

        # Test 7: Memory Recovery
        $TestResults.TotalTests++
        try {
            # Create memory pressure
            $array = 1..1000000 | ForEach-Object { "x" * 100 }
            $pressureUsage = Get-MemoryUsage
            
            # Clear pressure and wait for recovery
            $array = $null
            [System.GC]::Collect()
            Start-Sleep -Seconds 2
            
            $recoveryUsage = Get-MemoryUsage
            $TestResults.Metrics.Add("RecoveryMemoryUsage", $recoveryUsage)
            
            if ($recoveryUsage -lt $pressureUsage) {
                Write-TestLog "Memory recovery test successful"
                $TestResults.PassedTests++
            } else {
                throw "Memory not recovered after pressure"
            }
        } catch {
            Write-TestLog "Memory recovery test failed: $_" -Level "ERROR"
            $TestResults.FailedTests += "Memory Recovery"
            $TestResults.Errors += $_.Exception.Message
        }

    } catch {
        Write-TestLog "Unexpected error in test suite: $_" -Level "ERROR"
        $TestResults.Errors += $_.Exception.Message
    }

    # Generate test report
    $Report = @{
        Results = $TestResults
        PassRate = [math]::Round(($TestResults.PassedTests / $TestResults.TotalTests) * 100, 2)
        Environment = @{
            PowerShell = $PSVersionTable.PSVersion.ToString()
            OS = [System.Environment]::OSVersion.ToString()
            Time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            TotalMemory = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 2)
        }
    }

    $ReportPath = Join-Path $PSScriptRoot ".." "logs" "memory-test-report.json"
    $Report | ConvertTo-Json -Depth 10 | Set-Content -Path $ReportPath
    Write-TestLog "Test report generated at: $ReportPath"

    if ($TestResults.FailedTests.Count -gt 0) {
        throw "Tests failed: $($TestResults.FailedTests -join ', ')"
    }

    Write-TestLog "All memory management tests completed successfully"
    return $Report
}

# Export the test function
Export-ModuleMember -Function Test-MemoryManager 