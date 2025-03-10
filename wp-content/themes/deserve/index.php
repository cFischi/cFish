<?php 
/*
 * Main Template File.
 */
get_header(); ?>
<section>
    <div class="deserve-container">       
        <div class="col-md-9 col-sm-8  dblog">        
                  <?php while ( have_posts() ) : the_post(); ?>            
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
         <?php endwhile;  ?>
            <div class="gallery-pagination blog-pagination">
                <ul>						
						<?php if (function_exists('the_posts_pagination')) 
						{ ?>
						<li class="link_pagination" >
								<?php deserve_pagination(); ?>
						</li>
					<?php } else { ?>
							<li class="link_pagination"><?php previous_posts_link( '<<' ); ?> </li>
							<li class="link_pagination"><?php next_posts_link( '>>' ); ?> </li>
					
					<?php } ?>				
                </ul>
            </div>
        </div>
    <?php get_sidebar(); ?> 
    </div>
</section>
<?php get_footer();