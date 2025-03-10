<?php
/**
 * Bizcor theme functions and definitions
 *
 * @link https://developer.wordpress.org/themes/basics/theme-functions/
 *
 * @package WordPress
 * @subpackage Bizcor
 * 
 * @since Bizcor 0.1
 */

// Creating some of the theme constant variables here
$bizcor_theme = wp_get_theme();
define( 'BIZCOR_THEME_DIR', get_template_directory() );
define( 'BIZCOR_THEME_URI', get_template_directory_uri() );
define( 'BIZCOR_THEME_NAME', $bizcor_theme->get('Name') );
define( 'BIZCOR_THEME_VERSION', $bizcor_theme->get('Version') );

if( ! function_exists( 'bizcor_setup' ) ):
	/**
	 * Sets up theme defaults and registers support for various WordPress features.
	 *
	 * @since Bizcor 0.1
	 *
	 * @return void
	 */
	function bizcor_setup() {	
		// Defining a text domain name for the theme
		load_theme_textdomain('bizcor');
		
		// Supporting automatic feed links here
		add_theme_support('automatic-feed-links');
		
		// Supporting WordPress "Title" tags here
		add_theme_support('title-tag');

        // WooCommerce Plugin Support
		add_theme_support( 'woocommerce' );
		
		// Supporting "Pages" and "Excerpt" here
		add_post_type_support('page','excerpt');
		
		// Supporting "Featured Images" for the pages here
		add_theme_support('post-thumbnails');

		// Supporting References Supports
		add_theme_support( 'wp-block-styles');
		add_theme_support( 'responsive-embeds');
		add_theme_support( 'register_block_style');
		add_theme_support( 'register_block_pattern');
		add_theme_support( 'align-wide' );

		// Setup global content-width here
		global $content_width;
		
		if ( ! isset( $content_width ) ) {
			$content_width = 800;
		}
		
		// Registering primary navigation area here
		register_nav_menus( array(
			'primary' => esc_html__('Primary Menu','bizcor'),
		) );
		
		// Supporting HTML5 tags on the following theme parts
		add_theme_support('html5',array(
			'search-form',
			'comment-form',
			'comment-list',
			'gallery',
			'caption',
		) );
		
		// Enqueue editor styles for the theme
		add_editor_style( array('assets/css/editor-style.css', bizcor_fonts_url() ) );
		
		// Adding a custom logo image here
		add_theme_support('custom-logo',array(
			'height'      => 73,
			'width'       => 210,
			'flex-height' => true,
			'flex-width'  => true,
		) );
		
		// Adding a custom header image here
		$args = array(
			'width'        => 1600,
			'flex-width'   => true,
			'default-image'=> get_template_directory_uri() . '/img/sub-header.jpg',
			'header-text'  => false,
		);
		add_theme_support( 'custom-header', $args );

		// Custom background theme supports
		add_theme_support( 'custom-background' );
		
		// Supporting following plugins for adding advanced theme features
		add_theme_support( 'recommend-plugins', array(
			'britetechs-companion' => array(
				'name' => esc_html__( 'Britetechs Companion', 'bizcor' ),
				'active_filename' => 'britetechs-companion/britetechs-companion.php',
				'desc' => esc_html__( 'We highly recommend that you install the britetechs companion plugin to gain access to the team and testimonial sections.', 'bizcor' ),
			),
			'contact-form-7' => array(
				'name' => esc_html__( 'Contact Form 7', 'bizcor' ),
				'active_filename' => 'contact-form-7/wp-contact-form-7.php',
			),
		) );
		
		// Adding selective refresh feature in the theme
		add_theme_support( 'customize-selective-refresh-widgets' );
		
		/*
		 * Enable support for Post Formats.
		 *
		 * See: https://codex.wordpress.org/Post_Formats
		 */
		add_theme_support( 'post-formats', array(
			'aside',
			'image',
			'video',
			'quote',
			'link',
			'gallery',
			'audio',
		) );

		// load starter Content.
		add_theme_support( 'starter-content', bizcor_wp_starter_pack() );
	}
	add_action( 'after_setup_theme', 'bizcor_setup' );
