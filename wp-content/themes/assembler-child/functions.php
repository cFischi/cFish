<?php
/**
 * Assembler Child Theme functions and definitions
 */

// Enqueue parent theme styles
function assembler_child_enqueue_styles() {
    wp_enqueue_style('assembler-style', get_template_directory_uri() . '/style.css');
    wp_enqueue_style('assembler-child-style', get_stylesheet_directory_uri() . '/style.css', array('assembler-style'));
}
add_action('wp_enqueue_scripts', 'assembler_child_enqueue_styles');

// Customize the footer
function assembler_child_customize_footer() {
    // We'll use template_redirect to modify the footer for block themes
    if (is_singular() || is_archive() || is_home() || is_front_page()) {
        add_filter('render_block', 'assembler_child_modify_footer_block', 10, 2);
    }
}
add_action('template_redirect', 'assembler_child_customize_footer');

// Function to modify the footer block content
function assembler_child_modify_footer_block($block_content, $block) {
    // Only target the paragraph that contains "Designed with WordPress"
    if ($block['blockName'] === 'core/paragraph' && 
        strpos($block_content, 'Designed with') !== false &&
        strpos($block_content, 'WordPress') !== false) {
        
        // Replace with our custom text
        $block_content = str_replace(
            'Designed with <a href="https://wordpress.org" rel="nofollow">WordPress</a>',
            'Made with ❤️ by <a href="https://cfisch.io" style="font-weight:bold;color:red;">cFish.io</a>',
            $block_content
        );
    }
    
    return $block_content;
} 