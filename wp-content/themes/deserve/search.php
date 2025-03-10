<?php
/*
 * Search Template File.
 */
get_header(); ?>
<section>
    <div class="breadcumb-bg">
	<div class="deserve-container container">
    	<div class="site-breadcumb">
			<div class="row">
			 <div class="col-md-6 col-sm-6">
				<h1>
					<?php printf(/* translators: %s is Search query */
					 esc_html__( 'Search Results for : %s', 'deserve' ), get_search_query() ); ?>
				</h1>
			 </div>
			  <div class="col-md-6 col-sm-6">
				<ol class="breadcrumb breadcrumb-menubar">
				<?php if (function_exists('deserve_custom_breadcrumbs')) deserve_custom_breadcrumbs(); ?>
				</ol>
            </div>
            </div>
        </div>
    </div>
    </div>
    <div class="deserve-container">
        <div class="col-md-9 col-sm-8  dblog">
			<?php if(have_posts()):
				while ( have_posts() ) : the_post(); ?>
					<div class="blog-box">
		            	<?php  if(has_post_thumbnail()) { ?>
		                    <a href="<?php the_permalink(); ?>">
		                    <?php the_post_thumbnail('large'); ?>
		                    </a>
		                <?php } ?>
		                  <div class="post-data">
							<a href="<?php the_permalink(); ?>" class="blog-title"><?php the_title(); ?></a>
							 <div class="post-meta">
								<ul>
									<?php deserve_entry_meta(); ?>
								</ul>
		                    </div>
		                   <?php the_excerpt(); ?>
		                </div>
		            </div>
	        <?php endwhile;
         else : ?>
		    <div class="blog-box">
			    <div class="post-data">
					<h2><?php esc_html_e('Sorry, but nothing matched your search terms. Please try again with some different keywords.','deserve'); ?> </h2>
				</div>
				<div class="col-md-4">
					<?php get_search_form(); ?>
				</div>
			</div>
      	<?php  endif;?>
            <div class="gallery-pagination blog-pagination">
	            <ul>
	            	<li class="link_pagination" >
						<?php deserve_pagination(); ?>
					</li>
				</ul>
            </div>
        </div>
    <?php get_sidebar(); ?>
    </div>
</section>
<?php get_footer()	; 