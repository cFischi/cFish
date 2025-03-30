# WordPress Setup Guide

## Overview
This guide provides comprehensive instructions for setting up and configuring the WordPress environment for cFish.io. It follows the UcF standards for WordPress development and ensures proper integration with the Digital Organization System.

## Environment Requirements

| Component | Requirement | Notes |
|-----------|-------------|-------|
| PHP | 7.4+ | 8.0+ recommended for optimal performance |
| MySQL/MariaDB | 5.7+/10.3+ | Configured with UTF-8 character set |
| Web Server | Apache 2.4+ or Nginx 1.18+ | With mod_rewrite for Apache |
| WordPress | 6.0+ | Latest stable version recommended |
| Memory Limit | 256MB+ | 512MB recommended for development |
| SSL | Required | Production environments must use HTTPS |

## Installation Steps

### 1. Directory Structure Preparation
Ensure the WordPress installation follows the UcF directory structure:

```
U4-Production/
├── WordPress/             # Core WordPress files
├── Documentation/         # WordPress-specific documentation
│   └── WordPress/         # Setup guides, standards, etc.
├── Themes/                # Custom and modified themes
├── Plugins/               # Custom and modified plugins
└── Backup/                # WordPress-specific backups
```

### 2. WordPress Core Installation

1. **Download WordPress:**
   ```bash
   cd U4-Production/WordPress
   wget https://wordpress.org/latest.zip
   unzip latest.zip
   mv wordpress/* .
   rmdir wordpress
   rm latest.zip
   ```

2. **Create Configuration File:**
   ```bash
   cp wp-config-sample.php wp-config.php
   ```

3. **Configure Database Settings:**
   Edit wp-config.php and update the following:
   ```php
   define('DB_NAME', 'cfish_wordpress');
   define('DB_USER', 'cfish_wp_user');
   define('DB_PASSWORD', 'your_secure_password');
   define('DB_HOST', 'localhost');
   define('DB_CHARSET', 'utf8mb4');
   define('DB_COLLATE', '');
   ```

4. **Generate and Add Authentication Keys:**
   Visit https://api.wordpress.org/secret-key/1.1/salt/ and replace the authentication keys in wp-config.php.

5. **Configure Additional Settings:**
   ```php
   define('WP_DEBUG', false);
   define('WP_AUTO_UPDATE_CORE', 'minor');
   define('DISALLOW_FILE_EDIT', true);
   define('WP_MEMORY_LIMIT', '256M');
   ```

### 3. Database Setup

1. **Create Database:**
   ```sql
   CREATE DATABASE cfish_wordpress CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
   CREATE USER 'cfish_wp_user'@'localhost' IDENTIFIED BY 'your_secure_password';
   GRANT ALL PRIVILEGES ON cfish_wordpress.* TO 'cfish_wp_user'@'localhost';
   FLUSH PRIVILEGES;
   ```

2. **Complete Installation:**
   Navigate to your site URL and follow the WordPress installation wizard:
   - Site Title: cFish.io
   - Username: admin (will be changed later)
   - Password: Use a strong, unique password
   - Email: admin@cfish.io

### 4. Security Measures

1. **Update Default Admin Account:**
   - Create a new administrator account with a non-default username
   - Log in with the new account
   - Delete the default admin account

2. **Install Security Plugins:**
   - Wordfence Security
   - Sucuri Security
   - WP Limit Login Attempts

3. **Configure Security Settings:**
   - Limit login attempts
   - Enable two-factor authentication
   - Configure firewall settings
   - Set up regular malware scanning

### 5. UcF WordPress Configuration

1. **Theme Setup:**
   - Install and activate the cFish.io theme
   - Configure theme options according to brand guidelines
   - Verify responsive design on multiple devices

2. **Plugin Installation:**
   Required plugins for cFish.io:
   - Advanced Custom Fields Pro
   - WooCommerce
   - Yoast SEO
   - WP Rocket
   - Gravity Forms
   - Custom Post Type UI

