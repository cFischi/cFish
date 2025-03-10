<?php
/**
 * Theme functions and definitions
 *
 * @link https://developer.wordpress.org/themes/basics/theme-functions/
 *
 * @package WordPress
 * @subpackage ExS
 * @since 1.0.0
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit; // Exit if accessed directly
}

//load parent CSS
if ( ! function_exists( 'exs_music_enqueue_static' ) ) :
	/**
	 * exs_music_enqueue_static
	 *
	 * @return void
	 * @since 1.0.0
	 */
	function exs_music_enqueue_static() {

		$min = exs_option( 'assets_min' ) && ! EXS_DEV_MODE ? 'min/' : '';
		//main theme css file
		wp_enqueue_style( 'exs-music-style', get_stylesheet_directory_uri() . '/assets/css/' . $min . 'main.css', array( 'exs-style' ), wp_get_theme()->get( 'Version' ) );

		if ( function_exists( 'exs_extra_enqueue_static' ) ) {
			return;
		}

		//custom Google fonts css file and inline styles if option is enabled
		$exs_font_body     = json_decode( exs_option( 'font_body', '{"font":"","variant": [],"subset":[]}' ) );
		$exs_font_headings = json_decode( exs_option( 'font_headings', '{"font":"","variant": [],"subset":[]}' ) );
		if ( ! empty( $exs_font_body->font ) || ! empty( $exs_font_headings->font ) ) {
			/*
			Translators: If there are characters in your language that are not supported
			by chosen font(s), translate this to 'off'. Do not translate into your own language.
			*/

			if ( 'off' !== esc_html_x( 'on', 'Google font: on or off', 'exs-music' ) ) {
				$exs_body_subsets  = array();
				$exs_font_body_font = '';
				if (!empty($exs_font_body->font)) {
					$exs_font_body_font = $exs_font_body->font;
					if ( ! empty( $exs_font_body->variant ) ) {
						$exs_font_body->font .= ':'. implode( ',', $exs_font_body->variant );
					}
					$exs_body_subsets  = $exs_font_body->subset;
				}

				$exs_headings_subsets  = array();
				$exs_font_headings_font = '';
				if (!empty($exs_font_headings->font)) {
					$exs_font_headings_font = $exs_font_headings->font;
					if ( ! empty( $exs_font_headings->variant ) ) {
						$exs_font_headings->font .= ':'. implode( ',', $exs_font_headings->variant );
					}
					$exs_headings_subsets  = $exs_font_headings->subset;
				}

				$exs_fonts    = array(
					'body'     => $exs_font_body->font,
					'headings' => $exs_font_headings->font,
				);
				$exs_subsets  = array(
					'body'     => implode(',', $exs_body_subsets),
					'headings' => implode(',', $exs_headings_subsets),
				);
				//'Montserrat|Bowlby One|Quattrocento Sans';
				$exs_fonts_string    = implode('|', array_filter($exs_fonts));
				$exs_subsets_string  = implode(',', array_filter($exs_subsets));

				$exs_query_args = array(
					'family' => urlencode( $exs_fonts_string ),
				);
				if (!empty($exs_subsets_string)) {
					$exs_query_args['subset'] = urlencode( $exs_subsets_string );
				}
				$exs_query_args['display']='swap';
				$exs_font_url = add_query_arg(
					$exs_query_args,
					'//fonts.googleapis.com/css'
				);

				//no need to provide anew version for Google fonts link - exs-style added to load it before google fonts style
				wp_enqueue_style( 'exs-google-fonts-style', $exs_font_url, array( 'exs-style' ), '1.0.0' );

				//printing header styles
				$exs_body_style = ( ! empty( $exs_font_body_font ) ) ? 'body,button,input,select,textarea{font-family:"' . $exs_font_body_font . '",sans-serif}' : '';

				$exs_headings_style = ( ! empty( $exs_font_headings_font ) ) ? 'h1,h2,h3,h4,h5,h6{font-family: "' . $exs_font_headings_font . '",sans-serif}' : '';

				wp_add_inline_style(
					'exs-google-fonts-style',
					wp_kses(
						$exs_body_style . $exs_headings_style,
						false
					)
				);
			}
		}
	}
endif;
add_action( 'wp_enqueue_scripts', 'exs_music_enqueue_static', 20 );


