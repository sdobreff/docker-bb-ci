<?php
/**
 * The plugin bootstrap file
 *
 * This file is read by WordPress to generate the plugin information in the plugin
 * admin area. This file also includes all of the dependencies used by the plugin,
 * registers the activation and deactivation functions, and defines a function
 * that starts the plugin.
 *
 * @link              https://wp-secured.com
 * @since             1.0.0
 * @package           Secured
 *
 * @wordpress-plugin
 * Plugin Name:       Secured WP
 * Plugin URI:        https://wp-secured.com
 * Description:       Provides Security for WP sites. 2FA, login attempts, hardens WP login process
 * Version:           1.5.0
 * Author:            wp-secured
 * Author URI:        https://wp-secured.com
 * Author email:      wp.secured.com@gmail.com
 * License:           GPL-2.0+
 * License URI:       http://www.gnu.org/licenses/gpl-2.0.txt
 * Text Domain:       wp-secured
 * Domain Path:       /languages
 * License:           GPL2 or later
 * License URI:       http://www.gnu.org/licenses/gpl-2.0.html
 */

/** Prevent default call */
if ( ! function_exists( 'add_action' ) ) {
    exit;
}

require __DIR__ . '/vendor/autoload.php';
require __DIR__ . '/constants.php';

add_action( 'init', [ 'WPSEC\\Secured', 'init' ] );
add_action( 'init', [ 'WPSEC\\Controllers\\LoginCheck', 'checkOOBAndLogin' ] );

add_filter( 'plugin_action_links_' . plugin_basename( __FILE__ ), [ 'WPSEC\\Secured', 'addActionLinks' ] );

if ( ! (bool) WPSEC\Controllers\Modules\RememberMe::getGlobalSettingsValue() ) {
    add_filter( 'determine_current_user', [ 'WPSEC\\Controllers\\Modules\\RememberMe', 'checkRememberMe' ], 99 );
}

// Fires wp-login redirection.
if ( ! (bool) \WPSEC\Controllers\Modules\Login::getGlobalSettingsValue() ) {
    add_action(
        'plugins_loaded',
        function() {
            \WPSEC\Controllers\Modules\Login::init();
        }
    );
}

register_activation_hook( __FILE__, [ 'WPSEC\\Secured', 'pluginActivation' ] );
