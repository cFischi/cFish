<?php
get_template_part('/inc/customizer/custom-controls/customizer-notify/customizer-notify');

$config_customizer = array(
	'recommended_plugins'       => array(
		'britetechs-companion' => array(
			'recommended' => true,
			'description' => sprintf('Install and activate <strong>Britetechs Companion</strong> plugin for taking full advantage of all the features this theme has to offer %s.', 'bizcor'),
		),
		'woocommerce' => array(
			'recommended' => true,
			'description' => sprintf('Install and activate <strong>Wocommerce</strong> plugin for taking full advantage of all the shop features this theme has to offer %s.', 'bizcor'),
		),
	),
	'recommended_actions'       => array(),
	'recommended_actions_title' => esc_html__( 'Recommended Actions', 'bizcor' ),
	'recommended_plugins_title' => esc_html__( 'Recommended Plugin', 'bizcor' ),
	'install_button_label'      => esc_html__( 'Install and Activate', 'bizcor' ),
	'activate_button_label'     => esc_html__( 'Activate', 'bizcor' ),
	'deactivate_button_label'   => esc_html__( 'Deactivate', 'bizcor' ),
);
Bizcor_Customizer_Notify::init( apply_filters( 'bizcor_customizer_notify_array', $config_customizer ) );