<?php
function bizcor_customizer_header( $wp_customize ){

	global $bizcor_options;

	// Bizcor Header Panel
	$wp_customize->add_panel( 'bizcor_header',
		array(
			'priority'       => 30,
			'capability'     => 'edit_theme_options',
			'title'          => esc_html__('Bizcor Header','bizcor'),
		)
	);
		// Site identity
        $wp_customize->add_section('title_tagline',
            array(
                'priority'     => 1,
                'title'        => __('Site Identity','bizcor'),
                'panel'        => 'bizcor_header',
            )
        );

        	$wp_customize->get_setting( 'blogname' )->transport        = 'postMessage';
			$wp_customize->get_setting( 'blogdescription' )->transport = 'postMessage';

        	// bizcor_h_logo_width
			$wp_customize->add_setting('bizcor_h_logo_width',
					array(
						'sanitize_callback' => 'bizcor_sanitize_range_value',
						'priority'          => 6,
						'transport'         => 'postMessage',
					)
				);
			$wp_customize->add_control(new Bizcor_Range_Control($wp_customize,'bizcor_h_logo_width',
				array(
					'label' 		=> esc_html__('Logo Width', 'bizcor'),
					'section' 		=> 'title_tagline',
					'type'          => 'range-value',
					'media_query'   => true,
                    'input_attr' => array(
                        'mobile' => array(
                            'min' => 10,
                            'max' => 300,
                            'step' => 1,
                            'default_value' => $bizcor_options['bizcor_h_logo_width'],
                        ),
                        'tablet' => array(
                            'min' => 10,
                            'max' => 300,
                            'step' => 1,
                            'default_value' => $bizcor_options['bizcor_h_logo_width'],
                        ),
                        'desktop' => array(
                            'min' => 10,
                            'max' => 300,
                            'step' => 1,
                            'default_value' => $bizcor_options['bizcor_h_logo_width'],
                        ),
                    ),
				)
			) );

		// Header Navigation Section
		$wp_customize->add_section( 'header_navigation',
			array(
				'priority'    => 3,
				'title'       => esc_html__('Header Navigation','bizcor'),
				'panel'       => 'bizcor_header',
			)
		);

			// bizcor_nav_btn_hide
			$wp_customize->add_setting('bizcor_nav_btn_hide',
					array(
						'sanitize_callback' => 'bizcor_sanitize_checkbox',
						'default'           => $bizcor_options['bizcor_nav_btn_hide'],
						'priority'          => 1,
					)
				);
			$wp_customize->add_control('bizcor_nav_btn_hide',
				array(
					'type'        => 'checkbox',
					'label'       => esc_html__('Hide right navigation button?','bizcor'),
					'section'     => 'header_navigation',
				)
			);

			// bizcor_nav_btn_title
			$wp_customize->add_setting('bizcor_nav_btn_title',
					array(
						'sanitize_callback' => 'sanitize_text_field',
						'default'           => $bizcor_options['bizcor_nav_btn_title'],
						'priority'          => 2,
					)
				);
			$wp_customize->add_control('bizcor_nav_btn_title',
				array(
					'type'        => 'text',
					'label'       => esc_html__('Navigation Button Text','bizcor'),
					'section'     => 'header_navigation',
				)
			);

			// bizcor_nav_btn_link
			$wp_customize->add_setting('bizcor_nav_btn_link',
					array(
						'sanitize_callback' => 'esc_url_raw',
						'default'           => $bizcor_options['bizcor_nav_btn_link'],
						'priority'          => 3,
					)
				);
			$wp_customize->add_control('bizcor_nav_btn_link',
				array(
					'type'        => 'text',
					'label'       => esc_html__('Navigation Button Link','bizcor'),
					'section'     => 'header_navigation',
				)
			);

			// bizcor_nav_btn_target
			$wp_customize->add_setting('bizcor_nav_btn_target',
					array(
						'sanitize_callback' => 'bizcor_sanitize_checkbox',
						'default'           => $bizcor_options['bizcor_nav_btn_target'],
						'priority'          => 4,
					)
				);
			$wp_customize->add_control('bizcor_nav_btn_target',
				array(
					'type'        => 'checkbox',
					'label'       => esc_html__('Navigation button open in new tab?','bizcor'),
					'section'     => 'header_navigation',
				)
			);

		// Header Sticky
		$wp_customize->add_section( 'header_sticky',
			array(
				'priority'    => 5,
				'title'       => esc_html__('Header Sticky','bizcor'),
				'panel'       => 'bizcor_header',
			)
		);

			// bizcor_h_sticky_disable
			$wp_customize->add_setting('bizcor_h_sticky_disable',
					array(
						'sanitize_callback' => 'bizcor_sanitize_checkbox',
						'default'           => $bizcor_options['bizcor_h_sticky_disable'],
						'priority'          => 1,
					)
				);
			$wp_customize->add_control('bizcor_h_sticky_disable',
				array(
					'type'        => 'checkbox',
					'label'       => esc_html__('Hide sticky header?','bizcor'),
					'section'     => 'header_sticky',
				)
			);
}
add_action('customize_register','bizcor_customizer_header');