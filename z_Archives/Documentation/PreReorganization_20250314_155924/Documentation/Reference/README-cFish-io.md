# cFish.io Project

Welcome to the cFish.io project repository. This project contains both the WordPress website for cFish.io and the MD-JSON Synchronization System that powers documentation in both human-readable and AI-optimized formats.

## Project Overview

cFish.io is a comprehensive business platform integrating several key components:

1. **cFish.io (WordPress)** - Content Management and customer-facing website
2. **cFish.App (ClickUp)** - Task Management Hub for project tracking
3. **U.cFish.io (Notion)** - Knowledge Center for documentation and SOPs
4. **cFish.Vip (Vendasta)** - Client Solutions platform

This repository contains the WordPress component along with the specialized MD-JSON Synchronization System that ensures content is available in both Markdown and JSON formats for optimal human and AI consumption.

## Project Structure

The project follows UcF's organizational principles with the following structure:

```
cFish.io/
├── sync-system/           # MD-JSON Synchronization System
│   ├── core/              # Core implementation files
│   ├── agents/            # Agent-based architecture components
│   ├── utils/             # Utility functions and helpers
│   └── tests/             # Test files and test data
│
├── web/                   # WordPress Website
│   ├── wp-content/        # WordPress content files
│   └── shortlinks/        # Shortlink system for u.cfish.io
│
├── docs/                  # Documentation organized by UcF structure
│   ├── u1-overheads/      # Business administration
│   ├── u4-production/     # Production documentation
│   ├── u5-data-management/# Data & system documentation
│   ├── u6-social/         # Communication documentation
│   └── u7-specialized/    # Specialized operations docs
│
├── tools/                 # Development tools
└── scripts/               # Automation scripts
```

## MD-JSON Synchronization System

The MD-JSON Sync System provides bidirectional synchronization between Markdown documents and their corresponding JSON representations. This allows content to be edited in either format while maintaining consistency.

Key features:
- Bidirectional synchronization
- Agent-based architecture
- Memory optimization for large files
- Automatic error recovery
- Comprehensive backup system
- User interface with real-time status updates

## WordPress Site

The WordPress site serves as the main content management system and public-facing website for cFish.io. It's configured according to WordPress best practices and developed following UcF coding standards.

## Getting Started

### Prerequisites

- Node.js 14+ (for MD-JSON Sync System)
- WordPress development environment (for website development)

### Installation

1. Clone this repository
   ```
   git clone https://github.com/cfish-io/cfish-io.git
   cd cfish-io
   ```

2. Install dependencies
   ```
   npm install
   ```

3. Start the sync system
   ```
   npm run start
   ```

### Running WordPress Locally

1. Configure your local WordPress environment to use the `web` directory
2. Import the database (contact administrator for access)
3. Configure wp-config.php (not included in repo for security)

## Development Workflow

1. **Development Environment**:
   - Develop locally in Cursor IDE
   - Use the MD-JSON sync system for documentation

2. **WordPress Studio**:
   - Local WordPress Studio installation handles site management
   - Used for pushing changes to the live site

3. **GitHub Repository**:
   - All changes are tracked here
   - Main branch contains production-ready code
   - Development done in feature branches

4. **Deployment**:
   - Develop locally in Cursor
   - Push changes to WordPress Studio
   - Update live site through WordPress.com

## Documentation

Comprehensive documentation is available in both Markdown and JSON formats:

- **MD-JSON Sync System**: See `docs/u5-data-management/`
- **WordPress Development**: See `docs/u4-production/`
- **Business Overview**: See `docs/u1-overheads/`

## License

- WordPress components: GPL v2 or later
- MD-JSON Sync System: MIT License

## Contact

For more information, visit [cFish.io](https://cfish.io) or contact tY FischEYe through the website.

---

_Updated 03-14-2025 | AI: Cursor (Claude 3.7 Sonnet)_ 