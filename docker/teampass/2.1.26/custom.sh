#!/bin/bash
set -e
ROOTTP="/teampass/www"

# We don't want to run the installer
rm -rf $ROOTTP/install

# To get db config from docker env
echo "<?php
global \$lang, \$txt, \$k, \$pathTeampas, \$urlTeampass, \$pwComplexity, \$mngPages;
global \$server, \$user, \$pass, \$database, \$pre, \$db, \$port, \$encoding;

### DATABASE connexion parameters ###
\$server = getenv('MYSQL_SERVER');
\$user = getenv('MYSQL_USER');
\$pass = getenv('MYSQL_PASSWORD');
\$database = getenv('MYSQL_DATABASE');
\$pre = \"teampass_\";
\$port = 3306;
\$encoding = \"utf8\";

@date_default_timezone_set(\$_SESSION['settings']['timezone']);
@define('SECUREPATH', '/teampass/www/includes');
require_once \"/teampass/www/includes/sk.php\";
@define('COST', '13'); // Don't change this.
?>" > $ROOTTP/includes/config/settings.php

echo "<?php
@define('SALT', getenv('SALT')); //Never Change it once it has been used !!!!!
@define('COST', '13'); // Don't change this.
@define('AKEY', '');
@define('IKEY', '');
@define('SKEY', '');
@define('HOST', '');
?>" > $ROOTTP/includes/sk.php

# No need to hardcode the full url
sed -i "s/self::\$config\['jsUrl'\]/'\/includes\/libraries\/csrfp\/js\/csrfprotector\.js'/" $ROOTTP/includes/libraries/csrfp/libs/csrf/csrfprotector.php

# Fix really short password show timeout 50ms to 10s
sed -i "s/, 50/, 10000/" $ROOTTP/items.load.php

# PHP sessions need to be garbage collected, otherwise we run out of inodes
#sed -i "s/session.gc_probability = 0/session.gc_probability = 1/" /etc/php.ini

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
   "jsUrl" => "unused",
   "tokenLength" => 50,
   "disabledJavascriptMessage" => "This site attempts to protect users against <a href=\"https://www.owasp.org/index.php/Cross-Site_Request_Forgery_%28CSRF%29\">
   Cross-Site Request Forgeries </a> attacks. In order to do so, you must have JavaScript enabled in your web browser otherwise this site will fail to work correctly for you.
    See details of your web browser for how to enable JavaScript.",
    "verifyGetFor" => array("*page=items&type=duo_check*", "*upload.attachments.php*")
);' > $ROOTTP/includes/libraries/csrfp/libs/csrfp.config.php
