# Improved helper script to prompt for commit message and run git commands directly
# This version handles long filenames by avoiding global git add .

# First, check if there are any changes to commit
$hasChanges = git status --porcelain
if (-not $hasChanges) {
    Write-Host "No changes detected. Nothing to commit."
    Write-Host "If you've just made changes, make sure they're saved."
    exit
}

$commitMessage = Read-Host "Enter commit message"

if ($commitMessage -eq "") {
    Write-Host "No commit message provided. Operation cancelled."
    exit
}

# Get current branch
$branch = git rev-parse --abbrev-ref HEAD
Write-Host "Current branch: $branch"

# Show status
git status

Write-Host "Using commit message: ""$commitMessage"""

# Skip problematic directories with long filenames
Write-Host "Adding changes selectively (avoiding z_Archives directories with long paths)..."

# Get a list of modified files
$changedFiles = git status --porcelain | Where-Object { $_ -notmatch "z_Archives/" } | ForEach-Object { $_.Substring(3) }

# Check if there are any files to add after filtering
if ($changedFiles.Count -eq 0) {
    Write-Host "No valid files to commit. All changes might be in excluded directories."
    Write-Host "Nothing to push. Operation cancelled."
    exit
}

# Add each file individually, skipping long paths
foreach ($file in $changedFiles) {
    if (Test-Path $file) {
        git add "$file"
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Warning: Could not add file: $file (skipping)"
        }
    }
}

# Commit the changes
Write-Host "Committing changes with message: ""$commitMessage"""
git commit -n -m "$commitMessage"
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error committing changes. Please check the error message above."
    exit
}

# Push to GitHub
Write-Host "Pushing to GitHub..."
git push origin $branch
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error pushing to GitHub. Check your internet connection and GitHub access."
    exit
}

Write-Host "Success! Changes pushed to GitHub."
Write-Host "Remember to run 'cursor-pull.bat' on your other computer."
Write-Host ""
Write-Host "[Script executed via Ctrl+Alt+K shortcut]" 