<?php 
global $bizcor_options;
$navbar_btn_hide = get_theme_mod('bizcor_nav_btn_hide',$bizcor_options['bizcor_nav_btn_hide']);
$navbar_btn_title = get_theme_mod('bizcor_nav_btn_title',$bizcor_options['bizcor_nav_btn_title']);
$navbar_btn_link = get_theme_mod('bizcor_nav_btn_link',$bizcor_options['bizcor_nav_btn_link']);
$navbar_btn_target = get_theme_mod('bizcor_nav_btn_target',$bizcor_options['bizcor_nav_btn_target']);
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
                <div class="d-flex ml-auto">
                    <?php if($navbar_btn_hide==false && $navbar_btn_link!=''){ ?>
                    <a href="<?php echo esc_url($navbar_btn_link); ?>" class="btn btn-primary right-shap" <?php if($navbar_btn_target==true){ echo 'target="_blank"'; } ?>><?php echo esc_html($navbar_btn_title); ?></a>
                    <?php } ?>
                </div>
            </nav>
        </div>
    </div>
</div>