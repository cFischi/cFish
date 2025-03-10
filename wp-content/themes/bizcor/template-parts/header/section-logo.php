<?php 
global $bizcor_options;
$left_icon = get_theme_mod('bizcor_h_left_icon',$bizcor_options['bizcor_h_left_icon']);
$left_title = get_theme_mod('bizcor_h_left_title',$bizcor_options['bizcor_h_left_title']);
$left_desc = get_theme_mod('bizcor_h_left_desc',$bizcor_options['bizcor_h_left_desc']);
$right_icon = get_theme_mod('bizcor_h_right_icon',$bizcor_options['bizcor_h_right_icon']);
$right_title = get_theme_mod('bizcor_h_right_title',$bizcor_options['bizcor_h_right_title']);
$right_desc = get_theme_mod('bizcor_h_right_desc',$bizcor_options['bizcor_h_right_desc']);
?>
<div class="row-bottom">
    <div class="container">
        <div class="row">
            <div class="col-4 my-auto">
                <?php if( function_exists('bc_init') ){ ?>
                <div class="main-menu-right main-left">
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
                    </ul>
                </div>
                <?php } ?>
            </div>
            <div class="col-4 my-auto logo-middle">
                <div class="logo">
                    <div class="site-title">
                        <?php bizcor_logo(); ?>
                    </div>
                </div>
            </div>
            <div class="col-4 my-auto">
                <?php if( function_exists('bc_init') ){ ?>
                <div class="main-menu-right main-right">
                    <ul class="menu-right-list">
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
                <?php } ?>
            </div>
        </div>
    </div>
</div>