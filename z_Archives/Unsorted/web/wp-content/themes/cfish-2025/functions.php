<?php
/**
 * CFish 2025 Theme Functions
 *
 * @package CFish_2025
 */

// Exit if accessed directly
if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

// Define theme constants
define( 'CFISH_THEME_VERSION', '1.0.0' );
define( 'CFISH_THEME_DIR', get_template_directory() );
define( 'CFISH_THEME_URI', get_template_directory_uri() );

/**
 * Theme setup function
 */
function cfish_2025_setup() {
	// Add default posts and comments RSS feed links to head
	add_theme_support( 'automatic-feed-links' );

	// Let WordPress manage the document title
	add_theme_support( 'title-tag' );

	// Enable support for Post Thumbnails on posts and pages
	add_theme_support( 'post-thumbnails' );

	// Set default thumbnail size
	set_post_thumbnail_size( 1200, 630, true );

	// Register navigation menus
	register_nav_menus(
		array(
			'primary' => esc_html__( 'Primary Menu', 'cfish-2025' ),
			'footer'  => esc_html__( 'Footer Menu', 'cfish-2025' ),
			'social'  => esc_html__( 'Social Menu', 'cfish-2025' ),
		)
	);

	// Switch default core markup to output valid HTML5
	add_theme_support(
		'html5',
		array(
			'search-form',
			'comment-form',
			'comment-list',
			'gallery',
			'caption',
			'style',
			'script',
		)
	);

	// Set up the WordPress core custom background feature
	add_theme_support(
		'custom-background',
		apply_filters(
			'cfish_2025_custom_background_args',
			array(
				'default-color' => 'ffffff',
				'default-image' => '',
			)
		)
	);

	// Add theme support for selective refresh for widgets
	add_theme_support( 'customize-selective-refresh-widgets' );

	// Add support for custom logo
	add_theme_support(
		'custom-logo',
		array(
			'height'      => 250,
			'width'       => 250,
			'flex-width'  => true,
			'flex-height' => true,
		)
	);

	// Add support for full and wide align images
	add_theme_support( 'align-wide' );

	// Add support for editor styles
	add_theme_support( 'editor-styles' );

	// Add support for responsive embeds
	add_theme_support( 'responsive-embeds' );
}
add_action( 'after_setup_theme', 'cfish_2025_setup' );

/**
 * Set the content width in pixels, based on the theme's design and stylesheet.
 *
 * Priority 0 to make it available to lower priority callbacks.
 *
 * @global int $content_width
 */
function cfish_2025_content_width() {
	$GLOBALS['content_width'] = apply_filters( 'cfish_2025_content_width', 1200 );
}
add_action( 'after_setup_theme', 'cfish_2025_content_width', 0 );

/**
 * Register widget area.
 */
function cfish_2025_widgets_init() {
	register_sidebar(
		array(
			'name'          => esc_html__( 'Sidebar', 'cfish-2025' ),
			'id'            => 'sidebar-1',
			'description'   => esc_html__( 'Add widgets here.', 'cfish-2025' ),
			'before_widget' => '<section id="%1$s" class="widget %2$s">',
			'after_widget'  => '</section>',
			'before_title'  => '<h2 class="widget-title">',
			'after_title'   => '</h2>',
		)
	);

	register_sidebar(
		array(
			'name'          => esc_html__( 'Footer 1', 'cfish-2025' ),
			'id'            => 'footer-1',
			'description'   => esc_html__( 'First footer widget area', 'cfish-2025' ),
			'before_widget' => '<div id="%1$s" class="widget %2$s">',
			'after_widget'  => '</div>',
			'before_title'  => '<h3 class="widget-title">',
			'after_title'   => '</h3>',
		)
	);

	register_sidebar(
		array(
			'name'          => esc_html__( 'Footer 2', 'cfish-2025' ),
			'id'            => 'footer-2',
			'description'   => esc_html__( 'Second footer widget area', 'cfish-2025' ),
			'before_widget' => '<div id="%1$s" class="widget %2$s">',
			'after_widget'  => '</div>',
			'before_title'  => '<h3 class="widget-title">',
			'after_title'   => '</h3>',
		)
	);

	register_sidebar(
		array(
			'name'          => esc_html__( 'Footer 3', 'cfish-2025' ),
			'id'            => 'footer-3',
			'description'   => esc_html__( 'Third footer widget area', 'cfish-2025' ),
			'before_widget' => '<div id="%1$s" class="widget %2$s">',
			'after_widget'  => '</div>',
			'before_title'  => '<h3 class="widget-title">',
			'after_title'   => '</h3>',
		)
	);
}
add_action( 'widgets_init', 'cfish_2025_widgets_init' );

