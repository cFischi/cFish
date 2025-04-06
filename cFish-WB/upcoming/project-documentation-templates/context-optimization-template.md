# WordPress Project Context Optimization Template

## Overview
This template provides a structured approach for creating optimized context for WordPress development with Cursor AI. Fill out each section with concise, targeted information to improve AI assistance while minimizing token usage.

## Project Essentials

### Project Type
- [ ] Theme
- [ ] Plugin
- [ ] Block
- [ ] WooCommerce Extension
- [ ] Other: _____________

### Core Dependencies
- WordPress Version: _____________
- PHP Version: _____________
- Key Plugins: _____________
- Frontend Framework (if any): _____________

### Project Structure
```
project/
├── [Key directories and files only]
└── ...
```

### Naming Conventions
- Files: _____________
- Classes: _____________
- Functions: _____________
- Hooks: _____________

## Architecture Overview

### Design Patterns
[List 2-3 primary design patterns used in the project]
- Pattern 1: _____________
- Pattern 2: _____________

### Component Organization
[Brief description of how components are organized]

### Data Flow
[Simplified diagram or description of main data flow]

## Code Conventions

### Coding Standards
[Note any deviations from standard WordPress coding practices]

### Error Handling Approach
[Brief description of error handling strategy]

### Security Implementation
[Key security practices specific to this project]

## Development Focus Areas

### Current Development Priorities
[List 1-3 current focus areas]
1. _____________
2. _____________
3. _____________

### Known Issues/Constraints
[List any known limitations, bugs, or constraints]

### Optimization Targets
[Areas where performance is critical]

## Reference Shortcuts

### Key Files
[List critical files that may need frequent reference]
- `class-main.php`: Core functionality
- `template-functions.php`: Template-related functions
- _____________
- _____________

### Hook Reference
[List most frequently used custom hooks]
```php
// Actions
do_action('project_before_content', $post_id);
do_action('project_after_content', $post_id);

// Filters
apply_filters('project_content_classes', $classes, $post_id);
```

### Database Schema
[Brief overview of custom tables or key meta fields]
```
wp_custom_table:
- id (primary key)
- title
- content
- created_at
```

## Testing Environment

### Local Environment
[Brief description of local development setup]

### Test Data
[Notes about test data availability]

### Testing Process
[Brief outline of how to test changes]

## Implementation Examples

### Template Usage Example
```php
// How to use template parts in this project
get_template_part('template-parts/content', 'product', [
  'product_id' => $product_id,
  'show_price' => true
]);
```

### Custom Function Pattern
```php
// Pattern for implementing custom functions
function project_prefix_function_name($required_param, $optional_param = null) {
  // Parameter validation
  if (!$required_param) {
    return false;
  }
  
  // Function logic
  
  return $result;
}
```

### Hook Implementation
```php
// How hooks should be implemented
add_action('init', [$this, 'initialize'], 10, 1);
add_filter('project_filter', [$this, 'filter_callback'], 10, 2);
```

## Task-Specific Information

### [Task Name/Component]
[Add specific context relevant to the current task]

### Integration Points
[Any systems this task/component needs to integrate with]

### Required Capabilities
[Any WordPress capabilities needed for this functionality]

## How To Use This Template

1. Fill out relevant sections based on your project
2. Remove sections that don't apply to your project
3. Be concise - aim for maximum information with minimum text
4. Update this document as your project evolves
5. Reference this document in Cursor AI conversations with:
   ```
   @context-optimization-template.md
   ```
6. For task-specific work, only include the relevant sections:
   ```
   Here's the context for the current task:
   
   [Copy only relevant sections from this template]
   ```

## Optimization Tips

1. Include only what's needed for the current task
2. Use shorthand where possible (e.g., PHP 7.4+ instead of "PHP version 7.4 or higher")
3. Link to more detailed documentation rather than including it all
4. Update this template over time to reflect common needs
5. Consider creating multiple specialized context files for different aspects of the project

_Template Version: 1.0 - Created 05-06-2025 | AI: Cursor (Claude 3.7 Sonnet)_ 