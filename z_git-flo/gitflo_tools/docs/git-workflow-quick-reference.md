# Git Workflow Quick Reference

## Keyboard Shortcuts

| Shortcut    | Action                                       | Command                                                                                      |
|-------------:|----------------------------------------------|----------------------------------------------------------------------------------------------|
| Ctrl+Alt+L  | Pull changes from remote                     | `git pull`                                                                                   |
| Ctrl+Alt+K  | Stage, commit, and push changes to remote    | `git add . && git commit -n -m "Update from VS Code" && git push --no-verify`               |

## Usage Guidelines

### Pulling Changes (Ctrl+Alt+L)

1. Ensure you're in the correct repository
2. Press Ctrl+Alt+L to pull latest changes
3. Resolve any merge conflicts if prompted

### Pushing Changes (Ctrl+Alt+K)

1. Make sure your changes are ready to commit
2. Press Ctrl+Alt+K to stage, commit, and push all changes
3. The default commit message will be "Update from VS Code"
4. Note: This bypasses all Git hooks with `-n` and `--no-verify` flags

## Common Issues

### Push Rejected (Non-Fast-Forward)

If your push is rejected because the remote contains work you don't have locally:

1. Press Ctrl+Alt+L to pull changes first
2. Resolve any merge conflicts
3. Press Ctrl+Alt+K again to push your changes

### Error: "The term 'git' is not recognized..."

This indicates Git is not properly installed or not in your PATH:

1. Verify Git is installed
2. Restart VS Code or your terminal
3. If needed, add Git to your system PATH

### Custom Commit Messages

If you need a custom commit message:

1. Skip the keyboard shortcut
2. Use the terminal to run:
   ```
   git add .
   git commit -n -m "Your custom message"
   git push --no-verify
   ```

## Future Enhancements

Future versions will include:
- Branch management shortcuts
- Custom commit message input
- Status indicators
- Selective file staging

## Known Limitations

- Bypasses all Git hooks with `-n` and `--no-verify` flags
- Uses a generic commit message
- Stages all changes without selection
- No interactive conflict resolution 