# Git Cheat Sheet for cFish.io Cross-Computer Sync

## Setup Commands (One-time setup)

```bash
# Clone the repository (first time on a new computer)
git clone https://github.com/cFischi/cFish.git

# Configure your identity (if not already done)
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

## Daily Workflow Commands

```bash
# Before starting work (get latest changes)
git pull origin development

# Check status of your changes
git status

# View changes you've made
git diff

# Stage all changes for commit
git add .

# Commit your changes
git commit -m "Brief description of your changes"

# Push changes to GitHub
git push origin development
```

## Other Useful Commands

```bash
# Switch to a different branch
git checkout branch-name

# Create and switch to a new branch
git checkout -b new-branch-name

# View commit history
git log --oneline

# Undo uncommitted changes to a file
git checkout -- filename

# Undo your last commit (keep changes)
git reset --soft HEAD~1

# Discard all local changes
git reset --hard
```

## Cross-Computer Workflow

### On Computer A:
1. `git pull origin development` (get latest)
2. Make changes
3. `git add .`
4. `git commit -m "Description"`
5. `git push origin development`

### On Computer B:
1. `git pull origin development` (get all changes from Computer A)
2. Continue working
3. Repeat the process when done

## Dealing with Conflicts

If both computers modified the same file:

```bash
# When git pull shows conflicts
1. Open the file and look for conflict markers (<<<<<<, =======, >>>>>>>)
2. Edit the file to resolve conflicts
3. git add <filename>
4. git commit -m "Resolved conflicts"
5. git push origin development
``` 