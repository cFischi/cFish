# WordPress.com Testing Guide

## Overview
This document outlines best practices for safely testing WordPress changes directly on wordpress.com without disrupting the live site. As our primary development environment has shifted from WordPress Studio to wordpress.com's backend, these procedures ensure we can effectively develop and test while minimizing risk.

## Testing Principles

### Core Safety Guidelines
1. **Always use preview/draft mode first**
2. **Back up before major changes**
3. **Test one change at a time**
4. **Document all changes thoroughly**
5. **Have a rollback plan for every change**

## Testing Methods

### 1. Content Testing (Posts & Pages)

#### Draft Mode Testing
- Create content as drafts first
- Use WordPress.com's preview functionality
- Test across multiple device views using responsive preview
- Only publish when fully validated
- For existing pages, use "Preview Changes" rather than updating immediately

#### Revision History
- WordPress.com maintains revision history for posts and pages
- Use this as a safety net for content changes
- Know how to restore previous versions if needed

### 2. Theme Customization Testing

#### Using the Customizer
- Changes in the Customizer are previewed before being applied
- Test customizations across multiple device breakpoints
- Make incremental changes rather than many at once
- Take screenshots before/after for documentation

#### Additional CSS
- Use WordPress.com's Additional CSS feature in the Customizer
- Changes are previewed in real-time
- Start with temporary CSS (commented with test notes)
- Only save when CSS is confirmed working correctly

#### Theme File Edits
- For themes that allow direct file editing:
  - Make backups of original files
  - Edit in a code editor with syntax highlighting
  - Validate code before applying
  - Test immediately after changes

### 3. Plugin Testing

#### New Plugin Activation
- Research plugin compatibility before installation
- Activate one plugin at a time
- Test core site functionality immediately after activation
- Have deactivation steps ready if issues arise

#### Plugin Updates
- Create a backup before updating plugins
- Update plugins individually when possible
- Test key functionality after each update
- Document any issues encountered

### 4. Advanced Testing Techniques

#### Staging Environments
- For Business plan or higher: use staging environments when available
- Clone site to staging for major changes
- Test completely in staging before applying to production
- Document staging test results

#### Private Mode
- Set site visibility to private during major updates
- Use a maintenance mode plugin if available
- Communicate maintenance windows to team members
- Test thoroughly before making site public again

## Testing the Assembler Footer Update

### Specific Testing Plan
1. **Access WordPress.com Admin**
   - Log in to wordpress.com dashboard
   - Navigate to your site's admin panel

2. **Child Theme Verification**
   - Go to Appearance > Themes
   - Ensure Assembler Child theme is available
   - If needed, upload the theme files from local repository

3. **Theme Activation**
   - Activate the Assembler Child theme if not already active
   - Note: This may temporarily change site appearance

4. **Footer Verification**
   - Use "Preview" to check the frontend
   - Scroll to footer and verify "Made with ❤️ by cFish.io" appears
   - Confirm text styling (bold, red) is applied correctly
   - Check on multiple device sizes (mobile, tablet, desktop)

5. **Documentation**
   - Take screenshots of the working footer
   - Document any issues or necessary adjustments
   - Update testing notes in GitHub

## Documentation Standards

### Test Records
- Date and time of testing
- Specific changes tested
- Test environment (browser, device)
- Results (pass/fail)
- Screenshots or evidence
- Any issues encountered

### Change Log Updates
- Update changelog.md after successful tests
- Include summary of changes
- Link to any relevant issues or pull requests
- Document version numbers affected

## Recovery Procedures

### Content Rollback
- How to restore previous post/page versions
- Using WordPress.com's revision history

### Theme Rollback
- How to revert to previous theme
- Restoring original theme files

### Full Site Restore
- Using WordPress.com's backup features
- When to contact WordPress.com support
- Emergency contact procedures

## References
- [WordPress.com Support Documentation](https://wordpress.com/support/)
- [WordPress.com Theme Documentation](https://wordpress.com/support/themes/)
- [WordPress.com Customizer Guide](https://wordpress.com/support/customizer/) 