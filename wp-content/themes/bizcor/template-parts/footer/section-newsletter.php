<?php
global $bizcor_options;
$footer_above = get_theme_mod('bizcor_footer_above_disable',$bizcor_options['bizcor_footer_above_disable']);
$footer_above_info_icon = get_theme_mod('bizcor_footer_above_info_icon',$bizcor_options['bizcor_footer_above_info_icon']);
$footer_above_info_title = get_theme_mod('bizcor_footer_above_info_title',$bizcor_options['bizcor_footer_above_info_title']);
$footer_above_info_desc = get_theme_mod('bizcor_footer_above_info_desc',$bizcor_options['bizcor_footer_above_info_desc']);
$newsletter_disable = get_theme_mod('bizcor_footer_above_newsletter_disable',$bizcor_options['bizcor_footer_above_newsletter_disable']);
$newsletter_title = get_theme_mod('bizcor_footer_above_newsletter_title',$bizcor_options['bizcor_footer_above_newsletter_title']);
$newsletter_shortcode = get_theme_mod('bizcor_footer_above_newsletter_shortcode',$bizcor_options['bizcor_footer_above_newsletter_shortcode']);
if($footer_above==false){ 
?>
<section class="newsletter-section" >
    <div class="footer-newsletter">
        <div class="container">
            <div class="newsletter-bg">
                <div class="row align-items-center gy-lg-0 gy-3">
                    <div class="col-lg-5 col-md-12 col-12">
                        <div class="newsletter-widgetbg">
                            <aside class="widget widget-contact">
                                <div class="contact-area">
                                    <div class="contact-icon"><i class="<?php echo esc_attr($footer_above_info_icon); ?>"></i></div>
                                    <div class="contact-info">
                                        <?php if($footer_above_info_title!=''){ ?>
                                        <h6 class="title"><?php echo esc_html($footer_above_info_title); ?></h6>
                                        <?php } ?>
                                        <?php if($footer_above_info_desc!=''){ ?>
                                        <p class="text"><?php echo wp_kses_post($footer_above_info_desc); ?></p>
                                        <?php } ?>
                                    </div>
                                </div>
                            </aside>
                        </div>
                    </div>
                    <?php if($newsletter_disable==false){  ?>
                        <?php if($newsletter_title!=''){ ?>
                        <div class="col-lg-3 col-md-12 col-12 text-lg-left text-md-left text-center">
                            <div class="subscribe-content">
                                <div class="subscribe-text">
                                    <h3><?php echo esc_html($newsletter_title); ?></h3>
                                </div>
                            </div>
                        </div>
                        <?php } ?>
                        <?php if($newsletter_shortcode!=''){ ?>
                        <div class="col-lg-4 col-md-12 col-12 text-lg-right text-md-right text-center">
                            <aside class="widget widget-subscribe">
                                <div class="subscribe-inpute">
                                    <?php echo do_shortcode($newsletter_shortcode); ?>
                                </div>
                            </aside>
                        </div>
                        <?php } ?>
                    <?php } ?>
                </div>
            </div>
        </div>
    </div>
</section>
<?php } ?>