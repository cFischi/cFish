# PowerShell wrapper for resource dashboard
#Requires -Version 7.0
#Requires -Modules @{ ModuleName='PSResourceGet'; ModuleVersion='0.0.1' }
#Requires -Modules @{ ModuleName='Microsoft.PowerShell.ConsoleGuiTools'; ModuleVersion='0.0.1' }

$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'

function Test-ModuleAvailability {
    param(
        [string[]]$ModuleNames
    )
    
    foreach ($module in $ModuleNames) {
        if (-not (Get-Module -ListAvailable -Name $module)) {
            Write-Warning "Module $module not found. Attempting installation..."
            try {
                Install-Module -Name $module -Force -AllowClobber -Scope CurrentUser
                Import-Module $module -Force
            } catch {
                Write-Error "Failed to install module $module. Error: $_"
                return $false
            }
        }
    }
    return $true
}

function Start-ResourceDashboard {
    $requiredModules = @('PSResourceGet', 'Microsoft.PowerShell.ConsoleGuiTools')
    
    if (-not (Test-ModuleAvailability -ModuleNames $requiredModules)) {
        Write-Error "Required modules not available. Dashboard cannot start."
        return
    }

    try {
        # Check Node.js installation
        $nodeVersion = node --version
        Write-Verbose "Node.js version: $nodeVersion"
    } catch {
        Write-Error "Node.js is required but not installed."
        return
    }

    # Set environment variables for better memory management
    $env:NODE_OPTIONS = "--max-old-space-size=512 --gc-interval=100"
    
    try {
        # Start the dashboard with error handling
        $dashboardScript = Join-Path $PSScriptRoot "resource-dashboard.js"
        if (Test-Path $dashboardScript) {
            node $dashboardScript
        } else {
            Write-Error "Dashboard script not found at: $dashboardScript"
        }
    } catch {
        Write-Error "Failed to start dashboard: $_"
    }
}

# Start the dashboard
Start-ResourceDashboard 