 
#!/bin/bash
set -e

echo "Creating database gvmd and settings"
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE ROLE dba WITH SUPERUSER NOINHERIT;
    GRANT dba to gvm;
    CREATE EXTENSION "uuid-ossp";
EOSQL
