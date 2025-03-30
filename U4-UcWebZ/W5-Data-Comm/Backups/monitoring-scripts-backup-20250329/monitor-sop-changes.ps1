#Requires -Version 5.1

<#
.SYNOPSIS
    Monitors SOP documents for changes and updates configuration files accordingly.

.DESCRIPTION
    This script watches for changes in Standard Operating Procedure (SOP) documents
    and updates the configuration files used by the cFish.io Digital Organization System tools.
    It ensures that all tools remain in sync with the latest SOP requirements.

.NOTES
    File Name      : monitor-sop-changes.ps1
    Author         : AI: Cursor (Claude 3.7 Sonnet)
    Prerequisite   : PowerShell 5.1 or later
    Created        : 2025-03-14
    Version        : 1.0.0
#>

param(
    [switch]$RunOnce = $false,
    [switch]$Detailed = $false
)

# Set strict mode to catch common scripting mistakes
Set-StrictMode -Version Latest

# Set error action preference to stop on errors
$ErrorActionPreference = "Stop"

##### Get the root directory (current script location parent directory)
$rootDir = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

##### Log file path
$logFile = Join-Path $rootDir "U5-Data\Reports\sop-monitor-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"

##### Memory.md file path
$memoryMdFile = Join-Path $rootDir "Documentation\memory.md"

##### Changelog.md file path
$changelogMdFile = Join-Path $rootDir "Documentation\changelog.md"

##### SOP document paths (modify these paths to match your actual SOP documents)
$sopDocuments = @(
    @{
        Path = Join-Path $rootDir "Documentation\SOPs\ucf-u3.1-file-organization-sop-20250301.md"
        Type = "FileOrganization"
        LastModified = $null
        Hash = $null
    },
    @{
        Path = Join-Path $rootDir "Documentation\SOPs\ucf-u3.2-file-naming-convention-sop-20250301.md"
        Type = "FileNaming"
        LastModified = $null
        Hash = $null
    },
    @{
        Path = Join-Path $rootDir "Documentation\SOPs\ucf-u3.3-directory-structure-sop-20250301.md"
        Type = "DirectoryStructure"
        LastModified = $null
        Hash = $null
    }
)

##### Configuration files used by tools
$configFiles = @(
    @{
        Path = Join-Path $rootDir "U7-Systems\Tools\Config\file-naming-config.json"
        Type = "FileNaming"
    },
    @{
        Path = Join-Path $rootDir "U7-Systems\Tools\Config\directory-structure-config.json"
        Type = "DirectoryStructure"
    },
    @{
        Path = Join-Path $rootDir "U7-Systems\Tools\Config\file-organization-config.json"
        Type = "FileOrganization"
    }
)

##### Function to write to log file and console
function Write-Log {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet("Info", "Warning", "Error", "Success", "Change")]
        [string]$Level = "Info"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    
    ##### Create directory for log file if it doesn't exist
    $logDir = Split-Path -Parent $logFile
    if (-not (Test-Path $logDir)) {
        New-Item -Path $logDir -ItemType Directory -Force | Out-Null
    }
    
    ##### Append to log file
    Add-Content -Path $logFile -Value $logEntry
    
    ##### Write to console with appropriate color
    switch ($Level) {
        "Info" { Write-Host $logEntry -ForegroundColor Gray }
        "Warning" { Write-Host $logEntry -ForegroundColor Yellow }
        "Error" { Write-Host $logEntry -ForegroundColor Red }
        "Success" { Write-Host $logEntry -ForegroundColor Green }
        "Change" { Write-Host $logEntry -ForegroundColor Cyan }
        default { Write-Host $logEntry }
    }
}

##### Function to calculate file hash
function Get-FileContentHash {
    param (
        [string]$FilePath
    )
    
    if (Test-Path $FilePath) {
        $fileContent = Get-Content -Path $FilePath -Raw
        $stream = [System.IO.MemoryStream]::new([System.Text.Encoding]::UTF8.GetBytes($fileContent))
        $hash = Get-FileHash -InputStream $stream -Algorithm SHA256
        return $hash.Hash
    }
    
    return $null
}

