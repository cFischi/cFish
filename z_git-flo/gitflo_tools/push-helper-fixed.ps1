# Script for pushing changes to GitHub
# Updated to be location-aware and work regardless of where it's called from

param(
    [switch]$TestMode
)

# Determine the script's directory even if called from elsewhere
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$originalDir = Get-Location
$workspaceRoot = Resolve-Path "$scriptDir\..\.."

# Switch to workspace root
Push-Location $workspaceRoot

try {
    Write-Host "`n======================================================"
    Write-Host "                CURSOR PUSH OPERATION"
    Write-Host "            Working Directory: [$workspaceRoot]"
    if ($TestMode) {
        Write-Host "                  [TEST MODE]"
    }
    Write-Host "======================================================`n"

    if ($TestMode) {
        Write-Host "Test mode activated. No Git operations will be performed.`n" -ForegroundColor Yellow
        Write-Host "Script location: $scriptDir"
        Write-Host "Workspace root: $workspaceRoot"
        Write-Host "Original directory: $originalDir"
        Write-Host "Test successful!" -ForegroundColor Green
        return
    }

    # Check if git is available
    try {
        $gitVersion = git --version
        Write-Host "Git version: $gitVersion`n"
    }
    catch {
        Write-Host "Error: Git is not available. Please install Git and try again." -ForegroundColor Red
        exit 1
    }

    # Check current branch
    $currentBranch = git rev-parse --abbrev-ref HEAD
    Write-Host "Current branch: $currentBranch`n"

    # Check if there are any changes to commit
    $status = git status --porcelain
    if (-not $status) {
        Write-Host "No changes detected. Nothing to commit.`n" -ForegroundColor Yellow
        exit 0
    }

    # Show changes
    Write-Host "Changes to be committed:`n"
    git status

    # Prompt for commit message
    $commitMessage = Read-Host "`nEnter commit message"

    if ([string]::IsNullOrWhiteSpace($commitMessage)) {
        $commitMessage = "Update from $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
        Write-Host "Using default commit message: $commitMessage`n"
    }

    # Add all changes using git add -A instead of individual files
    # This handles renames and moves properly
    Write-Host "Adding all changes to commit...`n"
    git add -A

    # Commit with -n flag to bypass pre-commit hooks
    Write-Host "Committing with message: $commitMessage`n"
    $commitResult = git commit -n -m "$commitMessage"
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error during commit. Exit code: $LASTEXITCODE" -ForegroundColor Red
        exit $LASTEXITCODE
    }
    
    Write-Host "Pushing to GitHub...`n"
    $pushResult = git push origin $currentBranch
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error during push. Exit code: $LASTEXITCODE" -ForegroundColor Red
        exit $LASTEXITCODE
    }

    Write-Host "`n======================================================"
    Write-Host "Success! Changes pushed to GitHub."
    Write-Host "======================================================`n"

    Write-Host "Remember to run 'cursor-pull.bat' on your other computer."
}
catch {
    Write-Host "An error occurred: $_" -ForegroundColor Red
    exit 1
}
finally {
    # Return to original directory
    Pop-Location
    Write-Host "`n[Script executed via Ctrl+Alt+K shortcut]"
} 