FROM docker.dev.pardot.com/base/centos:7

ARG redis_version=4.0-rc2
ARG artifactory_host
ARG dist=el7
ARG redis_roaring_pkg_ver=1.0.0-1

RUN yum install -y epel-release && \
  yum install -y supervisor less which && \
  yum clean all

RUN yum install -y make gcc && \
  cd /tmp && \
  curl -L https://github.com/antirez/redis/archive/${redis_version}.tar.gz | tar -xvz && \
  cd redis-${redis_version} && \
  make && \
  make install && \
  cd /tmp && \
  rm -rf redis-${redis_version} && \
  rpm -e make gcc && \
  yum clean all

RUN yum --nogpgcheck localinstall -y "https://${artifactory_host}/artifactory/${dist}-pardot-rpms/redis-roaring-${redis_roaring_pkg_ver}.${dist}.centos.x86_64.rpm"

RUN groupadd -r redis -g 533 && \
  useradd -r -g redis -d /var/lib/redis -s /sbin/nologin -c "Redis" -u 533 redis

RUN mkdir -p /var/lib/redis && \
  mkdir -p /etc/redis && \
  mkdir -p /var/lib/redis/{6379,6380} && \
  chown -R redis:redis /var/lib/redis

ADD 6379.conf /etc/redis/6379.conf
ADD 6380.conf /etc/redis/6380.conf

ADD supervisord.conf /etc/supervisord.conf

EXPOSE 6379 6380

CMD ["supervisord", "-n", "-c", "/etc/supervisord.conf"]
