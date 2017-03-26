#!/usr/bin/env bash
set -euo pipefail
set -x

if ! which pip &> /dev/null; then
  cd /tmp
  curl -O https://bootstrap.pypa.io/get-pip.py
  python get-pip.py
fi

pip install --upgrade certifi
pip install --upgrade awscli
pip install --upgrade awsebcli
