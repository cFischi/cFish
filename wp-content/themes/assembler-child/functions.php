<?php
/**
 * Assembler Child Theme functions and definitions
 */

// Enqueue parent and child theme stylesheets
function assembler_child_enqueue_styles() {
    // Parent theme stylesheet
    wp_enqueue_style( 'assembler-style', get_template_directory_uri() . '/style.css' );
    
    // Child theme stylesheet
    wp_enqueue_style( 'assembler-child-style',
        get_stylesheet_directory_uri() . '/style.css',
        array( 'assembler-style' ),
        wp_get_theme()->get('Version')
    );
}
add_action( 'wp_enqueue_scripts', 'assembler_child_enqueue_styles' );

// No need for the filter-based footer customization as we're using a 
// complete footer.html file in the parts directory that will automatically
// override the parent theme's footer through WordPress's template hierarchy 