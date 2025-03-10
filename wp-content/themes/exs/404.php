<?php
/**
 * The 404 page template file
 *
 * @link https://developer.wordpress.org/themes/basics/template-hierarchy/
 *
 * @package WordPress
 * @subpackage ExS
 * @since 0.0.1
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit; // Exit if accessed directly
}

get_header();

$heading = exs_option( '404_heading', esc_html__( '404', 'exs' ) );
$subheading = exs_option( '404_subheading', esc_html__( 'Oops, page not found!', 'exs' ) );
$text_top = exs_option( '404_text_top', esc_html__( 'You can search what interested:', 'exs' ) );
$show_searchform = exs_option( '404_show_searchform', true );
$text_bottom = exs_option( '404_text_bottom', esc_html__( 'Or', 'exs' ) );
$text_button = exs_option( '404_text_button', esc_html__( 'Go To Home', 'exs' ) );
$text_button_url = exs_option( '404_text_button_url' );
if ( empty( $text_button_url ) ) {
	$text_button_url = home_url( '/' );
}

//since 2.5.3
$exs_fluid = exs_option( '404_fluid' ) ? '-fluid' : '';

$exs_404_background = exs_option( '404_background', '' );
$exs_extra_padding_top     = exs_option( '404_extra_padding_top', '' );
$exs_extra_padding_bottom  = exs_option( '404_extra_padding_bottom', '' );

$exs_border_top    = exs_option( '404_border_top', '' );
$exs_border_bottom = exs_option( '404_border_bottom', '' );
$exs_font_size     = exs_option( '404_font_size', '' );

$exs_background_image = exs_section_background_image_array( '404' );

?>
<div id="main"
		 class="main section-404 container-720 <?php echo esc_attr( $exs_404_background . ' ' . $exs_font_size . ' ' . $exs_background_image['class'] ); ?>"
	<?php echo ( ! empty( $exs_background_image['url'] ) ) ? 'style="background-image: url(' . esc_url( $exs_background_image['url'] ) . ');' . esc_attr( $exs_background_image['overlay'] ) . '"' : ''; ?>
>
<?php
if ( 'full' === $exs_border_top ) {
	?>
	<hr class="section-hr">
	<?php
}
?>
	<div class="container<?php echo esc_attr( $exs_fluid . ' ' . $exs_extra_padding_top . ' ' . $exs_extra_padding_bottom ); ?>">
		<?php
		if ( 'container' === $exs_border_top ) {
			?>
			<hr class="section-hr">
			<?php
		}
		?>
			<main>
				<div id="layout" class="text-center">
					<div class="wrap-404">
						<?php if ( ! empty( $heading ) ) :  ?>
						<h2 class="not_found mb-0 animate an__fadeInDown">
							<span class="has-huge-font-size"><?php echo esc_html( $heading ); ?></span>
						</h2>
						<?php endif; ?>
						<?php if ( ! empty( $subheading ) ) : ?>
							<h5 class=" animate an__fadeInDown">
								<?php echo esc_html( $subheading ); ?>
							</h5>
						<?php endif; ?>
						<?php if ( ! empty( $text_top ) ) : ?>
							<p class="animate an__fadeInLeft">
								<?php echo esc_html( $text_top ); ?>
							</p>
						<?php endif; ?>
						<?php if ( ! empty( $show_searchform ) ) : ?>
							<div class="widget widget_search mb-1 animate an__fadeInLeft">
								<?php get_search_form(); ?>
							</div>
						<?php endif; ?>
						<?php if ( ! empty( $text_bottom ) ) : ?>
							<p class="mb-1 animate an__fadeInUp">
								<?php echo esc_html( $text_bottom ); ?>
							</p>
						<?php endif; ?>
						<p class="mb-0 animate an__fadeInUp">
							<a href="<?php echo esc_url( $text_button_url ); ?>" class="btn wp-block-button__link">
								<?php echo esc_html( $text_button ); ?>
							</a>
						</p>
					</div>

				</div><!-- #layout -->
			</main>
		<?php
		if ( 'container' === $exs_border_bottom ) {
			?>
			<hr class="section-hr">
			<?php
		}
		?>
		</div><!-- .container -->
	<?php
	if ( 'full' === $exs_border_bottom ) {
		?>
		<hr class="section-hr">
		<?php
	}
	?>
	</div><!-- #main -->
<?php
get_footer();
