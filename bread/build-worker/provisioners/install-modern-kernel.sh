#!/usr/bin/env bash
set -euo pipefail
set -x

readonly KERNEL_VERSION="4.4.55"

rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org && \
  rpm -Uvh --replacepkgs http://www.elrepo.org/elrepo-release-7.0-2.el7.elrepo.noarch.rpm && \
  yum clean metadata && \
  yum --enablerepo=elrepo-kernel install -q -y "kernel-lt-${KERNEL_VERSION}" "kernel-lt-devel-${KERNEL_VERSION}"

grub2-set-default "$(grep "^menuentry" /boot/grub2/grub.cfg | \
  cut -d "'" -f2 | \
  grep "$KERNEL_VERSION" | \
  head -1)"
