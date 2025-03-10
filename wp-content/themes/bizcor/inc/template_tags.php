<?php

if ( ! function_exists( 'bizcor_logo' ) ) {
    function bizcor_logo(){
        $class = array();
        $html = '';
        
        if ( function_exists( 'has_custom_logo' ) ) {
            if ( has_custom_logo()) {
                $html .= get_custom_logo();
            }else{
                $html .= '<h1 class="site_title"><a href="'.esc_url( home_url( '/' ) ).'" rel="home">' . get_bloginfo('name') . '</a></h1>';
                
                $description = get_bloginfo( 'description', 'display' );
                if ( $description || is_customize_preview() ) {
                    $html .= '<p class="site_desc">'.$description.'</p>';
                }
            }
        }
        ?>
        <div class="site_logo <?php echo esc_attr( join( ' ', $class ) ); ?>"><?php echo wp_kses_post($html); ?></div>
        <?php
    }
}

// Adding new body classes
function bizcor_body_classes( $classes ) {

    global $bizcor_options;
    $layout = get_theme_mod('bizcor_layout',$bizcor_options['bizcor_layout']);

    if($layout=='boxed'){
        $classes[] = 'boxed';
    }

    return $classes;
}
add_filter( 'body_class', 'bizcor_body_classes' );

if ( ! function_exists( 'bizcor_get_media_url' ) ) {
    function bizcor_get_media_url( $media = array(), $size = 'full' ) {

        $media = wp_parse_args( $media, array('url' => '', 'id' => '') );
        $url = '';

        if ($media['id'] != '') {
            if ( strpos( get_post_mime_type( $media['id'] ), 'image' ) !== false ) {
                $image = wp_get_attachment_image_src( $media['id'],  $size );
                if ( $image ){
                    $url = $image[0];
                }
            } else {
                $url = wp_get_attachment_url( $media['id'] );
            }
        }

        if ($url == '' && $media['url'] != '') {
            $id = attachment_url_to_postid( $media['url'] );
            if ( $id ) {
                if ( strpos( get_post_mime_type( $id ), 'image' ) !== false ) {
                    $image = wp_get_attachment_image_src( $id,  $size );
                    if ( $image ){
                        $url = $image[0];
                    }
                } else {
                    $url = wp_get_attachment_url( $id );
                }
            } else {
                $url = $media['url'];
            }
        }
        return $url;
    }
}

function bizcor_filter_wp_list_pages_item_classes( $css_class, $page, $depth, $args, $current_page ) {
    // Only apply to wp_list_pages() calls with match_menu_classes set to true.
    $match_menu_classes = isset( $args['match_menu_classes'] );

    if ( ! $match_menu_classes ) {
        return $css_class;
    }

    // Add current menu item class.
    if ( in_array( 'current_page_item', $css_class, true ) ) {
        $css_class[] = 'current-menu-item';
    }

    // Add menu item has children class.
    if ( in_array( 'page_item_has_children', $css_class, true ) ) {
        $css_class[] = 'menu-item-has-children';
    }

    if( in_array( 'page_item', $css_class, true ) ){
    	$css_class[] = 'menu-item';
    }

    return $css_class;
}
add_filter( 'page_css_class', 'bizcor_filter_wp_list_pages_item_classes', 10, 5 );

function bizcor_add_sub_toggles_to_main_menu( $args, $item, $depth ) {
    // Add sub menu toggles to the Expanded Menu with toggles.
    if ( isset( $args->show_toggles ) && $args->show_toggles ) {

        // Wrap the menu item link contents in a div, used for positioning.
        $args->before = '<div class="ancestor-wrapper">';
        $args->after  = '';

        // Add a toggle to items with children.
        if ( in_array( 'menu-item-has-children', $item->classes, true ) ) {

            $toggle_target_string = '.menu-modal .menu-item-' . $item->ID . ' > .sub-menu';
            $toggle_duration      = bizcor_toggle_duration();

            // Add the sub menu toggle.
            $args->after .= '<button class="toggle sub-menu-toggle fill-children-current-color" data-toggle-target="' . $toggle_target_string . '" data-toggle-type="slidetoggle" data-toggle-duration="' . absint( $toggle_duration ) . '" aria-expanded="false"><span class="screen-reader-text">' . __( 'Show sub menu', 'bizcor' ) . '</span><i class="fa fa-caret-down"></i></button>';

        }

        // Close the wrapper.
        $args->after .= '</div><!-- .ancestor-wrapper -->';

        // Add sub menu icons to the primary menu without toggles.
    } elseif ( 'primary' === $args->theme_location || 'secondary' === $args->theme_location ) {
        if ( in_array( 'menu-item-has-children', $item->classes, true ) ) {
            $args->after = '<span class="mobile-collapsed d-lg-none"><button type="button" class="fas fa-angle-right" aria-expanded="false" aria-label="Mobile Collapsed"></button></span>';
        } else {
            $args->after = '';
        }
    }

    return $args;
}
add_filter( 'nav_menu_item_args', 'bizcor_add_sub_toggles_to_main_menu',10,3);

