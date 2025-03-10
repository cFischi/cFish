<?php
/*
 * Comment Template File.
 */
 if ( have_comments() ) : 	
 ?>
<div class="title">
<h2><span><?php comments_number( '', __('1 comment', 'deserve'), __('% comments', 'deserve') ); ?></span></h2>			  
</div>
<ol class="comment-list">
<?php
				wp_list_comments( array(
					'style'       => 'ol',
					'short_ping'  => true,
					'avatar_size' => 56,
				) );
?>
</ol><!-- .comment-list -->
<?php paginate_comments_links();
endif;  ?>
<div class="col-md-12 no-padding">
    <div class="reply-box">
					 <div class="input-row">
						<?php comment_form(); ?>
					</div>
			</div>
</div>