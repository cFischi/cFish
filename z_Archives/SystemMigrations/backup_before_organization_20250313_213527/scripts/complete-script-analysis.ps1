<#
.SYNOPSIS
    Completes the cross-platform script analysis for tYDiSync~ project.

.DESCRIPTION
    This script analyzes PowerShell scripts for cross-platform compatibility issues.
    It creates a detailed report with categorized issues and prioritizes scripts
    based on their impact and complexity for cross-platform migration.

.NOTES
    File Name      : complete-script-analysis.ps1
    Author         : tY FischEYe
    Prerequisite   : PowerShell 5.1 or later
    Created        : 2025-03-13
    Version        : 1.0
#>

#Requires -Version 5.1

# Set strict mode to catch common scripting mistakes
Set-StrictMode -Version Latest

# Set error action preference to stop on errors
$ErrorActionPreference = "Stop"

##### Import the PlatformDetection module
$platformDetectionModulePath = Join-Path $PSScriptRoot "PlatformDetection.psm1"
if (Test-Path $platformDetectionModulePath) {
    Import-Module $platformDetectionModulePath -Force
}
else {
    Write-Error "PlatformDetection module not found at: $platformDetectionModulePath"
    exit 1
}

##### Configuration
$outputDir = Join-Path $PSScriptRoot "..\docs"
$inventoryOutputPath = Join-Path $outputDir "script-inventory-detailed.csv"
$analysisReportPath = Join-Path $outputDir "cross-platform-compatibility-analysis.md"
$prioritizationReportPath = Join-Path $outputDir "cross-platform-migration-priorities.md"

