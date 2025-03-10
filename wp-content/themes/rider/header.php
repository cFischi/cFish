<?php
/**
 * The Header template file
 */
 $rider_options = get_option( 'rider_theme_options' ); 

 $TopHeaderSocialIconDefault = array(
  array('url'=>isset($rider_options['rider_fburl'])?$rider_options['rider_fburl']:'','icon'=>isset($rider_options['rider_fbcode'])?$rider_options['rider_fbcode']:'fa-facebook'),
  array('url'=>isset($rider_options['rider_twiiterurl'])?$rider_options['rider_twiiterurl']:'','icon'=>isset($rider_options['rider_twiitercode'])?$rider_options['rider_twiitercode']:'fa-twitter'),
  array('url'=>isset($rider_options['rider_youturl'])?$rider_options['rider_youturl']:'','icon'=>isset($rider_options['rider_youtcode'])?$rider_options['rider_youtcode']:'fa-youtube'),
  array('url'=>isset($rider_options['rider_insturl'])?$rider_options['rider_insturl']:'','icon'=>isset($rider_options['rider_instcode'])?$rider_options['rider_instcode']:'fa-instagram'),
  array('url'=>isset($rider_options['rider_gplusurl'])?$rider_options['rider_gplusurl']:'','icon'=>isset($rider_options['rider_gpluscode'])?$rider_options['rider_gpluscode']:'fa-google-plus')
  );  ?>