##### Function to update memory.md with operation details
function Update-MemoryMd {
    param (
        [string]$Title,
        [string[]]$Details
    )
    
    try {
        ##### Create Documentation directory if it doesn't exist
        $docDir = Split-Path -Parent $memoryMdFile
        if (-not (Test-Path $docDir)) {
            New-Item -Path $docDir -ItemType Directory -Force | Out-Null
        }
        
        ##### Check if memory.md exists, create it if not
        if (-not (Test-Path $memoryMdFile)) {
            Set-Content -Path $memoryMdFile -Value "# cFish.io Digital Organization System - Memory Log`n`n"
        }
        
        ##### Create new entry
        $date = Get-Date -Format "MM-dd-yyyy"
        $entry = "###### $Title ($date)`n"
        
        foreach ($detail in $Details) {
            $entry += "- $detail`n"
        }
        
        $entry += "`n_Updated $date | AI: Cursor (Claude 3.7 Sonnet)_`n`n"
        
        ##### Read existing content
        $content = Get-Content -Path $memoryMdFile -Raw
        
        ##### Check if there's a "Next Steps" section
        if ($content -match "###### Next Steps") {
            # Insert before "Next Steps"
            $content = $content -replace "(###### Next Steps)", "$entry`$1"
        } else {
            ##### Append to the end
            $content += $entry
        }
        
        ##### Save back to file
        Set-Content -Path $memoryMdFile -Value $content
        
        Write-Log "Updated memory.md with entry: $Title" "Success"
        return $true
    }
    catch {
        Write-Log ("Failed to update memory.md: " + $_.Exception.Message) "Error"
        return $false
    }
}

##### Function to update changelog.md with operation details
function Update-ChangelogMd {
    param (
        [string]$Version,
        [datetime]$Date,
        [string[]]$Added = @(),
        [string[]]$Changed = @(),
        [string[]]$Fixed = @()
    )
    
    try {
        ##### Create Documentation directory if it doesn't exist
        $docDir = Split-Path -Parent $changelogMdFile
        if (-not (Test-Path $docDir)) {
            New-Item -Path $docDir -ItemType Directory -Force | Out-Null
        }
        
        ##### Check if changelog.md exists, create it if not
        if (-not (Test-Path $changelogMdFile)) {
            Set-Content -Path $changelogMdFile -Value "# Changelog`n`nAll notable changes to the cFish.io Digital Organization System will be documented in this file.`n`n"
        }
        
        ##### Format the date
        $formattedDate = $Date.ToString("yyyy-MM-dd")
        
        ##### Create new entry
        $entry = "## [$Version] - [$formattedDate]`n`n"
        
        if ($Added.Count -gt 0) {
            $entry += "####### Added`n"
            foreach ($item in $Added) {
                $entry += "- $item`n"
            }
            $entry += "`n"
        }
        
        if ($Changed.Count -gt 0) {
            $entry += "####### Changed`n"
            foreach ($item in $Changed) {
                $entry += "- $item`n"
            }
            $entry += "`n"
        }
        
        if ($Fixed.Count -gt 0) {
            $entry += "####### Fixed`n"
            foreach ($item in $Fixed) {
                $entry += "- $item`n"
            }
            $entry += "`n"
        }
        
        ##### Read existing content
        $content = Get-Content -Path $changelogMdFile -Raw
        
        ##### Check if the version already exists
        if ($content -match "## \[$Version\]") {
            Write-Log "Version $Version already exists in changelog. Not updating." "Warning"
            return $false
        }
        
        ##### Insert after the header
        $content = $content -replace "(# Changelog.*?notable changes.*?\n\n)", "`$1$entry"
        
        ##### Save back to file
        Set-Content -Path $changelogMdFile -Value $content
        
        Write-Log "Updated changelog.md with version: $Version" "Success"
        return $true
    }
    catch {
        Write-Log ("Failed to update changelog.md: " + $_.Exception.Message) "Error"
        return $false
    }
}

