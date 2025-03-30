<?php
/**
 * Plugin Name: Inbox Pro Web Chat Widget
 * Version: 1.0.0
 * Description: Adds the AI-assisted web chat to your WordPress site.
 **/

 function my_chat_widget_enqueue_script() {
    wp_enqueue_script( 'web-chat-widget-script', 'https://cdn.apigateway.co/webchat-client..prod/sdk.js', array(), '1.0.0', false );
}
add_action( 'wp_enqueue_scripts', 'my_chat_widget_enqueue_script' );

function add_script_attributes( $tag, $handle ) {
    if ( 'web-chat-widget-script' !== $handle ) {
        return $tag;
    }
    return str_replace( ' src', ' data-widget-id="5324afd1-ad2a-11ef-8d72-229eeba38e3c" defer src', $tag );
}
add_filter( 'script_loader_tag', 'add_script_attributes', 10, 2 );
