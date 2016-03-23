#!/bin/bash
set -e

# From /start.sh to bypass dual /teampassinit and /teampass dirs
ROOTTP="/teampass"
mkdir -p $ROOTTP/sk
mv /teampassinit /$ROOTTP/www
chown -Rf www-data.www-data $ROOTTP
rm -rf $ROOTTP/www/install

# To get db config from docker env
echo "<?php
global \$lang, \$txt, \$k, \$pathTeampas, \$urlTeampass, \$pwComplexity, \$mngPages;
global \$server, \$user, \$pass, \$database, \$pre, \$db, \$port, \$encoding;

### DATABASE connexion parameters ###
\$server = getenv('MYSQL_SERVER');
\$user = getenv('MYSQL_USER');
\$pass = getenv('MYSQL_PASSWORD');
\$database = getenv('MYSQL_DATABASE');
\$pre = 'teampass_';
\$port = 3306;
\$encoding = 'utf8';

@date_default_timezone_set(\$_SESSION['settings']['timezone']);
@define('SECUREPATH', '/teampass/www/includes');
require_once '/teampass/www/includes/sk.php';
?>" > /teampass/www/includes/settings.php

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
   "jsUrl" => "http://localhost:8080/includes/libraries/csrfp/js/csrfprotector.js",
   "tokenLength" => 25,
   "disabledJavascriptMessage" => "This site attempts to protect users against <a href=\"https://www.owasp.org/index.php/Cross-Site_Request_Forgery_%28CSRF%29\">
   Cross-Site Request Forgeries </a> attacks. In order to do so, you must have JavaScript enabled in your web browser otherwise this site will fail to work correctly for you.
    See details of your web browser for how to enable JavaScript.",
    "verifyGetFor" => array()
);' > /teampass/www/includes/libraries/csrfp/libs/csrfp.config.php

echo "<?php
@define('SALT', getenv('SALT')); //Never Change it once it has been used !!!!!
@define('COST', '13'); // Don't change this.
@define('AKEY', '');
@define('IKEY', '');
@define('SKEY', '');
@define('HOST', '');" > /teampass/www/includes/sk.php

/usr/sbin/apache2ctl -D FOREGROUND & 
tail -f /var/log/apache2/*log
#exec "$@"
