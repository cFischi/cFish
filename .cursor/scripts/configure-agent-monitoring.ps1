# Agent Monitoring System Configuration Script
# Configures and initializes agent monitoring system

# Console logging setup
function Write-Log {
    param($Message, $Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] [$Level] $Message"
}

# Agent monitoring configuration
$monitoringConfig = @{
    "metrics" = @{
        "performance" = @{
            "responseTime" = @{
                "threshold" = 1000
                "unit" = "ms"
                "alert" = "threshold"
            }
            "accuracy" = @{
                "threshold" = 95
                "unit" = "percent"
                "alert" = "below"
            }
            "efficiency" = @{
                "threshold" = 90
                "unit" = "percent"
                "alert" = "below"
            }
            "reliability" = @{
                "threshold" = 99
                "unit" = "percent"
                "alert" = "below"
            }
        }
        "collaboration" = @{
            "handoffSuccess" = @{
                "threshold" = 95
                "unit" = "percent"
                "alert" = "below"
            }
            "conflictRate" = @{
                "threshold" = 5
                "unit" = "percent"
                "alert" = "above"
            }
            "resolutionTime" = @{
                "threshold" = 300
                "unit" = "seconds"
                "alert" = "threshold"
            }
            "teamEfficiency" = @{
                "threshold" = 90
                "unit" = "percent"
                "alert" = "below"
            }
        }
    }
    "monitoring" = @{
        "interval" = 60
        "retention" = @{
            "raw" = "7d"
            "hourly" = "30d"
            "daily" = "365d"
        }
        "alerting" = @{
            "channels" = @("email", "slack", "dashboard")
            "throttling" = "15m"
            "grouping" = "5m"
        }
    }
}

# Monitoring system functions
function Initialize-MetricsCollection {
    Write-Log "Initializing metrics collection..." "INFO"
    
    $metricsConfig = @{
        "collection" = @{
            "interval" = $monitoringConfig.monitoring.interval
            "metrics" = $monitoringConfig.metrics
        }
        "storage" = @{
            "type" = "time-series"
            "retention" = $monitoringConfig.monitoring.retention
        }
        "aggregation" = @{
            "realtime" = "1m"
            "shortterm" = "5m"
            "longterm" = "1h"
        }
    }

    $metricsConfig | ConvertTo-Json -Depth 10 | Out-File ".cursor/config/metrics-collection.json"
    Write-Log "Metrics collection configuration complete" "SUCCESS"
}

function Initialize-AlertingSystem {
    Write-Log "Initializing alerting system..." "INFO"
    
    $alertingConfig = @{
        "channels" = $monitoringConfig.monitoring.alerting.channels
        "rules" = @{
            "performance" = @{
                "responseTime" = "value > ${monitoringConfig.metrics.performance.responseTime.threshold}ms"
                "accuracy" = "value < ${monitoringConfig.metrics.performance.accuracy.threshold}%"
                "efficiency" = "value < ${monitoringConfig.metrics.performance.efficiency.threshold}%"
                "reliability" = "value < ${monitoringConfig.metrics.performance.reliability.threshold}%"
            }
            "collaboration" = @{
                "handoffSuccess" = "value < ${monitoringConfig.metrics.collaboration.handoffSuccess.threshold}%"
                "conflictRate" = "value > ${monitoringConfig.metrics.collaboration.conflictRate.threshold}%"
                "resolutionTime" = "value > ${monitoringConfig.metrics.collaboration.resolutionTime.threshold}s"
                "teamEfficiency" = "value < ${monitoringConfig.metrics.collaboration.teamEfficiency.threshold}%"
            }
        }
        "throttling" = $monitoringConfig.monitoring.alerting.throttling
        "grouping" = $monitoringConfig.monitoring.alerting.grouping
    }

    $alertingConfig | ConvertTo-Json -Depth 10 | Out-File ".cursor/config/alerting-system.json"
    Write-Log "Alerting system configuration complete" "SUCCESS"
}

function Initialize-DashboardConfig {
    Write-Log "Initializing dashboard configuration..." "INFO"
    
    $dashboardConfig = @{
        "layout" = @{
            "sections" = @(
                @{
                    "title" = "Performance Metrics"
                    "metrics" = @("responseTime", "accuracy", "efficiency", "reliability")
                    "visualization" = "line-chart"
                    "timeRange" = "6h"
                },
                @{
                    "title" = "Collaboration Metrics"
                    "metrics" = @("handoffSuccess", "conflictRate", "resolutionTime", "teamEfficiency")
                    "visualization" = "line-chart"
                    "timeRange" = "6h"
                },
                @{
                    "title" = "Alert History"
                    "type" = "alert-list"
                    "limit" = 100
                },
                @{
                    "title" = "System Health"
                    "type" = "status-panel"
                    "metrics" = @("system_health", "agent_status")
                }
            )
        }
        "refresh" = "1m"
        "timeRange" = @{
            "default" = "6h"
            "options" = @("1h", "6h", "12h", "24h", "7d", "30d")
        }
    }

    $dashboardConfig | ConvertTo-Json -Depth 10 | Out-File ".cursor/config/dashboard-config.json"
    Write-Log "Dashboard configuration complete" "SUCCESS"
}

