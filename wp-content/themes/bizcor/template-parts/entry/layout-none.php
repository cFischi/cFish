<div class="col">
    <article class="post-items blog-single">
        <div class="post-content">
            <div class="post-detail">
                <div class="entry-content">
					<?php if ( is_home() && current_user_can( 'publish_posts' ) ) { ?>
						<p><?php echo sprintf( esc_html__( 'Ready to publish your first post? %1$sGet started here%2$s.', 'bizcor' ), '<a href="'. esc_url( admin_url( 'post-new.php' ) ) .'" target="_blank">', '</a>' ); ?></p>
					<?php } elseif ( is_search() ) { ?>
						<p><?php esc_html_e( 'Sorry, but nothing matched your search terms. Please try again with different keywords.', 'bizcor' ); ?></p>
					<?php } elseif ( is_category() ) { ?>
						<p><?php esc_html_e( 'There aren\'t any posts currently published in this category.', 'bizcor' ); ?></p>
					<?php } elseif ( is_tax() ) { ?>
						<p><?php esc_html_e( 'There aren\'t any posts currently published under this taxonomy.', 'bizcor' ); ?></p>
					<?php } elseif ( is_tag() ) { ?>
						<p><?php esc_html_e( 'There aren\'t any posts currently published under this tag.', 'bizcor' ); ?></p>
					<?php } else { ?>
						<p><?php esc_html_e( 'It seems we can&rsquo;t find what you&rsquo;re looking for.', 'bizcor' ); ?></p>
					<?php } ?>
				</div>                
            </div>            
        </div>
    </article>
</div>
