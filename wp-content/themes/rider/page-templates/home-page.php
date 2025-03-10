<?php 
/*
 * Template Name: Front Page
 */
get_header();
$rider_options = get_option( 'rider_theme_options' ); ?>
<section>
	<div class="royals-container  container">
        <div class="about-me">
            <div class="title-box">  
                <?php if(get_theme_mod ( 'rider_aboutus_title',isset($rider_options['rider_aboutus-title'])?$rider_options['rider_aboutus-title']:'')!='') { ?><h2 class="content-heading"><?php  echo esc_html(get_theme_mod ( 'rider_aboutus_title',isset($rider_options['rider_aboutus-title'])?$rider_options['rider_aboutus-title']:'')); ?></h2><?php } ?>
            </div>
            <div class="about-me-info">
            <?php $sliderimage_image = get_theme_mod ( 'rider_author_image',isset($rider_options['rider_author-image'])?rider_get_image_id($rider_options['rider_author-image']):'');
                if (!empty($sliderimage_image)) {
                   $sliderimage_image_url = wp_get_attachment_image_src($sliderimage_image,'full');   ?>
                <a href="<?php if(get_theme_mod ( 'rider_author_link',isset($rider_options['rider_author-link'])?$rider_options['rider_author-link']:'')!='') { echo esc_url(get_theme_mod ( 'rider_author_link',isset($rider_options['rider_author-link'])?$rider_options['rider_author-link']:'')); } else { echo esc_url( home_url('/') ); } ?>"> <img class="img-circle author-img" src="<?php echo esc_url($sliderimage_image_url[0]); ?>" width="159" height="159" > </a>
            <?php } if(get_theme_mod ( 'rider_aboutus_name',isset($rider_options['rider_aboutus-name'])?$rider_options['rider_aboutus-name']:'')!='') { ?>
                <a href="<?php if(get_theme_mod ( 'rider_author_link',isset($rider_options['rider_author-link'])?$rider_options['rider_author-link']:'')!='') { echo esc_url(get_theme_mod ( 'rider_author_link',isset($rider_options['rider_author-link'])?$rider_options['rider_author-link']:'')); } else { echo esc_url( home_url('/') ); } ?>" class="author-name"><?php echo esc_html(get_theme_mod ( 'rider_aboutus_name',isset($rider_options['rider_aboutus-name'])?$rider_options['rider_aboutus-name']:'')); ?></a>
            <?php } ?>
                <p class="color-text"> <?php if(get_theme_mod ( 'rider_author_location',isset($rider_options['rider_author-location'])?$rider_options['rider_author-location']:'')!='') { echo esc_html(get_theme_mod ( 'rider_author_location',isset($rider_options['rider_author-location'])?$rider_options['rider_author-location']:'')); } ?></p>
            <?php  if(get_theme_mod ( 'rider_homemsg',isset($rider_options['rider_homemsg'])?$rider_options['rider_homemsg']:'')!='' ) { ?>
                <p><?php echo wp_kses_post(wpautop(get_theme_mod ( 'rider_homemsg',isset($rider_options['rider_homemsg'])?$rider_options['rider_homemsg']:''))); ?></p>
            <?php } ?>
            </div>
        </div>       
    </div>
    <!--latest-blog start-->
    <?php if(get_theme_mod('rider_homepage_second_sectionswitch',1)==1):
        if(get_theme_mod('rider_homepage_second_section_category',0)>0): 
        $rider_home_args = array( 'posts_per_page'    => 3,
            'cat' => get_theme_mod('rider_homepage_second_section_category'),
            'orderby'          => 'post_date',
            'order'            => 'DESC',
            'post_type'        => 'post',
            'post_status'      => 'publish',
            'meta_query' => array(
                array(
                 'key' => '_thumbnail_id',
                 'compare' => 'EXISTS'
                )),
            );
        else: 
        $rider_home_args = array( 'posts_per_page'    => 3,           
            'orderby'          => 'post_date',
            'order'            => 'DESC',
            'post_type'        => 'post',
            'post_status'      => 'publish',
            'meta_query' => array(
                array(
                 'key' => '_thumbnail_id',
                 'compare' => 'EXISTS'
                )),
            );
        endif;

            $rider_home_post = new WP_Query( $rider_home_args );
            $rider_home_i = 1;
            while ( $rider_home_post->have_posts() ) { $rider_home_post->the_post();
            if($rider_home_i == 1) { $rider_first_blog  = get_the_ID(); }
            if($rider_home_i == 2) { $rider_second_blog  = get_the_ID(); }
            if($rider_home_i == 3) { $rider_third_blog  = get_the_ID(); }
            $rider_home_i++; }  
    if($rider_home_i>1): ?>
    <div class="latest-blog-bg">
        <span class="mask-overlay"></span>
        <div class="royals-container  container">
            <div class="title-box">
                <?php if(get_theme_mod ( 'rider_homepage_second_section_title',isset($rider_options['rider_blog-title'])?$rider_options['rider_blog-title']:'')!='') { ?><h2 class="content-heading"><?php echo esc_html(get_theme_mod ( 'rider_homepage_second_section_title',isset($rider_options['rider_blog-title'])?$rider_options['rider_blog-title']:'')); ?></h2><?php } ?>
            </div>
            <div class="row">
            <?php if($rider_home_i>1): ?>
                <div class="col-md-8 latest-blog">
                    <?php $rider_home_first_url = wp_get_attachment_image_src( get_post_thumbnail_id($rider_first_blog), 'rider-blog-one' );
					 if(!empty($rider_home_first_url)) { ?><a href="<?php echo esc_url(get_permalink($rider_first_blog)); ?>"><img src="<?php echo esc_url( $rider_home_first_url[0] ); ?>"  alt="<?php echo esc_attr( get_the_title($rider_first_blog)); ?>" class="img-responsive"> </a><?php } ?>
                    <div class="blog-info">
                        <div class="blog-date">
                            <a href="<?php echo esc_url(get_month_link(get_the_time('Y',$rider_first_blog),get_the_time('m',$rider_first_blog))); ?>" class="color-text">
                                <b><?php echo esc_html(get_the_date('d',$rider_first_blog)); ?></b>
                                <span><?php echo esc_html(get_the_time('M',$rider_first_blog)).' '.esc_html(get_the_time('y',$rider_first_blog)); ?></span>
                            </a>
                        </div>
                        <div class="blog-meta">
                            <a class="blog-title" href="<?php echo esc_url(get_permalink($rider_first_blog)); ?>"><?php echo get_the_title($rider_first_blog); ?></a>
                            <ul>
                                <li> <span> <?php echo esc_html(get_comments_number( $rider_first_blog )); ?> </span> <?php esc_html_e('Comments','rider'); ?></li>
                                <li><span> <?php esc_html_e('Posted By','rider'); ?>: </span><a href="<?php echo esc_url( get_author_posts_url(get_post_field( 'post_author', $rider_first_blog ))); ?>"><?php echo esc_html(get_the_author_meta('user_login',get_post_field( 'post_author', $rider_first_blog ))); ?></a></li>
                            </ul>
                        </div>
                    </div>
                </div>
                <?php endif; ?>
                <div class="col-md-4 latest-blog-right">
                    <?php if($rider_home_i>2): ?>
                    <div class="latest-blog">
                    <?php $rider_home_second_url = wp_get_attachment_image_src( get_post_thumbnail_id($rider_second_blog), 'rider-blog-two' );
					 if(!empty($rider_home_second_url)) { ?><a href="<?php echo esc_url(get_permalink($rider_second_blog)); ?>"> <img src="<?php echo esc_url( $rider_home_second_url[0] ); ?>" alt="<?php echo esc_attr( get_the_title($rider_second_blog) ); ?>" class="img-responsive"> </a><?php } ?>
                        <div class="blog-info">
                            <div class="blog-date">
                                <a href="<?php echo esc_url(get_month_link(get_the_time('Y',$rider_second_blog),get_the_time('m',$rider_second_blog))); ?>" class="color-text"> 
                                    <b><?php echo esc_html(get_the_date('d',$rider_second_blog)); ?></b>
                                    <span><?php echo esc_html(get_the_time('M',$rider_second_blog)).' '.esc_html(get_the_time('y',$rider_second_blog)); ?></span>
                                </a>
                            </div>
                            <div class="blog-meta">
                                <a class="blog-title" href="<?php echo esc_url(get_permalink($rider_second_blog)); ?>"><?php echo get_the_title($rider_second_blog); ?></a>
                                <ul>
                                    <li> <span> <?php echo esc_html(get_comments_number( $rider_second_blog )); ?> </span> <?php esc_html_e('Comments','rider'); ?></li>  
                                    <li><span> <?php esc_html_e('Posted By: ','rider'); ?></span><a href="<?php echo esc_url( get_author_posts_url(get_post_field( 'post_author', $rider_second_blog ))); ?>"><?php echo esc_html(get_the_author_meta('user_login',get_post_field( 'post_author', $rider_second_blog ))); ?></a></li>
                                </ul>
                            </div>
                        </div>
                    </div>
                <?php endif; if($rider_home_i>3): ?>
                    <div class=" latest-blog">
                        <?php $rider_home_third_url = wp_get_attachment_image_src( get_post_thumbnail_id($rider_third_blog), 'rider-blog-two' );
                        if(!empty($rider_home_third_url)) { ?>
                        <a href="<?php echo esc_url(get_permalink($rider_third_blog)); ?>"> <img src="<?php echo esc_url( $rider_home_third_url[0] ); ?>" alt="<?php echo esc_attr( get_the_title($rider_third_blog) ); ?>" class="img-responsive"> </a><?php } ?>
                        <div class="blog-info">
                            <div class="blog-date">
                                <a href="<?php echo esc_url(get_month_link(get_the_time('Y',$rider_third_blog),get_the_time('m',$rider_third_blog))); ?>" class="color-text">
                                    <b><?php echo esc_html(get_the_date('d',$rider_third_blog)); ?></b>
                                    <span><?php echo esc_html(get_the_time('M',$rider_third_blog)).' '.esc_html(get_the_time('y',$rider_third_blog)); ?></span>
                                </a>
                            </div>
                            <div class="blog-meta">
                                <a class="blog-title" href="<?php echo esc_url(get_permalink($rider_third_blog)); ?>"><?php echo get_the_title($rider_third_blog); ?></a>
                                <ul>
                                    <li> <span> <?php echo esc_html(get_comments_number( $rider_third_blog )); ?> </span> <?php esc_html_e('Comments','rider'); ?></li>
                                    <li><span> <?php esc_html_e('Posted By','rider'); ?>: </span><a href="<?php echo esc_url( get_author_posts_url(get_post_field( 'post_author', $rider_third_blog ))); ?>"><?php echo esc_html(get_the_author_meta('user_login',get_post_field( 'post_author', $rider_third_blog ))); ?></a></li>
                                </ul>
                            </div>
                        </div>
                    </div>
                <?php endif; ?>
                </div>
            </div>
        </div>
    </div>
    <?php endif; endif;?>
    <!--latest-blog end-->
</section>
<?php get_footer(); ?>