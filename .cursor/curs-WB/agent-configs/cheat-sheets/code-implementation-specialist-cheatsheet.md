# Code Implementation Specialist Quick Reference Cheat Sheet

## Core Responsibilities
- Implement features according to project specifications
- Write clean, efficient, and maintainable code
- Fix bugs and resolve technical issues
- Optimize code for performance and scalability
- Ensure code adheres to project standards and best practices

## Common Tasks
- **Feature Implementation**
  - WordPress plugin development
  - Theme customization and extension
  - Custom post type creation
  - Shortcode development
  - API integration

- **Code Optimization**
  - Database query optimization
  - Frontend asset management
  - Caching implementation
  - Code refactoring

- **Bug Fixing**
  - Error identification
  - Root cause analysis
  - Patch development
  - Regression testing

## Key Commands & Actions
- `/implement feature [feature-name]` - Generate implementation for a feature
- `/implement function [function-name]` - Create a specific function
- `/implement class [class-name]` - Create a class structure
- `/optimize [code-block]` - Optimize a section of code
- `/debug [issue-description]` - Debug a specific issue

## Typical Prompts
1. "Implement a custom WordPress shortcode for [feature]"
2. "Create a WordPress REST API endpoint for [functionality]"
3. "Optimize this database query for better performance"
4. "Fix this bug where [description of issue]"
5. "Refactor this code to follow WordPress coding standards"

## WordPress-Specific Implementation Patterns

### Custom Post Type Registration
```php
function register_custom_post_type() {
    $args = [
        'labels' => [
            'name'               => __( 'Custom Items', 'text-domain' ),
            'singular_name'      => __( 'Custom Item', 'text-domain' ),
            // Additional labels...
        ],
        'public'             => true,
        'has_archive'        => true,
        'supports'           => ['title', 'editor', 'thumbnail', 'excerpt'],
        'show_in_rest'       => true,
        // Additional args...
    ];
    
    register_post_type( 'custom_item', $args );
}
add_action( 'init', 'register_custom_post_type' );
```

### WordPress REST API Custom Endpoint
```php
function register_custom_endpoint() {
    register_rest_route( 'my-plugin/v1', '/items', [
        'methods'  => 'GET',
        'callback' => 'get_items_callback',
        'permission_callback' => function() {
            return current_user_can( 'read' );
        }
    ]);
}
add_action( 'rest_api_init', 'register_custom_endpoint' );

function get_items_callback( $request ) {
    // Implementation
    return rest_ensure_response( $data );
}
```

### Custom Shortcode Implementation
```php
function custom_shortcode( $atts, $content = null ) {
    // Normalize attribute keys to lowercase
    $atts = array_change_key_case( (array) $atts, CASE_LOWER );
    
    // Override default attributes with user attributes
    $atts = shortcode_atts(
        [
            'attribute1' => 'default1',
            'attribute2' => 'default2',
        ],
        $atts
    );
    
    // Implementation
    $output = ''; // Generate your output here
    
    return $output;
}
add_shortcode( 'custom_shortcode', 'custom_shortcode' );
```

## Handoff Templates

### From Project Architect
```
## Project Architect → Code Implementation Specialist

### Feature Specification: [Feature Name]
- Technical requirements: [List key requirements]
- Architecture design: [Brief architecture description]
- Implementation constraints: [List constraints]
- API endpoints: [List required endpoints]
- Database interactions: [Describe DB interactions]
- Dependencies: [List dependencies]

### Key Implementation Guidelines
- [Guideline 1]
- [Guideline 2]
- [Guideline 3]

### Success Criteria
- [Criterion 1]
- [Criterion 2]
- [Criterion 3]
```

### To Security & QA Analyst
```
## Code Implementation Specialist → Security & QA Analyst

### Implementation Summary: [Feature Name]
- Implemented functionality: [Brief description]
- Key components: [List key components]
- Database changes: [Describe DB changes]
- External dependencies: [List dependencies]
- Known limitations: [List limitations]
- Areas for review focus: [List areas needing review focus]

### Specific Review Requests
- [Request 1]
- [Request 2]
- [Request 3]

### Test Cases
- [Test case 1]
- [Test case 2]
- [Test case 3]
```

## Best Practices
1. Follow WordPress coding standards
2. Use nonce verification for form submissions
3. Sanitize inputs and escape outputs
4. Use prepared statements for database queries
5. Keep functionality modular and reusable
6. Comment code adequately but not excessively
7. Implement proper error handling
8. Use WordPress hooks rather than modifying core

## Token Optimization Tips
1. Describe the implementation task clearly and concisely
2. Specify exactly which parts of the code need to be generated
3. Provide context about related code when requesting implementation
4. Be specific about coding standards to follow
5. Include information about edge cases to handle

## Related Documentation
- [WordPress Coding Standards](https://developer.wordpress.org/coding-standards/)
- [WordPress Developer Resources](https://developer.wordpress.org/)
- [WordPress Plugin Handbook](https://developer.wordpress.org/plugins/)
- [WordPress Theme Handbook](https://developer.wordpress.org/themes/) 