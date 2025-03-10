<?php if( has_post_thumbnail() ): ?>
<figure class="post-image">
    <div class="featured-image">

        <?php the_post_thumbnail('full'); ?>

        <?php if( ( !is_single() ) ){ ?>

        <a href="<?php the_permalink(); ?>">
            <div class="image-overlay-icon">
                <div class="icon"><i class="fa fa-plus"></i></div>
            </div>
        </a>

        <?php } ?>

    </div>
</figure>
<?php endif; ?>