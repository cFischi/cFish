<#
.SYNOPSIS
    Brief description of what the script does.

.DESCRIPTION
    Detailed description of the script functionality.

.PARAMETER Param1
    Description of first parameter.

.PARAMETER Param2
    Description of second parameter.

.NOTES
    File Name      : script-name.ps1
    Author         : Your Name
    Prerequisite   : PowerShell 5.1 or later
    Created        : 2025-03-13
    Version        : 1.0
    Cross-Platform : Yes (Windows PowerShell 5.1+, PowerShell Core 7+ on Windows/Linux/macOS)

.EXAMPLE
    .\script-name.ps1 -Param1 "Value1" -Param2 "Value2"
    Example of how to run the script with parameters.
#>

#Requires -Version 5.1

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false, Position = 0, HelpMessage = "Enter the first parameter")]
    [string]$Param1 = "DefaultValue",

    [Parameter(Mandatory = $false, Position = 1, HelpMessage = "Enter the second parameter")]
    [string]$Param2 = "DefaultValue"
)

#-----------------------------------------------------------[Initialization]------------------------------------------------------------

##### Set strict mode to catch common scripting mistakes
Set-StrictMode -Version Latest

##### Set error action preference to stop on errors
$ErrorActionPreference = "Stop"

#-----------------------------------------------------------[Platform Detection]--------------------------------------------------------

##### Platform detection - works on both Windows PowerShell 5.1 and PowerShell Core
function Get-PlatformInfo {
    ##### Create a custom object to hold platform information
    $platformInfo = [PSCustomObject]@{
        IsCore            = $false
        IsWindows         = $false
        IsLinux           = $false
        IsMacOS           = $false
        PlatformName      = ""
        PathSeparator     = [IO.Path]::DirectorySeparatorChar
        PSVersion         = $PSVersionTable.PSVersion
    }

    ##### Check if running PowerShell Core
    if ($PSVersionTable.PSEdition -eq 'Core') {
        $platformInfo.IsCore = $true
        
        ##### PowerShell Core specific platform checks
        if ($IsWindows -or [System.Environment]::OSVersion.Platform -eq "Win32NT") {
            $platformInfo.IsWindows = $true
            $platformInfo.PlatformName = "PowerShell Core (Windows)"
        }
        elseif ($IsLinux -or [System.Environment]::OSVersion.Platform -eq "Unix") {
            $platformInfo.IsLinux = $true
            $platformInfo.PlatformName = "PowerShell Core (Linux)"
        }
        elseif ($IsMacOS -or ([System.Environment]::OSVersion.Platform -eq "Unix" -and [System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::OSX))) {
            $platformInfo.IsMacOS = $true
            $platformInfo.PlatformName = "PowerShell Core (macOS)"
        }
        else {
            $platformInfo.PlatformName = "PowerShell Core (Unknown)"
        }
    }
    else {
        ##### Windows PowerShell
        $platformInfo.IsWindows = $true
        $platformInfo.PlatformName = "Windows PowerShell"
    }

    return $platformInfo
}

##### Get platform information
$Platform = Get-PlatformInfo

Write-Verbose "Platform: $($Platform.PlatformName)"
Write-Verbose "PowerShell Version: $($Platform.PSVersion)"

#-----------------------------------------------------------[Functions]---------------------------------------------------------------

function Write-LogMessage {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet("Info", "Warning", "Error", "Debug")]
        [string]$Severity = "Info",
        
        [Parameter(Mandatory = $false)]
        [string]$LogFilePath = (Join-Path -Path ${env}:TEMP -ChildPath "script-log.txt")
    )
    
    try {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logEntry = "[$timestamp] [$Severity] $Message"
        
        ##### Output to console with appropriate color
        switch ($Severity) {
            "Info"    { Write-Host $logEntry -ForegroundColor White }
            "Warning" { Write-Host $logEntry -ForegroundColor Yellow }
            "Error"   { Write-Host $logEntry -ForegroundColor Red }
            "Debug"   { Write-Verbose $logEntry }
        }
        
        ##### Ensure log directory exists
        $logDir = Split-Path -Path $LogFilePath -Parent
        if (-not (Test-Path -Path $logDir)) {
            New-Item -Path $logDir -ItemType Directory -Force | Out-Null
        }
        
        ##### Append to log file
        Add-Content -Path $LogFilePath -Value $logEntry -Encoding UTF8
    }
    catch {
        Write-Error "Failed to write to log: $_"
    }
}

function Get-SafePath {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$BasePath,
        
        [Parameter(Mandatory = $true)]
        [string]$ChildPath
    )
    
    try {
        return (Join-Path -Path $BasePath -ChildPath $ChildPath)
    }
    catch {
        Write-LogMessage -Message "Error creating path: $_" -Severity "Error"
        throw "Failed to create path: $_"
    }
}

function Test-CommandExists {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Command
    )
    
    try {
        if (Get-Command -Name $Command -ErrorAction SilentlyContinue) {
            return $true
        }
        return $false
    }
    catch {
        return $false
    }
}

#-----------------------------------------------------------[Main Execution]----------------------------------------------------------

##### Main script execution wrapped in try-catch block
try {
    Write-LogMessage -Message "Script started with parameters: Param1=$Param1, Param2=$Param2" -Severity "Info"
    
    ##### Create a temporary working directory using proper path handling
    $workingDir = Get-SafePath -BasePath ${env}:TEMP -ChildPath "script-workdir-$(Get-Random)"
    
    if (-not (Test-Path -Path $workingDir)) {
        New-Item -Path $workingDir -ItemType Directory -Force | Out-Null
        Write-LogMessage -Message "Created working directory: $workingDir" -Severity "Info"
    }
    
    ##### Example of platform-specific code using the platform detection
    if ($Platform.IsWindows) {
        Write-LogMessage -Message "Executing Windows-specific code" -Severity "Info"
        ##### Windows-specific code here
    }
    elseif ($Platform.IsLinux) {
        Write-LogMessage -Message "Executing Linux-specific code" -Severity "Info"
        ##### Linux-specific code here
    }
    elseif ($Platform.IsMacOS) {
        Write-LogMessage -Message "Executing macOS-specific code" -Severity "Info"
        ##### macOS-specific code here
    }
    
    ##### Example of using a version-specific feature with fallback
    if ($Platform.PSVersion.Major -ge 7) {
        ##### PowerShell 7+ specific feature
        Write-LogMessage -Message "Using PowerShell 7+ specific feature" -Severity "Info"
    }
    else {
        ##### Fallback for older versions
        Write-LogMessage -Message "Using fallback for PowerShell 5.1" -Severity "Info"
    }
    
    ##### Main script logic here
    Write-LogMessage -Message "Script execution completed successfully" -Severity "Info"
}
catch {
    Write-LogMessage -Message "Error occurred: $_" -Severity "Error"
    Write-LogMessage -Message "Error details: $($_.Exception | Format-List -Force | Out-String)" -Severity "Debug"
    
    ##### Re-throw the error if needed
    throw "Script execution failed: $_"
}
finally {
    ##### Clean up resources
    if (Test-Path -Path $workingDir) {
        Remove-Item -Path $workingDir -Recurse -Force -ErrorAction SilentlyContinue
        Write-LogMessage -Message "Cleaned up working directory" -Severity "Info"
    }
    
    Write-LogMessage -Message "Script execution ended" -Severity "Info"
} 
