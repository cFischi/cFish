<?php

if( ! function_exists('bizcor_footer_section') ){
	function bizcor_footer_section(){
		get_template_part('template-parts/footer/section','footer');
	}
	add_action('bizcor_footer','bizcor_footer_section');
}

if( ! function_exists('bizcor_footer_newsletter_section') ){
	function bizcor_footer_newsletter_section(){
		get_template_part('template-parts/footer/section','newsletter');
	}
	add_action('bizcor_footer_inner_before','bizcor_footer_newsletter_section');
}

if( ! function_exists('bizcor_footer_widget_section') ){
	function bizcor_footer_widget_section(){
		get_template_part('template-parts/footer/section','widget');
	}
	add_action('bizcor_footer_main','bizcor_footer_widget_section');
}

if( ! function_exists('bizcor_footer_copyright_section') ){
	function bizcor_footer_copyright_section(){
		get_template_part('template-parts/footer/section','copyright');
	}
	add_action('bizcor_footer_main','bizcor_footer_copyright_section');
}

if( ! function_exists('bizcor_footer_backtotop_section') ){
	function bizcor_footer_backtotop_section(){
		get_template_part('template-parts/footer/section','backTotop');
	}
	add_action('bizcor_footer_inner_after','bizcor_footer_backtotop_section');
}