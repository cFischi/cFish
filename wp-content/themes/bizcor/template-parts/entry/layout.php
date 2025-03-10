<?php 
// getting blog post format
$format = get_post_format();
?>
<div id="post-<?php the_ID(); ?>" class="col">
    <article <?php post_class('post-items'); ?>>

        <?php get_template_part( 'template-parts/entry/media/entry-media', $format ); ?>

        <div class="post-content">
            <div class="post-detail">
                <?php 
                    get_template_part( 'template-parts/entry/date' );
                    get_template_part( 'template-parts/entry/title' );
                    get_template_part( 'template-parts/entry/content' );
                    bizcor_edit_link();
                ?>                
            </div>
            <?php 
                get_template_part( 'template-parts/entry/meta' );
            ?>
        </div>
    </article>
</div>