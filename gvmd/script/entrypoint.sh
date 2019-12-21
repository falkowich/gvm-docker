#!/bin/bash

set -o pipefail

# TODO fix paths somehow instead of this crap..
export PATH=/opt/gvm/bin:/opt/gvm/sbin:/opt/gvm/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin 
su - gvm sh -c "export PATH=/opt/gvm/bin:/opt/gvm/sbin:/opt/gvm/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

echo "===> Waiting for REDIS service"
service redis-server restart
while [ ! -e /var/run/redis-openvas/redis.sock ]
do
  service redis-server restart
  sleep 2
done


X="$(redis-cli -s /var/run/redis-openvas/redis.sock ping)"
while  [ "${X}" != "PONG" ]; do
        echo "Redis not yet ready..."
        sleep 1
        X="$(redis-cli -s /var/run/redis-openvas/redis.sock ping)"
done

# Check if ssl certs are in place (it's rather late and I will fix this more elegant later[tm])
echo "===> Waiting to get certs ready"
until su - gvm sh -c "/opt/gvm/bin/gvm-manage-certs -V -q"
do
  su - gvm sh -c "/opt/gvm/bin/gvm-manage-certs -af"
done

# TODO Create better startup for postgresql

service postgresql restart 


# TODO Create working check

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


# TODO Create better startup for postgresql again....
service postgresql restart 


echo "===> Waiting to get psql up and running"
until ls -alh /var/run/postgresql/.s.PGSQL.5432
do
  ls -alh /var/run/postgresql/.s.PGSQL.5432
done


# Check if admin exists, if not create admin
echo "===> Checking if admin user exists"
if $(su - gvm sh -c "/opt/gvm/sbin/gvmd --get-users | grep -q 'admin'") ; then
    echo "---> Admin already exists.."
else
    echo "---> Creating admin with new password"
    su - gvm sh -c "/opt/gvm/sbin/gvmd --create-user=admin --password=admin"
fi


# Start GVM stuffs
echo "---> Starting GVMD"
su - gvm sh -c "/opt/gvm/sbin/gvmd --listen=0.0.0.0 --port=9391 --osp-vt-update=/opt/gvm/var/run/ospd.sock"


# TODO What to do with exports..
echo "---> Starting ospd-openvas"
su - gvm sh -c "export PATH=/opt/gvm/bin:/opt/gvm/sbin:/opt/gvm/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin ;\
                /opt/gvm/bin/ospd-scanner/bin/python /opt/gvm/bin/ospd-scanner/bin/ospd-openvas \
                                      --pid-file /opt/gvm/var/run/ospd-openvas.pid \
                                      --unix-socket=/opt/gvm/var/run/ospd.sock \
                                      --log-file /opt/gvm/var/log/gvm/ospd-scanner.log"


echo "---> Starting GSAD"
/opt/gvm/sbin/gsad --mlisten=0.0.0.0 --mport=9391


# TODO Create check that sock is up before starting
echo "---> Creating scanner"
su - gvm sh -c "export PATH=/opt/gvm/bin:/opt/gvm/sbin:/opt/gvm/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin ;\
                gvmd --create-scanner='TEST OPENVAS Scanner' --scanner-type='OpenVas' --scanner-host=/opt/gvm/var/run/ospd.sock"

# WHATTODOWITTHIS?
if [ -z "$BUILD" ]; then
  echo "Tailing logs"
  tail -F /opt/gvm/var/log/gvm/*
fi