//theme options
if ( ! function_exists( 'exs_music_default_options' ) ) :
	function exs_music_default_options() {
		return array(
			'demo_number' => '',
			'colors_palette_block_heading' => '',
			'colorLight' => '#0a0a0a',
			'colorFont' => '#d8d8d8',
			'colorFontMuted' => '#aaaaaa',
			'colorBackground' => '#161616',
			'colorBorder' => '#3a3a3a',
			'colorDark' => '#dbdbdb',
			'colorDarkMuted' => '#ffffff',
			'colorMain' => '#ea7e9b',
			'colorMain2' => '#2a99c1',
			'colorMain3' => '#e678f5',
			'colorMain4' => '#7892f5',
			'colors_theme_elements_block_heading' => '',
			'color_meta_icons' => 'meta-icons-main2',
			'color_meta_text' => 'meta-icons-main',
			'color_links_menu' => '',
			'color_links_menu_hover' => '',
			'color_links_content' => 'i c',
			'color_links_content_hover' => 'i c c2',
			'intro_block_heading' => '',
			'intro_position' => '',
			'intro_layout' => '',
			'intro_fullscreen' => '',
			'intro_background' => '',
			'intro_alignment' => 'text-center',
			'intro_extra_padding_top' => 'pt-5',
			'intro_extra_padding_bottom' => 'pb-5',
			'intro_show_search' => '',
			'intro_font_size' => '',
			'intro_background_image_heading' => '',
			'intro_background_image' => '',
			'intro_image_animation' => 'zoomIn',
			'intro_background_image_cover' => '1',
			'intro_background_image_fixed' => '1',
			'intro_background_image_overlay' => '',
			'intro_background_image_overlay_opacity' => '',
			'intro_section_content_heading' => '',
			'intro_heading' => '',
			'intro_heading_mt' => '',
			'intro_heading_mb' => '',
			'intro_heading_animation' => 'fadeInUp',
			'intro_description' => '',
			'intro_description_mt' => '',
			'intro_description_mb' => '',
			'intro_description_animation' => 'fadeInUp',
			'intro_button_text_first' => '',
			'intro_button_url_first' => '',
			'intro_button_first_animation' => 'fadeInUp',
			'intro_button_text_second' => '',
			'intro_button_url_second' => '',
			'intro_button_second_animation' => 'fadeInUp',
			'intro_buttons_mt' => '',
			'intro_buttons_mb' => '',
			'intro_shortcode' => '',
			'intro_shortcode_mt' => '',
			'intro_shortcode_mb' => '',
			'intro_shortcode_animation' => '',
			'intro_teasers_block_heading' => '',
			'intro_teaser_section_layout' => '',
			'intro_teaser_section_background' => '',
			'intro_teaser_section_padding_top' => 'pt-5',
			'intro_teaser_section_padding_bottom' => 'pb-5',
			'intro_teaser_font_size' => '',
			'intro_teaser_layout' => 'text-center',
			'intro_teaser_heading' => '',
			'intro_teaser_description' => '',
			'logo' => '3',
			'logo_text_primary' => '',
			'logo_text_primary_fs' => '24',
			'logo_text_primary_fs_xl' => '',
			'logo_text_primary_hidden' => '',
			'logo_text_secondary' => '',
			'logo_text_secondary_fs' => '24',
			'logo_text_secondary_fs_xl' => '',
			'logo_text_secondary_hidden' => '',
			'header_top_tall' => '1',
			'logo_background' => '',
			'logo_padding_horizontal' => '',
			'logo_width_zero' => '',
			'skins_extra' => '',
			'main_container_width' => '1140',
			'blog_container_width' => '',
			'blog_single_container_width' => '720',
			'search_container_width' => '',
			'preloader' => '',
			'widgets_ul_margin' => '1.5',
			'box_fade_in' => '',
			'assets_lightbox' => '1',
			'assets_min' => '1',
			'post_thumbnails_fullwidth' => '',
			'post_thumbnails_centered' => '',
			'assets_main_nob' => '',
			'assets_nob' => '',
			'remove_widgets_block_editor' => '',
			'remove_wp_default_duotone_svg' => '1',
			'buttons_main_heading' => '',
			'buttons_uppercase' => '1',
			'buttons_bold' => '1',
			'buttons_colormain' => '1',
			'buttons_outline' => '',
			'buttons_big' => '',
			'buttons_radius' => 'btns-rounded',
			'buttons_fs' => '12',
			'buttons_burger_heading' => '',
			'button_burger' => '5',
			'buttons_pagination_heading' => '',
			'buttons_pagination' => '2',
			'buttons_social_heading' => '',
			'buttons_social' => '3',
			'buttons_social_gap' => '',
			'buttons_totop_heading' => '',
			'totop' => '5',
			'meta_email' => '',
			'meta_email_label' => '',
			'meta_phone' => '',
			'meta_phone_label' => '',
			'meta_address' => '',
			'meta_address_label' => '',
			'meta_opening_hours' => '',
			'meta_opening_hours_label' => '',
			'meta_facebook' => '',
			'meta_twitter' => '',
			'meta_youtube' => '',
			'meta_instagram' => '',
			'meta_pinterest' => '',
			'meta_linkedin' => '',
			'meta_github' => '',
			'meta_tiktok' => '',
			'side_extra' => '',
			'header_image_background_image_inverse' => '',
			'header_image_background_image_cover' => '1',
			'header_image_background_image_fixed' => '1',
			'header_image_background_image_overlay' => '',
			'header_image_background_image_overlay_opacity' => '',
			'header_menu_options_heading_desktop' => '',
			'header_align_main_menu' => 'menu-center',
			'header_menu_uppercase' => '',
			'header_menu_bold' => '',
			'menu_desktop' => '',
			'header_menu_options_heading_mobile' => '',
			'header_toggler_menu_main' => '1',
			'header_toggler_menu_main_center' => '1',
			'menu_breakpoint' => '5000',
			'mobile_nav_width' => '320',
			'mobile_nav_px' => '40',
			'menu_mobile' => '6',
			'menu_mobile_show_logo' => '1',
			'menu_mobile_show_search' => '1',
			'menu_mobile_show_meta' => '1',
			'menu_mobile_show_social' => '1',
			'bottom_nav_height' => '',
			'bottom_nav_background' => '',
			'bottom_nav_border' => '',
			'bottom_nav_shadow' => '',
			'bottom_nav_font_size' => '',
			'bottom_nav_bold' => '',
			'bottom_nav_uppercase' => '',
			'bottom_nav_show_social' => '',
			'bottom_nav_icons_heading' => '',
			'bottom_nav_icons_center' => '',
			'bottom_nav_icon_labels_hidden' => '',
			'fixed_sidebar_breakpoint' => '',
			'fixed_sidebar_width' => '380',
			'fixed_sidebar_px' => '50',
			'fixed_sidebar_background' => 'i m',
			'fixed_sidebar_border' => '',
			'fixed_sidebar_shadow' => '',
			'fixed_sidebar_font_size' => '',
			'header' => '6',
			'header_logo_hidden' => 'hidden',
			'header_fluid' => '',
			'header_background' => 'l',
			'header_absolute' => '',
			'header_transparent' => '',
			'header_border_top' => '',
			'header_border_bottom' => '',
			'header_font_size' => '',
			'header_sticky' => 'scrolltop-sticky',
			'header_login_links' => '',
			'header_login_links_hidden' => '',
			'header_search' => '',
			'header_search_hidden' => '',
			'header_button_text' => '',
			'header_button_url' => '',
			'header_button_hidden' => '',
			'header_toplogo_options_heading' => '',
			'header_toplogo_background' => 'l',
			'header_toplogo_hidden' => '',
			'header_toplogo_social_hidden' => 'hidden',
			'header_toplogo_meta_hidden' => 'hidden',
			'header_toplogo_search_hidden' => 'hidden',
			'header_topline_options_heading' => '',
			'topline' => '',
			'topline_fluid' => '1',
			'topline_background' => 'i c gradient diagonal',
			'meta_topline_text' => '',
			'topline_font_size' => 'fs-14',
			'topline_login_links' => '',
			'topline_disable_dropdown' => '',
			'header_bottom' => '',
			'header_bottom_layout_gap' => '',
			'header_bottom_fluid' => '',
			'header_bottom_background' => '',
			'header_bottom_border_top' => '',
			'header_bottom_border_bottom' => '',
			'header_bottom_extra_padding_top' => 'pb-1',
			'header_bottom_extra_padding_bottom' => '',
			'header_bottom_font_size' => '',
			'header_bottom_background_image_heading' => '',
			'header_bottom_background_image' => '',
			'header_bottom_background_image_cover' => '',
			'header_bottom_background_image_fixed' => '',
			'header_bottom_background_image_overlay' => '',
			'header_bottom_background_image_overlay_opacity' => '',
			'header_bottom_hide_widget_titles' => '1',
			'header_bottom_lists_inline' => '1',
			'header_bottom_hidden' => '',
			'title' => '5',
			'title_fluid' => '',
			'title_show_title' => '1',
			'title_show_breadcrumbs' => '1',
			'title_show_search' => '',
			'title_background' => '',
			'title_border_top' => '',
			'title_border_bottom' => '',
			'title_extra_padding_top' => 'pt-4',
			'title_extra_padding_bottom' => 'pb-7',
			'title_font_size' => 'fs-14',
			'title_hide_taxonomy_name' => '',
			'title_background_image_heading' => '',
			'title_background_image' => '',
			'title_background_image_cover' => '1',
			'title_background_image_fixed' => '1',
			'title_background_image_overlay' => '',
			'title_background_image_overlay_opacity' => '',
			'title_single_post_meta_heading' => '',
			'title_blog_single_hide_meta_icons' => '',
			'title_blog_single_show_author' => '1',
			'title_blog_single_show_author_avatar' => '1',
			'title_blog_single_before_author_word' => '',
			'title_blog_single_show_date' => '1',
			'title_blog_single_before_date_word' => '',
			'title_blog_single_show_human_date' => '',
			'title_blog_single_show_categories' => '1',
			'title_blog_single_before_categories_word' => '',
			'title_blog_single_show_tags' => '1',
			'title_blog_single_before_tags_word' => '',
			'title_blog_single_show_comments_link' => '',
			'main_sidebar_width' => '25',
			'main_gap_width' => '4',
			'main_sidebar_sticky' => '1',
			'main_extra_padding_top' => '',
			'main_extra_padding_bottom' => 'pb-5',
			'main_font_size' => '',
			'sidebar_font_size' => 'fs-14',
			'main_sidebar_widgets_heading' => '',
			'main_sidebar_widgets_title_uppercase' => '',
			'main_sidebar_widgets_title_bold' => '1',
			'main_sidebar_widgets_title_decor' => '',
			'footer_top' => '',
			'footer_top_content_heading_text' => '',
			'footer_top_image' => '',
			'footer_top_pre_heading' => '',
			'footer_top_pre_heading_mt' => '',
			'footer_top_pre_heading_mb' => '',
			'footer_top_pre_heading_animation' => '',
			'footer_top_heading' => '',
			'footer_top_heading_mt' => '',
			'footer_top_heading_mb' => '',
			'footer_top_heading_animation' => '',
			'footer_top_description' => '',
			'footer_top_description_mt' => '',
			'footer_top_description_mb' => '',
			'footer_top_description_animation' => '',
			'footer_top_shortcode' => '',
			'footer_top_shortcode_mt' => '',
			'footer_top_shortcode_mb' => '',
			'footer_top_shortcode_animation' => '',
			'footer_top_options_heading_text' => '',
			'footer_top_fluid' => '',
			'footer_top_background' => '',
			'footer_top_border_top' => '',
			'footer_top_border_bottom' => '',
			'footer_top_extra_padding_top' => '',
			'footer_top_extra_padding_bottom' => '',
			'footer_top_font_size' => '',
			'footer_top_background_image' => '',
			'footer_top_background_image_cover' => '',
			'footer_top_background_image_fixed' => '',
			'footer_top_background_image_overlay' => '',
			'footer_top_background_image_overlay_opacity' => '',
			'footer' => '1',
			'footer_layout_gap' => '30',
			'footer_fluid' => '',
			'footer_background' => '',
			'footer_border_top' => '',
			'footer_border_bottom' => '',
			'footer_extra_padding_top' => 'pt-5',
			'footer_extra_padding_bottom' => 'pb-1',
			'footer_font_size' => 'fs-14',
			'footer_background_image_heading' => '',
			'footer_background_image' => '',
			'footer_background_image_cover' => '1',
			'footer_background_image_fixed' => '1',
			'footer_background_image_overlay' => '',
			'footer_background_image_overlay_opacity' => '',
			'footer_widgets_heading' => '',
			'footer_sidebar_widgets_title_uppercase' => '',
			'footer_sidebar_widgets_title_bold' => '1',
			'footer_sidebar_widgets_title_decor' => '',
			'copyright' => '4',
			'copyright_text' => '© [year] - All rights reserved',
			'copyright_fluid' => '',
			'copyright_background' => '',
			'copyright_extra_padding_top' => 'pt-1',
			'copyright_extra_padding_bottom' => 'pb-1',
			'copyright_font_size' => 'fs-12',
			'copyright_background_image_heading' => '',
			'copyright_background_image' => '',
			'copyright_background_image_cover' => '',
			'copyright_background_image_fixed' => '',
			'copyright_background_image_overlay' => '',
			'copyright_background_image_overlay_opacity' => '',
			'theme_icons' => 'ionic-filled',
			'typo_body_heading' => '',
			'typo_body_size' => '',
			'typo_body_weight' => '',
			'typo_body_line_height' => '',
			'typo_body_letter_spacing' => '0.05',
			'typo_p_margin_bottom' => '',
			'font_body_extra' => '',
			'infinite_loop_extra' => '',
			'share_buttons_extra' => '',
			'blog_layout' => 'meta-above-title 2',
			'blog_layout_gap' => '30',
			'blog_featured_image_size' => '',
			'blog_sidebar_position' => 'right',
			'blog_page_name' => 'News',
			'blog_show_full_text' => '',
			'blog_excerpt_length' => '20',
			'blog_read_more_text' => '',
			'blog_read_more_style' => '',
			'blog_read_more_block' => '',
			'blog_hide_taxonomy_type_name' => '',
			'blog_meta_options_heading' => '',
			'blog_hide_meta_icons' => '1',
			'blog_show_author' => '1',
			'blog_show_author_avatar' => '1',
			'blog_before_author_word' => '',
			'blog_show_date' => '1',
			'blog_before_date_word' => '',
			'blog_show_human_date' => '1',
			'blog_show_categories' => '1',
			'blog_before_categories_word' => '',
			'blog_show_tags' => '',
			'blog_before_tags_word' => '',
			'blog_show_comments_link' => 'number',
			'blog_show_date_over_image' => '',
			'blog_show_categories_over_image' => '',
			'blog_single_layout' => 'wide-image',
			'blog_single_featured_image_size' => '',
			'blog_single_sidebar_position' => 'no',
			'blog_single_first_embed_featured' => '',
			'blog_single_fullwidth_featured' => '',
			'blog_single_show_author_bio' => '1',
			'blog_single_author_bio_about_word' => '',
			'blog_single_post_nav_heading' => '',
			'blog_single_post_nav' => 'bg',
			'blog_single_post_nav_word_prev' => 'Previous Post',
			'blog_single_post_nav_word_next' => 'Next Post',
			'blog_single_related_posts_heading' => '',
			'blog_single_related_posts' => 'grid-3',
			'blog_single_related_posts_title' => 'You may also like',
			'blog_single_related_posts_number' => '3',
			'blog_single_related_posts_image_size' => 'exs-square',
			'blog_single_related_posts_base' => 'author',
			'blog_single_related_show_date' => '1',
			'blog_single_related_posts_readmore_text' => '',
			'blog_single_related_posts_hidden' => '',
			'blog_single_meta_options_heading' => '',
			'blog_single_hide_meta_icons' => '',
			'blog_single_show_author' => '',
			'blog_single_show_author_avatar' => '',
			'blog_single_before_author_word' => '',
			'blog_single_show_date' => '',
			'blog_single_before_date_word' => '',
			'blog_single_show_human_date' => '',
			'blog_single_show_categories' => '',
			'blog_single_before_categories_word' => '',
			'blog_single_show_tags' => '',
			'blog_single_before_tags_word' => '',
			'blog_single_show_comments_link' => '',
			'blog_single_show_date_over_image' => '',
			'blog_single_show_categories_over_image' => '',
			'blog_single_toc_heading' => '',
			'blog_single_toc_enabled' => '',
			'blog_single_toc_title' => '',
			'blog_single_toc_background' => '',
			'blog_single_toc_bordered' => '',
			'blog_single_toc_shadow' => '',
			'blog_single_toc_rounded' => '',
			'blog_single_toc_mt' => '',
			'blog_single_toc_mb' => '',
			'search_layout' => '',
			'search_featured_image_size' => '',
			'search_sidebar_position' => '',
			'search_show_full_text' => '',
			'search_excerpt_length' => '20',
			'search_read_more_text' => '',
			'search_read_more_style' => '',
			'search_read_more_block' => '',
			'search_meta_options_heading' => '',
			'search_hide_meta_icons' => '',
			'search_show_author' => '',
			'search_show_author_avatar' => '',
			'search_before_author_word' => '',
			'search_show_date' => '',
			'search_before_date_word' => '',
			'search_show_human_date' => '',
			'search_show_categories' => '',
			'search_before_categories_word' => '',
			'search_show_tags' => '',
			'search_before_tags_word' => '',
			'search_show_comments_link' => '',
			'search_none_page_heading' => '',
			'search_none_heading' => '',
			'search_none_text' => '',
			'search_none_content' => '',
			'special_categories_extra' => '',
			'animation_extra' => '',
			'contact_message_success' => 'Message was sent!',
			'contact_message_fail' => 'There was an error during message sending!',
			'popup_extra' => '',
			'edd_list_padding' => '15',
			'edd_list_show_cats' => '1',
			'edd_list_show_tags' => '',
			'edd_list_center_text' => '1',
			'edd_list_button_block' => '1',
			'edd_list_item_bg' => 'l m',
			'edd_list_bordered' => '1',
			'edd_list_shadow' => '',
			'edd_list_rounded' => '1',
			'edd_list_image_wide' => '',
			'preset' => '',
			'skin' => '',
			'jquery_to_footer' => '',
			'side_nav_position' => '',
			'side_nav_width' => '',
			'side_nav_px' => '',
			'side_nav_background' => 'l',
			'side_nav_type' => '',
			'side_nav_font_size' => '',
			'header_toggler_menu_side' => '1',
			'side_nav_logo_position' => '',
			'side_nav_meta_position' => 'bottom',
			'side_nav_social_position' => 'bottom',
			'side_nav_sticky_heading' => '',
			'side_nav_sticked' => '',
			'side_nav_sticked_shadow' => '',
			'side_nav_sticked_border' => '',
			'side_nav_header_overlap' => '',
			'infinite_scroll_type' => '',
			'infinite_scroll_label' => '',
			'share_buttons_enabled' => '',
			'share_buttons_post_heading' => '',
			'share_buttons_label_post' => '',
			'share_buttons_type_post' => '',
			'share_buttons_position_post' => '',
			'share_buttons_page_heading' => '',
			'share_buttons_archive_heading' => '',
			'share_buttons_label_archive' => '',
			'share_buttons_type_archive' => '',
			'share_buttons_position_archive' => '',
			'share_buttons_provider_heading' => '',
			'share_buttons_provider_facebook' => '',
			'share_buttons_provider_twitter' => '',
			'share_buttons_provider_pinterest' => '',
			'share_buttons_provider_linkedin' => '',
			'share_buttons_provider_email' => '',
			'share_buttons_provider_buffer' => '',
			'share_buttons_provider_tumblr' => '',
			'share_buttons_provider_reddit' => '',
			'share_buttons_provider_evernote' => '',
			'share_buttons_provider_delicious' => '',
			'share_buttons_provider_stumbleupon' => '',
			'share_buttons_provider_telegram' => '',
			'font_body_heading' => '',
			'font_body' => '{"font":"Lato","variant":["300","900"],"subset":[]}',
			'font_headings_heading' => '',
			'font_headings' => '{"font":"","variant":[],"subset":[]}',
			'category_portfolio_heading' => '',
			'category_portfolio' => '',
			'category_portfolio_layout' => 'cols-absolute-no-meta 3',
			'category_portfolio_layout_gap' => '5',
			'category_portfolio_sidebar_position' => 'no',
			'category_services_heading' => '',
			'category_services' => '',
			'category_services_layout' => 'cols-excerpt 3',
			'category_services_layout_gap' => '60',
			'category_services_sidebar_position' => 'no',
			'category_team_heading' => '',
			'category_team' => '',
			'category_team_layout' => 'cols-excerpt 3',
			'category_team_layout_gap' => '50',
			'category_team_sidebar_position' => 'no',
			'animation_enabled' => '',
			'animation_sidebar_widgets' => '',
			'animation_footer_widgets' => '',
			'animation_feed_posts' => '',
			'animation_feed_posts_thumbnail' => '',
			'message_top_heading' => '',
			'message_top_id' => '',
			'message_top_text' => '',
			'message_top_close_button_text' => '',
			'message_top_background' => 'l m',
			'message_top_font_size' => '',
			'message_bottom_heading' => '',
			'message_bottom_id' => '',
			'message_bottom_text' => '',
			'message_bottom_close_button_text' => '',
			'message_bottom_background' => 'l m',
			'message_bottom_font_size' => '',
			'message_bottom_layout' => '',
			'message_bottom_bordered' => '',
			'message_bottom_shadow' => '',
			'message_bottom_rounded' => '',
			'intro_teaser_image_1' => '',
			'intro_teaser_title_1' => '',
			'intro_teaser_text_1' => '',
			'intro_teaser_link_1' => '',
			'intro_teaser_button_text_1' => '',
			'intro_teaser_image_2' => '',
			'intro_teaser_title_2' => '',
			'intro_teaser_text_2' => '',
			'intro_teaser_link_2' => '',
			'intro_teaser_button_text_2' => '',
			'intro_teaser_image_3' => '',
			'intro_teaser_title_3' => '',
			'intro_teaser_text_3' => '',
			'intro_teaser_link_3' => '',
			'intro_teaser_button_text_3' => '',
			'intro_teaser_image_4' => '',
			'intro_teaser_title_4' => '',
			'intro_teaser_text_4' => '',
			'intro_teaser_link_4' => '',
			'intro_teaser_button_text_4' => '',
			'typo_heading_h1' => '',
			'typo_size_h1' => '3',
			'typo_line_height_h1' => '',
			'typo_letter_spacing_h1' => '',
			'typo_weight_h1' => '',
			'typo_mt_h1' => '',
			'typo_mb_h1' => '',
			'typo_heading_h2' => '',
			'typo_size_h2' => '',
			'typo_line_height_h2' => '',
			'typo_letter_spacing_h2' => '',
			'typo_weight_h2' => '',
			'typo_mt_h2' => '',
			'typo_mb_h2' => '',
			'typo_heading_h3' => '',
			'typo_size_h3' => '',
			'typo_line_height_h3' => '',
			'typo_letter_spacing_h3' => '',
			'typo_weight_h3' => '',
			'typo_mt_h3' => '',
			'typo_mb_h3' => '',
			'typo_heading_h4' => '',
			'typo_size_h4' => '',
			'typo_line_height_h4' => '',
			'typo_letter_spacing_h4' => '',
			'typo_weight_h4' => '',
			'typo_mt_h4' => '',
			'typo_mb_h4' => '',
			'typo_heading_h5' => '',
			'typo_size_h5' => '',
			'typo_line_height_h5' => '',
			'typo_letter_spacing_h5' => '',
			'typo_weight_h5' => '',
			'typo_mt_h5' => '',
			'typo_mb_h5' => '',
			'typo_heading_h6' => '',
			'typo_size_h6' => '',
			'typo_line_height_h6' => '',
			'typo_letter_spacing_h6' => '',
			'typo_weight_h6' => '',
			'typo_mt_h6' => '',
			'typo_mb_h6' => '',
		);
	}
