# Theme Development Specialist Quick Reference Cheat Sheet

## Core Responsibilities
- Design and develop WordPress themes
- Create responsive layouts for all device types
- Implement theme customization options
- Ensure proper integration with WordPress core
- Maintain compatibility with popular plugins
- Optimize themes for performance and accessibility

## Common Tasks
- **Theme Architecture**
  - Template hierarchy implementation
  - Theme structure organization
  - Template parts creation
  - Theme functions setup
  - Block theme foundations

- **Front-End Development**
  - Responsive CSS implementation
  - JavaScript enhancements
  - CSS preprocessor utilization
  - Asset optimization
  - Accessibility compliance

- **WordPress Integration**
  - Theme hooks and filters
  - Customizer API implementation
  - Block editor integration
  - Navigation menus setup
  - Widget areas registration

## Key Commands & Actions
- `/theme structure [theme-name]` - Generate theme directory structure
- `/theme template [template-name]` - Create a specific template file
- `/theme part [part-name]` - Design a reusable template part
- `/theme customizer [feature]` - Implement customizer controls
- `/theme block [block-name]` - Create block theme support

## Typical Prompts
1. "Create a responsive header template part for [theme]"
2. "Implement customizer settings for [feature]"
3. "Design a mobile-friendly navigation menu with dropdown support"
4. "Create block theme templates for archive, single, and page"
5. "Optimize theme assets for better performance"

## WordPress-Specific Implementation Patterns

### Template Part Structure
```php
<?php
/**
 * Template Part: Header
 *
 * @package ThemeName
 */

// Get custom options
$logo = get_theme_mod( 'custom_logo' );
$tagline_display = get_theme_mod( 'display_tagline', true );
?>

<header id="masthead" class="site-header">
    <div class="container">
        <div class="site-branding">
            <?php if ( has_custom_logo() ) : ?>
                <div class="site-logo"><?php the_custom_logo(); ?></div>
            <?php else : ?>
                <h1 class="site-title"><a href="<?php echo esc_url( home_url( '/' ) ); ?>"><?php bloginfo( 'name' ); ?></a></h1>
                <?php if ( $tagline_display && get_bloginfo( 'description' ) ) : ?>
                    <p class="site-description"><?php bloginfo( 'description' ); ?></p>
                <?php endif; ?>
            <?php endif; ?>
        </div>

        <nav id="site-navigation" class="main-navigation">
            <?php
            wp_nav_menu(
                array(
                    'theme_location' => 'primary',
                    'menu_id'        => 'primary-menu',
                    'container'      => false,
                    'menu_class'     => 'menu-wrapper',
                )
            );
            ?>
        </nav>
    </div>
</header>
```

### Customizer Implementation
```php
/**
 * Add customizer settings and controls
 *
 * @param WP_Customize_Manager $wp_customize Theme Customizer object.
 */
function themename_customize_register( $wp_customize ) {
    // Add a section
    $wp_customize->add_section( 'theme_header_options', array(
        'title'       => __( 'Header Options', 'themename' ),
        'priority'    => 30,
        'description' => __( 'Customize header elements', 'themename' ),
    ) );

    // Add a setting
    $wp_customize->add_setting( 'display_tagline', array(
        'default'           => true,
        'sanitize_callback' => 'themename_sanitize_checkbox',
        'transport'         => 'refresh',
    ) );

    // Add a control
    $wp_customize->add_control( 'display_tagline', array(
        'label'    => __( 'Display Site Tagline', 'themename' ),
        'section'  => 'theme_header_options',
        'type'     => 'checkbox',
    ) );
}
add_action( 'customize_register', 'themename_customize_register' );

// Sanitize function
function themename_sanitize_checkbox( $checked ) {
    return ( ( isset( $checked ) && true == $checked ) ? true : false );
}
```

### Block Theme Template Structure
```php
<?php
/**
 * Template Name: Full Width
 * Template Post Type: post, page
 *
 * @package ThemeName
 */

get_header();
?>

<main id="primary" class="site-main full-width">

    <?php
    while ( have_posts() ) :
        the_post();

        get_template_part( 'template-parts/content/content', 'page' );

        // If comments are open or we have at least one comment, load up the comment template.
        if ( comments_open() || get_comments_number() ) :
            comments_template();
        endif;

    endwhile; // End of the loop.
    ?>

</main><!-- #main -->

<?php
get_footer();
```

## Handoff Templates

### From Project Architect
```
## Project Architect → Theme Development Specialist

### Theme Specification: [Theme Name]
- Design requirements: [List key requirements]
- Visual style guide: [Brief style description]
- Implementation constraints: [List constraints]
- Required templates: [List required templates]
- Core functionality: [Describe core functionality]
- Mobile breakpoints: [List breakpoints]

### Key Theme Requirements
- [Requirement 1]
- [Requirement 2]
- [Requirement 3]

### Success Criteria
- [Criterion 1]
- [Criterion 2]
- [Criterion 3]
```

### To Code Implementation Specialist
```
## Theme Development Specialist → Code Implementation Specialist

### Theme Integration Details: [Feature Name]
- Theme hooks available: [List available hooks]
- Template structure: [Brief structure description]
- Style guidelines: [Describe style requirements]
- CSS classes to use: [List key CSS classes]
- JavaScript integration: [Describe JS integration points]
- Template parts available: [List template parts]

### Integration Guidelines
- [Guideline 1]
- [Guideline 2]
- [Guideline 3]

### Expected Output
- [Expected output 1]
- [Expected output 2]
- [Expected output 3]
```

## Best Practices
1. Follow WordPress theme development standards
2. Use proper escaping for all output (`esc_html`, `esc_url`, etc.)
3. Implement responsive design from mobile first
4. Keep theme functions modular and well-documented
5. Register and enqueue styles and scripts properly
6. Implement theme features using WordPress core functions
7. Test themes on multiple browsers and devices
8. Validate HTML and CSS according to standards

## Token Optimization Tips
1. Break theme development into focused components
2. Request one template or template part at a time
3. Reference WordPress theme development documentation instead of explaining basics
4. Specify responsive breakpoints clearly
5. Reuse CSS patterns across components for consistency

## Related Documentation
- [WordPress Theme Handbook](https://developer.wordpress.org/themes/)
- [Theme Development Standards](https://developer.wordpress.org/coding-standards/wordpress-coding-standards/)
- [Block Theme Development Guide](https://developer.wordpress.org/block-editor/how-to-guides/themes/block-theme-overview/)
- [Customizer API Documentation](https://developer.wordpress.org/themes/customize-api/) 