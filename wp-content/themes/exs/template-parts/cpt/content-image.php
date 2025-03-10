<?php
/**
 * The template for displaying all default single posts
 *
 * @link https://developer.wordpress.org/themes/basics/template-hierarchy/#single-post
 *
 * @package WordPress
 * @subpackage ExS
 * @since 0.0.1
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit; // Exit if accessed directly
}

the_post_thumbnail();

the_title( '<h1 class="entry-title" itemprop="headline"><span>', '</span></h1>' );

the_content();

wp_link_pages(
	exs_get_wp_link_pages_atts()
);
