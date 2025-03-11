# WordPress Studio Guide

## Overview
WordPress Studio is a local development environment for WordPress sites with an integrated AI assistant. This document outlines its capabilities, limitations, and how it fits into our development workflow.

## Studio Assistant Capabilities

### Informative Capabilities
- **WordPress Development Guidance:**
  - Provides code examples in PHP, CSS, and JavaScript following WordPress coding standards
  - Offers best practices for security, optimization, and efficiency
  - Suggests approaches for common WordPress development tasks

- **WP-CLI Assistance:**
  - Guides on using WP-CLI commands (pre-installed in Studio)
  - Helps formulate complex WP-CLI operations

- **Troubleshooting:**
  - Helps diagnose and troubleshoot errors on local WordPress sites
  - Provides solutions and guidance for common WordPress issues

- **Documentation and Resources:**
  - Links to relevant WordPress documentation and resources
  - Offers contextual learning materials

### Utility-Based Capabilities
- **Site Management:**
  - Create, manage, and configure local WordPress sites
  - Assist with tasks like updating plugins, themes, and WordPress versions

- **WP-CLI Execution:**
  - Execute WP-CLI commands directly through the Studio interface
  - Streamlines common WordPress management tasks

- **Site Launch:**
  - Guidance on launching local sites to production
  - Support for the all-in-one-wp-migration plugin for site migration

- **Contextual Assistance:**
  - Has context about your specific site setup
  - Tailors responses based on installed themes and plugins

## Limitations
- **Code Editing:** The Assistant cannot directly edit code on sites - it can only provide code snippets and guidance
- **IDE Integration:** Studio does not currently have configured IDEs - code editing must be done outside Studio
- **Version Control:** Limited native Git integration - requires external Git workflow (our current setup)
- **Real-time Collaboration:** No built-in tools for team collaboration

## Integration with Our Workflow

### Current Development Process
1. **Development in Cursor IDE:**
   - Main code development happens in Cursor (C:\Users\Chris\cFish.io)
   - Version control via Git with feature branches
   - Code organization and editing

2. **WordPress Studio for Testing:**
   - Site hosted at C:\Users\Chris\Studio\cfishio
   - Files synchronized from Cursor repository via batch scripts
   - Testing environment for WordPress functionality
   - Platform for using WP-CLI commands

3. **File Synchronization:**
   - Use our batch files (sync-wordpress-files.bat, sync-assembler-quick.bat) to push changes from Cursor to Studio
   - Manual verification in WordPress admin after synchronization
   - No automatic synchronization from Studio back to Cursor (one-way workflow)

### Best Practices
- Use Studio primarily for WordPress-specific tasks and testing
- Maintain Cursor as the primary development environment
- Always test changes in Studio before deploying to production
- Use Studio Assistant for WordPress guidance but implement code changes in Cursor
- Leverage WP-CLI through Studio for database and content management

## Future Potential
- Exploring deeper integration between Cursor and Studio
- Potential automation of two-way synchronization
- Evaluating Studio's plugin ecosystem as it grows
- Monitoring Studio updates for improved Git integration

## References
- [WordPress Studio Official Documentation](https://wordpress.org/studio/)
- [WP-CLI Documentation](https://wp-cli.org/)
- Internal docs: [sync-wordpress-files.bat](sync-wordpress-files.bat), [sync-assembler-quick.bat](sync-assembler-quick.bat) 