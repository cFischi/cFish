<?php
global $bizcor_options;
$column = absint( get_theme_mod('bizcor_footer_middle_columns',$bizcor_options['bizcor_footer_middle_columns']) );
$max_cols = 12;
$layouts = 12;
if ( $column > 1 ){
    $default = "12";
    switch ( $column ) {
        case 4:
            $default = '3+3+3+3';
            break;
        case 3:
            $default = '4+4+4';
            break;
        case 2:
            $default = '6+6';
            break;
    }
    $layouts = sanitize_text_field( get_theme_mod( 'footer_custom_'.$column.'_columns', $default ) );
}

$layouts = explode( '+', $layouts );
foreach ( $layouts as $k => $v ) {
    $v = absint( trim( $v ) );
    $v =  $v >= $max_cols ? $max_cols : $v;
    $layouts[ $k ] = $v;
}

$have_widgets = false;

for ( $count = 0; $count < $column; $count++ ) {
    $id = 'footer-' . ( $count + 1 );
    if ( is_active_sidebar( $id ) ) {
        $have_widgets = true;
    }
}

if ( $column > 0 && $have_widgets ) { 
?>
<div class="footer-main">
    <div class="container">
        <div class="row g-4">
            <?php
             for ( $count = 0; $count < $column; $count++ ) {
             $col = isset( $layouts[ $count ] ) ? $layouts[ $count ] : '';
             $id = 'footer-' . ( $count + 1 );
             if ( $col ) {
            ?>
            <div id="bizcor-footer-<?php echo esc_attr( $count + 1 ) ?>" class="col-lg-<?php echo esc_attr( $col ); ?> col-sm-6 wow fadeInUp">
                <?php dynamic_sidebar( $id ); ?>
            </div>
            <?php } } ?>
        </div>
    </div>
</div>
<?php } ?>