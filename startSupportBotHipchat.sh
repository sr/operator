#!/bin/sh
export HUBOT_HIPCHAT_JID="45727_308741@chat.hipchat.com"
export HUBOT_HIPCHAT_NAME="Support Bot"
export HUBOT_HIPCHAT_PASSWORD="!Parbot.2013!"
#export HUBOT_HIPCHAT_ROOMS="45727_support@conf.hipchat.com"
export HUBOT_HIPCHAT_ROOMS="45727_supporttest@conf.hipchat.com"
export HUBOT_HIPCHAT_API_KEY='7019554b399f58a4e7fb8892a1f444'
#export HUBOT_HIPCHAT_DEBUG="true"

# Ports to listen on
export HUBOT_CAT_PORT="7891123"
export PORT="7895123"

# Database settings
export DB_USER="root"
export DB_PASSWORD="poop"
export QUOTE_DATABASE="support_quotes"

export HUBOT_LOG_LEVEL="debug"  # This helps to see what Hubot is doing
export HUBOT_IRC_DEBUG="true"

# Set the bot type for permission related items
export BOT_TYPE="supportbot"

# Supportbot settings
export SUPPORTBOT_EXECUTABLE="php /var/www/supportq/symfony"

# Finally run:
./bin/hubot -a hipchat