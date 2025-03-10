<?php do_action( 'bizcor_entry_content_before' ); ?>

<div class="entry-content">
    <?php 
    the_content( sprintf(
                    /* translators: %s: Name of current post. */
                    wp_kses( __( 'Continue reading %s <span class="meta-nav">&rarr;</span>', 'bizcor' ), array( 'span' => array( 'class' => array() ) ) ),
                    the_title( '<span class="screen-reader-text">"', '"</span>', false )
                ) );

    wp_link_pages( array(
                    'before' => '<div class="page-links">' . esc_html__( 'Pages:', 'bizcor' ),
                    'after'  => '</div>',
                ) );
    ?>
</div>

<?php do_action( 'bizcor_entry_content_after' ); ?>