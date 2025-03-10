<?php do_action( 'bizcor_footer_before' ); ?>

<footer id="footer-section" class="footer-section main-footer">

    <?php do_action( 'bizcor_footer_inner_before' ); ?>

    <?php 
    global $bizcor_options;
    $bg_image = get_theme_mod('bizcor_footer_bg_image',$bizcor_options['bizcor_footer_bg_image']);
    $bg_attachment = get_theme_mod('bizcor_footer_bg_attachment',$bizcor_options['bizcor_footer_bg_attachment']);
    $bg_color = get_theme_mod('bizcor_footer_bg_color',$bizcor_options['bizcor_footer_bg_color']);
    ?>
        
    <section class="default-section st-pt-default" style="background:url(<?php echo esc_url($bg_image); ?>) no-repeat <?php echo esc_attr($bg_attachment); ?> center center / cover <?php echo esc_attr($bg_color); ?>;">
        
        <?php do_action( 'bizcor_footer_main' ); ?>
        
        <div id="particles-js"></div>
    </section>

    <?php do_action( 'bizcor_footer_inner_after' ); ?>

</footer>

<?php do_action( 'bizcor_footer_after' ); ?>