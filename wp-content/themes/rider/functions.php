<?php 
/*
 * Set up the content width value based on the theme's design.
 */
if ( ! function_exists( 'rider_setup' ) ) :
function rider_setup() {
	
	// This theme uses wp_nav_menu() in two locations.
	register_nav_menus( array(
		'primary'   => __( 'Main Menu', 'rider' ),	
	) );
	
	if ( ! isset( $content_width ) ) $content_width = 770;
		/*
		 * Make rider theme available for translation.
		 */

	load_theme_textdomain( 'rider', get_template_directory() . '/languages' );
	// This theme styles the visual editor to resemble the theme style.
	add_editor_style(array('css/editor-style.css', rider_font_url()));
	// Add RSS feed links to <head> for posts and comments.
	add_theme_support('automatic-feed-links');
	add_theme_support( 'title-tag' );
	add_theme_support('post-thumbnails');
	
	set_post_thumbnail_size(672, 372, true);
	add_image_size('rider-full-width', 1110, 576, true);
	add_image_size('rider-blog-image', 710, 470, true);
	add_image_size('rider-blog-one', 772, 515, true);
	add_image_size('rider-blog-two', 372, 245, true);
	
	/*        
	* Switch default core markup for search form, comment form, and comments        
	* to output valid HTML5.        
	*/
	add_theme_support('html5', array(
	   'search-form', 'comment-form', 'comment-list',
	));
	
	add_theme_support( 'custom-header', apply_filters( 'rider_custom_header_args', array(
		'uploads'       => true,
		'flex-height'   => true,
		'default-text-color' => '#fff',
		'header-text' => true,
		'height' => '120',
		'width'  => '1260'
 	) ) );

 	add_theme_support( 'custom-logo',array(
        'height'      => 250,
        'width'       => 250,
        'flex-width'  => true,
        'flex-height' => true,
        'priority' => 11,     
        'header-text' => array('img-responsive-logo', 'site-description-logo'),
    ) );
	add_theme_support( 'custom-background', apply_filters( 'rider_custom_background_args', array(
		'default-color' => 'f5f5f5',
	) ) );
	
	// Add support for featured content.
	add_theme_support('featured-content', array(
	   'featured_content_filter' => 'rider_get_featured_posts',
	   'max_posts' => 6,
	));
	
	// This theme uses its own gallery styles.       
	add_filter('use_default_gallery_style', '__return_false');
}

endif; // rider_setup
add_action( 'after_setup_theme', 'rider_setup' );

/*** Enqueue css and js files ***/
function rider_enqueue()
{
	wp_enqueue_style('rider-google-fonts-opensans','//fonts.googleapis.com/css?family=Open Sans',array());
	wp_enqueue_style('bootstrap',get_template_directory_uri().'/css/bootstrap.css',array());
	wp_enqueue_style('font-awesome',get_template_directory_uri().'/css/font-awesome.css',array());
	wp_enqueue_style('rider-default',get_template_directory_uri().'/css/default.css',array(),NULL,false);
	wp_enqueue_style('rider-style',get_stylesheet_uri(),array());
	
	wp_enqueue_script('bootstrap',get_template_directory_uri().'/js/bootstrap.js',array('jquery')); 
	wp_enqueue_script('rider-defaultjs',get_template_directory_uri().'/js/default.js',array('jquery'),NULL,false);

	if ( is_singular() ) wp_enqueue_script( "comment-reply" ); 

	rider_custom_css();
}

add_action('wp_enqueue_scripts', 'rider_enqueue');

add_action( 'admin_menu', 'rider_admin_menu');
function rider_admin_menu( ) {
    add_theme_page( __('Pro Feature','rider'), __('Rider Pro','rider'), 'manage_options', 'rider-pro-buynow', 'rider_buy_now', 300 );   
}
function rider_buy_now(){ ?>
<div class="rider_pro_version">
  <a href="<?php echo esc_url('https://fasterthemes.com/wordpress-themes/riderpro/'); ?>" target="_blank">    
    <img src ="<?php echo esc_url(get_template_directory_uri()); ?>/images/rider_pro_features.png" width="70%" height="auto" />
  </a>
</div>
<?php
}
/**Remove ? from JS and CSS**/
function rider_remove_cssjs_ver( $src ) {
    if( strpos( $src, '?ver=' ) )
        $src = remove_query_arg( 'ver', $src );
    return $src;
}
add_filter( 'style_loader_src', 'rider_remove_cssjs_ver', 10, 2 );
add_filter( 'script_loader_src', 'rider_remove_cssjs_ver', 10, 2 );

add_filter('get_custom_logo','rider_change_logo_class');
function rider_change_logo_class($html)
{
  $html = str_replace('class="custom-logo"', 'class="img-responsive logo-fixed"', $html);
  $html = str_replace('width=', 'original-width=', $html);
  $html = str_replace('height=', 'original-height=', $html);
  $html = str_replace('class="custom-logo-link"', 'class="img-responsive logo-fixed"', $html);
  return $html;
}
// retrieves the attachment ID from the file URL
function rider_get_image_id($image_url) {
    global $wpdb;
    $rider_attachment = $wpdb->get_col($wpdb->prepare("SELECT ID FROM $wpdb->posts WHERE guid='%s';", $image_url )); 
        return (empty($rider_attachment))?0:$rider_attachment[0]; 
}
/*** Theme Default Setup ***/
require get_template_directory() . '/inc/theme-default-setup.php';
/*** Breadcrumbs ***/
require get_template_directory() . '/inc/breadcrumbs.php';
/*** Customizer option ***/
require get_template_directory() . '/inc/customizer.php'; ?>