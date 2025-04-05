# Script to check monitoring status and view reports
$ErrorActionPreference = "Stop"
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$logFile = Join-Path $scriptPath "..\logs\monitoring.log"
$pidFile = Join-Path $scriptPath "monitoring.pid"
$reportsPath = Join-Path $scriptPath "..\md"
$pillarMetricsPath = Join-Path $scriptPath "..\pillar-configs"
$exportPath = Join-Path $scriptPath "exports"

# Import platform metrics module
Import-Module (Join-Path $scriptPath "platform-metrics.ps1") -Force

function Show-Menu {
    Clear-Host
    Write-Host "=== UcF Monitoring System Status ===" -ForegroundColor Cyan
    Write-Host "1. Check Monitoring Status"
    Write-Host "2. View Latest Logs"
    Write-Host "3. View memory.md"
    Write-Host "4. View changelog.md"
    Write-Host "5. Start Monitoring"
    Write-Host "6. Stop Monitoring"
    Write-Host ""
    Write-Host "Pillar Metrics:" -ForegroundColor Yellow
    Write-Host "7. U1 - Administration"
    Write-Host "8. U2 - Research"
    Write-Host "9. U4 - Production"
    Write-Host "10. U7 - Systems"
    Write-Host ""
    Write-Host "Platform Analysis:" -ForegroundColor Magenta
    Write-Host "11. Cross-Platform Metrics"
    Write-Host "12. Predictive Analytics"
    Write-Host ""
    Write-Host "Reports:" -ForegroundColor Green
    Write-Host "13. Relaunch Priorities Status"
    Write-Host "14. Export Reports"
    Write-Host "Q. Quit"
    Write-Host ""
}

function Check-MonitoringStatus {
    if (Test-Path $pidFile) {
        $processId = Get-Content $pidFile
        $process = Get-Process -Id $processId -ErrorAction SilentlyContinue
        if ($process) {
            Write-Host "Monitoring system is RUNNING (PID: $processId)" -ForegroundColor Green
        } else {
            Write-Host "Monitoring system is NOT running" -ForegroundColor Red
            Remove-Item $pidFile -Force
        }
    } else {
        Write-Host "Monitoring system is NOT running" -ForegroundColor Red
    }
}

function View-Logs {
    if (Test-Path $logFile) {
        Get-Content $logFile -Tail 20
    } else {
        Write-Host "No log file found" -ForegroundColor Yellow
    }
}

function View-File {
    param($filename)
    $file = Join-Path $reportsPath $filename
    if (Test-Path $file) {
        Get-Content $file | More
    } else {
        Write-Host "File not found: $filename" -ForegroundColor Yellow
    }
}

function Start-MonitoringSystem {
    & "$scriptPath\auto-start.ps1"
}

function Stop-MonitoringSystem {
    if (Test-Path $pidFile) {
        $processId = Get-Content $pidFile
        $process = Get-Process -Id $processId -ErrorAction SilentlyContinue
        if ($process) {
            Stop-Process -Id $processId -Force
            Remove-Item $pidFile -Force
            Write-Host "Monitoring system stopped" -ForegroundColor Yellow
        }
    }
}

