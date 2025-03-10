<?php 
global $bizcor_options;
$sticky_disable = get_theme_mod('bizcor_h_sticky_disable',$bizcor_options['bizcor_h_sticky_disable']);
$stick_class = 'is-sticky-on';
?>
<div class="row-center <?php if($sticky_disable==false){ echo esc_attr( $stick_class ); } ?>">
    <div class="container">
        <div class="row">
            <nav class="navbar-area">
                <div class="logo">
                    <div class="site-title">
                        <?php bizcor_logo(); ?>
                        <?php bloovo_transparent_logo(); ?>
                    </div>
                </div>
                <div class="main-navbar">
                    <?php if ( has_nav_menu( 'primary' ) || ! has_nav_menu( 'expanded' ) ) { ?>
                    <ul id="primary-menu" class="main-menu">
                        <?php 
                        if ( has_nav_menu( 'primary' ) ) {
                            wp_nav_menu( array(
                                'container'  => '',
                                'items_wrap' => '%3$s',
                                'theme_location' => 'primary',
                            ) );
                        }elseif( ! has_nav_menu( 'expanded' ) ) {
                            wp_list_pages( array(
                                'match_menu_classes' => true,
                                'show_sub_menu_icons' => true,
                                'title_li' => false,
                                'walker'   => new Bizcor_Walker_Page(),
                            ) );
                        }
                        ?>
                    </ul>
                    <?php } ?>
                </div>

                <?php 
                if( function_exists('bc_init')){ 
                $topbar_icons = bizcor_header_topbar_icons_data();
                $topbar_icons_target = get_theme_mod('bizcor_topbar_icons_target',$bizcor_options['bizcor_topbar_icons_target']);
                ?>
                <div class="d-flex ml-auto">
                    <div class="main-menu-right main-right">
                        <ul class="menu-right-list">
                            <li class="social-list">
                                <aside class="widget widget_social">
                                    <?php 
                                    if(!empty($topbar_icons)) { 
                                        foreach ($topbar_icons as $icon) {
                                    ?>
                                    <div class="circle">
                                        <a href="<?php echo esc_url($icon['link']); ?>" <?php if($topbar_icons_target==true){ echo 'target="_blank"'; } ?>><i class="<?php echo esc_attr($icon['icon']); ?>"></i></a>
                                    </div>
                                    <?php } } ?>
                                </aside>
                            </li>
                        </ul>
                    </div>
                </div>
                <?php } ?>               
            </nav>
        </div>
    </div>
</div>