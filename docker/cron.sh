#!/bin/bash
touch /var/log/cron.log
env | grep PULL_HOSTNAME | awk '{print "export " $0;}' > /tmp/.pullhostname.env
cron