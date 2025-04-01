# prepare-powershell-review.ps1
# Purpose: Prepare for PowerShell standards review meeting
# Ticket: CFIO-2025-02
# Created: 2025-03-13

# ========================================================================
# tYDiSync~ PowerShell Standards Review Preparation
# ========================================================================

# Set preferences
$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

##### Initialize variables
$logFile = "logs/powershell-review-$(Get-Date -Format 'yyyyMMdd').log"
$outputDir = "docs/powershell-review"
$standardsFile = "docs/powershell-standards.md"
$scriptsDir = "scripts"
$reportFile = "$outputDir/powershell-review-report.md"
$meetingFile = "$outputDir/powershell-review-meeting-agenda.md"

##### Ensure output directory exists
if (-not (Test-Path $outputDir)) {
    New-Item -Path $outputDir -ItemType Directory -Force | Out-Null
    Write-Host "Created output directory: $outputDir" -ForegroundColor Green
}

##### Ensure log directory exists
$logDir = Split-Path -Parent $logFile
if (-not (Test-Path $logDir)) {
    New-Item -Path $logDir -ItemType Directory -Force | Out-Null
    Write-Host "Created log directory: $logDir" -ForegroundColor Green
}

##### Function to write to log file and console
function Write-Log {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [Parameter(Mandatory=$false)]
        [ValidateSet("INFO", "SUCCESS", "WARNING", "ERROR")]
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    ##### Write to log file
    Add-Content -Path $logFile -Value $logMessage
    
    ##### Write to console with color based on level
    switch ($Level) {
        "INFO" { Write-Host $logMessage -ForegroundColor Gray }
        "SUCCESS" { Write-Host $logMessage -ForegroundColor Green }
        "WARNING" { Write-Host $logMessage -ForegroundColor Yellow }
        "ERROR" { Write-Host $logMessage -ForegroundColor Red }
        default { Write-Host $logMessage }
    }
}

##### Banner
Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "      tYDiSync~ PowerShell Standards Review Preparation          " -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host ""

##### Helper function to initialize the analysis object
function Initialize-Analysis {
    return [PSCustomObject]@{
        TotalScripts = 0
        ScriptsWithoutErrorActionPreference = @()
        ScriptsWithoutTryCatch = @()
        ScriptsWithPotentialIssues = @()
        CommandChainingIssues = @()
        StandardsCompliant = @()
        StandardsNonCompliant = @()
    }
}

##### 1. Analyze PowerShell scripts
function Analyze-PowerShellScripts {
    param (
        [string]$ScriptsDirectory
    )
    
    Write-Host "Analyzing PowerShell scripts in: $ScriptsDirectory" -ForegroundColor Cyan
    
    $analysis = Initialize-Analysis
    
    ##### Get all PowerShell scripts in the specified directory
    $scripts = Get-ChildItem -Path $ScriptsDirectory -Filter "*.ps1" -Recurse -ErrorAction SilentlyContinue
    
    ##### Check if scripts were found
    if ($null -eq $scripts) {
        Write-Host "No PowerShell scripts found in the specified directory!" -ForegroundColor Yellow
        return $analysis
    }
    
    ##### Ensure scripts is an array, even if only one file is found
    if ($scripts -isnot [System.Array]) {
        $scripts = @($scripts)
    }
    
    $analysis.TotalScripts = $scripts.Count
    
    Write-Host "Found $($analysis.TotalScripts) PowerShell scripts to analyze." -ForegroundColor Green
    
    foreach ($script in $scripts) {
        Write-Host "Analyzing script: $($script.Name)" -ForegroundColor Gray
        
        try {
            $content = Get-Content -Path $script.FullName -Raw -ErrorAction Stop
            
            ##### Skip empty files
            if ([string]::IsNullOrEmpty($content)) {
                Write-Host "  Script is empty, skipping: $($script.Name)" -ForegroundColor Yellow
                continue
            }
            
            ##### Check for ErrorActionPreference
            if ($content -notmatch "\`$ErrorActionPreference\s*=") {
                $analysis.ScriptsWithoutErrorActionPreference += $script.Name
            }
            
            ##### Check for try-catch blocks
            if ($content -notmatch "try\s*{") {
                $analysis.ScriptsWithoutTryCatch += $script.Name
            }
            
            ##### Simple check for potential issues with $_ variable
            if ($content -match '\".*\$_.*\"') {
                $analysis.ScriptsWithPotentialIssues += "$($script.Name) (potential `$_ variable in string)"
            }
            
            ##### Check for command chaining with &&
            if ($content -match '&&') {
                $analysis.CommandChainingIssues += "$($script.Name) (using && instead of ;)"
            }
            
            ##### Determine standards compliance based on presence of key elements
            if (($content -match "\`$ErrorActionPreference\s*=") -and 
                ($content -match "try\s*{") -and 
                ($content -notmatch '\".*\$_.*\"') -and
                ($content -notmatch '&&')) {
                $analysis.StandardsCompliant += $script.Name
            }
            else {
                $analysis.StandardsNonCompliant += $script.Name
            }
        }
        catch {
            Write-Host "  Error analyzing script $($script.Name): $_" -ForegroundColor Red
        }
    }
    
    return $analysis
}

