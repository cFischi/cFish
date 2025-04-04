# Monitoring Dashboard Script
# This script starts the real-time monitoring dashboard
# Version: 1.0.0

param (
    [string]$ConfigPath = "C:\Users\Chris\cFish.io\scripts\..\config\monitoring",
    [string]$MetricsPath = "C:\Users\Chris\cFish.io\scripts\..\logs\monitoring",
    [int]$RefreshInterval = 5
)

$dashboardConfig = Get-Content -Path "$ConfigPath\monitoring-config.json" | ConvertFrom-Json
$metricsFile = Join-Path $MetricsPath "system-metrics.json"

# Launch the dashboard application
try {
    npm run start:dashboard -- --config="$ConfigPath\monitoring-config.json" --metrics="$metricsFile" --refresh=$RefreshInterval
} catch {
    Write-Host "Error starting dashboard: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