<!DOCTYPE html>
<html <?php language_attributes(); ?> class="no-js">
    <head>
        <meta charset="<?php bloginfo('charset'); ?>">
        <meta name="viewport" content="width=device-width">
        <link rel="profile" href="http://gmpg.org/xfn/11">
        <link rel="pingback" href="<?php bloginfo('pingback_url'); ?>">       
		<?php  wp_head(); ?>
    </head>
    <body <?php body_class(); ?>>	
    <?php if ( function_exists( 'wp_body_open' ) ) { wp_body_open();   }  ?>
	<?php if (is_page_template('page-templates/home-page.php')) { ?>
        <header>
            <div class="header_bg">
                <span class="mask-overlay"></span>
                <div class="royals-container container">
                    <div class="royal-rides-header col-md-12">
                        <div class="logo">
                            <?php if(get_theme_mod ( 'rider_logo',isset($rider_options['rider_logo'])?rider_get_image_id($rider_options['rider_logo']):'')!='' ) { 
                                $rider_logo_id=get_theme_mod ( 'rider_logo',isset($rider_options['rider_logo'])?rider_get_image_id($rider_options['rider_logo']):'');
                                $rider_logo = wp_get_attachment_image_src($rider_logo_id,'full');?>
                            <a href="<?php echo esc_url( home_url('/') ); ?>">
                                <img alt="<?php esc_attr_e('logo','rider'); ?>" src="<?php echo esc_url( $rider_logo[0] ); ?>" class="img-responsive" height="220" width="230" >
                            </a>
                            <?php }
                            if(display_header_text()) {  ?>
								<h1>
								<a class="home-link" href="<?php echo esc_url(home_url('/')); ?>" title="<?php echo esc_attr(get_bloginfo('name', 'display')); ?>" rel="home">
							<?php bloginfo('name'); ?>
						</a></h1>
						<?php	$rider_description = get_bloginfo( 'description', 'display' );
							if ( $rider_description || is_customize_preview() ) : ?>
								<p class="site-description"><?php echo esc_html(get_bloginfo( 'description', 'display' )); ?></p>
							<?php endif;?>	
                            
							<?php } ?>
                        </div>
                        
                         <div class="menu-bar col-md-10 offset-md-1">
                             <?php
                                if (has_nav_menu('primary')) {                                   
                                    wp_nav_menu(array(
                                        'theme_location' => 'primary',
                                        'container' => 'div',
                                        'container_class' => ' main-menu-ul no-padding top-menu',
                                        'container_id' => 'example-navbar-collapse',                                        
                                        'echo' => true,                                     
                                        'items_wrap' => '<ul id="%1$s" class="%2$s">%3$s</ul>',
                                        'depth' => 0,
                                    ));
                                }
                            ?>
                        </div>
                        <div class="social-icon">
                             <ul>
                             	<?php for($i=1; $i<=5; $i++) : 
                                    if(get_theme_mod('TopHeaderSocialIconLink'.$i,$TopHeaderSocialIconDefault[$i-1]['url'])!='' && get_theme_mod('TopHeaderSocialIcon'.$i,$TopHeaderSocialIconDefault[$i-1]['icon'])!=''): ?>
                                   <li><a href="<?php echo esc_url(get_theme_mod('TopHeaderSocialIconLink'.$i,$TopHeaderSocialIconDefault[$i-1]['url'])); ?>" class="icon" title="" target="_blank">
                                        <i class="fa <?php echo esc_attr(get_theme_mod('TopHeaderSocialIcon'.$i,$TopHeaderSocialIconDefault[$i-1]['icon'])); ?>"></i>
                                    </a></li>
                                <?php endif; endfor;?>                            	
                            </ul>
                        </div> 
                        <div class="down-arrow">
                            <a href="javascript:void(0);" class="arrow bounce"><span class="fa fa-angle-down"></span></a>       
                        </div>
                    </div>
                </div>
            </div>
            <div class="scrolling-menubar"  >
                <div class="scroll-header" id="myId">
                    <span class="mask-overlay"></span>
                    <div class="royals-container  container">
                        <div class="row">
                            <div class="col-md-2 col-sm-12 logo-small">
							<?php if(has_custom_logo()) { 
									the_custom_logo();
							 } if(display_header_text()) { ?>
                            	<h1>
									<a class="home-link" href="<?php echo esc_url(home_url('/')); ?>" title="<?php echo esc_attr(get_bloginfo('name', 'display')); ?>" rel="home">
									<?php bloginfo('name'); ?>
									</a>
								</h1>
									<?php	$rider_description = get_bloginfo( 'description', 'display' );
											if ( $rider_description || is_customize_preview() ) : ?>
									<p class="site-description"><?php echo esc_html(get_bloginfo( 'description', 'display' )); ?></p>
								<?php endif;?>								
							<?php } ?>
                            </div>
                            <div class="col-md-10 col-sm-12 center-content">
                                 <div class="row">
                                <div id="mainmenu" class=" col-md-10 col-sm-10">
                                <?php                                   
                                    wp_nav_menu(array(
                                        'theme_location'  => 'primary',                            
                                        'container'       => 'ul',                            
                                        'echo'            => true,
                                        'menu_class'      => 'navbar-nav',
                                        'depth'           => 0,
                                    ));
                                 ?>
                                </div><!-- /.nav-collapse -->
                                <div class="col-md-2 col-sm-12 social-icon  no-padding">	
                                     <ul>
                                     	<?php for($i=1; $i<=5; $i++) : 
		                                    if(get_theme_mod('TopHeaderSocialIconLink'.$i,$TopHeaderSocialIconDefault[$i-1]['url'])!='' && get_theme_mod('TopHeaderSocialIcon'.$i,$TopHeaderSocialIconDefault[$i-1]['icon'])!=''): ?>
		                                   <li><a href="<?php echo esc_url(get_theme_mod('TopHeaderSocialIconLink'.$i,$TopHeaderSocialIconDefault[$i-1]['url'])); ?>" class="icon" title="" target="_blank">
		                                        <i class="fa <?php echo esc_attr(get_theme_mod('TopHeaderSocialIcon'.$i,$TopHeaderSocialIconDefault[$i-1]['icon'])); ?>"></i>
		                                    </a></li>
		                                <?php endif; endfor;?>                            	
									</ul>
                                </div>
                              </div>
                            </div>                           
                        </div>
                    </div>
                </div>
            </div>
        </header>

	<?php } else { ?>


		<header> 
            <div class="scroll-header" id="myId">
                <span class="mask-overlay"></span>
                <div class="royals-container  container">
                    <div class="row">
                        <div class="col-md-2 logo-small col-sm-2">
								<?php if(has_custom_logo()) { 
									the_custom_logo();
							 } if(display_header_text()) { ?>
                            <h1>
								<a class="home-link" href="<?php echo esc_url(home_url('/')); ?>" title="<?php echo esc_attr(get_bloginfo('name', 'display')); ?>" rel="home">
								<?php bloginfo('name'); ?>	
								</a></h1>
								<?php $rider_description = get_bloginfo( 'description', 'display' ); 
								if ( $rider_description || is_customize_preview() ) : ?>
								<p class="site-description"><?php echo esc_html(get_bloginfo( 'description', 'display' )); ?></p>
							<?php endif;
							} ?>
                        </div>
                        <?php if (get_header_image()) { ?>
						<div class="custom-header-img">
							<a href="<?php echo esc_url(home_url('/')); ?>" rel="home">
								<img src="<?php header_image(); ?>" width="<?php echo esc_attr(get_custom_header()->width); ?>" height="<?php echo esc_attr(get_custom_header()->height); ?>" alt="<?php echo esc_attr(get_the_title()); ?>">
							</a>
						</div>
					<?php } ?> 
                        <div class="col-md-10 col-sm-10 center-content">
                            <div class="row">
                            <div id="mainmenu" class=" col-md-10 col-sm-10">
                                <?php
                                    $rider_defaults = array(
                                        'theme_location'  => 'primary',                            
                                        'container'       => 'ul',                            
                                        'echo'            => true,
                                        'menu_class'      => 'navbar-nav',
                                        'depth'           => 0,
                                    );                               
                                    wp_nav_menu($rider_defaults);
                                 ?>
                                </div><!-- /.nav-collapse -->
                            <div class="col-md-2 col-sm-2 social-icon  no-padding">	
                                 <ul>
                                 	<?php for($i=1; $i<=5; $i++) : 
                                    if(get_theme_mod('TopHeaderSocialIconLink'.$i,$TopHeaderSocialIconDefault[$i-1]['url'])!='' && get_theme_mod('TopHeaderSocialIcon'.$i,$TopHeaderSocialIconDefault[$i-1]['icon'])!=''): ?>
            	                       <li><a href="<?php echo esc_url(get_theme_mod('TopHeaderSocialIconLink'.$i,$TopHeaderSocialIconDefault[$i-1]['url'])); ?>" class="icon" title="" target="_blank">
                	                        <i class="fa <?php echo esc_attr(get_theme_mod('TopHeaderSocialIcon'.$i,$TopHeaderSocialIconDefault[$i-1]['icon'])); ?>"></i>
        	                            </a></li>
    	                            <?php endif; endfor;?>
	                            </ul>
                            </div>
                          </div>
                        </div>
                    </div>
                </div>
            </div>
        </header>

	<?php } ?>