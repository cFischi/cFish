<?php

function bizcor_for_plus( $wp_customize ){
		
		$wp_customize->register_section_type( 'Bizcor_Section_Plus' );
		$wp_customize->add_section( new Bizcor_Section_Plus( $wp_customize, 'plus-bizcor' , array(
			'title'    => esc_html__( 'Upgrade To Pro', 'bizcor' ),
			'plus_text' => esc_html__( 'Click Here', 'bizcor' ),
			'plus_url'  => 'https://www.britetechs.com/theme/bizcor-pro/',
			'priority'     => 42,
		) ) );
}
add_action( 'customize_register', 'bizcor_for_plus' );