<#
.SYNOPSIS
    Platform detection module for cross-platform PowerShell scripts.

.DESCRIPTION
    This module provides reliable platform detection functions that work across
    Windows PowerShell 5.1 and PowerShell Core 7+ on Windows, Linux, and macOS.
    It includes functions for detecting the operating system, PowerShell edition,
    and environment variables.

.NOTES
    File Name      : PlatformDetection.psm1
    Author         : tY FischEYe
    Prerequisite   : PowerShell 5.1 or later
    Created        : 2025-03-13
    Version        : 1.0
    Cross-Platform : Yes (Windows PowerShell 5.1+, PowerShell Core 7+ on Windows/Linux/macOS)
#>

#Requires -Version 5.1

# Set strict mode to catch common scripting mistakes
Set-StrictMode -Version Latest

# Set error action preference to stop on errors
$ErrorActionPreference = "Stop"

<#
.SYNOPSIS
    Gets platform information for the current PowerShell environment.

.DESCRIPTION
    Detects the current platform (Windows, Linux, macOS) and PowerShell edition 
    (Desktop or Core) using multiple fallback mechanisms to ensure reliable detection
    across different PowerShell versions.

.EXAMPLE
    $Platform = Get-PlatformInfo
    Write-Host "Running on $($Platform.PlatformName)"

.OUTPUTS
    PSCustomObject with the following properties:
    - IsCore: Boolean indicating if running on PowerShell Core
    - IsWindows: Boolean indicating if running on Windows
    - IsLinux: Boolean indicating if running on Linux
    - IsMacOS: Boolean indicating if running on macOS
    - PlatformName: String with descriptive platform name
    - PathSeparator: Character used for path separation on current platform
    - PSVersion: PowerShell version information
#>
function Get-PlatformInfo {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param()
    
    # Create a custom object to hold platform information
    $platformInfo = [PSCustomObject]@{
        IsCore            = $false
        IsWindows         = $false
        IsLinux           = $false
        IsMacOS           = $false
        PlatformName      = ""
        PathSeparator     = [IO.Path]::DirectorySeparatorChar
        PSVersion         = $PSVersionTable.PSVersion
    }

    # Check if running PowerShell Core
    if ($PSVersionTable.PSEdition -eq 'Core') {
        $platformInfo.IsCore = $true
        
        # PowerShell Core specific platform checks
        if (Test-Path variable:IsWindows) {
            if ($IsWindows) {
                $platformInfo.IsWindows = $true
                $platformInfo.PlatformName = "PowerShell Core (Windows)"
            }
        } 
        elseif (Test-Path variable:IsLinux) {
            if ($IsLinux) {
                $platformInfo.IsLinux = $true
                $platformInfo.PlatformName = "PowerShell Core (Linux)"
            }
        }
        elseif (Test-Path variable:IsMacOS) {
            if ($IsMacOS) {
                $platformInfo.IsMacOS = $true
                $platformInfo.PlatformName = "PowerShell Core (macOS)"
            }
        }
        else {
            # Fallback for PowerShell Core when automatic variables are not available
            try {
                # Try using .NET Core's RuntimeInformation
                Add-Type -TypeDefinition @"
                using System;
                using System.Runtime.InteropServices;
                public class PlatformDetection {
                    public static bool IsWindows() { return RuntimeInformation.IsOSPlatform(OSPlatform.Windows); }
                    public static bool IsLinux() { return RuntimeInformation.IsOSPlatform(OSPlatform.Linux); }
                    public static bool IsOSX() { return RuntimeInformation.IsOSPlatform(OSPlatform.OSX); }
                }
"@ -ErrorAction SilentlyContinue

                if ([PlatformDetection]::IsWindows()) {
                    $platformInfo.IsWindows = $true
                    $platformInfo.PlatformName = "PowerShell Core (Windows)"
                }
                elseif ([PlatformDetection]::IsLinux()) {
                    $platformInfo.IsLinux = $true
                    $platformInfo.PlatformName = "PowerShell Core (Linux)"
                }
                elseif ([PlatformDetection]::IsOSX()) {
                    $platformInfo.IsMacOS = $true
                    $platformInfo.PlatformName = "PowerShell Core (macOS)"
                }
            }
            catch {
                # Last resort: check platform using .NET Framework approach
                if ([System.Environment]::OSVersion.Platform -eq "Win32NT") {
                    $platformInfo.IsWindows = $true
                    $platformInfo.PlatformName = "PowerShell Core (Windows)"
                }
                elseif ([System.Environment]::OSVersion.Platform -eq "Unix") {
                    # Further distinguish between Linux and macOS
                    if (Test-Path "/System/Library/CoreServices/SystemVersion.plist") {
                        $platformInfo.IsMacOS = $true
                        $platformInfo.PlatformName = "PowerShell Core (macOS)"
                    }
                    else {
                        $platformInfo.IsLinux = $true
                        $platformInfo.PlatformName = "PowerShell Core (Linux)"
                    }
                }
                else {
                    $platformInfo.PlatformName = "PowerShell Core (Unknown)"
                }
            }
        }
    }
    else {
        # Windows PowerShell - only runs on Windows
        $platformInfo.IsWindows = $true
        $platformInfo.PlatformName = "Windows PowerShell"
    }

    return $platformInfo
}

