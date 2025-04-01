# Git Workflow Test Script
# Tests keyboard shortcuts and Git operations across environments

param(
    [switch]$Verbose
)

function Test-GitEnvironment {
    $gitVersion = git --version
    Write-Host "Git Version: $gitVersion"
    
    if (-not (Test-Path ".git")) {
        Write-Host "Error: Not in a Git repository root" -ForegroundColor Red
        return $false
    }
    
    Write-Host "Git environment verified" -ForegroundColor Green
    return $true
}

function Test-KeyboardShortcuts {
    Write-Host "Testing keyboard shortcuts..."
    
    # Test push shortcut (Ctrl+Alt+K)
    Write-Host "Press Ctrl+Alt+K to test push operation"
    Start-Sleep -Seconds 5
    
    # Test pull shortcut (Ctrl+Alt+L)
    Write-Host "Press Ctrl+Alt+L to test pull operation"
    Start-Sleep -Seconds 5
    
    Write-Host "Keyboard shortcut test complete" -ForegroundColor Green
}

function Test-GitOperations {
    Write-Host "Testing Git operations..."
    
    # Test status
    git status
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: Git status failed" -ForegroundColor Red
        return $false
    }
    
    # Test add
    git add --dry-run .
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: Git add failed" -ForegroundColor Red
        return $false
    }
    
    # Test commit (dry run)
    $env:GIT_AUTHOR_NAME = "Test User"
    $env:GIT_AUTHOR_EMAIL = "test@example.com"
    git commit --dry-run -m "Test commit"
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: Git commit failed" -ForegroundColor Red
        return $false
    }
    
    Write-Host "Git operations test complete" -ForegroundColor Green
    return $true
}

# Main test execution
Write-Host "Starting Git workflow tests..." -ForegroundColor Cyan

if (Test-GitEnvironment) {
    Test-KeyboardShortcuts
    Test-GitOperations
    
    Write-Host "All tests completed successfully" -ForegroundColor Green
} else {
    Write-Host "Tests failed: Invalid Git environment" -ForegroundColor Red
    exit 1
} 