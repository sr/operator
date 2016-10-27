#!/bin/bash
set -e

# From /start.sh to bypass dual /teampassinit and /teampass dirs
mkdir -p /teampass/sk
chown -Rf www-data.www-data /teampass/sk
ROOTTP="/teampass/www"
[ -d /teampassinit ] && mv /teampassinit /$ROOTTP
chown -Rf www-data.www-data $ROOTTP

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
?>" > $ROOTTP/includes/settings.php

echo "<?php
@define('SALT', getenv('SALT')); //Never Change it once it has been used !!!!!
@define('COST', '13'); // Don't change this.
@define('AKEY', '');
@define('IKEY', '');
@define('SKEY', '');
@define('HOST', '');" > $ROOTTP/includes/sk.php

/usr/sbin/apache2ctl -D FOREGROUND & 
tail -f /var/log/apache2/*log
exec "$@"
