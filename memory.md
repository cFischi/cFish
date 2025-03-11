# cFish.io WordPress Development Memory

## Setup Completed
- Imported WordPress site from WordPress Studio to Cursor
- Created Git repository with proper .gitignore for WordPress
- Set up development branch for active development
- Configured Windows credential helper for GitHub authentication
- Successfully pushed WordPress files to GitHub repository (development branch)

## Development Workflow
1. Always work in feature branches, never directly on `main`
2. Current workflow:
   - Develop locally in Cursor (C:\Users\Chris\cFish.io)
   - Push changes to GitHub
   - Pull changes to WordPress Studio (C:\Users\Chris\Studio\cfishio)
   - Test in WordPress Studio
   - Deploy to live site from WordPress Studio

### File Synchronization Process
- **Manual method**: Use command prompt to copy files:
  ```
  xcopy "C:\Users\Chris\cFish.io\wp-content\themes\[theme-name]" "C:\Users\Chris\Studio\cfishio\wp-content\themes\[theme-name]" /E /I /Y
  ```
- **Automated method**: Use Node.js sync script (sync-to-studio.js) within Cursor:
  ```
  node sync-to-studio.js
  ```
- Always verify changes in WordPress Studio admin panel after synchronization
- Activate themes/plugins if needed
- Test functionality thoroughly before merging feature branches

## Git Commands to Remember
- `git checkout -b feature-name` - Create and switch to a new feature branch
- `git add .` - Stage all changes
- `git commit -m "Description of changes"` - Commit staged changes
- `git push -u origin feature-name` - Push feature branch to GitHub
- `git checkout main` - Switch to main branch
- `git merge feature-name` - Merge feature branch into main (after testing)
- `git push origin main` - Push main branch to GitHub

## Important Notes
- wp-config.php and other sensitive files are excluded from version control
- Must manually synchronize between Cursor and WordPress Studio
- Always commit small, focused changes with descriptive messages

## Documentation Suite
- Created comprehensive WordPress development documentation (2023-11-15)
  - Added toolset.md - Overview of development tools and technologies
  - Added sop.md - Standard Operating Procedures for development workflow
  - Added best-practices.md - Coding standards and best practices
  - Added changelog.md - Template for tracking changes
  - Added maintenance-checklist.md - Regular maintenance tasks
  - Added backup-recovery-plan.md - Data backup and recovery procedures
  - Added glossary.md - Technical terms and definitions
- Committed documentation to development branch
- Pushed changes to GitHub repository

## Project Specifications
- Created spec.md (2023-11-15)
  - Defined essential, important, optimal, and optional features
  - Established technical requirements
  - Outlined development milestones in 5 phases
  - Defined maintenance plan and success metrics
- Ready for review and implementation planning

## Workflow Testing
- Created feature/footer-update branch (2023-11-16)
  - Implemented test change with Storefront child theme
  - Added custom footer with "Made with ❤️ by cFish.io" text
  - Styled the text to be bold and red for visibility
  - Committed changes to feature branch
  - Pushed to GitHub repository

- Created feature/assembler-footer-update branch (2023-11-16)
  - Discovered Assembler is the active theme, not Storefront
  - Created Assembler child theme
  - Implemented custom footer using WordPress block filters
  - Modified footer text to "Made with ❤️ by cFish.io" in bold red
  - Committed changes to feature branch
  - Pushed to GitHub repository
  - Next steps:
    - Pull changes to WordPress Studio
    - Activate Assembler child theme in WordPress Studio
    - Test changes locally
    - Deploy to live site if appropriate
    - Merge to development branch once verified

## Next Steps
- ✅ Complete workflow testing by activating child theme in WordPress Studio
- ✅ Establish file synchronization process between Cursor and WordPress Studio
- ✅ Create automation scripts for common development tasks
- Review documentation and spec.md for completeness
- Consider merging documentation to main branch when approved
- Create a detailed roadmap with milestones based on spec.md
- Begin implementation of core features starting with Phase 1 tasks

