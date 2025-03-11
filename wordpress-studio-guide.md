# WordPress Studio Guide

## Overview
WordPress Studio is a local development environment for WordPress sites with an integrated AI assistant. As a relatively new tool (released approximately 2022), it has certain limitations that impact our workflow. This document outlines its capabilities, limitations, and its revised role in our development process.

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

## Limitations and Challenges

### Major Limitations
- **Code Editing:** The Assistant cannot directly edit code on sites - it can only provide code snippets and guidance
- **IDE Integration:** Studio does not currently have configured IDEs - code editing must be done outside Studio
- **Version Control:** Limited native Git integration - requires external Git workflow (our current setup)
- **Real-time Collaboration:** No built-in tools for team collaboration

### Usability Issues (Added 2023-11-16)
- **Performance Issues:** Slow loading times and poor responsiveness make development inefficient
- **Editing Experience:** Lacks robust editing capabilities compared to wordpress.com's backend
- **Interface Limitations:** UI/UX is still immature and lacks refinement
- **Stability Concerns:** Being relatively new software (about 1 year old), it has stability issues
- **Workflow Efficiency:** Creating a disjointed development experience requiring many workarounds

## Revised Role in Our Workflow

### PRIMARY WORKFLOW: WordPress.com Backend
- Main development and testing now happens directly on wordpress.com (see wordpress-com-testing.md)
- Use draft/preview mode for safe testing without publishing changes live
- Leverage wordpress.com's mature tools and interfaces

### SECONDARY ROLE: WordPress Studio
- **Limited Local Development:**
  - Used primarily for initial setup and occasional offline testing
  - Useful when internet access is limited or for major structural changes
  - For experimenting with configurations that might be risky online

- **WP-CLI Tasks:**
  - When command-line operations are needed that aren't available on wordpress.com
  - Database exports/imports and other administrative tasks

- **Emergency Backup:**
  - Maintaining a local copy as a backup/failsafe

## File Synchronization (Limited Usage)
- Use our batch files only when necessary to sync code changes to Studio
- Manual verification in WordPress admin after synchronization
- Prefer direct wordpress.com backend editing for most changes

## References
- [WordPress Studio Official Documentation](https://wordpress.org/studio/)
- [WP-CLI Documentation](https://wp-cli.org/)
- [WordPress.com Testing Guidelines](wordpress-com-testing.md)
- Internal docs: [sync-wordpress-files.bat](sync-wordpress-files.bat), [sync-assembler-quick.bat](sync-assembler-quick.bat) 