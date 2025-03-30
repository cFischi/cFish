# RepomiX - Repository Management and Integration Tool
# Version: 1.1.0
# Created: 03-28-2025
# Author: AI Assistant (Claude 3.7 Sonnet)

param (
    [Parameter(Mandatory = $false)]
    [string]$Action = "help",
    
    [Parameter(Mandatory = $false)]
    [string]$RepoPath,
    
    [Parameter(Mandatory = $false)]
    [string]$OutputPath,
    
    [Parameter(Mandatory = $false)]
    [switch]$Force,
    
    [Parameter(Mandatory = $false)]
    [switch]$Verbose,
    
    [Parameter(Mandatory = $false)]
    [switch]$Remote,
    
    [Parameter(Mandatory = $false)]
    [string]$BackupPath
)

# Set strict mode and error handling
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Initialize logging
$logFile = Join-Path $PSScriptRoot "repomix.log"
$script:verbose = $Verbose
$script:metricsPath = Join-Path $PSScriptRoot "metrics"

# Ensure metrics directory exists
if (-not (Test-Path $script:metricsPath)) {
    New-Item -ItemType Directory -Path $script:metricsPath -Force | Out-Null
}

function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "$timestamp [$Level] $Message"
    
    if ($script:verbose) {
        Write-Host $logMessage
    }
    
    Add-Content -Path $logFile -Value $logMessage
}

function Show-Help {
    Write-Host @"
RepomiX - Repository Management and Integration Tool
Version: 1.1.0

Usage:
    .\repomix.ps1 [action] [options]

Actions:
    analyze     - Analyze repository structure and dependencies
    integrate   - Integrate multiple repositories
    optimize    - Optimize repository structure
    backup     - Create repository backup
    metrics    - Generate repository metrics
    help       - Show this help message

Options:
    -RepoPath   - Path to the repository
    -OutputPath - Path for output files
    -Force      - Force operation without confirmation
    -Verbose    - Show detailed output
    -Remote     - Enable remote repository support
    -BackupPath - Path for backup storage

Examples:
    .\repomix.ps1 analyze -RepoPath C:\repos\myproject
    .\repomix.ps1 integrate -RepoPath C:\repos\project1,C:\repos\project2 -OutputPath C:\output
    .\repomix.ps1 optimize -RepoPath C:\repos\myproject -Force
    .\repomix.ps1 backup -RepoPath C:\repos\myproject -BackupPath C:\backups
    .\repomix.ps1 metrics -RepoPath C:\repos\myproject
"@
}

function Get-RepositoryMetrics {
    param(
        [string]$RepoPath
    )
    
    Write-Log "Collecting repository metrics for: $RepoPath"
    
    try {
        $metrics = @{
            timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            path = $RepoPath
            files = @{
                total = 0
                byType = @{}
            }
            size = @{
                total = 0
                byType = @{}
            }
            activity = @{
                lastModified = $null
                modificationsByMonth = @{}
            }
        }
        
        Get-ChildItem -Path $RepoPath -Recurse -File | ForEach-Object {
            # Update file counts
            $metrics.files.total++
            $ext = $_.Extension.ToLower()
            if (-not $metrics.files.byType.ContainsKey($ext)) {
                $metrics.files.byType[$ext] = 0
            }
            $metrics.files.byType[$ext]++
            
            # Update size metrics
            $metrics.size.total += $_.Length
            if (-not $metrics.size.byType.ContainsKey($ext)) {
                $metrics.size.byType[$ext] = 0
            }
            $metrics.size.byType[$ext] += $_.Length
            
            # Update activity metrics
            $month = $_.LastWriteTime.ToString("yyyy-MM")
            if (-not $metrics.activity.modificationsByMonth.ContainsKey($month)) {
                $metrics.activity.modificationsByMonth[$month] = 0
            }
            $metrics.activity.modificationsByMonth[$month]++
            
            if ($null -eq $metrics.activity.lastModified -or $_.LastWriteTime -gt $metrics.activity.lastModified) {
                $metrics.activity.lastModified = $_.LastWriteTime
            }
        }
        
        # Save metrics
        $metricsFile = Join-Path $script:metricsPath "metrics-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
        $metrics | ConvertTo-Json -Depth 10 | Set-Content $metricsFile
        
        Write-Log "Metrics collection complete. Saved to: $metricsFile"
        return $metrics
    }
    catch {
        Write-Log "Error collecting metrics: $_" -Level "ERROR"
        throw
    }
}

