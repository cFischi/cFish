# Git Workflow Quick Reference Guide

## Keyboard Shortcuts

| Shortcut | Action | Description |
|----------|--------|-------------|
| Ctrl+Alt+K | Push to GitHub | Commits and pushes changes to GitHub |
| Ctrl+Alt+L | Pull from GitHub | Pulls latest changes from GitHub |

## Common Usage

### Push Changes to GitHub (Ctrl+Alt+K)

1. Make your changes to files in the repository
2. Press Ctrl+Alt+K to launch the push script
3. Enter a commit message when prompted
4. Script will handle add, commit, and push operations automatically

### Pull Changes from GitHub (Ctrl+Alt+L)

1. Press Ctrl+Alt+L to launch the pull script
2. Script will automatically pull latest changes from GitHub
3. Any merge conflicts will be reported

## Troubleshooting

### Push/Pull Not Working

- Ensure VS Code has been restarted after keybinding changes
- Verify wrapper scripts exist in the root directory:
  - `push-helper.ps1` or `push-helper-fixed.ps1`
  - `cursor-pull.bat`
- Check script redirection to `z_git-flo/gitflo_tools`
- Run scripts directly from terminal to check for errors

### Common Error Messages

| Error | Solution |
|-------|----------|
| "No changes detected" | No files have been modified or all changes are in ignored directories |
| "Not a git repository" | Command being run outside of git repository; navigate to repository root |
| "Error: failed to push some refs" | Pull latest changes first with Ctrl+Alt+L, then try pushing again |
| "Merge conflict" | Resolve conflicts in the indicated files, then commit and push |

## Test Mode

You can run scripts in test mode to verify functionality without performing Git operations:

```powershell
.\push-helper.ps1 -TestMode  # Test push functionality
.\cursor-pull.bat -test      # Test pull functionality
```

## Script Locations

- Wrapper scripts: Root directory
  - `push-helper.ps1` / `push-helper-fixed.ps1`
  - `cursor-pull.bat`
- Implementation scripts: `z_git-flo/gitflo_tools` directory
  - `push-helper-fixed.ps1`
  - `cursor-pull.bat`

_Updated 06-02-2025 | AI: Cursor (Claude 3.7 Sonnet)_ 