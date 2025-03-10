<?php
/**
 * The template to override product content within loops
 */

defined( 'ABSPATH' ) || exit;

global $product;

// Ensure visibility.
if ( empty( $product ) || ! $product->is_visible() ) {
	return;
}
?>
<li <?php wc_product_class('',$product); ?>>
	<div class="product">
		<div class="product-single">
			<div class="product-img">
				<?php
				/**
				 * Hook: woocommerce_before_shop_loop_item.
				 *
				 * @hooked woocommerce_template_loop_product_link_open - 10
				 */
				do_action( 'woocommerce_before_shop_loop_item' );
				?>
				<a href="<?php the_permalink(); ?>">
					<?php the_post_thumbnail(); ?>
				</a>
				
				<?php if ( $product->is_on_sale() ) : ?>
					<?php echo apply_filters( 'woocommerce_sale_flash', '<div class="sale-ribbon"><span class="tag-line">' . esc_html__( 'Sale', 'bizcor' ) . '</span></div>', $post, $product ); ?>
				<?php endif; ?>

                <div class="product-action">			
					<?php 
					if(class_exists( 'YITH_WCQV' )) {  echo do_shortcode( '[yith_quick_view]' ); } 
					if(class_exists( 'YITH_WCWL' )) { echo do_shortcode( '[yith_wcwl_add_to_wishlist]' ); }
					if(class_exists( 'YITH_WOOCOMPARE' )) {  echo do_shortcode( '[yith_compare_button]' ); } 
					?>
				</div> 
			</div>
			<div class="product-content-outer">
				<div class="product-content">
					<div class="pro-rating">
						<?php 
						if ($average = $product->get_average_rating()) : 
							echo '<div class="star-rating" title="'.sprintf(__( 'Rated %s out of 5', 'bizcor' ), $average).'"><span style="width:'.( ( $average / 5 ) * 100 ) . '%"><strong itemprop="ratingValue" class="rating">'.$average.'</strong> '.__( 'out of 5', 'bizcor' ).'</span></div>'; 
						endif; 
						?>
					</div>
					<h3>
						<a href="<?php the_permalink(); ?>"><?php the_title(); ?></a>
					</h3>
					<div class="price">
						<?php echo wp_kses_post($product->get_price_html()); ?>
					</div>
					<?php

					/**
					 * Hook: woocommerce_after_shop_loop_item.
					 *
					 * @hooked woocommerce_template_loop_product_link_close - 5
					 * @hooked woocommerce_template_loop_add_to_cart - 10
					 */
					// do_action( 'woocommerce_after_shop_loop_item' );
					 woocommerce_template_loop_add_to_cart(); 
					?>
				</div>
			</div>
		</div>
	</div>
</li>