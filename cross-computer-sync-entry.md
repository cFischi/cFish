## Cross-Computer Git Synchronization Setup (03-30-2025)
- Confirmed existing GitHub repository connection at https://github.com/cFischi/cFish.git
- Created Git cheat sheet (git-cheat-sheet.md) documenting essential commands for cross-computer synchronization
- Established workflow for maintaining synchronized codebase between desktop and MSI laptop:
  - Use `git pull origin development` before starting work on either machine
  - Commit and push changes with `git add .`, `git commit -m "message"`, and `git push origin development`
  - Use `git pull origin development` on the other machine to receive changes
- Recommended using the "development" branch as the primary synchronization branch
- Identified existing branches: development, feature/footer-update, feature/assembler-footer-update, fix/include-parent-theme
- Created documentation for handling potential merge conflicts between machines
- Confirmed successful working setup on both desktop and MSI laptop

_Updated 03-30-2025 | AI: Cursor (Claude 3.7 Sonnet)_

## Git Synchronization Challenges and Solutions (04-01-2025)
- Identified critical repository structure issues:
  - Desktop working directory: C:\Users\Chris\cFish.io (main repository with work)
  - Laptop contained separate directory: C:\Users\Chris\cFish.io\cFish (nested repository from clone)
- Discovered branch discrepancies:
  - Desktop was working on branch "fix/include-parent-theme"
  - Laptop cloned repository was on branch "Main-_-cFish"
- Encountered GitHub file size limitations (100MB max):
  - Identified problematic files exceeding size limits:
    - U4-UcWebZ/WordPress/d749a-60fps-hd-motion-background-deep-blue-portal-1.png (130.52 MB)
    - z_Archives/SystemMigrations/backup_before_organization_20250313_213527/temp/powershell7-setup/PowerShell-7.3.4-win-x64.msi (100.76 MB)
  - Updated .gitignore to exclude these files and other large media/installer file types
  - Added general patterns to ignore common large file types (*.msi, *.mp4, *.png, etc.)
- Encountered synchronization issues with a local MD-JSON sync controller
  - Controller interrupts git operations with confirmations

### Next Steps
- On Desktop:
  1. Remove any remaining large files from git tracking: `git rm --cached [path/to/large/file]`
  2. Commit remaining changes: `git commit -m "Remove large files from tracking"`
  3. Push to GitHub: `git push origin fix/include-parent-theme`
- On Laptop:
  1. Navigate to the correct directory: `cd C:\Users\Chris\cFish.io\cFish`
  2. Checkout the same branch as desktop: `git checkout fix/include-parent-theme`
  3. Pull latest changes: `git pull origin fix/include-parent-theme`
- For future synchronization:
  1. Ensure working in correct directories on both machines
  2. Use the `-n` flag with git commands to bypass pre-commit hooks if needed: `git commit -n -m "message"`
  3. Consider implementing Git LFS for large files if they need to be tracked
  4. Be mindful of the MD-JSON sync controller interruptions during git operations

_Updated 04-01-2025 | AI: Cursor (Claude 3.7 Sonnet)_ 