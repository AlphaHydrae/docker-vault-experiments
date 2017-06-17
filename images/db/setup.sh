#!/usr/bin/env bash

echo "Creating the database user ${DATABASE_USERNAME}"
psql -U "$POSTGRES_USER" -c "CREATE USER ${DATABASE_USERNAME} PASSWORD '${DATABASE_PASSWORD}'"

echo "Creating the database ${DATABASE_NAME}"
createdb -U "$POSTGRES_USER" -O $DATABASE_USERNAME $DATABASE_NAME
