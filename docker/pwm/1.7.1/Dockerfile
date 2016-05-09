FROM docker.dev.pardot.com/base/centos:7

ARG artifactory_host
ARG pwm_version=1.7.1

RUN yum install -y epel-release && \
  yum install -y tomcat tomcat-webapps tomcat-admin-webapps && \
  yum install -y nginx && \
  yum install -y unzip supervisor && \
  curl -L 'https://github.com/progrium/entrykit/releases/download/v0.4.0/entrykit_0.4.0_Linux_x86_64.tgz' | tar -xzv -C /usr/bin && \
  entrykit --symlink

COPY ca-pardot.crt /etc/pki/tls/certs/ca-pardot.crt

RUN keytool -keystore /etc/pki/java/cacerts \
  -import -file /etc/pki/tls/certs/ca-pardot.crt \
  -noprompt \
  -storepass 'changeit' \
  -alias ca-pardot

RUN mkdir /tmp/pwm && \
  cd /tmp/pwm && \
  curl -O https://${artifactory_host}/artifactory/pd-tarball/pwm/pwm_v${pwm_version}.zip && \
  unzip pwm_v${pwm_version}.zip && \
  mkdir /usr/share/tomcat/webapps/pwm && \
  cp pwm.war /usr/share/tomcat/webapps/pwm && \
  cd /usr/share/tomcat/webapps/pwm && \
  unzip pwm.war && \
  rm -f pwm.war && \
  cd / && \
  chown -R tomcat:tomcat /usr/share/tomcat/webapps/pwm && \
  rm -rf /tmp/pwm

COPY supervisord.conf /etc/supervisord.conf

# tomcat configuration
COPY tomcat.sh /usr/local/bin/tomcat.sh
COPY PwmConfiguration.xml.tmpl /usr/share/tomcat/webapps/pwm/WEB-INF/PwmConfiguration.xml.tmpl

# nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80
ENTRYPOINT [ \
  "render", "/usr/share/tomcat/webapps/pwm/WEB-INF/PwmConfiguration.xml", "--", \
  "supervisord", "-n", "-c", "/etc/supervisord.conf" \
]
