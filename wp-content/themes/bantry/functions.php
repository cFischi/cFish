<?php
/**
 * Bantry functions and definitions
 *
 * @link https://developer.wordpress.org/themes/basics/template-hierarchy/
 *
 * @package WordPress
 * @subpackage Bantry
 * @since 1.0
 */

if ( ! function_exists( 'bantry_setup' ) ) :
	/**
	 * Sets up theme defaults and registers support for various WordPress features.
	 *
	 * Note that this function is hooked into the after_setup_theme hook, which
	 * runs before the init hook. The init hook is too late for some features, such
	 * as indicating support for post thumbnails.
	 */
	function bantry_setup() {

		// Add support for editor styles.
		add_theme_support( 'editor-styles' );

		// Enqueue editor styles.
		add_editor_style( 'variables.css' );

		// Editor color palette.
		$colors_theme_mod = get_theme_mod( 'custom_colors_active' );
		$primary          = ( ! empty( $colors_theme_mod ) && 'default' === $colors_theme_mod || empty( get_theme_mod( 'seedlet_--global--color-primary' ) ) ) ? '#000000' : get_theme_mod( 'seedlet_--global--color-primary' );
		$secondary        = ( ! empty( $colors_theme_mod ) && 'default' === $colors_theme_mod || empty( get_theme_mod( 'seedlet_--global--color-secondary' ) ) ) ? '#1a1a1a' : get_theme_mod( 'seedlet_--global--color-secondary' );
		$foreground       = ( ! empty( $colors_theme_mod ) && 'default' === $colors_theme_mod || empty( get_theme_mod( 'seedlet_--global--color-foreground' ) ) ) ? '#1a1a1a' : get_theme_mod( 'seedlet_--global--color-foreground' );
		$tertiary         = ( ! empty( $colors_theme_mod ) && 'default' === $colors_theme_mod || empty( get_theme_mod( 'seedlet_--global--color-tertiary' ) ) ) ? '#fafafa' : get_theme_mod( 'seedlet_--global--color-tertiary' );
		$background       = ( ! empty( $colors_theme_mod ) && 'default' === $colors_theme_mod || empty( get_theme_mod( 'seedlet_--global--color-background' ) ) ) ? '#ffffff' : get_theme_mod( 'seedlet_--global--color-background' );

		add_theme_support(
			'editor-color-palette',
			array(
				array(
					'name'  => __( 'Primary', 'bantry' ),
					'slug'  => 'primary',
					'color' => $primary,
				),
				array(
					'name'  => __( 'Secondary', 'bantry' ),
					'slug'  => 'secondary',
					'color' => $secondary,
				),
				array(
					'name'  => __( 'Foreground', 'bantry' ),
					'slug'  => 'foreground',
					'color' => $foreground,
				),
				array(
					'name'  => __( 'Tertiary', 'bantry' ),
					'slug'  => 'tertiary',
					'color' => $tertiary,
				),
				array(
					'name'  => __( 'Background', 'bantry' ),
					'slug'  => 'background',
					'color' => $background,
				),
			)
		);
	}
endif;
add_action( 'after_setup_theme', 'bantry_setup', 11 );

/**
 * Filter the colors for Bantry
 */
function bantry_colors() {
	return array(
		array( '--global--color-background', '#ffffff', __( 'Background Color', 'bantry' ) ),
		array( '--global--color-foreground', '#1a1a1a', __( 'Foreground Color', 'bantry' ) ),
		array( '--global--color-primary', '#000000', __( 'Primary Color', 'bantry' ) ),
		array( '--global--color-secondary', '#1a1a1a', __( 'Secondary Color', 'bantry' ) ),
		array( '--global--color-tertiary', '#fafafa', __( 'Tertiary Color', 'bantry' ) ),
	);
}
add_filter( 'seedlet_colors', 'bantry_colors' );

/**
 * Remove Seedlet theme features.
 */
function bantry_remove_parent_theme_features() {
	// Theme Support.
	remove_theme_support( 'custom-header' );
}
add_action( 'after_setup_theme', 'bantry_remove_parent_theme_features', 11 );

/**
 * Dequeue Seedlet scripts.
 */
