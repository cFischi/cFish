# Production Deployment Testing Script for cFish Process Visualization
# This script validates all components in a production-like environment
# Version: 1.0.0
# Date: 05-07-2025

param(
    [string]$TestMode = "Full", # Options: Full, Component, Integration, Performance
    [string]$LogPath = "$PSScriptRoot\..\logs\deployment-tests",
    [int]$MemoryThresholdMB = 100,
    [switch]$GenerateReport = $true,
    [switch]$VerifyIntegration = $true
)

#region Setup
# Ensure log directory exists
if (-not (Test-Path $LogPath)) {
    New-Item -Path $LogPath -ItemType Directory -Force | Out-Null
}

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$logFile = Join-Path $LogPath "deployment-test-$timestamp.log"
$reportFile = Join-Path $LogPath "deployment-test-report-$timestamp.html"
$errorCount = 0
$warningCount = 0
$testCount = 0
$passCount = 0

function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    $logTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$logTime] [$Level] $Message"
    
    Add-Content -Path $logFile -Value $logMessage
    
    switch ($Level) {
        "ERROR" { 
            Write-Host $logMessage -ForegroundColor Red
            $script:errorCount++
        }
        "WARNING" { 
            Write-Host $logMessage -ForegroundColor Yellow 
            $script:warningCount++
        }
        "SUCCESS" { Write-Host $logMessage -ForegroundColor Green }
        default { Write-Host $logMessage }
    }
}

function Test-Component {
    param(
        [string]$ComponentName,
        [scriptblock]$TestScript
    )
    
    $script:testCount++
    Write-Log "Testing component: $ComponentName" -Level "INFO"
    
    try {
        $result = & $TestScript
        if ($result) {
            Write-Log "Component test passed: $ComponentName" -Level "SUCCESS"
            $script:passCount++
            return $true
        } else {
            Write-Log "Component test failed: $ComponentName" -Level "ERROR"
            return $false
        }
    } catch {
        Write-Log "Error testing component $ComponentName`: $($_.Exception.Message)" -Level "ERROR"
        return $false
    }
}
#endregion

#region Environment Validation
Write-Log "Starting Production Deployment Testing" -Level "INFO"
Write-Log "Test Mode: $TestMode" -Level "INFO"

# Verify system resources
$systemInfo = Get-CimInstance -ClassName Win32_OperatingSystem
$availableMemoryMB = [math]::Round($systemInfo.FreePhysicalMemory / 1024, 2)
$totalMemoryMB = [math]::Round($systemInfo.TotalVisibleMemorySize / 1024, 2)

Write-Log "System memory: $availableMemoryMB MB available of $totalMemoryMB MB total" -Level "INFO"

if ($availableMemoryMB -lt $MemoryThresholdMB) {
    Write-Log "Insufficient memory available for testing. Required: $MemoryThresholdMB MB, Available: $availableMemoryMB MB" -Level "WARNING"
}

# Check for required tools and dependencies
$npmVersion = npm -v
if ($LASTEXITCODE -ne 0) {
    Write-Log "npm not found or not working properly" -Level "ERROR"
    exit 1
} else {
    Write-Log "npm version: $npmVersion" -Level "INFO"
}

# Check for Node.js
$nodeVersion = node -v
if ($LASTEXITCODE -ne 0) {
    Write-Log "Node.js not found or not working properly" -Level "ERROR"
    exit 1
} else {
    Write-Log "Node.js version: $nodeVersion" -Level "INFO"
}
#endregion

#region Component Testing
if ($TestMode -eq "Full" -or $TestMode -eq "Component") {
    Write-Log "Starting component testing..." -Level "INFO"
    
    # Process Tree Visualization Test
    Test-Component -ComponentName "ProcessTreeVisualization" -TestScript {
        Write-Log "Running ProcessTreeVisualization component tests..." -Level "INFO"
        $output = npm test -- --testPathPattern="ProcessTreeVisualization" 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Log "ProcessTreeVisualization tests passed" -Level "SUCCESS"
            return $true
        } else {
            Write-Log "ProcessTreeVisualization tests failed: $output" -Level "ERROR"
            return $false
        }
    }
    
    # Alert Correlation Engine Test
    Test-Component -ComponentName "AlertCorrelationEngine" -TestScript {
        Write-Log "Running Alert Correlation Engine tests..." -Level "INFO"
        $output = npm test -- --testPathPattern="AlertCorrelation" 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Log "Alert Correlation Engine tests passed" -Level "SUCCESS"
            return $true
        } else {
            Write-Log "Alert Correlation Engine tests failed: $output" -Level "ERROR"
            return $false
        }
    }
    
    # Queue Priority System Test
    Test-Component -ComponentName "QueuePrioritySystem" -TestScript {
        Write-Log "Running Queue Priority System tests..." -Level "INFO"
        $output = npm test -- --testPathPattern="QueuePriority" 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Log "Queue Priority System tests passed" -Level "SUCCESS"
            return $true
        } else {
            Write-Log "Queue Priority System tests failed: $output" -Level "ERROR"
            return $false
        }
    }
    
    # Monitoring Dashboard Test
    Test-Component -ComponentName "MonitoringDashboard" -TestScript {
        Write-Log "Running Monitoring Dashboard tests..." -Level "INFO"
        $output = npm test -- --testPathPattern="MonitoringDashboard" 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Log "Monitoring Dashboard tests passed" -Level "SUCCESS"
            return $true
        } else {
            Write-Log "Monitoring Dashboard tests failed: $output" -Level "ERROR"
            return $false
        }
    }
}
#endregion

