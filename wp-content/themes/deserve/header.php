<?php
/*
 * Header For Deserve Theme.
 */
$deserve_options = get_option( 'deserve_theme_options' ); ?>
<!DOCTYPE html>
<!--[if IE 7]>
<html class="ie ie7" <?php language_attributes(); ?>>
<![endif]-->
<!--[if IE 8]>
<html class="ie ie8" <?php language_attributes(); ?>>
<![endif]-->
<!--[if !(IE 7) & !(IE 8)]><!-->
<html <?php language_attributes(); ?>>
<!--<![endif]-->
<head>
	<meta charset="<?php bloginfo( 'charset' ); ?>">
	<meta name="viewport" content="width=device-width">	
	<link rel="profile" href="http://gmpg.org/xfn/11">
	<?php wp_head(); ?>
</head>
<body <?php body_class(); ?>>
<?php if ( function_exists( 'wp_body_open' ) ) { wp_body_open();   }  ?>
<header>    
    <div class="menubar top-bar">
    	<div class="deserve-container clearfix">
            <div class="col-md-6">
                <div class="contact-info">
                    <ul>
                        <?php if(get_theme_mod('theme_phone_number',$deserve_options['phone'])) { ?>		
                        <li>
							<i class="fa fa-phone"></i> <?php echo esc_attr(get_theme_mod('theme_phone_number',$deserve_options['phone'])); ?>							
						</li>
						<?php }
						if(get_theme_mod('theme_email_id',$deserve_options['email'])) { ?> 
						<li>
							<a href="mailto:<?php echo esc_attr(get_theme_mod('theme_email_id',$deserve_options['email'])); ?>"><i class="fa fa-envelope"></i> <?php echo esc_attr(get_theme_mod('theme_email_id',$deserve_options['email'])); ?></a>
						</li>
						<?php } ?>
                    </ul>
                </div>
            </div>
            <div class="col-md-6">
            	 <div class="social-link">
                    <ul>
                        <?php for($i=1; $i<=4; $i++) : ?>
                            <?php if(get_theme_mod('TopHeaderSocialIconLink'.$i)!='' && get_theme_mod('TopHeaderSocialIcon'.$i)!=''): ?>
                               <li><a href="<?php echo esc_url(get_theme_mod('TopHeaderSocialIconLink'.$i)); ?>" class="icon" title="" target="_blank">
                                    <i class="fa <?php echo esc_attr(get_theme_mod('TopHeaderSocialIcon'.$i)); ?>"></i>
                                </a></li>
                            <?php endif; ?>
                        <?php endfor; ?>						
                    </ul>
                </div>
            </div>
        </div>
    </div>
    <div class="menubar responsive-menubar">
    	<div class="deserve-container clearfix">
            <div class="col-md-2">
            	<div  class="site-logo">
				<?php if(has_custom_logo()){
                            the_custom_logo();
                      }
                  if(display_header_text()==true) { ?>
        		<h4 class="deserve-site-name"><a href="<?php echo esc_url(home_url('/')); ?>">
                    <?php echo esc_html(get_bloginfo('name')); ?></a></h4>
                <h6 class="deserve-site-description"><a href="<?php echo esc_url(home_url('/')); ?>">
                    <?php echo esc_html(get_bloginfo('description')); ?></a></h6>
				<?php } ?>
                    <div class="navbar-header res-nav-header toggle-respon">
                        <button type="button" class="navbar-toggle toggle-menu" data-toggle="collapse" data-target=".navbar-collapse">
                           <span class="sr-only"></span>
                           <span class="icon-bar"></span>
                           <span class="icon-bar"></span>
                           <span class="icon-bar"></span>
                       </button>
                   </div>
                </div>
            </div>
            <div class="col-md-10">
                <div class="header-menu">             
                    <?php						
						wp_nav_menu(array(
                            'theme_location'  => 'primary',
                            'container'       => 'div',                         
                            'menu_class'      => 'navbar-collapse nav_coll no-padding collapse',
                            'menu_id'         => 'example-navbar-collapse',
                            'echo'            => true,
                            'fallback_cb'     => 'wp_page_menu',                            
                            'items_wrap'      => '<ul id="%1$s" class="%2$s nav">%3$s</ul>',
                            'depth'           => 0,                         
                        )); ?>
                </div>
            </div>
        </div>
         <?php if(get_header_image()){ ?>
        <div class="custom-header-img">
        <a href="<?php echo esc_url( home_url( '/' ) ); ?>" >
        	<img src="<?php esc_url(header_image()); ?>" width="<?php echo esc_attr(get_custom_header()->width); ?>" height="<?php echo esc_attr(get_custom_header()->height); ?>" alt="<?php esc_attr_e('customheader','deserve') ?>">
        </a>
        </div>
    <?php } ?>
    </div>
</header>