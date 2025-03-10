<?php
global $bizcor_options;
$blog_disable = get_theme_mod('bizcor_blog_disable',$bizcor_options['bizcor_blog_disable']);
$blog_subtitle = get_theme_mod('bizcor_blog_subtitle',$bizcor_options['bizcor_blog_subtitle']);
$blog_title = get_theme_mod('bizcor_blog_title',$bizcor_options['bizcor_blog_title']);
$blog_desc = get_theme_mod('bizcor_blog_desc',$bizcor_options['bizcor_blog_desc']);
$blog_show = get_theme_mod('bizcor_blog_show',$bizcor_options['bizcor_blog_show']);
$blog_category = get_theme_mod('bizcor_blog_category',$bizcor_options['bizcor_blog_category']);
$blog_column = get_theme_mod('bizcor_blog_column',$bizcor_options['bizcor_blog_column']);
if($blog_disable==false){
?>
<section id="post-section" class="post-section st-py-default">
    <div class="container">
        <div class="row">
            <div class="col-lg-6 col-12 mx-lg-auto mb-5 text-center">
                <div class="heading-default wow fadeInUp">
                    <?php if($blog_subtitle!=''){ ?>
                    <span class="badge"><?php echo esc_html($blog_subtitle); ?></span>
                    <?php } ?>

                    <?php if($blog_title!=''){ ?>
                    <h2 class="mb-0"><?php echo wp_kses_post($blog_title); ?></h2>
                    <?php } ?>

                    <?php if($blog_desc!=''){ ?>
                    <p class="mb-0"><?php echo wp_kses_post($blog_desc); ?></p>
                    <?php } ?>                       
                </div>
            </div>
        </div>
        <div class="row row-cols-1 row-cols-lg-<?php echo esc_attr($blog_column); ?> row-cols-md-2 g-5 wow fadeInUp">
            <?php
            $args = array(
                'posts_per_page' => $blog_show,
                'suppress_filters' => 0,
            );

            if (  isset($blog_category) ) {
                            $args['category__in'] = $blog_category;
                        }


            $query = new WP_Query( $args );
            ?>
            <?php if ( $query->have_posts() ) : ?>
            <?php while ( $query->have_posts() ) : $query->the_post(); ?>
            <div class="col">
                <article id="post-<?php the_ID(); ?>" class="post-items">
                    <?php if( has_post_thumbnail() ): ?>
                    <figure class="post-image">
                        <div class="featured-image">
                            <?php the_post_thumbnail(); ?>
                            <a href="<?php the_permalink(); ?>">
                                <div class="image-overlay-icon">
                                    <div class="icon"><i class="fa fa-plus"></i></div>
                                </div>
                            </a>
                        </div>
                    </figure>
                    <?php endif; ?>

                    <div class="post-content">
                        <div class="post-detail">
                            <?php get_template_part( 'template-parts/entry/date' ); ?>
                            <h5 class="post-title">
                                <a href="<?php the_permalink(); ?>" title="<?php the_title_attribute(); ?>" rel="bookmark"><?php the_title(); ?></a>
                            </h5>
                            <?php the_excerpt(); ?>
                        </div>
                        <?php
                        global $authordata;
                        ?>
                        <div class="post-btn">
                            <a href="<?php echo esc_url( get_author_posts_url( $authordata->ID, $authordata->user_nicename ) ); ?>" class="btn"><span><i class="fas fa-user"></i></span> <?php echo get_the_author(); ?></a>

                            <?php if( has_category() ) { 
                                $category = get_the_category();
                            ?>
                            <a href="<?php echo esc_url(get_category_link( $category[0]->term_id )); ?>" class="btn"><span><i class="fas fa-tags"></i></span> <?php echo esc_html($category[0]->cat_name); ?></a>
                            <?php } ?>
                        </div>
                    </div>
                </article>
            </div>
            <?php endwhile; wp_reset_postdata(); ?>
            <?php endif; ?>
        </div>
    </div>
</section>
<?php } ?>