<?php
defined( 'ABSPATH' ) || exit;

global $product;

// Ensure visibility.
if ( empty( $product ) || ! $product->is_visible() ) {
	return;
}
?>
<li <?php wc_product_class( '', $product ); ?>>
	<div class="product">
		<div class="product-single">

			<div class="product-bg"></div>
			
			<div class="product-img">
				<a href="<?php the_permalink(); ?>">
					<img src="<?php the_post_thumbnail_url(); ?>" class="attachment-post-thumbnail size-post-thumbnail wp-post-image" loading="lazy" />
				</a>

				<div class="btn-group"></div>
				
				<?php if ( $product->is_on_sale() ) : ?>
					<?php if ( is_page_template( 'templates/template-frontpage-2.php' )): ?>
						<?php echo apply_filters( 'woocommerce_sale_flash', '<div class="sale-ribbon sale"><span class="tag-line">' . esc_html__( 'Sale', 'bizcor' ) . '</span></div>', $post, $product ); ?>
					<?php else: ?>	
						<?php echo apply_filters( 'woocommerce_sale_flash', '<div class="sale-ribbon"><span class="tag-line">' . esc_html__( 'Sale', 'bizcor' ) . '</span></div>', $post, $product ); ?>
					<?php endif; ?>
				<?php endif; ?>
			</div>

			<div class="product-content-outer">
				<div class="product-content">                                                    
					<h3>
						<a href="<?php the_permalink(); ?>"><?php the_title(); ?></a>
					</h3>
						
					<?php if ($average = $product->get_average_rating()) : ?>
						<?php echo '<i class="fa fa-star" title="'.sprintf(__( 'Rated %s out of 5', 'bizcor' ), $average).'"><span style="width:'.( ( $average / 5 ) * 100 ) . '%"><strong itemprop="ratingValue" class="rating">'.$average.'</strong> '.__( 'out of 5', 'bizcor' ).'</span></i>'; ?>
					<?php endif; ?>

					<div class="price">
						<?php  echo $product->get_price_html(); ?>
					</div>

					<?php woocommerce_template_loop_add_to_cart(); ?>

				</div>
				<div class="product-action"></div>
			</div>
		</div>
	</div>
</li>