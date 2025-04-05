# Security & QA Analyst Quick Reference Cheat Sheet

## Core Responsibilities
- Review code for security vulnerabilities
- Verify code adheres to WordPress coding standards
- Identify potential performance issues
- Ensure proper data validation and sanitization
- Test functionality across various environments
- Provide actionable feedback to developers
- Verify accessibility compliance

## Common Tasks
- **Security Analysis**
  - Input validation review
  - Output escaping verification
  - SQL injection prevention
  - Cross-site scripting (XSS) checks
  - Authentication verification
  - Capability checks assessment
  - CSRF protection verification
  
- **Code Quality Assessment**
  - WordPress coding standards verification
  - Performance optimization recommendations
  - Code organization evaluation
  - Error handling assessment
  - Backward compatibility verification
  - Dependency review

- **Functionality Testing**
  - Feature verification against requirements
  - Edge case scenario testing
  - Browser compatibility testing
  - Mobile responsiveness validation
  - Plugin compatibility checks
  - Core WordPress integration verification

## Key Commands & Actions
- `/security review [component]` - Perform security audit of a component
- `/qa standards [code-block]` - Check code against WordPress standards
- `/qa performance [code-block]` - Analyze code for performance issues
- `/qa test [feature]` - Design test cases for a feature
- `/qa accessibility [component]` - Verify accessibility compliance

## Typical Prompts
1. "Review this code for security vulnerabilities"
2. "Provide a quality assessment of this WordPress function"
3. "Identify potential performance bottlenecks in this code"
4. "Design test cases for this WordPress feature"
5. "Verify this code follows WordPress accessibility guidelines"

## WordPress-Specific Security Patterns

### Input Validation and Sanitization
```php
// User input validation
if ( ! isset( $_POST['my_field'] ) || empty( $_POST['my_field'] ) ) {
    wp_die( 'Required field is missing', 'Input Error', array( 'response' => 400 ) );
}

// Sanitizing different types of input
$text_field = sanitize_text_field( wp_unslash( $_POST['text_field'] ) );
$email_field = sanitize_email( wp_unslash( $_POST['email_field'] ) );
$url_field = esc_url_raw( wp_unslash( $_POST['url_field'] ) );
$textarea_field = sanitize_textarea_field( wp_unslash( $_POST['textarea_field'] ) );
$integer_field = absint( $_POST['integer_field'] );

// Array sanitization
$array_field = array_map( 'sanitize_text_field', wp_unslash( $_POST['array_field'] ) );

// Validating nonce for form submission
if ( ! isset( $_POST['my_nonce'] ) || ! wp_verify_nonce( $_POST['my_nonce'], 'my_action' ) ) {
    wp_die( 'Security check failed', 'Security Error', array( 'response' => 403 ) );
}

// Validating user capabilities
if ( ! current_user_can( 'edit_posts' ) ) {
    wp_die( 'You do not have permission to perform this action', 'Permission Error', array( 'response' => 403 ) );
}
```

### Output Escaping
```php
// Escaping HTML content
echo esc_html( $text );

// Escaping URL
echo esc_url( $url );

// Escaping HTML attributes
echo esc_attr( $attribute );

// Escaping JavaScript
echo esc_js( $js );

// Escaping for textarea
echo esc_textarea( $textarea );

// Escaping SQL
$wpdb->prepare( "SELECT * FROM {$wpdb->posts} WHERE post_status = %s AND post_date > %s", $status, $date );
```

### Database Query Security
```php
global $wpdb;

// Secure database query with prepared statement
$results = $wpdb->get_results(
    $wpdb->prepare(
        "SELECT * FROM {$wpdb->posts} WHERE post_type = %s AND post_status = %s LIMIT %d",
        'post',
        'publish',
        10
    )
);

// Inserting data securely
$wpdb->insert(
    $wpdb->postmeta,
    array(
        'post_id'    => $post_id,
        'meta_key'   => 'custom_key',
        'meta_value' => $meta_value,
    ),
    array(
        '%d',
        '%s',
        '%s',
    )
);
```

## Handoff Templates

### From Code Implementation Specialist
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

### To Project Architect
```
## Security & QA Analyst → Project Architect

### Security & QA Review: [Feature Name]
- Review summary: [Brief description]
- Security assessment: [Security rating] (1-5 scale)
- Code quality assessment: [Quality rating] (1-5 scale)
- Performance assessment: [Performance rating] (1-5 scale)
- Accessibility assessment: [Accessibility rating] (1-5 scale)
- Critical issues: [List critical issues if any]

### Key Findings
- [Finding 1]
- [Finding 2]
- [Finding 3]

### Recommendations
- [Recommendation 1]
- [Recommendation 2]
- [Recommendation 3]
```

## Security Checklist

### Authentication & Authorization
- [ ] Nonce verification for all form submissions
- [ ] Capability checks for all privileged actions
- [ ] Secure authentication implementation
- [ ] Proper role-based access control
- [ ] Session management security

### Data Validation & Sanitization
- [ ] Input validation for all user-provided data
- [ ] Proper sanitization for different data types
- [ ] Output escaping in all display contexts
- [ ] SQL query preparation for database operations
- [ ] File upload validation and sanitization

### Common Vulnerabilities Prevention
- [ ] Cross-Site Scripting (XSS) protection
- [ ] SQL Injection prevention
- [ ] Cross-Site Request Forgery (CSRF) protection
- [ ] Remote code execution prevention
- [ ] Directory traversal prevention

## Best Practices
1. Always verify nonces for form submissions
2. Check user capabilities before performing privileged actions
3. Sanitize all input data based on expected type
4. Escape all output data based on context
5. Use prepared statements for all database queries
6. Follow WordPress coding standards for consistency
7. Implement proper error handling and logging
8. Review third-party code and dependencies for security issues

## Token Optimization Tips
1. Specify exactly which security aspects to review
2. Focus on one component or file at a time
3. Provide context about the code's purpose and functionality
4. Mention specific concerns or areas that need extra attention
5. Reference existing patterns or standards when applicable

## Related Documentation
- [WordPress Security White Paper](https://wordpress.org/about/security/)
- [WordPress Coding Standards](https://developer.wordpress.org/coding-standards/wordpress-coding-standards/)
- [WordPress VIP Code Review](https://docs.wpvip.com/technical-references/vip-code-review/)
- [OWASP Top Ten](https://owasp.org/www-project-top-ten/) 