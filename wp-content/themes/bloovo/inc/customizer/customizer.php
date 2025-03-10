<?php
function bloovo_site_identity_settings( $wp_customize ){
	
	global $bizcor_options;

	// bizcor_transparent_logo
	$wp_customize->add_setting('bizcor_transparent_logo',
			array(
				'sanitize_callback' => 'esc_url_raw',
				'default'           => $bizcor_options['bizcor_transparent_logo'],
			)
		);
	$wp_customize->add_control(new WP_Customize_Image_Control($wp_customize,'bizcor_transparent_logo',
		array(
			'label' 		=> esc_html__('Sticky Header Logo', 'bloovo'),
			'section' 		=> 'title_tagline',
		)
	) );
}
add_action('customize_register','bloovo_site_identity_settings');