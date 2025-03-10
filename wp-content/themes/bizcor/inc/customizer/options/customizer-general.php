<?php
function bizcor_customizer_general( $wp_customize ){
	
	global $bizcor_options;

	// Bizcor General Panel
	$wp_customize->add_panel( 'bizcor_general',
		array(
			'priority'       => 31,
			'capability'     => 'edit_theme_options',
			'title'          => esc_html__('Bizcor Global','bizcor'),
		)
	);

		// Header Breadcrumb
		$wp_customize->add_section( 'section_breadcrumb',
			array(
				'priority'    => 2,
				'title'       => esc_html__('Breadcrumbs','bizcor'),
				'panel'       => 'bizcor_general',
			)
		);

			// bizcor_breadcrumb_disable
			$wp_customize->add_setting('bizcor_breadcrumb_disable',
					array(
						'sanitize_callback' => 'bizcor_sanitize_checkbox',
						'default'           => $bizcor_options['bizcor_breadcrumb_disable'],
						'priority'          => 1,
					)
				);
			$wp_customize->add_control('bizcor_breadcrumb_disable',
				array(
					'type'        => 'checkbox',
					'label'       => esc_html__('Hide breadcrumb section?', 'bizcor'),
					'section'     => 'section_breadcrumb',
				)
			);

			// bizcor_breadcrumb_title_disable
			$wp_customize->add_setting('bizcor_breadcrumb_title_disable',
					array(
						'sanitize_callback' => 'bizcor_sanitize_checkbox',
						'default'           => $bizcor_options['bizcor_breadcrumb_title_disable'],
						'priority'          => 2,
					)
				);
			$wp_customize->add_control('bizcor_breadcrumb_title_disable',
				array(
					'type'        => 'checkbox',
					'label'       => esc_html__('Hide breadcrumb title?', 'bizcor'),
					'section'     => 'section_breadcrumb',
				)
			);

			// bizcor_breadcrumb_path_disable
			$wp_customize->add_setting('bizcor_breadcrumb_path_disable',
					array(
						'sanitize_callback' => 'bizcor_sanitize_checkbox',
						'default'           => $bizcor_options['bizcor_breadcrumb_path_disable'],
						'priority'          => 3,
					)
				);
			$wp_customize->add_control('bizcor_breadcrumb_path_disable',
				array(
					'type'        => 'checkbox',
					'label'       => esc_html__('Hide breadcrumb page path?', 'bizcor'),
					'section'     => 'section_breadcrumb',
				)
			);

			// bizcor_breadcrumb_bg_image
			$wp_customize->add_setting('bizcor_breadcrumb_bg_image',
					array(
						'sanitize_callback' => 'esc_url_raw',
						'default'           => $bizcor_options['bizcor_breadcrumb_bg_image'],
						'priority'          => 4,
					)
				);
			$wp_customize->add_control(new WP_Customize_Image_Control($wp_customize,'bizcor_breadcrumb_bg_image',
				array(
					'label' 		=> esc_html__('Background Image', 'bizcor'),
					'section' 		=> 'section_breadcrumb',
				)
			) );

			// bizcor_breadcrumb_attachment
			$wp_customize->add_setting('bizcor_breadcrumb_attachment',
					array(
						'sanitize_callback' => 'bizcor_sanitize_select',
						'default'           => $bizcor_options['bizcor_breadcrumb_attachment'],
						'priority'          => 5,
					)
				);
			$wp_customize->add_control('bizcor_breadcrumb_attachment',
				array(
					'type'        => 'select',
					'label'       => esc_html__('Background Attachment', 'bizcor'),
					'section'     => 'section_breadcrumb',
					'choices'     => array(
						'scroll' => __('Scroll','bizcor'),
						'fixed' => __('Fixed','bizcor'),
					),
				)
			);

			// bizcor_breadcrumb_effect_disable
			$wp_customize->add_setting('bizcor_breadcrumb_effect_disable',
					array(
						'sanitize_callback' => 'bizcor_sanitize_checkbox',
						'default'           => $bizcor_options['bizcor_breadcrumb_effect_disable'],
						'priority'          => 7,
					)
				);
			$wp_customize->add_control('bizcor_breadcrumb_effect_disable',
				array(
					'type'        => 'checkbox',
					'label'       => esc_html__('Hide breadcrumb wave effect?', 'bizcor'),
					'section'     => 'section_breadcrumb',
				)
			);

			// bizcor_breadcrumb_height
			$wp_customize->add_setting('bizcor_breadcrumb_height',
					array(
						'sanitize_callback' => 'bizcor_sanitize_range_value',
						'priority'          => 8,
						'transport'         => 'postMessage',
					)
				);
			$wp_customize->add_control(new Bizcor_Range_Control($wp_customize,'bizcor_breadcrumb_height',
				array(
					'label' 		=> esc_html__('Breadcrumb Section Height', 'bizcor'),
					'section' 		=> 'section_breadcrumb',
					'type'          => 'range-value',
					'media_query'   => true,
                    'input_attr' => array(
                        'mobile' => array(
                            'min' => 100,
                            'max' => 1024,
                            'step' => 1,
                            'default_value' => $bizcor_options['bizcor_breadcrumb_height'],
                        ),
                        'tablet' => array(
                            'min' => 100,
                            'max' => 1024,
                            'step' => 1,
                            'default_value' => $bizcor_options['bizcor_breadcrumb_height'],
                        ),
                        'desktop' => array(
                            'min' => 100,
                            'max' => 1024,
                            'step' => 1,
                            'default_value' => $bizcor_options['bizcor_breadcrumb_height'],
                        ),
                    ),
				)
			) );
}
add_action('customize_register','bizcor_customizer_general');