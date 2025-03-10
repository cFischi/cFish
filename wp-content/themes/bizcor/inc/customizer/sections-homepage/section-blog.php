<?php
function bizcor_customizer_blog_section( $wp_customize ){

	global $bizcor_options;

		// Homepage Blog
		$wp_customize->add_section( 'blog_section',
			array(
				'priority'    => 10,
				'title'       => esc_html__('Section Blog','bizcor'),
				'panel'       => 'bizcor_frontpage',
			)
		);

			// bizcor_blog_disable
			$wp_customize->add_setting('bizcor_blog_disable',
					array(
						'sanitize_callback' => 'bizcor_sanitize_checkbox',
						'default'           => $bizcor_options['bizcor_blog_disable'],
						'priority'          => 1,
					)
				);
			$wp_customize->add_control('bizcor_blog_disable',
				array(
					'type'        => 'checkbox',
					'label'       => esc_html__('Hide this section?', 'bizcor'),
					'section'     => 'blog_section',
				)
			);

			// bizcor_blog_subtitle
			$wp_customize->add_setting('bizcor_blog_subtitle',
					array(
						'sanitize_callback' => 'wp_kses_post',
						'default'           => $bizcor_options['bizcor_blog_subtitle'],
						'priority'          => 2,
					)
				);
			$wp_customize->add_control('bizcor_blog_subtitle',
				array(
					'type'        => 'text',
					'label'       => esc_html__('Subtitle', 'bizcor'),
					'section'     => 'blog_section',
				)
			);

			// bizcor_blog_title
			$wp_customize->add_setting('bizcor_blog_title',
					array(
						'sanitize_callback' => 'wp_kses_post',
						'default'           => $bizcor_options['bizcor_blog_title'],
						'priority'          => 3,
					)
				);
			$wp_customize->add_control('bizcor_blog_title',
				array(
					'type'        => 'text',
					'label'       => esc_html__('Title', 'bizcor'),
					'section'     => 'blog_section',
				)
			);

			// bizcor_blog_desc
			$wp_customize->add_setting('bizcor_blog_desc',
					array(
						'sanitize_callback' => 'wp_kses_post',
						'default'           => $bizcor_options['bizcor_blog_desc'],
						'priority'          => 4,
					)
				);
			$wp_customize->add_control('bizcor_blog_desc',
				array(
					'type'        => 'textarea',
					'label'       => esc_html__('Description', 'bizcor'),
					'section'     => 'blog_section',
				)
			);

			// bizcor_blog_show
			$wp_customize->add_setting('bizcor_blog_show',
					array(
						'sanitize_callback' => 'bizcor_sanitize_select',
						'default'           => $bizcor_options['bizcor_blog_show'],
						'priority'          => 6,
					)
				);
			$wp_customize->add_control('bizcor_blog_show',
				array(
					'type'        => 'select',
					'label'       => esc_html__('No. of posts to show', 'bizcor'),
					'section'     => 'blog_section',
					'choices'     => array(
						1 => 1,
						2 => 2,
						3 => 3,
						4 => 4,
						5 => 5,
						6 => 6,
						7 => 7,
						8 => 8,
						9 => 9,
						10 => 10,
					),
				)
			);
}
add_action('customize_register','bizcor_customizer_blog_section');