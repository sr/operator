FROM docker.dev.pardot.com/base/centos:6

ARG kafka_version=0.9.0.1
ARG kafka_revision=1
ARG artifactory_host
ENV JAVA_HOME=/usr/java/jre1.7.0_80

RUN ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime

RUN yum install -y epel-release && \
  yum install -y supervisor && \
  yum --nogpgcheck localinstall -y "https://${artifactory_host}/artifactory/pd-yum/jre-7u80-linux-x64.rpm" && \
  yum --nogpgcheck localinstall -y "https://${artifactory_host}/artifactory/pd-stacki/RedHat/RPMS/kafka-${kafka_version}-${kafka_revision}.el6.noarch.rpm" && \
  ln -s "/opt/kafka/kafka_${kafka_version}" "/opt/kafka/current" && \
  yum clean all

RUN mkdir -p /etc/kafka
COPY server.properties /etc/kafka/server.properties

RUN mkdir -p /etc/zookeeper
COPY zookeeper.properties /etc/zookeeper/server.properties

RUN mkdir -p /opt/kafka-data && \
  chown kafka:kafka /opt/kafka-data && \
  mkdir -p /opt/zookeeper && \
  chown kafka:kafka /opt/zookeeper

COPY supervisord.conf /etc/supervisord.conf
COPY entrypoint.sh /entrypoint.sh

VOLUME ["/opt/kafka-data", "/opt/zookeeper"]
EXPOSE 2181 9092
ENTRYPOINT ["/entrypoint.sh"]
CMD ["supervisord", "-n", "-c", "/etc/supervisord.conf"]
