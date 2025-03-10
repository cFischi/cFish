<?php
/**
 * The template for displaying top and bottom sidebars for archives and single posts if the appropriate
 * Customizer option is enabled
 *
 * @link https://developer.wordpress.org/themes/basics/template-hierarchy/
 *
 * @package WordPress
 * @subpackage ExS
 * @since 2.4.0
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit; // Exit if accessed directly
}

$args = ! empty( $args ) ? $args : array();
$default_args = array(
	'sidebar-name' => '',
);
$args = array_merge( $default_args, $args );
if ( is_active_sidebar( $args['sidebar-name'] ) ) :
	?>
	<aside class="<?php echo esc_attr( $args['sidebar-name'] ); ?>">
		<?php dynamic_sidebar( $args['sidebar-name'] ); ?>
	</aside>
<?php endif;