endif;

if ( ! function_exists( 'bizcor_fonts_url' ) ) :
	/**
	 * Enqueue google fonts.
	 *
	 * @since Bizcor 0.1
	 *
	 * @return void
	 */
	function bizcor_fonts_url() {
		global $bizcor_options;

		$fonts_url = '';
		$Inter = _x( 'on', 'Inter font: on or off', 'bizcor' );

		if ( 'off' !== $Inter ) {

			$font_families = array();
			if ( 'off' !== $Inter ) {
				$font_families[] = 'Inter:100,200,300,400,500,600,700,800,900,italic';
			}

			$sections = array(
				'body',
				'h1',
				'h2',
				'h3',
				'h4',
				'h5',
				'h6',
			);

			foreach( $sections as $section ){
				$font = get_theme_mod('bizcor_'.$section.'_font');
				if(isset($font) && $font != '' ){
					$font_families[] = $font.':100,200,300,400,500,600,700,800,900,italic';
				}				 
			}
			
			$subset = 'latin';
			$query_args = array(
				'family' => urlencode( implode( '|', $font_families ) ),
				'subset' => urlencode( $subset ),
			);
			$fonts_url = add_query_arg( $query_args, '//fonts.googleapis.com/css?family=' );
		}
		return esc_url_raw( $fonts_url );
	}
endif;

if( ! function_exists('bizcor_widgets_register') ):
	/**
	 * Registering theme widgets.
	 *
	 * @since Bizcor 0.1
	 *
	 * @return void
	 */
	function bizcor_widgets_register(){
		register_sidebar( array(
			'name'          => esc_html__('Primary Sidebar','bizcor'),
			'id'            => 'sidebar-1',
			'description'   => 'This sidebar contents will be show on the blog archive pages.',
			'before_widget' => '<div id="%1$s" class="widget %2$s">',
			'after_widget'  => '</div>',
			'before_title'  => '<h5 class="widget-title">',
			'after_title'   => '</h5>',
		) );
		
		for ( $i = 1; $i<= 4; $i++ ) {
			register_sidebar( array(
				'name'          => sprintf( __('Footer %s','bizcor'), $i ),
				'id'            => 'footer-' . $i,
				'description'   => 'This sidebar contents will be show in the footer '.$i.' column area.',
				'before_widget' => '<div id="%1$s" class="widget %2$s">',
				'after_widget'  => '</div>',
				'before_title'  => '<h5 class="widget-title">',
				'after_title'   => '</h5>',
			) );
		}

		register_sidebar( array(
			'name'          => __('WooCommerce Sidebar','bizcor'),
			'id'            => 'woocommerce',
			'description'   => __('This Widget area for WooCommerce Widget','bizcor'),
			'before_widget' => '<aside id="%1$s" class="widget %2$s">',
			'after_widget'  => '</aside>',
			'before_title'  => '<h5 class="widget-title">',
			'after_title'   => '</h5>',
		) );
	}
	add_action('widgets_init','bizcor_widgets_register');
endif;

// Include css and js files
require get_template_directory() . '/inc/enqueue.php';

// Include default data file
require get_template_directory() . '/inc/default_data.php';

// Include helpers functions files
require get_template_directory() . '/inc/header_helpers.php';
require get_template_directory() . '/inc/footer_helpers.php';
require get_template_directory() . '/inc/sections_helpers.php';
require get_template_directory() . '/inc/blog_helpers.php';

// Include nav walker file
require get_template_directory() . '/inc/theme_nav_walker.php';

// Include template tags file
require get_template_directory() . '/inc/template_tags.php';

// Include dynamic css files
require get_template_directory() . '/inc/class-frontend-css.php';
require get_template_directory() . '/inc/css_output.php';

// Include customizer file
require get_template_directory() . '/inc/customizer/customizer.php';

// Include customizer recommanded plugins files
require get_parent_theme_file_path('/inc/customizer/install/class-install-helper.php');
require get_parent_theme_file_path('/inc/customizer/install/customizer_recommended_plugin.php');