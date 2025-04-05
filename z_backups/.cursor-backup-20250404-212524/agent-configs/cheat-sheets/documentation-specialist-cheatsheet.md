# Documentation Specialist Quick Reference Cheat Sheet

## Core Responsibilities
- Create comprehensive technical documentation
- Develop user guides and tutorials
- Generate inline code documentation
- Maintain documentation consistency and accuracy
- Ensure documentation follows standards and best practices
- Create documentation templates and structures
- Keep documentation updated with code changes

## Common Tasks
- **Technical Documentation**
  - API documentation generation
  - Function and class documentation
  - Architecture documentation
  - Development workflow guides
  - System requirements documentation
  - Installation and setup guides
  
- **User Documentation**
  - End-user manuals and guides
  - Admin interface documentation
  - Feature usage tutorials
  - Troubleshooting guides
  - FAQ creation and maintenance
  - Video script preparation

- **WordPress-Specific Documentation**
  - Theme documentation
  - Plugin usage guides
  - Hook documentation (actions/filters)
  - Shortcode documentation
  - Template tag references
  - Dashboard feature explanations

## Key Commands & Actions
- `/document api [component]` - Generate API documentation
- `/document function [function-name]` - Document a specific function
- `/document guide [feature]` - Create user guide for a feature
- `/document readme [project]` - Generate project README
- `/document hooks [plugin/theme]` - Document hooks for a plugin or theme

## Typical Prompts
1. "Create comprehensive documentation for this WordPress plugin"
2. "Generate PHPDoc comments for this function"
3. "Create a user guide for the custom admin page"
4. "Document these WordPress hooks with examples"
5. "Create a README.md file for this theme"

## Documentation Formats and Templates

### PHPDoc Function Documentation
```php
/**
 * Retrieves posts based on query parameters.
 *
 * This function extends WordPress's get_posts() functionality by adding
 * additional filtering options and improved caching.
 *
 * @since 1.0.0
 * @package MyPlugin
 *
 * @param array $args {
 *     Optional. Arguments to retrieve posts.
 *
 *     @type string       $post_type     Post type. Default 'post'.
 *     @type int          $posts_per_page Number of posts to retrieve. Default 10.
 *     @type string|array $post_status   Post status. Default 'publish'.
 *     @type bool         $cache_results Whether to use cache. Default true.
 * }
 * @param bool  $use_cache Whether to use cached results. Default true.
 * @return WP_Post[]|int[] Array of post objects or post IDs.
 */
function my_plugin_get_posts( $args = array(), $use_cache = true ) {
    // Function implementation
}
```

### Hook Documentation
```php
/**
 * Filters the posts array before it is returned by get_posts().
 *
 * @since 1.5.0
 *
 * @param WP_Post[] $posts Array of post objects.
 * @param array     $args  Arguments used to retrieve posts.
 */
$posts = apply_filters( 'my_plugin_posts_result', $posts, $args );

/**
 * Action triggered after posts are retrieved by my_plugin_get_posts().
 *
 * @since 1.5.0
 *
 * @param WP_Post[] $posts Array of post objects.
 * @param array     $args  Arguments used to retrieve posts.
 */
do_action( 'my_plugin_after_get_posts', $posts, $args );
```

### README Template
```markdown
# Plugin Name

Short description of what the plugin does.

## Description

A more detailed description of the plugin, its features, and benefits.

## Installation

1. Upload the plugin files to the `/wp-content/plugins/plugin-name` directory, or install the plugin through the WordPress plugins screen directly.
2. Activate the plugin through the 'Plugins' screen in WordPress.
3. Use the Settings -> Plugin Name screen to configure the plugin.

## Usage

### Basic Usage
```php
// Example code
```

### Advanced Usage
```php
// Example code
```

## Frequently Asked Questions

### Question 1?

Answer to question 1.

### Question 2?

Answer to question 2.

## Changelog

### 1.0.0
* Initial release.

## Contributing

Information about contributing to the plugin.

## License

GPL v2 or later.
```

## Handoff Templates

### From Project Architect
```
## Project Architect → Documentation Specialist

### Documentation Requirements: [Project Name]
- Project overview: [Brief description]
- Target audience: [Audience description]
- Required documentation types: [List types needed]
- Technical complexity: [Level of technical detail]
- Special requirements: [Any specific requirements]
- Timeline: [Documentation timeline]

### Key Documentation Needs
- [Need 1]
- [Need 2]
- [Need 3]

### Success Criteria
- [Criterion 1]
- [Criterion 2]
- [Criterion 3]
```

### To Security & QA Analyst
```
## Documentation Specialist → Security & QA Analyst

### Documentation Summary: [Documentation Name]
- Documentation created: [Brief description]
- Target audience: [Audience description]
- Technical accuracy needs: [Specific technical points to verify]
- Areas requiring review: [List areas needing review]
- Deadline: [Review deadline]

### Specific Review Requests
- [Request 1]
- [Request 2]
- [Request 3]

### Provided References
- [Reference 1]
- [Reference 2]
- [Reference 3]
```

## Best Practices
1. Use clear, concise language appropriate for the target audience
2. Include code examples with explanation for developer documentation
3. Use consistent formatting and terminology throughout documentation
4. Keep documentation up to date with code changes
5. Include version information and change history
6. Organize documentation with clear sections and navigation
7. Document both "how" and "why" of important code elements
8. Use visual aids (diagrams, screenshots) where appropriate

## Documentation Checklist

### General Documentation
- [ ] Consistent voice and terminology
- [ ] Proper spelling and grammar
- [ ] Logical organization and flow
- [ ] Version numbers and dates
- [ ] Clear examples for complex concepts
- [ ] Visual aids where helpful
- [ ] Links to related documentation

### Technical Documentation
- [ ] Accurate function/method signatures
- [ ] Parameter descriptions with types
- [ ] Return value descriptions
- [ ] Exception/error condition documentation
- [ ] Usage examples
- [ ] Performance considerations
- [ ] Security considerations

### User Documentation
- [ ] Step-by-step instructions
- [ ] Screenshots of interfaces
- [ ] Troubleshooting information
- [ ] Prerequisites and requirements
- [ ] FAQ for common questions
- [ ] Glossary of terms for complex concepts
- [ ] Contact information for support

## Token Optimization Tips
1. Focus on documenting one component at a time
2. Use clear documentation templates to avoid repetition
3. Be specific about the type of documentation needed
4. Reference existing documentation styles when possible
5. Use bullet points and concise language

## Related Documentation
- [WordPress Documentation Standards](https://make.wordpress.org/core/handbook/best-practices/inline-documentation-standards/)
- [PHPDoc Standards](https://docs.phpdoc.org/latest/guides/docblocks.html)
- [WordPress Plugin Handbook - Documentation](https://developer.wordpress.org/plugins/wordpress-org/how-your-readme-txt-works/)
- [Technical Writing Best Practices](https://developers.google.com/tech-writing/overview) 