function Backup-Repository {
    param(
        [string]$RepoPath,
        [string]$BackupPath
    )
    
    Write-Log "Starting repository backup: $RepoPath -> $BackupPath"
    
    try {
        # Create backup directory if it doesn't exist
        if (-not (Test-Path $BackupPath)) {
            New-Item -ItemType Directory -Path $BackupPath -Force | Out-Null
        }
        
        # Create timestamped backup directory
        $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
        $backupDir = Join-Path $BackupPath "backup-$timestamp"
        New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
        
        # Copy repository contents
        Copy-Item -Path "$RepoPath\*" -Destination $backupDir -Recurse -Force
        
        # Create backup manifest
        $manifest = @{
            timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            source = $RepoPath
            destination = $backupDir
            files = (Get-ChildItem -Path $backupDir -Recurse -File).Count
            size = (Get-ChildItem -Path $backupDir -Recurse -File | Measure-Object -Property Length -Sum).Sum
        }
        
        $manifestPath = Join-Path $backupDir "manifest.json"
        $manifest | ConvertTo-Json | Set-Content $manifestPath
        
        Write-Log "Backup complete: $backupDir"
        return $true
    }
    catch {
        Write-Log "Error during backup: $_" -Level "ERROR"
        return $false
    }
}

function Analyze-Repository {
    param(
        [string]$RepoPath
    )
    
    Write-Log "Starting repository analysis for: $RepoPath"
    
    try {
        # Verify repository path
        if (-not (Test-Path $RepoPath)) {
            throw "Repository path does not exist: $RepoPath"
        }
        
        # Collect metrics first
        $metrics = Get-RepositoryMetrics -RepoPath $RepoPath
        
        # Enhanced analysis
        $analysis = @{
            metrics = $metrics
            recommendations = @()
            issues = @()
            optimizations = @()
        }
        
        # Analyze file distribution
        foreach ($ext in $metrics.files.byType.Keys) {
            $percentage = ($metrics.files.byType[$ext] / $metrics.files.total) * 100
            if ($percentage -gt 30) {
                $analysis.recommendations += "High concentration of $ext files ($percentage%)"
            }
        }
        
        # Analyze size distribution
        foreach ($ext in $metrics.size.byType.Keys) {
            $percentage = ($metrics.size.byType[$ext] / $metrics.size.total) * 100
            if ($percentage -gt 40) {
                $analysis.recommendations += "Large storage usage by $ext files ($percentage%)"
            }
        }
        
        # Generate report
        $reportPath = Join-Path $OutputPath "repo-analysis-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
        $analysis | ConvertTo-Json -Depth 10 | Set-Content $reportPath
        
        Write-Log "Analysis complete. Report saved to: $reportPath"
        return $true
    }
    catch {
        Write-Log "Error during analysis: $_" -Level "ERROR"
        return $false
    }
}

function Integrate-Repositories {
    param(
        [string[]]$RepoPaths,
        [string]$OutputPath
    )
    
    Write-Log "Starting repository integration for: $($RepoPaths -join ', ')"
    
    try {
        # Verify all paths
        foreach ($path in $RepoPaths) {
            if (-not (Test-Path $path)) {
                throw "Repository path does not exist: $path"
            }
        }
        
        # Create output directory if it doesn't exist
        if (-not (Test-Path $OutputPath)) {
            New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
        }
        
        # Create integration workspace
        $workspace = Join-Path $OutputPath "integration-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
        New-Item -ItemType Directory -Path $workspace -Force | Out-Null
        
        # Process each repository
        $integrationManifest = @{
            timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            repositories = @()
            conflicts = @()
            actions = @()
        }
        
        foreach ($path in $RepoPaths) {
            Write-Log "Processing repository: $path"
            
            # Collect repository info
            $repoInfo = @{
                path = $path
                files = @()
                metrics = Get-RepositoryMetrics -RepoPath $path
            }
            
            # Copy files
            Get-ChildItem -Path $path -Recurse -File | ForEach-Object {
                $relativePath = $_.FullName.Substring($path.Length + 1)
                $targetPath = Join-Path $workspace $relativePath
                
                # Create target directory if needed
                $targetDir = Split-Path $targetPath -Parent
                if (-not (Test-Path $targetDir)) {
                    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
                }
                
                # Check for conflicts
                if (Test-Path $targetPath) {
                    $integrationManifest.conflicts += @{
                        file = $relativePath
                        repositories = @($path)
                    }
                }
                else {
                    Copy-Item -Path $_.FullName -Destination $targetPath -Force
                    $integrationManifest.actions += "Copied: $relativePath"
                }
                
                $repoInfo.files += $relativePath
            }
            
            $integrationManifest.repositories += $repoInfo
        }
        
        # Save integration manifest
        $manifestPath = Join-Path $workspace "integration-manifest.json"
        $integrationManifest | ConvertTo-Json -Depth 10 | Set-Content $manifestPath
        
        Write-Log "Integration complete. Output saved to: $workspace"
        return $true
    }
    catch {
        Write-Log "Error during integration: $_" -Level "ERROR"
        return $false
    }
}

