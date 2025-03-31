# tYDiSync~ WordPress Plugin

## Overview

The tYDiSync~ WordPress Plugin integrates WordPress with tYDiSync~ synchronization functionality, allowing content from JSON sources to be seamlessly displayed and managed within WordPress sites. The plugin works consistently across Windows and Linux hosting environments.

## Features

- WordPress admin interface for tYDiSync~ configuration
- Shortcodes for displaying JSON-sourced content
- Content mapping between JSON sources and WordPress
- Direct integration with tYDiSync~ core functionality
- Cross-platform compatibility (Windows and Linux)

## Architecture

The plugin uses a modular architecture:

1. **Admin Interface**: PHP-based admin pages within WordPress
2. **Core Logic**: PHP classes implementing plugin functionality
3. **Integration Layer**: Cross-platform PowerShell interaction components
4. **Data Layer**: WordPress database with custom tables for synchronization metadata

## Development Timeline

| Phase | Dates | Deliverables |
|-------|-------|--------------|
| Design | 2025-05-02 | Architecture, database schema, UI wireframes |
| Admin Interface | 2025-05-03 | Settings page, dashboard widget, content mapping interface |
| Core Logic | 2025-05-04 | PowerShell integration, shortcode handlers, data transformation |
| Testing | 2025-05-05 | Cross-platform testing, security validation |
| Deployment | 2025-05-06 | Documentation, WordPress.org submission preparation |

## WordPress Integration

### Admin Features

- **Dashboard Widget**: Quick status overview of synchronization
- **Settings Page**: Configuration management for tYDiSync~ integration
- **Content Mapping**: Visual interface for connecting JSON sources to WordPress content
- **Manual Controls**: Trigger synchronization operations from WordPress admin

### Frontend Features

- **Shortcodes**: Display synchronized content with `[tydisync source="path/to/source.json" field="title"]`
- **Template Functions**: PHP functions for theme integration
- **Blocks**: Custom Gutenberg blocks for visual editing

## Cross-Platform Considerations

- Compatible with WordPress on Windows (IIS) and Linux (Apache/Nginx)
- Handles file path differences between platforms
- Securely executes PowerShell scripts on both platforms
- Consistent error handling and user feedback

## Requirements

- WordPress 6.0+
- PHP 7.4+
- PowerShell 7+ (for certain functionality)
- tYDiSync~ Core installed and configured

## Installation

1. Upload the `tydisync` folder to the `/wp-content/plugins/` directory
2. Activate the plugin through the 'Plugins' menu in WordPress
3. Configure the plugin settings via the 'tYDiSync~' menu
4. Create content mappings and use shortcodes to display synchronized content

## Security

- All inputs are sanitized using WordPress sanitization functions
- All outputs are escaped with appropriate escaping functions
- Nonces are used for all form submissions
- Capability checks ensure only authorized users can access functionality
- PowerShell execution is secured with appropriate permissions

_Updated 03-13-2025 | AI: Cursor (Claude 3.7 Sonnet)_ 