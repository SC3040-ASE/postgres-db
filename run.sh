#!/bin/bash

rm -f database_setup.log

# Load database connection info
set -o allexport
source asedb-config.env
set +o allexport

# Set up logging
LOG_FILE="database_setup.log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "$(date): Starting database setup script"

run_sql_file() {
    echo "$(date): Running SQL file: $1"
    PGPASSWORD=$PGPASSWORD psql -h $PGHOST -p $PGPORT -U $PGUSER -d $PGDATABASE -f $1
    if [ $? -eq 0 ]; then
        echo "$(date): SQL file $1 executed successfully"
    else
        echo "$(date): Error executing SQL file $1"
    fi
}

echo "$(date): Attempting to drop and recreate database $PGDATABASE"
PGPASSWORD=$PGPASSWORD psql -h $PGHOST -p $PGPORT -U $PGUSER -d postgres <<EOF
DROP DATABASE IF EXISTS $PGDATABASE;
CREATE DATABASE $PGDATABASE;
EOF

if [ $? -eq 0 ]; then
    echo "$(date): Database reset completed successfully"
else
    echo "$(date): Error resetting database"
    exit 1
fi

echo "$(date): Creating tables..."
run_sql_file ./scripts/init_tables.sql

echo "$(date): Inserting sample data..."
run_sql_file ./scripts/populate_data.sql

echo "$(date): Database setup completed."
