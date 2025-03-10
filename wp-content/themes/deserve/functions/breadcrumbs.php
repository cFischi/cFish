<?php
/*
 * deserve Breadcrumbs
*/
function deserve_custom_breadcrumbs() {

  $deserve_showonhome = 0; // 1 - show breadcrumbs on the homepage, 0 - don't show
  $deserve_delimiter = '/'; // deserve_delimiter between crumbs
  $deserve_home = __('Home','deserve'); // text for the 'Home' link
  $deserve_showcurrent = 1; // 1 - show current post/page title in breadcrumbs, 0 - don't show
  $deserve_before = ' '; // tag before the current crumb
  $deserve_after = ' '; // tag after the current crumb

  global $post;
  $deserve_homelink = esc_url(home_url());

  if (is_home() || is_front_page()) {

    if ($deserve_showonhome == 1){
      printf(/* translators: %1$s is home url, %2$s is Home title */
        wp_kses_post('<li><a href="%1$s">%2$s</a></li>'),esc_url(home_url()),esc_html__('Home','deserve'));
    }

  } else {
     printf(/* translators: %1$s is home url, %2$s is Home title , %3$s is Delimiter*/
        wp_kses_post('<li><a href="%1$s">%2$s</a> %3$s '),
        esc_url(home_url()),esc_html__('Home','deserve'),esc_html($deserve_delimiter));

    if ( is_category() ) {
      $deserve_thisCat = get_category(get_query_var('cat'), false);
      if ($deserve_thisCat->parent != 0) echo wp_kses_post(get_category_parents($deserve_thisCat->parent, TRUE, ' ' . $deserve_delimiter . ' ')); 
      printf(/* translators: %s is Single title */
        esc_html__(' Archive by category "%s" ','deserve'), esc_html(single_cat_title('', false)) );

     } elseif ( is_search() ) {      
	     printf(/* translators: %s is Search Title */
        esc_html__(' Search results for "%s" ','deserve'), esc_html(get_search_query()) );

    } elseif ( is_day() ) {
       printf(/* translators: %1$s is Year Url,%2$s is year,%3$s is delimiter */
        wp_kses_post('<a href="%1$s">%2$s</a> %3$s '),
        esc_url(get_year_link(get_the_time('Y'))) ,esc_html(get_the_time('Y')),esc_html($deserve_delimiter) );

      printf(/* translators: %1$s is month Url,%2$s is month, %3$s is delimiter ,, %4$s is date */
        wp_kses_post('<a href="%1$s">%2$s</a> %3$s  %4$s '),
        esc_url(get_month_link(get_the_time('Y'),get_the_time('m'))) ,esc_html(get_the_time('F')),esc_html($deserve_delimiter),esc_html(get_the_time('d')) );
    } elseif ( is_month() ) {
      printf(/* translators: %1$s is Year Url,%2$s is year,%3$s is delimiter ,%4$s is month*/
        wp_kses_post('<a href="%1$s">%2$s</a> %3$s %4$s '),
        esc_url(get_year_link(get_the_time('Y'))) ,esc_html(get_the_time('Y')),esc_html($deserve_delimiter),esc_html(get_the_time('F')) );     

    } elseif ( is_year() ) { ?>
      &nbsp;<?php echo esc_html(get_the_time('Y')); ?>&nbsp;
    <?php } elseif ( is_single() && !is_attachment() ) {
      if ( get_post_type() != 'post' ) {
        $deserve_post_type = get_post_type_object(get_post_type());
        $deserve_slug = $deserve_post_type->rewrite;
        printf(/* translators: %1$s is slug url,%2$s is single name */
        wp_kses_post('<a href="%1$s">%2$s</a> %3$s'),
        esc_url(home_url('/'.$deserve_slug['slug'])) ,esc_html($deserve_post_type->labels->singular_name) ,esc_html($deserve_delimiter));        
          if ($deserve_showcurrent == 1) { ?>
            &nbsp;<?php echo esc_html(get_the_title()); ?>&nbsp;
          <?php }
      } else {
        $deserve_cat = get_the_category(); $deserve_cat = $deserve_cat[0];
        $deserve_cats = get_category_parents($deserve_cat, TRUE, ' ' . $deserve_delimiter . ' ');
        if ($deserve_showcurrent == 0) $deserve_cats = preg_replace("#^(.+)\s$deserve_delimiter\s$#", "$1", $deserve_cats);
        echo wp_kses_post($deserve_cats);
          if ($deserve_showcurrent == 1) { ?>
            &nbsp;<?php echo esc_html(get_the_title()); ?>&nbsp;
          <?php } 
      }
    } elseif ( !is_single() && !is_page() && get_post_type() != 'post' && !is_404() ) {
      $deserve_post_type = get_post_type_object(get_post_type());     ?>
            &nbsp;<?php echo esc_html($deserve_post_type->labels->singular_name); ?>&nbsp;
      <?php
    } elseif ( is_attachment() ) {
      $deserve_parent = get_post($post->post_parent);
      $deserve_cat = get_the_category($deserve_parent->ID); $deserve_cat = $deserve_cat[0];
      echo wp_kses_post(get_category_parents($deserve_cat, TRUE, ' ' . $deserve_delimiter . ' '));
      printf(/* translators: %1$s is slug url,%2$s is single name */
        wp_kses_post('<a href="%1$s">%2$s</a> %3$s '),
        esc_url(get_permalink($deserve_parent)) ,esc_html($deserve_parent->post_title) ,esc_html($deserve_delimiter));        
      if ($deserve_showcurrent == 1) { ?>
            &nbsp;<?php echo esc_html(get_the_title()); ?>&nbsp;
       <?php } 
    } elseif ( is_page() && !$post->post_parent ) {
      if ($deserve_showcurrent == 1) { ?>
            &nbsp;<?php echo esc_html(get_the_title()); ?>&nbsp;
      <?php } 
    } elseif ( is_page() && $post->post_parent ) {
      $deserve_parent_id  = $post->post_parent;
      $deserve_breadcrumbs = array();
      while ($deserve_parent_id) {
        $deserve_page = get_page($deserve_parent_id);
        $deserve_breadcrumbs[] = sprintf(/* translators: %1$s is url,%2$s is single name */
        wp_kses_post('<a href="%1$s">%2$s</a>'),
        esc_url(get_permalink($deserve_page->ID)) ,esc_html(get_the_title($deserve_page->ID)));   
        $deserve_parent_id  = $deserve_page->post_parent;
      }
      $deserve_breadcrumbs = array_reverse($deserve_breadcrumbs);
      for ($deserve_i = 0; $deserve_i < count($deserve_breadcrumbs); $deserve_i++) {
        echo wp_kses_post($deserve_breadcrumbs[$deserve_i]);
        if ($deserve_i != count($deserve_breadcrumbs)-1) echo ' ' . esc_html($deserve_delimiter) . ' ';
      }
      if ($deserve_showcurrent == 1) echo ' ' . esc_html($deserve_delimiter); ?>
            &nbsp;<?php echo esc_html(get_the_title()); ?>&nbsp;
      <?php
    } elseif ( is_tag() ) {     
     printf(/* translators: %s is single tag name  */
        esc_html__(' Posts tagged "%s" ','deserve'), esc_html(single_tag_title('', false)) );


    } elseif ( is_author() ) {
       global $author;
      $deserve_userdata = get_userdata($author);
      printf(/* translators: %s is user name */
        esc_html__(' Articles posted by "%s" ','deserve'), esc_html($deserve_userdata->display_name) );

    } elseif ( is_404() ) { ?>
      &nbsp;<?php esc_html_e('Error 404','deserve'); ?>&nbsp;
    <?php }
    if ( get_query_var('paged') ) {
      if ( is_category() || is_day() || is_month() || is_year() || is_search() || is_tag() || is_author() ) echo ' (';
      printf(/* translators: %s is search query */
        esc_html__(' Page %s ','deserve'), esc_html(get_query_var('paged')) );
      if ( is_category() || is_day() || is_month() || is_year() || is_search() || is_tag() || is_author() ) echo ')';
    }

    echo '</li>';

  }
} // end deserve_custom_breadcrumbs()