function bizcor_toggle_duration(){
    $duration = apply_filters( 'bizcor_toggle_duration',250);
    return $duration;
}

function bizcor_nav_menu_submenu_css_class( $classes ) {
    $classes[] = 'dropdown-menu';
    return $classes;
}
add_filter( 'nav_menu_submenu_css_class', 'bizcor_nav_menu_submenu_css_class' );

function bizcor_header_topbar_data(){
    $items = get_theme_mod('bizcor_topbar_content');

    if(is_string($items)){
        $items = json_decode($items);
    }

    if ( empty( $items ) || !is_array( $items ) ) {
        $items = array();
    }

    $texts = array();
    if (!empty($items) && is_array($items)) {
        foreach ($items as $k => $v) {
            $texts[] = wp_parse_args($v,array(
                        'text'=> '',
                    ));
        }
    }else{
        $texts = bizcor_header_topbar_default_data();
    }

    return $texts;
}

function bizcor_header_topbar_icons_data(){
    $items = get_theme_mod('bizcor_topbar_icons');

    if(is_string($items)){
        $items = json_decode($items);
    }

    if ( empty( $items ) || !is_array( $items ) ) {
        $items = array();
    }

    $icons = array();
    if (!empty($items) && is_array($items)) {
        foreach ($items as $k => $v) {
            $icons[] = wp_parse_args($v,array(
                        'icon'=> '',
                        'link'=> '#',
                    ));
        }
    }else{
        $icons = bizcor_header_topbar_icons_default_data();
    }

    return $icons;
}

function bizcor_homepage_slider_data(){
    $items = get_theme_mod('bizcor_slider_content');

    if(is_string($items)){
        $items = json_decode($items);
    }

    if ( empty( $items ) || !is_array( $items ) ) {
        $items = array();
    }

    $slides = array();
    if (!empty($items) && is_array($items)) {
        foreach ($items as $k => $v) {
            $slides[] = wp_parse_args($v,array(
                        'image' => array(
                            'url'=>get_template_directory_uri().'/img/slider-1.jpg',
                            'id'=>51
                        ),
                        'title' => sprintf(__('We Provide Quality<span><br></span><span class="bg-primary">business <mask id="myMask">service</mask></span>','bizcor')),
                        'desc' => __('Lorem ipsum dolor sit amet elit sed do incit ut let dolore qut sunt in culpa qui officia deserunt mollit anim id est laborum.','bizcor'),
                        'button1_label' => __('Shop Now','bizcor'),
                        'button1_link' => '#',
                        'button1_target' => false,
                        'button2_label' => __('Explore More','bizcor'),
                        'button2_link' => '#',
                        'button2_target' => false,
                    ),
                );
        }
    }else{
        $slides = bizcor_homepage_slider_default_data();
    }

    return $slides;
}

function bizcor_homepage_info_data(){
    $items = get_theme_mod('bizcor_info_content');

    if(is_string($items)){
        $items = json_decode($items);
    }

    if ( empty( $items ) || !is_array( $items ) ) {
        $items = array();
    }

    $info = array();
    if (!empty($items) && is_array($items)) {
        foreach ($items as $k => $v) {
            $info[] = wp_parse_args($v,array(
                        'icon' => 'fa fa-search-plus',
                        'title' => __('Transparant','bizcor'),                            
                        'desc' => __('Lorem ipsum dolor amet sed do labore et dolore elit','bizcor'),
                    ),
                );
        }
    }else{
        $info = bizcor_homepage_info_default_data();
    }

    return $info;
}