function bantry_dequeue_parent_scripts() {
	if ( false === get_theme_mod( 'show_site_header', false ) ) {
		// Naviation assets.
		wp_dequeue_script( 'seedlet-primary-navigation-script' );
		wp_dequeue_style( 'seedlet-style-navigation' );
	}
}
add_action( 'wp_enqueue_scripts', 'bantry_dequeue_parent_scripts', 11 );

/**
 * Remove unused custmizer settings.
 */
function bantry_remove_customizer_settings( $wp_customize ) {

	// Remove Jetpack's Author Bio setting.
	if ( function_exists( 'jetpack_author_bio' ) ) {
		$wp_customize->remove_control( 'jetpack_content_author_bio_title' );
		$wp_customize->remove_control( 'jetpack_content_author_bio' );
	}

	// Remove Seedlet's header and footer hide options,
	// since they're already hidden by default.
	$wp_customize->remove_control( 'hide_site_header' );
	$wp_customize->remove_control( 'hide_site_footer' );
}
add_action( 'customize_register', 'bantry_remove_customizer_settings', 11 );

/**
 * Add custmizer settings.
 */
function bantry_add_customizer_settings( $wp_customize ) {

	// Cast the widgets panel as an object.
	$customizer_widgets_panel = (object) $wp_customize->get_panel( 'widgets' );

	$content_options_link = "wp.customize.control('show_site_header').focus(); return false;";

	// Add a Customizer message about the site title & tagline options.
	// translators: %s is an action which opens the "Content Options" section of customizer
	$wp_customize->get_section( 'title_tagline' )->description  = sprintf( __( 'The site logo, title, and tagline will only appear on all posts and pages if the "Site header and top menu" option is enabled in the <a href="#" onClick="%s">Content Options</a> section.', 'bantry' ), $content_options_link );
	$wp_customize->get_section( 'menu_locations' )->description = __( 'This theme will only display Menus if they are enabled in the Content Options section.', 'bantry' );
	$wp_customize->get_panel( 'nav_menus' )->description        = __( 'This theme will only display Menus if they are enabled in the Content Options section.', 'bantry' );
	$customizer_widgets_panel->description                      = __( 'This theme will only display Widgets if they are enabled in the Content Options section.', 'bantry' );
}
add_action( 'customize_register', 'bantry_add_customizer_settings', 11 );

/**
 * Remove Meta Footer Items.
 */
if ( ! function_exists( 'seedlet_entry_meta_footer' ) ) :
	/**
	 * Prints HTML with meta information for the categories, tags and comments.
	 */
	function seedlet_entry_meta_footer() {

		// Edit post link.
		edit_post_link(
			sprintf(
				wp_kses(
					/* translators: %s: Name of current post. Only visible to screen readers. */
					__( 'Edit <span class="screen-reader-text">%s</span>', 'bantry' ),
					array(
						'span' => array(
							'class' => array(),
						),
					)
				),
				get_the_title()
			),
			'<span class="edit-link">' . seedlet_get_icon_svg( 'edit', 16 ),
			'</span>'
		);
	}
endif;

/**
 * Enqueue scripts and styles.
 */
function bantry_enqueue() {
	wp_enqueue_style( 'bantry-styles', get_stylesheet_uri() );
}
add_action( 'wp_enqueue_scripts', 'bantry_enqueue', 11 );

/**
 * Block Patterns.
 */
require get_stylesheet_directory() . '/inc/block-patterns.php';

/**
 * Customizer additions.
 */
require get_stylesheet_directory() . '/inc/customizer.php';

/**
 * Adds custom classes to the array of body classes.
 *
 * @param array $classes Classes for the body element.
 * @return array
 */
function bantry_body_classes( $classes ) {

	if ( false === get_theme_mod( 'show_post_and_page_titles', false ) ) {
		$classes[] = 'hide-post-and-page-titles';
	}

	if ( false === get_theme_mod( 'show_site_footer', false ) ) {
		$classes[] = 'hide-site-footer';
	}

	if ( false === get_theme_mod( 'show_comments', false ) ) {
		$classes[] = 'hide-comments';
	}

	return $classes;
}
add_filter( 'body_class', 'bantry_body_classes' );
