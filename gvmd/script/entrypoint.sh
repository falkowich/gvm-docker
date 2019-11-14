#!/bin/bash

set -o pipefail

 export PATH=/opt/gvm/bin:/opt/gvm/sbin:/opt/gvm/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin 


# Check if ssl certs are in place (it's rather late and I will fix this more elegant later[tm])
echo "===> Waiting to get certs ready"
until /opt/gvm/bin/gvm-manage-certs -V -q
do
  /opt/gvm/bin/gvm-manage-certs -af
done


echo "===> Waiting to get psql up and running"
until ls -alh /var/run/postgresql/.s.PGSQL.5432
do
  ls -alh /var/run/postgresql/.s.PGSQL.5432
done


# Check if admin exists, if not create admin
if $(/opt/gvm/sbin/gvmd --get-users | grep -q 'admin') ; then
    echo "---> Admin already exists.."
else
    echo "---> Creating admin with new password"
    /opt/gvm/sbin/gvmd --create-user=admin --password=admin
fi


# Start GVM stuffs
echo "---> Starting GVMD"
gvmd --listen=0.0.0.0 --port=9391 --osp-vt-update=/opt/gvm/var/run/ospd.sock

# WHATTODOWITTHIS?
if [ -z "$BUILD" ]; then
  echo "Tailing logs"
  tail -F /opt/gvm/var/log/gvm/*
fi