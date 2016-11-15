#!/bin/bash
set -e

ROOTTP="/teampassinit"

rm -rf $ROOTTP/install

# No need to hardcode the full url
sed -i "s/self::\$config\['jsUrl'\]/'\/includes\/libraries\/csrfp\/js\/csrfprotector\.js'/" $ROOTTP/includes/libraries/csrfp/libs/csrf/csrfprotector.php

# Fix really short password show timeout 50ms to 10s
sed -i "s/, 50/, 10000/" $ROOTTP/items.load.php

# PHP sessions need to be garbage collected, otherwise we run out of inodes
sed -i "s/session.gc_probability = 0/session.gc_probability = 1/" /etc/php5/apache2/php.ini

# Make ops managers the default managers (this should be taken out if it's a db without an ops role)
sed -i "s/'fonction_id' => '0',/'fonction_id' => '0','isAdministratedByRole' => '1',/" $ROOTTP/sources/identify.php

echo '<?php
/**
 * Configuration file for CSRF Protector z
 */

return array(
   "CSRFP_TOKEN" => getenv("CSRFP_TOKEN"),
   "logDirectory" => "../log",
   "failedAuthAction" => array(
      "GET" => 0,
      "POST" => 0),
   "errorRedirectionPage" => "",
   "customErrorMessage" => "",
   "jsPath" => "../js/csrfprotector.js",
   "tokenLength" => 25,
   "disabledJavascriptMessage" => "This site attempts to protect users against <a href=\"https://www.owasp.org/index.php/Cross-Site_Request_Forgery_%28CSRF%29\">
   Cross-Site Request Forgeries </a> attacks. In order to do so, you must have JavaScript enabled in your web browser otherwise this site will fail to work correctly for you.
    See details of your web browser for how to enable JavaScript.",
    "verifyGetFor" => array()
);' > $ROOTTP/includes/libraries/csrfp/libs/csrfp.config.php

# Add apache http redirect entry
ln -sf /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-enabled/
