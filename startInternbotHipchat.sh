#!/bin/sh

echo "GOTO THECLOUD # internbot is a separate project these days"
exit 1

export HUBOT_HIPCHAT_JID="45727_306060@chat.hipchat.com"
export HUBOT_HIPCHAT_PASSWORD="P4RD07"
export HUBOT_HIPCHAT_NAME="Intern Bot"
export HUBOT_HIPCHAT_ROOMS="45727_engineering@conf.hipchat.com"
export HUBOT_HIPCHAT_API_KEY='33965558fc3c09972af5a4e3edf510'
export HUBOT_HIPCHAT_TOKEN='33965558fc3c09972af5a4e3edf510'
#export HUBOT_HIPCHAT_DEBUG="true"

export HUBOT_LOG_LEVEL="debug"  # This helps to see what Hubot is doing

# Set the bot type for permission related items
export BOT_TYPE="internbot"

export TWITTER_CONSUMER_KEY='Gk66I5eFsB2LD9uxRFayjA'
export TWITTER_CONSUMER_SECRET='muTHNzlTltgekd9dzIP3pwneMh0DWGSCpPCuB8UZ5Y8'
export TWITTER_ACCESS_TOKEN='21393149-bKTd17d3vaX9rKOh30L8X78YI3yXDQVoIdBigxPJc'
export TWITTER_ACCESS_TOKEN_SECRET='lVP2KugUCTEfxpYlzNqw3dKlD5j00OGCHMpUXF0hY'

export MEMEGENERATOR_USERNAME='asuahInternbot'
export MEMEGENERATOR_PASSWORD='internbot'

# Database settings
export DB_USER="bot"
export DB_PASSWORD="BotSnack.2014"
export QUOTE_DATABASE="pardot_quotes"
export RELEASE_DATABASE="pardot_releases"
export KPI_DATABASE="pardot_kpis"

export BOT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# TODO: should we avoid starting if PID file exists?
echo $$ > /var/run/$BOT_TYPE.pid

# Finally run:
$BOT_PATH/bin/hubot -a hipchat