function View-PillarMetrics {
    param($pillarId)
    
    $pillarMap = @{
        "U1" = "Administration"
        "U2" = "Research"
        "U4" = "Production"
        "U7" = "Systems"
    }
    
    $metricsFile = Join-Path $pillarMetricsPath "$pillarId-metrics.json"
    if (Test-Path $metricsFile) {
        $metrics = Get-Content $metricsFile | ConvertFrom-Json
        
        Write-Host "=== $pillarId - $($pillarMap[$pillarId]) Metrics ===" -ForegroundColor Cyan
        Write-Host "Token Usage: $($metrics.tokenUsage)%" -ForegroundColor Yellow
        Write-Host "Efficiency: $($metrics.efficiency)%" -ForegroundColor Yellow
        Write-Host "Load Time: $($metrics.loadTime)ms" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Specific Metrics:" -ForegroundColor Magenta
        
        switch ($pillarId) {
            "U1" {
                Write-Host "Documentation Quality: $($metrics.docQuality)%"
                Write-Host "Process Efficiency: $($metrics.processEfficiency)%"
            }
            "U2" {
                Write-Host "AI Response Time: $($metrics.aiResponseTime)ms"
                Write-Host "Model Accuracy: $($metrics.modelAccuracy)%"
            }
            "U4" {
                Write-Host "WordPress Performance: $($metrics.wpPerformance)%"
                Write-Host "Content Delivery: $($metrics.contentDelivery)ms"
            }
            "U7" {
                Write-Host "System Uptime: $($metrics.uptime)%"
                Write-Host "Integration Health: $($metrics.integrationHealth)%"
            }
        }
    } else {
        Write-Host "No metrics found for $pillarId" -ForegroundColor Red
    }
}

function View-CrossPlatformMetrics {
    $metrics = Analyze-CrossPlatformMetrics
    
    Write-Host "=== Cross-Platform Analysis ===" -ForegroundColor Cyan
    Write-Host "Timestamp: $($metrics.timestamp)" -ForegroundColor Yellow
    Write-Host ""
    
    Write-Host "Performance Metrics:" -ForegroundColor Magenta
    foreach ($platform in $metrics.performance.Keys) {
        Write-Host "$platform" -ForegroundColor Yellow
        Write-Host "  Response Time: $($metrics.performance[$platform].responseTime)ms"
        Write-Host "  Throughput: $($metrics.performance[$platform].throughput)"
        Write-Host "  Reliability: $($metrics.performance[$platform].reliability)%"
        Write-Host "  Score: $($metrics.performance[$platform].score)" -ForegroundColor Green
        Write-Host ""
    }
    
    Write-Host "Integration Metrics:" -ForegroundColor Magenta
    foreach ($platform in $metrics.integration.Keys) {
        Write-Host "$platform" -ForegroundColor Yellow
        Write-Host "  Sync Success: $($metrics.integration[$platform].syncSuccess)%"
        Write-Host "  Data Accuracy: $($metrics.integration[$platform].dataAccuracy)%"
        Write-Host "  Latency: $($metrics.integration[$platform].latency)ms"
        Write-Host "  Score: $($metrics.integration[$platform].score)" -ForegroundColor Green
        Write-Host ""
    }
    
    Write-Host "Overall Health:" -ForegroundColor Cyan
    Write-Host "  Performance: $($metrics.overallHealth.performance)" -ForegroundColor Green
    Write-Host "  Integration: $($metrics.overallHealth.integration)" -ForegroundColor Green
    Write-Host "  Optimization: $($metrics.overallHealth.optimization)" -ForegroundColor Green
}

function View-PredictiveAnalytics {
    $predictions = & node (Join-Path $scriptPath "predictive-analytics.js")
    $results = $predictions | ConvertFrom-Json
    
    Write-Host "=== Predictive Analytics ===" -ForegroundColor Cyan
    Write-Host "Generated: $($results.timestamp)" -ForegroundColor Yellow
    Write-Host ""
    
    Write-Host "Token Predictions:" -ForegroundColor Magenta
    Write-Host "Next Day: $($results.tokenPrediction.projected.nextDay)"
    Write-Host "Next Week: $($results.tokenPrediction.projected.nextWeek)"
    Write-Host "Next Month: $($results.tokenPrediction.projected.nextMonth)"
    Write-Host ""
    
    Write-Host "Performance Forecast:" -ForegroundColor Magenta
    Write-Host "Next Day: $($results.performanceForecast.projected.nextDay)"
    Write-Host "Next Week: $($results.performanceForecast.projected.nextWeek)"
    Write-Host "Next Month: $($results.performanceForecast.projected.nextMonth)"
    Write-Host ""
    
    Write-Host "Recommendations:" -ForegroundColor Green
    foreach ($rec in $results.tokenPrediction.recommendations) {
        Write-Host "[$($rec.priority)] $($rec.action)" -ForegroundColor Yellow
        Write-Host "  Impact: $($rec.impact)"
    }
    
    Write-Host ""
    Write-Host "Prediction Confidence:" -ForegroundColor Cyan
    Write-Host "Overall: $($results.confidence.overall)%" -ForegroundColor Green
    Write-Host "Token: $($results.confidence.components.token)%"
    Write-Host "Performance: $($results.confidence.components.performance)%"
    Write-Host "Optimization: $($results.confidence.components.optimization)%"
}

