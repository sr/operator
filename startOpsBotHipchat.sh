#!/bin/sh
export HUBOT_HIPCHAT_JID="45727_307793@chat.hipchat.com"
export HUBOT_HIPCHAT_NAME="Ops Bot"
export HUBOT_HIPCHAT_PASSWORD="!Parbot.2013!"
export HUBOT_HIPCHAT_ROOMS="45727_ops@conf.hipchat.com"
export HUBOT_HIPCHAT_API_KEY='33965558fc3c09972af5a4e3edf510'
#export HUBOT_HIPCHAT_DEBUG="true"

# Ports to listen on
export HUBOT_CAT_PORT="7890"
export PORT="7894"

# Database settings
export DB_USER="root"
export DB_PASSWORD="poop"
export QUOTE_DATABASE="pardot_quotes"
export RELEASE_DATABASE="pardot_releases"
export KPI_DATABASE="pardot_kpis"

export HUBOT_LOG_LEVEL="debug"  # This helps to see what Hubot is doing

# Set the bot type for permission related items
export BOT_TYPE="parbot"

export BOT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Finally run:
$BOT_PATH/bin/hubot -a hipchat