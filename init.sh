#!/bin/bash

# NOTE: run "chmod +x init.sh" once before first use

set -e # Exit immediately if a command exits with a non-zero status
set -u # Treat unset variables as an error

# Load environment variables 
if [ ! -f .env ]; then
  echo "ERROR: .env file not found. Copy .env.example and fill in your values."
  exit 1
fi

source .env

# Start the stack
echo "Starting Docker Compose stack..."
docker compose up -d

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL to be ready..."
until docker exec postgres_server pg_isready -U "$POSTGRES_USER" -d "$POSTGRES_DB" > /dev/null 2>&1; do
  echo "  ...not ready yet, retrying in 2s"
  sleep 2
done
echo "PostgreSQL is ready."

# Create the server_admin database (skip if it already exists) ─
echo "Setting up server_admin database..."

DB_EXISTS=$(docker exec postgres_server psql -U "$POSTGRES_USER" -tAc \
  "SELECT 1 FROM pg_database WHERE datname = 'server_admin'")

if [ "$DB_EXISTS" = "1" ]; then
  echo "  server_admin already exists, skipping creation."
else
  docker exec postgres_server psql -U "$POSTGRES_USER" -c \
    "CREATE DATABASE server_admin OWNER ${POSTGRES_USER} ENCODING 'UTF8' TEMPLATE template0;"
  docker exec postgres_server psql -U "$POSTGRES_USER" -c \
    "REVOKE ALL ON DATABASE server_admin FROM PUBLIC;"
  echo "  server_admin created."
fi

# Run SQL init files against server_admin 
echo "Running SQL files..."

for file in database/*.sql; do
  # Skip empty files
  if [ ! -s "$file" ]; then
    echo "  Skipping empty file: $file"
    continue
  fi

  echo "  Running $file..."
  docker exec -i postgres_server psql -U "$POSTGRES_USER" -d server_admin < "$file"
done

# Done
echo ""
echo "Setup complete!"
echo "pgAdmin is available at: http://localhost:${PGADMIN_PORT_HOST}"