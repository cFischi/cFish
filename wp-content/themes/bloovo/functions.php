<?php

/* Enqueue chlid theme scripts */
function bloovo_enqueue_script() {
  	$parent_style = 'parent-style';
  	wp_dequeue_style('bizcor-bloovo-main');
  	wp_enqueue_style('bloovo-style',get_stylesheet_directory_uri().'/style.css',$parent_style);
  	wp_dequeue_script('bizcor-custom');  	
  	wp_enqueue_script('bloovo-custom',get_stylesheet_directory_uri().'/js/custom.js');

  	// Setting in JS
	global $bizcor_options;
	$slider_speed = get_theme_mod('bizcor_slider_speed',$bizcor_options['bizcor_slider_speed']);
	$slider_animation_start = get_theme_mod('bizcor_slider_animation_start',$bizcor_options['bizcor_slider_animation_start']);
	$slider_animation_end = get_theme_mod('bizcor_slider_animation_end',$bizcor_options['bizcor_slider_animation_end']);

    $bizcor_settings = array(
        'homeUrl'     => home_url( '/' ),
		'slider_speed' => $slider_speed,
		'slider_animation_start' => $slider_animation_start,
		'slider_animation_end' => $slider_animation_end,
    );

	wp_localize_script('bloovo-custom','bizcor_settings',$bizcor_settings);
}
add_action( 'wp_enqueue_scripts' ,'bloovo_enqueue_script',99);

/* Overriding custom theme color scheme of parent theme. */
function bloovo_reset_data( $data ){
	$data['bizcor_theme_color'] = '#ff8514';
	$data['bizcor_transparent_logo'] = '';
	return $data;
}
add_filter('bizcor_default_data','bloovo_reset_data',999);

/* Removing old homepage sections */
function bloovo_remove_homepage_sections(){
	remove_action('bizcor_sections','bizcor_slider_section',5);
	remove_action('bizcor_sections','bizcor_info_section',10);
	remove_action('bizcor_sections','bizcor_service_section',15);
	remove_filter('bizcor_excerpt_more_output','bizcor_blog_read_more_button');
	remove_filter('bizcor_content_more_link_output','bizcor_blog_read_more_button');
	remove_action('bizcor_header','bizcor_header_section');
	remove_action('bizcor_header_navigation','bizcor_header_topbar_section', 5 );
	remove_action('bizcor_header_navigation','bizcor_header_navigation_section');
	remove_action('bizcor_header_navigation_after','bizcor_header_logo_section');
	remove_action('bizcor_header_inner_nav_wrap_after','bizcor_header_mobile_nav_section');
}
add_action('wp_head','bloovo_remove_homepage_sections');

// Header area
if( ! function_exists('bloovo_header_section') ){
	function bloovo_header_section(){
		get_template_part('template-parts/header/section','header');
	}
	add_action('bizcor_header','bloovo_header_section');
}

// Topbar
if( ! function_exists('bloovo_header_topbar_section') && function_exists('bc_init') ){
	function bloovo_header_topbar_section(){
		get_template_part('template-parts/header/section','topbar');
	}
	add_action('bizcor_header_navigation_before','bloovo_header_topbar_section', 5 );
}

// Navigation
if( ! function_exists('bloovo_header_navigation_section') ){
	function bloovo_header_navigation_section(){
		get_template_part('template-parts/header/section','navigation');
	}
	add_action('bizcor_header_navigation','bloovo_header_navigation_section');
}

// Logo
if( ! function_exists('bloovo_header_logo_section') ){
	function bloovo_header_logo_section(){
		get_template_part('template-parts/header/section','logo');
	}
	add_action('bizcor_header_navigation_inner_before','bloovo_header_logo_section');
}

// Mobile menu
if( ! function_exists('bloovo_header_mobile_nav_section') ){
	function bloovo_header_mobile_nav_section(){
		get_template_part('template-parts/header/section','mobile-menu');
	}
	add_action('bizcor_header_inner_nav_wrap_after','bloovo_header_mobile_nav_section');
}

