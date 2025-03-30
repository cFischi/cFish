<?php
/**
 * The template for displaying the footer
 *
 * Contains the closing of the #page div and all content after.
 *
 * @link https://developer.wordpress.org/themes/basics/template-files/#template-partials
 *
 * @package CFish_2025
 */

?>

	<footer id="colophon" class="site-footer">
		<div class="container">
			<div class="footer-widgets">
				<div class="footer-widget-area">
					<?php if ( is_active_sidebar( 'footer-1' ) ) : ?>
						<div class="footer-widget footer-widget-1">
							<?php dynamic_sidebar( 'footer-1' ); ?>
						</div>
					<?php endif; ?>
				</div>
				<div class="footer-widget-area">
					<?php if ( is_active_sidebar( 'footer-2' ) ) : ?>
						<div class="footer-widget footer-widget-2">
							<?php dynamic_sidebar( 'footer-2' ); ?>
						</div>
					<?php endif; ?>
				</div>
				<div class="footer-widget-area">
					<?php if ( is_active_sidebar( 'footer-3' ) ) : ?>
						<div class="footer-widget footer-widget-3">
							<?php dynamic_sidebar( 'footer-3' ); ?>
						</div>
					<?php endif; ?>
				</div>
			</div><!-- .footer-widgets -->
			
			<div class="footer-navigation">
				<?php
				wp_nav_menu(
					array(
						'theme_location' => 'footer',
						'menu_id'        => 'footer-menu',
						'depth'          => 1,
						'fallback_cb'    => false,
					)
				);
				?>
			</div><!-- .footer-navigation -->
			
			<div class="site-info">
				<?php
				$cfish_footer_text = get_theme_mod( 'cfish_footer_text' );
				if ( $cfish_footer_text ) :
					echo wp_kses_post( $cfish_footer_text );
				else :
					/* translators: %s: Current year and site name */
					printf( esc_html__( '© %s cFish.io. All rights reserved.', 'cfish-2025' ), date_i18n( 'Y' ) );
				endif;
				?>
				
				<span class="sep"> | </span>
				
				<?php
				/* translators: %1$s: Theme name, %2$s: Theme author website */
				printf( esc_html__( 'Theme: %1$s by %2$s', 'cfish-2025' ), 'CFish 2025', '<a href="https://cfish.io/">tY FischEYe</a>' );
				?>
			</div><!-- .site-info -->
			
			<?php if ( has_nav_menu( 'social' ) ) : ?>
				<div class="social-navigation">
					<?php
					wp_nav_menu(
						array(
							'theme_location' => 'social',
							'menu_id'        => 'social-menu',
							'depth'          => 1,
							'link_before'    => '<span class="screen-reader-text">',
							'link_after'     => '</span>',
							'fallback_cb'    => false,
						)
					);
					?>
				</div><!-- .social-navigation -->
			<?php endif; ?>
		</div><!-- .container -->
	</footer><!-- #colophon -->
</div><!-- #page -->

<?php wp_footer(); ?>

</body>
</html> 