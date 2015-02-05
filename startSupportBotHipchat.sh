#!/bin/bash
export HUBOT_HIPCHAT_JID="1_180@chat.btf.hipchat.com"
export HUBOT_HIPCHAT_NAME="Support Bot"
export HUBOT_HIPCHAT_PASSWORD="STILL WAITING ON THE PASSWORD RESET EMAIL"
export HUBOT_HIPCHAT_ROOMS="1_support@conf.btf.hipchat.com"
export HUBOT_HIPCHAT_API_KEY='f9e237a292b8c3e6fbfa30bf0b687a'
export HUBOT_HIPCHAT_TOKEN='f9e237a292b8c3e6fbfa30bf0b687a'
export HUBOT_HIPCHAT_HOST="hipchat.dev.pardot.com"
export HUBOT_HIPCHAT_XMPP_DOMAIN="btf.hipchat.com"

#export HUBOT_HIPCHAT_DEBUG="true"

# Ports to listen on
export HUBOT_CAT_PORT="7891"
export PORT="7895"

# Database settings
export DB_USER="bot"
export DB_PASSWORD="BotSnack.2014"
export QUOTE_DATABASE="support_quotes"

export HUBOT_LOG_LEVEL="debug"  # This helps to see what Hubot is doing
export HUBOT_IRC_DEBUG="true"

# Set the bot type for permission related items
export BOT_TYPE="supportbot"

# Supportbot settings
export SUPPORTBOT_EXECUTABLE="php /var/www/supportq/symfony"

export BOT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# TODO: should we avoid starting if PID file exists?
echo $$ > /var/run/$BOT_TYPE.pid

# Finally run:
$BOT_PATH/bin/hubot -a hipchat