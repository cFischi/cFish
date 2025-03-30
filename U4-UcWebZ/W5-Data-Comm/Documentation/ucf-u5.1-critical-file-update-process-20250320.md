# Critical File Update Process

## Overview

This document outlines the proper procedures for updating critical files within the cFish.io system, specifically memory.md and changelog.md. These files contain vital historical information about system development and changes, and following these procedures ensures their integrity is maintained.

## Update Procedures

### 1. Memory.md Update Procedure

#### 1.1 Required Format for New Entries

Each entry in memory.md must follow this specific format:

```markdown
## [Title] (MM-DD-YYYY)
- [Bullet point with key information]
- [Additional bullet points as needed]
- [Final bullet point]

_Updated MM-DD-YYYY | AI: Cursor (Claude 3.7 Sonnet)_
```

or for human updates:

```markdown
## [Title] (MM-DD-YYYY)
- [Bullet point with key information]
- [Additional bullet points as needed]
- [Final bullet point]

_Updated MM-DD-YYYY | Human: tY FischEYe_
```

#### 1.2 Placement of New Entries

- New entries should be placed at the TOP of the file, not the bottom
- This ensures the most recent entries are visible first
- Maintain a blank line between entries for readability

#### 1.3 Pre-Update Verification

Before updating memory.md:

1. Create a backup of the current file
   ```powershell
   Copy-Item -Path "memory.md" -Destination "U5-Data\Backups\critical\memory-$(Get-Date -Format 'yyyyMMdd-HHmmss').md"
   ```

2. Verify file integrity using the verification script
   ```powershell
   .\U5-Data\Scripts\simple-verify.ps1
   ```

3. Only proceed if verification is successful

#### 1.4 Update Process

1. Open memory.md in a text editor with Markdown support
2. Add the new entry at the TOP of the file
3. Ensure proper formatting (including signature line)
4. Save the file
5. Run verification again to confirm integrity

### 2. Changelog.md Update Procedure

#### 2.1 Required Format for New Versions

Each version in changelog.md must follow this specific format:

```markdown
## [Version] - [YYYY-MM-DD]

### Added
- [New features]

### Changed
- [Changes to existing functionality]

### Fixed
- [Bug fixes]
```

#### 2.2 Versioning Rules

- Follow semantic versioning (MAJOR.MINOR.PATCH)
- MAJOR version: incompatible API changes
- MINOR version: add functionality in a backward-compatible manner
- PATCH version: backward-compatible bug fixes

#### 2.3 Pre-Update Verification

Before updating changelog.md:

1. Create a backup of the current file
   ```powershell
   Copy-Item -Path "changelog.md" -Destination "U5-Data\Backups\critical\changelog-$(Get-Date -Format 'yyyyMMdd-HHmmss').md"
   ```

2. Verify file integrity using the verification script
   ```powershell
   .\U5-Data\Scripts\simple-verify.ps1
   ```

3. Only proceed if verification is successful

#### 2.4 Update Process

1. Open changelog.md in a text editor with Markdown support
2. Add the new version entry BELOW the header but ABOVE other versions
3. Ensure proper formatting with all required sections
4. Save the file
5. Run verification again to confirm integrity

## Post-Update Procedures

After updating either file:

1. Run the backup script to create a verified backup
   ```powershell
   .\U5-Data\Scripts\simple-backup.ps1
   ```

2. Run the verification script to update fingerprints
   ```powershell
   .\U5-Data\Scripts\simple-verify.ps1
   ```

3. Document the update in the appropriate workbench memory file:
   - For system-wide changes: cFish-WB/WB-memory.md
   - For department-specific changes: U#-Department/U#-WB/WB-memory.md

## Distributed Memory Management System (DMMS) Considerations

When the DMMS is fully implemented:

1. For department-specific updates, edit the corresponding department memory.md file
2. The synchronization process will update the master memory.md file
3. For system-wide updates, edit the master memory.md file
4. The synchronization process will distribute relevant content to department files

## Approval Requirements

Updates to critical files require the following approval process:

1. For minor updates (typo fixes, formatting improvements), only self-review is required
2. For content updates, peer review by at least one other team member is required
3. For major structural changes, approval from the system administrator is required

## Troubleshooting

If issues occur during the update process:

1. Do not attempt multiple updates
2. Restore from the backup created during pre-update verification
3. Contact the system administrator or refer to the Critical File Recovery Process document

## Conclusion

Following these procedures ensures that critical historical information in memory.md and changelog.md remains properly formatted, well-organized, and protected from accidental data loss.

_Created 03-20-2025 | AI: Cursor (Claude 3.7 Sonnet)_ 