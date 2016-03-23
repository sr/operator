#!/bin/bash
set -e

# From /start.sh to bypass dual /teampassinit and /teampass dirs
ROOTTP="/teampass"
mkdir -p $ROOTTP/sk
mv /teampassinit /$ROOTTP/www
chown -Rf www-data.www-data $ROOTTP
rm -rf $ROOTTP/install

# To get db config from docker env
echo "<?php
global \$lang, \$txt, \$k, \$pathTeampas, \$urlTeampass, \$pwComplexity, \$mngPages;
global \$server, \$user, \$pass, \$database, \$pre, \$db, \$port, \$encoding;

### DATABASE connexion parameters ###
\$server = \$_SERVER['MYSQL_SERVER'];
\$user = \$_SERVER['MYSQL_USER'];
\$pass = \$_SERVER['MYSQL_PASSWORD'];
\$database = \$_SERVER['MYSQL_DATABASE'];
\$pre = 'teampass_';
\$port = 3306;
\$encoding = 'utf8';

@date_default_timezone_set(\$_SESSION['settings']['timezone']);
@define('SECUREPATH', '/teampass/www/includes');
require_once '/teampass/www/includes/sk.php';
?>" > /teampass/www/includes/settings.php

/usr/sbin/apache2ctl -D FOREGROUND && tail -f /var/log/apache2/*log
#exec "$@"
