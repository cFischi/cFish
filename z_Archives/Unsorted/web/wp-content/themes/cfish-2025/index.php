<?php
/**
 * The main template file
 *
 * This is the most generic template file in a WordPress theme
 * and one of the two required files for a theme (the other being style.css).
 * It is used to display a page when nothing more specific matches a query.
 *
 * @link https://developer.wordpress.org/themes/basics/template-hierarchy/
 *
 * @package CFish_2025
 */

get_header();
?>

<main id="primary" class="site-main">
	<div class="container">
		<div class="content-area">
			<?php if ( have_posts() ) : ?>

				<header class="page-header">
					<?php if ( is_home() && ! is_front_page() ) : ?>
						<h1 class="page-title"><?php single_post_title(); ?></h1>
					<?php elseif ( is_search() ) : ?>
						<h1 class="page-title">
							<?php
							/* translators: %s: search query. */
							printf( esc_html__( 'Search Results for: %s', 'cfish-2025' ), '<span>' . get_search_query() . '</span>' );
							?>
						</h1>
					<?php elseif ( is_archive() ) : ?>
						<?php the_archive_title( '<h1 class="page-title">', '</h1>' ); ?>
						<?php the_archive_description( '<div class="archive-description">', '</div>' ); ?>
					<?php endif; ?>
				</header><!-- .page-header -->

				<div class="posts-grid">
					<?php
					/* Start the Loop */
					while ( have_posts() ) :
						the_post();

						/*
						 * Include the Post-Type-specific template for the content.
						 * If you want to override this in a child theme, then include a file
						 * called content-___.php (where ___ is the Post Type name) and that will be used instead.
						 */
						get_template_part( 'template-parts/content', get_post_type() );

					endwhile;
					?>
				</div><!-- .posts-grid -->

				<?php
				// Previous/next page navigation
				the_posts_pagination( 
					array(
						'prev_text'          => '&larr; ' . __( 'Previous', 'cfish-2025' ),
						'next_text'          => __( 'Next', 'cfish-2025' ) . ' &rarr;',
						'before_page_number' => '<span class="meta-nav screen-reader-text">' . __( 'Page', 'cfish-2025' ) . ' </span>',
					)
				);
				?>

			<?php else : ?>

				<?php get_template_part( 'template-parts/content', 'none' ); ?>

			<?php endif; ?>
		</div><!-- .content-area -->

		<?php get_sidebar(); ?>
	</div><!-- .container -->
</main><!-- #primary -->

<?php
get_footer(); 