<?php

// Blog
if( ! function_exists('bizcor_blog_section') ){
	function bizcor_blog_section(){
		get_template_part('template-parts/sections-homepage/section','blog');
	}
	$section_priority = apply_filters( 'bizcor_section_priority', 50, 'bizcor_blog_section' );
	if(isset($section_priority) && $section_priority != '' ){
		add_action('bizcor_sections','bizcor_blog_section', absint($section_priority));
	}
}