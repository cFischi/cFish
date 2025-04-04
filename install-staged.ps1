$ErrorActionPreference = 'Stop'

# Function to check system resources
function Check-SystemResources {
    try {
        $memory = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction Stop
        $freePhysicalMemory = [math]::Round($memory.FreePhysicalMemory / 1MB, 2)
        $totalVisibleMemory = [math]::Round($memory.TotalVisibleMemorySize / 1MB, 2)
        $usagePercent = [math]::Round((($totalVisibleMemory - $freePhysicalMemory) / $totalVisibleMemory) * 100, 2)

        Write-Host "Memory Usage: $usagePercent%"
        Write-Host "Free Memory: ${freePhysicalMemory}GB of ${totalVisibleMemory}GB"
        
        # More conservative memory limit
        if ($usagePercent -gt 75) {
            Write-Host "WARNING: High memory usage detected. Pausing for system recovery..."
            [System.GC]::Collect()
            Start-Sleep -Seconds 45
            return $false
        }
        return $true
    }
    catch {
        Write-Host "Error getting system resources: $_"
        Write-Host "Falling back to conservative resource check..."
        Start-Sleep -Seconds 30
        return $true
    }
}

# Function to install dependencies in stages
function Install-Dependencies {
    param (
        [string[]]$Packages,
        [switch]$Dev
    )
    
    foreach ($package in $Packages) {
        $attempts = 0
        $maxAttempts = 3
        
        while ($attempts -lt $maxAttempts) {
            try {
                if (Check-SystemResources) {
                    Write-Host "Installing $package..."
                    if ($Dev) {
                        npm install $package --save-dev --no-audit --no-fund --verbose
                    } else {
                        npm install $package --save --no-audit --no-fund --verbose
                    }
                    Write-Host "Successfully installed $package"
                    Start-Sleep -Seconds 5 # Cool down period between installations
                    break
                }
            }
            catch {
                $attempts++
                Write-Host "Failed to install $package (Attempt $attempts of $maxAttempts)"
                Write-Host "Error: $_"
                if ($attempts -eq $maxAttempts) {
                    throw "Failed to install $package after $maxAttempts attempts: $_"
                }
                Start-Sleep -Seconds 20
            }
        }
    }
}

# Set environment variables for Node.js
$env:NODE_OPTIONS="--max-old-space-size=4096"

# Clear npm cache
Write-Host "Cleaning npm cache..."
npm cache clean --force
npm cache verify

# Install packages in smaller batches
Write-Host "Installing core dependencies..."

# React core
$reactCore = @(
    "react",
    "react-dom"
)
Install-Dependencies $reactCore

# Next.js
$nextCore = @(
    "next"
)
Install-Dependencies $nextCore

# Additional core dependencies
$additionalCore = @(
    "axios",
    "d3"
)
Install-Dependencies $additionalCore

# Install dev dependencies in batches
Write-Host "Installing dev dependencies..."

# TypeScript core
$typeScriptCore = @(
    "typescript",
    "@types/react",
    "@types/node",
    "@types/d3"
)
Install-Dependencies $typeScriptCore -Dev

# ESLint and Prettier
$lintingTools = @(
    "eslint",
    "prettier",
    "@typescript-eslint/eslint-plugin",
    "@typescript-eslint/parser",
    "eslint-config-prettier",
    "eslint-plugin-react"
)
Install-Dependencies $lintingTools -Dev

# Testing tools
$testingTools = @(
    "@testing-library/react",
    "@testing-library/jest-dom",
    "jest",
    "jest-environment-jsdom",
    "ts-jest"
)
Install-Dependencies $testingTools -Dev

# Styling
$stylingTools = @(
    "sass"
)
Install-Dependencies $stylingTools -Dev

Write-Host "Installation complete!" 