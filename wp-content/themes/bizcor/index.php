<?php 
/**
 * This is the main template file
 *
 * This is the most generic template file in a WordPress theme
 * and one of the two required files for a theme (the other being style.css).
 * It is used to display a page when nothing more specific matches a query.
 * E.g., it puts together the home page when no home.php file exists.
 *
 * @link https://codex.wordpress.org/Template_Hierarchy
 *
 * @package WordPress
 * @subpackage Bizcor
 * 
 * @since Bizcor 0.1
 */

get_header();
get_template_part('template-parts/section-breadcrumbs');
?>

<?php do_action( 'bizcor_main_content_before' ); ?>

<section id="post-section" class="post-section st-py-default">

	<?php do_action( 'bizcor_main_content_inner_before' ); ?>

    <div class="container">
        <div class="row g-4 wow fadeInUp">
        	<div class="col-lg-8 primary">

        		<?php do_action( 'bizcor_content_before' ); ?>

                <div class="row row-cols-1 row-cols-md-1 g-5">                    
                	<?php
                	// Check if posts exist
					if ( have_posts() ) :

						// loop
						while ( have_posts() ) : the_post();

							get_template_part( 'template-parts/entry/layout', get_post_format() );

						endwhile;

                        if( is_single() ){
                            get_template_part( 'template-parts/entry/meta', 'footer' );
                        }

						the_posts_pagination( array(
                                    'prev_text' => '<i class="fa fa-angle-double-left"></i>',
                                    'next_text' => '<i class="fa fa-angle-double-right"></i>',
                                ) );

						// If comments are open or we have at least one comment, load up the comment template.
                        if ( comments_open() || get_comments_number() ) :
                            comments_template();
                        endif;

					else:

						get_template_part( 'template-parts/entry/layout','none');

					endif;
                	?>
                </div>                

                <?php do_action( 'bizcor_content_after' ); ?>

            </div>
        	
        	<?php get_sidebar(); ?>

        </div>
    </div>

    <?php do_action( 'bizcor_main_content_inner_after' ); ?>

</section>

<?php do_action( 'bizcor_main_content_after' ); ?>

<?php get_footer(); ?>