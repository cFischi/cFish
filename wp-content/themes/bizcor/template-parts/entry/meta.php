<?php
global $authordata;
?>
<div class="post-btn">
    <a href="<?php echo esc_url( get_author_posts_url( $authordata->ID, $authordata->user_nicename ) ); ?>" class="btn"><span><i class="fas fa-user"></i></span> <?php echo get_the_author(); ?></a>

    <?php if( has_category() ) { ?>
    <div class="btn"><span><i class="fa fa-tags"></i></span> <?php the_category( '<span class="swp-sep">,</span> ', get_the_ID() ); ?></div>
    <?php } ?>
</div>