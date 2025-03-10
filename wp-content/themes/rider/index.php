<?php 
/*
 *The main index template file
 */
$rider_options = get_option( 'rider_theme_options' );
get_header(); ?>
<section id="post-<?php the_ID(); ?>" <?php post_class(); ?>>
            <!--breadcrumb start-->
            <div class="royals-container container">
                <div class="site-breadcumb">
                    <h1>
					<?php if(!empty($rider_options['rider_blogtitle'])) { 
						echo esc_attr($rider_options['rider_blogtitle']);
					 } else { 	
						esc_html_e('My Blog','rider');
					} ?>
                	</h1>
                    <ol class="breadcrumb breadcrumb-menubar">
                        <li>
                            <a href="<?php echo esc_url( home_url('/') ); ?>"><?php esc_html_e('Home','rider'); ?></a>
                            <?php esc_html_e('Blog','rider'); ?>
                        </li>                                
                    </ol>
                </div>  
            </div>
            <!--breadcrumb end-->          

            <!--blog start-->
            <div class="royals-container container">
                <div class="row">
                    <div class="col-md-8 col-sm-7 blog-box">
                        <?php while ( have_posts() ) : the_post(); ?>
						
						<div class="blog-wrap">
                            <div class="blog-info">
                                <div class="blog-date">
									<?php "MAYUR".  get_the_date(); ?>
                                    <a class="color-text" href="<?php echo esc_url(get_month_link(get_the_time('Y'),get_the_time('m'))); ?>"> 
                                        <b><?php echo esc_html(get_the_date('d')); ?></b>
                                        <span><?php echo esc_html(get_the_time('M')).' '.esc_html(get_the_time('y')); ?></span>
                                    </a>
                                </div>
                                <div class="blog-meta">
									<a href="<?php the_permalink(); ?>" class="blog-title"><?php the_title(); ?></a>
									<?php rider_entry_meta(); ?>
                                </div>
                            </div>
                            <div class="blog-content">
                                <?php if ( has_post_thumbnail() ) : 
                                    the_post_thumbnail( 'rider-blog-image', array( 'alt' => get_the_title(), 'class' => 'img-responsive') ); ?>
								<?php endif; ?>
                                <?php the_excerpt(); ?>
                                <div class="read-more col-md-offset-3 col-md-6">
                                    <a href="<?php the_permalink(); ?>"><?php esc_html_e('READ MORE','rider'); ?></a>
                                </div>
                            </div>
                        </div>
						<?php endwhile; ?>
                        <div class="site-pagination">
							<?php rider_pagination(); ?>			
                        </div>
                    </div>
                    <div class="col-md-4 col-sm-5">
                        <?php get_sidebar(); ?>
                    </div>
                </div>
            </div>
            <!--blog end-->
        </section>
<?php get_footer(); ?>