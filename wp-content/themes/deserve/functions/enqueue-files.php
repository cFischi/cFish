<?php 
/*
 * deserve Enqueue css and js files
*/
function deserve_enqueue()
{
	wp_enqueue_style( 'deserve-google-fonts-QuickSand', '//fonts.googleapis.com/css?family=Quicksand', array(), '1.0.0' );
	wp_enqueue_style('deserve-bootstrap',get_template_directory_uri().'/css/bootstrap.css',array());
	wp_enqueue_style('style',get_stylesheet_uri(),array());
	wp_enqueue_style('deserve-font-awesome',get_template_directory_uri().'/css/font-awesome.css',array());
	
	wp_enqueue_script('deserve-bootstrapjs',get_template_directory_uri().'/js/bootstrap.js',array('jquery'));
	    

	if ( is_singular() ) wp_enqueue_script( "comment-reply" ); 
}
add_action('wp_enqueue_scripts', 'deserve_enqueue');


function deserve_admin_enqueue() {
   	wp_enqueue_style('deserve-custom-css',get_template_directory_uri().'/css/custom.css',array());
    
}
add_action( 'admin_print_styles-widgets.php', 'deserve_admin_enqueue' );
