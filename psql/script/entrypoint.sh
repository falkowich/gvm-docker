#!/bin/bash

set -o pipefail

mkdir /var/run/postgresql/ -p ;\
touch /var/run/postgresql/.s.PGSQL.5432 ;\
chmod 0666 /var/run/postgresql/ -R ;\
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

