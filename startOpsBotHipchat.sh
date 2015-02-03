#!/bin/bash
export HUBOT_HIPCHAT_JID="45727_307793@chat.hipchat.com"
export HUBOT_HIPCHAT_NAME="Ops Bot"
export HUBOT_HIPCHAT_PASSWORD="!Parbot@2015!"
export HUBOT_HIPCHAT_ROOMS="45727_ops@conf.hipchat.com"
#export HUBOT_HIPCHAT_API_KEY='33965558fc3c09972af5a4e3edf510'
export HUBOT_HIPCHAT_API_KEY='f6d93713a7b06e2af14570fbeb0062'
#export HUBOT_HIPCHAT_DEBUG="true"

# Ports to listen on
export HUBOT_CAT_PORT="7890"
export PORT="7894"

# Database settings
export DB_USER="bot"
export DB_PASSWORD="BotSnack.2014"
export QUOTE_DATABASE="pardot_quotes"
export RELEASE_DATABASE="pardot_releases"
export KPI_DATABASE="pardot_kpis"

export HUBOT_LOG_LEVEL="debug"  # This helps to see what Hubot is doing

# Set the bot type for permission related items
export BOT_TYPE="parbot"

export BOT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# TODO: should we avoid starting if PID file exists?
echo $$ > /var/run/$BOT_TYPE.pid

# Finally run:
$BOT_PATH/bin/hubot -a hipchat