#region Integration Testing
if ($TestMode -eq "Full" -or $TestMode -eq "Integration") {
    Write-Log "Starting integration testing..." -Level "INFO"
    
    # Cross-Component Integration Test
    Test-Component -ComponentName "CrossComponentIntegration" -TestScript {
        Write-Log "Running Cross-Component Integration tests..." -Level "INFO"
        $output = npm test -- --testPathPattern="integration" 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Log "Cross-Component Integration tests passed" -Level "SUCCESS"
            return $true
        } else {
            Write-Log "Cross-Component Integration tests failed: $output" -Level "ERROR"
            return $false
        }
    }
    
    # Platform Integration Tests
    if ($VerifyIntegration) {
        # WordPress Integration Test
        Test-Component -ComponentName "WordPressIntegration" -TestScript {
            Write-Log "Running WordPress Integration tests..." -Level "INFO"
            $output = npm test -- --testPathPattern="wordpress-integration" 2>&1
            
            if ($LASTEXITCODE -eq 0) {
                Write-Log "WordPress Integration tests passed" -Level "SUCCESS"
                return $true
            } else {
                Write-Log "WordPress Integration tests failed: $output" -Level "ERROR"
                return $false
            }
        }
        
        # ClickUp Integration Test
        Test-Component -ComponentName "ClickUpIntegration" -TestScript {
            Write-Log "Running ClickUp Integration tests..." -Level "INFO"
            $output = npm test -- --testPathPattern="clickup-integration" 2>&1
            
            if ($LASTEXITCODE -eq 0) {
                Write-Log "ClickUp Integration tests passed" -Level "SUCCESS"
                return $true
            } else {
                Write-Log "ClickUp Integration tests failed: $output" -Level "ERROR"
                return $false
            }
        }
        
        # Notion Integration Test
        Test-Component -ComponentName "NotionIntegration" -TestScript {
            Write-Log "Running Notion Integration tests..." -Level "INFO"
            $output = npm test -- --testPathPattern="notion-integration" 2>&1
            
            if ($LASTEXITCODE -eq 0) {
                Write-Log "Notion Integration tests passed" -Level "SUCCESS"
                return $true
            } else {
                Write-Log "Notion Integration tests failed: $output" -Level "ERROR"
                return $false
            }
        }
        
        # Vendasta Integration Test
        Test-Component -ComponentName "VendastaIntegration" -TestScript {
            Write-Log "Running Vendasta Integration tests..." -Level "INFO"
            $output = npm test -- --testPathPattern="vendasta-integration" 2>&1
            
            if ($LASTEXITCODE -eq 0) {
                Write-Log "Vendasta Integration tests passed" -Level "SUCCESS"
                return $true
            } else {
                Write-Log "Vendasta Integration tests failed: $output" -Level "ERROR"
                return $false
            }
        }
    }
}
#endregion