function bizcor_homepage_service_data(){
    $items = get_theme_mod('bizcor_service_content');

    if(is_string($items)){
        $items = json_decode($items);
    }

    if ( empty( $items ) || !is_array( $items ) ) {
        $items = array();
    }

    $services = array();
    if (!empty($items) && is_array($items)) {
        foreach ($items as $k => $v) {
            $services[] = wp_parse_args($v,array(
                        'icon' => 'fa fa-business-time',
                        'image' => array(
                            'url'=>get_template_directory_uri().'/img/service-1.jpg',
                            'id'=>54
                        ),
                        'title' => __('Strategic Planing','bizcor'),                            
                        'desc' => __('At vero eos et iusto odio atque quos dolores et quas.','bizcor'),
                    ),
                );
        }
    }else{
        $services = bizcor_homepage_service_default_data();
    }

    return $services;
}

function bizcor_homepage_testimonial_data(){
    $items = get_theme_mod('bizcor_testimonial_content');

    if(is_string($items)){
        $items = json_decode($items);
    }

    if ( empty( $items ) || !is_array( $items ) ) {
        $items = array();
    }

    $contents = array();
    if (!empty($items) && is_array($items)) {
        foreach ($items as $k => $v) {
            $contents[] = wp_parse_args($v,array(
                            'image' => array(
                                'url'=>get_template_directory_uri().'/img/testi-1.jpg',
                                'id'=>62
                            ),
                            'title' => __('Donald Salvor','bizcor'),                            
                            'designation' => __('CEO & Founder','bizcor'),                
                            'desc' => __('Lorem arcu sit amet accums and eriat aliquam sapien in posuer vinar elit sapin non aen m euIi you are going to  you need to be sure there in the middle  ome form, by injected humof text.','bizcor'),
                            'rating' => '5',
                        ) );
        }
    }else{
        $contents = bizcor_homepage_testimonial_default_data();
    }

    return $contents;
}

function bizcor_footer_bottom_links_data(){
    $items = get_theme_mod('bizcor_footer_bottom_content');

    if(is_string($items)){
        $items = json_decode($items);
    }

    if ( empty( $items ) || !is_array( $items ) ) {
        $items = array();
    }

    $contents = array();
    if (!empty($items) && is_array($items)) {
        foreach ($items as $k => $v) {
            $contents[] = wp_parse_args($v,array(
                            'title' => __('Tearm & Conditions','bizcor'),                            
                            'link' => '#',
                            'target' => true,
                        ) );
        }
    }else{
        if ( function_exists( 'bizcor_footer_bottom_links_default_data' ) ){
            $contents = bizcor_footer_bottom_links_default_data();
        }        
    }

    return $contents;
}

if ( ! function_exists( 'bizcor_edit_link' ) ) :
    function bizcor_edit_link() {
        edit_post_link(
            sprintf(
                /* translators: %s: Post title. */
                __( 'Edit<span class="screen-reader-text"> "%s"</span>', 'bizcor' ),
                get_the_title()
            ),
            '<span class="edit-link">',
            '</span>'
        );
    }
endif;

// Content starter pack data
function bizcor_wp_starter_pack() {

    // Define and register starter contents

    $starter_content = array(
        'widgets'     => array(
            'sidebar-1'   => array(
                'search',
                'categories',
                'tag',
                'meta',
            ),
            'footer-1'    => array(
                'my_text' => array(
                    'text',
                    array(
                        'title' => _x('About US', 'My text starter contents', 'bizcor'),
                        'text'  =>  _x('Lorem ipsum dolor sit amet consectetur dipisicing elit sed do eiusmod tempor incididunt ut labore et dolore magna aliqua Ut enim ad minim veniam.', 'My text starter contents', 'bizcor'),
                    ),
                ),
            ),
            'footer-2'    => array(
                'search' => array(
                    'search',
                    array(
                        'title' => _x( 'search', 'My text starter contents', 'bizcor' ),
                    )
                ),
            ),
            'footer-3'    => array(
                'categories'=> array(
                    'categories',
                    array(
                        'title' => _x( 'categories', 'My text starter contents', 'bizcor' ),
                    )
                ),
            ),
        ),
        'posts'       => array(
            'home',
            'about',
            'contact',
            'blog',
        ),
        'options'     => array(
            'show_on_front'  => 'page',
            'page_on_front'  => '{{home}}',
            'page_for_posts' => '{{blog}}',
            'header_image'   => '',
        ),
        'nav_menus'   => array(
            'primary'    => array(
                'name'  => __( 'Primary Menu', 'bizcor' ),
                'items' => array(
                    'link_home',
                    'page_about',
                    'page_blog',
                    'page_contact',
                    'page_loremuipsum' => array(
                        'type'      => 'post_type',
                        'object'    => 'page',
                        'object_id' => '{{loremipsum}}',
                    ),
                ),
            ),
        ),
    );

    return apply_filters( 'bizcor_wp_starter_pack', $starter_content );
}