##### Function to extract configuration from SOP document
function Extract-SOPConfiguration {
    param (
        [string]$SOPPath,
        [string]$SOPType
    )
    
    try {
        if (-not (Test-Path $SOPPath)) {
            Write-Log ("SOP document not found: " + $SOPPath) "Warning"
            return $null
        }
        
        $sopContent = Get-Content -Path $SOPPath -Raw
        
        ##### Extract configuration based on SOP type
        switch ($SOPType) {
            "FileNaming" {
                ##### Extract file naming convention configuration
                $config = @{
                    CompanyPrefixes = @()
                    DepartmentNumbers = @()
                    FileNamePattern = ""
                    ExemptPatterns = @()
                    LastUpdated = Get-Date -Format "yyyy-MM-dd"
                }
                
                ##### Extract company prefixes (this is a simplified example - adjust pattern as needed)
                if ($sopContent -match "Company Prefixes:\s*(?<prefixes>[\w\s,]+)") {
                    $prefixesText = $Matches['prefixes']
                    $config.CompanyPrefixes = $prefixesText -split '[,\s]+' | Where-Object { $_ -ne "" }
                }
                
                ##### Extract department numbers
                if ($sopContent -match "Department Numbers:\s*(?<depts>[\w\s,]+)") {
                    $deptsText = $Matches['depts']
                    $config.DepartmentNumbers = $deptsText -split '[,\s]+' | Where-Object { $_ -ne "" }
                }
                
                ##### Extract file name pattern
                if ($sopContent -match "File Name Pattern:\s*(?<pattern>.+)") {
                    $config.FileNamePattern = $Matches['pattern'].Trim()
                }
                
                ##### Extract exempt patterns
                if ($sopContent -match "Exempt Files:([\s\S]*?)(?=##|$)") {
                    $exemptText = $Matches[1]
                    $config.ExemptPatterns = $exemptText -split '\r?\n' | 
                                             Where-Object { $_ -match '^\s*-\s*(.+)' } | 
                                             ForEach-Object { $Matches[1].Trim() }
                }
                
                return $config
            }
            "DirectoryStructure" {
                ##### Extract directory structure configuration
                $config = @{
                    RootDirectories = @()
                    RequiredDirectories = @()
                    LastUpdated = Get-Date -Format "yyyy-MM-dd"
                }
                
                ##### Extract root directories (simplified example)
                if ($sopContent -match "Root Directories:([\s\S]*?)(?=##|$)") {
                    $rootText = $Matches[1]
                    $config.RootDirectories = $rootText -split '\r?\n' | 
                                             Where-Object { $_ -match '^\s*-\s*(.+)' } | 
                                             ForEach-Object { $Matches[1].Trim() }
                }
                
                ##### Extract required directories
                if ($sopContent -match "Required Directories:([\s\S]*?)(?=##|$)") {
                    $requiredText = $Matches[1]
                    $config.RequiredDirectories = $requiredText -split '\r?\n' | 
                                                Where-Object { $_ -match '^\s*-\s*(.+)' } | 
                                                ForEach-Object { $Matches[1].Trim() }
                }
                
                return $config
            }
            "FileOrganization" {
                ##### Extract file organization configuration
                $config = @{
                    OrganizationRules = @()
                    FileCategoryMappings = @{}
                    LastUpdated = Get-Date -Format "yyyy-MM-dd"
                }
                
                ##### Extract organization rules (simplified example)
                if ($sopContent -match "Organization Rules:([\s\S]*?)(?=##|$)") {
                    $rulesText = $Matches[1]
                    $config.OrganizationRules = $rulesText -split '\r?\n' | 
                                              Where-Object { $_ -match '^\s*-\s*(.+)' } | 
                                              ForEach-Object { $Matches[1].Trim() }
                }
                
                ##### Extract file category mappings (simplified)
                if ($sopContent -match "File Category Mappings:([\s\S]*?)(?=##|$)") {
                    $mappingsText = $Matches[1]
                    $mappings = $mappingsText -split '\r?\n' | 
                                Where-Object { $_ -match '^\s*-\s*(.+?):(.+)' }
                    
                    foreach ($mapping in $mappings) {
                        if ($mapping -match '^\s*-\s*(.+?):(.+)') {
                            $key = $Matches[1].Trim()
                            $value = $Matches[2].Trim()
                            $config.FileCategoryMappings[$key] = $value
                        }
                    }
                }
                
                return $config
            }
            default {
                Write-Log "Unknown SOP type: $SOPType" "Warning"
                return $null
            }
        }
    }
    catch {
        Write-Log ("Error extracting configuration from SOP: " + $_.Exception.Message) "Error"
        return $null
    }
}

##### Function to update tool configuration file
function Update-ConfigurationFile {
    param (
        [string]$ConfigPath,
        [object]$Configuration,
        [string]$SOPType
    )
    
    try {
        ##### Create directory for config file if it doesn't exist
        $configDir = Split-Path -Parent $ConfigPath
        if (-not (Test-Path $configDir)) {
            New-Item -Path $configDir -ItemType Directory -Force | Out-Null
        }
        
        ##### Convert configuration to JSON and save
        $Configuration | ConvertTo-Json -Depth 10 | Set-Content -Path $ConfigPath
        
        Write-Log "Updated configuration file: $ConfigPath" "Success"
        return $true
    }
    catch {
        Write-Log ("Error updating configuration file: " + $_.Exception.Message) "Error"
        return $false
    }
}

