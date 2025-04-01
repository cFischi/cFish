# Script for pushing changes to GitHub
# Updated to be location-aware and work regardless of where it's called from

param(
    [switch]$TestMode
)

# Determine the script's directory even if called from elsewhere
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$workspaceRoot = Resolve-Path "$scriptDir\..\.."

# Configure Git to handle line endings
git config core.autocrlf true

# Switch to workspace root and store current location
$originalLocation = Get-Location
Push-Location $workspaceRoot

try {
    # Check if we're in a Git repository
    $gitStatus = git status 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: Not in a Git repository or Git is not installed."
        exit 1
    }

    # Check for changes
    $changes = git status --porcelain
    if (-not $changes) {
        Write-Host "No changes to commit."
        exit 0
    }

    $commitMessage = Read-Host "Enter commit message"

    if ($commitMessage -ne "") {
        if ($TestMode) {
            Write-Host "Test mode: Would execute the following commands:"
            Write-Host "git add ."
            Write-Host "git commit -n -m `"$commitMessage`""
            Write-Host "git push origin HEAD"
        } else {
            Write-Host "Adding changes..."
            git add .
            if ($LASTEXITCODE -eq 0) {
                Write-Host "Committing changes with -n flag to bypass hooks..."
                git commit -n -m "$commitMessage"
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "Pushing to remote..."
                    git push origin HEAD
                    if ($LASTEXITCODE -eq 0) {
                        Write-Host "Successfully pushed changes to remote."
                    } else {
                        Write-Host "Error: Failed to push changes to remote."
                        Write-Host "Try: git pull origin HEAD --allow-unrelated-histories"
                    }
                } else {
                    Write-Host "Error: Failed to commit changes."
                }
            } else {
                Write-Host "Error: Failed to add changes."
            }
        }
    } else {
        Write-Host "No commit message provided. Operation cancelled."
    }
} catch {
    Write-Host "Error: $_"
    exit 1
} finally {
    # Always return to original directory
    Pop-Location
} 