// Get Started Notice

add_action( 'wp_ajax_bizcor_dismissed_notice_handler', 'bizcor_ajax_notice_handler' );
function bizcor_ajax_notice_handler() {
    if ( isset( $_POST['type'] ) ) {
        $type = sanitize_text_field( wp_unslash( $_POST['type'] ) );
        update_option( 'dismissed-' . $type, TRUE );
    }
}

function bizcor_deprecated_hook_admin_notice() {
        if ( ! get_option('dismissed-get_started', FALSE ) ) {
            ?>
            <div class="updated notice notice-get-started-class is-dismissible" data-notice="get_started">
                <div class="bizcor-getting-started-notice clearfix">
                    <div class="bizcor-theme-screenshot">
                        <img src="<?php echo esc_url( get_stylesheet_directory_uri() ); ?>/screenshot.png" class="screenshot" alt="<?php esc_attr_e( 'Theme Screenshot', 'bizcor' ); ?>" />
                    </div>
                    <div class="bizcor-theme-notice-content">
                        <h2 class="bizcor-notice-h2">
                            <?php
                        printf(
                            /* translators: 1: welcome page link starting html tag, 2: welcome page link ending html tag. */
                            esc_html__( 'Welcome! Thank you for choosing %1$s!', 'bizcor' ), '<strong>'. wp_get_theme()->get('Name'). '</strong>' );
                        ?>
                        </h2>

                        <p class="plugin-install-notice"><?php echo sprintf(__('Install and activate <strong>Britetechs Companion</strong> plugin for taking full advantage of all the features this theme has to offer.', 'bizcor')) ?></p>

                        <a class="bizcor-btn-get-started button button-primary button-hero bizcor-button-padding" href="#" data-name="" data-slug=""><?php _e( 'Get started with Bizcor', 'bizcor' ) ?></a><span class="bizcor-push-down">
                        <?php
                            /* translators: %1$s: Anchor link start %2$s: Anchor link end */
                            printf(
                                'or %1$sCustomize theme%2$s</a></span>',
                                '<a target="_blank" href="' . esc_url( admin_url( 'customize.php' ) ) . '">',
                                '</a>'
                            );
                        ?>
                    </div>
                </div>
            </div>
        <?php }
}
add_action( 'admin_notices', 'bizcor_deprecated_hook_admin_notice' );

// Plugin Installer

function bizcor_admin_install_plugin() {

    include_once ABSPATH . '/wp-admin/includes/file.php';
    include_once ABSPATH . '/wp-admin/includes/class-wp-upgrader.php';
    include_once ABSPATH . '/wp-admin/includes/plugin-install.php';

    if ( ! file_exists( WP_PLUGIN_DIR . '/britetechs-companion' ) ) {
        $api = plugins_api( 'plugin_information', array(
            'slug'   => sanitize_key( wp_unslash( 'britetechs-companion' ) ),
            'fields' => array(
                'sections' => false,
            ),
        ) );

        $skin     = new WP_Ajax_Upgrader_Skin();
        $upgrader = new Plugin_Upgrader( $skin );
        $result   = $upgrader->install( $api->download_link );
    }

    // Activate plugin.
    if ( current_user_can( 'activate_plugin' ) ) {
        $result = activate_plugin( 'britetechs-companion/britetechs-companion.php' );
    }
}
add_action( 'wp_ajax_install_act_plugin', 'bizcor_admin_install_plugin' );