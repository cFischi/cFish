# PowerShell Module Installation Script
# Optimized for low-memory environments

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue" # Speeds up web requests

# Required modules with specific versions
$requiredModules = @(
    @{
        Name = "ProcessTree"
        Version = "1.0.0"
        Source = "PSGallery"
    },
    @{
        Name = "ResourceMetrics"
        Version = "1.0.0"
        Source = "PSGallery"
    },
    @{
        Name = "ProcessAlerts"
        Version = "1.0.0"
        Source = "PSGallery"
    }
)

function Test-ModuleInstalled {
    param (
        [string]$Name,
        [string]$Version
    )
    
    $module = Get-Module -ListAvailable -Name $Name | Where-Object { $_.Version -eq $Version }
    return $null -ne $module
}

function Install-RequiredModule {
    param (
        [string]$Name,
        [string]$Version,
        [string]$Source
    )
    
    try {
        Write-Host "Installing $Name version $Version..."
        
        # Remove existing module if present
        if (Get-Module -Name $Name) {
            Remove-Module -Name $Name -Force
        }
        
        # Install module with specific version
        Install-Module -Name $Name -RequiredVersion $Version -Force -AllowClobber -Source $Source
        
        Write-Host "Successfully installed $Name version $Version" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "Failed to install $Name version $Version. Error: $_" -ForegroundColor Red
        return $false
    }
}

# Main installation process
Write-Host "Starting PowerShell module installation..." -ForegroundColor Cyan

# Verify PSGallery is trusted
if ((Get-PSRepository -Name "PSGallery").InstallationPolicy -ne "Trusted") {
    Write-Host "Setting PSGallery as trusted source..."
    Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
}

$failedInstalls = @()

foreach ($module in $requiredModules) {
    if (-not (Test-ModuleInstalled -Name $module.Name -Version $module.Version)) {
        if (-not (Install-RequiredModule -Name $module.Name -Version $module.Version -Source $module.Source)) {
            $failedInstalls += $module.Name
        }
        
        # Clear memory after each installation
        [System.GC]::Collect()
        Start-Sleep -Seconds 2
    }
    else {
        Write-Host "$($module.Name) version $($module.Version) is already installed" -ForegroundColor Green
    }
}

# Report results
if ($failedInstalls.Count -gt 0) {
    Write-Host "`nFailed to install the following modules:" -ForegroundColor Red
    $failedInstalls | ForEach-Object { Write-Host "- $_" -ForegroundColor Red }
    exit 1
}
else {
    Write-Host "`nAll required PowerShell modules have been installed successfully!" -ForegroundColor Green
    exit 0
} 