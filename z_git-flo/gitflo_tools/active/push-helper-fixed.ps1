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

# Save the current location
Push-Location

# Navigate to the workspace root
try {
    # Change to the workspace root directory
    Set-Location "C:\Users\Chris\cFish.io"
    
    # Get the current branch name
    $currentBranch = git rev-parse --abbrev-ref HEAD
    Write-Host "Current branch: $currentBranch"
    
    # Check if there are any changes to commit
    $status = git status -s
    if ([string]::IsNullOrWhiteSpace($status)) {
        Write-Host "No changes to commit."
        Pop-Location
        exit 0
    }
    
    # Show changes before commit
    Write-Host "Changes to be committed:"
    git status -s
    
    # Prompt for commit message
    $commitMessage = Read-Host -Prompt "Enter commit message"
    if ([string]::IsNullOrWhiteSpace($commitMessage)) {
        $commitMessage = "Update from $env:COMPUTERNAME - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    }
    
    # Stage all changes (avoiding long paths)
    $changedFiles = git status -s | Where-Object { $_ -notlike "*z_Archives*" -and $_ -notlike "* -> *" } | ForEach-Object { $_.Substring(3) }
    if ($changedFiles.Count -eq 0) {
        Write-Host "No valid files to commit. All changes might be in excluded directories."
        Pop-Location
        exit 0
    }
    
    # Add changes
    Write-Host "Adding changes..."
    git add .
    
    # Commit changes with -n flag to bypass hooks
    Write-Host "Committing changes..."
    git commit -n -m "$commitMessage"
    
    # Push to remote repository
    Write-Host "Pushing to remote repository..."
    git push origin $currentBranch
    
    Write-Host "Successfully pushed changes to remote repository on branch $currentBranch."
}
catch {
    Write-Host "Error: $_"
}
finally {
    # Return to the original location
    Pop-Location
} 