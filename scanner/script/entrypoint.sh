#!/bin/bash

set -o pipefail


service postgresql restart 

# Start GVM stuffs
echo "---> Starting ospd-openvas"
ospd-openvas -pid-file /opt/gvm/var/run/ospd/ospd.pid \
      --unix-socket=/opt/gvm/var/run/ospd/ospd.sock


# WHATTODOWITTHIS?
if [ -z "$BUILD" ]; then
  echo "Tailing logs"
  tail -F /opt/gvm/var/log/gvm/*
fi