<?php 
/**
 * Right sidebar
 *
 *
 */
 
if ( ! is_active_sidebar('sidebar-1') ) {
	return;
}
?>
<div class="col-lg-4 secondary">
    <div class="sidebar">
        <?php dynamic_sidebar('sidebar-1'); ?>
    </div>
</div><!-- .secondary -->