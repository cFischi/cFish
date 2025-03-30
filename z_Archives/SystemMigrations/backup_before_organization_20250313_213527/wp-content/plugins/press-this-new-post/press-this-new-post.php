<?php
/**
 * Plugin Name: Press This New Post
 * Description: Adds a 'Press This' item to the '+ New' drop-down in the Toolbar for directly accessing Press This.
 * Author: Drew Jaynes
 * Author URI: http://werdswords.com
 * Version: 1.0
 * License: GPLv2 or later
 */

/**
 * Press This New Post class.
 *
 * @since 1.0
 */
class Press_This_New_Post {

	/**
	 * Constructor.
	 *
	 * @since 1.0
	 * @access public
	 */
	public function __construct() {
		add_action( 'admin_bar_menu', array( $this, 'admin_bar_menu' ), 100 );
	}

	/**
	 * Add the 'Press This' direct link to the '+ New' Toolbar drop-down.
	 *
	 * @since 1.0
	 * @access public
	 *
	 * @param WP_Admin_Bar $wp_admin_bar Toolbar instance.
	 */
	public function admin_bar_menu( $wp_admin_bar ) {
		$wp_admin_bar->add_menu( array(
			'id'     => 'press-this-new-post',
			'href'   => admin_url( 'press-this.php' ),
			'parent' => 'new-content',
			'title'  => __( 'Press This' ),
		) );
	}
}

new Press_This_New_Post();
