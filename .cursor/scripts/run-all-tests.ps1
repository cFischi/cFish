# run-all-tests.ps1
# Comprehensive test runner for all .cursor components
#
# This script runs all test frameworks and generates a consolidated report
# of test results. It includes:
# - Installation script testing
# - Component testing
# - Integration testing
# - Performance testing

param (
    [switch]$IncludePerformance = $false,
    [switch]$GenerateReport = $true,
    [switch]$Verbose
)

$ErrorActionPreference = "Stop"

# Configuration
$config = @{
    TestOutputDir = ".cursor/test-results"
    ReportDir = ".cursor/test-results/reports"
    LogDir = ".cursor/test-results/logs"
    TestFrameworks = @(
        @{
            Name = "Installation Scripts"
            Command = ".cursor/scripts/test-installation-scripts.ps1"
            ReportPath = ".cursor/test-results/reports/installation-report.html"
            Priority = "CRITICAL"
        },
        @{
            Name = "Component Tests"
            Command = "npm run test:d3"
            ReportPath = "coverage/lcov-report/index.html"
            Priority = "CRITICAL"
        },
        @{
            Name = "Integration Tests"
            Command = "npm test"
            ReportPath = "coverage/lcov-report/index.html"
            Priority = "CRITICAL"
        }
    )
    PerformanceTests = @(
        @{
            Name = "Process Tree Rendering"
            Command = ".cursor/performance-tools/test-process-tree-performance.ps1"
            ReportPath = ".cursor/performance-tools/reports/process-tree-perf.html"
            Threshold = @{
                RenderTime = 16  # ms
                MemoryUsage = 100  # MB
            }
        },
        @{
            Name = "Memory Management"
            Command = ".cursor/performance-tools/test-memory-manager-performance.ps1"
            ReportPath = ".cursor/performance-tools/reports/memory-manager-perf.html"
            Threshold = @{
                MemoryUsage = 50  # MB
                ProcessCount = 10
            }
        }
    )
}

