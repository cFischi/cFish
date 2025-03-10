<div id="post-<?php the_ID(); ?>" >
    <article <?php post_class('post-items blog-single'); ?>>

        <?php if( has_post_thumbnail() ): ?>
        <figure class="post-image">
            <div class="featured-image">
                <?php the_post_thumbnail('full'); ?>
            </div>
            <?php
            get_template_part( 'template-parts/entry/date' );
            ?>
        </figure>
        <?php endif; ?>

        <div class="post-content">
            <div class="post-detail">
                <?php 
                    get_template_part( 'template-parts/entry/title' );
                    get_template_part( 'template-parts/entry/content' );
                    bizcor_edit_link();
                ?>                
            </div>
            <?php 
                if(BIZCOR_THEME_NAME!='Bizcor'){
                    // get_template_part( 'template-parts/entry/meta' );
                }
            ?>
        </div>
    </article>
</div>