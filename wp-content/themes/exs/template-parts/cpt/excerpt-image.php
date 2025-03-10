<?php
/**
 * Template part for displaying posts
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


$args = ! empty( $args ) ? $args : array();
$columns = ! empty( $args['columns'] );

if ( $columns ) :
?>
<div class="grid-item">
<?php endif; //columns

echo '<div>';

if ( has_post_thumbnail() ) {
	echo '<a href="' . esc_url( get_permalink() ) . '" class="exs-cpt-thumbnail">';
	the_post_thumbnail();
	echo '</a>';
}

the_title( sprintf( '<h2 class="entry-title" itemprop="headline"><a href="%s" rel="bookmark">', esc_url( get_permalink() ) ), '</a></h2>' );

the_excerpt();

wp_link_pages(
	exs_get_wp_link_pages_atts()
);

echo '</div>';
if ( $columns ) : ?>
</div><!--.grid-item-->
<?php endif; //columns ?>
