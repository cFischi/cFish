<?php
/*
 * Template Name: Home Page 
 */
$deserve_options = get_option('deserve_theme_options');

get_header();?>
<section> 	
<?php $deserve_i = 0;  
for ($deserve_loop = 1; $deserve_loop <= 5; $deserve_loop++): 

    $sliderimage_image = get_theme_mod ( 'deserve_homepage_sliderimage'.$deserve_loop.'_image',deserve_get_image_id_by_url($deserve_options['slider-img-' . $deserve_loop]));
    $sliderimage_title = get_theme_mod ( 'deserve_homepage_sliderimage'.$deserve_loop.'_title',$deserve_options['slidercontent-' . $deserve_loop]);
    $sliderimage_subtitle = get_theme_mod ( 'deserve_homepage_sliderimage'.$deserve_loop.'_subtitle','');
    $sliderimage_link  = get_theme_mod ( 'deserve_homepage_sliderimage'.$deserve_loop.'_link');

    if($sliderimage_image!=''){
       if($deserve_i == 0) { ?>
        <div class="banner"> 	 
        	<div id="sidebar-carousel-1" class="carousel slide " data-ride="carousel">
        			<div class="carousel-inner slider">
    	<?php  $deserve_sliderclass = "active";
        }else {
          $deserve_sliderclass = "";  
        }
        if($sliderimage_image!=''){
			$sliderimage_image_url = wp_get_attachment_image_src($sliderimage_image,'full');?>	
			<div class="item <?php echo esc_attr($deserve_sliderclass); ?> "> 
    			<?php if($sliderimage_image!=''){ ?>
					<img src="<?php echo esc_url($sliderimage_image_url[0]); ?>" alt="<?php echo esc_attr($deserve_loop); ?>"> 
					<?php if ($sliderimage_title !='') { ?>
					<div class="caption-text">
                        <?php if ($sliderimage_link !='') { ?>
                            <a href="<?php echo esc_url($sliderimage_link);?>" target="_blank">
    						  <h2> <?php echo esc_html($sliderimage_title); ?></h2>
                            </a>
                            <p> <?php echo esc_html($sliderimage_subtitle); ?></p>
                        <?php } else {?>
                            <h2> <?php echo esc_html($sliderimage_title); ?></h2>
                            <p> <?php echo esc_html($sliderimage_subtitle); ?></p>
                        <?php } ?>
					</div>
					<?php } ?>
				<?php } ?>
			</div>
            <?php $deserve_i++; 
        }  
	}
endfor; 
if($deserve_loop >= $deserve_i && $deserve_i > 0) : ?>
    </div>
<?php endif; 
            /* Controls  */
    if ($deserve_i >= 2) { ?>	
        <a class="left carousel-control slider_button" href="#sidebar-carousel-1" data-slide="prev"> <i class="fa fa-angle-left"></i></a> 
        <a class="right carousel-control slider_button" href="#sidebar-carousel-1" data-slide="next"> <i class="fa fa-angle-right"></i></a> 
    <?php } ?>
    <?php  if($deserve_loop >= $deserve_i && $deserve_i > 0) { ?>    
        </div>
    </div>  
    <?php  } ?> 

    <div class="deserve-container container devlopment-">

	    <?php if(get_theme_mod ( 'deserve_homepage_first_sectionswitch',1)==1){
                  if(get_theme_mod ( 'deserve_homepage_section_title',$deserve_options['home-title'])!='' || get_theme_mod ( 'deserve_homepage_section_desc',$deserve_options['home-content'] )!='' ) {  ?>
        <div class="title">
            <?php if (get_theme_mod ( 'deserve_homepage_section_title',$deserve_options['home-title'])!='') {
                ?> 
                <h2><span class="color-text"> <?php echo esc_html(get_theme_mod ( 'deserve_homepage_section_title',$deserve_options['home-title'])); ?> </span></h2>
            <?php } ?> 
            <?php if (get_theme_mod ( 'deserve_homepage_section_desc',$deserve_options['home-content'] )!='') {
                ?>   
                <p>  <?php echo wp_kses_post(get_theme_mod ( 'deserve_homepage_section_desc',$deserve_options['home-content'] )); ?></p>
            <?php } ?>
        </div>
          <?php } } ?>

       <?php for ($deserve_l = 1; $deserve_l <= 3; $deserve_l++):
                if(get_theme_mod ( 'deserve_homepage_first_section'.$deserve_l.'_image',$deserve_options['home-icon-'.$deserve_l])) : ?>
        <div class="row devlopment-wrap">
          <?php for ($deserve_l = 1; $deserve_l <= 3; $deserve_l++):
                if (get_theme_mod ( 'deserve_homepage_first_section'.$deserve_l.'_image',$deserve_options['home-icon-'.$deserve_l])):
        
                $deserve_id = get_theme_mod ( 'deserve_homepage_first_section'.$deserve_l.'_image',deserve_get_image_id_by_url($deserve_options['home-icon-'.$deserve_l]));
                $deserve_image = wp_get_attachment_image_src($deserve_id, 'deserve-home-tab-size'); ?>        
                    <div class="col-md-4 col-sm-6 col-sm-offset-3 col-md-offset-0">
                        <div class="process-detail">                            
                            <div class="round-image">
                                <img alt="<?php echo esc_attr($deserve_l); ?>" class="img-circle" src="<?php echo esc_url($deserve_image[0]); ?>" width="<?php echo esc_attr($deserve_image[1]); ?>" height="<?php echo esc_attr($deserve_image[2]); ?>">			
                            </div>
                            <div class="process">
								<?php if(get_theme_mod ( 'deserve_homepage_first_section'.$deserve_l.'_link',$deserve_options['section-link-'.$deserve_l])!='') { ?>
								<a href="<?php echo esc_url(get_theme_mod ( 'deserve_homepage_first_section'.$deserve_l.'_link',$deserve_options['section-link-'.$deserve_l])) ?>" >
									<h2><?php if (get_theme_mod ( 'deserve_homepage_first_section'.$deserve_l.'_title',$deserve_options['section-title-'.$deserve_l])!='') echo esc_html(get_theme_mod ( 'deserve_homepage_first_section'.$deserve_l.'_title',$deserve_options['section-title-'.$deserve_l])); ?></h2>
                                </a>
                                <?php } else { ?>
								<h2><?php if (get_theme_mod ( 'deserve_homepage_first_section'.$deserve_l.'_title',$deserve_options['section-title-'.$deserve_l])!=''): echo esc_html(get_theme_mod ( 'deserve_homepage_first_section'.$deserve_l.'_title',$deserve_options['section-title-'.$deserve_l])); ?></h2>
								<?php endif; } ?>
                                <p><?php if (get_theme_mod ( 'deserve_homepage_first_section'.$deserve_l.'_desc',$deserve_options['section-content-'.$deserve_l])!=''): echo wp_kses_post(get_theme_mod ( 'deserve_homepage_first_section'.$deserve_l.'_desc',$deserve_options['section-content-'.$deserve_l])); endif; ?></p>
                            </div>
                        </div>
                    </div>
                <?php
            endif;
        endfor; ?>
        </div>
    </div>
    <?php
    endif;
