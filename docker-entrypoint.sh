#!/bin/bash
set -e

echo "<?php
global $lang, $txt, $k, $pathTeampas, $urlTeampass, $pwComplexity, $mngPages;
global $server, $user, $pass, $database, $pre, $db, $port, $encoding;

### DATABASE connexion parameters ###
$server = $_SERVER['MYSQL_SERVER'];
$user = $_SERVER['MYSQL_USER'];
$pass = $_SERVER['MYSQL_PASSWORD'];
$database = $_SERVER['MYSQL_DATABASE'];
$pre = 'teampass_';
$port = 3306;
$encoding = 'utf8';

@date_default_timezone_set($_SESSION['settings']['timezone']);
@define('SECUREPATH', '/teampass/www/includes');
require_once '/teampass/www/includes/sk.php';
?>" > teampass/www/includes/settings.php

exec "$@"