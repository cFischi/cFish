<?php

class Bizcor_Editor_Scripts{

    public static function enqueue() {

        if ( ! class_exists( '_WP_Editors' ) ) {
            require ABSPATH . WPINC . '/class-wp-editor.php';
        }

        add_action('customize_controls_print_footer_scripts',array( __CLASS__,'enqueue_editor' ),2);
        add_action('customize_controls_print_footer_scripts',array('_WP_Editors','editor_js' ),50);
        add_action('customize_controls_print_footer_scripts',array('_WP_Editors','enqueue_scripts'),1);
    }

    public  static function enqueue_editor(){
        if( ! isset( $GLOBALS['__wp_mce_editor__'] ) || ! $GLOBALS['__wp_mce_editor__'] ) {
            $GLOBALS['__wp_mce_editor__'] = true;
            ?>
            <script id="_wp-mce-editor-tpl" type="text/html">
                <?php wp_editor('', '__wp_mce_editor__'); ?>
            </script>
            <?php
        }
    }
}
add_action( 'customize_controls_enqueue_scripts',array('Bizcor_Editor_Scripts','enqueue'),95);

function bizcor_customizer_control_scripts(){
    wp_enqueue_media();
    wp_enqueue_script('jquery-ui-sortable');
    wp_enqueue_script('wp-color-picker');
    wp_enqueue_style('wp-color-picker');
    wp_enqueue_script('bizcor-customizer',get_template_directory_uri().'/inc/customizer/js/customizer.js',array('customize-controls','wp-color-picker'));
    wp_enqueue_style('bizcor-customizer-js',get_template_directory_uri().'/inc/customizer/css/customizer.css');
}
add_action( 'customize_controls_enqueue_scripts','bizcor_customizer_control_scripts',99);

function bizcor_enqueue_editor(){
    if( ! isset( $GLOBALS['__wp_mce_editor__'] ) || ! $GLOBALS['__wp_mce_editor__'] ) {
        $GLOBALS['__wp_mce_editor__'] = true;
        ?>
        <script id="_wp-mce-editor-tpl" type="text/html">
            <?php wp_editor('', '__wp_mce_editor__'); ?>
        </script>
        <?php
    }
}

function bizcor_customize_preview_script() {
    wp_enqueue_script(
        'bizcor-customize-preview',
        get_template_directory_uri().'/inc/customizer/js/customize-preview.js',
        array('customize-preview'),
        '20160816',
        true
    );
}
add_action( 'customize_preview_init','bizcor_customize_preview_script');

function bizcor_customize_controls_icons_scripts(){

    $icons = bizcor_fontawesome_icons_list();
    
    $string_icons='';
    foreach( $icons as $key => $value ){
        $string_icons = $string_icons.'|'.$key;
    }

    wp_localize_script( 'customize-controls', 'bizcor_icons', array_keys($icons) );

    $string_icons = substr($string_icons, 1);

    wp_localize_script( 'customize-controls', 'C_Icon_Picker',
        apply_filters( 'c_icon_picker_js_setup',
            array(
                'search'    => esc_html__( 'Search', 'bizcor' ),
                'fonts' => array(
                    'font-awesome' => array(
                        // Name of icon
                        'name' => esc_html__( 'Font Awesome', 'bizcor' ),
                        // Prefix class example for font-awesome fa-fa-{name}
                        'prefix' => '',
                        // Font url
                        'url' => esc_url( add_query_arg( array( 'ver'=> '5.14.0' ), get_template_directory_uri() .'/assets/css/all.min.css' ) ),
                        // Icon class name, separated by |
                        'icons' => $string_icons,
                    ),
                )
            )
        )
    );
}
add_action( 'customize_controls_enqueue_scripts','bizcor_customize_controls_icons_scripts');