##### 2. Generate review report
function Generate-ReviewReport {
    param (
        [PSCustomObject]$Analysis,
        [string]$OutputFile
    )
    
    if ($null -eq $Analysis) {
        Write-Host "Analysis object is null! Cannot generate report." -ForegroundColor Red
        return
    }
    
    try {
        $report = @"
##### PowerShell Scripts Standards Review Report
Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

###### Summary
- Total Scripts Analyzed: $($Analysis.TotalScripts)
- Standards Compliant: $(if ($null -ne $Analysis.StandardsCompliant) { $Analysis.StandardsCompliant.Count } else { 0 })
- Standards Non-Compliant: $(if ($null -ne $Analysis.StandardsNonCompliant) { $Analysis.StandardsNonCompliant.Count } else { 0 })

###### Details

####### Missing ErrorActionPreference
$(if ($null -ne $Analysis.ScriptsWithoutErrorActionPreference -and $Analysis.ScriptsWithoutErrorActionPreference.Count -gt 0) {
    ($Analysis.ScriptsWithoutErrorActionPreference | ForEach-Object { "- $_" }) -join "`n"
} else {
    "None - All scripts set ErrorActionPreference"
})

####### Missing Try-Catch Blocks
$(if ($null -ne $Analysis.ScriptsWithoutTryCatch -and $Analysis.ScriptsWithoutTryCatch.Count -gt 0) {
    ($Analysis.ScriptsWithoutTryCatch | ForEach-Object { "- $_" }) -join "`n"
} else {
    "None - All scripts use try-catch blocks"
})

####### Potential `$_` Variable Issues
$(if ($null -ne $Analysis.ScriptsWithPotentialIssues -and $Analysis.ScriptsWithPotentialIssues.Count -gt 0) {
    ($Analysis.ScriptsWithPotentialIssues | ForEach-Object { "- $_" }) -join "`n"
} else {
    "None - No scripts with potential `$_` variable issues"
})

####### Command Chaining Issues (using && instead of ;)
$(if ($null -ne $Analysis.CommandChainingIssues -and $Analysis.CommandChainingIssues.Count -gt 0) {
    ($Analysis.CommandChainingIssues | ForEach-Object { "- $_" }) -join "`n"
} else {
    "None - No scripts with command chaining issues"
})

####### Standards Compliant Scripts
$(if ($null -ne $Analysis.StandardsCompliant -and $Analysis.StandardsCompliant.Count -gt 0) {
    ($Analysis.StandardsCompliant | ForEach-Object { "- $_" }) -join "`n"
} else {
    "None - No scripts are fully standards compliant"
})

####### Standards Non-Compliant Scripts
$(if ($null -ne $Analysis.StandardsNonCompliant -and $Analysis.StandardsNonCompliant.Count -gt 0) {
    ($Analysis.StandardsNonCompliant | ForEach-Object { "- $_" }) -join "`n"
} else {
    "None - All scripts are standards compliant"
})

###### Recommendations
1. Add `$ErrorActionPreference = 'Stop'` at the beginning of all scripts
2. Implement try-catch blocks for error handling
3. Avoid using the `$_` variable directly in strings
4. Use semicolons (;) instead of ampersands (&&) for command chaining
"@
        
        # Save the report to the specified output file
        $report | Out-File -FilePath $OutputFile -Encoding utf8 -Force
        
        Write-Host "Report generated successfully: $OutputFile" -ForegroundColor Green
    }
    catch {
        Write-Host "Error generating report: $_" -ForegroundColor Red
    }
}

