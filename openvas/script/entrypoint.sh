#!/bin/bash

set -o pipefail


# Start GVM stuffs
echo "---> Starting ospd-openvas"
/opt/gvm/bin/ospd-scanner/bin/python /opt/gvm/bin/ospd-scanner/bin/ospd-openvas \
                                      --pid-file /opt/gvm/var/run/ospd-openvas.pid \
                                      --unix-socket=/opt/gvm/var/run/ospd.sock \
                                      --log-file /opt/gvm/var/log/gvm/ospd-scanner.log

# WHATTODOWITTHIS?
if [ -z "$BUILD" ]; then
  echo "Tailing logs"
  tail -F /opt/gvm/var/log/gvm/*
fi