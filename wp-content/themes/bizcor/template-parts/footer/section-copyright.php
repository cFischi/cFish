<?php
global $bizcor_options;
$footer_bottom = get_theme_mod('bizcor_footer_bottom_disable',$bizcor_options['bizcor_footer_bottom_disable']);
$copyright_text = get_theme_mod('bizcor_footer_bottom_copyright',$bizcor_options['bizcor_footer_bottom_copyright']);
$links = bizcor_footer_bottom_links_data();
if($footer_bottom==false){ 
?>
<div class="footer-bottom">
    <div class="container">
        <div class="footer-copyright">
            <div class="row align-items-center gy-lg-0 gy-4">
                <div class="col-lg-6 col-md-6 col-12 text-lg-left text-md-left text-center">
                    <div class="widget-left text-lg-left text-md-left text-center">
                        <div class="copyright-text"><?php echo wp_kses_post($copyright_text); ?></div>
                    </div>
                </div>
                <div class="col-lg-6 col-md-6 col-12 text-lg-right text-md-right text-center">
                    <aside class="widget widget_nav_menu">
                        <div class="menu-pages-container">
                            <ul class="menu">
                                <?php 
                                if(!empty($links)) { 
                                    foreach ($links as $val) {
                                        $title = isset( $val['title'] ) ?  $val['title'] : '';
                                        $link = isset( $val['link'] ) ?  $val['link'] : '';
                                        $target = isset( $val['target'] ) && $val['target'] == true ? true : false;
                                ?>
                                <li class="menu-item">
                                    <?php if($link!=''){ ?>
                                    <a href="<?php echo esc_url($link); ?>" <?php if($target==true){ echo 'target="_blank"'; } ?>>
                                    <?php } ?>
                                        <?php echo esc_html($title); ?>
                                    <?php if($link!=''){ ?>
                                    </a>
                                    <?php } ?>
                                </li>
                                <?php } } ?>
                            </ul>
                        </div>
                    </aside>
                </div>
            </div>
        </div>
    </div>
</div>
<?php } ?>