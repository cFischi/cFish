<?php
class Bizcor_Customizer_Notify {

	private $recommended_actions;
	private $recommended_plugins;
	private static $instance;
	private $recommended_actions_title;
	private $recommended_plugins_title;
	private $dismiss_button;
	private $install_button_label;
	private $activate_button_label;
	private $deactivate_button_label;
	private $config;

	public static function init( $config ) {
		if ( ! isset( self::$instance ) && ! ( self::$instance instanceof Bizcor_Customizer_Notify ) ) {
			self::$instance = new Bizcor_Customizer_Notify;
			if ( ! empty( $config ) && is_array( $config ) ) {
				self::$instance->config = $config;
				self::$instance->setup_config();
				self::$instance->setup_actions();
			}
		}

	}

	public function setup_config() {

		global $bizcor_customizer_notify_recommended_plugins;
		global $bizcor_customizer_notify_recommended_actions;

		global $install_button_label;
		global $activate_button_label;
		global $deactivate_button_label;

		$this->recommended_actions = isset( $this->config['recommended_actions'] ) ? $this->config['recommended_actions'] : array();
		$this->recommended_plugins = isset( $this->config['recommended_plugins'] ) ? $this->config['recommended_plugins'] : array();

		$this->recommended_actions_title = isset( $this->config['recommended_actions_title'] ) ? $this->config['recommended_actions_title'] : '';
		$this->recommended_plugins_title = isset( $this->config['recommended_plugins_title'] ) ? $this->config['recommended_plugins_title'] : '';
		$this->dismiss_button            = isset( $this->config['dismiss_button'] ) ? $this->config['dismiss_button'] : '';

		$bizcor_customizer_notify_recommended_plugins = array();
		$bizcor_customizer_notify_recommended_actions = array();

		if ( isset( $this->recommended_plugins ) ) {
			$bizcor_customizer_notify_recommended_plugins = $this->recommended_plugins;
		}

		if ( isset( $this->recommended_actions ) ) {
			$bizcor_customizer_notify_recommended_actions = $this->recommended_actions;
		}

		$install_button_label    = isset( $this->config['install_button_label'] ) ? $this->config['install_button_label'] : '';
		$activate_button_label   = isset( $this->config['activate_button_label'] ) ? $this->config['activate_button_label'] : '';
		$deactivate_button_label = isset( $this->config['deactivate_button_label'] ) ? $this->config['deactivate_button_label'] : '';
	}

	public function setup_actions() {
		// Register the section
		add_action( 'customize_register', array( $this, 'bizcor_plugin_notification_customize_register' ) );

		// Enqueue scripts and styles
		add_action( 'customize_controls_enqueue_scripts', array( $this, 'bizcor_customizer_notify_scripts_for_customizer' ), 0 );

		/* ajax callback for dismissable recommended actions */
		add_action( 'wp_ajax_bizcor_customizer_notify_dismiss_action', array( $this, 'bizcor_customizer_notify_dismiss_recommended_action_callback' ) );

		add_action( 'wp_ajax_bizcor_customizer_notify_dismiss_recommended_plugins', array( $this, 'bizcor_customizer_notify_dismiss_recommended_plugins_callback' ) );
	}

	
	public function bizcor_customizer_notify_scripts_for_customizer() {
		wp_enqueue_style( 'bizcor-customizer-notify-css', get_template_directory_uri() . '/inc/customizer/custom-controls/customizer-notify/css/notify.css', array());

		wp_enqueue_style( 'plugin-install' );
		wp_enqueue_script( 'plugin-install' );
		wp_add_inline_script( 'plugin-install', 'var bizcor_pagenow = "customizer";' );

		wp_enqueue_script( 'updates' );

		wp_enqueue_script( 'bizcor-customizer-notify-js', get_template_directory_uri() . '/inc/customizer/custom-controls/customizer-notify/js/notify.js', array( 'customize-controls' ));
		wp_localize_script(
			'bizcor-customizer-notify-js', 'bizcorCustomizercompanionObject', array(
				'ajaxurl'            => admin_url( 'admin-ajax.php' ),
				'template_directory' => get_template_directory_uri(),
				'base_path'          => admin_url(),
				'activating_string'  => __( 'Activating', 'bizcor' ),
			)
		);
	}

	
	public function bizcor_plugin_notification_customize_register( $wp_customize ) {
		
		require get_parent_theme_file_path('/inc/customizer/custom-controls/customizer-notify/customizer-notify-section.php');

		$wp_customize->register_section_type( 'Bizcor_Customizer_Notify_Section' );
		$wp_customize->add_section(
			new Bizcor_Customizer_Notify_Section(
				$wp_customize,
				'bizcor-customizer-notify-section',
				array(
					'title'          => $this->recommended_actions_title,
					'plugin_text'    => $this->recommended_plugins_title,
					'dismiss_button' => $this->dismiss_button,
					'priority'       => 0,
				)
			)
		);
	}

