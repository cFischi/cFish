<div class="col">
    <div class="tag-area">
        <div class="row align-items-center">
            <div class="col-md-7">
                <div class="tag-item">
                    <?php if( has_tag() ) { ?>
                    <ul class="list-group list-group-horizontal">
                        <?php the_tags( '<li class="list-group ">', '</li><li class="list-group ">', '</li>' ); ?>
                    </ul>
                    <?php } ?>
                </div>
            </div>
            <div class="col-md-5">
                <aside class="widget widget_social">
                    <div class="circle"><a href="https://www.facebook.com/sharer/sharer.php?u=<?php the_permalink(); ?>"><i class="fab fa-facebook-f"></i></a></div>
                    <div class="circle"><a href="https://twitter.com/intent/tweet?url=<?php the_permalink(); ?>"><i class="fab fa-twitter"></i></a></div>
                    <div class="circle"><a href="https://www.instagram.com/?url=<?php the_permalink(); ?>"><i class="fab fa-instagram"></i></a></div>
                    <div class="circle"><a href="https://www.linkedin.com/shareArticle?mini=true&url=<?php the_permalink(); ?>"><i class="fab fa-linkedin-in"></i></a></div>
                </aside>
            </div>
        </div>
    </div>
</div>