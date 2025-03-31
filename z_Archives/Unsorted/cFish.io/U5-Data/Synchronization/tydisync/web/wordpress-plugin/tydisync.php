<?php
/**
 * Plugin Name: tYDiSync~ Integration
 * Plugin URI: https://cfish.io/tydisync
 * Description: Integrates tYDiSync~ synchronization functionality with WordPress, allowing content from JSON sources to be seamlessly displayed and managed within WordPress sites.
 * Version: 0.1.0
 * Author: tYDiSync~ Team
 * Author URI: https://cfish.io
 * Text Domain: tydisync
 * Domain Path: /languages
 * Requires at least: 6.0
 * Requires PHP: 7.4
 *
 * @package TYDiSync
 */

// If this file is called directly, abort.
if (!defined('WPINC')) {
    die;
}

/**
 * Current plugin version.
 */
define('TYDISYNC_VERSION', '0.1.0');
define('TYDISYNC_PLUGIN_DIR', plugin_dir_path(__FILE__));
define('TYDISYNC_PLUGIN_URL', plugin_dir_url(__FILE__));

/**
 * The core plugin class.
 */
require_once TYDISYNC_PLUGIN_DIR . 'includes/class-tydisync.php';

/**
 * Begins execution of the plugin.
 */
function run_tydisync() {
    $plugin = new TYDiSync();
    $plugin->run();
}

/**
 * Run the plugin.
 */
run_tydisync();

/**
 * Register activation hook.
 */
register_activation_hook(__FILE__, 'tydisync_activate');

/**
 * Register deactivation hook.
 */
register_deactivation_hook(__FILE__, 'tydisync_deactivate');

/**
 * Plugin activation.
 */
function tydisync_activate() {
    // Create necessary database tables
    require_once TYDISYNC_PLUGIN_DIR . 'includes/class-tydisync-activator.php';
    TYDiSync_Activator::activate();
}

/**
 * Plugin deactivation.
 */
function tydisync_deactivate() {
    // Clean up if needed
    require_once TYDISYNC_PLUGIN_DIR . 'includes/class-tydisync-deactivator.php';
    TYDiSync_Deactivator::deactivate();
}

/**
 * Register the [tydisync] shortcode
 */
function tydisync_shortcode($atts) {
    // Parse attributes
    $atts = shortcode_atts(
        array(
            'source' => '',
            'field' => '',
            'template' => 'default',
            'limit' => -1,
            'filter' => '',
        ),
        $atts,
        'tydisync'
    );
    
    // Load the shortcode handler
    require_once TYDISYNC_PLUGIN_DIR . 'includes/class-tydisync-shortcode.php';
    $shortcode_handler = new TYDiSync_Shortcode();
    
    // Process the shortcode
    return $shortcode_handler->render($atts);
}
add_shortcode('tydisync', 'tydisync_shortcode');

/**
 * Cross-platform PowerShell execution
 */
function tydisync_execute_powershell($command) {
    // Determine OS and path to PowerShell
    $is_windows = (strtoupper(substr(PHP_OS, 0, 3)) === 'WIN');
    $powershell_path = $is_windows ? 'powershell.exe' : '/usr/bin/pwsh';
    
    // Check if PowerShell Core is available
    if (file_exists($is_windows ? 'C:\\Program Files\\PowerShell\\7\\pwsh.exe' : '/usr/bin/pwsh')) {
        $powershell_path = $is_windows ? 'C:\\Program Files\\PowerShell\\7\\pwsh.exe' : '/usr/bin/pwsh';
    }
    
    // Build the command
    $full_command = $is_windows 
        ? "$powershell_path -ExecutionPolicy Bypass -Command \"$command\""
        : "$powershell_path -Command \"$command\"";
    
    // Execute the command
    $output = array();
    $return_var = 0;
    exec($full_command, $output, $return_var);
    
    // Return the results
    return array(
        'output' => $output,
        'return_var' => $return_var,
        'success' => ($return_var === 0),
    );
}

/**
 * Add admin menu items
 */
function tydisync_admin_menu() {
    add_menu_page(
        __('tYDiSync~ Integration', 'tydisync'),
        __('tYDiSync~', 'tydisync'),
        'manage_options',
        'tydisync',
        'tydisync_admin_page',
        'dashicons-update',
        100
    );
    
    add_submenu_page(
        'tydisync',
        __('Settings', 'tydisync'),
        __('Settings', 'tydisync'),
        'manage_options',
        'tydisync-settings',
        'tydisync_settings_page'
    );
    
    add_submenu_page(
        'tydisync',
        __('Content Mapping', 'tydisync'),
        __('Content Mapping', 'tydisync'),
        'manage_options',
        'tydisync-mapping',
        'tydisync_mapping_page'
    );
    
    add_submenu_page(
        'tydisync',
        __('Logs', 'tydisync'),
        __('Logs', 'tydisync'),
        'manage_options',
        'tydisync-logs',
        'tydisync_logs_page'
    );
}
add_action('admin_menu', 'tydisync_admin_menu');

/**
 * Render the main admin page
 */
function tydisync_admin_page() {
    require_once TYDISYNC_PLUGIN_DIR . 'admin/partials/tydisync-admin-display.php';
}

/**
 * Render the settings page
 */
function tydisync_settings_page() {
    require_once TYDISYNC_PLUGIN_DIR . 'admin/partials/tydisync-admin-settings.php';
}

/**
 * Render the content mapping page
 */
function tydisync_mapping_page() {
    require_once TYDISYNC_PLUGIN_DIR . 'admin/partials/tydisync-admin-mapping.php';
}

/**
 * Render the logs page
 */
function tydisync_logs_page() {
    require_once TYDISYNC_PLUGIN_DIR . 'admin/partials/tydisync-admin-logs.php';
}

/**
 * Register settings
 */
function tydisync_register_settings() {
    register_setting('tydisync_options', 'tydisync_powershell_path');
    register_setting('tydisync_options', 'tydisync_sync_directory');
    register_setting('tydisync_options', 'tydisync_auto_sync');
    register_setting('tydisync_options', 'tydisync_sync_interval');
    register_setting('tydisync_options', 'tydisync_debug_mode');
}
add_action('admin_init', 'tydisync_register_settings');

/**
 * Add dashboard widget
 */
function tydisync_add_dashboard_widget() {
    wp_add_dashboard_widget(
        'tydisync_dashboard_widget',
        __('tYDiSync~ Status', 'tydisync'),
        'tydisync_dashboard_widget_callback'
    );
}
add_action('wp_dashboard_setup', 'tydisync_add_dashboard_widget');

/**
 * Render dashboard widget
 */
function tydisync_dashboard_widget_callback() {
    require_once TYDISYNC_PLUGIN_DIR . 'admin/partials/tydisync-dashboard-widget.php';
} 