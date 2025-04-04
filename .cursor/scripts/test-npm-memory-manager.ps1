# Test-npm-memory-manager.ps1
# Unit tests for npm-memory-manager.ps1 functionality

param (
    [string]$SourceScript = "scripts/npm-memory-manager.ps1",
    [string]$TestOutputDir = ".cursor/test-metrics",
    [switch]$Verbose
)

# Ensure test output directory exists
if (-not (Test-Path $TestOutputDir)) {
    New-Item -ItemType Directory -Path $TestOutputDir -Force | Out-Null
}

# Import the module to test
$modulePath = Resolve-Path $SourceScript
if (-not (Test-Path $modulePath)) {
    Write-Error "Source script not found: $SourceScript"
    exit 1
}

# Setup test environment by creating mock functions
function Setup-TestEnvironment {
    # Mock Get-WmiObject for OS and computer system
    function Global:Get-WmiObject {
        param($Class)
        
        switch ($Class) {
            "Win32_OperatingSystem" {
                return [PSCustomObject]@{
                    FreePhysicalMemory = 4GB / 1KB  # Convert to KB for WMI
                    TotalVisibleMemorySize = 16GB / 1KB # Convert to KB
                    FreeVirtualMemory = 8GB / 1KB
                    TotalVirtualMemorySize = 32GB / 1KB
                }
            }
            "Win32_ComputerSystem" {
                return [PSCustomObject]@{
                    TotalPhysicalMemory = 16GB
                }
            }
            default {
                throw "Unexpected WMI class: $Class"
            }
        }
    }
    
    # Mock Get-Process
    function Global:Get-Process {
        param($Name)
        
        $processes = @(
            [PSCustomObject]@{ Name = "npm"; Id = 1001; WorkingSet64 = 100MB; CPU = 2 },
            [PSCustomObject]@{ Name = "node"; Id = 1002; WorkingSet64 = 200MB; CPU = 5 },
            [PSCustomObject]@{ Name = "chrome"; Id = 1003; WorkingSet64 = 500MB; CPU = 10 },
            [PSCustomObject]@{ Name = "powershell"; Id = $PID; WorkingSet64 = 150MB; CPU = 3 }
        )
        
        if ($Name) {
            return $processes | Where-Object { $_.Name -like $Name }
        }
        
        return $processes
    }
    
    # Mock npm commands
    function Global:npm {
        param($Command, $Arg1, $Arg2)
        
        switch ($Command) {
            "config" {
                if ($Arg1 -eq "set") {
                    Write-Output "Setting npm config $Arg1 to $Arg2"
                    return $true
                }
                elseif ($Arg1 -eq "get") {
                    if ($Arg2 -eq "cache") { return "C:\temp\npm-cache" }
                    if ($Arg2 -eq "tmp") { return "C:\temp\npm-cache" }
                    return "mock-value"
                }
            }
            "cache" {
                if ($Arg1 -eq "clean" -and $Arg2 -eq "--force") {
                    Write-Output "Cleaned npm cache"
                    return $true
                }
            }
            "doctor" {
                Write-Output "npm doctor: everything looks ok"
                return $true
            }
            "audit" {
                if ($Arg1 -eq "fix") {
                    Write-Output "Fixed 0 vulnerabilities"
                    return $true
                }
            }
            default {
                return "Mock npm command: $Command $Arg1 $Arg2"
            }
        }
    }
    
    # Override the module config for testing
    $Global:CONFIG = @{
        MaxMemoryPercent = 65
        WarningMemoryPercent = 60
        CriticalMemoryPercent = 75
        MaxProcessCount = 500
        ProcessCheckInterval = 1
        CleanupThreshold = 70
        TempDir = "$TestOutputDir\npm-cache"
        LogDir = "$TestOutputDir\logs"
        MetricsDir = "$TestOutputDir\metrics"
        ConfigDir = "$TestOutputDir\config"
        MaxNpmProcesses = 5
        MaxNodeProcesses = 10
        EmergencyMemoryPercent = 85
        ProcessTimeout = 5
        AutoRecoveryEnabled = $true
        RecoveryAttempts = 2
        RecoveryInterval = 1
        AutoCleanupSchedule = @{
            Morning = (Get-Date).ToString("HH:mm")
        }
    }
    
    # Create test directories
    $dirs = @(
        $Global:CONFIG.TempDir,
        $Global:CONFIG.LogDir,
        $Global:CONFIG.MetricsDir,
        $Global:CONFIG.ConfigDir
    )
    
    foreach ($dir in $dirs) {
        if (-not (Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
        }
    }
}

# Run tests
function Run-MemoryManagerTests {
    Write-Host "Testing npm-memory-manager.ps1..." -ForegroundColor Cyan
    
    # Import the module to test
    . $modulePath
    
    # Setup test environment
    Setup-TestEnvironment
    
    # Test Initialize-Environment
    Write-Host "Testing Initialize-Environment..." -ForegroundColor Yellow
    Initialize-Environment
    
    $configPath = Join-Path $Global:CONFIG.ConfigDir "memory-thresholds.json"
    $configExists = Test-Path $configPath
    Assert-Test "Initialize-Environment creates config files" $configExists
    
    # Test Get-MemoryMetrics
    Write-Host "Testing Get-MemoryMetrics..." -ForegroundColor Yellow
    $metrics = Get-MemoryMetrics
    Assert-Test "Get-MemoryMetrics returns metrics" ($metrics -ne $null)
    Assert-Test "Memory metrics includes MemoryUsagePercent" ($metrics.MemoryUsagePercent -ne $null)
    Assert-Test "Memory metrics includes Process counts" ($metrics.ProcessCount -eq 4)
    
    $metricsFile = Get-ChildItem -Path $Global:CONFIG.MetricsDir -Filter "memory-metrics-*.json" | Select-Object -First 1
    Assert-Test "Get-MemoryMetrics creates metrics file" ($metricsFile -ne $null)
    
    # Test Test-MemorySafe
    Write-Host "Testing Test-MemorySafe..." -ForegroundColor Yellow
    $safetyStatus = Test-MemorySafe
    Assert-Test "Test-MemorySafe returns safety status" ($safetyStatus -ne $null)
    Assert-Test "Test-MemorySafe includes IsSafe property" ($safetyStatus.ContainsKey("IsSafe"))
    
    # Test Start-ProcessCleanup
    Write-Host "Testing Start-ProcessCleanup..." -ForegroundColor Yellow
    $cleanupResult = Start-ProcessCleanup -Force
    
    # Test Set-NpmConfig
    Write-Host "Testing Set-NpmConfig..." -ForegroundColor Yellow
    $configResult = Set-NpmConfig
    Assert-Test "Set-NpmConfig returns true for successful configuration" $configResult
    
    # Test Start-NpmOperation (simple test without actually running npm)
    Write-Host "Testing Start-NpmOperation Mock..." -ForegroundColor Yellow
    # Mock Invoke-Expression for testing
    function Global:Invoke-Expression { param($Command) return "Mock: $Command" }
    
    $operationResult = Start-NpmOperation -Command "install test-package"
    Assert-Test "Start-NpmOperation returns true for successful operation" $operationResult
    
    Write-Host "All tests completed." -ForegroundColor Green
}

# Assert helper function
function Assert-Test {
    param(
        [string]$TestName,
        [bool]$Condition
    )
    
    if ($Condition) {
        Write-Host "  [PASS] $TestName" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] $TestName" -ForegroundColor Red
        $Global:TestsFailed++
    }
}

# Run tests
$Global:TestsFailed = 0
Run-MemoryManagerTests

# Return test status
if ($Global:TestsFailed -gt 0) {
    Write-Host "$Global:TestsFailed test(s) failed." -ForegroundColor Red
    exit 1
} else {
    Write-Host "All tests passed successfully." -ForegroundColor Green
    exit 0
} 