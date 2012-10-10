#!/bin/sh

# Irc connection settings
export HUBOT_IRC_SERVER="supportbot.pardot.com"
export HUBOT_IRC_ROOMS="#testroom"
export HUBOT_IRC_PORT="7000"
export HUBOT_IRC_USESSL="true"
export HUBOT_IRC_NICK="Parbot"
export HUBOT_IRC_SERVER_FAKE_SSL="true"

# Ports to listen on
export HUBOT_CAT_PORT="7890"
export PORT="7893"

# Database settings
export DB_USER="root"
export DB_PASSWORD="poop"
export QUOTE_DB_DATABASE="pardot_quotes"
export RELEASE_DATABASE="pardot_releases"

export HUBOT_LOG_LEVEL="debug"  # This helps to see what Hubot is doing
export HUBOT_IRC_DEBUG="true"

# Supportbot settings
export SUPPORTBOT_ENABLED="false"

# HoursBot settings
export HOURSBOT_ENABLED="false"

# Release tracker
export RELEASE_TRACKING_ENABLED="true"

# Finally run:
./bin/hubot -a irc