##### Cross-platform issue types
$issueTypes = @{
    'Path' = @{
        Description = "Path handling issues (backslashes, drive letters, etc.)"
        Keywords = @('\', 'C:', '[A-Z]:', 'System32', '${env}:WINDIR', '${env}:ProgramFiles')
        Severity = "High"
        Recommendation = "Use Join-Path for all path operations and avoid hardcoded paths"
    }
    'LineEndings' = @{
        Description = "Line ending inconsistencies (CRLF vs LF)"
        Keywords = @('\r\n', '\n', 'Get-Content -Raw')
        Severity = "Medium"
        Recommendation = "Use [System.Environment]::NewLine for line breaks and -Raw parameter with Get-Content when processing text"
    }
    'Commands' = @{
        Description = "Windows-specific command usage"
        Keywords = @('cmd.exe', 'cmd /c', 'powershell.exe', 'Start-Process')
        Severity = "High"
        Recommendation = "Use PowerShell cmdlets instead of external commands, test for platform before using platform-specific commands"
    }
    'ExecutionPolicy' = @{
        Description = "Execution policy settings"
        Keywords = @('ExecutionPolicy', 'Set-ExecutionPolicy', 'Bypass')
        Severity = "Medium"
        Recommendation = "Avoid relying on execution policy settings, which differ between platforms"
    }
    'FileSystems' = @{
        Description = "Filesystem differences"
        Keywords = @('Hidden', 'Attributes', 'FileSystemRights', '[System.IO.FileAttributes]')
        Severity = "Medium"
        Recommendation = "Check platform before accessing filesystem-specific attributes"
    }
    'ServiceManagement' = @{
        Description = "Windows service management"
        Keywords = @('Get-Service', 'Start-Service', 'Stop-Service', 'Set-Service')
        Severity = "High"
        Recommendation = "Use platform-specific alternatives or create platform-abstracted helper functions"
    }
    'Registry' = @{
        Description = "Windows registry access"
        Keywords = @('Registry::', 'HKLM:', 'HKCU:', 'Get-ItemProperty')
        Severity = "High"
        Recommendation = "Create platform-specific abstraction for configuration storage"
    }
    'ProcessManagement' = @{
        Description = "Process management differences"
        Keywords = @('Get-Process', '-ProcessName', 'taskkill')
        Severity = "Medium"
        Recommendation = "Use Get-Process with proper platform checks, avoid Win32 process termination methods"
    }
    'EventLogs' = @{
        Description = "Windows event log usage"
        Keywords = @('Get-EventLog', 'Write-EventLog', 'New-EventLog')
        Severity = "Medium"
        Recommendation = "Create a cross-platform logging abstraction"
    }
    'Formatting' = @{
        Description = "Output formatting differences"
        Keywords = @('Format-Table', 'Format-List', 'Format-Wide', 'Out-GridView')
        Severity = "Low"
        Recommendation = "Test formatting on all platforms, avoid Windows-specific formatters like Out-GridView"
    }
    'Authentication' = @{
        Description = "Authentication and security differences"
        Keywords = @('Get-Credential', 'ConvertTo-SecureString', 'PSCredential')
        Severity = "Medium"
        Recommendation = "Test credential handling on all platforms"
    }
    'NetworKing' = @{
        Description = "Networking commandlet differences"
        Keywords = @('Get-NetAdapter', 'Get-NetIPAddress', 'Get-NetRoute')
        Severity = "Medium"
        Recommendation = "Use cross-platform network cmdlets when available"
    }
}

##### Initialize output directory
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

##### Find all PowerShell scripts in the project
function Find-PowerShellScripts {
    param (
        [string]$RootDir = (Join-Path $PSScriptRoot ".."),
        [string[]]$ExcludeDirs = @(".git", "node_modules", ".vscode", "temp")
    )
    
    Write-Host "Finding PowerShell scripts in: $RootDir" -ForegroundColor Yellow
    
    ##### Create an array to store scripts
    $scripts = @()
    
    ##### Find all .ps1 and .psm1 files
    $files = Get-ChildItem -Path $RootDir -Recurse -Include "*.ps1", "*.psm1" -File | 
             Where-Object { 
                $excludeMatched = $false
                foreach ($excludeDir in $ExcludeDirs) {
                    if ($_.FullName -like "*\$excludeDir\*") {
                        $excludeMatched = $true
                        break
                    }
                }
                -not $excludeMatched
             }
    
    foreach ($file in $files) {
        $scripts += @{
            Path = $file.FullName
            RelativePath = $file.FullName.Replace($RootDir, "").TrimStart("\")
            Name = $file.Name
            Extension = $file.Extension
            SizeKB = [math]::Round($file.Length / 1KB, 2)
            ModifiedDate = $file.LastWriteTime
            Content = Get-Content -Path $file.FullName -Raw
        }
    }
    
    Write-Host "Found $($scripts.Count) PowerShell scripts." -ForegroundColor Green
    
    return $scripts
}

##### Analyze scripts for cross-platform issues
function Analyze-ScriptsForIssues {
    param (
        [array]$Scripts,
        [hashtable]$IssueTypes
    )
    
    Write-Host "Analyzing scripts for cross-platform compatibility issues..." -ForegroundColor Yellow
    
    $results = @()
    
    foreach ($script in $Scripts) {
        Write-Host "Analyzing: $($script.RelativePath)" -ForegroundColor Cyan
        
        $issues = @{}
        $totalIssueCount = 0
        
        foreach ($issueType in $IssueTypes.Keys) {
            $issueInfo = $IssueTypes[$issueType]
            $issueCount = 0
            $issueLines = @()
            
            foreach ($keyword in $issueInfo.Keywords) {
                if ($script.Content -match $keyword) {
                    ##### Count lines containing the issue
                    $content = Get-Content -Path $script.Path
                    $lineNum = 1
                    
                    foreach ($line in $content) {
                        if ($line -match $keyword) {
                            $issueCount++
                            $issueLines += "Line $lineNum`: $line"
                        }
                        $lineNum++
                    }
                }
            }
            
            if ($issueCount -gt 0) {
                $issues[$issueType] = @{
                    Count = $issueCount
                    Lines = $issueLines
                    Description = $issueInfo.Description
                    Severity = $issueInfo.Severity
                    Recommendation = $issueInfo.Recommendation
                }
                
                $totalIssueCount += $issueCount
            }
        }
        
        ##### Determine compatibility score (0-100, higher is better)
        $compatibilityScore = 100
        if ($totalIssueCount -gt 0) {
            ##### Base score reduction on issue count and severity
            $severeIssueCount = 0
            $mediumIssueCount = 0
            $lowIssueCount = 0
            
            foreach ($issueType in $issues.Keys) {
                if ($IssueTypes[$issueType].Severity -eq "High") {
                    $severeIssueCount += $issues[$issueType].Count
                }
                elseif ($IssueTypes[$issueType].Severity -eq "Medium") {
                    $mediumIssueCount += $issues[$issueType].Count
                }
                else {
                    $lowIssueCount += $issues[$issueType].Count
                }
            }
            
            ##### Calculate score reduction
            $scoreReduction = [math]::Min(
                100,
                ($severeIssueCount * 10) + ($mediumIssueCount * 5) + ($lowIssueCount * 2)
            )
            
            $compatibilityScore = [math]::Max(0, 100 - $scoreReduction)
        }
        
        ##### Determine migration priority based on compatibility score and size
        $priority = "Low"
        if ($compatibilityScore -lt 50) {
            $priority = "High"
        }
        elseif ($compatibilityScore -lt 75) {
            $priority = "Medium"
        }
        
        ##### Create result object
        $result = [PSCustomObject]@{
            Script = $script.RelativePath
            Name = $script.Name
            SizeKB = $script.SizeKB
            ModifiedDate = $script.ModifiedDate
            IssueCount = $totalIssueCount
            Issues = $issues
            CompatibilityScore = $compatibilityScore
            MigrationPriority = $priority
        }
        
        $results += $result
    }
    
    Write-Host "Script analysis completed." -ForegroundColor Green
    
    return $results
}

##### Export script inventory to CSV
function Export-ScriptInventory {
    param (
        [array]$AnalysisResults,
        [string]$OutputPath
    )
    
    Write-Host "Exporting script inventory to CSV: $OutputPath" -ForegroundColor Yellow
    
    $csvData = foreach ($result in $AnalysisResults) {
        $issuesSummary = ""
        foreach ($issueType in $result.Issues.Keys) {
            $issuesSummary += "$issueType($($result.Issues[$issueType].Count)), "
        }
        $issuesSummary = $issuesSummary.TrimEnd(", ")
        
        [PSCustomObject]@{
            Script = $result.Script
            Name = $result.Name
            SizeKB = $result.SizeKB
            ModifiedDate = $result.ModifiedDate
            IssueCount = $result.IssueCount
            IssueTypes = $issuesSummary
            CompatibilityScore = $result.CompatibilityScore
            MigrationPriority = $result.MigrationPriority
        }
    }
    
    $csvData | Export-Csv -Path $OutputPath -NoTypeInformation
    
    Write-Host "Script inventory exported to CSV successfully." -ForegroundColor Green
}

##### Create analysis report in Markdown
function Create-AnalysisReport {
    param (
        [array]$AnalysisResults,
        [string]$OutputPath,
        [hashtable]$IssueTypes
    )
    
    Write-Host "Creating analysis report: $OutputPath" -ForegroundColor Yellow
    
    $report = @"
##### tYDiSync~ Cross-Platform Compatibility Analysis

**Date: $(Get-Date -Format "yyyy-MM-dd")**

###### Overview

This report analyzes the cross-platform compatibility of PowerShell scripts in the tYDiSync~ project. It identifies potential issues that may affect the scripts' ability to run on different platforms (Windows PowerShell 5.1, PowerShell Core on Windows, PowerShell Core on Linux/macOS).

###### Summary

- **Total Scripts Analyzed**: $($AnalysisResults.Count)
- **Scripts with Issues**: $($AnalysisResults | Where-Object { $_.IssueCount -gt 0 } | Measure-Object).Count
- **Total Issues Found**: $($AnalysisResults | Measure-Object -Property IssueCount -Sum).Sum
- **Average Compatibility Score**: $([math]::Round(($AnalysisResults | Measure-Object -Property CompatibilityScore -Average).Average, 2))

###### Issue Types

| Issue Type | Description | Severity | Recommendation |
|------------|-------------|----------|----------------|
"@
    
    foreach ($issueType in $IssueTypes.Keys | Sort-Object) {
        $issueInfo = $IssueTypes[$issueType]
        $report += "| $issueType | $($issueInfo.Description) | $($issueInfo.Severity) | $($issueInfo.Recommendation) |`r`n"
    }
    
    $report += @"

###### Scripts by Migration Priority

####### High Priority

| Script | Size (KB) | Issue Count | Compatibility Score |
|--------|-----------|-------------|---------------------|
"@
    
    $highPriorityScripts = $AnalysisResults | Where-Object { $_.MigrationPriority -eq "High" } | Sort-Object -Property IssueCount -Descending
    foreach ($script in $highPriorityScripts) {
        $report += "| $($script.Script) | $($script.SizeKB) | $($script.IssueCount) | $($script.CompatibilityScore) |`r`n"
    }
    
    $report += @"

####### Medium Priority

| Script | Size (KB) | Issue Count | Compatibility Score |
|--------|-----------|-------------|---------------------|
"@
    
    $mediumPriorityScripts = $AnalysisResults | Where-Object { $_.MigrationPriority -eq "Medium" } | Sort-Object -Property IssueCount -Descending
    foreach ($script in $mediumPriorityScripts) {
        $report += "| $($script.Script) | $($script.SizeKB) | $($script.IssueCount) | $($script.CompatibilityScore) |`r`n"
    }
    
    $report += @"

####### Low Priority

| Script | Size (KB) | Issue Count | Compatibility Score |
|--------|-----------|-------------|---------------------|
"@
    
    $lowPriorityScripts = $AnalysisResults | Where-Object { $_.MigrationPriority -eq "Low" } | Sort-Object -Property IssueCount -Descending
    foreach ($script in $lowPriorityScripts) {
        $report += "| $($script.Script) | $($script.SizeKB) | $($script.IssueCount) | $($script.CompatibilityScore) |`r`n"
    }
    
    $report += @"

###### Detailed Issue Analysis

The following sections provide detailed information about the issues found in each script.

"@
    
    foreach ($script in ($AnalysisResults | Where-Object { $_.IssueCount -gt 0 } | Sort-Object -Property MigrationPriority, IssueCount -Descending)) {
        $report += @"

####### $($script.Script)

- **Size**: $($script.SizeKB) KB
- **Modified**: $($script.ModifiedDate)
- **Issues**: $($script.IssueCount)
- **Compatibility Score**: $($script.CompatibilityScore)
- **Migration Priority**: $($script.MigrationPriority)

| Issue Type | Count | Severity | Description |
|------------|-------|----------|-------------|
"@
        
        foreach ($issueType in $script.Issues.Keys | Sort-Object) {
            $issue = $script.Issues[$issueType]
            $report += "| $issueType | $($issue.Count) | $($issue.Severity) | $($issue.Description) |`r`n"
        }
        
        $report += "`r`n######## Example Issues`r`n`r`n"
        
        foreach ($issueType in $script.Issues.Keys | Sort-Object) {
            $issue = $script.Issues[$issueType]
            $report += "**$issueType**:`r`n`r`n"
            
            ##### Show up to 5 example lines
            $exampleLines = $issue.Lines | Select-Object -First 5
            foreach ($line in $exampleLines) {
                $report += "````r`n$line`r`n````r`n`r`n"
            }
            
            if ($issue.Lines.Count -gt 5) {
                $report += "... and $($issue.Lines.Count - 5) more instances.`r`n`r`n"
            }
        }
    }
    
    $report += @"

###### Recommendations

1. Start with high-priority scripts and implement the platform detection module.
2. Create helper functions for path handling, process management, and other platform-specific operations.
3. Develop unit tests that run on all target platforms.
4. Establish cross-platform coding guidelines based on the identified issues.
5. Create platform-specific alternatives for features not available across platforms.

###### Next Steps

1. Complete the implementation plan for migration.
2. Set up test environments for all target platforms.
3. Begin migration of high-priority scripts.
4. Create comprehensive testing framework.
5. Document best practices and lessons learned.

_Generated on $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")_
"@
    
    $report | Out-File -FilePath $OutputPath -Encoding utf8
    
    Write-Host "Analysis report created successfully." -ForegroundColor Green
}

##### Create migration priorities report in Markdown
function Create-PrioritizationReport {
    param (
        [array]$AnalysisResults,
        [string]$OutputPath
    )
    
    Write-Host "Creating migration priorities report: $OutputPath" -ForegroundColor Yellow
    
    $report = @"
##### tYDiSync~ Cross-Platform Migration Priorities

**Date: $(Get-Date -Format "yyyy-MM-dd")**

###### Overview

This document outlines the prioritized plan for migrating tYDiSync~ PowerShell scripts to be cross-platform compatible. The scripts are categorized by priority based on their compatibility score, complexity, and importance to the system.

###### Migration Phases

####### Phase 1: Core Infrastructure (Due: 2025-03-24)

Focus on critical infrastructure scripts that form the foundation of the system.

| Script | Size (KB) | Compatibility Score | Issues | Estimated Effort |
|--------|-----------|---------------------|--------|------------------|
"@
    
    # Get scripts in priority order for Phase 1
    $phase1Scripts = $AnalysisResults | 
                    Where-Object { $_.MigrationPriority -eq "High" } | 
                    Sort-Object -Property IssueCount -Descending |
                    Select-Object -First 10
    
    foreach ($script in $phase1Scripts) {
        ##### Calculate estimated effort in hours based on size and issues
        $effortHours = [math]::Round(($script.SizeKB * 0.1) + ($script.IssueCount * 0.5), 1)
        $report += "| $($script.Script) | $($script.SizeKB) | $($script.CompatibilityScore) | $($script.IssueCount) | $effortHours hours |`r`n"
    }
    
    $report += @"

####### Phase 2: Supporting Modules (Due: 2025-03-31)

Focus on modules and scripts that support the core functionality.

| Script | Size (KB) | Compatibility Score | Issues | Estimated Effort |
|--------|-----------|---------------------|--------|------------------|
"@
    
    # Get scripts in priority order for Phase 2
    $phase2Scripts = $AnalysisResults | 
                    Where-Object { $_.MigrationPriority -eq "Medium" -or ($_.MigrationPriority -eq "High" -and $_ -notin $phase1Scripts) } | 
                    Sort-Object -Property MigrationPriority, IssueCount -Descending |
                    Select-Object -First 15
    
    foreach ($script in $phase2Scripts) {
        ##### Calculate estimated effort in hours based on size and issues
        $effortHours = [math]::Round(($script.SizeKB * 0.08) + ($script.IssueCount * 0.4), 1)
        $report += "| $($script.Script) | $($script.SizeKB) | $($script.CompatibilityScore) | $($script.IssueCount) | $effortHours hours |`r`n"
    }
    
    $report += @"

####### Phase 3: Utilities and Tools (Due: 2025-04-07)

Focus on utility scripts and tools that are used less frequently.

| Script | Size (KB) | Compatibility Score | Issues | Estimated Effort |
|--------|-----------|---------------------|--------|------------------|
"@
    
    # Get scripts in priority order for Phase 3
    $phase3Scripts = $AnalysisResults | 
                    Where-Object { $_ -notin $phase1Scripts -and $_ -notin $phase2Scripts } | 
                    Sort-Object -Property MigrationPriority, IssueCount -Descending |
                    Select-Object -First 20
    
    foreach ($script in $phase3Scripts) {
        # Calculate estimated effort in hours based on size and issues
        $effortHours = [math]::Round(($script.SizeKB * 0.06) + ($script.IssueCount * 0.3), 1)
        $report += "| $($script.Script) | $($script.SizeKB) | $($script.CompatibilityScore) | $($script.IssueCount) | $effortHours hours |`r`n"
    }
    
    $report += @"

###### Resources Allocation

| Resource | Phase 1 Hours | Phase 2 Hours | Phase 3 Hours | Total Hours |
|----------|---------------|---------------|---------------|-------------|
| Developer 1 | $([math]::Round(($phase1Scripts | Measure-Object -Property SizeKB -Sum).Sum * 0.1 * 0.4, 1)) | $([math]::Round(($phase2Scripts | Measure-Object -Property SizeKB -Sum).Sum * 0.08 * 0.4, 1)) | $([math]::Round(($phase3Scripts | Measure-Object -Property SizeKB -Sum).Sum * 0.06 * 0.4, 1)) | $([math]::Round((($phase1Scripts | Measure-Object -Property SizeKB -Sum).Sum * 0.1 * 0.4) + (($phase2Scripts | Measure-Object -Property SizeKB -Sum).Sum * 0.08 * 0.4) + (($phase3Scripts | Measure-Object -Property SizeKB -Sum).Sum * 0.06 * 0.4), 1)) |
| Developer 2 | $([math]::Round(($phase1Scripts | Measure-Object -Property SizeKB -Sum).Sum * 0.1 * 0.3, 1)) | $([math]::Round(($phase2Scripts | Measure-Object -Property SizeKB -Sum).Sum * 0.08 * 0.3, 1)) | $([math]::Round(($phase3Scripts | Measure-Object -Property SizeKB -Sum).Sum * 0.06 * 0.3, 1)) | $([math]::Round((($phase1Scripts | Measure-Object -Property SizeKB -Sum).Sum * 0.1 * 0.3) + (($phase2Scripts | Measure-Object -Property SizeKB -Sum).Sum * 0.08 * 0.3) + (($phase3Scripts | Measure-Object -Property SizeKB -Sum).Sum * 0.06 * 0.3), 1)) |
| Developer 3 | $([math]::Round(($phase1Scripts | Measure-Object -Property SizeKB -Sum).Sum * 0.1 * 0.3, 1)) | $([math]::Round(($phase2Scripts | Measure-Object -Property SizeKB -Sum).Sum * 0.08 * 0.3, 1)) | $([math]::Round(($phase3Scripts | Measure-Object -Property SizeKB -Sum).Sum * 0.06 * 0.3, 1)) | $([math]::Round((($phase1Scripts | Measure-Object -Property SizeKB -Sum).Sum * 0.1 * 0.3) + (($phase2Scripts | Measure-Object -Property SizeKB -Sum).Sum * 0.08 * 0.3) + (($phase3Scripts | Measure-Object -Property SizeKB -Sum).Sum * 0.06 * 0.3), 1)) |

###### Common Migration Tasks

For each script, the following tasks should be completed:

1. **Import PlatformDetection Module**: Add `Import-Module PlatformDetection` to the script.
2. **Fix Path Handling**: Replace hardcoded paths with `Join-Path` functions.
3. **Add Platform Checks**: Add conditional logic for platform-specific code sections.
4. **Implement Error Handling**: Ensure consistent error handling across platforms.
5. **Test on All Platforms**: Verify script functionality on Windows PowerShell, PowerShell Core on Windows, and PowerShell Core on Linux.
6. **Document Changes**: Update script documentation with cross-platform notes.

###### Testing Strategy

For each migrated script:

1. Run on Windows PowerShell 5.1
2. Run on PowerShell Core 7+ on Windows
3. Run on PowerShell Core in WSL (Ubuntu)
4. Verify results are consistent across platforms
5. Document any platform-specific limitations

###### Implementation Guidelines

- Always use `Join-Path` for path operations
- Use `[System.Environment]::NewLine` for line breaks
- Check platform before using platform-specific features
- Create wrapper functions for functionality that differs across platforms
- Use `Invoke-Command` for remote execution instead of `Enter-PSSession` when possible
- Test file operations with different path formats

_Generated on $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")_
"@
    
    $report | Out-File -FilePath $OutputPath -Encoding utf8
    
    Write-Host "Migration priorities report created successfully." -ForegroundColor Green
}

##### Main execution flow
function Main {
    Write-Host "=== tYDiSync~ Cross-Platform Script Analysis ===" -ForegroundColor Cyan
    
    ##### Find PowerShell scripts
    $scripts = Find-PowerShellScripts
    
    ##### Analyze scripts for cross-platform issues
    $analysisResults = Analyze-ScriptsForIssues -Scripts $scripts -IssueTypes $issueTypes
    
    ##### Export script inventory
    Export-ScriptInventory -AnalysisResults $analysisResults -OutputPath $inventoryOutputPath
    
    ##### Create analysis report
    Create-AnalysisReport -AnalysisResults $analysisResults -OutputPath $analysisReportPath -IssueTypes $issueTypes
    
    ##### Create prioritization report
    Create-PrioritizationReport -AnalysisResults $analysisResults -OutputPath $prioritizationReportPath
    
    Write-Host "=== Script Analysis Completed ===" -ForegroundColor Cyan
    Write-Host "Inventory CSV: $inventoryOutputPath" -ForegroundColor Green
    Write-Host "Analysis Report: $analysisReportPath" -ForegroundColor Green
    Write-Host "Prioritization Report: $prioritizationReportPath" -ForegroundColor Green
}

# Run the main function
Main 
