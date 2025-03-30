<#
.SYNOPSIS
    Creates an inventory of PowerShell scripts with cross-platform compatibility analysis.

.DESCRIPTION
    This script scans the specified directories for PowerShell scripts (.ps1 files),
    analyzes their content for platform-specific code, dependencies, and cross-platform
    compatibility issues, and generates a CSV inventory with prioritization.

.PARAMETER ScanDirectories
    Array of directories to scan for PowerShell scripts.

.PARAMETER OutputPath
    Path where to save the CSV inventory file.

.NOTES
    File Name      : cross-platform-script-inventory.ps1
    Author         : tY FischEYe
    Prerequisite   : PowerShell 5.1 or later
    Created        : 2025-03-13
    Version        : 1.0
    Cross-Platform : Yes (Windows PowerShell 5.1+, PowerShell Core 7+ on Windows/Linux/macOS)

.EXAMPLE
    .\cross-platform-script-inventory.ps1 -ScanDirectories @(".", "scripts", "sync-system") -OutputPath "docs/script-inventory.csv"
#>

#Requires -Version 5.1

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false, Position = 0)]
    [string[]]$ScanDirectories = @(".", "scripts", "sync-system"),

    [Parameter(Mandatory = $false, Position = 1)]
    [string]$OutputPath = "docs/script-inventory.csv"
)

#-----------------------------------------------------------[Initialization]------------------------------------------------------------

##### Set strict mode to catch common scripting mistakes
Set-StrictMode -Version Latest

##### Set error action preference to stop on errors
$ErrorActionPreference = "Stop"

##### Import platform detection function from template
. (Join-Path -Path $PSScriptRoot -ChildPath "cross-platform-template.ps1")

##### Create platform info object
$Platform = Get-PlatformInfo

#-----------------------------------------------------------[Functions]---------------------------------------------------------------

function Test-PathExists {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path
    )
    
    try {
        return (Test-Path -Path $Path)
    }
    catch {
        Write-Error "Error testing path: $_"
        return $false
    }
}

function Get-ScriptPriority {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Content,
        
        [Parameter(Mandatory = $true)]
        [string]$FileName
    )
    
    ##### Keywords that indicate critical scripts
    $criticalKeywords = @(
        'sync-engine', 
        'data-backup', 
        'error-handling', 
        'core-functions',
        'backup', 
        'sync', 
        'critical'
    )
    
    ##### Keywords that indicate high priority scripts
    $highPriorityKeywords = @(
        'file-operations', 
        'log-management', 
        'config-handler', 
        'user-interface',
        'configuration', 
        'logging', 
        'security',
        'authentication'
    )
    
    ##### Keywords that indicate medium priority scripts
    $mediumPriorityKeywords = @(
        'reporting', 
        'maintenance', 
        'scheduling', 
        'notification',
        'user-notification',
        'report'
    )
    
    ##### Default priority is Low
    $priority = "Low"
    
    ##### Check for critical keywords
    foreach ($keyword in $criticalKeywords) {
        if ($FileName -like "*$keyword*" -or $Content -like "*function*$keyword*") {
            $priority = "Critical"
            break
        }
    }
    
    ##### If not critical, check for high priority keywords
    if ($priority -eq "Low") {
        foreach ($keyword in $highPriorityKeywords) {
            if ($FileName -like "*$keyword*" -or $Content -like "*function*$keyword*") {
                $priority = "High"
                break
            }
        }
    }
    
    ##### If not high, check for medium priority keywords
    if ($priority -eq "Low") {
        foreach ($keyword in $mediumPriorityKeywords) {
            if ($FileName -like "*$keyword*" -or $Content -like "*function*$keyword*") {
                $priority = "Medium"
                break
            }
        }
    }
    
    return $priority
}

function Get-PlatformSpecificCode {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Content
    )
    
    $platformIssues = @()
    
    ##### Check for platform-specific automatic variables
    if ($Content -match '\$IsWindows|\$IsLinux|\$IsMacOS') {
        $platformIssues += "Uses automatic platform variables ($IsWindows/$IsLinux/$IsMacOS)"
    }
    
    ##### Check for platform-specific path separators
    if ($Content -match '[^\\]\\[^\\]') {
        $platformIssues += "Uses hardcoded backslashes"
    }
    
    ##### Check for platform-specific commands
    if ($Content -match 'cmd\.exe|cmd /c|powershell\.exe|bash|sh ') {
        $platformIssues += "Uses platform-specific command shells"
    }
    
    ##### Check for platform-specific paths
    if ($Content -match 'C:\\|/etc/|/usr/|/var/') {
        $platformIssues += "Uses hardcoded OS-specific paths"
    }
    
    ##### Check for WMI (Windows-specific)
    if ($Content -match 'Get-WmiObject|Get-CimInstance') {
        $platformIssues += "Uses Windows-specific WMI/CIM"
    }
    
    ##### Check for registry access (Windows-specific)
    if ($Content -match 'Registry::|HKLM:|HKCU:') {
        $platformIssues += "Uses Windows registry"
    }
    
    return $platformIssues -join ", "
}

