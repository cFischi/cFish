<?php 
/**
 * Template Name: Home Page
 *
 * @link https://developer.wordpress.org/themes/basics/theme-functions/
 *
 * @package WordPress
 * @subpackage Bizcor
 * 
 * @since Bizcor 0.1
 */
if ( is_page_template() ) {
	get_header();
	if( !function_exists('bc_init') ){
		get_template_part('template-parts/section-breadcrumbs');
	}
		do_action('bizcor_sections',false);

	get_footer();
}
?>