<?php
/*
 * A1  Breadcrumbs
*/
global $rider_options;

  function rider_custom_breadcrumbs() {
    $rider_showonhome = 0; // 1 - show breadcrumbs on the homepage, 0 - don't show    
    $rider_showcurrent = 1; // 1 - show current post/page title in breadcrumbs, 0 - don't show 
   
    global $post;
    
    if (is_home() || is_front_page()) {
      if ($rider_showonhome == 1) echo '<li class="active"><a href="' . esc_url(home_url()) . '">' . esc_html__('Home','rider') . '</a></li>';
    } else {
      echo '<li class="active"><a href="' . esc_url(home_url()) . '">' . esc_html__('Home','rider') . '</a> ';
      if ( is_category() ) {
        $rider_thisCat = get_category(get_query_var('cat'), false);
        if ($rider_thisCat->parent != 0) echo get_category_parents($rider_thisCat->parent, TRUE, ' ');
        esc_html_e('Archive by category: ' , 'rider');  echo esc_html(single_cat_title('', false)) ;
      } elseif ( is_search() ) {
        esc_html_e('Search results for','rider'); echo esc_html(get_search_query());
      } elseif ( is_day() ) {
        echo '<a href="' . esc_url(get_year_link(get_the_time('Y'))) . '">' . esc_html(get_the_time('Y')) . '</a> ';
        echo '<a href="' . esc_url(get_month_link(get_the_time('Y'),get_the_time('m'))) . '">' . esc_html(get_the_time('F')) . '</a> ';
        echo esc_html(get_the_time('d')) ;
      } elseif ( is_month() ) {
        echo '<a href="' . esc_url(get_year_link(get_the_time('Y'))) . '">' . esc_html(get_the_time('Y')) . '</a> ';
        echo  esc_html(get_the_time('F')) ;
      } elseif ( is_year() ) {
        echo  esc_html(get_the_time('Y')) ;
      } elseif ( is_single() && !is_attachment() ) {
        if ( get_post_type() != 'post' ) {
    $rider_post_type = get_post_type_object(get_post_type());
    $rider_slug = $rider_post_type->rewrite;
    echo '<a href="' . esc_url(home_url('/' . $rider_slug['slug'] . '/')). '">' . esc_html($rider_post_type->labels->singular_name) . '</a>';
    if ($rider_showcurrent == 1) echo  esc_html(get_the_title()) ;
        } else {
    $rider_cat = get_the_category(); $rider_cat = $rider_cat[0];
    $rider_cats = get_category_parents($rider_cat, TRUE, ' ');
    if ($rider_showcurrent == 0) $rider_cats = 
    preg_replace("#^(.+)\s\s$#", "$1",$rider_cats);
    echo $rider_cats;
    if ($rider_showcurrent == 1) echo  esc_html(get_the_title()) ;
        }
      } elseif ( !is_single() && !is_page() && get_post_type() != 'post' && !is_404() ) {
        $rider_post_type = get_post_type_object(get_post_type());
        echo  $rider_post_type->labels->singular_name ;
      } elseif ( is_attachment() ) {
        $rider_parent = get_post($post->post_parent);
        $rider_cat = get_the_category($rider_parent->ID); $rider_cat = $rider_cat[0];
        echo get_category_parents($rider_cat, TRUE, ' ');
        echo '<a href="' . esc_url(get_permalink($rider_parent)) . '">' . esc_html($rider_parent->post_title) . '</a>';
        if ($rider_showcurrent == 1) echo esc_html(get_the_title()) ;
      } elseif ( is_page() && !$post->post_parent ) {
        if ($rider_showcurrent == 1) echo esc_html(get_the_title()) ;
      } elseif ( is_page() && $post->post_parent ) {
        $rider_parent_id  = $post->post_parent;
        $rider_breadcrumbs = array();
        while ($rider_parent_id) {
    $rider_page = get_page($rider_parent_id);
    $rider_breadcrumbs[] = '<a href="' . esc_url(get_permalink($rider_page->ID)) . '">' . esc_html(get_the_title($rider_page->ID)) . '</a>';
    $rider_parent_id  = $rider_page->post_parent;
        }
        $rider_breadcrumbs = array_reverse($rider_breadcrumbs);
        for ($rider_i = 0; $rider_i < count($rider_breadcrumbs); $rider_i++) {
    echo $rider_breadcrumbs[$rider_i];
    if ($rider_i != count($rider_breadcrumbs)-1) echo ' ';
        }
        if ($rider_showcurrent == 1) echo esc_html(get_the_title()) ;
      } elseif ( is_tag() ) {
        echo  esc_html__('Posts tagged','rider'); echo esc_html(single_tag_title('', false)) . '"';
      } elseif ( is_author() ) {
         global $author;
        $rider_userdata = get_userdata($author);
        echo esc_html__('Articles posted by','rider'); echo esc_html($rider_userdata->display_name) ;
      } elseif ( is_404() ) {
        echo esc_html__('Error 404','rider'); 
      }
      if ( get_query_var('paged') ) {
        if ( is_category() || is_day() || is_month() || is_year() || is_search() || is_tag() || is_author() ) echo ' (';
        echo esc_html__('Page','rider') . ' ' . esc_html(get_query_var('paged'));
        if ( is_category() || is_day() || is_month() || is_year() || is_search() || is_tag() || is_author() ) echo ')';
      }
      echo '</li>';
    }
  } // end breadcrumbs
