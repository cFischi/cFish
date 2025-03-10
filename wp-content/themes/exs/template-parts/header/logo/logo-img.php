<?php
/**
 * The logo template file
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
$exs_custom_logo = ! empty ( $args['exs_custom_logo'] ) ? $args['exs_custom_logo'] : '';

if ( $exs_custom_logo ) :
	$alt = trim( strip_tags( get_post_meta( $exs_custom_logo, '_wp_attachment_image_alt', true ) ) );
	$alt = ! empty( $alt ) ? $alt : esc_attr( get_bloginfo( 'name' ) );
	$logo_max_height = exs_option( 'logo_img_max_height' );
	$logo_img_args = ! empty( $logo_max_height )
		?
		array( 'alt' => $alt, 'loading' => 'eager', 'style' => 'max-height:' . ( int ) $logo_max_height . 'px' )
		:
		array( 'alt' => $alt, 'loading' => 'eager' );
	echo wp_get_attachment_image( $exs_custom_logo, 'full', false, $logo_img_args );
endif;