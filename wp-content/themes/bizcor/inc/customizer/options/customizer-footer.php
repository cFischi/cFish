<?php
function bizcor_customizer_footer( $wp_customize ){

	global $bizcor_options;

	// Bizcor Footer Panel
	$wp_customize->add_panel( 'bizcor_footer',
		array(
			'priority'       => 32,
			'capability'     => 'edit_theme_options',
			'title'          => esc_html__('Bizcor Footer','bizcor'),
		)
	);

		// Footer Above Section
		$wp_customize->add_section( 'footer_above',
			array(
				'priority'    => 1,
				'title'       => esc_html__('Footer Above','bizcor'),
				'panel'       => 'bizcor_footer',
			)
		);

			// bizcor_footer_above_disable
			$wp_customize->add_setting('bizcor_footer_above_disable',
					array(
						'sanitize_callback' => 'bizcor_sanitize_checkbox',
						'default'           => $bizcor_options['bizcor_footer_above_disable'],
						'priority'          => 1,
					)
				);
			$wp_customize->add_control('bizcor_footer_above_disable',
				array(
					'type'        => 'checkbox',
					'label'       => esc_html__('Hide above footer?', 'bizcor'),
					'section'     => 'footer_above',
				)
			);

			// bizcor_footer_above_info_icon
			$wp_customize->add_setting('bizcor_footer_above_info_icon',
					array(
						'sanitize_callback' => 'sanitize_text_field',
						'default'           => $bizcor_options['bizcor_footer_above_info_icon'],
						'priority'          => 2,
					)
				);
			$wp_customize->add_control(new Bizcor_Iconpicker_Control($wp_customize,'bizcor_footer_above_info_icon',
				array(
					'label'       => esc_html__('Footer left info icon', 'bizcor'),
					'section'     => 'footer_above',
				)
			) );

			// bizcor_footer_above_info_title
			$wp_customize->add_setting('bizcor_footer_above_info_title',
					array(
						'sanitize_callback' => 'sanitize_text_field',
						'default'           => $bizcor_options['bizcor_footer_above_info_title'],
						'priority'          => 3,
					)
				);
			$wp_customize->add_control('bizcor_footer_above_info_title',
				array(
					'type'        => 'text',
					'label'       => esc_html__('Footer left info title', 'bizcor'),
					'section'     => 'footer_above',
				)
			);

			// bizcor_footer_above_info_desc
			$wp_customize->add_setting('bizcor_footer_above_info_desc',
					array(
						'sanitize_callback' => 'wp_kses_post',
						'default'           => $bizcor_options['bizcor_footer_above_info_desc'],
						'priority'          => 3,
					)
				);
			$wp_customize->add_control('bizcor_footer_above_info_desc',
				array(
					'type'        => 'textarea',
					'label'       => esc_html__('Footer left info description', 'bizcor'),
					'section'     => 'footer_above',
				)
			);

			// bizcor_footer_above_newsletter_disable
			$wp_customize->add_setting('bizcor_footer_above_newsletter_disable',
					array(
						'sanitize_callback' => 'bizcor_sanitize_checkbox',
						'default'           => $bizcor_options['bizcor_footer_above_newsletter_disable'],
						'priority'          => 4,
					)
				);
			$wp_customize->add_control('bizcor_footer_above_newsletter_disable',
				array(
					'type'        => 'checkbox',
					'label'       => esc_html__('Hide newsletter?', 'bizcor'),
					'section'     => 'footer_above',
				)
			);

			// bizcor_footer_above_newsletter_title
			$wp_customize->add_setting('bizcor_footer_above_newsletter_title',
					array(
						'sanitize_callback' => 'sanitize_text_field',
						'default'           => $bizcor_options['bizcor_footer_above_newsletter_title'],
						'priority'          => 5,
					)
				);
			$wp_customize->add_control('bizcor_footer_above_newsletter_title',
				array(
					'type'        => 'text',
					'label'       => esc_html__('Newsletter Title', 'bizcor'),
					'section'     => 'footer_above',
				)
			);

			// bizcor_footer_above_newsletter_shortcode
			$wp_customize->add_setting('bizcor_footer_above_newsletter_shortcode',
					array(
						'sanitize_callback' => 'wp_kses_post',
						'default'           => $bizcor_options['bizcor_footer_above_newsletter_shortcode'],
						'priority'          => 6,
					)
				);
			$wp_customize->add_control('bizcor_footer_above_newsletter_shortcode',
				array(
					'type'        => 'textarea',
					'label'       => esc_html__('Newsletter Shortcode', 'bizcor'),
					'section'     => 'footer_above',
				)
			);

		// Footer Middle Section
		$wp_customize->add_section( 'footer_middle',
			array(
				'priority'    => 2,
				'title'       => esc_html__('Footer Middle','bizcor'),
				'panel'       => 'bizcor_footer',
			)
		);

			// bizcor_footer_middle_columns
			$wp_customize->add_setting('bizcor_footer_middle_columns',
					array(
						'sanitize_callback' => 'bizcor_sanitize_select',
						'default'           => $bizcor_options['bizcor_footer_middle_columns'],
						'priority'          => 1,
					)
				);
			$wp_customize->add_control('bizcor_footer_middle_columns',
				array(
					'type'        => 'select',
					'label'       => esc_html__('Widgets Column Layout', 'bizcor'),
					'section'     => 'footer_middle',
					'choices' => array(
						'4' => 4,
						'3' => 3,
						'2' => 2,
						'1' => 1,
						'0' => esc_html__('Disable footer widgets', 'bizcor'),
					),
				)
			);

			for ( $i = 1; $i<=4; $i ++ ) {
				$df = 12;
				if ( $i > 1 ) {
					$_n = 12/$i;
					$df = array();
					for ( $j = 0; $j < $i; $j++ ) {
						$df[ $j ] = $_n;
					}
					$df = join( '+', $df );
				}
				$wp_customize->add_setting('footer_custom_'.$i.'_columns',
					array(
						'sanitize_callback' => 'sanitize_text_field',
						'default' => $df,
						'transport' => 'postMessage',
					)
				);
				$wp_customize->add_control('footer_custom_'.$i.'_columns',
					array(
						'label' => $i == 1 ? __('Custom footer 1 column width', 'bizcor') : sprintf( __('Custom footer %s columns width', 'bizcor'), $i ),
						'section' => 'footer_middle',
						'description' => esc_html__('Enter int numbers and sum of them must smaller or equal 12, separated by "+"', 'bizcor'),
					)
				);
			}

		// Footer Bottom Section
		$wp_customize->add_section( 'footer_bottom',
			array(
				'priority'    => 3,
				'title'       => esc_html__('Footer Bottom','bizcor'),
				'panel'       => 'bizcor_footer',
			)
		);

			// bizcor_footer_bottom_disable
			$wp_customize->add_setting('bizcor_footer_bottom_disable',
					array(
						'sanitize_callback' => 'bizcor_sanitize_checkbox',
						'default'           => $bizcor_options['bizcor_footer_bottom_disable'],
						'priority'          => 1,
					)
				);
			$wp_customize->add_control('bizcor_footer_bottom_disable',
				array(
					'type'        => 'checkbox',
					'label'       => esc_html__('Hide bottom footer?', 'bizcor'),
					'section'     => 'footer_bottom',
				)
			);

			// bizcor_footer_bottom_copyright
			$wp_customize->add_setting('bizcor_footer_bottom_copyright',
					array(
						'sanitize_callback' => 'wp_kses_post',
						'default'           => $bizcor_options['bizcor_footer_bottom_copyright'],
						'priority'          => 2,
					)
				);
			$wp_customize->add_control('bizcor_footer_bottom_copyright',
				array(
					'type'        => 'textarea',
					'label'       => esc_html__('Copyright Text', 'bizcor'),
					'description' => __('<code>%current_year%</code> to update the year automatically.<br/><code>%copy%</code> to include the copyright symbol.<br/>HTML is allowed.', 'bizcor'),
					'section'     => 'footer_bottom',
				)
			);

		// Footer Background Settings
		$wp_customize->add_section( 'footer_background',
			array(
				'priority'    => 4,
				'title'       => esc_html__('Footer Background','bizcor'),
				'panel'       => 'bizcor_footer',
			)
		);

			// bizcor_footer_bg_image
			$wp_customize->add_setting('bizcor_footer_bg_image',
					array(
						'sanitize_callback' => 'esc_url_raw',
						'default'           => $bizcor_options['bizcor_footer_bg_image'],
						'priority'          => 1,
					)
				);
			$wp_customize->add_control(new WP_Customize_Image_Control($wp_customize,'bizcor_footer_bg_image',
				array(
					'label' 		=> esc_html__('Background Image', 'bizcor'),
					'section' 		=> 'footer_background',
				)
			) );

			// bizcor_footer_bg_attachment
			$wp_customize->add_setting('bizcor_footer_bg_attachment',
					array(
						'sanitize_callback' => 'bizcor_sanitize_select',
						'default'           => $bizcor_options['bizcor_footer_bg_attachment'],
						'priority'          => 3,
					)
				);
			$wp_customize->add_control('bizcor_footer_bg_attachment',
				array(
					'type'        => 'select',
					'label'       => esc_html__('Background Attachment', 'bizcor'),
					'section'     => 'footer_background',
					'choices'     => array(
						'scroll' => __('Scroll','bizcor'),
						'fixed' => __('Fixed','bizcor'),
					),
				)
			);

}
add_action('customize_register','bizcor_customizer_footer');