# Initialize test environment
function Initialize-TestEnvironment {
    Write-Host "Initializing test environment..." -ForegroundColor Cyan
    
    # Create necessary directories
    $dirs = @(
        $config.TestOutputDir,
        $config.ReportDir,
        $config.LogDir
    )
    
    foreach ($dir in $dirs) {
        if (!(Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
        }
    }
    
    # Initialize consolidated report
    $reportFile = "$($config.ReportDir)/consolidated-report.html"
    if (Test-Path $reportFile) {
        Remove-Item $reportFile -Force
    }
    
    # Setup log file
    $logFile = "$($config.LogDir)/test-run-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"
    "" | Set-Content -Path $logFile
    
    Write-Host "Test environment initialized." -ForegroundColor Green
    Write-Host "Test output directory: $($config.TestOutputDir)" -ForegroundColor Gray
    Write-Host "Log file: $logFile" -ForegroundColor Gray
    
    return @{
        LogFile = $logFile
        ReportFile = $reportFile
    }
}

# Log function
function Write-TestLog {
    param(
        [string]$Message,
        [ValidateSet("INFO", "WARNING", "ERROR", "SUCCESS")]
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    # Write to log file
    $logFile = "$($config.LogDir)/test-run-$(Get-Date -Format 'yyyyMMdd').log"
    $logMessage | Out-File -Append -FilePath $logFile
    
    # Write to console with colors
    switch ($Level) {
        "WARNING" { Write-Host $logMessage -ForegroundColor Yellow }
        "ERROR" { Write-Host $logMessage -ForegroundColor Red }
        "SUCCESS" { Write-Host $logMessage -ForegroundColor Green }
        default { 
            if ($Verbose) {
                Write-Host $logMessage -ForegroundColor Gray
            }
        }
    }
}

# Run a test framework
function Invoke-TestFramework {
    param(
        [hashtable]$Framework
    )
    
    Write-Host "Running test framework: $($Framework.Name)" -ForegroundColor Cyan
    Write-TestLog "Starting test framework: $($Framework.Name)" -Level "INFO"
    
    try {
        $start = Get-Date
        
        # Execute the test command
        if ($Framework.Command.EndsWith(".ps1")) {
            # PowerShell script
            $result = & $Framework.Command
            $exitCode = $LASTEXITCODE
        }
        else {
            # npm command
            $result = Invoke-Expression $Framework.Command
            $exitCode = $LASTEXITCODE
        }
        
        $end = Get-Date
        $duration = ($end - $start).TotalSeconds
        
        $success = $exitCode -eq 0
        $level = if ($success) { "SUCCESS" } else { "ERROR" }
        $status = if ($success) { "PASSED" } else { "FAILED" }
        
        Write-Host "Test framework $($Framework.Name): $status (Duration: $([math]::Round($duration, 2))s)" -ForegroundColor $(if ($success) { "Green" } else { "Red" })
        Write-TestLog "Test framework $($Framework.Name) completed: $status (Duration: $([math]::Round($duration, 2))s)" -Level $level
        
        # Verify report file exists
        $reportExists = Test-Path $Framework.ReportPath
        if (-not $reportExists) {
            Write-TestLog "Warning: Report file not found: $($Framework.ReportPath)" -Level "WARNING"
        }
        
        return @{
            Name = $Framework.Name
            Success = $success
            Duration = $duration
            ReportPath = if ($reportExists) { $Framework.ReportPath } else { $null }
            Priority = $Framework.Priority
        }
    }
    catch {
        Write-Host "Error running test framework $($Framework.Name): $_" -ForegroundColor Red
        Write-TestLog "Error running test framework $($Framework.Name): $_" -Level "ERROR"
        
        return @{
            Name = $Framework.Name
            Success = $false
            Duration = 0
            ReportPath = $null
            Priority = $Framework.Priority
            ErrorMessage = $_.Exception.Message
        }
    }
}

# Run a performance test
function Invoke-PerformanceTest {
    param(
        [hashtable]$Test
    )
    
    Write-Host "Running performance test: $($Test.Name)" -ForegroundColor Cyan
    Write-TestLog "Starting performance test: $($Test.Name)" -Level "INFO"
    
    try {
        $start = Get-Date
        
        # Execute the test command
        if ($Test.Command.EndsWith(".ps1")) {
            # PowerShell script
            $result = & $Test.Command
            $exitCode = $LASTEXITCODE
        }
        else {
            # npm command
            $result = Invoke-Expression $Test.Command
            $exitCode = $LASTEXITCODE
        }
        
        $end = Get-Date
        $duration = ($end - $start).TotalSeconds
        
        $success = $exitCode -eq 0
        $level = if ($success) { "SUCCESS" } else { "ERROR" }
        $status = if ($success) { "PASSED" } else { "FAILED" }
        
        Write-Host "Performance test $($Test.Name): $status (Duration: $([math]::Round($duration, 2))s)" -ForegroundColor $(if ($success) { "Green" } else { "Red" })
        Write-TestLog "Performance test $($Test.Name) completed: $status (Duration: $([math]::Round($duration, 2))s)" -Level $level
        
        # Verify report file exists
        $reportExists = Test-Path $Test.ReportPath
        if (-not $reportExists) {
            Write-TestLog "Warning: Report file not found: $($Test.ReportPath)" -Level "WARNING"
        }
        
        return @{
            Name = $Test.Name
            Success = $success
            Duration = $duration
            ReportPath = if ($reportExists) { $Test.ReportPath } else { $null }
            Thresholds = $Test.Threshold
        }
    }
    catch {
        Write-Host "Error running performance test $($Test.Name): $_" -ForegroundColor Red
        Write-TestLog "Error running performance test $($Test.Name): $_" -Level "ERROR"
        
        return @{
            Name = $Test.Name
            Success = $false
            Duration = 0
            ReportPath = $null
            Thresholds = $Test.Threshold
            ErrorMessage = $_.Exception.Message
        }
    }
}

# Generate consolidated HTML report
function New-ConsolidatedReport {
    param(
        [array]$TestResults,
        [array]$PerformanceResults,
        [string]$OutputPath
    )
    
    Write-Host "Generating consolidated test report..." -ForegroundColor Cyan
    
    $totalTests = $TestResults.Count
    $passedTests = ($TestResults | Where-Object { $_.Success -eq $true }).Count
    $criticalTests = ($TestResults | Where-Object { $_.Priority -eq "CRITICAL" }).Count
    $passedCriticalTests = ($TestResults | Where-Object { $_.Priority -eq "CRITICAL" -and $_.Success -eq $true }).Count
    
    $passRate = if ($totalTests -gt 0) { [math]::Round(100 * $passedTests / $totalTests, 2) } else { 0 }
    $criticalPassRate = if ($criticalTests -gt 0) { [math]::Round(100 * $passedCriticalTests / $criticalTests, 2) } else { 0 }
    
    # Generate test results rows
    $testRows = ""
    foreach ($result in $TestResults) {
        $statusClass = if ($result.Success) { "success" } else { "danger" }
        $status = if ($result.Success) { "PASSED" } else { "FAILED" }
        $priorityClass = if ($result.Priority -eq "CRITICAL") { "critical" } else { "normal" }
        $reportLink = if ($result.ReportPath) { "<a href='$($result.ReportPath)' target='_blank'>View Report</a>" } else { "N/A" }
        $errorMsg = if ($result.ErrorMessage) { $result.ErrorMessage } else { "" }
        
        $testRows += @"
        <tr class="$statusClass">
            <td>$($result.Name)</td>
            <td class="$priorityClass">$($result.Priority)</td>
            <td>$status</td>
            <td>$([math]::Round($result.Duration, 2))s</td>
            <td>$reportLink</td>
            <td>$errorMsg</td>
        </tr>
"@
    }
    
    # Generate performance results rows
    $perfRows = ""
    if ($PerformanceResults.Count -gt 0) {
        foreach ($result in $PerformanceResults) {
            $statusClass = if ($result.Success) { "success" } else { "danger" }
            $status = if ($result.Success) { "PASSED" } else { "FAILED" }
            $reportLink = if ($result.ReportPath) { "<a href='$($result.ReportPath)' target='_blank'>View Report</a>" } else { "N/A" }
            $thresholds = if ($result.Thresholds) {
                $thresholdStr = ""
                foreach ($key in $result.Thresholds.Keys) {
                    $thresholdStr += "$key`: $($result.Thresholds[$key])<br>"
                }
                $thresholdStr
            } else { "N/A" }
            $errorMsg = if ($result.ErrorMessage) { $result.ErrorMessage } else { "" }
            
            $perfRows += @"
            <tr class="$statusClass">
                <td>$($result.Name)</td>
                <td>$status</td>
                <td>$([math]::Round($result.Duration, 2))s</td>
                <td>$thresholds</td>
                <td>$reportLink</td>
                <td>$errorMsg</td>
            </tr>
"@
        }
    }
    
    # Generate HTML report
    $html = @"
<!DOCTYPE html>
<html>
<head>
    <title>Consolidated Test Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        h1, h2 { color: #333; }
        .summary {
            background-color: #f5f5f5;
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
        .metrics {
            display: flex;
            flex-wrap: wrap;
            gap: 20px;
            margin-bottom: 20px;
        }
        .metric {
            background-color: #fff;
            border: 1px solid #ddd;
            border-radius: 5px;
            padding: 15px;
            min-width: 200px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .metric h3 { margin-top: 0; }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 20px;
        }
        th, td {
            border: 1px solid #ddd;
            padding: 10px;
            text-align: left;
        }
        th {
            background-color: #f5f5f5;
            font-weight: bold;
        }
        tr.success td { background-color: #dff0d8; }
        tr.danger td { background-color: #f2dede; }
        td.critical { font-weight: bold; color: #a94442; }
        .progress {
            height: 20px;
            width: 100%;
            background-color: #f5f5f5;
            border-radius: 5px;
            margin-bottom: 10px;
            overflow: hidden;
        }
        .progress-bar {
            height: 100%;
            background-color: #5cb85c;
            text-align: center;
            line-height: 20px;
            color: white;
        }
        .progress-bar.critical { background-color: #d9534f; }
    </style>
</head>
<body>
    <h1>Consolidated Test Report</h1>
    <div class="summary">
        <p>Test run completed at $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")</p>
        <div class="metrics">
            <div class="metric">
                <h3>Test Results</h3>
                <p>Total Tests: $totalTests</p>
                <p>Passed: $passedTests ($passRate%)</p>
                <p>Failed: $($totalTests - $passedTests) ($([math]::Round(100 - $passRate, 2))%)</p>
                <div class="progress">
                    <div class="progress-bar" style="width: $passRate%">$passRate%</div>
                </div>
            </div>
            <div class="metric">
                <h3>Critical Tests</h3>
                <p>Total Critical: $criticalTests</p>
                <p>Passed: $passedCriticalTests ($criticalPassRate%)</p>
                <p>Failed: $($criticalTests - $passedCriticalTests) ($([math]::Round(100 - $criticalPassRate, 2))%)</p>
                <div class="progress">
                    <div class="progress-bar critical" style="width: $criticalPassRate%">$criticalPassRate%</div>
                </div>
            </div>
            <div class="metric">
                <h3>Performance</h3>
                <p>Performance Tests: $($PerformanceResults.Count)</p>
                <p>Passed: $($PerformanceResults | Where-Object { $_.Success -eq $true }).Count</p>
                <p>Failed: $($PerformanceResults | Where-Object { $_.Success -eq $false }).Count</p>
            </div>
        </div>
    </div>
    
    <h2>Test Framework Results</h2>
    <table>
        <tr>
            <th>Test Framework</th>
            <th>Priority</th>
            <th>Status</th>
            <th>Duration</th>
            <th>Report</th>
            <th>Error</th>
        </tr>
        $testRows
    </table>
    
$(
if ($PerformanceResults.Count -gt 0) {
@"
    <h2>Performance Test Results</h2>
    <table>
        <tr>
            <th>Test</th>
            <th>Status</th>
            <th>Duration</th>
            <th>Thresholds</th>
            <th>Report</th>
            <th>Error</th>
        </tr>
        $perfRows
    </table>
"@
}
)
    
    <p>Report generated at $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")</p>
</body>
</html>
"@
    
    $html | Set-Content -Path $OutputPath
    Write-Host "Consolidated report generated: $OutputPath" -ForegroundColor Green
    Write-TestLog "Consolidated report generated: $OutputPath" -Level "SUCCESS"
}

# Main execution
function Start-TestExecution {
    $env = Initialize-TestEnvironment
    
    Write-Host "Starting test execution..." -ForegroundColor Cyan
    Write-TestLog "Starting comprehensive test execution" -Level "INFO"
    
    # Run all test frameworks
    $testResults = @()
    foreach ($framework in $config.TestFrameworks) {
        $result = Invoke-TestFramework -Framework $framework
        $testResults += $result
    }
    
    # Run performance tests if requested
    $performanceResults = @()
    if ($IncludePerformance) {
        Write-Host "Running performance tests..." -ForegroundColor Cyan
        Write-TestLog "Starting performance test execution" -Level "INFO"
        
        foreach ($test in $config.PerformanceTests) {
            $result = Invoke-PerformanceTest -Test $test
            $performanceResults += $result
        }
    }
    
    # Generate consolidated report
    if ($GenerateReport) {
        New-ConsolidatedReport -TestResults $testResults -PerformanceResults $performanceResults -OutputPath $env.ReportFile
    }
    
    # Check if any critical tests failed
    $criticalFailed = $testResults | Where-Object { $_.Priority -eq "CRITICAL" -and $_.Success -eq $false }
    if ($criticalFailed.Count -gt 0) {
        Write-Host "CRITICAL FAILURE: $($criticalFailed.Count) critical tests failed!" -ForegroundColor Red
        Write-TestLog "CRITICAL FAILURE: $($criticalFailed.Count) critical tests failed!" -Level "ERROR"
        foreach ($failure in $criticalFailed) {
            Write-Host "  - $($failure.Name): $($failure.ErrorMessage)" -ForegroundColor Red
        }
        return $false
    }
    
    # Check if any tests failed
    $failed = $testResults | Where-Object { $_.Success -eq $false }
    if ($failed.Count -gt 0) {
        Write-Host "WARNING: $($failed.Count) non-critical tests failed." -ForegroundColor Yellow
        Write-TestLog "WARNING: $($failed.Count) non-critical tests failed." -Level "WARNING"
        return $true  # Still success since only non-critical tests failed
    }
    
    Write-Host "All tests passed successfully!" -ForegroundColor Green
    Write-TestLog "All tests passed successfully!" -Level "SUCCESS"
    return $true
}

# Run tests
try {
    $success = Start-TestExecution
    exit $(if ($success) { 0 } else { 1 })
}
catch {
    Write-Host "Unhandled error in test execution: $_" -ForegroundColor Red
    Write-TestLog "Unhandled error in test execution: $_" -Level "ERROR"
    exit 1
} 