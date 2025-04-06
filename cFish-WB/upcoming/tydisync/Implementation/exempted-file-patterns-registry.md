# cFish.io Exempted File Patterns Registry

## Overview

This registry maintains a list of file patterns that are exempted from the UcF file naming convention. These files should be placed in the appropriate category directories according to the Digital Organization System, but should maintain their original filenames to preserve functionality.

## Implementation Details

- Files matching these patterns will be **exempted** from renaming operations
- File naming checker will identify and report these as "exempted" rather than "non-compliant"
- These files should still be placed in the proper directories according to their function
- The check-file-naming.ps1 script contains this list in its configuration section

## Exempted File Patterns

### WordPress Core Files
- `wp-*.php`
- `index.php`
- `wp-admin/*`
- `wp-includes/*`

### Plugins and Themes
- `plugins/*`
- `themes/*`

### Configuration Files
- `wp-config.php`
- `*.config`
- `web.config`
- `*.ini`
- `*.env`

### Legal Documents
- `license*.txt`
- `license*.md`
- `terms-of-service.pdf`
- `privacy-policy.pdf`
- `contract*.pdf`
- `agreement*.pdf`

### System Files
- `*.dll`
- `*.so`
- `*.exe`
- `*.sys`
- `*.bin`

### Third-party Libraries
- `vendor/*`
- `lib/*`
- `dist/*`
- `build/*`
- `node_modules/*`

### Package Management
- `package.json`
- `composer.json`
- `*.lock`
- `yarn.lock`
- `package-lock.json`

## Adding New Exemptions

To add new exemptions to this registry:

1. Edit this file to add the pattern under the appropriate category
2. Update the `$script:config.ExemptedFilePatterns` array in the check-file-naming.ps1 script
3. Document the reason for the exemption in the comments

## Reviewing Exemptions

The exemption registry should be reviewed quarterly to ensure:

1. All necessary files are properly exempted
2. No unnecessary exemptions remain in the list
3. Patterns are as specific as possible to minimize false exemptions

---

_Updated 04-20-2025 | AI: Cursor (Claude 3.7 Sonnet)_ 