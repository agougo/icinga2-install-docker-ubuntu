#!/bin/bash

set -euo pipefail
trap 'echo "Error on line $LINENO: $BASH_COMMAND" >&2' ERR

echo "=========================================="
echo "Starting Icinga PostgreSQL initialization"
echo "=========================================="

# Function to run psql commands as postgres user
run_psql() {
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$1" -c "$2"
}

# Function to create database with specific settings
create_database() {
    local dbname=$1
    local owner=$2
    echo "Creating database: $dbname (owner: $owner)"
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname postgres <<-EOSQL
        CREATE DATABASE $dbname
        WITH ENCODING 'UTF8'
        LC_COLLATE='en_US.utf8'
        LC_CTYPE='en_US.utf8'
        TEMPLATE=template0
        OWNER=$owner;
EOSQL
}

# ====================================
# 1. Setup IcingaDB
# ====================================
echo ""
echo "=== 1/4 Setting up IcingaDB ==="
run_psql "postgres" "CREATE USER icingadb WITH PASSWORD 'icingadb';"
create_database "icingadb" "icingadb"
run_psql "icingadb" "CREATE EXTENSION IF NOT EXISTS citext;"

echo "Downloading IcingaDB schema..."
cd /tmp
if command -v curl > /dev/null; then
    curl -fsSL https://raw.githubusercontent.com/Icinga/icingadb/refs/heads/main/schema/pgsql/schema.sql -o icingadb-schema.sql
elif command -v wget > /dev/null; then
    wget -q https://raw.githubusercontent.com/Icinga/icingadb/refs/heads/main/schema/pgsql/schema.sql -O icingadb-schema.sql
else
    echo "ERROR: Neither curl nor wget found!"
    exit 1
fi

if [ -f icingadb-schema.sql ]; then
    echo "Importing IcingaDB schema..."
    export PGPASSWORD=icingadb
    psql -U icingadb -d icingadb -f icingadb-schema.sql
    unset PGPASSWORD
    echo "✓ IcingaDB setup completed"
else
    echo "⚠️  WARNING: Could not download IcingaDB schema"
fi

# ====================================
# 2. Setup Director
# ====================================
echo ""
echo "=== 2/4 Setting up Director ==="
run_psql "postgres" "CREATE DATABASE director WITH ENCODING 'UTF8';"
run_psql "postgres" "CREATE USER director WITH PASSWORD 'director';"
run_psql "director" "CREATE EXTENSION IF NOT EXISTS pgcrypto;"

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "director" <<-EOSQL
    GRANT ALL PRIVILEGES ON DATABASE director TO director;
    GRANT ALL PRIVILEGES ON SCHEMA public TO director;
    GRANT CREATE ON SCHEMA public TO director;
    ALTER DATABASE director OWNER TO director;
EOSQL

echo "✓ Director setup completed"

# ====================================
# 3. Setup Reporting
# ====================================
echo ""
echo "=== 3/4 Setting up Reporting ==="
run_psql "postgres" "CREATE USER reporting WITH PASSWORD 'reporting';"
create_database "reporting" "reporting"
run_psql "postgres" "GRANT ALL PRIVILEGES ON DATABASE reporting TO reporting;"

echo "Downloading Reporting schema..."
if command -v curl > /dev/null; then
    curl -fsSL https://raw.githubusercontent.com/Icinga/icingaweb2-module-reporting/refs/heads/main/schema/pgsql.schema.sql -o reporting-schema.sql
elif command -v wget > /dev/null; then
    wget -q https://raw.githubusercontent.com/Icinga/icingaweb2-module-reporting/refs/heads/main/schema/pgsql.schema.sql -O reporting-schema.sql
fi

if [ -f reporting-schema.sql ]; then
    echo "Importing Reporting schema..."
    export PGPASSWORD=reporting
    psql -U reporting -d reporting -f reporting-schema.sql
    unset PGPASSWORD
    echo "✓ Reporting setup completed"
else
    echo "⚠️  WARNING: Could not download Reporting schema"
fi

# ====================================
# 4. Setup x509
# ====================================
echo ""
echo "=== 4/4 Setting up x509 ==="
run_psql "postgres" "CREATE USER x509 WITH PASSWORD 'x509';"
create_database "x509" "x509"
run_psql "postgres" "GRANT ALL PRIVILEGES ON DATABASE x509 TO x509;"

echo "Downloading x509 schema..."
if command -v curl > /dev/null; then
    curl -fsSL https://raw.githubusercontent.com/Icinga/icingaweb2-module-x509/refs/heads/main/schema/pgsql.schema.sql -o x509-schema.sql
elif command -v wget > /dev/null; then
    wget -q https://raw.githubusercontent.com/Icinga/icingaweb2-module-x509/refs/heads/main/schema/pgsql.schema.sql -O x509-schema.sql
fi

if [ -f x509-schema.sql ]; then
    echo "Importing x509 schema..."
    export PGPASSWORD=x509
    psql -U x509 -d x509 -f x509-schema.sql
    unset PGPASSWORD
    echo "✓ x509 setup completed"
else
    echo "⚠️  WARNING: Could not download x509 schema"
fi

# ====================================
# Cleanup
# ====================================
echo ""
echo "Cleaning up temporary files..."
rm -f /tmp/*.sql

echo ""
echo "=========================================="
echo "Icinga PostgreSQL initialization COMPLETED!"
echo "=========================================="
echo "Created databases and users:"
echo "  ✓ icingadb (user: icingadb, password: icingadb)"
echo "  ✓ director (user: director, password: director)"
echo "  ✓ reporting (user: reporting, password: reporting)"
echo "  ✓ x509 (user: x509, password: x509)"
echo "=========================================="