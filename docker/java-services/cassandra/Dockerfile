FROM docker.dev.pardot.com/base/centos:7

ARG artifactory_host
ENV CASSANDRA_HOME=/usr/share/cassandra \
  CASSANDRA_CONF=/etc/cassandra/conf \
  CASSANDRA_INCLUDE=/usr/share/cassandra/cassandra.in.sh \
  JAVA_HOME=/usr/java/jre1.7.0_80

RUN yum install -y bind-utils && \
  yum --nogpgcheck localinstall -y "https://${artifactory_host}/artifactory/pd-yum/jre-7u80-linux-x64.rpm"

COPY datastax.repo /etc/yum.repos.d/datastax.repo
RUN yum clean metadata && yum install -y dsc20

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

USER cassandra
EXPOSE 7000 9160 9042
CMD ["/usr/sbin/cassandra", "-f"]
