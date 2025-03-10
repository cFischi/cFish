<?php 
/*
 * Template Name: Full Width
 */
get_header(); ?>
<section>
    <div class="breadcumb-bg">
    	<div class="deserve-container container">
        	<div class="site-breadcumb">
    			<div class="row">
    			 <div class="col-md-6 col-sm-6">
    				<h1><?php the_title(); ?></h1>
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
        <div class="col-md-12 dblog">         
            <?php while ( have_posts() ) : the_post(); ?>                 
                <div class="blog-box">              
                	<?php  if(has_post_thumbnail()) { ?>
                        <?php the_post_thumbnail('full'); ?>
                    <?php } ?>
                    <div class="post-data">    			
                      <h2 class="single-page-title"><?php the_title(); ?></h2>        
                        <?php  the_content(); ?>
                    </div>             
                </div>    	
    		<?php endwhile; ?>    			
    		<div class="comments-article">
    			 <?php comments_template(); ?>
    		</div>
        </div>
    </div>
</section>
<?php get_footer();