# Git Workflow Automation Script
# Automates git workflow processes according to established standards

# Console logging setup
function Write-Log {
    param($Message, $Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] [$Level] $Message"
}

# Git workflow functions
function Test-BranchNaming {
    param($BranchName)
    $valid_prefixes = @("feature", "bugfix", "hotfix", "release")
    $pattern = "^($($valid_prefixes -join '|'))/[a-z0-9-]+$"
    return $BranchName -match $pattern
}

function Test-CommitMessage {
    param($Message)
    $pattern = "^(feat|fix|docs|style|refactor|test|chore)(\([a-z-]+\))?: .+$"
    return $Message -match $pattern
}

function Initialize-GitHooks {
    Write-Log "Setting up git hooks..." "INFO"
    
    # Create hooks directory if it doesn't exist
    $hooksDir = ".git/hooks"
    if (-not (Test-Path $hooksDir)) {
        New-Item -ItemType Directory -Path $hooksDir
    }
    
    # Create pre-commit hook
    $preCommitPath = ".git/hooks/pre-commit"
    @'
#!/bin/sh
# Pre-commit hook for validation

# Check branch naming
branch_name=$(git symbolic-ref --short HEAD)
if ! echo "$branch_name" | grep -E "^(feature|bugfix|hotfix|release)/[a-z0-9-]+$" > /dev/null; then
    echo "ERROR: Branch name '$branch_name' does not follow naming convention"
    exit 1
fi

# Check commit message format
commit_msg=$(cat "$1")
if ! echo "$commit_msg" | grep -E "^(feat|fix|docs|style|refactor|test|chore)(\([a-z-]+\))?: .+$" > /dev/null; then
    echo "ERROR: Commit message does not follow conventional commits format"
    exit 1
fi

# Run linting
if command -v eslint >/dev/null 2>&1; then
    eslint . || exit 1
fi

# Run tests
if command -v npm >/dev/null 2>&1; then
    npm test || exit 1
fi

exit 0
'@ | Out-File -FilePath $preCommitPath -Encoding UTF8 -NoNewline

    # Create pre-push hook
    $prePushPath = ".git/hooks/pre-push"
    @'
#!/bin/sh
# Pre-push hook for validation

# Run full test suite
if command -v npm >/dev/null 2>&1; then
    npm run test:full || exit 1
fi

# Check code coverage
if command -v npm >/dev/null 2>&1; then
    npm run test:coverage || exit 1
fi

exit 0
'@ | Out-File -FilePath $prePushPath -Encoding UTF8 -NoNewline

    # Make hooks executable
    if ($IsLinux -or $IsMacOS) {
        chmod +x .git/hooks/pre-commit
        chmod +x .git/hooks/pre-push
    }

    Write-Log "Git hooks setup complete" "SUCCESS"
}

function Initialize-GitConfig {
    Write-Log "Configuring git settings..." "INFO"
    
    # Create config directory if it doesn't exist
    $configDir = ".git"
    if (-not (Test-Path $configDir)) {
        git init
    }
    
    # Set commit template
    $templatePath = ".git/commit-template"
    @'
# <type>(<scope>): <subject>
# |<----  Using a Maximum Of 50 Characters  ---->|

# Explain why this change is being made
# |<----   Try To Limit Each Line to a Maximum Of 72 Characters   ---->|

# Provide links or keys to any relevant tickets, articles or other resources
# Example: Resolves: #123
# See: #456, #789

# --- COMMIT END ---
# Type can be 
#    feat     (new feature)
#    fix      (bug fix)
#    docs     (changes to documentation)
#    style    (formatting, missing semi colons, etc; no code change)
#    refactor (refactoring production code)
#    test     (adding or refactoring tests; no production code change)
#    chore    (updating grunt tasks etc; no production code change)
# --------------------
# Remember to
#   - Capitalize the subject line
#   - Use the imperative mood in the subject line
#   - Do not end the subject line with a period
#   - Separate subject from body with a blank line
#   - Use the body to explain what and why vs. how
#   - Can use multiple lines with "-" for bullet points in body
# --------------------
'@ | Out-File -FilePath $templatePath -Encoding UTF8 -NoNewline

    # Configure git
    git config --local commit.template $templatePath
    git config --local core.autocrlf true
    git config --local pull.rebase true
    git config --local push.default current

    Write-Log "Git configuration complete" "SUCCESS"
}

function Initialize-GitAliases {
    Write-Log "Setting up git aliases..." "INFO"
    
    # Workflow aliases
    git config --local alias.st "status -sb"
    git config --local alias.co "checkout"
    git config --local alias.cob "checkout -b"
    git config --local alias.cm "commit -m"
    git config --local alias.amend "commit --amend --no-edit"
    git config --local alias.unstage "reset HEAD --"
    git config --local alias.undo "reset --soft HEAD~1"
    git config --local alias.last "log -1 HEAD"
    git config --local alias.graph "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
    
    Write-Log "Git aliases setup complete" "SUCCESS"
}

# Main execution
Write-Log "Starting git workflow automation setup" "INFO"

try {
    # Create logs directory if it doesn't exist
    if (-not (Test-Path ".cursor/logs")) {
        New-Item -ItemType Directory -Path ".cursor/logs"
    }

    # Setup components
    Initialize-GitHooks
    Initialize-GitConfig
    Initialize-GitAliases

    # Verify setup
    $hooks_exist = (Test-Path ".git/hooks/pre-commit") -and (Test-Path ".git/hooks/pre-push")
    $config_exists = Test-Path ".git/commit-template"
    
    if ($hooks_exist -and $config_exists) {
        Write-Log "Git workflow automation setup complete" "SUCCESS"
    } else {
        throw "Setup verification failed"
    }

    # Export setup results
    $results = @{
        "timestamp" = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        "hooks_installed" = $hooks_exist
        "config_setup" = $config_exists
        "aliases_configured" = $true
    }

    $results | ConvertTo-Json -Depth 10 | Out-File ".cursor/logs/git-workflow-setup.json"
    Write-Log "Setup results exported to .cursor/logs/git-workflow-setup.json" "INFO"

} catch {
    Write-Log "Error during setup: $_" "ERROR"
    exit 1
} 