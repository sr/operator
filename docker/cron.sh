#!/bin/bash
touch /var/log/cron.log
env | grep PULL_HOSTNAME | awk '{print "export " $0;}' > /tmp/.pullhostname.env
# CMD crond -n # on CentOS, cron -f # on Ubuntu for running in fg
cron
