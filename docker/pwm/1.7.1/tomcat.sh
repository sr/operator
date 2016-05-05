#!/bin/bash

if [ -r /usr/share/java-utils/java-functions ]; then
  . /usr/share/java-utils/java-functions
else
  echo "Can't read Java functions library, aborting"
  exit 1
fi

# Get the tomcat config (use this for environment specific settings)
if [ -z "${TOMCAT_CFG}" ]; then
  TOMCAT_CFG="/etc/tomcat/tomcat.conf"
fi

if [ -r "$TOMCAT_CFG" ]; then
  . $TOMCAT_CFG
fi

# Get instance specific config file
if [ -r "/etc/sysconfig/tomcat" ]; then
    . /etc/sysconfig/tomcat
fi

set_javacmd
cd ${CATALINA_HOME}
# CLASSPATH munging
if [ ! -z "$CLASSPATH" ] ; then
  CLASSPATH="$CLASSPATH":
fi

if [ -n "$JSSE_HOME" ]; then
  CLASSPATH="${CLASSPATH}$(build-classpath jcert jnet jsse 2>/dev/null):"
fi
CLASSPATH="${CLASSPATH}${CATALINA_HOME}/bin/bootstrap.jar"
CLASSPATH="${CLASSPATH}:${CATALINA_HOME}/bin/tomcat-juli.jar"
CLASSPATH="${CLASSPATH}:$(build-classpath commons-daemon 2>/dev/null)"

${JAVACMD} $JAVA_OPTS $CATALINA_OPTS \
  -classpath "$CLASSPATH" \
  -Dcatalina.base="$CATALINA_BASE" \
  -Dcatalina.home="$CATALINA_HOME" \
  -Djava.endorsed.dirs="$JAVA_ENDORSED_DIRS" \
  -Djava.io.tmpdir="$CATALINA_TMPDIR" \
  -Djava.util.logging.config.file="${CATALINA_BASE}/conf/logging.properties" \
  -Djava.util.logging.manager="org.apache.juli.ClassLoaderLogManager" \
  org.apache.catalina.startup.Bootstrap start
