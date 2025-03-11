# cFish.io WordPress Development Standard Operating Procedures (SOP)

This document outlines the standard procedures for common development tasks for cFish.io WordPress site.

## Table of Contents

1. [Development Environment Setup](#development-environment-setup)
2. [Feature Development Workflow](#feature-development-workflow)
3. [WordPress.com Admin Workflow](#wordpresscom-admin-workflow)
4. [GitHub-WordPress.com Integration](#github-wordpresscom-integration)
5. [Content Updates](#content-updates)
6. [Theme Customization](#theme-customization)
7. [Plugin Management](#plugin-management)
8. [WordPress Core Updates](#wordpress-core-updates)
9. [Database Management](#database-management)
10. [Deployment Procedures](#deployment-procedures)
11. [WordPress Studio Usage (Limited)](#wordpress-studio-usage-limited)
12. [Troubleshooting Common Issues](#troubleshooting-common-issues)

## Development Environment Setup

### Initial Setup

1. **Clone the repository**
   ```
   git clone https://github.com/cFischi/cFish.git
   cd cFish
   ```

2. **Set up Git credentials**
   ```
   git config --global user.name "Your Name"
   git config --global user.email "your.email@example.com"
   git config --global credential.helper wincred
   ```

3. **Create local WordPress configuration**
   - Create a `wp-config.php` file (this is not in version control)
   - Configure database connection parameters
   - Set up debug mode for development

### Environment Synchronization (Modified Workflow)

1. **Primary Development: WordPress.com Backend**
   - Most development and content updates happen directly on wordpress.com
   - Use draft/preview mode for testing changes
   - Export theme modifications as needed for version control

2. **Code Version Control: Cursor & GitHub**
   - Major code changes developed in Cursor
   - Backed up and versioned in GitHub
   - Used for collaborative development and tracking changes

3. **WordPress Studio (Limited Usage)**
   - Used mainly for offline development and WP-CLI operations
   - Not a primary part of daily workflow

## Feature Development Workflow

1. **Create a feature branch**
   ```
   git checkout -b feature/descriptive-name
   ```

2. **Development Approach Options**
   
   **Option A: WordPress.com Direct (Preferred)**
   - For minor to moderate changes
   - Make changes directly in WordPress.com Customizer or editor
   - Test in draft/preview mode
   - Document changes for later backup to version control

   **Option B: Local Development & Upload**
   - For complex changes requiring offline work
   - Make code changes in Cursor
   - Commit to feature branch
   - Upload to WordPress.com for testing
   - Document results

3. **Commit changes incrementally**
   ```
   git add .
   git commit -m "Descriptive message about changes"
   ```

4. **Push changes to GitHub**
   ```
   git push -u origin feature/descriptive-name
   ```

5. **Test on WordPress.com**
   - Upload changed files to WordPress.com if needed
   - Test in draft/preview mode
   - Document test results

6. **Create Pull Request**
   - Go to GitHub repository
   - Create PR from feature branch to main
   - Document changes and testing performed

7. **Review and Merge**
   - Review code in GitHub
   - Merge to main when approved
   ```
   git checkout main
   git pull origin main
   git merge feature/descriptive-name
   git push origin main
   ```

## WordPress.com Admin Workflow

### Safe Testing on WordPress.com

1. **Using Draft Mode**
   - Create draft posts/pages for testing content changes
   - Preview drafts to see how they will appear when published
   - Only publish when fully tested

2. **Theme Customizer**
   - Use the built-in Customizer for theme modifications
   - Changes in Customizer are previewed before publishing
   - Save changes only when satisfied with results

3. **Plugin Testing**
   - Test new plugins in isolation when possible
   - Have a rollback plan before activating major plugins
   - Document plugin test results

4. **Backup Before Major Changes**
   - Create a backup point before significant changes
   - Use WordPress.com's built-in backup features or plugins
   - Know how to restore from backup if needed

## GitHub-WordPress.com Integration

WordPress.com Business plan includes an official GitHub Deployments feature that provides native integration between your GitHub repository and WordPress.com site, enabling automated or manual deployments.

### Setup and Configuration

1. **Access GitHub Deployments**
   - Go to your WordPress.com dashboard
   - Navigate to Tools → GitHub Deployments
   - Click "Connect Repository"

2. **Repository Connection**
   - Authenticate with your GitHub account when prompted
   - Choose between:
     - Connect an existing repository
     - Create a new repository from your WordPress.com site
   - Select the repository you want to connect
   - Configure initial deployment settings

3. **Deployment Configuration**
   - Set branch to deploy from (e.g., `main`, `development`, or feature branches)
   - Configure deployment triggers:
     ```
     Automatic: Deploy on every push to the selected branch
     Manual: Only deploy when manually triggered from dashboard
     ```
   - Set file paths to include/exclude (if needed)
   - Configure pre-deployment GitHub Actions workflows (optional)

### Standard GitHub-to-WordPress.com Workflow

1. **Code Development**
   - Develop in Cursor IDE as usual
   - Commit to feature branches
   - Push to GitHub

2. **Testing Approaches**
   
   **Approach A: Manual Testing (Recommended for Initial Tests)**
   - Push changes to feature branch on GitHub
   - Log into WordPress.com dashboard
   - Navigate to Tools → GitHub Deployments
   - Manually trigger deployment from feature branch
   - Test changes on live or staging site
   
   **Approach B: Automated Testing**
   - Configure automatic deployments for certain branches
   - Push to designated testing branch
   - Changes automatically deploy to WordPress.com
   - Monitor deployment status in run logs
   
   **Approach C: Staging Site Testing**
   - For Business plans with staging sites
   - Configure GitHub deployments to update staging environment
   - Test thoroughly before promoting to production

3. **Deployment to Production**
   - After successful testing, merge feature branch to main
   - If automatic deployments are enabled, changes will deploy automatically
   - If using manual deployments, trigger final deployment from dashboard
   - Verify deployment in run logs
   - Document changes in changelog

4. **Monitoring Deployments**
   - Check Tools → GitHub Deployments → Deployment Run Logs
   - Review status of all deployments
   - Troubleshoot any failed deployments
   - Document deployment history

### Maintaining Code Integrity

1. **GitHub as Source of Truth**
   - Always treat GitHub repository as the canonical source code
   - Direct edits on WordPress.com should be avoided when possible
   - If emergency changes are made directly on WordPress.com, commit those changes back to GitHub

2. **Version Control Best Practices**
   - Use semantic versioning for releases
   - Tag significant releases in GitHub
   - Maintain a detailed changelog
   - Use descriptive commit messages

3. **Backup Procedures**
   - WordPress.com handles backups of the production site
   - GitHub preserves code history and versions
   - Consider additional backup solutions for critical projects

### GitHub Actions Integration (Advanced)

1. **Pre-Deployment Processing**
   - Create GitHub Actions workflows for:
     - Code linting and validation
     - Asset compilation (Sass, JavaScript, etc.)
     - Automated testing
   - Configure these to run before deployment

2. **Notification Workflows**
   - Set up GitHub Actions to notify team of successful/failed deployments
   - Integrate with Slack, email, or other notification systems

## Content Updates

### Blog Posts

1. **Create/edit content in WordPress.com Editor**
   - Use WordPress.com block editor for content creation
   - Preview content before publishing
   - Save as draft for team review if needed

2. **Media Management**
   - Optimize images before upload (compression, proper dimensions)
   - Use descriptive filenames and alt text
   - Organize media library with folders if using appropriate plugin

### Page Updates

1. **Major page structure changes**
   - Create in draft mode first
   - Preview extensively across devices
   - Document changes in version control after publishing

2. **Minor content updates**
   - Make directly in WordPress.com editor
   - Use preview mode to verify changes
   - Document changes in change log

## Theme Customization

1. **Theme file modifications**
   - For advanced customizations, use Cursor for code development
   - Version changes in Git
   - Upload to WordPress.com for testing
   - Document implementation process

2. **CSS Customizations**
   - Preferably use WordPress.com's Additional CSS feature
   - Test changes using preview
   - For complex changes, develop in Cursor first
   - Document CSS modifications

3. **JavaScript Enhancements**
   - Create separate JS files for custom functionality
   - Test locally before uploading
   - Verify compatibility across browsers

## Plugin Management

1. **Adding new plugins**
   - Research plugin reputation, support, and compatibility
   - Install in WordPress Studio test environment first
   - Export/copy files to Cursor workspace
   - Commit with detailed description of plugin purpose

2. **Updating plugins**
   - Test updates in staging environment first
   - Document plugin version changes
   - Create separate branch for significant plugin updates

3. **Removing plugins**
   - Verify dependencies before removal
   - Clean up any orphaned data
   - Document removal reason

## WordPress Core Updates

1. **Preparation**
   - Full backup of site and database
   - Document current WordPress version

2. **Update process**
   - Perform update in WordPress Studio first
   - Test core functionality
   - Copy updated files to Cursor workspace
   - Commit with detailed update notes

3. **Post-update checks**
   - Verify all custom functionality still works
   - Check theme compatibility
   - Confirm plugin compatibility

## Database Management

1. **Local database updates**
   - Document schema changes
   - Consider migration scripts for significant changes

2. **Database synchronization**
   - Use WordPress export/import for moving content
   - Replace URLs in database when moving environments
   - Never directly edit production database

## Deployment Procedures

1. **Pre-deployment checklist**
   - Code review completed
   - All tests passing in wordpress.com preview mode
   - Feature branch merged to main
   - Documentation updated

2. **Deployment**
   - For changes developed locally: Upload to WordPress.com
   - For changes made in WordPress.com: Publish from draft/preview
   - Document deployment time and version

3. **Post-deployment verification**
   - Check critical site functionality
   - Verify visual integrity across devices
   - Confirm third-party integrations

## WordPress Studio Usage (Limited)

### Overview
- WordPress Studio serves as a **secondary environment** for special cases
- Refer to [wordpress-studio-guide.md](wordpress-studio-guide.md) for detailed capabilities and limitations
- **Not recommended for primary development** due to performance and usability issues

### When to Use Studio
1. **Offline Development Needs**
   - When internet access is limited or unreliable
   - For experimenting with high-risk changes
   - As a local backup environment

2. **WP-CLI Operations**
   - For database exports and manipulation
   - Bulk content operations not available in WordPress.com
   - Custom scripts requiring server access

3. **File Synchronization (Infrequent)**
   - Use synchronization batch files only when necessary
   - Verify changes in WordPress admin after synchronization
   - Consider this a fallback approach, not primary workflow

## Troubleshooting Common Issues

### Git Issues

1. **Authentication failures**
   - Verify GitHub credentials
   - Check Windows credential manager
   - Reset/update stored credentials if needed

2. **Merge conflicts**
   - Identify conflicting files
   - Resolve conflicts with appropriate merging strategy
   - Test thoroughly after conflict resolution

### WordPress Issues

1. **White screen of death**
   - Check PHP error logs
   - Disable plugins one by one
   - Revert to default theme temporarily

2. **Database connection errors**
   - Verify database credentials in wp-config.php
   - Check database server is running
   - Confirm database user permissions

3. **Plugin conflicts**
   - Disable all plugins then enable one by one
   - Check for JavaScript errors in browser console
   - Verify theme compatibility with plugins 