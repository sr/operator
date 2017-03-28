FROM docker.dev.pardot.com/base/centos:7

ARG artifactory_host

# Based on concepts from <https://github.com/avsm/docker-ssh-agent-forward>,
# creates a container whose job is to expose an SSH agent for use with Docker
# for Mac.

RUN yum install -y openssh-clients openssh-server && \
  yum clean all

RUN mkdir -p /root/.ssh

COPY entrypoint.sh /entrypoint.sh

EXPOSE 22
VOLUME ["/root/.ssh/authorized_keys"]
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/sbin/sshd", "-D"]
