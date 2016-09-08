FROM docker.dev.pardot.com/base/centos:7

ARG artifactory_host
ARG chefdk_version=0.17.17-1
ARG docker_version=1.12.1-1
# ChefDK ships with an older version of Rubocop. We require features from a later version
ARG rubocop_version=0.41.2
ARG dist=el7

RUN yum install -y gcc make git rsync openssh-clients && \
  yum install -y https://packages.chef.io/stable/el/7/chefdk-${chefdk_version}.${dist}.x86_64.rpm && \
  yum install -y http://yum.dockerproject.org/repo/main/centos/7/Packages/docker-engine-selinux-${docker_version}.${dist}.centos.noarch.rpm && \
  yum install -y http://yum.dockerproject.org/repo/main/centos/7/Packages/docker-engine-${docker_version}.${dist}.centos.x86_64.rpm && \
  chef gem install --no-ri --no-rdoc --no-user-install rubocop -v ${rubocop_version} && \
  ln -sf /opt/chefdk/embedded/bin/rubocop /usr/bin/rubocop && \
  yum clean all