function Optimize-Repository {
    param(
        [string]$RepoPath
    )
    
    Write-Log "Starting repository optimization for: $RepoPath"
    
    try {
        # Verify repository path
        if (-not (Test-Path $RepoPath)) {
            throw "Repository path does not exist: $RepoPath"
        }
        
        # Collect initial metrics
        $beforeMetrics = Get-RepositoryMetrics -RepoPath $RepoPath
        
        # Optimization tasks
        $optimizations = @{
            timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            repository = $RepoPath
            actions = @()
            improvements = @()
        }
        
        # Analyze and optimize file organization
        $fileTypes = @{}
        Get-ChildItem -Path $RepoPath -Recurse -File | ForEach-Object {
            $ext = $_.Extension.ToLower()
            if (-not $fileTypes.ContainsKey($ext)) {
                $fileTypes[$ext] = @()
            }
            $fileTypes[$ext] += $_
        }
        
        # Organize files by type if needed
        foreach ($ext in $fileTypes.Keys) {
            if ($fileTypes[$ext].Count -gt 10) {
                $typeDir = Join-Path $RepoPath "by-type$ext"
                if (-not (Test-Path $typeDir)) {
                    New-Item -ItemType Directory -Path $typeDir -Force | Out-Null
                    $optimizations.actions += "Created directory: by-type$ext"
                }
                
                foreach ($file in $fileTypes[$ext]) {
                    $newPath = Join-Path $typeDir $file.Name
                    if (-not (Test-Path $newPath)) {
                        Move-Item -Path $file.FullName -Destination $newPath -Force
                        $optimizations.actions += "Moved: $($file.Name) -> by-type$ext"
                    }
                }
            }
        }
        
        # Collect final metrics
        $afterMetrics = Get-RepositoryMetrics -RepoPath $RepoPath
        
        # Calculate improvements
        $optimizations.improvements = @{
            fileOrganization = "Organized $(($fileTypes.Values | Measure-Object).Count) file types"
            sizeReduction = ($beforeMetrics.size.total - $afterMetrics.size.total)
        }
        
        # Save optimization report
        $reportPath = Join-Path $RepoPath "optimization-report-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
        $optimizations | ConvertTo-Json -Depth 10 | Set-Content $reportPath
        
        Write-Log "Optimization complete for: $RepoPath"
        return $true
    }
    catch {
        Write-Log "Error during optimization: $_" -Level "ERROR"
        return $false
    }
}

# Main execution
try {
    Write-Log "RepomiX started with action: $Action"
    
    switch ($Action.ToLower()) {
        "analyze" {
            if (-not $RepoPath) {
                throw "Repository path is required for analysis"
            }
            $success = Analyze-Repository -RepoPath $RepoPath
        }
        "integrate" {
            if (-not $RepoPath -or -not $OutputPath) {
                throw "Repository path and output path are required for integration"
            }
            $repoPaths = $RepoPath -split ','
            $success = Integrate-Repositories -RepoPaths $repoPaths -OutputPath $OutputPath
        }
        "optimize" {
            if (-not $RepoPath) {
                throw "Repository path is required for optimization"
            }
            $success = Optimize-Repository -RepoPath $RepoPath
        }
        "backup" {
            if (-not $RepoPath -or -not $BackupPath) {
                throw "Repository path and backup path are required for backup"
            }
            $success = Backup-Repository -RepoPath $RepoPath -BackupPath $BackupPath
        }
        "metrics" {
            if (-not $RepoPath) {
                throw "Repository path is required for metrics collection"
            }
            $metrics = Get-RepositoryMetrics -RepoPath $RepoPath
            $success = $null -ne $metrics
        }
        "help" {
            Show-Help
            $success = $true
        }
        default {
            throw "Unknown action: $Action"
        }
    }
    
    if ($success) {
        Write-Log "Operation completed successfully"
        exit 0
    }
    else {
        Write-Log "Operation failed" -Level "ERROR"
        exit 1
    }
}
catch {
    Write-Log "Fatal error: $_" -Level "ERROR"
    exit 1
}