/* Adding new chlid theme homepage sections */

// Slider Section
if( ! function_exists('bloovo_slider_section') && function_exists('bc_init') ){
	function bloovo_slider_section(){
		get_template_part('template-parts/sections-homepage/section','slider');
	}

	$section_priority = apply_filters( 'bizcor_section_priority', 5, 'bloovo_slider_section' );
	if(isset($section_priority) && $section_priority != '' ){
		add_action('bizcor_sections','bloovo_slider_section', absint($section_priority));
	}
}

// Info Section
if( ! function_exists('bloovo_info_section') && function_exists('bc_init') ){
	function bloovo_info_section(){
		get_template_part('template-parts/sections-homepage/section','info');
	}
	$section_priority = apply_filters( 'bizcor_section_priority', 10, 'bloovo_info_section' );
	if(isset($section_priority) && $section_priority != '' ){
		add_action('bizcor_sections','bloovo_info_section', absint($section_priority));
	}
}

// Service Section
if( ! function_exists('bloovo_service_section') && function_exists('bc_init') ){
	function bloovo_service_section(){
		get_template_part('template-parts/sections-homepage/section','service');
	}
	$section_priority = apply_filters( 'bizcor_section_priority', 15, 'bloovo_service_section' );
	if(isset($section_priority) && $section_priority != '' ){
		add_action('bizcor_sections','bloovo_service_section', absint($section_priority));
	}
}

function bloovo_blog_read_more_button( $output ) {
    $archive_readmore_button = true;
    $excerpt_readmore = sprintf(__('Read More','bloovo'));

    $class='';
    if($archive_readmore_button){
        $class = 'btn btn-primary theme_btn';
    }

    if ( !$archive_readmore_button ) {
        return $output;
    }

    return sprintf( '%5$s<p class="more-link-container mt-4 mb-2"><a title="%1$s" class="more-link %6$s" href="%2$s"><span>%3$s%4$s</span> <i class="fa fa-angle-right"></i></a></p>',
        the_title_attribute( 'echo=0' ),
        esc_url( get_permalink( get_the_ID() ) . apply_filters( 'bizcor_more_jump','#more-' . get_the_ID() ) ),
        wp_kses_post( $excerpt_readmore ),
        '<span class="screen-reader-text">' . get_the_title() . '</span>',
        'bizcor_excerpt_more_output' == current_filter() ? ' ... ' : '',
        esc_attr($class)
    );
}
add_filter( 'bizcor_excerpt_more_output', 'bloovo_blog_read_more_button' );
add_filter( 'bizcor_content_more_link_output', 'bloovo_blog_read_more_button' );

if ( ! function_exists( 'bloovo_transparent_logo' ) ) {
    function bloovo_transparent_logo(){
        $class = array();
        $html = '';

        global $bizcor_options;
        $logo = get_theme_mod('bizcor_transparent_logo',$bizcor_options['bizcor_transparent_logo']);
        
        if ( function_exists( 'has_custom_logo' ) ) {
            if ( has_custom_logo()) {
                $html .= get_custom_logo();

                if($logo!=''){
	            	$html = '<a href="'.esc_url( home_url( '/' ) ).'" rel="home"><img src="'.esc_url($logo).'" class="custom-logo"></a>';
	            }

            }else{
                $html .= '<h1 class="site_title"><a href="'.esc_url( home_url( '/' ) ).'" rel="home">' . get_bloginfo('name') . '</a></h1>';
                
                $description = get_bloginfo( 'description', 'display' );
                if ( $description || is_customize_preview() ) {
                    $html .= '<p class="site_desc">'.$description.'</p>';
                }
            }
        }
        ?>
        <div class="site_logo sticky_logo <?php echo esc_attr( join( ' ', $class ) ); ?>"><?php echo wp_kses_post($html); ?></div>
        <?php
    }
}

// Include customizer file
get_template_part('inc/customizer/customizer');