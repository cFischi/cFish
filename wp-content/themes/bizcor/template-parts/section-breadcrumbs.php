<?php
global $bizcor_options;
$breadcrumb_disable = get_theme_mod('bizcor_breadcrumb_disable',$bizcor_options['bizcor_breadcrumb_disable']);
$breadcrumb_title_disable = get_theme_mod('bizcor_breadcrumb_title_disable',$bizcor_options['bizcor_breadcrumb_title_disable']);
$breadcrumb_path_disable = get_theme_mod('bizcor_breadcrumb_path_disable',$bizcor_options['bizcor_breadcrumb_path_disable']);
$breadcrumb_bg_image = get_theme_mod('bizcor_breadcrumb_bg_image',$bizcor_options['bizcor_breadcrumb_bg_image']);
$breadcrumb_attachment = get_theme_mod('bizcor_breadcrumb_attachment',$bizcor_options['bizcor_breadcrumb_attachment']);
$breadcrumb_overlay = get_theme_mod('bizcor_breadcrumb_overlay',$bizcor_options['bizcor_breadcrumb_overlay']);
$effect_disable = get_theme_mod('bizcor_breadcrumb_effect_disable',$bizcor_options['bizcor_breadcrumb_effect_disable']);
if( $breadcrumb_disable == false ){
?>
<section id="breadcrumb-section" class="breadcrumb-area breadcrumb-center" style="background: url('<?php echo esc_attr($breadcrumb_bg_image); ?>') center center <?php echo esc_attr($breadcrumb_attachment); ?>;">
    <div class="container">
        <div class="row">
            <div class="col-12">
                <div class="breadcrumb-content">
                    <?php if($breadcrumb_title_disable==false){ ?>
                    <div class="breadcrumb-heading">                        
                        <h1>
                            <?php 
                            if ( is_day() ) : 
                                    
                                printf( __( 'Daily Archives: %s', 'bizcor' ), get_the_date() ); 
                            
                            elseif ( is_month() ) :
                            
                                printf( __( 'Monthly Archives: %s', 'bizcor' ), get_the_date( 'F Y' ) );
                                
                            elseif ( is_year() ) :
                            
                                printf( __( 'Yearly Archives: %s', 'bizcor' ), get_the_date( 'Y' )  );
                                
                            elseif ( is_category() ) :
                            
                                printf( __( 'Category Archives: %s', 'bizcor' ), single_cat_title( '', false ) );

                            elseif ( is_tag() ) :
                            
                                printf( __( 'Tag Archives: %s', 'bizcor' ), single_tag_title( '', false ) );
                                
                            elseif ( is_404() ) :

                                printf( __( 'Error 404', 'bizcor' ));
                                
                            elseif ( is_author() ) :
                            
                                printf( __( 'Author: %s', 'bizcor' ), get_the_author( '', false ) );

                            elseif ( is_archive() ):

                                if( is_post_type_archive() ){

                                    printf( __( '%s', 'bizcor' ), post_type_archive_title( '', false ) );

                                }else{

                                    printf( __( 'Archives: %s', 'bizcor' ), post_type_archive_title( '', false ) );

                                }

                            elseif ( is_front_page() ):

                                printf( __( 'Home', 'bizcor' ) );

                            elseif ( is_home() ):

                                single_post_title();

                            else :
                                the_title();
                            endif;
                            ?>
                        </h1>
                    </div>
                    <?php } ?>

                    <?php
                    if($breadcrumb_path_disable==false){ 
                        if( is_archive() ){
                            the_archive_description( '<div class="taxonomy-description">', '</div>' );
                        }
                    ?>
                    <ol class="breadcrumb-list">
                        <?php
                            $delimiter  = '';
                            $home       = __('Home','bizcor');
                            $showCurrent= 1;
                            $before     = '<li class="active">';
                            $after      = '</li>';
                         
                            global $post;
                            $homeLink = home_url( '/' );

                            if( is_front_page() ){
                                printf(
                                    __('<li>%s','bizcor'),
                                    esc_html($home)
                                );
                            }elseif( is_home() ){
                                printf(
                                    __('<li><a href="%1$s">%2$s</a></li>','bizcor'),
                                    esc_url($homeLink),
                                    esc_html($home)
                                );                                
                                single_post_title('<li>','</li>');
                            }else{

                                printf(
                                        __('<li><a href="%1$s">%2$s</a></li>','bizcor'),
                                        esc_url($homeLink),
                                        esc_html($home)
                                    );
                         
                                if( is_category() ){
                                    $thisCat = get_category(get_query_var('cat'), false);
                                    if ($thisCat->parent != 0) echo get_category_parents($thisCat->parent, TRUE, ' ' . ' ');
                                    echo $before . esc_html__('Archive by category','bizcor').' "' . esc_html(single_cat_title('', false)) . '"' .$after;
                                }elseif( is_search() ){
                                    echo $before . esc_html__('Search results for ','bizcor').' "' . esc_html(get_search_query()) . '"' . $after;
                                }elseif( is_day() ){
                                    echo '<li><a href="' . esc_url(get_year_link(get_the_time('Y'))) . '">' . esc_html(get_the_time('Y')) . '</a></li> ';
                                    echo '<li><a href="' . esc_url(get_month_link(get_the_time('Y'),get_the_time('m'))) . '">' . esc_html(get_the_time('F')) . '</a></li> ';
                                    echo $before . esc_html(get_the_time('d')) . $after;
                                }elseif( is_month() ){
                                    echo '<li><a href="' . esc_url(get_year_link(get_the_time('Y'))) . '">' . esc_html(get_the_time('Y')) . '</a> ' . esc_attr($delimiter);
                                    echo $before . esc_html(get_the_time('F')) . $after;
                                }elseif( is_year() ){
                                    echo $before . esc_html(get_the_time('Y')) . $after;
                                }elseif( is_single() && !is_attachment() ){
                                    if( get_post_type() != 'post' ){
                                        printf(
                                            __('<li><a href="%1$s">%2$s</a>','bizcor'),
                                            esc_url(get_post_type_archive_link( get_post_type() )),
                                            get_post_type_object(get_post_type())->labels->name
                                        );
                                        if ($showCurrent == 1) echo ' ' . esc_attr($delimiter) . $before . esc_html(get_the_title()) . $after;
                                    }else{
                                        $cat = get_the_category(); $cat = $cat[0];
                                        $cats = get_category_parents($cat, TRUE, '' . esc_attr($delimiter) . '');
                                        if ($showCurrent == 0) $cats = preg_replace("#^(.+)\s$delimiter\s$#", "$1", $cats);
                                        echo $before . $cats . $after;
                                        if ($showCurrent == 1) echo $before . esc_html(get_the_title()) . $after;
                                    }
                                }elseif( !is_single() && !is_page() && get_post_type() != 'post' && !is_404() ){
                                    if(class_exists( 'WooCommerce' ) ){
                                        if ( is_shop() ) {
                                            echo $before . woocommerce_page_title( false ) . $after;
                                        }else{
                                            if(get_post_type() == 'product'){
                                                $terms = get_the_terms(get_the_ID(), 'product_cat', '' , '' );
                                                if($terms){
                                                    echo '<li>';
                                                    the_terms( get_the_ID() , 'product_cat' , '' , ' </li><li>' );
                                                    echo ' ' . $delimiter . '<i class="fa fa-angle-double-right"></i> ' . '<span class="current">' . get_the_title() . '</span>';
                                                }else{
                                                    echo '<span class="current">' . get_the_title() . '</span>';
                                                }
                                            }
                                        }           
                                    }else{
                                        $post_type = get_post_type_object( get_post_type() );
                                        if( isset(get_post_type_object( get_post_type() )->labels->name) ){
                                            echo $before . get_post_type_object( get_post_type() )->labels->name . $after;
                                        }                           
                                    }   
                                }elseif( !is_single() && !is_page() && get_post_type() != 'post' && !is_404() ){
                                    echo $before . get_post_type_object(get_post_type())->labels->singular_name . $after;
                                }elseif( is_attachment() ){
                                    $parent = get_post($post->post_parent);
                                    $cat = get_the_category($parent->ID); 
                                    if(!empty($cat)){
                                    $cat = $cat[0];
                                    echo get_category_parents($cat, TRUE, ' ' . esc_attr($delimiter) . '');
                                    }
                                    echo '<a href="' . get_permalink($parent) . '">' . $parent->post_title . '</a>';
                                    if ($showCurrent == 1) echo ' ' . esc_attr($delimiter) . ' ' . $before . esc_html(get_the_title()) . $after;
                             
                                }elseif( is_page() && !$post->post_parent ){
                                    if ($showCurrent == 1) echo $before . esc_html(get_the_title()) . $after;
                                }elseif( is_page() && $post->post_parent ){
                                    $parent_id  = $post->post_parent;
                                    $breadcrumbs = array();
                                    while ($parent_id) {
                                        $page = get_page($parent_id);
                                        $breadcrumbs[] = '<a href="' . esc_url(get_permalink($page->ID)) . '">' . esc_html(get_the_title($page->ID)) . '</a>' . '';
                                        $parent_id  = $page->post_parent;
                                    }
                                    
                                    $breadcrumbs = array_reverse($breadcrumbs);
                                    for ($i = 0; $i < count($breadcrumbs); $i++) {
                                        echo $breadcrumbs[$i];
                                        if ($i != count($breadcrumbs)-1) echo ' ' . esc_attr($delimiter) . '';
                                    }

                                    if($showCurrent == 1) echo ' ' . esc_attr($delimiter) . ' ' . $before . esc_html(get_the_title()) . $after;
                             
                                }elseif( is_tag() ){
                                    echo $before . esc_html__('Posts tagged ','bizcor').' "' . single_tag_title('', false) . '"' . $after;
                                }elseif( is_author() ){
                                    global $author;
                                    $userdata = get_userdata($author);
                                    echo $before . esc_html__('Article posted by ','bizcor').'' . $userdata->display_name . $after;
                                }elseif( is_404() ){
                                    echo $before . esc_html__('Error 404 ','bizcor'). $after;
                                }
                                
                                if( get_query_var('paged') ){
                                    if ( is_category() || is_day() || is_month() || is_year() || is_search() || is_tag() || is_author() ) echo '';
                                    echo ' ( ' . esc_html__('Page','bizcor') . '' . esc_html(get_query_var('paged')). ' )';
                                    if ( is_category() || is_day() || is_month() || is_year() || is_search() || is_tag() || is_author() ) echo '';
                                }

                                echo '</li>';
                            }
                        ?>
                    </ol>
                    <?php } ?>
                </div>                   
            </div>
        </div>
    </div>
    <?php if( $effect_disable == false ) { ?>
    <div id="particles-js2"></div>
    <svg class="breadcrumb-waves" xmlns="http://www.w3.org/2000/svg" xlink="http://www.w3.org/1999/xlink" viewBox="0 24 150 28" preserveAspectRatio="none" shape-rendering="auto">
        <defs>
            <path id="gentle-wave" d="M-160 44c30 0 58-18 88-18s 58 18 88 18 58-18 88-18 58 18 88 18 v44h-352z"></path>
        </defs>
        <g class="waves-parallax">
            <use href="#gentle-wave" x="48" y="0" fill="rgba(var(--body-R),var(--body-G),var(--body-B),0.7"></use>
            <use href="#gentle-wave" x="48" y="3" fill="rgba(var(--body-R),var(--body-G),var(--body-B),0.5)"></use>
            <use href="#gentle-wave" x="48" y="5" fill="rgba(var(--body-R),var(--body-G),var(--body-B),0.3)"></use>
            <use href="#gentle-wave" x="48" y="7" fill="var(--body-bg-color)"></use>
        </g>
    </svg>
    <?php } ?>
</section>
<?php } ?>