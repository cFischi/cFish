<?php 
/*
 * Attachment Template File.
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
    <div  id="post-<?php the_ID(); ?>" <?php post_class("deserve-container"); ?>>       
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
							<?php if (function_exists('deserve_entry_meta')) deserve_entry_meta(); ?>												
						</ul>                    
                    </div>
                     <?php the_content(); ?>
                </div>       
            </div>
        	<?php endwhile; ?>
			<div class="comments-article">
				 <?php comments_template(); ?>
			</div>
        </div>
       <?php get_sidebar(); ?> 
    </div>
</section>
<?php get_footer(); ?>