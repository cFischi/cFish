<?php
/**
 * Theme help
 *
 * Adds a simple Theme help page to the Appearance section of the WordPress Dashboard.
 *
 * @package Retail
 */

// Add Theme help page to admin menu.
add_action( 'admin_menu', 'retail_add_theme_help_page' );

function retail_add_theme_help_page() {

	// Get Theme Details from style.css
	$theme = wp_get_theme();

	add_theme_page(
		sprintf( esc_html__( 'Welcome to %1$s %2$s', 'retail' ), $theme->get( 'Name' ), $theme->get( 'Version' ) ), esc_html__( 'Retail Theme', 'retail' ), 'edit_theme_options', 'retail', 'retail_display_theme_help_page'
	);
}

// Display Theme help page.
function retail_display_theme_help_page() {

	// Get Theme Details from style.css.
	$theme = wp_get_theme();
	?>

	<div class="wrap theme-help-wrap">

		<h1><?php printf( esc_html__( 'Welcome to %1$s %2$s', 'retail' ), esc_html( $theme->get( 'Name' ) ), esc_html( $theme->get( 'Version' ) ) ); ?></h1>

		<div class="theme-description"><?php echo esc_html( $theme->get( 'Description' ) ); ?></div>

		<hr>
		<div class="important-links clearfix">
			<p><strong><?php esc_html_e( 'Theme Links', 'retail' ); ?>:</strong>
				<a href="<?php echo esc_url( 'https://uxlthemes.com/theme/retail/' ); ?>" target="_blank"><?php esc_html_e( 'Theme Page', 'retail' ); ?></a>
				<a href="<?php echo esc_url( 'https://uxlthemes.com/demo/?demo=retail' ); ?>" target="_blank"><?php esc_html_e( 'Theme Demo', 'retail' ); ?></a>
				<a href="<?php echo esc_url( 'https://wordpress.org/support/theme/retail/' ); ?>" target="_blank"><?php esc_html_e( 'Theme Support', 'retail' ); ?></a>
			</p>
		</div>
		<hr>

		<div id="getting-started">

			<h3><?php printf( esc_html__( 'Getting Started with %s', 'retail' ), esc_html( $theme->get( 'Name' ) ) ); ?></h3>

			<div class="columns-wrapper clearfix">

				<div class="column column-half clearfix">

					<div class="section">
						<h4><?php esc_html_e( 'Theme Options', 'retail' ); ?></h4>

						<p class="about">
							<?php printf( esc_html__( '%s makes use of the Customizer for the theme settings.', 'retail' ), esc_html( $theme->get( 'Name' ) ) ); ?>
						</p>
						<p>
							<a href="<?php echo esc_url( wp_customize_url() ); ?>" class="button button-primary">
								<?php esc_html_e( 'Customize Theme', 'retail' ); ?>
							</a>
						</p>
					</div>

					<div class="section">
						<h4><?php esc_html_e( 'Recommended Plugins', 'retail' ); ?></h4>

						<p class="about">
							<?php esc_html_e( 'This theme recommends the Classic Editor and Classic Widgets plugins.', 'retail' ); ?>
						</p>
						<p>
							<a href="<?php echo esc_url( get_admin_url() . 'themes.php?page=tgmpa-install-plugins' ); ?>" class="button button-primary">
								<?php esc_html_e( 'Get Recommended Plugins', 'retail' ); ?>
							</a>
						</p>
					</div>

					<div class="section">
						<h4><?php esc_html_e( 'Upgrade', 'retail' ); ?></h4>

						<p class="about">
							<?php esc_html_e( 'Upgrade to Retail Pro for even more cool features and customization options.', 'retail' ) ; ?>
						</p>
						<p>
							<a href="<?php echo esc_url( 'https://uxlthemes.com/theme/retail-pro/' ); ?>" target="_blank" class="button button-pro">
								<?php esc_html_e( 'GO PRO', 'retail' ); ?>
							</a>
						</p>
					</div>

				</div>

				<div class="column column-half clearfix">

					<img src="<?php echo esc_url( get_template_directory_uri() ); ?>/screenshot.png" />

				</div>

			</div>

			<h3><?php esc_html_e( 'The Future of WordPress', 'retail' ); ?></h3>

			<div class="columns-wrapper clearfix">

				<div class="column column-half clearfix">

					<div class="section">
						<h4><?php esc_html_e( 'Block Themes', 'retail' ); ?></h4>

						<p class="about">
							<?php esc_html_e( 'A block theme uses blocks for all parts of your site, including navigation menus, headers, content, and footers. This allows you to edit and customize all parts of your site within the Site Editor.', 'retail' ); ?>
						</p>
						<p class="about">
							<?php
							/* translators: %1$s: opening <strong> tag, %2$s: closing </strong> tag */
							printf( esc_html__( 'To help you get the most from the Site Editor and futureproof your website, we have created the %1$sEternal%2$s block theme, which can optionally be used with the Starter Sites plugin, giving you an incredible headstart when creating any website.', 'retail' ), '<strong>', '</strong>' ); ?>
						</p>
						<p>
							<a href="<?php echo esc_url( retail_eternal_admin_link() ); ?>" class="button button-secondary">
								<?php esc_html_e( 'Check out the Eternal theme', 'retail' ); ?>
							</a>
						</p>

					</div>

				</div>

				<div class="column column-half clearfix">

					<img src="<?php echo esc_url( get_template_directory_uri() ); ?>/images/eternal-screenshot.png" />

				</div>

			</div>

		</div>

		<hr>

		<div id="theme-author">

			<p>
				<?php printf( esc_html__( '%1$s is proudly brought to you by %2$s. If you like this theme, %3$s :)', 'retail' ), esc_html( $theme->get( 'Name' ) ), '<a target="_blank" href="https://uxlthemes.com/" title="UXL Themes">UXL Themes</a>', '<a target="_blank" href="https://wordpress.org/support/theme/retail/reviews/?filter=5" title="' . esc_html__( 'Retail Review', 'retail' ) . '">' . esc_html__( 'rate it', 'retail' ) . '</a>' ); ?>
			</p>

		</div>

	</div>

	<?php
}

