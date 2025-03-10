<?php
if( ! function_exists('bizcor_enqueue_scripts') ):
	function bizcor_enqueue_scripts(){
		$theme = wp_get_theme( 'bizcor' );
	    $version = $theme->get( 'Version' );
		wp_enqueue_style('bizcor-fonts', bizcor_fonts_url(), array(), $version);

		// CSS files
		wp_enqueue_style('bootstrap-all',get_template_directory_uri().'/assets/css/all.min.css');
		wp_enqueue_style('animate',get_template_directory_uri().'/assets/css/animate.min.css');
		wp_enqueue_style('bootstrap-min',get_template_directory_uri().'/assets/css/bootstrap.min.css');
		wp_enqueue_style('classic-menu',get_template_directory_uri().'/assets/css/classic-menu.css');
		wp_enqueue_style('bizcor-editor-style',get_template_directory_uri().'/assets/css/editor-style.css');
		wp_enqueue_style('owl-carousel',get_template_directory_uri().'/assets/css/owl.carousel.min.css');
		wp_enqueue_style('bizcor-main',get_template_directory_uri().'/assets/css/main.css');
		wp_enqueue_style('bizcor-bloovo-main',get_template_directory_uri().'/assets/css/bloovo-main.css');
		wp_enqueue_style('bizcor-widgets',get_template_directory_uri().'/assets/css/widgets.css');
		wp_enqueue_style('bizcor-responsive',get_template_directory_uri().'/assets/css/responsive.css');
		wp_enqueue_style('bizcor-woo',get_template_directory_uri().'/assets/css/woo.css');
		wp_enqueue_style('bizcor-style',get_stylesheet_uri());

		// JS files
		wp_enqueue_script( 'jquery' );
		wp_enqueue_script('bootstrap-min',get_template_directory_uri().'/assets/js/bootstrap.min.js',array('jquery'),false,true);
		wp_enqueue_script('owl-carousel',get_template_directory_uri().'/assets/js/owl.carousel.min.js','',false,true);
		wp_enqueue_script('wow-min',get_template_directory_uri().'/assets/js/wow.min.js','',false,true);
		wp_enqueue_script('bizcor-theme-min',get_template_directory_uri().'/assets/js/theme.min.js','',false,true);
		wp_enqueue_script('bizcor-custom',get_template_directory_uri().'/assets/js/custom.min.js','',false,true);

		if ( is_singular() && comments_open() && get_option( 'thread_comments' ) ) {
			wp_enqueue_script( 'comment-reply' );
		}

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

		wp_localize_script('bizcor-custom','bizcor_settings',$bizcor_settings);
	}
	add_action( 'wp_enqueue_scripts', 'bizcor_enqueue_scripts' );
endif;

if( ! function_exists('bizcor_admin_enqueue_scripts') ):
	function bizcor_admin_enqueue_scripts(){
		wp_enqueue_style('bizcor-admin', get_template_directory_uri() . '/assets/css/admin.css');

		wp_enqueue_script( 'bizcor-admin-script', get_template_directory_uri() . '/assets/js/bizcor-admin-script.min.js', array( 'jquery' ), '', true );

		wp_localize_script( 'bizcor-admin-script', 'bizcor_ajax_object',
	        array( 'ajax_url' => admin_url( 'admin-ajax.php' ) )
	    );
	}
	add_action( 'admin_enqueue_scripts', 'bizcor_admin_enqueue_scripts' );
endif;