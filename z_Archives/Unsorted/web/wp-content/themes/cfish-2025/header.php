<?php
/**
 * The header for our theme
 *
 * This is the template that displays all of the <head> section and beginning of <body>
 *
 * @link https://developer.wordpress.org/themes/basics/template-files/#template-partials
 *
 * @package CFish_2025
 */

?>
<!doctype html>
<html <?php language_attributes(); ?>>
<head>
	<meta charset="<?php bloginfo( 'charset' ); ?>">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<link rel="profile" href="https://gmpg.org/xfn/11">

	<?php wp_head(); ?>
</head>

<body <?php body_class(); ?>>
<?php wp_body_open(); ?>
<div id="page" class="site">
	<a class="skip-link screen-reader-text" href="#primary"><?php esc_html_e( 'Skip to content', 'cfish-2025' ); ?></a>

	<header id="masthead" class="site-header">
		<div class="container">
			<div class="site-branding">
				<?php
				the_custom_logo();
				if ( is_front_page() && is_home() ) :
					?>
					<h1 class="site-title"><a href="<?php echo esc_url( home_url( '/' ) ); ?>" rel="home"><?php bloginfo( 'name' ); ?></a></h1>
					<?php
				else :
					?>
					<p class="site-title"><a href="<?php echo esc_url( home_url( '/' ) ); ?>" rel="home"><?php bloginfo( 'name' ); ?></a></p>
					<?php
				endif;
				$cfish_2025_description = get_bloginfo( 'description', 'display' );
				if ( $cfish_2025_description || is_customize_preview() ) :
					?>
					<p class="site-description"><?php echo $cfish_2025_description; // phpcs:ignore WordPress.Security.EscapeOutput.OutputNotEscaped ?></p>
				<?php endif; ?>
			</div><!-- .site-branding -->

			<nav id="site-navigation" class="main-navigation">
				<button class="menu-toggle" aria-controls="primary-menu" aria-expanded="false">
					<span class="menu-toggle-text"><?php esc_html_e( 'Menu', 'cfish-2025' ); ?></span>
					<span class="menu-toggle-icon">
						<span class="bar"></span>
						<span class="bar"></span>
						<span class="bar"></span>
					</span>
				</button>
				<?php
				wp_nav_menu(
					array(
						'theme_location' => 'primary',
						'menu_id'        => 'primary-menu',
						'container'      => 'div',
						'container_class' => 'menu-container',
						'fallback_cb'    => false,
					)
				);
				?>
			</nav><!-- #site-navigation -->
			
			<?php if ( function_exists( 'cfish_header_search' ) ) : ?>
				<div class="header-search">
					<?php cfish_header_search(); ?>
				</div>
			<?php endif; ?>
		</div><!-- .container -->
	</header><!-- #masthead -->

	<?php if ( has_header_image() && is_front_page() ) : ?>
		<div class="header-image-container">
			<img src="<?php header_image(); ?>" width="<?php echo esc_attr( get_custom_header()->width ); ?>" height="<?php echo esc_attr( get_custom_header()->height ); ?>" alt="" class="header-image">
			<?php if ( get_theme_mod( 'cfish_header_text' ) ) : ?>
				<div class="header-text-overlay">
					<div class="container">
						<h2><?php echo esc_html( get_theme_mod( 'cfish_header_text' ) ); ?></h2>
						<?php if ( get_theme_mod( 'cfish_header_subtext' ) ) : ?>
							<p><?php echo esc_html( get_theme_mod( 'cfish_header_subtext' ) ); ?></p>
						<?php endif; ?>
						<?php if ( get_theme_mod( 'cfish_header_button_text' ) && get_theme_mod( 'cfish_header_button_url' ) ) : ?>
							<a href="<?php echo esc_url( get_theme_mod( 'cfish_header_button_url' ) ); ?>" class="button"><?php echo esc_html( get_theme_mod( 'cfish_header_button_text' ) ); ?></a>
						<?php endif; ?>
					</div>
				</div>
			<?php endif; ?>
		</div>
	<?php endif; ?>
</body>
</html> 