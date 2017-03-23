#!/usr/bin/env bash
set -euo pipefail

cd /home/bamboo/bamboo-agent-home/xml-data/build-dir
find . -maxdepth 1 -type d -mmin +180 -print0 | xargs -0 rm -rf
