<?php 
global $bizcor_options;
$topbar_disable = get_theme_mod('bizcor_topbar_disable',$bizcor_options['bizcor_topbar_disable']);
$topbar_texts = bizcor_header_topbar_data();
if($topbar_disable==false){
?>
<div class="row-top">
    <div class="container">
        <div class="row">
            <div class="col">
                <div class="main-menu-right main-left">
                    <ul class="menu-right-list d-flex justify-content-between">
                        <?php 
                        if(!empty($topbar_texts)) { 
                            foreach ($topbar_texts as $text) {
                        ?>
                        <li class="content-list">
                            <aside class="widget widget-contact first">
                                <div class="contact-area">
                                    <div class="contact-info">
                                        <p class="top-text"><?php echo wp_kses_post($text['text']); ?></p>
                                    </div>
                                </div>
                            </aside>
                        </li>
                        <?php } } ?>
                    </ul>
                </div>
            </div>
        </div>
    </div>
</div>
<?php } ?>