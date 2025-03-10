<?php
/**
 * Storefront Child Theme functions and definitions
 */

// Enqueue parent theme styles
function storefront_child_enqueue_styles() {
    wp_enqueue_style('parent-style', get_template_directory_uri() . '/style.css');
    wp_enqueue_style('child-style', get_stylesheet_directory_uri() . '/style.css', array('parent-style'));
}
add_action('wp_enqueue_scripts', 'storefront_child_enqueue_styles');

// Custom footer credit - our simple but noticeable change
function storefront_child_footer_credit() {
    ?>
    <div class="site-info">
        <?php echo esc_html('&copy; ' . get_bloginfo('name') . ' ' . gmdate('Y')); ?>
        <br />
        <span style="color: #e74c3c; font-weight: bold;">Made with ❤️ by cFish.io</span>
    </div><!-- .site-info -->
    <?php
}

// Remove parent theme footer credit and add our custom one
function storefront_child_remove_footer_credit() {
    remove_action('storefront_footer', 'storefront_credit', 20);
    add_action('storefront_footer', 'storefront_child_footer_credit', 20);
}
add_action('init', 'storefront_child_remove_footer_credit'); 