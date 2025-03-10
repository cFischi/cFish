<?php
function bizcor_customizer_error_template( $wp_customize ){

	global $bizcor_options;

		// 404 Template
		$wp_customize->add_section( 'template_error',
			array(
				'priority'    => 8,
				'title'       => esc_html__('404 Page','bizcor'),
				'panel'       => 'bizcor_custom_template',
			)
		);

			// bizcor_error_code
			$wp_customize->add_setting('bizcor_error_code',
					array(
						'sanitize_callback' => 'sanitize_text_field',
						'default'           => $bizcor_options['bizcor_error_code'],
						'priority'          => 1,
					)
				);
			$wp_customize->add_control('bizcor_error_code',
				array(
					'type'        => 'text',
					'label'       => esc_html__('Error Code', 'bizcor'),
					'section'     => 'template_error',
				)
			);

			// bizcor_error_subtitle
			$wp_customize->add_setting('bizcor_error_subtitle',
					array(
						'sanitize_callback' => 'sanitize_text_field',
						'default'           => $bizcor_options['bizcor_error_subtitle'],
						'priority'          => 2,
					)
				);
			$wp_customize->add_control('bizcor_error_subtitle',
				array(
					'type'        => 'text',
					'label'       => esc_html__('Subtitle', 'bizcor'),
					'section'     => 'template_error',
				)
			);

			// bizcor_error_title
			$wp_customize->add_setting('bizcor_error_title',
					array(
						'sanitize_callback' => 'sanitize_text_field',
						'default'           => $bizcor_options['bizcor_error_title'],
						'priority'          => 3,
					)
				);
			$wp_customize->add_control('bizcor_error_title',
				array(
					'type'        => 'text',
					'label'       => esc_html__('Title', 'bizcor'),
					'section'     => 'template_error',
				)
			);

			// bizcor_error_desc
			$wp_customize->add_setting('bizcor_error_desc',
					array(
						'sanitize_callback' => 'wp_kses_post',
						'default'           => $bizcor_options['bizcor_error_desc'],
						'priority'          => 4,
					)
				);
			$wp_customize->add_control('bizcor_error_desc',
				array(
					'type'        => 'textarea',
					'label'       => esc_html__('Description', 'bizcor'),
					'section'     => 'template_error',
				)
			);

			// bizcor_error_btn_label
			$wp_customize->add_setting('bizcor_error_btn_label',
					array(
						'sanitize_callback' => 'sanitize_text_field',
						'default'           => $bizcor_options['bizcor_error_btn_label'],
						'priority'          => 5,
					)
				);
			$wp_customize->add_control('bizcor_error_btn_label',
				array(
					'type'        => 'text',
					'label'       => esc_html__('Button Label', 'bizcor'),
					'section'     => 'template_error',
				)
			);
			
}
add_action('customize_register','bizcor_customizer_error_template');