function Initialize-StorageSystem {
    Write-Log "Initializing storage system..." "INFO"
    
    $storageConfig = @{
        "metrics" = @{
            "type" = "time-series"
            "engine" = "prometheus"
            "retention" = $monitoringConfig.monitoring.retention
        }
        "alerts" = @{
            "type" = "document"
            "engine" = "elasticsearch"
            "retention" = "90d"
        }
        "logs" = @{
            "type" = "document"
            "engine" = "elasticsearch"
            "retention" = "30d"
        }
    }

    $storageConfig | ConvertTo-Json -Depth 10 | Out-File ".cursor/config/storage-system.json"
    Write-Log "Storage system configuration complete" "SUCCESS"
}

# Validation functions
function Test-MetricsSetup {
    Write-Log "Validating metrics setup..." "INFO"
    
    if (Test-Path ".cursor/config/metrics-collection.json") {
        $config = Get-Content ".cursor/config/metrics-collection.json" | ConvertFrom-Json
        if ($config.collection.interval -eq $monitoringConfig.monitoring.interval) {
            Write-Log "Metrics configuration validated" "SUCCESS"
            return $true
        }
    }
    Write-Log "Metrics configuration validation failed" "ERROR"
    return $false
}

function Test-AlertingSetup {
    Write-Log "Validating alerting setup..." "INFO"
    
    if (Test-Path ".cursor/config/alerting-system.json") {
        $config = Get-Content ".cursor/config/alerting-system.json" | ConvertFrom-Json
        if ($config.throttling -eq $monitoringConfig.monitoring.alerting.throttling) {
            Write-Log "Alerting configuration validated" "SUCCESS"
            return $true
        }
    }
    Write-Log "Alerting configuration validation failed" "ERROR"
    return $false
}

function Test-DashboardSetup {
    Write-Log "Validating dashboard setup..." "INFO"
    
    if (Test-Path ".cursor/config/dashboard-config.json") {
        $config = Get-Content ".cursor/config/dashboard-config.json" | ConvertFrom-Json
        if ($config.refresh -eq "1m") {
            Write-Log "Dashboard configuration validated" "SUCCESS"
            return $true
        }
    }
    Write-Log "Dashboard configuration validation failed" "ERROR"
    return $false
}

function Test-StorageSetup {
    Write-Log "Validating storage setup..." "INFO"
    
    if (Test-Path ".cursor/config/storage-system.json") {
        $config = Get-Content ".cursor/config/storage-system.json" | ConvertFrom-Json
        if ($config.metrics.type -eq "time-series") {
            Write-Log "Storage configuration validated" "SUCCESS"
            return $true
        }
    }
    Write-Log "Storage configuration validation failed" "ERROR"
    return $false
}

# Main execution
Write-Log "Starting agent monitoring system configuration" "INFO"

try {
    # Create config directory if it doesn't exist
    if (-not (Test-Path ".cursor/config")) {
        New-Item -ItemType Directory -Path ".cursor/config"
    }

    # Initialize components
    Initialize-MetricsCollection
    Initialize-AlertingSystem
    Initialize-DashboardConfig
    Initialize-StorageSystem

    # Validate setup
    $metrics_valid = Test-MetricsSetup
    $alerting_valid = Test-AlertingSetup
    $dashboard_valid = Test-DashboardSetup
    $storage_valid = Test-StorageSetup
    
    $all_valid = $metrics_valid -and $alerting_valid -and $dashboard_valid -and $storage_valid
    
    if ($all_valid) {
        Write-Log "Agent monitoring system configuration complete" "SUCCESS"
    } else {
        throw "Configuration validation failed"
    }

    # Export configuration results
    $results = @{
        "timestamp" = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        "metrics_configured" = $metrics_valid
        "alerting_configured" = $alerting_valid
        "dashboard_configured" = $dashboard_valid
        "storage_configured" = $storage_valid
        "configuration" = $monitoringConfig
    }

    $results | ConvertTo-Json -Depth 10 | Out-File ".cursor/logs/monitoring-system-setup.json"
    Write-Log "Configuration results exported to .cursor/logs/monitoring-system-setup.json" "INFO"

} catch {
    Write-Log "Error during configuration: $_" "ERROR"
    exit 1
} 