<?php

// Custom excerpt length
if ( ! function_exists( 'bizcor_custom_excerpt_length' ) ) :
    function bizcor_custom_excerpt_length( $length ) {
    	if( is_admin() ){
    		return $length;
    	}

    	return 20;
    }
    add_filter( 'excerpt_length', 'bizcor_custom_excerpt_length', 999 );
endif;

// Remove […]
if ( ! function_exists( 'bizcor_new_excerpt_more' ) ) :
    function bizcor_new_excerpt_more( $more ) {
    	$excerpt_readmore = sprintf(__('Read More','bizcor'));

        // If empty, return
        if ( '' == $excerpt_readmore ) {
            return $more;
        }

        return apply_filters( 'bizcor_excerpt_more_output', sprintf( ' ... <a title="%1$s" class="more-link mt-4 mb-2" href="%2$s">%3$s <i class="fa fa-angle-right"></i></a>',
            the_title_attribute( 'echo=0' ),
            esc_url( get_permalink( get_the_ID() ) ),
            wp_kses_post( $excerpt_readmore )
        ) );
    }
    add_filter('excerpt_more', 'bizcor_new_excerpt_more');
endif;

// Content Read More
if ( ! function_exists( 'bizcor_blog_content_more' ) ) {
    function bizcor_blog_content_more( $more ) {
        $excerpt_readmore = sprintf(__('Read More','bizcor'));

        // If empty, return
        if ( '' == $excerpt_readmore ) {
            return $more;
        }

        return apply_filters( 'bizcor_content_more_link_output', sprintf( '<p class="more-link-container mt-4 mb-2"><a title="%1$s" class="more-link content-more-link" href="%2$s">%3$s%4$s <i class="fa fa-angle-right"></i></a></p>',
            the_title_attribute( 'echo=0' ),
            esc_url( get_permalink( get_the_ID() ) . apply_filters( 'bizcor_more_jump','#more-' . get_the_ID() ) ),
            wp_kses_post( $excerpt_readmore ),
            '<span class="screen-reader-text">' . get_the_title() . '</span>'
        ) );
    }
    add_filter( 'the_content_more_link', 'bizcor_blog_content_more', 15 );
}

function bizcor_blog_read_more_button( $output ) {
    $archive_readmore_button = true;
    $excerpt_readmore = sprintf(__('Read More','bizcor'));

    $class='';
    if($archive_readmore_button){
        $class = 'btn btn-primary';
    }

    if ( !$archive_readmore_button ) {
        return $output;
    }

    return sprintf( '%5$s<p class="more-link-container mt-4 mb-2"><a title="%1$s" class="more-link %6$s" href="%2$s">%3$s%4$s <i class="fa fa-angle-right"></i></a></p>',
        the_title_attribute( 'echo=0' ),
        esc_url( get_permalink( get_the_ID() ) . apply_filters( 'bizcor_more_jump','#more-' . get_the_ID() ) ),
        wp_kses_post( $excerpt_readmore ),
        '<span class="screen-reader-text">' . get_the_title() . '</span>',
        'bizcor_excerpt_more_output' == current_filter() ? ' ... ' : '',
        esc_attr($class)
    );
}
add_filter( 'bizcor_excerpt_more_output', 'bizcor_blog_read_more_button' );
add_filter( 'bizcor_content_more_link_output', 'bizcor_blog_read_more_button' );

if ( ! function_exists( 'bizcor_excerpt' ) ) {
    function bizcor_excerpt( $length = 7 ) {
        global $post;
        return implode(' ', array_slice(explode(' ', get_the_excerpt()), 0, $length))."...\n";
    }
}