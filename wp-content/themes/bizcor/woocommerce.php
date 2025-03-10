<?php
/**
 * @package Bizcor
 */

get_header();
get_template_part('template-parts/section-breadcrumbs');
?>
<section id="product" class="product-section st-py-default">
    <div class="container">
        <div class="row gy-lg-0 gy-5 wow fadeInUp">
			<div id="product-content" class="col-lg-<?php if ( !is_active_sidebar( 'woocommerce' ) ){ echo '12'; }else{ echo '8'; } ?>">
				<?php woocommerce_content(); ?>
			</div>
			<?php get_sidebar('woocommerce'); ?>
		</div>	
	</div>
</section>
<?php get_footer(); ?>