	public function bizcor_customizer_notify_dismiss_recommended_action_callback() {
		global $bizcor_customizer_notify_recommended_actions;

		$option = wp_parse_args(  get_option( 'bizcor_option', array() ), array() );

		$action_id = ( isset( $_GET['id'] ) ) ? $_GET['id'] : 0;

		echo esc_html( $action_id ); 

		if ( ! empty( $action_id ) ) {

			
			if ( $option['bizcor_customizer_notify_show'] != '' ) {

				$bizcor_customizer_notify_show_recommended_actions = $option['bizcor_customizer_notify_show'];
				switch ( $_GET['todo'] ) {
					case 'add':
						$bizcor_customizer_notify_show_recommended_actions[ $action_id ] = true;
						break;
					case 'dismiss':
						$bizcor_customizer_notify_show_recommended_actions[ $action_id ] = false;
						break;
				}
				$option['bizcor_customizer_notify_show'] = $bizcor_customizer_notify_show_recommended_actions;
				update_option('bizcor_option',$option);
				
			} else {
				$bizcor_customizer_notify_show_recommended_actions = array();
				if ( ! empty( $bizcor_customizer_notify_recommended_actions ) ) {
					foreach ( $bizcor_customizer_notify_recommended_actions as $bizcor_customizer_notify_recommended_action ) {
						if ( $bizcor_customizer_notify_recommended_action['id'] == $action_id ) {
							$bizcor_customizer_notify_show_recommended_actions[ $bizcor_customizer_notify_recommended_action['id'] ] = false;
						} else {
							$bizcor_customizer_notify_show_recommended_actions[ $bizcor_customizer_notify_recommended_action['id'] ] = true;
						}
					}
					$option['bizcor_customizer_notify_show'] = $bizcor_customizer_notify_show_recommended_actions;
					update_option('bizcor_option',$option);
				}
			}
		}
		die(); 
	}

	public function bizcor_customizer_notify_dismiss_recommended_plugins_callback() {

		$action_id = ( isset( $_GET['id'] ) ) ? $_GET['id'] : 0;

		$option = wp_parse_args(  get_option( 'bizcor_option', array() ), array() );

		echo esc_html( $action_id ); 

		if ( ! empty( $action_id ) ) {

			$bizcor_customizer_notify_show_recommended_plugins = $option['bizcor_customizer_notify_show_recommended_plugins'];

			switch ( $_GET['todo'] ) {
				case 'add':
					$bizcor_customizer_notify_show_recommended_plugins[ $action_id ] = false;
					break;
				case 'dismiss':
					$bizcor_customizer_notify_show_recommended_plugins[ $action_id ] = true;
					break;
			}
			$option['bizcor_customizer_notify_show_recommended_plugins'] = $bizcor_customizer_notify_show_recommended_plugins;
			update_option('bizcor_option',$option);
		}
		die(); 
	}

}