/**
 * Enqueue scripts and styles.
 */
function cfish_2025_scripts() {
	// Enqueue Google Fonts
	wp_enqueue_style(
		'cfish-2025-fonts',
		'https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700&family=Roboto+Mono&family=Roboto:wght@400;500;700&display=swap',
		array(),
		CFISH_THEME_VERSION
	);

	// Enqueue main stylesheet
	wp_enqueue_style(
		'cfish-2025-style',
		get_stylesheet_uri(),
		array(),
		CFISH_THEME_VERSION
	);

	// Enqueue custom scripts
	wp_enqueue_script(
		'cfish-2025-navigation',
		CFISH_THEME_URI . '/js/navigation.js',
		array(),
		CFISH_THEME_VERSION,
		true
	);

	// Enqueue custom scripts for mobile menu
	wp_enqueue_script(
		'cfish-2025-mobile-menu',
		CFISH_THEME_URI . '/js/mobile-menu.js',
		array( 'jquery' ),
		CFISH_THEME_VERSION,
		true
	);

	if ( is_singular() && comments_open() && get_option( 'thread_comments' ) ) {
		wp_enqueue_script( 'comment-reply' );
	}
}
add_action( 'wp_enqueue_scripts', 'cfish_2025_scripts' );

/**
 * Implement the Custom Header feature.
 */
require get_template_directory() . '/inc/custom-header.php';

/**
 * Custom template tags for this theme.
 */
require get_template_directory() . '/inc/template-tags.php';

/**
 * Functions which enhance the theme by hooking into WordPress.
 */
require get_template_directory() . '/inc/template-functions.php';

/**
 * Customizer additions.
 */
require get_template_directory() . '/inc/customizer.php';

/**
 * Load Jetpack compatibility file.
 */
if ( defined( 'JETPACK__VERSION' ) ) {
	require get_template_directory() . '/inc/jetpack.php';
}

/**
 * Add custom image sizes
 */
function cfish_2025_add_image_sizes() {
	add_image_size( 'cfish-featured', 1200, 630, true );
	add_image_size( 'cfish-thumbnail', 600, 400, true );
	add_image_size( 'cfish-square', 400, 400, true );
}
add_action( 'after_setup_theme', 'cfish_2025_add_image_sizes' );

/**
 * Filter the except length to 20 words.
 *
 * @param int $length Excerpt length.
 * @return int (Maybe) modified excerpt length.
 */
function cfish_2025_excerpt_length( $length ) {
	return 20;
}
add_filter( 'excerpt_length', 'cfish_2025_excerpt_length', 999 );

/**
 * Filter the excerpt "read more" string.
 *
 * @param string $more "Read more" excerpt string.
 * @return string (Maybe) modified "read more" excerpt string.
 */
function cfish_2025_excerpt_more( $more ) {
	return '&hellip; <a class="read-more" href="' . esc_url( get_permalink() ) . '">' . esc_html__( 'Read More', 'cfish-2025' ) . '</a>';
}
add_filter( 'excerpt_more', 'cfish_2025_excerpt_more' );

/**
 * Add custom classes to the body class
 */
function cfish_2025_body_classes( $classes ) {
	// Add a class if there is a custom header
	if ( get_header_image() ) {
		$classes[] = 'has-custom-header';
	}

	// Add a class if sidebar is used
	if ( is_active_sidebar( 'sidebar-1' ) ) {
		$classes[] = 'has-sidebar';
	} else {
		$classes[] = 'no-sidebar';
	}

	return $classes;
}
add_filter( 'body_class', 'cfish_2025_body_classes' );

/**
 * Create js directories and placeholder files to ensure they exist in git
 */
function cfish_2025_create_js_files() {
    $js_dir = get_template_directory() . '/js';
    if (!file_exists($js_dir)) {
        mkdir($js_dir, 0755);
    }
    
    $navigation_file = $js_dir . '/navigation.js';
    if (!file_exists($navigation_file)) {
        file_put_contents($navigation_file, "/**\n * Navigation related JavaScript\n */\n");
    }
    
    $mobile_menu_file = $js_dir . '/mobile-menu.js';
    if (!file_exists($mobile_menu_file)) {
        file_put_contents($mobile_menu_file, "/**\n * Mobile menu JavaScript\n */\n");
    }
}
add_action('after_setup_theme', 'cfish_2025_create_js_files'); 