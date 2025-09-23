#!/bin/bash
set -e

# Run the main SQL dump from its new location in /app.
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -f /app/dump.sql

echo "Database initialization script completed successfully."

# Create the flag file to signal that the database is fully ready.
touch /tmp/db_init_complete

echo "Healthcheck flag file created at /tmp/db_init_complete."