// Add CSS for Theme help Panel.
add_action( 'admin_enqueue_scripts', 'retail_theme_help_page_css' );

function retail_theme_help_page_css( $hook ) {

	// Load styles and scripts only on theme help page.
	if ( 'appearance_page_retail' != $hook ) {
		return;
	}

	// Embed theme help css style.
	wp_enqueue_style( 'retail-theme-help-css', get_template_directory_uri() . '/css/theme-help.css' );
}

function retail_eternal_admin_link() {
	if ( wp_get_theme( 'eternal' )->exists() ) {
		return admin_url( 'themes.php?theme=eternal' );
	} else {
		return admin_url( 'theme-install.php?theme=eternal' );
	}
}

function retail_eternal_dismiss() {
	if ( isset( $_GET['retail-eternal-dismiss'] ) && check_admin_referer( 'retail-eternal-dismiss-' . get_current_user_id() ) ) {
		update_user_meta( get_current_user_id(), 'retail_eternal_dismissed_notice', 1 );
	}
}
add_action( 'admin_head', 'retail_eternal_dismiss' );

function retail_eternal_nudge() {
	return '<span style="display: block; font-size: 1.2em; margin: 0.5em 0.5em 1em 0; clear: both;">' . esc_html__( 'The future of WordPress is block themes.', 'retail' ) . '</span>
		<span style="display: block; font-weight: normal; margin: 1em 0.5em 1em 0; clear: both;">' . esc_html__( 'A block theme uses blocks for all parts of your site, including navigation menus, headers, content, and footers. This allows you to edit and customize all parts of your site within the Site Editor.', 'retail' ) . '</span>
		<span style="display: block; font-weight: normal; margin: 1em 0.5em 1em 0; clear: both;">' . 
		/* translators: %1$s: opening <strong> tag, %2$s: closing </strong> tag */
		sprintf( esc_html__( 'To help you get the most from the Site Editor and futureproof your website, we have created the %1$sEternal%2$s block theme, which can optionally be used with the Starter Sites plugin, giving you an incredible headstart when creating any website.', 'retail' ), '<strong>', '</strong>' ) . '</span>
		<span style="display: block; font-weight: normal; margin: 1em 0.5em 1em 0; clear: both;"><a href="' . esc_url( retail_eternal_admin_link() ) . '" class="button button-primary">' . esc_html__( 'Check out the Eternal theme', 'retail' ) . '</a></span>
		<span style="display: block; font-weight: normal; margin: 1em 0.5em 1em 0; clear: both;"><a href="' . esc_url( wp_nonce_url( add_query_arg( 'retail-eternal-dismiss', 'dismiss_admin_notices' ), 'retail-eternal-dismiss-' . get_current_user_id() ) ) . '" class="dismiss-notice" target="_parent">' . esc_html__( 'Permanently dismiss this notice', 'retail' ) . '</a></span>';
}

function retail_admin_notice() {
	if (  get_user_meta( get_current_user_id(), 'retail_eternal_dismissed_notice', true )  ) {
		return;
	}
	add_settings_error( 'retail-eternal-notice', 'retail-eternal-notice', retail_eternal_nudge(), 'info' );
	settings_errors( 'retail-eternal-notice' );
}
add_action( 'admin_notices', 'retail_admin_notice' );