##### 3. Generate meeting agenda
function Generate-MeetingAgenda {
    param (
        [Parameter(Mandatory=$true)]
        [hashtable]$Analysis
    )
    
    Write-Log "Generating meeting agenda..." "INFO"
    
    ##### Safely get counts with null checks
    $withoutStrictModeCount = if ($null -ne $Analysis.ScriptsWithoutStrictMode) { 
        if ($Analysis.ScriptsWithoutStrictMode -is [array] -or $Analysis.ScriptsWithoutStrictMode -is [System.Collections.ICollection]) { 
            $Analysis.ScriptsWithoutStrictMode.Count 
        } else { 
            if ($null -ne $Analysis.ScriptsWithoutStrictMode) { 1 } else { 0 } 
        } 
    } else { 0 }
    
    $withoutErrorActionCount = if ($null -ne $Analysis.ScriptsWithoutErrorActionPreference) { 
        if ($Analysis.ScriptsWithoutErrorActionPreference -is [array] -or $Analysis.ScriptsWithoutErrorActionPreference -is [System.Collections.ICollection]) { 
            $Analysis.ScriptsWithoutErrorActionPreference.Count 
        } else { 
            if ($null -ne $Analysis.ScriptsWithoutErrorActionPreference) { 1 } else { 0 } 
        } 
    } else { 0 }
    
    $withoutTryCatchCount = if ($null -ne $Analysis.ScriptsWithoutTryCatch) { 
        if ($Analysis.ScriptsWithoutTryCatch -is [array] -or $Analysis.ScriptsWithoutTryCatch -is [System.Collections.ICollection]) { 
            $Analysis.ScriptsWithoutTryCatch.Count 
        } else { 
            if ($null -ne $Analysis.ScriptsWithoutTryCatch) { 1 } else { 0 } 
        } 
    } else { 0 }
    
    $potentialIssuesCount = if ($null -ne $Analysis.ScriptsWithPotentialIssues) { 
        if ($Analysis.ScriptsWithPotentialIssues -is [array] -or $Analysis.ScriptsWithPotentialIssues -is [System.Collections.ICollection]) { 
            $Analysis.ScriptsWithPotentialIssues.Count 
        } else { 
            if ($null -ne $Analysis.ScriptsWithPotentialIssues) { 1 } else { 0 } 
        } 
    } else { 0 }
    
    $agenda = @"
# tYDiSync~ PowerShell Standards Review Meeting Agenda

**Meeting Date:** [SCHEDULE DATE]
**Location:** [VIRTUAL/PHYSICAL LOCATION]
**Duration:** 60 minutes

## Meeting Purpose
Review and align on PowerShell coding standards for the tYDiSync~ project to improve code quality, maintainability, and error handling.

## Attendees
- [LIST TEAM MEMBERS]

## Preparation Materials
- Please review the PowerShell Standards document: docs/powershell-standards.md
- Review the attached PowerShell Standards Review Report
- Prepare questions or suggestions for standards enhancement

## Agenda Items

### 1. Introduction (5 min)
- Meeting objectives
- Review of PowerShell standards document

### 2. Current Status Review (10 min)
- Overview of PowerShell scripts analysis
- Key findings:
  - $withoutStrictModeCount scripts need Set-StrictMode
  - $withoutErrorActionCount scripts need ErrorActionPreference
  - $withoutTryCatchCount scripts need try-catch blocks
  - $potentialIssuesCount scripts have potential issues

### 3. Standards Discussion (20 min)
- Error handling best practices
- Variable reference requirements
- Command chaining conventions
- Logging standards
- Script header format

### 4. Implementation Plan (15 min)
- Prioritization of scripts to update
- Assignment of responsibilities
- Timeline for standards implementation

### 5. Next Steps and Action Items (10 min)
- Document decisions
- Schedule follow-up review
- Set deadlines for implementation

## Notes and Action Items
[To be completed during meeting]

"@
    
    Set-Content -Path $meetingFile -Value $agenda
    Write-Log "Meeting agenda saved to $meetingFile" "SUCCESS"
}

