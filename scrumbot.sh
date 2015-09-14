#!/bin/bash

export HUBOT_HIPCHAT_JID="1_300@conf.btf.hipchat.com"
export HUBOT_HIPCHAT_PASSWORD="3EqCkJbX8ofdx6cTK3jL5Dh5haHPIt8l"
export HUBOT_HIPCHAT_HOST="hipchat.dev.pardot.com"
export HUBOT_HIPCHAT_XMPP_DOMAIN="btf.hipchat.com"
export HUBOT_LOG_LEVEL="info"
export HUBOT_HIPCHAT_ROOMS="1_bottest_2_the_rebot@conf.btf.hipchat.com"

bin/hubot --adapter hipchat