## Development Tools Added
- Created `sync-to-studio.js` - Node.js script to sync Assembler child theme to WordPress Studio
- Created `sync-wp-files.js` - Configurable script to sync any WordPress files (themes, plugins, content)
- Created `sync-assembler-theme.bat` - One-click batch file to sync Assembler child theme
- Created `test-node.bat` - Utility to verify Node.js installation
- Created `sync-wordpress-files.bat` - Interactive menu-driven batch file for syncing various WordPress files
- Created `sync-assembler-quick.bat` - Simplified one-click sync for Assembler child theme (no Node.js required)
- Created `.cursorrules` - Configuration file to improve terminal functionality
- Created `terminal-troubleshooting.md` - Guide for fixing terminal issues in Cursor
- Created `wordpress-studio-guide.md` - Comprehensive documentation on WordPress Studio capabilities, limitations, and workflow integration (2023-11-16)

## Environment Issues Addressed
- Identified and documented PowerShell/terminal compatibility issues in Cursor
- Created batch file workarounds for file synchronization without relying on Cursor's terminal
- Configured Cursor to use cmd.exe instead of PowerShell for better compatibility
- Documented terminal troubleshooting steps for future reference

### Cursor Terminal Issue Diagnosis (2023-11-16)
- Core terminal handling problems identified:
  - Pager Conflicts: Commands with paginated output (like `git branch`) get stuck in pager mode
  - Shell Configuration Mismatch: Despite `.cursorrules` specifying `cmd.exe`, Cursor still uses PowerShell
  - Buffer Limitations: Terminal buffer size issues cause errors like `ArgumentOutOfRangeException`
  - Interactive Command Interruption: Commands requiring user input are interrupted before completion
  - Command Piping Problems: PowerShell's handling of piped commands differs from cmd.exe

- Workaround Recommendations:
  - Run batch files directly from Windows Explorer or Command Prompt when needed
  - Use simpler, non-interactive commands within Cursor
  - Continue WordPress development workflow focusing on development tasks
  - Use batch files for file synchronization between repositories

## .cursorrules file
```
{
  "terminal": {
    "shell": "cmd.exe",
    "args": []
  },
  "editor": {
    "formatOnSave": true,
    "tabSize": 2
  }
}
```

## Workflow Strategy Update (2023-11-16)
- Evaluated WordPress Studio performance and usability after initial testing
- Identified significant limitations in WordPress Studio's functionality:
  - Performance issues (slow loading, poor responsiveness)
  - Limited editing capabilities compared to wordpress.com's backend
  - Immature interface with usability challenges
  - Inefficient workflow requiring excessive workarounds
- Decided to reposition WordPress Studio as a secondary/backup environment
- Shifted primary development workflow to wordpress.com's backend:
  - Direct editing in wordpress.com admin interfaces
  - Testing via draft/preview mode on wordpress.com
  - Using wordpress.com's mature, reliable toolset
- Discovered WordPress.com Business plan offers GitHub integration options:
  - Theme upload directly from GitHub repositories
  - Git Updater plugin for automated theme updates
  - Potential SFTP access for direct file transfers
  - More streamlined development-to-production workflow
- Updated all documentation to reflect this workflow change:
  - Revised `wordpress-studio-guide.md` to highlight limitations
  - Updated `sop.md` to focus on wordpress.com workflows
  - Created `wordpress-com-testing.md` for safe testing procedures
  - Added GitHub integration workflow documentation
- Assembler footer update feature to be tested directly on wordpress.com
- Next steps adjusted to emphasize wordpress.com-centric approach
- Maintained Studio as offline backup and for WP-CLI operations

## Documentation Updates
- Created `wordpress-com-testing.md` - Guide for safely testing changes on wordpress.com (2023-11-16)
- Updated `wordpress-studio-guide.md` - Repositioned Studio's role and documented limitations (2023-11-16)
- Revised `sop.md` - Shifted focus to wordpress.com backend workflows and GitHub integration (2023-11-16)