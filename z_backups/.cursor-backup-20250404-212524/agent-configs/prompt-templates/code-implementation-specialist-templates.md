# Code Implementation Specialist Prompt Templates

These templates provide structured formats for common Code Implementation Specialist tasks in WordPress development. Using these templates helps ensure comprehensive implementation requirements and reduces token usage.

## Plugin Feature Implementation

```
# WordPress Plugin Feature Implementation

## Feature Name: [NAME]
## Description: [BRIEF DESCRIPTION]

### Technical Requirements
- WordPress Version: [VERSION RANGE]
- PHP Version: [VERSION RANGE]
- Required Dependencies: [DEPENDENCIES]
- Performance Constraints: [CONSTRAINTS]

### Feature Scope
- [FUNCTIONALITY 1]
- [FUNCTIONALITY 2]
- [FUNCTIONALITY 3]

### Integration Points
- WordPress Hooks: [HOOKS]
- Database Interactions: [DB INTERACTIONS]
- External APIs: [API DETAILS]
- User Interface Elements: [UI ELEMENTS]

### Implementation Request
Please implement this WordPress plugin feature with the following:

1. Main class(es) with proper namespace and docblocks
2. Initialization hooks and setup methods
3. Core functionality methods
4. Admin interface components (if applicable)
5. Frontend rendering components (if applicable)
6. Database interactions with proper sanitization and validation
7. Security measures including capability checks and nonce verification
8. Internationalization support

Follow WordPress coding standards and best practices throughout.
```

## Custom Post Type Implementation

```
# WordPress Custom Post Type Implementation

## Post Type Name: [NAME]
## Post Type Slug: [SLUG]

### Post Type Details
- Public: [YES/NO]
- Has Archive: [YES/NO]
- Hierarchical: [YES/NO]
- Show in REST: [YES/NO]
- Menu Position: [POSITION]
- Menu Icon: [ICON]
- Supports: [FEATURES]

### Taxonomy Integration
- Existing Taxonomies: [TAXONOMIES]
- Custom Taxonomies: [CUSTOM TAXONOMIES]

### Meta Fields
- [FIELD 1 NAME]: [TYPE] - [DESCRIPTION]
- [FIELD 2 NAME]: [TYPE] - [DESCRIPTION]
- [FIELD 3 NAME]: [TYPE] - [DESCRIPTION]

### Implementation Request
Please implement this WordPress custom post type with:

1. Registration function with proper hook integration
2. Labels array with full internationalization support
3. Arguments array with all necessary settings
4. Meta box implementation for custom fields
5. Admin column integration for relevant fields
6. REST API support with proper endpoints
7. Admin CSS for improved user interface
8. Proper sanitization and validation for all data

Follow WordPress coding standards with proper prefixing and namespace usage.
```

## REST API Endpoint Implementation

```
# WordPress REST API Endpoint Implementation

## Endpoint Base: [BASE PATH]
## Endpoint Version: [VERSION]

### Endpoint Routes
- GET [ROUTE 1]: [DESCRIPTION]
- POST [ROUTE 2]: [DESCRIPTION]
- PUT [ROUTE 3]: [DESCRIPTION]
- DELETE [ROUTE 4]: [DESCRIPTION]

### Parameters
- [PARAMETER 1]: [TYPE] - [DESCRIPTION] - [REQUIRED/OPTIONAL]
- [PARAMETER 2]: [TYPE] - [DESCRIPTION] - [REQUIRED/OPTIONAL]
- [PARAMETER 3]: [TYPE] - [DESCRIPTION] - [REQUIRED/OPTIONAL]

### Authentication Requirements
- [CAPABILITY/ROLE REQUIREMENTS]
- [NONCE REQUIREMENTS]
- [OTHER AUTH REQUIREMENTS]

### Response Format
- Success: [STRUCTURE]
- Error: [STRUCTURE]

### Implementation Request
Please implement these WordPress REST API endpoints with:

1. Route registration function with proper namespace
2. Parameter validation with sanitization
3. Permission callback with proper authentication
4. Main callback functions for each endpoint
5. Responses following REST standards
6. Error handling with appropriate status codes
7. Proper data formatting for response
8. Documentation in PHPDoc format

Ensure proper REST API practices and WordPress coding standards.
```

## Shortcode Implementation

```
# WordPress Shortcode Implementation

## Shortcode Name: [NAME]
## Shortcode Tag: [TAG]

### Parameters
- [PARAMETER 1]: [DEFAULT] - [DESCRIPTION]
- [PARAMETER 2]: [DEFAULT] - [DESCRIPTION]
- [PARAMETER 3]: [DEFAULT] - [DESCRIPTION]

### Functionality
[DETAILED DESCRIPTION OF SHORTCODE FUNCTIONALITY]

### Output Requirements
- HTML Structure: [STRUCTURE]
- CSS Integration: [INTEGRATION APPROACH]
- JavaScript Dependencies: [DEPENDENCIES]

### Implementation Request
Please implement this WordPress shortcode with:

1. Registration function with proper hook
2. Parameter normalization with defaults
3. Proper sanitization of all inputs
4. Content processing if applicable
5. HTML output generation with escaping
6. Required CSS and JavaScript loading
7. Caching approach for performance
8. Clear documentation in comments

Follow WordPress shortcode best practices and coding standards.
```

## Settings Page Implementation

