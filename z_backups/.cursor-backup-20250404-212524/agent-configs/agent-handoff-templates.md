# Agent Handoff Templates for cFish.io WordPress Development

This document provides standardized templates for handoffs between specialized agent roles. Using these templates ensures consistent communication and effective knowledge transfer between agents working on WordPress development projects.

## Table of Contents

1. [Using Handoff Templates](#using-handoff-templates)
2. [Project Architect to Code Implementation Specialist](#project-architect-to-code-implementation-specialist)
3. [Project Architect to Theme Development Specialist](#project-architect-to-theme-development-specialist)
4. [Code Implementation Specialist to Security & QA Analyst](#code-implementation-specialist-to-security--qa-analyst)
5. [Theme Development Specialist to Code Implementation Specialist](#theme-development-specialist-to-code-implementation-specialist)
6. [Code Implementation Specialist to Documentation Specialist](#code-implementation-specialist-to-documentation-specialist)
7. [Security & QA Analyst to Code Implementation Specialist](#security--qa-analyst-to-code-implementation-specialist)
8. [Plugin Integration Specialist to Theme Development Specialist](#plugin-integration-specialist-to-theme-development-specialist)
9. [Security & QA Analyst to Documentation Specialist](#security--qa-analyst-to-documentation-specialist)
10. [General Handoff Template](#general-handoff-template)

## Using Handoff Templates

To use these templates:

1. Copy the relevant template based on your current role and the role you're handing off to
2. Fill in the required information in all sections
3. Include all necessary file paths, code snippets, and relevant context
4. Add the completed handoff as a comment in the prompt requesting the agent switch
5. When receiving a handoff, confirm receipt and review the information before proceeding

## Project Architect to Code Implementation Specialist

```
## HANDOFF: Project Architect → Code Implementation Specialist

### Project Context
- Project Name: [Project Name]
- Phase: [Development Phase]
- Related Files: [List all relevant file paths]

### Feature Specification
[Detailed description of the feature to be implemented]

### Technical Requirements
- Database Interactions: [Describe any required database operations]
- WordPress Hooks: [List relevant action/filter hooks to be used]
- Dependencies: [List any plugin/theme dependencies]
- Performance Considerations: [Note any performance requirements]

### Implementation Guidelines
- [Specific implementation guidelines]
- [Code style requirements]
- [Framework or library usage instructions]

### Success Criteria
- [List measurable criteria for successful implementation]
- [Include any required test scenarios]

### Additional Resources
- [Links to relevant documentation]
- [References to similar implementations]
```

## Project Architect to Theme Development Specialist

```
## HANDOFF: Project Architect → Theme Development Specialist

### Project Context
- Project Name: [Project Name]
- Design Assets: [Links to design files/mockups]
- Related Files: [List all relevant file paths]

### Design Requirements
- Theme Type: [Parent/Child/Custom]
- Design System: [Color palette, typography, spacing guidelines]
- Responsive Breakpoints: [List required breakpoints]
- Core Templates Required: [List required WordPress templates]

### Technical Requirements
- Browser Support: [List required browsers]
- Performance Goals: [Speed/performance targets]
- Accessibility Standards: [WCAG level required]
- Compatibility: [Plugin compatibility requirements]

### Implementation Guidelines
- [Specific implementation guidelines]
- [Code organization requirements]
- [Asset optimization guidelines]

### Success Criteria
- [List measurable criteria for successful implementation]
- [Include any required test scenarios]

### Additional Resources
- [Links to design systems]
- [References to similar implementations]
- [Any prototype or mockup URLs]
```

## Code Implementation Specialist to Security & QA Analyst

```
## HANDOFF: Code Implementation Specialist → Security & QA Analyst

### Implementation Summary
- Feature Name: [Feature Name]
- Files Modified: [List all modified files with paths]
- New Files Created: [List all new files with paths]

### Implementation Details
[Brief description of the implementation approach]

### Key Security Considerations
- Data Handling: [Describe how user data is handled]
- Input Validation: [Describe validation methods used]
- Output Escaping: [Describe escaping methods used]
- Database Queries: [Describe how queries are prepared]
- Authentication: [Describe any auth-related code]

### Areas of Concern
[List any areas you're particularly concerned about]

### Testing Requirements
- Required Test Cases: [List specific test scenarios]
- Environment Details: [Relevant environment information]

### Additional Context
[Any other relevant information for the security review]
```

## Theme Development Specialist to Code Implementation Specialist

```
## HANDOFF: Theme Development Specialist → Code Implementation Specialist

### Theme Context
- Theme Name: [Theme Name]
- Theme Structure: [Brief description of theme architecture]
- Files Created/Modified: [List relevant files with paths]

### Implementation Request
[Describe the functionality that needs to be implemented]

### Integration Points
- Template Files: [List template files where functionality should be added]
- Hook Locations: [Describe where actions/filters should be added]
- CSS Classes: [List relevant CSS classes for styling]

### Design Constraints
- Responsive Behavior: [Describe any responsive considerations]
- Accessibility Requirements: [Note specific a11y requirements]
- Animation/Interaction: [Describe any required animations]

### Technical Requirements
- Browser Support: [List required browsers]
- Performance Considerations: [Note any performance requirements]

### Additional Context
[Any other relevant information needed for implementation]
```

## Code Implementation Specialist to Documentation Specialist

```
## HANDOFF: Code Implementation Specialist → Documentation Specialist

### Feature Summary
- Feature Name: [Feature Name]
- Files Implemented: [List relevant files with paths]
- Version: [Version number where feature was added]

### Feature Description
[Comprehensive description of the implemented feature]

### Usage Instructions
[Step-by-step instructions on how to use the feature]

### Code Examples
```php
// Example code showing usage
```

### Configuration Options
- [Option name]: [Description and possible values]
- [Option name]: [Description and possible values]

### Technical Details
- Hooks Available: [List actions/filters with parameters]
- Database Impact: [Describe any database changes]
- Performance Considerations: [Note any performance impacts]
- Dependencies: [List any dependencies]

### Screenshots/Visuals
[Describe any screenshots or visuals that should be included]
```

## Security & QA Analyst to Code Implementation Specialist

```
## HANDOFF: Security & QA Analyst → Code Implementation Specialist

### Review Summary
- Feature Reviewed: [Feature Name]
- Files Reviewed: [List reviewed files with paths]
- Overall Assessment: [Pass/Needs Revision/Critical Issues]

### Security Issues
[List security issues found with severity levels]

### Recommended Fixes
- [Issue 1]: [Suggested fix with code example if applicable]
- [Issue 2]: [Suggested fix with code example if applicable]

### Quality Issues
- [Issue 1]: [Description and recommendation]
- [Issue 2]: [Description and recommendation]

### Testing Results
[Summary of testing performed and results]

### Additional Recommendations
[Any other recommendations for improving the code]
```

## Plugin Integration Specialist to Theme Development Specialist

```
## HANDOFF: Plugin Integration Specialist → Theme Development Specialist

### Plugin Context
- Plugin Name: [Plugin Name]
- Plugin Version: [Version number]
- Integration Purpose: [Why this plugin needs theme integration]

### Theme Integration Requirements
- Templates Needed: [List any templates that need to be created/modified]
- Style Requirements: [Describe styling needs]
- Script Requirements: [Describe any JS modifications needed]

### Integration Points
- Hook Locations: [Describe where theme should add actions/filters]
- Template Overrides: [List templates that should be overridden]
- CSS Classes: [List CSS classes that should be styled]

### Technical Constraints
- Plugin Dependencies: [List any other plugin dependencies]
- Performance Considerations: [Note any performance requirements]

### Additional Context
[Any other relevant information for theme integration]
```

## Security & QA Analyst to Documentation Specialist

```
## HANDOFF: Security & QA Analyst → Documentation Specialist

### Feature Assessment
- Feature Name: [Feature Name]
- Security Level: [Assessment of security - High/Medium/Low]
- Key Protections: [List key security protections implemented]

### Security Documentation Needs
- Security Features: [List security features that need documentation]
- Usage Warnings: [List any usage warnings that should be documented]
- Best Practices: [Security best practices to include]

### Technical Details for Documentation
- Validation Methods: [Describe input validation methods]
- Escaping Techniques: [Describe output escaping techniques]
- Database Protections: [Describe query preparation methods]

### Test Cases
[List test cases that should be included in documentation]

### Additional Security Notes
[Any other security information that should be included]
```

## General Handoff Template

```
## HANDOFF: [Source Role] → [Target Role]

### Context
- Project/Feature: [Project or Feature Name]
- Files Involved: [List relevant files with paths]
- Current Status: [Brief status description]

### Task Description
[Clear description of what needs to be done]

### Key Information
- [Key point 1]
- [Key point 2]
- [Key point 3]

### Dependencies and Requirements
- [List any dependencies or requirements]

### Success Criteria
- [List measurable criteria for successful completion]

### Additional Context
[Any other relevant information]
```

## Implementation Guidelines

When implementing handoffs between agent roles, the following practices should be observed:

1. **Completeness**: Ensure all sections of the template are filled out with specific, actionable information
2. **Context**: Provide sufficient context so the receiving agent can understand the task without extensive questioning
3. **File Paths**: Always include absolute file paths when referencing files
4. **Code Snippets**: Include relevant code snippets with proper formatting and syntax highlighting
5. **Success Criteria**: Define clear success criteria so the receiving agent knows when the task is completed satisfactorily
6. **Documentation Links**: Include links to relevant documentation when applicable
7. **Versioning**: Note any version dependencies for WordPress, plugins, or themes
8. **Communication**: Acknowledge handoff receipt and ask clarifying questions before proceeding

## Example Handoff

Here's an example of a completed handoff from Project Architect to Code Implementation Specialist:

```
## HANDOFF: Project Architect → Code Implementation Specialist

### Project Context
- Project Name: Client Dashboard Widget
- Phase: Initial Implementation
- Related Files: 
  - wp-content/plugins/client-dashboard/client-dashboard.php
  - wp-content/plugins/client-dashboard/includes/class-client-dashboard-widget.php
  - wp-content/plugins/client-dashboard/includes/class-client-dashboard-data.php

### Feature Specification
Implement a WordPress dashboard widget that displays recent client activity from our custom client management system. The widget should show the 5 most recent client interactions, including interaction type, date, and client name. Clicking on a client name should navigate to the client detail page.

### Technical Requirements
- Database Interactions: Query the wp_client_interactions table using $wpdb
- WordPress Hooks: 
  - wp_dashboard_setup (to register the widget)
  - admin_enqueue_scripts (for widget-specific styles)
- Dependencies: Client Management System plugin must be active
- Performance Considerations: Cache query results for 1 hour using transients API

### Implementation Guidelines
- Use OOP approach with a dedicated ClientDashboardWidget class
- Follow WordPress coding standards
- Implement proper capability checks (manage_options)
- Ensure all database queries are properly prepared
- Use nonces for any actions within the widget

### Success Criteria
- Widget appears on WordPress dashboard for admin users
- Widget correctly displays 5 most recent client interactions
- Data refreshes when cache expires
- Clicking client names navigates to client detail page
- No PHP errors or warnings
- Passes WordPress coding standards check

### Additional Resources
- Client Management System API Documentation: /docs/client-management-api.md
- Similar implementation: wp-content/plugins/client-management/widgets/recent-tickets.php
``` 