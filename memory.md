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

## Next Steps
- Review documentation for completeness
- Consider merging documentation to main branch when approved
- Begin implementation of core features based on spec.md