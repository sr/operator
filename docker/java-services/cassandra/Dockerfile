FROM docker.dev.pardot.com/base/centos:7

ARG artifactory_host
ENV CASSANDRA_HOME=/usr/share/cassandra \
  CASSANDRA_CONF=/etc/cassandra/conf \
  CASSANDRA_INCLUDE=/usr/share/cassandra/cassandra.in.sh \
  JAVA_HOME=/usr/lib/jvm/jre-1.8.0

RUN yum install -y bind-utils java-1.8.0-openjdk

COPY datastax.repo /etc/yum.repos.d/datastax.repo
RUN yum clean metadata && yum install -y datastax-ddc

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

USER cassandra
EXPOSE 7000 9160 9042
CMD ["/usr/sbin/cassandra", "-f"]
