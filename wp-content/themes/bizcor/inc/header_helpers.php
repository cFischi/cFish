<?php
if( ! function_exists('bizcor_header_section') ){
	function bizcor_header_section(){
		get_template_part('template-parts/header/section','header');
	}
	add_action('bizcor_header','bizcor_header_section');
}

if( ! function_exists('bizcor_header_navigation_section') ){
	function bizcor_header_navigation_section(){
		get_template_part('template-parts/header/section','navigation');
	}
	add_action('bizcor_header_navigation','bizcor_header_navigation_section');
}

if( ! function_exists('bizcor_header_logo_section') ){
	function bizcor_header_logo_section(){
		get_template_part('template-parts/header/section','logo');
	}
	add_action('bizcor_header_navigation_after','bizcor_header_logo_section');
}

if( ! function_exists('bizcor_header_mobile_nav_section') ){
	function bizcor_header_mobile_nav_section(){
		get_template_part('template-parts/header/section','mobile-menu');
	}
	add_action('bizcor_header_inner_nav_wrap_after','bizcor_header_mobile_nav_section');
}