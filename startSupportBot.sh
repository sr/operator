#!/bin/sh

# Irc connection settings
export HUBOT_IRC_SERVER="supportbot.pardot.com"
export HUBOT_IRC_ROOMS="#support"
export HUBOT_IRC_PORT="7000"
export HUBOT_IRC_USESSL="true"
export HUBOT_IRC_NICK="SupportBot"
export HUBOT_IRC_SERVER_FAKE_SSL="true"

# Ports to listen on
export HUBOT_CAT_PORT="7894"
export PORT="7895"

# Database settings
export DB_USER="root"
export DB_PASSWORD="poop"
export QUOTE_DATABASE="support_quotes"

export HUBOT_LOG_LEVEL="debug"  # This helps to see what Hubot is doing
export HUBOT_IRC_DEBUG="true"

# Supportbot settings
export SUPPORTBOT_ENABLED="true"
export SUPPORTBOT_EXECUTABLE="php /var/www/supportq/symfony"

# KPIBot settings
export KPIBOT_ENABLED="false"

# Release tracker
export RELEASE_TRACKING_ENABLED="false"

# Finally run:
./bin/hubot -a irc