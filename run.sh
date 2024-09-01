#!/bin/bash

rm -f database_setup.log

# Load database connection info and Azure AI settings
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



echo "$(date): Attempting to create pgvector and azure_ai extensions"
PGPASSWORD=$PGPASSWORD psql -h $PGHOST -p $PGPORT -U $PGUSER -d $PGDATABASE <<EOF
CREATE EXTENSION IF NOT EXISTS azure_ai;
CREATE EXTENSION IF NOT EXISTS vector;
select azure_ai.set_setting('azure_openai.endpoint','$AZURE_OPENAI_ENDPOINT');
select azure_ai.set_setting('azure_openai.subscription_key', '$AZURE_OPENAI_SUBSCRIPTION_KEY');
EOF

if [ $? -eq 0 ]; then
    echo "$(date): pgvector and azure_ai extensions created successfully"
else
    echo "$(date): Error creating pgvector and azure_ai extensions"
    exit 1
fi



echo "$(date): Creating tables..."
run_sql_file ./scripts/1_init_tables.sql

echo "$(date): Inserting sample data..."
run_sql_file ./scripts/2_create_functions.sql

echo "$(date): Creating functions..."
run_sql_file ./scripts/3_create_triggers.sql

# echo "$(date): Creating functions..."
# run_sql_file ./scripts/4_populate_data.sql

echo "$(date): Database setup completed."