#region Performance Testing
if ($TestMode -eq "Full" -or $TestMode -eq "Performance") {
    Write-Log "Starting performance testing..." -Level "INFO"
    
    # Process Tree Visualization Performance Test
    Test-Component -ComponentName "ProcessTreeVisualizationPerformance" -TestScript {
        Write-Log "Running Process Tree Visualization Performance tests..." -Level "INFO"
        $output = npm test -- --testPathPattern="performance/ProcessTree" 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Log "Process Tree Visualization Performance tests passed" -Level "SUCCESS"
            return $true
        } else {
            Write-Log "Process Tree Visualization Performance tests failed: $output" -Level "ERROR"
            return $false
        }
    }
    
    # Alert Correlation Engine Performance Test
    Test-Component -ComponentName "AlertCorrelationPerformance" -TestScript {
        Write-Log "Running Alert Correlation Engine Performance tests..." -Level "INFO"
        $output = npm test -- --testPathPattern="performance/AlertCorrelation" 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Log "Alert Correlation Engine Performance tests passed" -Level "SUCCESS"
            return $true
        } else {
            Write-Log "Alert Correlation Engine Performance tests failed: $output" -Level "ERROR"
            return $false
        }
    }
    
    # End-to-End System Performance
    Test-Component -ComponentName "EndToEndPerformance" -TestScript {
        Write-Log "Running End-to-End System Performance tests..." -Level "INFO"
        $output = npm test -- --testPathPattern="performance/EndToEnd" 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Log "End-to-End System Performance tests passed" -Level "SUCCESS"
            return $true
        } else {
            Write-Log "End-to-End System Performance tests failed: $output" -Level "ERROR"
            return $false
        }
    }
}
#endregion

#region Report Generation
if ($GenerateReport) {
    Write-Log "Generating test report..." -Level "INFO"
    
    $reportContent = @"
<!DOCTYPE html>
<html>
<head>
    <title>Production Deployment Test Report - $timestamp</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { background-color: #4CAF50; color: white; padding: 10px; }
        .summary { background-color: #f2f2f2; padding: 10px; margin-top: 20px; }
        .test-results { margin-top: 20px; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ddd; padding: 8px; }
        th { padding-top: 12px; padding-bottom: 12px; text-align: left; background-color: #4CAF50; color: white; }
        .pass { color: green; }
        .fail { color: red; }
        .warning { color: orange; }
    </style>
</head>
<body>
    <div class="header">
        <h1>Production Deployment Test Report</h1>
        <p>Generated: $((Get-Date).ToString("yyyy-MM-dd HH:mm:ss"))</p>
    </div>
    
    <div class="summary">
        <h2>Test Summary</h2>
        <p>Total Tests: $testCount</p>
        <p>Passed: $passCount</p>
        <p>Failed: $($testCount - $passCount)</p>
        <p>Errors: $errorCount</p>
        <p>Warnings: $warningCount</p>
        <p>Success Rate: $([math]::Round(($passCount / $testCount) * 100, 2))%</p>
    </div>
    
    <div class="test-results">
        <h2>Test Results</h2>
        <table>
            <tr>
                <th>Component</th>
                <th>Status</th>
                <th>Details</th>
            </tr>
"@

    $logContent = Get-Content $logFile
    $components = @()
    $currentComponent = ""
    
    foreach ($line in $logContent) {
        if ($line -match "Testing component: (.+)") {
            $currentComponent = $matches[1]
            $components += $currentComponent
        }
        
        if ($line -match "Component test (passed|failed): (.+)") {
            $status = $matches[1]
            $component = $matches[2]
            
            if ($status -eq "passed") {
                $statusClass = "pass"
                $statusText = "✓ PASS"
            } else {
                $statusClass = "fail"
                $statusText = "✗ FAIL"
            }
            
            $reportContent += @"
            <tr>
                <td>$component</td>
                <td class="$statusClass">$statusText</td>
                <td></td>
            </tr>
"@
        }
    }
    
    $reportContent += @"
        </table>
    </div>
    
    <div class="system-info">
        <h2>System Information</h2>
        <p>Total Memory: $totalMemoryMB MB</p>
        <p>Available Memory: $availableMemoryMB MB</p>
        <p>Node.js Version: $nodeVersion</p>
        <p>npm Version: $npmVersion</p>
    </div>
    
    <div class="log-excerpt">
        <h2>Log Excerpt</h2>
        <pre>$($logContent | Select-Object -Last 50 | Out-String)</pre>
    </div>
</body>
</html>
"@

    Set-Content -Path $reportFile -Value $reportContent
    Write-Log "Test report generated: $reportFile" -Level "SUCCESS"
}
#endregion

#region Summary
$successRate = [math]::Round(($passCount / $testCount) * 100, 2)
Write-Log "Test Summary:" -Level "INFO"
Write-Log "Total Tests: $testCount" -Level "INFO"
Write-Log "Passed: $passCount" -Level "INFO"
Write-Log "Failed: $($testCount - $passCount)" -Level "INFO"
Write-Log "Errors: $errorCount" -Level "INFO"
Write-Log "Warnings: $warningCount" -Level "INFO"
Write-Log "Success Rate: $successRate%" -Level "INFO"

if ($successRate -ge 90) {
    Write-Log "Production Deployment Testing PASSED" -Level "SUCCESS"
    exit 0
} else {
    Write-Log "Production Deployment Testing FAILED" -Level "ERROR"
    exit 1
}
#endregion 