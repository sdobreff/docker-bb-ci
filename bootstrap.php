<?php

// bootstrap.php

/*new approach*/

require_once __DIR__ . '/tests/PHPUnitSetUp/install.php';

activate_plugin( __DIR__ . '/wp-2fa.php' );
/*old approach*/
require_once __DIR__ . '/vendor/autoload.php';

if ( '' !== getenv( 'HTTP_HOST' ) ) {
    /** need that in order to test in my local env before fire WP 😉 */
    putenv( 'HTTP_HOST=local.wp-secured.plugin' );
}

require_once __DIR__ . '/../../../wp-load.php';