endif;
add_filter( 'exs_default_theme_options', 'exs_music_default_options' );

//filter page menu
if ( ! function_exists( 'exs_music_filter_wp_page_menu_args' ) ) :
	function exs_music_filter_wp_page_menu_args( $args ) {

		$args['menu_class'] = 'top-menu ';
		$args['container'] = 'ul';
		$args['show_home'] = '1';

		return $args;
	}
endif;
add_filter( 'wp_page_menu_args', 'exs_music_filter_wp_page_menu_args' );

//set pages menu as a fallback menu to header menu if no menu set
if ( ! function_exists( 'exs_music_filter_wp_page_menu_primary_location' ) ) :
	function exs_music_filter_wp_page_menu_primary_location( $has_nav_menu, $location ) {
		return 'primary' === $location ? true : $has_nav_menu;
	}
endif;
add_filter( 'has_nav_menu', 'exs_music_filter_wp_page_menu_primary_location', 10, 2 );

//starter content
if ( ! function_exists( 'exs_music_starter_content' ) ) :
	function exs_music_starter_content() {
		return  array(
			'widgets'     => array(
				// Place one core-defined widgets in the first footer widget area.
				'sidebar-1' => array(
					'search',
					'text_about',
					'categories',
				),
			),

			// Create the custom image attachments used as post thumbnails for pages.
			'attachments' => array(
				'image-guitar' => array(
					'post_title' => _x( 'Example image 1', 'Theme starter content', 'exs-music' ),
					'file'       => 'assets/img/girl-guitar.jpg', // URL relative to the template directory.
				),
			),

			// Specify the core-defined pages to create and add custom thumbnails to some of them.
			'posts'       => array(
				//wp_block
				'block_title' => array(
					'post_type'    => 'wp_block',
					'post_title'   => esc_html__( 'Title with subtitle', 'exs-music' ),
					'post_content' => exs_get_html_markup_from_template( 'title-with-subtitle' ),
				),

				//post
				'postone'     => array(
					'post_type'    => 'post',
					'post_title'   => esc_html__( 'Single Post', 'exs-music' ),
					'post_content' => exs_get_html_markup_from_template( 'sample-post' ),
					'thumbnail'    => '{{image-guitar}}',
					'taxonomy'     => array(
						'category' => array(
							array(
								'term' => esc_html__( 'Blog', 'exs-music' ),
								'slug' => 'blog',
							),
						),
					),
				),

				//pages
				'front'       => array(
					'post_type'    => 'page',
					'post_title'   => esc_html__( 'Home', 'exs-music' ),
					'thumbnail'    => '{{image-guitar}}',
					'post_content' => exs_get_html_markup_from_template( 'home' ),
					'template'     => 'page-templates/header-overlap.php',
				),
				'band'       => array(
					'post_type'    => 'page',
					'post_title'   => esc_html__( 'Band', 'exs-music' ),
					'thumbnail'    => '{{image-guitar}}',
					'post_content' => exs_get_html_markup_from_template( 'band' ),
				),
				'events'       => array(
					'post_type'    => 'page',
					'post_title'   => esc_html__( 'Events', 'exs-music' ),
					'thumbnail'    => '{{image-guitar}}',
					'post_content' => exs_get_html_markup_from_template( 'events' ),
				),
				'typography'       => array(
					'post_type'    => 'page',
					'post_title'   => esc_html__( 'Typography', 'exs-music' ),
					'thumbnail'    => '{{image-guitar}}',
					'post_content' => exs_get_html_markup_from_template( 'sample-page-typography' ),
				),
				'contacts'     => array(
					'post_type'    => 'page',
					'post_title'   => esc_html__( 'Contacts', 'exs-music' ),
					'thumbnail'    => '{{image-guitar}}',
					'post_content' => exs_get_html_markup_from_template( 'contacts' ),
				),
				'blog',
			),

			// Default to a static front page and assign the front and posts pages.
			'options'     => array(
				'show_on_front'  => 'page',
				'page_on_front'  => '{{front}}',
				'page_for_posts' => '{{blog}}',
			),

			// Set up nav menus for each of the two areas registered in the theme.
			'nav_menus'   => array(
				// Assign a menu to the "primary" location.
				'primary'  => array(
					'name'  => esc_html__( 'Primary', 'exs-music' ),
					'items' => array(
						'link_home',
						// Note that the core "home" page is actually a link in case a static front page is not used.
						'page_band' => array(
							'type'      => 'post_type',
							'object'    => 'page',
							'object_id' => '{{band}}',
						),
						'page_events'  => array(
							'type'      => 'post_type',
							'object'    => 'page',
							'object_id' => '{{events}}',
						),
						'page_contacts'  => array(
							'type'      => 'post_type',
							'object'    => 'page',
							'object_id' => '{{contacts}}',
						),
						'page_typography'  => array(
							'type'      => 'post_type',
							'object'    => 'page',
							'object_id' => '{{typography}}',
						),
						'page_blog',
						'post_postone' => array(
							'type'      => 'post_type',
							'object'    => 'post',
							'object_id' => '{{postone}}',
						),
					),
				),
				// This replicates primary just to demonstrate the expanded menu.
				'expanded' => array(
					'name'  => esc_html__( 'Primary', 'exs-music' ),
					'items' => array(
						'link_home',
						// Note that the core "home" page is actually a link in case a static front page is not used.
						'page_band' => array(
							'type'      => 'post_type',
							'object'    => 'page',
							'object_id' => '{{band}}',
						),
						'page_events'  => array(
							'type'      => 'post_type',
							'object'    => 'page',
							'object_id' => '{{events}}',
						),
						'page_contacts'  => array(
							'type'      => 'post_type',
							'object'    => 'page',
							'object_id' => '{{contacts}}',
						),
						'page_typography'  => array(
							'type'      => 'post_type',
							'object'    => 'page',
							'object_id' => '{{typography}}',
						),
						'page_blog',
					),
				),
			),
		);
	}
endif;
add_filter( 'exs_starter_content', 'exs_music_starter_content' );
