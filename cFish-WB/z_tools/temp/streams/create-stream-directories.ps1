# Stream Directory Creation Script
# Created: 2025-03-25
# Purpose: Create all required directories for cFish.io Phase 3 implementation streams

# Stream definitions
$streams = @(
    @{Id = 1; Name = "Advanced-Integration"; Tasks = @("Setup", "External-API-Framework", "Third-Party-Service-Connectors", "Data-Exchange-Protocols", "Integration-Monitoring")},
    @{Id = 2; Name = "Knowledge-Management"; Tasks = @("Setup", "Enhanced-Knowledge-Base", "Semantic-Search-Capabilities", "Knowledge-Visualization-Tools", "Knowledge-Analytics")},
    @{Id = 3; Name = "Security-Compliance"; Tasks = @("Setup", "Enhanced-Authentication", "Compliance-Reporting", "Data-Protection-Measures", "Security-Monitoring-Dashboard")},
    @{Id = 4; Name = "Performance-Scalability"; Tasks = @("Setup", "Database-Optimization", "Load-Balancing-Solution", "Caching-Strategy", "Performance-Monitoring-Tools")}
)

# Standard subdirectories to create for each task
$standardDirs = @("docs", "templates", "reports", "completed")

# Create root streams directory if it doesn't exist
$streamRoot = "cFish-WB/streams"
if (-not (Test-Path $streamRoot)) {
    New-Item -ItemType Directory -Path $streamRoot -Force | Out-Null
    Write-Output "Created root streams directory: $streamRoot"
}

# Create all stream directories
foreach ($stream in $streams) {
    $streamPath = "$streamRoot/Stream-$($stream.Id)-$($stream.Name)"
    if (-not (Test-Path $streamPath)) {
        New-Item -ItemType Directory -Path $streamPath -Force | Out-Null
        Write-Output "Created stream directory: $streamPath"
    }
    
    # Create task directories and standard subdirectories
    foreach ($task in $stream.Tasks) {
        $taskPath = "$streamPath/S$($stream.Id)-$(([string]$streams.Tasks.IndexOf($task)).PadLeft(3, '0'))-$task"
        if (-not (Test-Path $taskPath)) {
            New-Item -ItemType Directory -Path $taskPath -Force | Out-Null
            Write-Output "Created task directory: $taskPath"
        }
        
        # Create standard subdirectories
        foreach ($dir in $standardDirs) {
            $dirPath = "$taskPath/$dir"
            if (-not (Test-Path $dirPath)) {
                New-Item -ItemType Directory -Path $dirPath -Force | Out-Null
                Write-Output "Created directory: $dirPath"
            }
        }
    }
}

Write-Output "Directory creation complete." 