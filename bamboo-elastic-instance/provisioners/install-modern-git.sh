#!/usr/bin/env bash
set -euo pipefail
set -x

readonly GIT_VERSION="2.12.1"
readonly GIT_CHECKSUM="65d62d10caf317fc1daf2ca9975bdb09dbff874c92d24f9529d29a7784486b43"

yum install -q -y make gcc gettext expat-devel libcurl-devel openssl-devel perl \
  perl-ExtUtils-MakeMaker perl-libintl zlib-devel

rpm -e git || true

cd /tmp
curl -sLo git.tar.gz "https://www.kernel.org/pub/software/scm/git/git-${GIT_VERSION}.tar.gz"
echo "${GIT_CHECKSUM} git.tar.gz" | sha256sum -c
tar -xzf git.tar.gz
cd "git-${GIT_VERSION}"
make BLK_SHA1=1 NO_TCLTK=1 prefix=/usr all
make BLK_SHA1=1 NO_TCLTK=1 prefix=/usr install

cd /tmp
rm -rf git.tar.gz "git-${GIT_VERSION}"
