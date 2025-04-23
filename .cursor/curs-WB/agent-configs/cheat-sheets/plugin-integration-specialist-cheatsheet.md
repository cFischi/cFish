# Plugin Integration Specialist Quick Reference Cheat Sheet

## Core Responsibilities
- Evaluate plugins for security, performance, and compatibility
- Implement and configure third-party plugins
- Customize plugin functionality to meet project requirements
- Resolve plugin conflicts and integration issues
- Develop extensions and add-ons for plugins
- Ensure proper data migration between plugins
- Maintain plugin updates and security

## Common Tasks
- **Plugin Evaluation**
  - Security assessment
  - Performance impact analysis
  - Code quality evaluation
  - Feature compatibility verification
  - Support and maintenance evaluation
  - License compliance verification
  
- **Plugin Implementation**
  - Installation and activation
  - Configuration optimization
  - Custom field mapping
  - Template customization
  - Shortcode implementation
  - Widget placement and configuration

- **Plugin Customization**
  - Functionality extension
  - Hook implementation (actions/filters)
  - Template overrides
  - Custom endpoint creation
  - Admin interface customization
  - Integration with other plugins

## Key Commands & Actions
- `/plugin evaluate [plugin-name]` - Perform plugin evaluation
- `/plugin implement [plugin-name]` - Generate implementation plan
- `/plugin customize [feature]` - Design customization for a feature
- `/plugin conflict [plugins]` - Resolve conflict between plugins
- `/plugin extend [plugin-name]` - Create plugin extension or add-on

## Typical Prompts
1. "Evaluate WooCommerce for this e-commerce project"
2. "Implement and configure Yoast SEO for optimal performance"
3. "Customize Contact Form 7 to include file uploads and custom validation"
4. "Resolve conflict between WooCommerce and another plugin"
5. "Create an extension for Advanced Custom Fields to add custom field types"

## WordPress Plugin Integration Patterns

### Plugin Evaluation Framework
```
# Plugin Evaluation Checklist

## Basic Information
- Plugin Name: [Name]
- Current Version: [Version]
- WordPress Compatibility: [WP Versions]
- PHP Compatibility: [PHP Versions]
- Developer/Company: [Developer]
- Support Options: [Options]
- License: [License Type]
- Cost: [Cost Structure]

## Security Assessment
- Code Quality Rating: [1-5]
- Recent Security Issues: [Yes/No - Details]
- Vulnerability History: [Details]
- Authentication Handling: [Assessment]
- Data Sanitization Practices: [Assessment]
- Third-party Dependency Security: [Assessment]

## Performance Impact
- Database Impact: [Low/Medium/High]
- Frontend Impact: [Low/Medium/High]
- Admin Dashboard Impact: [Low/Medium/High]
- Asset Loading Approach: [Assessment]
- Caching Implementation: [Assessment]
- Query Efficiency: [Assessment]

## Feature Assessment
- Required Features Present: [Yes/No - Details]
- Feature Quality Rating: [1-5]
- Customization Options: [Limited/Moderate/Extensive]
- Integration Capabilities: [Assessment]
- Extension Ecosystem: [Assessment]
- Documentation Quality: [Assessment]

## Recommendation
- Overall Rating: [1-5]
- Recommendation: [Recommend/Conditional/Do Not Recommend]
- Concerns: [List Concerns]
- Alternatives: [List Alternatives]
```

### Plugin Hook Implementation
```php
/**
 * Customizes the behavior of Example Plugin.
 *
 * Implements custom hooks to modify the plugin's functionality
 * to meet specific project requirements.
 *
 * @package ThemeName
 */

/**
 * Modifies the output of Example Plugin's shortcode.
 *
 * @param string $output The shortcode output.
 * @param array  $atts   The shortcode attributes.
 * @return string Modified shortcode output.
 */
function custom_modify_example_plugin_shortcode( $output, $atts ) {
    // Customization code here
    
    return $output;
}
add_filter( 'example_plugin_shortcode_output', 'custom_modify_example_plugin_shortcode', 10, 2 );

/**
 * Adds custom options to Example Plugin's settings page.
 *
 * @param array $options The current plugin options.
 * @return array Modified plugin options.
 */
function custom_add_example_plugin_options( $options ) {
    $options['custom_option'] = [
        'label'   => __( 'Custom Option', 'text-domain' ),
        'type'    => 'text',
        'default' => '',
    ];
    
    return $options;
}
add_filter( 'example_plugin_options', 'custom_add_example_plugin_options' );

/**
 * Executes custom code after Example Plugin processes a form.
 *
 * @param array $form_data The processed form data.
 * @param int   $form_id   The ID of the processed form.
 */
function custom_after_example_plugin_form_process( $form_data, $form_id ) {
    // Custom action code here
}
add_action( 'example_plugin_after_form_process', 'custom_after_example_plugin_form_process', 10, 2 );
```

