<?php
/**
 * The Footer template file
 */
 $rider_options = get_option( 'rider_theme_options' );
 $TopHeaderSocialIconDefault = array(
  array('url'=>isset($rider_options['rider_fburl'])?$rider_options['rider_fburl']:'','icon'=>isset($rider_options['rider_fbcode'])?$rider_options['rider_fbcode']:'fa-facebook'),
  array('url'=>isset($rider_options['rider_twiiterurl'])?$rider_options['rider_twiiterurl']:'','icon'=>isset($rider_options['rider_twiitercode'])?$rider_options['rider_twiitercode']:'fa-twitter'),
  array('url'=>isset($rider_options['rider_youturl'])?$rider_options['rider_youturl']:'','icon'=>isset($rider_options['rider_youtcode'])?$rider_options['rider_youtcode']:'fa-youtube'),
  array('url'=>isset($rider_options['rider_insturl'])?$rider_options['rider_insturl']:'','icon'=>isset($rider_options['rider_instcode'])?$rider_options['rider_instcode']:'fa-instagram'),
  array('url'=>isset($rider_options['rider_gplusurl'])?$rider_options['rider_gplusurl']:'','icon'=>isset($rider_options['rider_gpluscode'])?$rider_options['rider_gpluscode']:'fa-google-plus')
  );  ?>
<footer>
    <div class="footer-bg">
        <div class="royals-container  container">
            <div class="footer-logo">
                <?php if(get_theme_mod('rider_footer_logo',isset($rider_options['rider_footer-logo'])?$rider_options['rider_footer-logo']:'')!='') { $rider_logo_id = get_theme_mod('rider_footer_logo',isset($rider_options['rider_footer-logo'])?rider_get_image_id($rider_options['rider_footer-logo']):'') ; 
                    $footer_logo_image = wp_get_attachment_image_src($rider_logo_id,'full'); ?>
					<a href="<?php echo esc_url( home_url('/') ); ?>">
                        <img alt="<?php esc_attr_e('logo','rider'); ?>" src="<?php echo esc_url( $footer_logo_image[0] ); ?>" class="img-responsive" />
                    </a>
					<?php } ?>
            </div>
            <div class="footer-text">
				<?php if( get_theme_mod('rider_footerdescription',isset($rider_options['rider_footerdescription'])?$rider_options['rider_footerdescription']:'')!='' ) { ?><p class="text-widget"><?php echo esc_html(wp_trim_words( esc_html(get_theme_mod('rider_footerdescription',isset($rider_options['rider_footerdescription'])?$rider_options['rider_footerdescription']:'')), 100, '' ));?></p><?php } ?>
                <div class="footer-social-icon">
                     <ul>
                        <?php for($i=1; $i<=5; $i++) : 
                            if(get_theme_mod('TopHeaderSocialIconLink'.$i,$TopHeaderSocialIconDefault[$i-1]['url'])!='' && get_theme_mod('TopHeaderSocialIcon'.$i,$TopHeaderSocialIconDefault[$i-1]['icon'])!=''): ?>
                               <li><a href="<?php echo esc_url(get_theme_mod('TopHeaderSocialIconLink'.$i,$TopHeaderSocialIconDefault[$i-1]['url'])); ?>" class="icon" title="" target="_blank">
                                    <i class="fa <?php echo esc_attr(get_theme_mod('TopHeaderSocialIcon'.$i,$TopHeaderSocialIconDefault[$i-1]['icon'])); ?>"></i>
                                </a></li>
                        <?php endif; endfor;?>
                    </ul>
                </div>
                <div class="copyright">
                    <p>
                        <?php if(get_theme_mod('rider_footertext',isset($rider_options['rider_footertext'])?$rider_options['rider_footertext']:'')!='') { ?><?php echo esc_html(get_theme_mod('rider_footertext',isset($rider_options['rider_footertext'])?$rider_options['rider_footertext']:'')); }
                        printf(/* translators: %1s is theme url info.*/ esc_html__( ' Powered by %1$s', 'rider' ), '<a href="'.esc_url("https://fasterthemes.com/wordpress-themes/rider").'" target="_blank">'.esc_html__('Rider WordPress Theme','rider').'</a>' ); ?>
                    </p>
                </div>
            </div>
        </div>
    </div>
</footer>
<?php wp_footer(); ?>
</body>
</html>