##### Function to check if SOP documents have changed
function Test-SOPChanges {
    $changesDetected = $false
    $changeDetails = @()
    
    foreach ($sop in $sopDocuments) {
        if (Test-Path $sop.Path) {
            $currentLastModified = (Get-Item $sop.Path).LastWriteTime
            $currentHash = Get-FileContentHash -FilePath $sop.Path
            
            if (($sop.LastModified -ne $null -and $currentLastModified -ne $sop.LastModified) -or 
                ($sop.Hash -ne $null -and $currentHash -ne $sop.Hash)) {
                
                Write-Log "Change detected in SOP document: $($sop.Path)" "Change"
                $changesDetected = $true
                
                ##### Extract new configuration
                $config = Extract-SOPConfiguration -SOPPath $sop.Path -SOPType $sop.Type
                
                if ($config -ne $null) {
                    ##### Find matching config file
                    $configFile = $configFiles | Where-Object { $_.Type -eq $sop.Type } | Select-Object -First 1
                    
                    if ($configFile -ne $null) {
                        ##### Update the config file
                        if (Update-ConfigurationFile -ConfigPath $configFile.Path -Configuration $config -SOPType $sop.Type) {
                            $sopType = $sop.Type
                            $sopFileName = Split-Path -Leaf $sop.Path
                            $changeDetails += "Updated $sopType configuration based on changes in $sopFileName"
                        }
                    }
                }
                
                ##### Update SOP tracking information
                $sop.LastModified = $currentLastModified
                $sop.Hash = $currentHash
            }
            else {
                if ($Detailed) {
                    Write-Log "No changes detected in SOP document: $($sop.Path)" "Info"
                }
            }
        }
        else {
            Write-Log "SOP document not found: $($sop.Path)" "Warning"
            
            ##### Initialize config directory structure if needed
            foreach ($configFile in $configFiles) {
                $configDir = Split-Path -Parent $configFile.Path
                if (-not (Test-Path $configDir)) {
                    New-Item -Path $configDir -ItemType Directory -Force | Out-Null
                    Write-Log "Created configuration directory: $configDir" "Info"
                }
            }
        }
    }
    
    if ($changesDetected) {
        ##### Update memory.md with changes
        Update-MemoryMd -Title "SOP Document Changes" -Details $changeDetails
        
        ##### Update changelog.md with changes
        Update-ChangelogMd -Version "1.0.1" -Date (Get-Date) -Changed $changeDetails
    }
    
    return $changesDetected
}

##### Function to initialize SOP tracking
function Initialize-SOPTracking {
    Write-Log "Initializing SOP tracking..." "Info"
    
    ##### Create Config directory if it doesn't exist
    $configDir = Join-Path $rootDir "U7-Systems\Tools\Config"
    if (-not (Test-Path $configDir)) {
        New-Item -Path $configDir -ItemType Directory -Force | Out-Null
        Write-Log "Created configuration directory: $configDir" "Info"
    }
    
    foreach ($sop in $sopDocuments) {
        if (Test-Path $sop.Path) {
            $sop.LastModified = (Get-Item $sop.Path).LastWriteTime
            $sop.Hash = Get-FileContentHash -FilePath $sop.Path
            
            Write-Log "Initialized tracking for SOP: $($sop.Path)" "Info"
            
            ##### Extract initial configuration
            $config = Extract-SOPConfiguration -SOPPath $sop.Path -SOPType $sop.Type
            
            if ($config -ne $null) {
                ##### Find matching config file
                $configFile = $configFiles | Where-Object { $_.Type -eq $sop.Type } | Select-Object -First 1
                
                if ($configFile -ne $null) {
                    ##### Update the config file
                    Update-ConfigurationFile -ConfigPath $configFile.Path -Configuration $config -SOPType $sop.Type
                }
            }
        }
        else {
            Write-Log "SOP document not found: $($sop.Path)" "Warning"
        }
    }
}