### Plugin Template Override
```php
/**
 * Plugin Template Override Example
 *
 * 1. Create a folder in your theme: /theme-name/example-plugin/
 * 2. Copy the template file from the plugin to your theme folder
 * 3. Modify the template as needed
 * 4. The plugin should automatically use your template version
 */

// Alternative method: Filter to change template path
function custom_example_plugin_template_path( $template_path, $template_name ) {
    // Check if we want to override this specific template
    if ( 'specific-template.php' === $template_name ) {
        // Return custom template path
        return get_stylesheet_directory() . '/custom-templates/' . $template_name;
    }
    
    return $template_path;
}
add_filter( 'example_plugin_template_path', 'custom_example_plugin_template_path', 10, 2 );
```

## Handoff Templates

### From Project Architect
```
## Project Architect → Plugin Integration Specialist

### Plugin Requirements: [Project Name]
- Project overview: [Brief description]
- Required functionality: [List key functionality]
- Integration constraints: [List constraints]
- Performance requirements: [Performance expectations]
- Security considerations: [Security requirements]
- Budget constraints: [Budget for plugins]

### Key Plugin Functionality
- [Functionality 1]
- [Functionality 2]
- [Functionality 3]

### Success Criteria
- [Criterion 1]
- [Criterion 2]
- [Criterion 3]
```

### To Code Implementation Specialist
```
## Plugin Integration Specialist → Code Implementation Specialist

### Plugin Integration Summary: [Plugin Name]
- Plugin implemented: [Plugin name and version]
- Customizations required: [List customizations]
- Integration points: [List integration points]
- Hook details: [Describe hooks to use]
- Templates modified: [List modified templates]
- Known limitations: [List limitations]

### Implementation Guidelines
- [Guideline 1]
- [Guideline 2]
- [Guideline 3]

### Custom Code Required
- [Code requirement 1]
- [Code requirement 2]
- [Code requirement 3]
```

## Plugin Integration Checklist

### Pre-Implementation
- [ ] Perform thorough plugin evaluation
- [ ] Check compatibility with WordPress version
- [ ] Verify compatibility with other installed plugins
- [ ] Review plugin documentation and support
- [ ] Assess performance impact on the site
- [ ] Identify necessary customizations
- [ ] Create backup of the site

### Implementation
- [ ] Install plugin in development environment first
- [ ] Configure plugin settings according to requirements
- [ ] Implement necessary customizations
- [ ] Test all plugin functionality
- [ ] Test plugin integration with other components
- [ ] Optimize plugin performance
- [ ] Document implementation and customizations

### Post-Implementation
- [ ] Verify plugin functions as expected
- [ ] Confirm plugin meets all requirements
- [ ] Check for any unexpected side effects
- [ ] Document maintenance procedures
- [ ] Set up plugin update protocol
- [ ] Train client/team on plugin usage
- [ ] Create troubleshooting guide for common issues

## Common Plugin Categories

### Content Management
- Advanced Custom Fields
- Custom Post Type UI
- Pods
- Toolset

### E-Commerce
- WooCommerce
- Easy Digital Downloads
- WP eCommerce
- BigCommerce

### SEO & Performance
- Yoast SEO
- SEOPress
- WP Rocket
- W3 Total Cache

### Forms & User Interaction
- Contact Form 7
- Gravity Forms
- WPForms
- Formidable Forms

### Security
- Wordfence
- Sucuri
- iThemes Security
- Shield Security

## Best Practices
1. Always evaluate plugins before recommending or implementing
2. Prefer plugins with regular updates and good support
3. Check security history and code quality before implementation
4. Use hooks and filters rather than modifying plugin files directly
5. Create plugin template overrides in the theme when needed
6. Test plugin updates in a staging environment before applying to production
7. Document all customizations and configuration settings
8. Keep the number of plugins to a minimum to maintain performance

## Token Optimization Tips
1. Specify precisely which plugin and version you're working with
2. Clearly state the customization requirements
3. Mention any known conflicts or issues to address
4. Provide context about the website's purpose and audience
5. Reference specific plugin features or shortcodes in your request

## Related Documentation
- [WordPress Plugin Handbook](https://developer.wordpress.org/plugins/)
- [WordPress Plugin Directory](https://wordpress.org/plugins/)
- [WordPress Plugin Development Standards](https://developer.wordpress.org/plugins/wordpress-org/detailed-plugin-guidelines/)
- [WP Plugin Security Guide](https://developer.wordpress.org/plugins/security/) 