##### Main execution
try {
    ##### Analyze scripts
    $analysis = Analyze-PowerShellScripts -ScriptsDirectory $scriptsDir
    
    ##### Generate review report
    Generate-ReviewReport -Analysis $analysis -OutputFile $reportFile
    
    ##### Generate meeting agenda
    Generate-MeetingAgenda -Analysis $analysis
    
    ##### Print summary of analysis with null checks
    Write-Host "`nAnalysis Summary:" -ForegroundColor Cyan
    Write-Host "- Total PowerShell scripts: $($analysis.TotalScripts)" -ForegroundColor White
    
    $withoutStrictModeCount = if ($null -ne $analysis.ScriptsWithoutStrictMode) { 
        if ($analysis.ScriptsWithoutStrictMode -is [array] -or $analysis.ScriptsWithoutStrictMode -is [System.Collections.ICollection]) { 
            $analysis.ScriptsWithoutStrictMode.Count 
        } else { 
            if ($null -ne $analysis.ScriptsWithoutStrictMode) { 1 } else { 0 } 
        } 
    } else { 0 }
    Write-Host "- Scripts without Set-StrictMode: $withoutStrictModeCount" -ForegroundColor White
    
    $withoutErrorActionCount = if ($null -ne $analysis.ScriptsWithoutErrorActionPreference) { 
        if ($analysis.ScriptsWithoutErrorActionPreference -is [array] -or $analysis.ScriptsWithoutErrorActionPreference -is [System.Collections.ICollection]) { 
            $analysis.ScriptsWithoutErrorActionPreference.Count 
        } else { 
            if ($null -ne $analysis.ScriptsWithoutErrorActionPreference) { 1 } else { 0 } 
        } 
    } else { 0 }
    Write-Host "- Scripts without ErrorActionPreference: $withoutErrorActionCount" -ForegroundColor White
    
    $withoutTryCatchCount = if ($null -ne $analysis.ScriptsWithoutTryCatch) { 
        if ($analysis.ScriptsWithoutTryCatch -is [array] -or $analysis.ScriptsWithoutTryCatch -is [System.Collections.ICollection]) { 
            $analysis.ScriptsWithoutTryCatch.Count 
        } else { 
            if ($null -ne $analysis.ScriptsWithoutTryCatch) { 1 } else { 0 } 
        } 
    } else { 0 }
    Write-Host "- Scripts without try-catch blocks: $withoutTryCatchCount" -ForegroundColor White
    
    $potentialIssuesCount = if ($null -ne $analysis.ScriptsWithPotentialIssues) { 
        if ($analysis.ScriptsWithPotentialIssues -is [array] -or $analysis.ScriptsWithPotentialIssues -is [System.Collections.ICollection]) { 
            $analysis.ScriptsWithPotentialIssues.Count 
        } else { 
            if ($null -ne $analysis.ScriptsWithPotentialIssues) { 1 } else { 0 } 
        } 
    } else { 0 }
    Write-Host "- Scripts with potential issues: $potentialIssuesCount" -ForegroundColor White
    
    ##### Instructions for next steps
    Write-Host "`nNext steps:" -ForegroundColor Yellow
    Write-Host "1. Review the generated report at $reportFile" -ForegroundColor White
    Write-Host "2. Update the meeting agenda at $meetingFile with appropriate details" -ForegroundColor White
    Write-Host "3. Schedule the PowerShell standards review meeting with team members" -ForegroundColor White
    Write-Host "4. Distribute the agenda and report to attendees before the meeting" -ForegroundColor White
    
    Write-Log "PowerShell standards review preparation completed successfully" "SUCCESS"
}
catch {
    Write-Log "Error during PowerShell standards review preparation: $_" "ERROR"
    Write-Error $_
}

Write-Host "`n=================================================================" -ForegroundColor Cyan
Write-Host "      PowerShell Standards Review Preparation Complete            " -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan 
