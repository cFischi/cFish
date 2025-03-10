<?php 
/*
 * 404 Template File.
 */
get_header(); ?>
<section>
    <div class="breadcumb-bg">
	<div class="deserve-container container">
    	<div class="site-breadcumb">
			  <div class="row">
			 <div class="col-md-6 col-sm-6">
				<h1><?php esc_html_e('404 - Article Not Found','deserve');?></h1>
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
            <div class="blog-box">
                <div class="post-data">
				    <div class="jumbotron">
                    	<h1><?php esc_html_e('Epic 404 - Article Not Found','deserve'); ?></h1>
                    	<p><?php esc_html_e("This is embarassing. We can't find what you were looking for.","deserve"); ?></p>
        					<section class="post_content">
                                <p><?php esc_html_e('Whatever you were looking for was not found, but maybe try looking again or search using the form below.','deserve'); ?></p>
                                <div class="row">
                                    <div class="col-sm-12">
                                    <?php get_search_form(); ?>
                                    </div>
                                </div>
                             </section>
                    </div>
                </div>             
            </div>
        </div>
       <?php get_sidebar(); ?>
    </div>
</section>
<?php get_footer(); ?>