endfor;
if(get_theme_mod ( 'deserve_homepage_second_sectionswitch',1)==1): ?>
    <div class="latest-full-bg">
        <div class="container deserve-container latest-blog">
          <?php if(get_theme_mod('deserve_homepage_second_section_title',$deserve_options['shome-title'])!=''){ ?>
            <div class="title">
                <?php if (get_theme_mod('deserve_homepage_second_section_title',$deserve_options['shome-title'])!='') {   ?> 
                    <h2><span class="color-text"> <?php echo esc_html(get_theme_mod ( 'deserve_homepage_second_section_title',$deserve_options['shome-title'])); ?> </span></h2>

                <?php } 
                if(get_theme_mod('deserve_homepage_second_section_desc',$deserve_options['shome-content'])!=''){ ?>
                    <p><?php echo wp_kses_post(get_theme_mod ( 'deserve_homepage_second_section_desc',$deserve_options['shome-content'])); ?></p>
                <?php } ?>
            </div>
          <?php } ?>
            <div class="row deserve_potfolio">
                <?php
                $deserve_args = array(
                    'orderby' => 'post_date',
                    'order' => 'DESC',
                    'post_type' => 'post',
                    'posts_per_page' => get_theme_mod('deserve_homepage_second_section_perpage',4),
                    'paged' => $paged,
                    'post_status' => 'publish',
                    'ignore_sticky_posts'=> true,
    				'meta_query' => array(
                        array(
                            'key' => '_thumbnail_id',
                            'compare' => 'EXISTS'
                        ),
                     )
                );
                $deserve_query = new WP_Query($deserve_args);
                if ($deserve_query->have_posts()) :
                 while ($deserve_query->have_posts()) : $deserve_query->the_post();
                    $deserve_image = wp_get_attachment_image_src(get_post_thumbnail_id(get_the_id()), 'deserve-latest-post'); 
                    if ($deserve_image[0] != "") { ?>
                        <div class="col-md-3 col-sm-6">
                            <div class="blog-image"> 
                                <a href="<?php the_permalink(); ?>">
                                    <img src="<?php echo esc_url($deserve_image[0]); ?>" width="<?php echo esc_attr($deserve_image[1]); ?>" height="<?php echo esc_attr($deserve_image[2]); ?>" class="img-responsive" alt="<?php the_title_attribute(array('echo'=>false)); ?>"/>
                                </a> 
                            </div>
                            <div class="blog-data col-md-12 no-padding"> <a href="<?php the_permalink(); ?>"><?php echo esc_html(mb_strimwidth(get_the_title(), 0, 50, '...')); ?></a>
                                <div class="item">                                  
                                  <p><?php the_excerpt(); ?></p>
                                  <span class="date-blog"><?php the_date(); ?></span>
                                  <a href="<?php the_permalink(); ?>"><?php esc_html_e('Read More','deserve'); ?></a>
                                </div>                                
                            </div>
                        </div>
                    <?php } ?>
                <?php endwhile;
            endif; ?>
            </div>
        </div>
    </div>
    <?php endif; ?>
</section>
<?php get_footer();