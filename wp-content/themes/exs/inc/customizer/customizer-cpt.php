<?php
if ( ! defined( 'ABSPATH' ) ) {
	exit; // Exit if accessed directly
}

//add Extended sidebars support
add_filter( 'exs_customizer_options', 'exs_filter_exs_customizer_options_add_cpt_settings', 9 );
if ( ! function_exists( 'exs_filter_exs_customizer_options_add_cpt_settings' ) ) :
	function exs_filter_exs_customizer_options_add_cpt_settings( $options ) {
		$cpt_array = get_post_types(
			array(
				'public'   => true,
				'_builtin' => false
			),
			'objects'
		);

		//unset supported post types here
		//WooCommerce support
		if ( class_exists( 'WooCommerce' ) ) {
			unset($cpt_array['product']);
		}
		//Elementor
		if ( defined( 'ELEMENTOR_VERSION' ) || defined( 'ELEMENTOR_PRO_VERSION' ) ) {
			unset($cpt_array['elementor_library']);
		}
		//EDD support
		if ( class_exists( 'Easy_Digital_Downloads' ) ) {
			unset($cpt_array['download']);
		}
		//bbPress support
		if ( class_exists( 'bbPress' ) ) {
			unset($cpt_array['forum']);
			unset($cpt_array['topic']);
			unset($cpt_array['reply']);
		}
		//BuddyPress support - does not create any public custom post types
		//WP Job Manager support
		if ( class_exists( 'WP_Job_Manager' ) ) {
			unset($cpt_array['job_listing']);
		}
		//Events Calendar
		//Activation of this plugin changes Customizer options on init and 'Publish' button is always active
		if ( class_exists( 'Tribe__Events__Main' ) ) {
			unset($cpt_array['tribe_events']);
		}
		//LearnPress
		if ( class_exists( 'LearnPress' ) ) {
			unset($cpt_array['lp_course']);
			unset($cpt_array['lp_lesson']);
			unset($cpt_array['lp_quiz']);
			unset($cpt_array['lp_question']);
		}

		//if no custom post types
		if ( empty( $cpt_array ) ) {
			return $options;
		}

		$options['panel_cpt']                           = array(
			'type'            => 'panel',
			'label'           => esc_html__( 'ExS Custom Post Types options', 'exs' ),
			'description'     => esc_html__( 'Manage your Custom Post Types options. Set your archive and singular templates, sidebar positions etc. Please note that if your custom post types are created using 3rd party plugins that have their own template files, these settings may be ignored.', 'exs' ),
			'priority'        => 130,
		);

		$options['section_custom_sidebars']                       = array(
			'type'            => 'section',
			'panel'           => 'panel_cpt',
			'label'           => esc_html__( 'Create Custom Sidebars', 'exs' ),
			'description'     => esc_html__( 'You can create your custom sidebars to display them on your custom post types', 'exs' ),
			'priority'        => 100,
		);

		$options['custom_sidebars_csv']        = array(
			'type'        => 'textarea',
			'section'     => 'section_custom_sidebars',
			'label'       => esc_html__( 'Coma separated custom sidebar titles', 'exs' ),
			'description' => esc_html__( 'Latin letters preferred. For example: "Services sidebar, Single service sidebar"', 'exs' ),
			'default'     => esc_html( exs_option( 'custom_sidebars_csv', '' ) ),
		);

		$exs = ExS::instance();
		$sidebar_choices          = $exs->get( 'sidebars' );
		$sidebar_choices          = wp_parse_args( $sidebar_choices, array( '' => esc_html__( 'Inherit from Blog options', 'exs' ) ) );
		$sidebar_choices_opposite = wp_parse_args(
			$sidebar_choices,
			array(
				'' => esc_html__( 'Inherit from Blog options', 'exs' ),
				'sidebar-not-existing' => esc_html__( 'Disabled', 'exs' ),
			)
		);

		//$sidebar_positions[0] - for inherit from the blog
		$sidebar_positions = exs_get_sidebar_position_options( true );

		//add exceptions here for Woo Products, EDD downloads etc.
		foreach ( $cpt_array as $cpt_slug => $cpt_obj ) :

			$options['section_options_' . $cpt_slug ]                       = array(
				'type'            => 'section',
				'panel'           => 'panel_cpt',
				'label'           => $cpt_obj->labels->name,
				'description'     => esc_html__( 'Override blog, post layouts and main sidebars for this Post Type. Please note that if your custom post type is created using 3rd party plugins that have its own template files and do not use theme default template files, these settings may be ignored.', 'exs' ),
				'priority'        => 100,
			);

			//archive cpt
			$options[ $cpt_slug . '_sidebar_position_archive_heading']                   = array(
				'type'        => 'block-heading',
				'section'     => 'section_options_' . $cpt_slug,
				'label'       => esc_html__( 'Archive options', 'exs' ),
				'description' => esc_html__( 'Archive options for this post type', 'exs' ),
			);
			$options [ $cpt_slug . '_container_width' ]                  = array(
				'type'    => 'radio',
				'section' => 'section_options_' . $cpt_slug,
				'label'   => esc_html__( 'Archive container max width', 'exs' ),
				'default' => esc_html( exs_option( $cpt_slug . '_container_width', '' ) ),
				'choices' => array(
					''     => esc_html__( 'Inherit from Blog options', 'exs' ),
					'1400' => esc_html__( '1400px', 'exs' ),
					'1140' => esc_html__( '1140px', 'exs' ),
					'960'  => esc_html__( '960px', 'exs' ),
					'720'  => esc_html__( '720px', 'exs' ),
				),
			);
			//$options['cpt_template_blank_archive']  = array(
			$options['cpt_' . $cpt_slug . '_layout_archive']  = array(
				'type'        => 'select',
				'section'     => 'section_options_' . $cpt_slug,
				'label'       => esc_html__( 'Archive custom layout for this Post Type', 'exs' ),
				'description' => esc_html__( 'Change default blog layout for this Custom Post Type archives', 'exs' ),
				'default'     => esc_html( exs_option( 'cpt_' . $cpt_slug . '_layout_archive', false ) ),
				'choices'     => array(
					''              => esc_html__( 'Inherit from Blog options', 'exs' ),
					'excerpt-blank' => esc_html__( 'Only the_excerpt()', 'exs' ),
					'excerpt-blank 2' => esc_html__( 'Only the_excerpt() - 2 columns', 'exs' ),
					'excerpt-blank 3' => esc_html__( 'Only the_excerpt() - 3 columns', 'exs' ),
					'excerpt-blank 4' => esc_html__( 'Only the_excerpt() - 4 columns', 'exs' ),
					'excerpt-title' => esc_html__( 'Linked title and excerpt', 'exs' ),
					'excerpt-title 2' => esc_html__( 'Linked title and excerpt - 2 columns', 'exs' ),
					'excerpt-title 3' => esc_html__( 'Linked title and excerpt - 3 columns', 'exs' ),
					'excerpt-title 4' => esc_html__( 'Linked title and excerpt - 4 columns', 'exs' ),
					'excerpt-image 2' => esc_html__( 'Image, title and excerpt - 2 columns', 'exs' ),
					'excerpt-image 3' => esc_html__( 'Image, title and excerpt - 3 columns', 'exs' ),
					'excerpt-image 4' => esc_html__( 'Image, title and excerpt - 4 columns', 'exs' ),
				),
			);
			$options['cpt_' . $cpt_slug . '_layout_gap'] = array(
				'type'        => 'select',
				'section'     => 'section_options_' . $cpt_slug,
				'label'       => esc_html__( 'Archive layout gap', 'exs' ),
				'description' => esc_html__( 'Used only for grid and masonry layouts', 'exs' ),
				'default'     => esc_html( exs_option( 'cpt_' . $cpt_slug . '_layout_gap', '' ) ),
				'choices'     => exs_get_feed_layout_gap_options( true ),
			);

			//sidebars
			$options[ $cpt_slug . '_sidebar_position'] = array(
				'type'        => 'radio',
				'section'     => 'section_options_' . $cpt_slug,
				'default'     => exs_option( $cpt_slug . '_sidebar_position', 0 ),
				'label'       => esc_html__( 'Archive main sidebar position', 'exs' ),
				'description' => esc_html__( 'This option let you manage sidebar position for archive pages', 'exs' ),
				'choices'     => $sidebar_positions,
			);
			$options[ $cpt_slug . '_sidebar_selected_main'] = array(
				'type'        => 'select',
				'section'     => 'section_options_' . $cpt_slug,
				'default'     => exs_option( $cpt_slug . '_sidebar_selected_main', '' ),
				'label'       => esc_html__( 'Main sidebar', 'exs' ),
				'choices'     => $sidebar_choices,
			);
			$options[ $cpt_slug . '_sidebar_selected_main_opposite'] = array(
				'type'        => 'select',
				'section'     => 'section_options_' . $cpt_slug,
				'default'     => exs_option( $cpt_slug . '_sidebar_selected_main_opposite', '' ),
				'label'       => esc_html__( 'Main opposite sidebar', 'exs' ),
				'choices'     => $sidebar_choices_opposite,
			);


			//single cpt post
			$options[ $cpt_slug . '_sidebar_position_single_heading']                   = array(
				'type'        => 'block-heading',
				'section'     => 'section_options_' . $cpt_slug,
				'label'       => esc_html__( 'Single post options', 'exs' ),
				'description' => esc_html__( 'Single post options for this post type', 'exs' ),
			);
			$options[ $cpt_slug . '_single_container_width' ]           = array(
				'type'    => 'radio',
				'section' => 'section_options_' . $cpt_slug,
				'label'   => esc_html__( 'Singular container max width', 'exs' ),
				'default' => esc_html( exs_option( $cpt_slug . '_single_container_width', '' ) ),
				'choices' => array(
					''     => esc_html__( 'Inherit from Single post options', 'exs' ),
					'1400' => esc_html__( '1400px', 'exs' ),
					'1140' => esc_html__( '1140px', 'exs' ),
					'960'  => esc_html__( '960px', 'exs' ),
					'720'  => esc_html__( '720px', 'exs' ),
				),
			);
			//$options['cpt_template_blank_singular'] = array(
			$options['cpt_' . $cpt_slug . '_layout_single'] = array(
				'type'        => 'select',
				'section'     => 'section_options_' . $cpt_slug,
				'label'       => esc_html__( 'Singular custom layout for this Post Type', 'exs' ),
				'description' => esc_html__( 'Change default singular layout for this Custom Post Type', 'exs' ),
				'default'     => esc_html( exs_option( 'cpt_' . $cpt_slug . '_layout_single', false ) ),
				'choices'     => array(
					''              => esc_html__( 'Inherit from Single post options', 'exs' ),
					'content-blank' => esc_html__( 'Only the_content()', 'exs' ),
					'content-title' => esc_html__( 'Title and content', 'exs' ),
					'content-image' => esc_html__( 'Image, title and content', 'exs' ),
				),
			);
			//single sidebars
			$options[ $cpt_slug . '_single_sidebar_position'] = array(
				'type'        => 'radio',
				'section'     => 'section_options_' . $cpt_slug,
				'default'     => exs_option( 'downloads_sidebar_position', 0 ),
				'label'       => esc_html__( 'Single item main sidebar position', 'exs' ),
				'description' => esc_html__( 'This option let you manage sidebar position for single item pages', 'exs' ),
				'choices'     => $sidebar_positions,
			);
			$options[ $cpt_slug . '_single_sidebar_selected_main'] = array(
				'type'        => 'select',
				'section'     => 'section_options_' . $cpt_slug,
				'default'     => exs_option( $cpt_slug . '_single_sidebar_selected_main', '' ),
				'label'       => esc_html__( 'Main sidebar', 'exs' ),
				'choices'     => $sidebar_choices,
			);
			$options[ $cpt_slug . '_single_sidebar_selected_main_opposite'] = array(
				'type'        => 'select',
				'section'     => 'section_options_' . $cpt_slug,
				'default'     => exs_option( $cpt_slug . '_single_sidebar_selected_main_opposite', '' ),
				'label'       => esc_html__( 'Main opposite sidebar', 'exs' ),
				'choices'     => $sidebar_choices_opposite,
			);

		endforeach;

		return $options;
	}
endif;