##### Function to rename tools according to file naming convention
function Rename-ToolsAccordingToConvention {
    Write-Log "Checking tool names against file naming convention..." "Info"
    
    $toolsDir = Join-Path $rootDir "U7-Systems\Tools"
    $tools = Get-ChildItem -Path $toolsDir -File
    
    $changedTools = @()
    
    ##### Load file naming config if available
    $configPath = Join-Path $toolsDir "Config\file-naming-config.json"
    $config = $null
    
    if (Test-Path $configPath) {
        $config = Get-Content -Path $configPath -Raw | ConvertFrom-Json
    }
    
    ##### Default settings if config not available
    $companyPrefix = "ucf"
    $department = "u7"
    $filePattern = "$companyPrefix-$department.7-{0}-{1}.{2}"
    
    ##### Override with config if available
    if ($config -ne $null) {
        if ($config.CompanyPrefixes -and $config.CompanyPrefixes.Count -gt 0) {
            $companyPrefix = $config.CompanyPrefixes[0]
        }
        if ($config.DepartmentNumbers -and $config.DepartmentNumbers.Count -gt 0) {
            ##### Find u7 if available, otherwise use first
            $u7 = $config.DepartmentNumbers | Where-Object { $_ -eq "u7" } | Select-Object -First 1
            $department = if ($u7) { $u7 } else { $config.DepartmentNumbers[0] }
        }
    }
    
    foreach ($tool in $tools) {
        ##### Skip already compliant files and .bat files (which are wrappers)
        if (($tool.Name -match "^$companyPrefix-$department\.\d-.*-\d{8}\.(ps1|bat)$") -or 
            ($tool.Name -match "\.bat$")) {
            continue
        }
        
        ##### Generate new name
        $extension = $tool.Extension.TrimStart(".")
        $date = Get-Date -Format "yyyyMMdd"
        $baseName = $tool.BaseName
        
        ##### Format description part (convert camelCase to kebab-case)
        $description = $baseName -replace '([a-z])([A-Z])', '$1-$2' 
        $description = $description.ToLower() -replace '[^a-z0-9-]', '-' -replace '-+', '-' -replace '^-|-$', ''
        
        $newName = $filePattern -f "tools", $description, $extension
        $newName = $newName -replace "{date}", $date
        
        ##### Add date if missing
        if (-not ($newName -match '\d{8}')) {
            $newName = $newName -replace "\.$extension$", "-$date.$extension"
        }
        
        ##### Check if new name already exists
        $newPath = Join-Path $toolsDir $newName
        if (Test-Path $newPath) {
            Write-Log "Cannot rename $($tool.Name) to $newName: File already exists" "Warning"
            continue
        }
        
        try {
            Rename-Item -Path $tool.FullName -NewName $newName
            $changedTools += "$($tool.Name) -> $newName"
            Write-Log "Renamed tool: $($tool.Name) -> $newName" "Success"
        }
        catch {
            Write-Log ("Failed to rename $($tool.Name): " + $_.Exception.Message) "Error"
        }
    }
    
    if ($changedTools.Count -gt 0) {
        ##### Update memory.md with changes
        Update-MemoryMd -Title "Tool Naming Convention Compliance" -Details $changedTools
        
        ##### Update changelog.md with changes
        Update-ChangelogMd -Version "1.0.1" -Date (Get-Date) -Changed @("Renamed tools to follow file naming convention")
    }
    
    return $changedTools.Count
}

##### Main function to monitor SOP changes
function Monitor-SOPChanges {
    param (
        [bool]$RunOnce = $false,
        [bool]$Detailed = $false
    )
    
    Write-Log "Starting SOP change monitoring..." "Info"
    
    ##### Initialize SOP tracking
    Initialize-SOPTracking
    
    ##### Check for tool naming convention compliance
    $renamedTools = Rename-ToolsAccordingToConvention
    
    if ($RunOnce) {
        ##### Check for changes once
        Test-SOPChanges
        Write-Log "SOP change monitoring completed." "Info"
    }
    else {
        ##### Continuous monitoring
        Write-Log "Continuous SOP change monitoring started. Press Ctrl+C to exit." "Info"
        
        try {
            while ($true) {
                $changesDetected = Test-SOPChanges
                
                if ($Detailed -or $changesDetected) {
                    Write-Log "Waiting for SOP changes..." "Info"
                }
                
                ##### Wait 60 seconds before checking again
                Start-Sleep -Seconds 60
            }
        }
        catch {
            Write-Log ("Error in monitoring: " + $_.Exception.Message) "Error"
        }
        finally {
            Write-Log "SOP change monitoring stopped." "Info"
        }
    }
}

##### Main execution
try {
    Write-Host "cFish.io Digital Organization System - SOP Change Monitor" -ForegroundColor Cyan
    Write-Host "=================================================================" -ForegroundColor Cyan
    
    ##### Run the monitor
    Monitor-SOPChanges -RunOnce $RunOnce -Detailed $Detailed
}
catch {
    Write-Log ("Unhandled exception: " + $_.Exception.Message) "Error"
    Write-Host "`nAn error occurred during SOP monitoring." -ForegroundColor Red
    Write-Host "See log file for details: $logFile" -ForegroundColor Red
    exit 1
} 
