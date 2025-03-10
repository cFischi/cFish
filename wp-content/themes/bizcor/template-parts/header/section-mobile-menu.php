<?php 
global $bizcor_options;
$sticky_disable = get_theme_mod('bizcor_h_sticky_disable',$bizcor_options['bizcor_h_sticky_disable']);
$stick_class = 'is-sticky-on';
?>
<div class="main-mobile-nav <?php if($sticky_disable==false){ echo esc_attr( $stick_class ); } ?>">
    <div class="container">
        <div class="row">
            <div class="col-12">
                <div class="main-mobile-menu">
                    <div class="mobile-logo">
                        <div class="logo">
                            <div class="site-title">
                                <?php bizcor_logo(); ?>
                            </div>
                        </div>
                    </div>
                    <div class="menu-collapse-wrap">
                        <div class="hamburger-menu">
                            <button type="button" class="menu-collapsed" aria-label="Menu Collaped">
                            <div class="top-bun"></div>
                            <div class="meat"></div>
                            <div class="bottom-bun"></div>
                            </button>
                        </div>
                    </div>
                    <div class="main-mobile-wrapper">
                        <div id="mobile-menu-build" class="main-mobile-build">
                            <div class="main-mobile-build-logo">
                                <div class="site-title">
                                    <?php bizcor_logo(); ?>
                                </div>
                            </div>
                            <button type="button" class="header-close-menu close-style" aria-label="Header Close Menu"></button>
                        </div>
                        <div class="main-mobile-overlay" tabindex="-1"></div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>