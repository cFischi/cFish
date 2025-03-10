<?php do_action( 'bizcor_header_before' ); ?>

<header id="main-header" class="main-header header-one">

    <?php do_action( 'bizcor_header_inner_before' ); ?>

    <div class="navigation-wrapper">

        <?php do_action( 'bizcor_header_inner_nav_wrap_before' ); ?>

        <div class="main-navigation-area d-none d-lg-block">

            <div class="main-navigation ">

                <div class="container">

                    <?php do_action( 'bizcor_header_navigation_before' ); ?>

                    <div class="bg-area">
                        
                        <?php do_action( 'bizcor_header_navigation' ); ?>
                        
                    </div>
                    
                    <?php do_action( 'bizcor_header_navigation_after' ); ?>
                    
                </div>

            </div>
            
        </div>
        
        <?php do_action( 'bizcor_header_inner_nav_wrap_after' ); ?>
        
    </div>

    <?php do_action( 'bizcor_header_inner_after' ); ?>

</header>

<?php do_action( 'bizcor_header_after' ); ?>