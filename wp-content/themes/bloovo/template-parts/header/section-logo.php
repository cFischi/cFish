<?php 
global $bizcor_options;
$left_icon = get_theme_mod('bizcor_h_left_icon',$bizcor_options['bizcor_h_left_icon']);
$left_title = get_theme_mod('bizcor_h_left_title',$bizcor_options['bizcor_h_left_title']);
$left_desc = get_theme_mod('bizcor_h_left_desc',$bizcor_options['bizcor_h_left_desc']);
$right_icon = get_theme_mod('bizcor_h_right_icon',$bizcor_options['bizcor_h_right_icon']);
$right_title = get_theme_mod('bizcor_h_right_title',$bizcor_options['bizcor_h_right_title']);
$right_desc = get_theme_mod('bizcor_h_right_desc',$bizcor_options['bizcor_h_right_desc']);

$navbar_btn_hide = get_theme_mod('bizcor_nav_btn_hide',$bizcor_options['bizcor_nav_btn_hide']);
$navbar_btn_title = get_theme_mod('bizcor_nav_btn_title',$bizcor_options['bizcor_nav_btn_title']);
$navbar_btn_link = get_theme_mod('bizcor_nav_btn_link',$bizcor_options['bizcor_nav_btn_link']);
$navbar_btn_target = get_theme_mod('bizcor_nav_btn_target',$bizcor_options['bizcor_nav_btn_target']);
?>
<div class="row-bottom">
    <div class="container">
        <div class="row">
            <div class="col-3 my-auto logo-middle">
                <div class="logo">
                    <div class="site-title">
                        <?php bizcor_logo(); ?>
                    </div>
                </div>
            </div>
            <?php if( function_exists('bc_init')){ ?>
            <div class="col-6 my-auto">
                <div class="main-menu-right">
                    <ul class="menu-right-list">
                        <li class="content-list">
                            <aside class="widget widget-contact first">
                                <div class="contact-area">
                                    <?php if($left_icon!=''){ ?>
                                    <div class="contact-icon">
                                        <div class="contact-corn"><i class="<?php echo esc_attr($left_icon); ?>"></i></div>
                                    </div>
                                    <?php } ?>
                                    <div class="contact-info">
                                        <?php if($left_title!=''){ ?>
                                        <h6 class="title"><?php echo esc_html($left_title); ?></h6>
                                        <?php } ?>
                                        <?php if($left_desc!=''){ ?>
                                        <p class="text"><?php echo wp_kses_post($left_desc); ?></p>
                                        <?php } ?>
                                    </div>
                                </div>
                            </aside>
                        </li>
                        <li class="content-list">
                            <aside class="widget widget-contact first">
                                <div class="contact-area">
                                    <?php if($right_icon!=''){ ?>
                                    <div class="contact-icon">
                                        <div class="contact-corn"><i class="<?php echo esc_attr($right_icon); ?>"></i></div>
                                    </div>
                                    <?php } ?>
                                    <div class="contact-info">
                                        <?php if($right_title!=''){ ?>
                                        <h6 class="title"><?php echo esc_html($right_title); ?></h6>
                                        <?php } ?>
                                        <?php if($right_desc!=''){ ?>
                                        <p class="text"><?php echo wp_kses_post($right_desc); ?></p>
                                        <?php } ?>
                                    </div>
                                </div>
                            </aside>
                        </li>
                    </ul>
                </div>
            </div>
            <?php } ?>           
            <div class="col-3 my-auto">
                <div class="float-right">
                    <?php if($navbar_btn_hide==false && $navbar_btn_link!=''){ ?>
                    <a href="<?php echo esc_url($navbar_btn_link); ?>" class="btn btn-primary theme_btn mr-4" <?php if($navbar_btn_target==true){ echo 'target="_blank"'; } ?>><span><?php echo esc_html($navbar_btn_title); ?></span></a>
                    <?php } ?>
                </div>
            </div>
        </div>
    </div>
</div>