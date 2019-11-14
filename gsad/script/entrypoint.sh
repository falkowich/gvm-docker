#!/bin/bash

set -o pipefail

gosu gvm export PATH=/opt/gvm/bin:/opt/gvm/sbin:/opt/gvm/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin 
service postgresql restart 

echo "===> Checking if db is ready"
if psql gvmd -c '\q' 2>&1; then
   echo "database is ready"
else
  echo "Creating database gvmd and settings"
  su postgres sh -c "createuser -DRS gvm" ;\
  su postgres sh -c "createdb -O gvm gvmd" ;\
  su postgres sh -c "psql -d gvmd"   << EOSQL
      create role dba with superuser noinherit;
      grant dba to gvm;
      CREATE EXTENSION "uuid-ossp";
EOSQL
fi

# Check if ssl certs are in place (it's rather late and I will fix this more elegant later[tm])
echo "===> Waiting to get certs ready"
until gosu gvm /opt/gvm/bin/gvm-manage-certs -V -q
do
  gosu gvm /opt/gvm/bin/gvm-manage-certs -af
done

# Check if admin exists, if not create admin
if $(gosu gvm /opt/gvm/sbin/gvmd --get-users | grep -q 'admin') ; then
    echo "---> Admin already exists.."
else
    echo "---> Creating admin with new password"
    gosu gvm  /opt/gvm/sbin/gvmd --create-user=admin --password=admin
fi


# Try to start certdata and scapdata sync
#echo "---> Starting Certsync.." ;\
#gosu gvm  /opt/gvm/sbin/greenbone-certdata-sync ;\
#echo "---> Starting Scapsync.." ;\
#gosu gvm  /opt/gvm/sbin/greenbone-scapdata-sync


# Start GVM stuffs
echo "---> Starting GVMD"
gosu gvm gvmd --listen=0.0.0.0 --port=9391 --osp-vt-update=/opt/gvm/var/run/ospd.sock
echo "---> Starting GSAD"
gsad --mlisten=0.0.0.0 --mport=9391

echo "---> Starting ospd-openvas"

gosu gvm ospd-openvas -f --key-file /opt/gvm/var/lib/gvm/private/CA/serverkey.pem \
      --cert-file /opt/gvm/var/lib/gvm/CA/servercert.pem \
      --ca-file /opt/gvm/var/lib/gvm/CA/cacert.pem \
      --pid-file /opt/gvm/var/run/ospd.pid \
      --unix-socket=/opt/gvm/var/run/ospd.sock

# WHATTODOWITTHIS?
if [ -z "$BUILD" ]; then
  echo "Tailing logs"
  tail -F /opt/gvm/var/log/gvm/*
fi