function Get-Dependencies {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Content
    )
    
    $dependencies = @()
    
    ##### Check for module imports
    if ($Content -match 'Import-Module (.+?)($|\r|\n| )') {
        $dependencies += $matches[1].Trim()
    }
    
    ##### Check for dot sourcing
    if ($Content -match '\. \$?[^.\r\n]+\.ps1') {
        $dependencies += "Dot-sources other scripts"
    }
    
    ##### Check for requires statements
    if ($Content -match '#Requires -Module (.+?)($|\r|\n| )') {
        $dependencies += $matches[1].Trim()
    }
    
    ##### Check for external commands
    if ($Content -match 'Start-Process|Invoke-Expression|Invoke-Command') {
        $dependencies += "Executes external commands"
    }
    
    return $dependencies -join ", "
}

function Get-PowerShellScripts {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string[]]$Directories
    )
    
    $scripts = @()
    
    foreach ($dir in $Directories) {
        if (Test-PathExists -Path $dir) {
            $scriptFiles = Get-ChildItem -Path $dir -Filter "*.ps1" -Recurse -File
            $scripts += $scriptFiles
        }
        else {
            Write-Warning "Directory does not exist: $dir"
        }
    }
    
    return $scripts
}

function Export-ScriptInventory {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [System.Object[]]$Inventory,
        
        [Parameter(Mandatory = $true)]
        [string]$OutputPath
    )
    
    try {
        ##### Ensure output directory exists
        $outputDir = Split-Path -Path $OutputPath -Parent
        if (-not (Test-PathExists -Path $outputDir)) {
            New-Item -Path $outputDir -ItemType Directory -Force | Out-Null
            Write-Host "Created output directory: $outputDir" -ForegroundColor Green
        }
        
        ##### Export to CSV
        $Inventory | Sort-Object -Property Priority, Name | Export-Csv -Path $OutputPath -NoTypeInformation -Encoding UTF8
        Write-Host "Successfully exported inventory to: $OutputPath" -ForegroundColor Green
        
        ##### Also export a summary
        $summary = $Inventory | Group-Object -Property Priority | Select-Object Name, Count
        $summaryContent = "# PowerShell Script Inventory Summary`n`n"
        $summaryContent += "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n`n"
        $summaryContent += "###### Prioritized Scripts`n`n"
        
        foreach ($group in $summary) {
            $summaryContent += "- $($group.Name) Priority: $($group.Count) scripts`n"
        }
        
        $summaryContent += "`n###### Platform Issues`n`n"
        $platformIssueCount = ($Inventory | Where-Object { $_.PlatformSpecificIssues -ne "" }).Count
        $summaryContent += "- $platformIssueCount scripts have platform-specific code`n"
        
        $summaryPath = $OutputPath -replace '\.csv$', '-summary.md'
        $summaryContent | Out-File -FilePath $summaryPath -Encoding UTF8 -Force
        Write-Host "Successfully exported summary to: $summaryPath" -ForegroundColor Green
    }
    catch {
        Write-Error "Error exporting inventory: $_"
    }
}

#-----------------------------------------------------------[Main Execution]----------------------------------------------------------

try {
    Write-Host "Starting PowerShell script inventory..." -ForegroundColor Cyan
    Write-Host "Platform: $($Platform.PlatformName)" -ForegroundColor Yellow
    
    ##### Get all PowerShell scripts
    $scriptFiles = Get-PowerShellScripts -Directories $ScanDirectories
    Write-Host "Found $($scriptFiles.Count) PowerShell scripts" -ForegroundColor Green
    
    ##### Create inventory
    $inventory = @()
    $counter = 0
    
    foreach ($script in $scriptFiles) {
        $counter++
        Write-Progress -Activity "Analyzing scripts" -Status "Processing $counter of $($scriptFiles.Count)" -PercentComplete (($counter / $scriptFiles.Count) * 100)
        
        try {
            $content = Get-Content -Path $script.FullName -Raw -ErrorAction Stop
            $priority = Get-ScriptPriority -Content $content -FileName $script.Name
            $platformIssues = Get-PlatformSpecificCode -Content $content
            $dependencies = Get-Dependencies -Content $content
            
            $item = [PSCustomObject]@{
                Name                  = $script.Name
                Path                  = $script.FullName
                Priority              = $priority
                PlatformSpecificIssues = $platformIssues
                Dependencies          = $dependencies
                LastModified          = $script.LastWriteTime
                SizeKB                = [math]::Round($script.Length / 1KB, 2)
            }
            
            $inventory += $item
        }
        catch {
            Write-Warning "Error analyzing script $($script.FullName): $_"
        }
    }
    
    ##### Export inventory
    Export-ScriptInventory -Inventory $inventory -OutputPath $OutputPath
    
    Write-Host "Inventory complete! Analysis summary:" -ForegroundColor Cyan
    $inventory | Group-Object -Property Priority | Select-Object Name, Count | Format-Table -AutoSize
}
catch {
    Write-Error "Error during script inventory: $_"
} 
