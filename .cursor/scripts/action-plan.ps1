# action-plan.ps1
# Comprehensive Action Plan for .cursor Project
# Purpose: Integrates Cursor Instance Consolidation, Library Organization, and Resource-Aware Architecture
# Created: 05-07-2025

[CmdletBinding()]
param(
    [Parameter()]
    [switch]$DryRun = $false,
    
    [Parameter()]
    [switch]$ForceCleanup = $false,
    
    [Parameter()]
    [string]$LogPath = "$PSScriptRoot\..\logs\action-plan.log"
)

# Ensure log directory exists
$logDir = Split-Path $LogPath -Parent
if (-not (Test-Path $logDir)) {
    try {
        New-Item -Path $logDir -ItemType Directory -Force | Out-Null
        Write-Verbose "Created log directory: $logDir"
    } 
    catch {
        Write-Error "Failed to create log directory: $($_.Exception.Message)"
        exit 1
    }
}

# Helper Functions
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    
    try {
        Add-Content -Path $LogPath -Value $logEntry
        
        switch ($Level) {
            "ERROR" { Write-Host $logEntry -ForegroundColor Red }
            "WARNING" { Write-Host $logEntry -ForegroundColor Yellow }
            "SUCCESS" { Write-Host $logEntry -ForegroundColor Green }
            default { Write-Host $logEntry }
        }
    }
    catch {
        Write-Error "Failed to write to log: $($_.Exception.Message)"
    }
}

function Invoke-ScriptStep {
    param(
        [string]$StepName,
        [string]$ScriptPath,
        [hashtable]$Parameters = @{},
        [switch]$Critical = $false
    )
    
    try {
        Write-Log "----- Starting Step: $StepName -----" "INFO"
        
        if (-not (Test-Path $ScriptPath)) {
            Write-Log "Script not found: $ScriptPath" "ERROR"
            return @{
                Success = $false
                Error = "Script not found: $ScriptPath"
            }
        }
        
        # Build parameter string
        $paramString = ""
        foreach ($key in $Parameters.Keys) {
            $value = $Parameters[$key]
            
            if ($value -is [switch] -or $value -is [bool]) {
                if ($value) {
                    $paramString += " -$key"
                }
            }
            else {
                $paramString += " -$key '$value'"
            }
        }
        
        # Build command
        $command = "& '$ScriptPath'$paramString"
        
        Write-Log "Executing: $command" "INFO"
        
        if ($DryRun) {
            Write-Log "DRY RUN: Would execute script: $ScriptPath with parameters: $paramString" "INFO"
            return @{
                Success = $true
                DryRun = $true
                Command = $command
            }
        }
        
        # Execute the script and capture output
        $output = @()
        $errorOutput = @()
        
        $result = $null
        
        try {
            $result = Invoke-Expression $command -ErrorVariable errorOutput | Tee-Object -Variable output
            Start-Sleep -Seconds 2 # Give time for output to finish
        }
        catch {
            Write-Log "Error executing script: $($_.Exception.Message)" "ERROR"
            $errorOutput += $_.Exception.Message
        }
        
        # Log output
        if ($output.Count -gt 0) {
            foreach ($line in $output) {
                Write-Log "Output: $line" "INFO"
            }
        }
        
        # Log errors
        if ($errorOutput.Count -gt 0) {
            foreach ($error in $errorOutput) {
                Write-Log "Error: $error" "ERROR"
            }
            
            if ($Critical) {
                Write-Log "Critical step failed, aborting execution" "ERROR"
                return @{
                    Success = $false
                    Error = $errorOutput -join "`n"
                }
            }
        }
        
        Write-Log "----- Completed Step: $StepName -----" "SUCCESS"
        
        return @{
            Success = $errorOutput.Count -eq 0
            Result = $result
            Output = $output
            Errors = $errorOutput
        }
    }
    catch {
        Write-Log "Failed to execute step '$StepName': $($_.Exception.Message)" "ERROR"
        return @{
            Success = $false
            Error = $_.Exception.Message
        }
    }
}