<#
.SYNOPSIS
    Gets the proper path for temporary files.

.DESCRIPTION
    Returns the appropriate temporary directory path for the current platform.
    On Windows, this is typically %TEMP%. On Linux/macOS, this is typically /tmp.

.EXAMPLE
    $tempDir = Get-TempPath
    $tempFile = Join-Path -Path $tempDir -ChildPath "myTempFile.txt"

.OUTPUTS
    String with the temporary directory path.
#>
function Get-TempPath {
    [CmdletBinding()]
    [OutputType([string])]
    param()
    
    $platform = Get-PlatformInfo
    
    if ($platform.IsWindows) {
        return $env:TEMP
    }
    elseif ($platform.IsLinux -or $platform.IsMacOS) {
        # Check for TMPDIR environment variable first
        if ($env:TMPDIR) {
            return $env:TMPDIR
        }
        # Default to /tmp on Unix systems
        else {
            return "/tmp"
        }
    }
    else {
        # Fallback to current directory
        Write-Warning "Could not determine appropriate temp directory for platform. Using current directory."
        return (Get-Location).Path
    }
}

<#
.SYNOPSIS
    Gets the proper path for user home directory.

.DESCRIPTION
    Returns the appropriate home directory path for the current platform.
    On Windows, this is typically %USERPROFILE%. On Linux/macOS, this is typically $HOME.

.EXAMPLE
    $homeDir = Get-HomePath
    $configFile = Join-Path -Path $homeDir -ChildPath ".config/myapp/settings.json"

.OUTPUTS
    String with the home directory path.
#>
function Get-HomePath {
    [CmdletBinding()]
    [OutputType([string])]
    param()
    
    # HOME is defined on all platforms
    if ($env:HOME) {
        return $env:HOME
    }
    # USERPROFILE is Windows-specific
    elseif ($env:USERPROFILE) {
        return $env:USERPROFILE
    }
    # Fallback to current directory
    else {
        Write-Warning "Could not determine home directory. Using current directory."
        return (Get-Location).Path
    }
}

<#
.SYNOPSIS
    Creates a platform-independent path.

.DESCRIPTION
    Joins path components in a platform-independent way, ensuring proper 
    directory separators for the current platform.

.PARAMETER PathComponents
    Array of path components to join.

.EXAMPLE
    $myPath = New-PlatformPath -PathComponents "folder", "subfolder", "file.txt"

.OUTPUTS
    String with the combined path.
#>
function New-PlatformPath {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string[]]$PathComponents
    )
    
    $result = $PathComponents[0]
    
    for ($i = 1; $i -lt $PathComponents.Length; $i++) {
        $result = Join-Path -Path $result -ChildPath $PathComponents[$i]
    }
    
    return $result
}

<#
.SYNOPSIS
    Checks if running on the specified platform.

.DESCRIPTION
    Determines if the current script is running on the specified platform.

.PARAMETER Platform
    Platform to check for. Valid values are "Windows", "Linux", "macOS", or "Unix" (Linux or macOS).

.EXAMPLE
    if (Test-Platform -Platform "Windows") {
        # Run Windows-specific code
    }

.OUTPUTS
    Boolean indicating if running on the specified platform.
#>
function Test-Platform {
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateSet("Windows", "Linux", "macOS", "Unix")]
        [string]$Platform
    )
    
    $platformInfo = Get-PlatformInfo
    
    switch ($Platform) {
        "Windows" {
            return $platformInfo.IsWindows
        }
        "Linux" {
            return $platformInfo.IsLinux
        }
        "macOS" {
            return $platformInfo.IsMacOS
        }
        "Unix" {
            return ($platformInfo.IsLinux -or $platformInfo.IsMacOS)
        }
    }
}

<#
.SYNOPSIS
    Gets PowerShell version information.

.DESCRIPTION
    Returns detailed information about the current PowerShell version.

.EXAMPLE
    $versionInfo = Get-PSVersionDetail
    if ($versionInfo.Edition -eq "Core" -and $versionInfo.Major -ge 7) {
        # Use PowerShell 7+ features
    }

.OUTPUTS
    PSCustomObject with PowerShell version details.
#>
function Get-PSVersionDetail {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param()
    
    $versionInfo = [PSCustomObject]@{
        Edition     = $PSVersionTable.PSEdition
        Major       = $PSVersionTable.PSVersion.Major
        Minor       = $PSVersionTable.PSVersion.Minor
        Build       = $PSVersionTable.PSVersion.Build
        Revision    = $PSVersionTable.PSVersion.Revision
        IsPSCore    = ($PSVersionTable.PSEdition -eq "Core")
        IsPS5OrLater = ($PSVersionTable.PSVersion.Major -ge 5)
        IsPS7OrLater = ($PSVersionTable.PSEdition -eq "Core" -and $PSVersionTable.PSVersion.Major -ge 7)
        FullVersion = $PSVersionTable.PSVersion.ToString()
    }
    
    return $versionInfo
}

# Export functions
Export-ModuleMember -Function Get-PlatformInfo
Export-ModuleMember -Function Get-TempPath
Export-ModuleMember -Function Get-HomePath
Export-ModuleMember -Function New-PlatformPath
Export-ModuleMember -Function Test-Platform
Export-ModuleMember -Function Get-PSVersionDetail 