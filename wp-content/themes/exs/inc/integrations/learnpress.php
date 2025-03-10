<?php
/**
 * LearnPress support
 *
 * @package WordPress
 * @subpackage ExS
 * @since 1.0.3
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit; // Exit if accessed directly
}

if ( ! is_active_sidebar( 'sidebar-course' ) ) :

	//landing single course sidebar
	remove_action( 'learn-press/content-landing-summary', 'learn_press_course_meta_start_wrapper', 5 );
	remove_action( 'learn-press/content-landing-summary', 'learn_press_course_students', 10 );
	remove_action( 'learn-press/content-landing-summary', 'learn_press_course_meta_end_wrapper', 15 );

	add_action( 'exs_learnpress_course_sidebar_price_button', 'learn_press_course_meta_start_wrapper', 5 );
	add_action( 'exs_learnpress_course_sidebar_price_button', 'learn_press_course_students', 10 );
	add_action( 'exs_learnpress_course_sidebar_price_button', 'learn_press_course_meta_end_wrapper', 15 );
	add_action( 'exs_learnpress_course_sidebar_price_button', 'learn_press_course_price', 25 );
	add_action( 'exs_learnpress_course_sidebar_price_button', 'learn_press_course_buttons', 30 );

	add_action( 'learn-press/content-landing-summary', 'exs_learnpress_show_course_features_in_description', 1 );
	if ( ! function_exists( 'exs_learnpress_show_course_features_in_description' ) ) :
		function exs_learnpress_show_course_features_in_description() {
			echo '<div class="course-flex-1-3">';
			if ( class_exists( 'LP_Widget_Course_Info' ) ) {
				echo '<div class="single-course-info bordered">';
				$exs_args = array(
					'before_widget' => '',
					'after_widget'  => '',
					'before_title' => '<h3><span>',
					'after_title'  => '</span></h3>',
				);

				the_widget( 'LP_Widget_Course_Info', array(), $exs_args );

				do_action( 'exs_learnpress_course_sidebar_price_button' );

				echo '</div><!--.single-course-info-->';
				echo '<div class="course-info-wrap">';
			}
		}
	endif;

	add_action( 'learn-press/content-landing-summary', 'exs_learnpress_show_course_features_in_description_close', 100 );
	if ( ! function_exists( 'exs_learnpress_show_course_features_in_description_close' ) ) :
		function exs_learnpress_show_course_features_in_description_close() {
			if ( class_exists( 'LP_Widget_Course_Info' ) ) {
				echo '</div><!--.course-info-wrap-->';
			}

			echo '</div><!--.course-flex-1-3-->';
		}
	endif;

	//learning single course sidebar
	remove_action( 'learn-press/content-learning-summary', 'learn_press_course_meta_start_wrapper', 10 );
	remove_action( 'learn-press/content-learning-summary', 'learn_press_course_students', 15 );
	remove_action( 'learn-press/content-learning-summary', 'learn_press_course_meta_end_wrapper', 20 );
	remove_action( 'learn-press/content-learning-summary', 'learn_press_course_progress', 25 );
	remove_action( 'learn-press/content-learning-summary', 'learn_press_course_remaining_time', 30 );

	add_action( 'exs_learnpress_course_learning_sidebar', 'learn_press_course_meta_start_wrapper', 10 );
	add_action( 'exs_learnpress_course_learning_sidebar', 'learn_press_course_students', 15 );
	add_action( 'exs_learnpress_course_learning_sidebar', 'learn_press_course_meta_end_wrapper', 20 );
	add_action( 'exs_learnpress_course_learning_sidebar', 'learn_press_course_progress', 25 );
	add_action( 'exs_learnpress_course_learning_sidebar', 'learn_press_course_remaining_time', 30 );
	add_action( 'exs_learnpress_course_learning_sidebar', 'learn_press_course_buttons', 40 );

	add_action( 'learn-press/content-learning-summary', 'exs_learnpress_show_course_learning_progress', 1 );
	if ( ! function_exists( 'exs_learnpress_show_course_learning_progress' ) ) :
		function exs_learnpress_show_course_learning_progress() {
			echo '<div class="course-flex-1-3">';
			echo '<div class="single-course-info bordered">';

			echo '<h3>';
			esc_html_e( 'Course Info', 'exs' );
			echo '</h3>';

			do_action( 'exs_learnpress_course_learning_sidebar' );

			echo '</div><!--.single-course-info-->';
			echo '<div class="course-info-wrap">';

		}
	endif;

	add_action( 'learn-press/content-learning-summary', 'exs_learnpress_show_course_learning_progress_close', 100 );
	if ( ! function_exists( 'exs_learnpress_show_course_learning_progress_close' ) ) :
		function exs_learnpress_show_course_learning_progress_close() {
			echo '</div><!--.course-info-wrap-->';
			echo '</div><!--.cols-2-->';
		}
	endif;
endif; //sidebar-course


//add archive buy button - fatal error in the new versions
//add_action( 'learn-press/after-courses-loop-item', 'learn_press_course_loop_item_buttons', 35 );

//wrap default AJAX courses LP pagination with div class 'nav-links'
if ( ! function_exists( 'exs_learnpress_change_rest_courses_pagination_html' ) ) :
	function exs_learnpress_change_rest_courses_pagination_html( $response ) {
		if ( ! empty( $response ) && ! empty( $response->data ) && !empty( $response->data->pagination ) ) {
			$response->data->pagination = str_replace( 'navigation pagination"><ul', 'navigation pagination"><div class="nav-links"><ul', $response->data->pagination );
			$response->data->pagination = str_replace( '</ul>', '</ul></div>', $response->data->pagination );
		}
		return $response;
	}
endif;
add_filter('lp/rest-api/frontend/course/archive_course/response', 'exs_learnpress_change_rest_courses_pagination_html');

//wrap default SSG courses LP pagination with div class 'nav-links'
if ( ! function_exists( 'exs_learnpress_change_generated_courses_pagination_args' ) ) :
	function exs_learnpress_change_generated_courses_pagination_args( $args ) {
		if ( is_array( $args ) ) {
			$args['wrap_with_nav_links_div'] = true;
		}
		return $args;
	}
endif;
add_filter( 'learn-press/pagination_args', 'exs_learnpress_change_generated_courses_pagination_args');
if ( ! function_exists( 'exs_learnpress_change_generated_courses_pagination_html' ) ) :
	function exs_learnpress_change_generated_courses_pagination_html( $html, $args ) {
		if ( ! empty( $html ) && is_array( $args ) && ! empty( $args['wrap_with_nav_links_div'] ) ) {
			$html = str_replace( '<ul', '<div class="nav-links"><ul', $html );
			$html = str_replace( '</ul>', '</ul></div>', $html );
		}
		return $html;
	}
endif;
add_filter( 'paginate_links_output', 'exs_learnpress_change_generated_courses_pagination_html', 10, 2 );

//remove breadcrumbs. We have our own
//update - causes error on the courses category pages, so we hide it via CSS
//remove_action( 'learn-press/before-main-content', 'learn_press_breadcrumb', 10 );
