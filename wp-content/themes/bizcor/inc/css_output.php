<?php
if ( ! function_exists( 'bizcor_get_dynamic_css' ) ) :
	function bizcor_get_dynamic_css() {

		global $bizcor_options;

		// Calling Bizcor_CSS class for generate dynamic css
		$pro_css = new Bizcor_CSS;

		$logo_width = json_decode(get_theme_mod('bizcor_h_logo_width',$bizcor_options['bizcor_h_logo_width']));
		$site_title = json_decode(get_theme_mod('bizcor_h_site_title_fontsize',$bizcor_options['bizcor_h_site_title_fontsize']));
		$site_desc = json_decode(get_theme_mod('bizcor_h_site_desc_fontsize',$bizcor_options['bizcor_h_site_desc_fontsize']));
		$breadcrumb_height = json_decode(get_theme_mod('bizcor_breadcrumb_height',$bizcor_options['bizcor_breadcrumb_height']));
		$breadcrumb_overlay = get_theme_mod('bizcor_breadcrumb_overlay',$bizcor_options['bizcor_breadcrumb_overlay']);

		$slider_opacity = get_theme_mod('bizcor_slider_opacity',$bizcor_options['bizcor_slider_opacity']);
		$body_bg_color = get_background_color();
		if($body_bg_color==''){
			$body_bg_color = 'ffffff';
		}
		list($body_r, $body_g, $body_b) = sscanf( '#'.$body_bg_color, "#%02x%02x%02x" );
		$theme_color = get_theme_mod('bizcor_theme_color',$bizcor_options['bizcor_theme_color']);
		$custom_color_disable = get_theme_mod('bizcor_custom_color_disable',$bizcor_options['bizcor_custom_color_disable']);
		$custom_color = get_theme_mod('bizcor_custom_color',$bizcor_options['bizcor_custom_color']);
		if($custom_color_disable==false){
			$color = $custom_color;
		}else{
			$color = $theme_color;
		}
		list($r, $g, $b) = sscanf( $color, "#%02x%02x%02x" );

		$typo_sections = array('body','h1','h2','h3','h4','h5','h6');
		foreach($typo_sections as $sec) {
			$sec_fontsize = json_decode(get_theme_mod('bizcor_'.$sec.'_fontsize',$bizcor_options['bizcor_'.$sec.'_fontsize']));
			$sec_lineheight = json_decode(get_theme_mod('bizcor_'.$sec.'_lineheight',$bizcor_options['bizcor_'.$sec.'_lineheight']));
			$sec_texttransform = get_theme_mod('bizcor_'.$sec.'_texttransform',$bizcor_options['bizcor_'.$sec.'_texttransform']);

			$pro_css->set_selector( $sec );
			
			if($sec_texttransform!=''){
				$pro_css->add_property( 'text-transform', esc_attr($sec_texttransform));
			}			

			// Desktop CSS
			$pro_css->start_media_query( apply_filters( 'bizcor_'.$sec.'_desktop_media_query', '(min-width:991px)' ) );
				$pro_css->set_selector( $sec );
				if(isset($sec_fontsize->desktop)){
					$pro_css->add_property( 'font-size', esc_attr($sec_fontsize->desktop).'px' );
				}
				if(isset($sec_lineheight->desktop)){
				$pro_css->add_property( 'line-height', esc_attr($sec_lineheight->desktop) );
				}							
			$pro_css->stop_media_query();

			// Tablet CSS
			$pro_css->start_media_query( apply_filters( 'bizcor_'.$sec.'_tablet_media_query', '(min-width:768px) and (max-width:991px)' ) );
				$pro_css->set_selector( $sec );
				if(isset($sec_fontsize->tablet)){
					$pro_css->add_property( 'font-size', esc_attr($sec_fontsize->tablet).'px' );
				}
				if(isset($sec_lineheight->tablet)){
				$pro_css->add_property( 'line-height', esc_attr($sec_lineheight->tablet) );
				}				
			$pro_css->stop_media_query();

			// Mobile CSS
			$pro_css->start_media_query( apply_filters( 'bizcor_'.$sec.'_mobile_media_query', '(max-width:768px)' ) );
				$pro_css->set_selector( $sec );
				if(isset($sec_fontsize->mobile)){
					$pro_css->add_property( 'font-size', esc_attr($sec_fontsize->mobile).'px' );
				}
				if(isset($sec_lineheight->mobile)){
				$pro_css->add_property( 'line-height', esc_attr($sec_lineheight->mobile) );
				}				
			$pro_css->stop_media_query();
		}

		$pro_css->set_selector( ':root' );
		$pro_css->add_property( '--breadcrumb-bg-color', esc_attr($breadcrumb_overlay));
		$pro_css->add_property( '--body-bg-color', '#'.esc_attr($body_bg_color));
		$pro_css->add_property( '--body-R', esc_attr($body_r));
		$pro_css->add_property( '--body-G', esc_attr($body_g));
		$pro_css->add_property( '--body-B', esc_attr($body_b));
		$pro_css->add_property( '--bs-primary', esc_attr($color));
		$pro_css->add_property( '--bs-primary-light1', bizcor_convertRGBAtoHEX6('rgba('.esc_attr($r).', '.esc_attr($g).', '.esc_attr($b).', 0.6)'));
		$pro_css->add_property( '--bs-primary-light2', bizcor_convertRGBAtoHEX6('rgba('.esc_attr($r).', '.esc_attr($g).', '.esc_attr($b).', 0.3)'));
		$pro_css->add_property( '--bs-primary-light3', bizcor_convertRGBAtoHEX6('rgba('.esc_attr($r).', '.esc_attr($g).', '.esc_attr($b).', 0.1)'));
		$pro_css->add_property( '--bs-primary-shadow', 'rgb('.esc_attr($r).', '.esc_attr($g).', '.esc_attr($b).', 0.5)');
		$pro_css->add_property( '--bs-R', esc_attr($r));
		$pro_css->add_property( '--bs-G', esc_attr($g));
		$pro_css->add_property( '--bs-B', esc_attr($b));
		$pro_css->set_selector( '.home-slider-one .main-slider' );
		$pro_css->add_property( 'background-color', 'rgba(0,0,0,'.esc_attr($slider_opacity).')' );

		// Desktop CSS
		$pro_css->start_media_query( apply_filters( 'bizcor_desktop_media_query', '(min-width:991px)' ) );
			if(isset($logo_width->desktop)){
				$pro_css->set_selector( '.logo img' );
				$pro_css->add_property( 'max-width', esc_attr($logo_width->desktop).'px' );
			}

			if(isset($site_title->desktop)){
				$pro_css->set_selector( '.header-one .site_title' );
				$pro_css->add_property( 'font-size', esc_attr($site_title->desktop).'px' );
			}

			if(isset($site_desc->desktop)){
				$pro_css->set_selector( '.header-one .site_desc' );
				$pro_css->add_property( 'font-size', esc_attr($site_desc->desktop).'px' );
			}

			if(isset($breadcrumb_height->desktop)){
				$pro_css->set_selector( '.breadcrumb-area' );
				$pro_css->add_property( 'height', esc_attr($breadcrumb_height->desktop).'px' );
			}
		$pro_css->stop_media_query();

		// Tablet CSS
		$pro_css->start_media_query( apply_filters( 'bizcor_tablet_media_query', '(min-width:768px) and (max-width:991px)' ) );
			if(isset($logo_width->tablet)){
				$pro_css->set_selector( '.logo img' );
				$pro_css->add_property( 'max-width', esc_attr($logo_width->tablet).'px' );
			}

			if(isset($site_title->tablet)){
				$pro_css->set_selector( '.header-one .site_title' );
				$pro_css->add_property( 'font-size', esc_attr($site_title->tablet).'px' );
			}

			if(isset($site_desc->tablet)){
				$pro_css->set_selector( '.header-one .site_desc' );
				$pro_css->add_property( 'font-size', esc_attr($site_desc->tablet).'px' );
			}

			if(isset($breadcrumb_height->tablet)){
				$pro_css->set_selector( '.breadcrumb-area' );
				$pro_css->add_property( 'height', esc_attr($breadcrumb_height->tablet).'px' );
			}
		$pro_css->stop_media_query();

		// Mobile CSS
		$pro_css->start_media_query( apply_filters( 'bizcor_mobile_media_query', '(max-width:768px)' ) );
			if(isset($logo_width->mobile)){
				$pro_css->set_selector( '.logo img' );
				$pro_css->add_property( 'max-width', esc_attr($logo_width->mobile).'px' );
			}

			if(isset($site_title->mobile)){
				$pro_css->set_selector( '.header-one .site_title' );
				$pro_css->add_property( 'font-size', esc_attr($site_title->mobile).'px' );
			}

			if(isset($site_desc->mobile)){
				$pro_css->set_selector( '.header-one .site_desc' );
				$pro_css->add_property( 'font-size', esc_attr($site_desc->mobile).'px' );
			}

			if(isset($breadcrumb_height->mobile)){
				$pro_css->set_selector( '.breadcrumb-area' );
				$pro_css->add_property( 'height', esc_attr($breadcrumb_height->mobile).'px' );
			}
		$pro_css->stop_media_query();

		return apply_filters( 'bizcor_pro_dynamic_css', wp_strip_all_tags( $pro_css->css_output() ) );
	}
endif;
if ( ! function_exists( 'bizcor_enqueue_dynamic_css' ) ) :
	function bizcor_enqueue_dynamic_css() {
		$css = bizcor_get_dynamic_css();
		wp_register_style( 'bizcor-style', false );
		wp_enqueue_style( 'bizcor-style' );
		wp_add_inline_style( 'bizcor-style', wp_strip_all_tags( $css ) );
	}
	add_action( 'wp_enqueue_scripts', 'bizcor_enqueue_dynamic_css');
endif;