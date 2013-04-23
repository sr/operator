#!/bin/sh
export HUBOT_HIPCHAT_JID="45727_306047@chat.hipchat.com"
export HUBOT_HIPCHAT_NAME="Parbot"
export HUBOT_HIPCHAT_PASSWORD="!Parbot.2013!"
export HUBOT_HIPCHAT_ROOMS="45727_engineering@conf.hipchat.com"
#export HUBOT_HIPCHAT_DEBUG="true"

# Ports to listen on
export HUBOT_CAT_PORT="7778"
export PORT="7777"

# Database settings
export DB_USER="root"
export DB_PASSWORD="poop"
export QUOTE_DATABASE="pardot_quotes"
export RELEASE_DATABASE="pardot_releases"
export KPI_DATABASE="pardot_kpis"

export HUBOT_LOG_LEVEL="debug"  # This helps to see what Hubot is doing

# Supportbot settings
export SUPPORTBOT_ENABLED="false"

# KPIBot settings
export KPIBOT_ENABLED="false"

# Release tracker
export RELEASE_TRACKING_ENABLED="true"

# Fire tracker
export FIRE_RECORDING_ENABLED="false"

# Finally run:
./bin/hubot -a hipchat