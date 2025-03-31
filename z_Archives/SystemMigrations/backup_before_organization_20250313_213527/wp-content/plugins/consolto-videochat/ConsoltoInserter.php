<?php

/*
Plugin Name: Consolto Video Chat Plugin
Plugin URI: www.consolto.com
Description: The #1 video chat plugin, heavily used 1-stop-shop solution for Sales teams, consultants and coaches that want to increase conversion. Boosts video-calls, Screen sharing, payment collection via paypal, in-app chat, Whatsapp, Facebook Messenger, scheduling appointments and more...
Author: Consolto Team
License: GPLv2
License URI:  https://www.gnu.org/licenses/gpl-2.0.html
Stable tag: 2.7.7
Version: 2.7.7
Author URI: https://www.consolto.com/?utm_source=plugins&utm_medium=wordpress&utm_campaign=author_uri
*/

/**
  * Register the plugin settings panel
*/

	add_action('admin_menu', 'etwp_admin_panel_menu');

    function etwp_admin_panel_menu() {
		add_menu_page( __('Consolto Plugin','Consolto Plugin Installer' ), __( 'Consolto Plugin','Consolto Plugin Installer' ), 'manage_options', 'ConsoltoPlugin', 'etwp_embed_script', 'https://res.cloudinary.com/expertips/image/upload/v1640851574/expertipsPhotos/consolto-logo-wordpress-plugin2.svg', 50 );  
	}
	add_action('admin_head', 'consolto_stylesheet');
	function consolto_stylesheet() {
		echo '<style>
				#toplevel_page_ConsoltoPlugin .wp-menu-image img { 
					padding:0;
				}	
			</style>';
	}

	function etwp_embed_script(){
		if( isset($_POST['submit']) ) {
			$widget_id_before_regex =   $_POST['consolto_widget_link'];
		
			$pattern ='/data-widgetId=\\\"([^"]*)\\\"/';
            $pattern_new = '/\\\\\'data-widgetId\\\\\'\, \\\\\'([^\']*)\\\\\'\)/';
			$match = preg_match($pattern, $widget_id_before_regex,$matchdata);
			$match_new = preg_match($pattern_new, $widget_id_before_regex,$matchdata_new);	
			if($match == 1){
			$widget_id = $matchdata[1];
			update_option( 'consolto_script', '');
			}else{
			$widget_id = $matchdata_new[1];	
            update_option( 'consolto_script', $widget_id_before_regex );
			}
						
			$data = array(
				// 'first_name'  => sanitize_text_field( $_POST['first_name'] ),
				// 'last_name' => sanitize_text_field( $_POST['last_name'] ),
				'profile_name' => sanitize_text_field( $_POST['profile_name'] ),
				'widget_id' => sanitize_text_field($widget_id),
				'consolto_widget_link' => $widget_id_before_regex,
				// 'link' => sanitize_text_field( $_POST['link'] ),
				// 'headline' => sanitize_text_field( $_POST['headline'] ),
				// 'text'   => sanitize_text_field( $_POST['text'] )
			);
			
			//entering data into options table
			update_option( 'etwp_my_option_key', $data );
			$etwp_db_values = get_option( 'etwp_my_option_key' );
			if( $etwp_db_values ) {
			$etwp_widget_id = $etwp_db_values['widget_id'] ? $etwp_db_values['widget_id'] : '';
			}
			if($etwp_widget_id ){
					add_action('form_message', 'etwp_write_here_show_success_messages' );
			}else{
				add_action('form_message', 'etwp_write_here_show_error_messages' );
			}
		
			
			
		} ?>
<?php
		//having data from options table
		$etwp_db_values = get_option( 'etwp_my_option_key' );
		//setting empty values to avoid 'undefined index' warning
		// $etwp_first_name = '';
		// $etwp_last_name = '';
		$etwp_profile_name = '';
		$etwp_consolto_widget_link = ''; 
		$etwp_widget_id = '';
		// $etwp_link = '';
		// $etwp_headline = '';
		// $etwp_text = '';

		//if there's any data in options table, updating our variables with relevant data
		if( $etwp_db_values ) {
			// $etwp_first_name = $etwp_db_values['first_name'] ? $etwp_db_values['first_name'] : '';
			// $etwp_last_name = $etwp_db_values['last_name'] ? $etwp_db_values['last_name'] : '';
			$etwp_profile_name = $etwp_db_values['profile_name'] ? $etwp_db_values['profile_name'] : '';
			$etwp_consolto_widget_link= $etwp_db_values['consolto_widget_link'] ? $etwp_db_values['consolto_widget_link'] : '';
			$etwp_widget_id = $etwp_db_values['widget_id'] ? $etwp_db_values['widget_id'] : '';
			// $etwp_link = $etwp_db_values['link'] ? $etwp_db_values['link'] : '';
			// $etwp_headline = $etwp_db_values['headline'] ? $etwp_db_values['headline'] : '';
			// $etwp_text = $etwp_db_values['text'] ? $etwp_db_values['text'] : '';
		}
		?>
<div class="consolto-plugin-container">

  <?php screen_icon(); ?>
  <style>
  .et-wp-container {
    font-family: "Roboto";

    background: #e1e9fe;
    color: #2d2756;
    padding: 72px;
    position: relative;
    margin-left: -15px;
  }

  .et-wp-inner-wrap {
    height: 675px;
    margin: auto;
    background: #ffffff;
    box-shadow: 0px 0px 30px rgba(45, 39, 86, 0.1);
    border-radius: 20px;
    padding: 50px;
  }

  .et-wp-inner-left-wrap {
    height: 100%;
    width: 515px;
  }

  .etwp-title-wrap {
    font-weight: 700;
    font-size: 32px;
    line-height: 38px;
    /* identical to box height */
    display: flex;
    width: 100%;
    color: #2d2756;
  }

  .etwp-title-logo img {
    width: 60px;
  }

  .etwp-title-text {
    margin-left: 15px;
  }

  .etwp-title-text-blue {
    display: inline-block;
    color: #2961fa;
  }

  .etwp-h1-text {
    margin-top: 20px;
    font-weight: 700;
    font-size: 20px;
    line-height: 24px;
  }

  .etwp-few-moments {
    margin-top: 15px;
    font-weight: 500;
    font-size: 16px;
    line-height: 19px;
  }

  .etwp-features {
    margin-top: 10px;
  }

  .etwp-features-item {
    padding: 2px 0;
  }

  .etwp-excited {
    margin-top: 15px;
    font-weight: 500;
    font-size: 14px;
    line-height: 16px;
    margin-bottom: 15px;
  }

  .etwp-secondary-btn {
    display: inline-block;
    padding: 10px 15px;
    background: rgba(41, 97, 250, 0.14);
    border: 1px solid #2961fa;
    border-radius: 6px;
    color: #2961fa !important;

  }

  .etwp-secondary-btn:hover {
    color: #2961fa;
    cursor: pointer;
  }

  .etwp-script-input-wrap {
    display: flex;
    margin-top: 10px;
  }

  .etwp-script-input {
    border: 1px solid rgba(45, 39, 86, 0.2) !important;
    border-radius: 8px !important;
    width: 100%;
    padding: 0 10px;
  }

  .etwp-script-input-wrap input.button.button-primary,
  .etwp-primary-btn {
    display: inline-block;
    padding: 10px 15px;
    background: #2961fa;
    border: 1px solid #2961fa;
    border-radius: 6px;

    font-weight: 700;
    font-size: 14px;
    line-height: 16px;

    color: #ffffff;
  }

  .etwp-script-input-wrap input.button.button-primary {
    margin-left: 10px;
  }

  .etwp-script-input-wrap p.submit {
    margin: 0;
    padding: 0;
  }

  .etwp-script-input-wrap {
    min-width: 120px;
    text-align: center;
  }

  .etwp-script-installation-status {
    margin-top: 5px;
  }

  .etwp-separator {
    border-top: 1px solid #ededed;
    margin: 15px 0;
  }

  .etwp-important-notes {
    margin-top: 40px;
  }

  .etwp-small-text {
    font-style: normal;
    margin-top: 10px;
    font-weight: 500;
    font-size: 12px;
    line-height: 14px;
  }
  </style>
  <div class="et-wp-container">
    <div class="et-wp-inner-wrap">
      <div class="et-wp-inner-left-wrap">
        <div class="etwp-title-wrap">
          <div class="etwp-title-logo">
            <a href="https://www.consolto.com?utm_source=plugins&utm_medium=wordpress&utm_campaign=wp_plugin_dashboard"
              target="_blank">
              <img src="https://res.cloudinary.com/expertips/image/upload/v1681667673/expertipsPhotos/icon-svg.svg" />
            </a>
          </div>
          <div class="etwp-title-text">
            Consolto
            <div class="etwp-title-text-blue">Video Chat</div>
          </div>
        </div>
        <div class="etwp-h1-text">
          Welcome aboard!! We’re so happy you’re here!
        </div>
        <div class="etwp-few-moments">
          In a few moments you'll have the Consolto magic on your website:
        </div>
        <div class="etwp-features">
          <div class="etwp-features-item">✅ Video Chat</div>
          <div class="etwp-features-item">✅ Appointment scheduling</div>
          <div class="etwp-features-item">✅ Live chat</div>
        </div>

        <div class="etwp-excited">Excited? We definitely are...</div>
        <a target="_blank"
          href="https://www.consolto.com/knowledge-posts/wordpress-installation-instructions?utm_source=plugins&utm_medium=wordpress&utm_campaign=wp_plugin_dashboard">
          <div class="etwp-secondary-btn">Installation instructions</div>
        </a>
        <div class="etwp-separator" />
        <div class="etwp-h1-text">Paste the widget script:</div>
        <form method="post" action="">
          <?php settings_fields( 'etwp_my_option_key' ); ?>

          <div class="etwp-script-input-wrap">
            <input class="etwp-script-input" type="text" name="consolto_widget_link"
              value="<?php echo isset($_POST['consolto_widget_link']) ? "": ""; ?>" required />
            <?php  submit_button('Save changes', 'primary', 'submit'); ?>

          </div>
          <?php do_action('form_message'); ?>

        </form>

        <div class="etwp-script-installation-status">
          <?php	 echo $etwp_db_values['widget_id']?"Consolto plugin is successfully installed. Your widget Id is ".$etwp_db_values['widget_id']:"Please paste the script you received from the Consolto dashboard"; ?>
        </div>
        <div class="etwp-h1-text etwp-important-notes">
          Important notes & links
        </div>
        <div class="etwp-small-text">
          The widget script can be found in:
          <a target="_blank"
            href="https://app.consolto.com/expertHome/widgetCenter?utm_source=plugins&utm_medium=wordpress&utm_campaign=wp_plugin_dashboard">
            app.consolto.com/expertHome/widgetCenter
          </a>
          >> Installation
        </div>
        <div class="etwp-small-text">
          Not registered yet? Go to
          <a target="_blank"
            href="https://www.consolto.com/?utm_source=plugins&utm_medium=wordpress&utm_campaign=wp_plugin_dashboard">
            Consolto.com
          </a>
          and get your widget.
        </div>
        <div class="etwp-small-text">
          Still have questions? We're here to hold your hand. Feel free to
          contact us:
          <a target="_blank" href="mailto:support@consolto.com">support@consolto.com </a>
        </div>
      </div>
    </div>
  </div>
</div>
<?php
	}
	function etwp_write_here_show_success_messages( ) { ?>


<div id="setting-error-settings_updated" class="updated settings-error notice is-dismissible">
  <p><strong>Settings saved.</strong></p>
  <button type="button" class="notice-dismiss"><span class="screen-reader-text">Dismiss this notice.</span></button>
</div>


<?php }

	function etwp_write_here_show_error_messages( ) { ?>
<div id="setting-error-settings_updated" class="notice inline notice-error  is-dismissible ">
  <p><strong>Please add vaild script file</strong></p>
  <button type="button" class="notice-dismiss"><span class="screen-reader-text">Dismiss this notice.</span></button>
</div>
<?php }

	// This is where we embed the widget on pages that contain the wp_footer: 
	
	function etwp_insert_script_heade() {
		 $etwp_db_values = get_option( 'etwp_my_option_key' );
		$consolto_script = get_option( 'consolto_script');
        
	?>


<div id="et-iframe" data-version="0.5" data-wp-site="true" data-test="false"
  <?php echo $etwp_db_values['widget_id']?"data-widgetId=".$etwp_db_values['widget_id']:"data-profilename=".$etwp_db_values['profile_name']; ?>>
</div>
<?php wp_enqueue_script( 'ConsoltoInserter', 'https://client.consolto.com/iframeApp/iframeApp.js', false );?>

<?php }
	add_action( 'wp_footer', 'etwp_insert_script_heade' ); // if wp_footer exists in this page, run the etwp_insert_script_heade method. 
?>