# cFish
cFish.io

## Known Git Push Issue

When pushing commits to the repository, you may encounter the following error:

```
npm error Missing script: "test:full"
npm error
npm error To see a list of scripts, run:
npm error   npm run
error: failed to push some refs to 'https://github.com/cFischi/cFish.git'
```

### Issue Details

- The pre-push hook is attempting to run a `test:full` script that doesn't exist in package.json
- Even when the terminal reports "Successfully pushed changes to remote repository," the push may have failed
- GitHub repository may not show your latest commits despite the success message

### Temporary Solutions

1. **Push with `--no-verify` flag to bypass hooks:**
   ```
   git push origin your-branch-name --no-verify
   ```

2. **Add the missing script to package.json:**
   ```json
   "scripts": {
     "test:full": "echo 'No tests configured' && exit 0",
     // ...other existing scripts
   }
   ```

3. **Temporarily disable Git hooks:**
   ```
   git -c core.hooksPath=/dev/null push origin your-branch-name
   ```

4. **Verify successful push:**
   ```
   git status
   ```
   Should not show "Your branch is ahead of 'origin/branch-name'" if push was successful.

### Branch Naming Conventions

If you receive a "Branch name does not follow naming convention" error:
- Ensure branch names follow the established pattern
- Common prefixes: feature/, fix/, docs/, refactor/, etc.

This issue will be fixed on the development computer. In the meantime, use one of the above workarounds when pushing changes.

## Keyboard Shortcut Issues (Ctrl+Alt+K/L)

The git-flo system implements keyboard shortcuts for Git operations:

- **Ctrl+Alt+K**: Commit and push changes
- **Ctrl+Alt+L**: Pull changes from remote

### Current Keyboard Shortcut Problems

1. **Missing Commit Stage**: The shortcuts are not properly staging modified files before commit
   - Changes to files are being detected but not included in the commit
   - Modified files remain in "Changes not staged for commit" status

2. **Incomplete Error Handling**: The keyboard shortcuts do not properly report or handle errors
   - The error for missing "test:full" script is not being properly caught
   - Success messages appear even when the actual operation fails

3. **Workflow Breakage**: The intended seamless workflow is interrupted
   - Files require manual staging with `git add <file>` before using shortcuts
   - Push operations require manual intervention with `--no-verify` flag

4. **Missing VS Code Integration**: Keyboard bindings are not properly configured in VS Code
   - Check `.vscode/keybindings.json` for correct shortcut mappings
   - Verify terminal integration scripts are correctly linked

### Shortcut Implementation Path

The keyboard shortcuts depend on several components:
- VS Code keybindings in `.vscode/keybindings.json`
- PowerShell scripts in `z_git-flo/gitflo_tools/`
- Git hook scripts in `.git/hooks/`

All three components need to be properly configured for the shortcuts to work as intended.

### Temporary Workflow

Until the keyboard shortcuts are fixed:

1. Stage changes manually:
   ```
   git add .
   ```

2. Commit changes:
   ```
   git commit -m "Your commit message"
   ```

3. Push with --no-verify flag:
   ```
   git push origin your-branch-name --no-verify
   ```

This issue will be fixed on the development computer along with the test:full script issue.