```
# WordPress Settings Page Implementation

## Settings Page Name: [NAME]
## Menu Location: [LOCATION]

### Settings Sections
- [SECTION 1]: [DESCRIPTION]
- [SECTION 2]: [DESCRIPTION]
- [SECTION 3]: [DESCRIPTION]

### Settings Fields
- [FIELD 1]: [TYPE] - [SECTION] - [DESCRIPTION]
- [FIELD 2]: [TYPE] - [SECTION] - [DESCRIPTION]
- [FIELD 3]: [TYPE] - [SECTION] - [DESCRIPTION]

### Validation Requirements
- [FIELD 1]: [VALIDATION RULES]
- [FIELD 2]: [VALIDATION RULES]
- [FIELD 3]: [VALIDATION RULES]

### Implementation Request
Please implement this WordPress settings page with:

1. Registration function with proper hook
2. Page callback function with admin UI
3. Settings sections with descriptions
4. Settings fields with proper types
5. Validation and sanitization functions
6. Default values handling
7. Settings retrieval helper function
8. Nonce verification for form submission

Follow WordPress Settings API best practices and coding standards.
```

## Database Query Optimization

```
# WordPress Database Query Optimization

## Query Purpose: [PURPOSE]
## Current Performance: [METRICS]
## Target Performance: [METRICS]

### Current Query
```php
[CURRENT QUERY CODE]
```

### Data Requirements
- Primary Data: [DESCRIPTION]
- Related Data: [DESCRIPTION]
- Ordering: [REQUIREMENTS]
- Filtering: [REQUIREMENTS]

### Optimization Constraints
- Must Maintain: [FUNCTIONALITY TO PRESERVE]
- Can Change: [CHANGEABLE ASPECTS]
- Environment: [WP VERSION, PHP VERSION, ETC]

### Optimization Request
Please optimize this WordPress database query focusing on:

1. Query structure and approach
2. JOIN optimization
3. WHERE clause efficiency
4. Index utilization
5. Results limiting and pagination
6. Meta query improvements
7. Caching implementation
8. Prepare statement usage

Provide the optimized query with comments explaining optimization approach.
```

## AJAX Handler Implementation

```
# WordPress AJAX Handler Implementation

## AJAX Action: [ACTION NAME]
## Access: [ADMIN/FRONTEND/BOTH]

### Functionality
[DETAILED DESCRIPTION OF AJAX FUNCTIONALITY]

### Parameters
- [PARAMETER 1]: [TYPE] - [DESCRIPTION] - [REQUIRED/OPTIONAL]
- [PARAMETER 2]: [TYPE] - [DESCRIPTION] - [REQUIRED/OPTIONAL]
- [PARAMETER 3]: [TYPE] - [DESCRIPTION] - [REQUIRED/OPTIONAL]

### Security Requirements
- Nonce: [NONCE NAME]
- Capability: [REQUIRED CAPABILITY]
- Rate Limiting: [REQUIREMENTS]

### Response Format
- Success: [STRUCTURE]
- Error: [STRUCTURE]

### Implementation Request
Please implement this WordPress AJAX handler with:

1. PHP server-side handler function
2. JavaScript client-side function
3. Proper wp_ajax hook registration
4. Nonce verification
5. Parameter validation and sanitization
6. Capability checks
7. Error handling
8. Structured JSON response

Ensure proper security practices and WordPress coding standards.
```

## Theme Template Implementation

```
# WordPress Theme Template Implementation

## Template: [TEMPLATE NAME]
## Template Hierarchy Position: [POSITION]

### Template Purpose
[DETAILED DESCRIPTION OF TEMPLATE PURPOSE]

### Content Structure
- [SECTION 1]: [DESCRIPTION]
- [SECTION 2]: [DESCRIPTION]
- [SECTION 3]: [DESCRIPTION]

### Template Features
- Responsive Breakpoints: [BREAKPOINTS]
- Dynamic Elements: [ELEMENTS]
- Template Parts: [PARTS]
- Block Support: [SUPPORT DETAILS]

### Implementation Request
Please implement this WordPress theme template with:

1. Proper template header comments
2. WordPress template tags usage
3. Content structure implementation
4. Responsive layout approach
5. Block editor compatibility
6. Template part integration
7. Dynamic content handling
8. Proper escaping for all outputs

Follow WordPress theme development best practices and coding standards.
```

## Block Pattern Implementation

```
# WordPress Block Pattern Implementation

## Pattern Name: [NAME]
## Pattern Category: [CATEGORY]

### Pattern Purpose
[DETAILED DESCRIPTION OF PATTERN PURPOSE]

### Block Components
- [BLOCK 1]: [CONFIGURATION]
- [BLOCK 2]: [CONFIGURATION]
- [BLOCK 3]: [CONFIGURATION]

### Styling Requirements
- Spacing: [REQUIREMENTS]
- Colors: [REQUIREMENTS]
- Typography: [REQUIREMENTS]

### Implementation Request
Please implement this WordPress block pattern with:

1. Pattern registration function
2. Block structure with proper nesting
3. Appropriate block attributes
4. Design implementation according to requirements
5. Default content population
6. Category assignment
7. Viewport considerations
8. Pattern preview thumbnail

Follow WordPress block pattern best practices and coding standards.
```

## Best Practices for Using These Templates

1. **Be specific about requirements** - Provide detailed requirements to avoid back-and-forth
2. **Include context** - Reference related code or functionality when applicable
3. **Specify constraints** - Technical limitations, performance requirements, etc.
4. **Include code snippets** - For optimization or enhancement tasks, include current code
5. **Define acceptance criteria** - What constitutes successful implementation?
6. **Reference existing patterns** - For consistency with the rest of the codebase
7. **Provide examples** - Similar functionality examples when available
8. **Specify versioning requirements** - WordPress, PHP, browser compatibility

## Next Steps After Template Use

1. **Code review** - Review generated code against requirements
2. **Testing** - Test functionality in appropriate environment
3. **Documentation** - Ensure adequate documentation is included
4. **Integration** - Integrate with existing codebase
5. **Performance validation** - Verify performance meets requirements 