function Check-RelaunchMetrics {
    $relaunchFile = Join-Path $reportsPath "relaunch-metrics.json"
    if (Test-Path $relaunchFile) {
        $relaunchMetrics = Get-Content $relaunchFile | ConvertFrom-Json
        
        Write-Host "=== Relaunch Priorities Status ===" -ForegroundColor Magenta
        Write-Host "Knowledge Monetization: $($relaunchMetrics.knowledgeMonetization.status)" -ForegroundColor Yellow
        Write-Host "Progress: $($relaunchMetrics.knowledgeMonetization.progress)%"
        Write-Host ""
        Write-Host "Cross-Platform Integration: $($relaunchMetrics.crossPlatform.status)" -ForegroundColor Yellow
        Write-Host "Progress: $($relaunchMetrics.crossPlatform.progress)%"
        Write-Host ""
        Write-Host "Token Optimization: $($relaunchMetrics.tokenOptimization.status)" -ForegroundColor Yellow
        Write-Host "Progress: $($relaunchMetrics.tokenOptimization.progress)%"
    } else {
        Write-Host "No relaunch metrics found" -ForegroundColor Red
    }
}

function Export-Reports {
    if (!(Test-Path $exportPath)) {
        New-Item -ItemType Directory -Path $exportPath
    }
    
    $timestamp = Get-Date -Format "yyyy-MM-dd-HHmm"
    $reportFile = Join-Path $exportPath "monitoring-report-$timestamp.json"
    
    $report = @{
        timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        systemStatus = @{
            isRunning = Test-Path $pidFile
            lastCheck = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }
        pillarMetrics = @{}
    }
    
    # Collect pillar metrics
    @("U1", "U2", "U4", "U7") | ForEach-Object {
        $pillarId = $_
        $metricsFile = Join-Path $pillarMetricsPath "$pillarId-metrics.json"
        if (Test-Path $metricsFile) {
            $report.pillarMetrics[$pillarId] = Get-Content $metricsFile | ConvertFrom-Json
        }
    }
    
    # Add relaunch metrics
    $relaunchFile = Join-Path $reportsPath "relaunch-metrics.json"
    if (Test-Path $relaunchFile) {
        $report.relaunchMetrics = Get-Content $relaunchFile | ConvertFrom-Json
    }
    
    $report | ConvertTo-Json -Depth 10 | Out-File $reportFile
    
    Write-Host "Report exported to: $reportFile" -ForegroundColor Green
}

do {
    Show-Menu
    $selection = Read-Host "Please make a selection"
    Write-Host ""
    
    switch ($selection) {
        '1' { Check-MonitoringStatus; pause }
        '2' { View-Logs; pause }
        '3' { View-File "memory.md"; pause }
        '4' { View-File "changelog.md"; pause }
        '5' { Start-MonitoringSystem; pause }
        '6' { Stop-MonitoringSystem; pause }
        '7' { View-PillarMetrics -pillarId "U1"; pause }
        '8' { View-PillarMetrics -pillarId "U2"; pause }
        '9' { View-PillarMetrics -pillarId "U4"; pause }
        '10' { View-PillarMetrics -pillarId "U7"; pause }
        '11' { View-CrossPlatformMetrics; pause }
        '12' { View-PredictiveAnalytics; pause }
        '13' { Check-RelaunchMetrics; pause }
        '14' { Export-Reports; pause }
    }
} until ($selection -eq 'q') 