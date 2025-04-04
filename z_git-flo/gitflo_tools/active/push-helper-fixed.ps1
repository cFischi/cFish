# Simple but effective script for pushing changes to GitHub
# Uses --no-verify flag to bypass pre-push hooks

param(
    [switch]$TestMode
)

# Save the current location
$originalLocation = Get-Location

try {
    # Change to repository root directory
    Set-Location "C:\Users\Chris\cFish.io"
    
    # Check if there are any changes to commit
    $status = git status -s
    if ([string]::IsNullOrWhiteSpace($status)) {
        Write-Output "No changes to commit."
        return
    }
    
    # Show changes before commit
    Write-Output "Changes to be committed:"
    git status -s
    
    # If in test mode, stop here
    if ($TestMode) {
        Write-Output "Test mode: Would commit and push the changes above."
        return
    }
    
    # Prompt for commit message
    $commitMessage = Read-Host "Enter commit message (or press Enter for default)"
    if ([string]::IsNullOrWhiteSpace($commitMessage)) {
        $commitMessage = "Update from $env:COMPUTERNAME - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
        Write-Output "Using default message: $commitMessage"
    }
    
    # Stage all changes
    Write-Output "Adding changes..."
    git add .
    
    # Commit changes with -n flag to bypass hooks
    Write-Output "Committing changes..."
    git commit -n -m "$commitMessage"
    
    # Push to remote repository with --no-verify flag
    Write-Output "Pushing to remote repository..."
    git push origin $(git rev-parse --abbrev-ref HEAD) --no-verify
    
    Write-Output "Push operation completed."
}
catch {
    Write-Output "Error: $_"
    
    # Provide simple guidance based on error
    if ($_ -match "rejected") {
        Write-Output "Try pulling recent changes first with Ctrl+Alt+L"
    }
}
finally {
    # Return to the original location
    Set-Location $originalLocation
} 