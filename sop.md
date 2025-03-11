# cFish.io WordPress Development Standard Operating Procedures (SOP)

This document outlines the standard procedures for common development tasks for cFish.io WordPress site.

## Table of Contents

1. [Development Environment Setup](#development-environment-setup)
2. [Feature Development Workflow](#feature-development-workflow)
3. [Content Updates](#content-updates)
4. [Theme Customization](#theme-customization)
5. [Plugin Management](#plugin-management)
6. [WordPress Core Updates](#wordpress-core-updates)
7. [Database Management](#database-management)
8. [Deployment Procedures](#deployment-procedures)
9. [WordPress Studio Usage](#wordpress-studio-usage)
10. [Troubleshooting Common Issues](#troubleshooting-common-issues)

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

### Environment Synchronization

1. **Syncing from WordPress Studio to Cursor**
   - Export database from WordPress Studio if needed
   - Copy files from `C:\Users\Chris\Studio\cfishio` to `C:\Users\Chris\cFish.io`
   - Verify file integrity

2. **Syncing from Cursor to WordPress Studio**
   - Commit and push changes to GitHub
   - Copy modified files from `C:\Users\Chris\cFish.io` to `C:\Users\Chris\Studio\cfishio`

## Feature Development Workflow

1. **Create a feature branch**
   ```
   git checkout -b feature/descriptive-name
   ```

2. **Make necessary code changes in Cursor**

3. **Commit changes incrementally**
   ```
   git add .
   git commit -m "Descriptive message about changes"
   ```

4. **Push changes to GitHub**
   ```
   git push -u origin feature/descriptive-name
   ```

5. **Test in WordPress Studio**
   - Copy changed files to WordPress Studio
   - Test functionality thoroughly

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

## Content Updates

### Blog Posts

1. **Create/edit content in WordPress Studio**
   - Use WordPress editor for content creation
   - Preview content before publishing

2. **Media Management**
   - Optimize images before upload (compression, proper dimensions)
   - Use descriptive filenames and alt text
   - Organize media library with folders if using appropriate plugin

### Page Updates

1. **Major page structure changes**
   - Create feature branch for template changes
   - Test layout changes in WordPress Studio
   - Follow standard feature workflow

2. **Minor content updates**
   - Make directly in WordPress Studio
   - Document changes in change log

## Theme Customization

1. **Theme file modifications**
   - Create feature branch with `theme/` prefix
   - Edit theme files in Cursor
   - Test in WordPress Studio
   - Follow standard feature workflow

2. **CSS Customizations**
   - Work in dedicated feature branch
   - Use browser inspector to test changes
   - Implement in appropriate stylesheet files
   - Minimize use of !important declarations

3. **JavaScript Enhancements**
   - Create separate JS files for custom functionality
   - Enqueue properly via functions.php
   - Test thoroughly for browser compatibility

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
   - All tests passing
   - Feature branch merged to main
   - Documentation updated

2. **Deployment to WordPress.com**
   - Deploy from WordPress Studio to WordPress.com
   - Follow WordPress.com specific deployment steps
   - Document deployment time and version

3. **Post-deployment verification**
   - Check critical site functionality
   - Verify visual integrity across devices
   - Confirm third-party integrations

## WordPress Studio Usage

### Overview
- WordPress Studio serves as our testing environment and WordPress management platform
- Refer to [wordpress-studio-guide.md](wordpress-studio-guide.md) for detailed capabilities and limitations

### Best Practices
1. **Using Studio Assistant**
   - Leverage Studio Assistant for WordPress-specific guidance
   - Request code examples for WordPress standards
   - Use for troubleshooting WordPress-specific issues

2. **WP-CLI Usage**
   - Access WP-CLI through WordPress Studio Terminal
   - Common useful commands:
     ```
     wp plugin list
     wp theme list
     wp core version
     wp db export backup.sql
     ```

3. **File Synchronization**
   - Always use the synchronization batch files to move code from Cursor to Studio
   - After synchronizing, verify changes in WordPress admin
   - For theme changes, check if theme needs to be activated or reactivated

4. **Testing Workflow**
   - Make code changes in Cursor
   - Sync to WordPress Studio
   - Test in WordPress Studio
   - Document results
   - Only then commit changes to Git

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