3. **Content Structure:**
   - Set up custom post types for cFish.io content
   - Configure taxonomies for proper content organization
   - Create initial page structure according to site map

### 6. Integration with Digital Organization System

1. **File Organization:**
   - Ensure all WordPress customizations follow UcF file naming conventions
   - Store custom theme files in U4-Production/Themes/
   - Store custom plugin files in U4-Production/Plugins/

2. **Documentation:**
   - Document all custom features in U4-Production/Documentation/WordPress/
   - Create technical documentation for developers
   - Create user guides for content managers

3. **Backup Configuration:**
   - Set up automated daily backups to U4-Production/Backup/
   - Configure backup rotation (7 daily, 4 weekly, 12 monthly)
   - Test backup restoration process

### 7. Performance Optimization

1. **Caching Setup:**
   - Configure page caching
   - Set up browser caching with proper headers
   - Enable GZIP compression
   - Optimize database with scheduled cleanup

2. **Asset Optimization:**
   - Minify CSS and JavaScript files
   - Configure image optimization
   - Implement lazy loading for images
   - Set up CDN if applicable

3. **Database Optimization:**
   - Schedule regular database optimization
   - Configure transient cleanup
   - Set up post revision limits

## Maintenance Procedures

### Regular Updates

| Component | Frequency | Process |
|-----------|-----------|---------|
| WordPress Core | Monthly | Test in staging, then update production |
| Plugins | Bi-weekly | Test in staging, then update production |
| Themes | Monthly | Test in staging, then update production |
| PHP | Quarterly | Test compatibility in staging before updating |
| Database | Weekly | Backup, optimize, verify integrity |

### Backup Verification

1. **Weekly Backup Check:**
   - Verify backup files exist and are not corrupted
   - Check backup size for unexpected changes
   - Validate database backup can be restored in test environment

2. **Monthly Restore Test:**
   - Perform full site restore in staging environment
   - Verify all content and functionality is preserved
   - Document restore process and timing for disaster recovery planning

## Troubleshooting

### Common Issues

1. **White Screen of Death:**
   - Check PHP error logs
   - Increase memory limit if needed
   - Disable plugins one by one to identify conflicts

2. **Database Connection Errors:**
   - Verify database credentials in wp-config.php
   - Check database server is running
   - Confirm database user has proper permissions

3. **Broken Themes/Plugins:**
   - Access site via FTP and rename offending theme/plugin folder
   - Restore from backup if necessary
   - Update theme/plugin from trusted source

### Support Resources

1. **Internal Documentation:**
   - U4-Production/Documentation/WordPress/ucf-u4.2-wp-troubleshooting-guide-20250315.md
   - U4-Production/Documentation/WordPress/ucf-u4.2-wp-error-codes-20250315.md

2. **External Resources:**
   - [WordPress Codex](https://codex.wordpress.org/)
   - [WordPress Support Forums](https://wordpress.org/support/forums/)
   - [WordPress Developer Resources](https://developer.wordpress.org/)

## Best Practices

1. **Development Workflow:**
   - Use development -> staging -> production workflow
   - Maintain version control for all custom code
   - Document all customizations and configurations

2. **Security Best Practices:**
   - Keep all software updated
   - Use strong, unique passwords
   - Implement role-based access control
   - Regular security audits and penetration testing

3. **Performance Optimization:**
   - Regular performance testing and benchmarking
   - Optimize images before uploading
   - Minimize plugin use to only essential functionality
   - Regular database maintenance

## Conclusion
Following this guide will ensure a secure, optimized WordPress installation that integrates properly with the cFish.io Digital Organization System. For questions or assistance, refer to the additional documentation in U4-Production/Documentation/WordPress/ or contact the WordPress administrator.

_Updated 03-15-2025 | AI: Cursor (Claude 3.7 Sonnet)_ 