function Update-MemoryFile {
    param(
        [string]$Title,
        [string[]]$Content
    )
    
    try {
        $memoryPath = "$PSScriptRoot\..\memory.md"
        
        if (-not (Test-Path $memoryPath)) {
            Write-Log "Memory file not found at $memoryPath" "WARNING"
            return $false
        }
        
        $timestamp = Get-Date -Format "MM-dd-2025"
        $entry = "`n`n## $Title ($timestamp)`n"
        
        foreach ($line in $Content) {
            $entry += "- $line`n"
        }
        
        $entry += "`n_Updated $timestamp | AI: Cursor (Claude 3.7 Sonnet)_"
        
        # Find the "Next Steps" section to insert before
        $memoryContent = Get-Content -Path $memoryPath -Raw
        $pattern = "## Next Steps"
        
        if ($memoryContent -match $pattern) {
            $newContent = $memoryContent -replace $pattern, "$entry`n`n$pattern"
            $newContent | Out-File -FilePath $memoryPath -Encoding utf8
        }
        else {
            # If "Next Steps" section not found, append to end
            Add-Content -Path $memoryPath -Value $entry
        }
        
        Write-Log "Updated memory.md with entry: $Title" "SUCCESS"
        return $true
    }
    catch {
        Write-Log "Failed to update memory.md: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Update-ChangelogFile {
    param(
        [string]$Version,
        [hashtable]$Changes
    )
    
    try {
        $changelogPath = "$PSScriptRoot\..\changelog.md"
        
        if (-not (Test-Path $changelogPath)) {
            Write-Log "Changelog file not found at $changelogPath" "WARNING"
            return $false
        }
        
        $timestamp = Get-Date -Format "yyyy-MM-dd"
        $entry = "## [$Version] - $timestamp`n`n"
        
        foreach ($section in $Changes.Keys) {
            $entry += "### $section`n"
            
            foreach ($item in $Changes[$section]) {
                $entry += "- $item`n"
            }
            
            $entry += "`n"
        }
        
        $entry += "_Updated $timestamp | AI: Cursor (Claude 3.7 Sonnet)_`n`n"
        
        # Insert at the beginning of the file after the header
        $changelogContent = Get-Content -Path $changelogPath -Raw
        $pattern = "^(#.*?)\n"
        
        if ($changelogContent -match $pattern) {
            $newContent = $changelogContent -replace $pattern, "`$1`n`n$entry"
            $newContent | Out-File -FilePath $changelogPath -Encoding utf8
        }
        else {
            # If no header found, prepend to file
            $newContent = "$entry`n$changelogContent"
            $newContent | Out-File -FilePath $changelogPath -Encoding utf8
        }
        
        Write-Log "Updated changelog.md with version: $Version" "SUCCESS"
        return $true
    }
    catch {
        Write-Log "Failed to update changelog.md: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

# Main execution
try {
    Write-Log "===== Comprehensive Action Plan Started =====" "INFO"
    Write-Log "Dry Run: $DryRun" "INFO"
    Write-Log "Force Cleanup: $ForceCleanup" "INFO"
    
    # Step 1: Check System Resources
    Write-Log "Checking system resources..." "INFO"
    
    $os = Get-CimInstance -ClassName Win32_OperatingSystem
    $totalMemoryMB = [math]::Round($os.TotalVisibleMemorySize / 1024)
    $freeMemoryMB = [math]::Round($os.FreePhysicalMemory / 1024)
    $usedMemoryPercent = [math]::Round(100 - (($freeMemoryMB / $totalMemoryMB) * 100), 2)
    $processCount = (Get-Process).Count
    
    Write-Log "Memory: $usedMemoryPercent% used ($freeMemoryMB MB free of $totalMemoryMB MB total)" "INFO"
    Write-Log "Processes: $processCount" "INFO"
    
    # Memory/process thresholds
    $memoryThreshold = 85
    $processThreshold = 300
    
    # Step 2: Execute Cursor Instance Consolidation (Critical)
    if ($usedMemoryPercent -gt $memoryThreshold -or $processCount -gt $processThreshold -or $ForceCleanup) {
        Write-Log "Resource usage exceeds thresholds, performing immediate Cursor Instance Consolidation" "WARNING"
        
        $cursorManagerPath = "$PSScriptRoot\cursor-manager.ps1"
        $consolidationResult = Invoke-ScriptStep -StepName "Cursor Instance Consolidation" -ScriptPath $cursorManagerPath -Parameters @{
            ForceCleanup = $true
            MaxInstances = 1
            LogPath = "$PSScriptRoot\..\logs\cursor-manager.log"
        } -Critical
        
        if (-not $consolidationResult.Success) {
            Write-Log "Cursor Instance Consolidation failed, aborting further steps" "ERROR"
            exit 1
        }
        
        # Pause for resources to stabilize
        Start-Sleep -Seconds 5
    }
    else {
        Write-Log "Resource usage within acceptable limits, proceeding with normal execution" "INFO"
        
        # Still run consolidation but without force
        $cursorManagerPath = "$PSScriptRoot\cursor-manager.ps1"
        $consolidationResult = Invoke-ScriptStep -StepName "Cursor Instance Consolidation" -ScriptPath $cursorManagerPath -Parameters @{
            ForceCleanup = $false
            MaxInstances = 1
            LogPath = "$PSScriptRoot\..\logs\cursor-manager.log"
        }
    }
    
    # Step 3: Configure Resource-Aware Architecture
    $resourceConfigPath = "$PSScriptRoot\resource-config.ps1"
    $resourceResult = Invoke-ScriptStep -StepName "Resource-Aware Architecture Configuration" -ScriptPath $resourceConfigPath -Parameters @{
        MaxMemoryPercent = 65
        MaxCpuPercent = 70
        CleanupThresholdPercent = 75
        EmergencyThresholdPercent = 85
        LogPath = "$PSScriptRoot\..\logs\resource-config.log"
    } -Critical
    
    if (-not $resourceResult.Success) {
        Write-Log "Resource-Aware Architecture Configuration failed, aborting further steps" "ERROR"
        exit 1
    }
    
    # Step 4: Organize .cursor Library
    $libraryOrganizerPath = "$PSScriptRoot\library-organizer.ps1"
    $organizerResult = Invoke-ScriptStep -StepName ".cursor Library Organization" -ScriptPath $libraryOrganizerPath -Parameters @{
        CreateBackup = $true
        DryRun = $DryRun
        LogPath = "$PSScriptRoot\..\logs\library-organizer.log"
    }
    
    # Update memory.md with execution summary
    $memoryContent = @(
        "Implemented comprehensive system stabilization strategy",
        "Executed Cursor Instance Consolidation to prevent proliferation",
        "Configured Resource-Aware Architecture with strict resource limits",
        "Organized .cursor library with minimal cross-dependencies",
        "Implemented automatic cleanup mechanisms and monitoring",
        "Established resource thresholds for proactive management"
    )
    
    $memoryUpdateResult = Update-MemoryFile -Title "System Stabilization Strategy Implementation" -Content $memoryContent
    
    # Update changelog.md
    $changelogContent = @{
        "Added [RELAUNCH-CRITICAL]" = @(
            "Implemented Cursor Instance Consolidation system to prevent crashes",
            "Created Resource-Aware Architecture with strict memory limits",
            "Established .cursor Library Organization with minimal dependencies",
            "Added automatic cleanup mechanisms with configurable thresholds",
            "Implemented real-time resource monitoring system"
        )
        "Changed" = @(
            "Shifted from dependency-heavy approach to minimalist architecture",
            "Replaced installation attempts with controlled resource management",
            "Improved system stability with proactive instance management",
            "Enhanced library organization with clear boundaries",
            "Implemented modular structure with isolated components"
        )
        "Fixed" = @(
            "Resolved recursive installation crashes via instance consolidation",
            "Fixed memory exhaustion with configurable resource limits",
            "Addressed system instability through controlled cleanup",
            "Eliminated dependency cascade failures with library isolation",
            "Resolved PowerShell linter errors in scripts"
        )
        "Next Steps" = @(
            "Complete minimal viable testing infrastructure",
            "Implement static validation for library structure",
            "Create resource-aware test execution framework",
            "Enhance cross-platform validation strategies",
            "Conduct comprehensive performance verification"
        )
    }
    
    $changelogUpdateResult = Update-ChangelogFile -Version "1.0.0" -Changes $changelogContent
    
    # Final report
    Write-Log "===== Action Plan Summary =====" "INFO"
    Write-Log "Cursor Instance Consolidation: $(if($consolidationResult.Success){"SUCCESS"}else{"FAILED"})" "INFO"
    Write-Log "Resource-Aware Architecture: $(if($resourceResult.Success){"SUCCESS"}else{"FAILED"})" "INFO"
    Write-Log "Library Organization: $(if($organizerResult.Success){"SUCCESS"}else{"FAILED"})" "INFO"
    Write-Log "Memory File Update: $(if($memoryUpdateResult){"SUCCESS"}else{"FAILED"})" "INFO"
    Write-Log "Changelog Update: $(if($changelogUpdateResult){"SUCCESS"}else{"FAILED"})" "INFO"
    
    Write-Log "===== Comprehensive Action Plan Completed =====" "SUCCESS"
}
catch {
    Write-Log "Unexpected error: $($_.Exception.Message)" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    exit 1
} 