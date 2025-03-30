# WordPress-Specific Token Optimization Strategies

## Overview

This guide provides specialized token optimization strategies for WordPress development tasks using the Multi-Agent Workflow System. These strategies are designed to maximize efficiency while maintaining high-quality output for WordPress themes, plugins, and core customizations.

## Theme Development Optimization

### Template Structure
- **Template Hierarchy Focus**: Request specific template files rather than entire theme structure
- **Template Part Isolation**: Work on header, footer, sidebar, and content components separately
- **Style Chunking**: Organize CSS requests by component rather than full stylesheets
- **Mobile-First Strategy**: Request mobile styles first, then progressive enhancements
- **Reference Patterns**: Use `"Implement similar to Twenty Twenty-Five theme navigation"` instead of describing from scratch

### Sample Optimized Template Request
```
Create a WordPress single.php template file with the following:
1. Featured image with responsive sizing
2. Post meta (date, author, categories) below title
3. Social sharing section after content
4. Related posts section (3 posts max)
5. Standard WordPress comments section

Follow WordPress Theme standards and compatibility with Gutenberg blocks.
```

### Theme Customizer
- **Panel-Based Requests**: Request one customizer panel implementation at a time
- **Settings API Focus**: Generate settings fields in grouped sections
- **Control Patterns**: Generate one control type, then request variations
- **Sanitization Functions**: Create reusable sanitization functions first, then reference

## Plugin Development Optimization

### Architecture Planning
- **Feature Isolation**: Request a plugin architecture diagram before implementation
- **Modular Structure**: Plan distinct modules, then implement individually
- **Hook Mapping**: Create a hook map diagram showing action/filter flow
- **Class Planning**: Define class responsibilities before implementation

### Implementation Strategy
- **Base Class First**: Generate the main plugin class with initialization hooks
- **Core Functions**: Implement essential functions before specialized features
- **Admin vs. Frontend**: Separate admin-related code from frontend functionality
- **API Endpoints**: Generate endpoints individually rather than all at once
- **Internationalization**: Add i18n at the end rather than during initial implementation

### Sample Optimized Plugin Implementation Plan
```
1. Create plugin base class with activation/deactivation hooks
2. Implement custom post type registration
3. Add admin metaboxes for the custom post type
4. Create frontend shortcode for displaying items
5. Implement settings page
6. Add REST API endpoints
7. Enhance with AJAX functionality
```

## Database Operations Optimization

### Query Optimization
- **Individual Query Focus**: Optimize one query pattern at a time
- **$wpdb Preparation**: Always use prepared statements template once, then reference
- **Query Types**: Generate separate optimized queries for SELECT, INSERT, UPDATE
- **Meta Query Patterns**: Create reusable meta query templates
- **Taxonomy Query Patterns**: Create reusable taxonomy query templates

### Example Optimized Database Request
```
Create an optimized WP_Query for retrieving:
- Custom post type 'product'
- With meta_key 'featured' = 'yes'
- In the 'promotion' taxonomy with term 'summer-sale'
- Ordered by 'menu_order'
- Limited to 10 items
- With proper caching considerations
```

## Block Editor (Gutenberg) Optimization

### Block Development
- **Block Registration First**: Generate block.json and registration code first
- **Edit Component**: Focus on edit component functionality in isolation
- **Save Component**: Create save component separately from edit component
- **Attributes Structure**: Define attributes structure before implementation
- **Block Variations**: Create core block, then request variations separately

### Block Patterns
- **Pattern Categories**: Define pattern categories first
- **Individual Patterns**: Create one pattern at a time
- **Pattern Registration**: Generate registration code after patterns are finalized

### Sample Optimized Block Request
```
Create a custom Gutenberg block with:
1. block.json registration with appropriate metadata
2. Attributes for: title (string), content (rich text), linkUrl (string), imageId (number)
3. Edit component with Inspector Controls for all attributes
4. Save component that renders a styled card with these elements
```

## REST API Optimization

### Endpoint Strategy
- **Route Registration First**: Register routes before implementing callbacks
- **Individual Endpoints**: Create GET, POST, PUT endpoints separately
- **Permission Callback**: Create permission callback functions as reusable utilities
- **Response Formatting**: Create response formatting utilities for consistency
- **Schema Definitions**: Define schemas before implementation

### Example Optimized REST API Request
```
Create a WordPress REST API endpoint for:
1. Route: 'my-plugin/v1/profiles'
2. Method: GET with parameters for filtering by 'category' and 'status'
3. Permission callback requiring 'read' capability
4. Response that includes formatted profile data with embedded author information
```

## Security Implementation Optimization

### Data Validation
- **Input Type Focus**: Create validators for specific input types
- **Reusable Sanitizers**: Build a library of sanitization functions
- **Nonce Implementation**: Create standard nonce verification pattern once
- **Capability Checks**: Establish pattern for capability verification

### Example Optimized Security Request
```
Create a comprehensive input sanitization function for:
1. User-submitted form with text, email, URL and textarea fields
2. AJAX submission handling
3. Nonce verification
4. Capability check for 'edit_posts'
```

## Metabox and Settings Optimization

### Settings API
- **Settings Section First**: Register settings sections before fields
- **Field Types**: Group similar field types in requests
- **Validation Functions**: Create field validation functions separately
- **Settings Storage**: Implement settings storage pattern once

### Metaboxes
- **Registration First**: Register metabox before field implementation
- **Field Group Strategy**: Implement related fields together
- **Specialized Fields**: Request custom field types individually
- **Data Storage**: Implement meta storage functions separately

## Token-Efficient Communication Templates

### Architecture Planning
```
Define a WordPress plugin architecture for [FEATURE] with:
1. Core functionality requirements
2. Data structures needed
3. Admin vs. Frontend components
4. Integration points with WordPress core
5. Required hooks (actions/filters)
6. Class structure and responsibilities
```

### Feature Implementation
```
Implement WordPress [FEATURE] based on:
1. Specific functionality: [DESCRIPTION]
2. WordPress hooks to utilize: [HOOKS]
3. Data structures: [STRUCTURES]
4. Integration requirements: [REQUIREMENTS]
```

### Optimization Request
```
Optimize this WordPress [CODE TYPE] for:
1. Performance issues: [ISSUES]
2. Best practices: [STANDARDS]
3. Security considerations: [CONCERNS]
```

## Implementation Process

1. **Task Analysis** - Determine WordPress-specific task type and complexity
2. **Strategy Selection** - Choose appropriate optimization strategy from this guide
3. **Request Formulation** - Structure request using provided templates
4. **Progressive Implementation** - Build features in logical, modular progression
5. **Reuse Patterns** - Leverage established patterns across implementation
6. **Verification** - Validate against WordPress coding standards and best practices

## Additional Resources
- [WordPress Coding Standards](https://developer.wordpress.org/coding-standards/)
- [WordPress Developer Resources](https://developer.wordpress.org/)
- [Token Budget Guidelines](.cursor/token-management/token-budget-guidelines.md)
- [Token Monitoring Guide](.cursor/performance-tools/token-monitoring-guide.md) 