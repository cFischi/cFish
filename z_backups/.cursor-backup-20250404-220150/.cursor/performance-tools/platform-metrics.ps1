# Cross-platform metric correlation functions
$ErrorActionPreference = "Stop"
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$metricsPath = Join-Path $scriptPath "..\pillar-configs"
$platformMetricsPath = Join-Path $scriptPath "..\platform-metrics"

function Get-WordPressMetrics {
    $wpMetricsFile = Join-Path $platformMetricsPath "wordpress-metrics.json"
    if (Test-Path $wpMetricsFile) {
        return Get-Content $wpMetricsFile | ConvertFrom-Json
    }
    return $null
}

function Get-ClickUpMetrics {
    $cuMetricsFile = Join-Path $platformMetricsPath "clickup-metrics.json"
    if (Test-Path $cuMetricsFile) {
        return Get-Content $cuMetricsFile | ConvertFrom-Json
    }
    return $null
}

function Get-NotionMetrics {
    $notionMetricsFile = Join-Path $platformMetricsPath "notion-metrics.json"
    if (Test-Path $notionMetricsFile) {
        return Get-Content $notionMetricsFile | ConvertFrom-Json
    }
    return $null
}

function Get-VendasaMetrics {
    $vendasaMetricsFile = Join-Path $platformMetricsPath "vendasa-metrics.json"
    if (Test-Path $vendasaMetricsFile) {
        return Get-Content $vendasaMetricsFile | ConvertFrom-Json
    }
    return $null
}

function Compare-PlatformPerformance {
    param($metrics)
    
    $performanceScores = @{}
    foreach ($platform in $metrics.Keys) {
        if ($metrics[$platform]) {
            $performanceScores[$platform] = @{
                responseTime = $metrics[$platform].performance.responseTime
                throughput = $metrics[$platform].performance.throughput
                reliability = $metrics[$platform].performance.reliability
                score = Calculate-PerformanceScore $metrics[$platform]
            }
        }
    }
    
    return $performanceScores
}

function Analyze-IntegrationEfficiency {
    param($metrics)
    
    $integrationScores = @{}
    foreach ($platform in $metrics.Keys) {
        if ($metrics[$platform]) {
            $integrationScores[$platform] = @{
                syncSuccess = $metrics[$platform].integration.syncRate
                dataAccuracy = $metrics[$platform].integration.accuracy
                latency = $metrics[$platform].integration.latency
                score = Calculate-IntegrationScore $metrics[$platform]
            }
        }
    }
    
    return $integrationScores
}

function Calculate-OptimizationImpact {
    param($metrics)
    
    $optimizationScores = @{}
    foreach ($platform in $metrics.Keys) {
        if ($metrics[$platform]) {
            $optimizationScores[$platform] = @{
                resourceUsage = $metrics[$platform].optimization.resourceUsage
                efficiency = $metrics[$platform].optimization.efficiency
                costImpact = $metrics[$platform].optimization.costImpact
                score = Calculate-OptimizationScore $metrics[$platform]
            }
        }
    }
    
    return $optimizationScores
}

function Calculate-PerformanceScore {
    param($platformMetrics)
    
    $weights = @{
        responseTime = 0.4
        throughput = 0.3
        reliability = 0.3
    }
    
    $score = ($platformMetrics.performance.responseTime * $weights.responseTime +
              $platformMetrics.performance.throughput * $weights.throughput +
              $platformMetrics.performance.reliability * $weights.reliability)
              
    return [math]::Round($score, 2)
}

function Calculate-IntegrationScore {
    param($platformMetrics)
    
    $weights = @{
        syncRate = 0.4
        accuracy = 0.4
        latency = 0.2
    }
    
    $score = ($platformMetrics.integration.syncRate * $weights.syncRate +
              $platformMetrics.integration.accuracy * $weights.accuracy +
              (100 - $platformMetrics.integration.latency) * $weights.latency)
              
    return [math]::Round($score, 2)
}

function Calculate-OptimizationScore {
    param($platformMetrics)
    
    $weights = @{
        resourceUsage = 0.3
        efficiency = 0.4
        costImpact = 0.3
    }
    
    $score = ((100 - $platformMetrics.optimization.resourceUsage) * $weights.resourceUsage +
              $platformMetrics.optimization.efficiency * $weights.efficiency +
              $platformMetrics.optimization.costImpact * $weights.costImpact)
              
    return [math]::Round($score, 2)
}

function Analyze-CrossPlatformMetrics {
    $metrics = @{
        "cFish.io" = Get-WordPressMetrics
        "cFish.App" = Get-ClickUpMetrics
        "U.cFish.io" = Get-NotionMetrics
        "cFish.Vip" = Get-VendasaMetrics
    }
    
    $correlations = @{
        timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        performance = Compare-PlatformPerformance $metrics
        integration = Analyze-IntegrationEfficiency $metrics
        optimization = Calculate-OptimizationImpact $metrics
    }
    
    # Calculate overall health scores
    $correlations.overallHealth = @{
        performance = Calculate-AverageScore $correlations.performance
        integration = Calculate-AverageScore $correlations.integration
        optimization = Calculate-AverageScore $correlations.optimization
    }
    
    return $correlations
}

function Calculate-AverageScore {
    param($metrics)
    
    $total = 0
    $count = 0
    
    foreach ($platform in $metrics.Keys) {
        if ($metrics[$platform].score) {
            $total += $metrics[$platform].score
            $count++
        }
    }
    
    return if ($count -gt 0) { [math]::Round($total / $count, 2) } else { 0 }
}

Export-ModuleMember -Function Analyze-CrossPlatformMetrics 