# Database Setup Script

'run.sh' script automates the process of setting up and populating a PostgreSQL database for the project.

## Prerequisites

- PostgreSQL installed and running
- `psql` command-line tool available
- insert database credentials and connection information into `asedb-config.env`

## Files

- `run.sh`: The main shell script for database setup
- `asedb-config.env`: Environment file containing database connection information
- `./scripts/init_tables.sql`: SQL file for creating database tables
- `./scripts/populate_data.sql`: SQL file for inserting sample data

## Setup

1. Ensure all the required files are in their correct locations.
2. Make sure `run.sh` has execute permissions:
   ```
   chmod +x run.sh
   ```
3. Edit the `asedb-config.env` file to set your database connection information:
   ```
   PGHOST=
   PGUSER=
   PGPORT=
   PGPASSWORD=
   PGDATABASE=
   ```

## Caution

This script will drop and recreate the database. Only runs it when you want to reset the database.
