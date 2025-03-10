<?php

function bizcor_customizer_register_controls( $wp_customize ){
	get_template_part('/inc/customizer/custom-controls/control-repeater');
	get_template_part('/inc/customizer/custom-controls/control-section-plus');
	get_template_part('/inc/customizer/custom-controls/control-reorder');
	get_template_part('/inc/customizer/custom-controls/customizer-range/class/control-range');
	$wp_customize->register_control_type( 'Bizcor_Range_Control' );
	get_template_part('/inc/customizer/custom-controls/iconpicker-control/control-icon-picker');
}
add_action('customize_register','bizcor_customizer_register_controls');