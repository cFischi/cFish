<?php 
global $bizcor_options;
$backTotop_disable = get_theme_mod('bizcor_backTotop_disable',$bizcor_options['bizcor_backTotop_disable']);
if($backTotop_disable==false){ 
?>
<div class="prgoress_scrollingUp scrolling-btn">
    <svg class="progress-circle svg-content" width="100%" height="100%" viewBox="-1 -1 102 102">
        <path d="M50,1 a49,49 0 0,1 0,98 a49,49 0 0,1 0,-98" />
    </svg>
</div>
<?php } ?>