# Simple helper script to prompt for commit message and run cursor-push.bat
$commitMessage = Read-Host "Enter commit message"

if ($commitMessage -ne "") {
    # Run the cursor-push.bat with the provided commit message
    & "$PSScriptRoot\cursor-push.bat" "$commitMessage"
} else {
    Write-Host "No commit message provided. Operation cancelled."
} 